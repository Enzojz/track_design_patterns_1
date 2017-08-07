local paramsutil = require "paramsutil"
local func = require "flyingjunction/func"
local coor = require "flyingjunction/coor"
local trackEdge = require "flyingjunction/trackedge"
local line = require "flyingjunction/coorline"
local arc = require "flyingjunction/coorarc"
local station = require "flyingjunction/stationlib"
local pipe = require "flyingjunction/pipe"
local junction = require "junction"
local jA = require "junction_assoc"
local jM = require "junction_main"

local rList = {junction.infi * 0.001, 5, 3, 2, 1.5, 1, 0.75, 0.5, 2 / 3, 0.4, 1 / 3, 1 / 4, 1 / 5, 1 / 6, 1 / 7, 1 / 8, 1 / 9, 0.1}
local slopeList = {15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70}
local heightList = {11, 10, 9, 8, 7, 6, 5, 4, 3}

local function params()
    return {
        paramsutil.makeTrackTypeParam(),
        paramsutil.makeTrackCatenaryParam(),
        {
            key = "nbTracks",
            name = _("Number of tracks"),
            values = {_("1"), _("2"), _("3"), _("4"), _("5"), _("6"), },
            defaultIndex = 1
        },
        {
            key = "radius",
            name = _("Radius") .. ("(m)"),
            values = pipe.from("∞") + func.map(func.range(rList, 2, #rList), function(r) return tostring(math.floor(r * 1000 + 0.5)) end),
            defaultIndex = #rList - 1
        },
        {
            key = "isMir",
            name = _("Mirrored"),
            values = {_("No"), _("Yes")},
            defaultIndex = 0
        },
        {
            key = "slope",
            name = _("Slope(‰)"),
            values = func.map(slopeList, tostring),
            defaultIndex = #slopeList - 1
        },
        {
            key = "isDescding",
            name = _("Direction"),
            values = {"↗", "↘"},
            defaultIndex = 0
        },
        {
            key = "dz",
            name = _("ΔHeight") .. ("(m)"),
            values = func.map(heightList, tostring),
            defaultIndex = 3
        }
    }

end


local composite = function(config)
    local offsets = junction.buildCoors(config.nbTracks, config.nbTracks)
    local guideline = arc.byOR(coor.xyz(config.r, 0, 0), math.abs(config.r))
    
    local tracks = offsets.tracks * pipe.map(function(o) return guideline + o end)
        * pipe.map(function(tr)
            local fn = jA.retriveFn(config)
            return {
                guidelines = fn.retriveArc(tr),
                fn = fn,
                config = config,
            }
        end)
    
    local walls = offsets.walls * pipe.map(function(o) return guideline + o end)
        * pipe.map(function(wa)
            local fn = jA.retriveFn(config)
            return {
                guidelines = fn.retriveArc(wa),
                fn = fn,
                config = config,
            }
        end)
    
    return {
        edges = jA.retriveTracks(tracks),
        polys = jA.retrivePolys(tracks, 1),
        surface = jA.retriveTrackSurfaces(tracks),
        walls = jA.retriveWalls(walls)
    }
end

local function defaultParams(param)
    local function limiter(d, u)
        return function(v) return v and v < u and v or d end
    end
    
    func.forEach(params(), function(i)param[i.key] = limiter(i.defaultIndex or 0, #i.values)(param[i.key]) end)
end

local updateFn = function(models)
    return function(params)
        defaultParams(params)
        
        local trackType = ({"standard.lua", "high_speed.lua"})[params.trackType + 1]
        local catenary = params.catenary == 1
        local trackBuilder = trackEdge.builder(catenary, trackType)
        local sFactor = params.isDescding == 1 and 1 or -1
        local height = sFactor * heightList[params.dz + 1]
        
        local nbTracks = params.nbTracks + 1
        local r = (params.isMir == 0 and 1 or -1) * rList[params.radius + 1] * 1000
        
        local surface = composite({
            initRad = r > 0 and math.pi or 0,
            slope = jA.generateSlope(sFactor * slopeList[params.slope + 1] * 0.001, height),
            height = height,
            r = r,
            nbTracks = nbTracks,
            radFactor = 1,
            models = models
        })
        
        local underground = composite({
            initRad = r > 0 and math.pi or 0,
            slope = jA.generateSlope(-sFactor * slopeList[params.slope + 1] * 0.001, -0.75 * height, 1.75 * height),
            height = 0.5 * height,
            r = r,
            nbTracks = nbTracks,
            radFactor = -1,
            models = models
        })
        return
            {
                edgeLists = {
                    station.fusionEdges({
                        surface.edges.inf,
                        surface.edges.main
                    }
                    ) * pipe.map(station.mergeEdges) * station.prepareEdges * trackBuilder.nonAligned(),
                    station.fusionEdges({
                        underground.edges.main,
                        underground.edges.sup
                    }
                    ) * pipe.map(station.mergeEdges) * station.prepareEdges * trackBuilder.tunnel()
                },
                models = (surface.walls + surface.surface) * pipe.flatten(),
                terrainAlignmentLists = jM.mergePoly({
                    equal = jM.projectPolys(coor.I())(surface.polys.polys),
                    slot = jM.projectPolys(coor.I())(surface.polys.trackPolys),
                })
            }
    end
end

return {
    updateFn = updateFn,
    params = params
}
