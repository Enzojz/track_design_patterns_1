local paramsutil = require "paramsutil"
local func = require "track_design_patterns/func"
local coor = require "track_design_patterns/coor"
local arc = require "track_design_patterns/coorarc"
local trackEdge = require "track_design_patterns/trackedge"
local station = require "track_design_patterns/stationlib"
local pipe = require "track_design_patterns/pipe"
local tdp = require "track_design_patterns"

local math = math
local abs = math.abs
local pi = math.pi
local atan = math.atan
local acos = math.acos
local cos = math.cos
local sin = math.sin
local tan = math.tan
local unpack = table.unpack

local slopeList = pipe.new * {2.5, 5, 7.5, 10, 12.5, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 90, 100}
slopeList = slopeList * pipe.map(pipe.neg()) + {0} + slopeList
local wallList = {
    "track_design_patterns/concrete_wall",
    "track_design_patterns/brick_wall",
    "track_design_patterns/arch_wall",
    "track_design_patterns/track_multi_lod_0_sound_insulation_10m"
}
local wallHeightList = {15, 15, 15, 8}
local wallLengthList = {5, 5, 5, 10}
local wallWidthList = {0.5, 0.5, 0.5, 0.4}
local wallTransList = {
    function(h) return coor.transZ((h > 0 and h or 0) - 10) end,
    function(h) return coor.transZ((h > 0 and h or 0) - 10) end,
    function(h) return coor.transZ((h > 0 and h or 0) - 10) end,
    function(h) return coor.transZ((h > 8 and 8 or abs(h)) - 5.1) end
}

local sizeSwitch = {4, 5, 6, 7, 9, 12, 14, 16, 18}

local function params()
    local sp = "·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·\n"
    return tdp.trackType + {
        {
            key = "cot",
            name = _("Turnout #"),
            uiType = "SLIDER",
            values = func.map(func.map(sizeSwitch, math.floor), tostring),
            defaultIndex = 5
        },
        {
            key = "nbTracks",
            name = _("Number of tracks"),
            values = func.seqMap({1, 10}, tostring),
            defaultIndex = 0
        },
        {
            key = "distance",
            name = _("Track Distance"),
            values = {"5", "9", "10"},
            defaultIndex = 0,
        },
        {
            key = "isOpen",
            name = _("Last Section"),
            values = {_("Open"), _("Closed")},
            defaultIndex = 0,
        },
        {
            key = "orientation",
            name = _("Orientaion"),
            values = {_("Left"), _("Right")},
            defaultIndex = 1,
        },
        {
            key = "slope",
            name = _("Slope") .. "(‰)",
            values = func.map(slopeList, tostring),
            uiType = "SLIDER",
            defaultIndex = (#slopeList -1 ) * 0.5
        },
        {
            key = "wallAHeight",
            name = _("Wall A") .. " " .. _("Height") .. " " .. _("(m)"),
            values = pipe.new * {"↓", _("None")} + func.seqMap({1, 15}, tostring),
            uiType = "SLIDER",
            defaultIndex = 1
        },
        {
            key = "wallAType",
            name = _("Wall A") .. " " .. _("Type"),
            values = {_("Concrete"), _("Stone brick"), _("Arch")},
            defaultIndex = 0
        },
        {
            key = "wallBHeight",
            name = _("Wall B") .. " " .. _("Height") .. " " .. _("(m)"),
            values = pipe.new * {_("Sync"), "↓", _("None")} + func.seqMap({1, 15}, tostring),
            uiType = "SLIDER",
            defaultIndex = 0
        },
        {
            key = "wallBType",
            name = _("Wall B") .. " " .. _("Type"),
            values = {_("Sync"), _("Concrete"), _("Stone brick"), _("Arch")},
            defaultIndex = 0
        },
        {
            key = "wallOffset",
            name = _("Wall-Track distance") .. " " .. _("(m)"),
            values = func.seqMap({0, 8}, function(n) return tostring(n * 0.5) end),
            defaultIndex = 1
        },
        {
            key = "freeNodes",
            name = _("Free tracks"),
            values = {_("No"), _("Yes"), _("Not build")},
            defaultIndex = 1
        }
    }
end

local function defaultParams(param)
    local function limiter(d, u)
        return function(v) return v and v < u and v or d end
    end
    func.forEach(params(), function(i)param[i.key] = limiter(i.defaultIndex or 0, #i.values)(param[i.key]) end)
end

local updateFn = function(params, closureParams)
    local trackList = closureParams.trackList
    local trackType = trackList[params.trackType + 1]
    
    defaultParams(params)
    local catenary = params.catenary == 1
    local trackBuilder = trackEdge.builder(catenary, trackType)
    local nbTracks = params.nbTracks + 1
    local wallOffset = params.wallOffset * 0.5 + 0.2
    local slope = slopeList[params.slope + 1] * 0.001
    local isOpen = params.isOpen == 0
    local distance = ({5, 9, 10})[params.distance + 1]
    
    local cot = sizeSwitch[params.cot + 1]
    local rad = atan(1 / cot)
    local w = 1.435
    local r = w / (1 - cos(rad)) - w * 0.5
    
    local guidelines = {
        l = arc.byOR(coor.xy(tdp.infi, 0), tdp.infi),
        r = arc.byOR(coor.xy(r, 0), r),
    }
    
    local dy, ept, vec, ipt = unpack(cot < 5 and
        pipe.exec * function()
            local rad = acos(1 - distance * 0.5 / r)
            local vec = coor.xyz(sin(rad), cos(rad), 0)
            local ept = coor.xyz(distance * 0.5, r * sin(rad), 0)
            local ipt = ept
            local dy = distance / sin(rad)
            return {dy, ept, vec, ipt}
        end
        or
        pipe.exec * function()
            local vec = coor.xyz(sin(rad), cos(rad), 0)
            local ept = coor.xyz(distance * 0.5, r * sin(rad) + (distance * 0.5 - (r - r * cos(rad))) / tan(rad), 0)
            local ipt = ept - vec * 0.5 * (distance - w) * 0.5 / tan(rad)
            local dy = distance / sin(rad)
            return {dy, ept, vec, ipt}
        end
    )
    local turnouts =
        cot < 5
        and pipe.new
        / {coor.xyz(0, 0, 0), ept, coor.xyz(0, 1, 0), vec}
        or pipe.new
        / {coor.xyz(0, 0, 0), ipt, coor.xyz(0, 1, 0), vec}
        / {ipt, ept + vec * 5, vec, vec}
    
    local fz = function(pt) return coor.xyz(pt.x, pt.y, pt.y * slope) end
    
    local trY = function(e, n)
        return e * pipe.mapi(function(e) return {e[1] .. coor.transY(n * dy), e[2] .. coor.transY(dy * n), e[3], e[4]} end)
            * pipe.map(pipe.map(fz))
    end
    
    local edge =
        (
        pipe.new * func.seq(0, nbTracks - 1) * pipe.map(function(n)
            return {
                edge = trY(turnouts, n),
                snap = cot < 5 and pipe.new / {false, true} or pipe.new / {false, false} / {false, true}
            }
        end)
        +
        pipe.new * func.seq(0, nbTracks - 2) * pipe.map(function(n)
            return {
                edge = trY(pipe.new / {coor.xyz(0, 0, 0), coor.xyz(0, dy, 0), coor.xyz(0, 1, 0), coor.xyz(0, 1, 0)}, n),
                snap = pipe.new / {false, false}
            }
        end)
        / {
            edge = (pipe.new
            / {coor.xyz(0, -5, 0), coor.xyz(0, 0, 0), coor.xyz(0, 1, 0), coor.xyz(0, 1, 0)}
            + (isOpen and {{coor.xyz(0, dy * nbTracks - dy, 0), coor.xyz(0, dy * nbTracks + 5, 0), coor.xyz(0, 1, 0), coor.xyz(0, 1, 0)}} or {})
            ) * pipe.map(pipe.map(fz)),
            snap = pipe.new * (isOpen and {{true, false}, {false, true}} or {{true, false}})
        }
        )
        * station.mergeEdges
    
    
    
    
    guidelines.r = pipe.exec * function()
        local rm = guidelines.r:withLimits(
            {
                sup = guidelines.r:rad(ipt),
                mid = guidelines.r:rad(coor.xy(0, 0)),
                inf = guidelines.r:rad(coor.xy(0, -1))
            }
        )
        local ext = arc.byOR(ipt - (ipt - guidelines.r.o):normalized() * tdp.infi, tdp.infi)
        ext = ext:withLimits(
            {
                sup = ext:rad(ept + vec * 5),
                mid = ext:rad(ipt),
                inf = ext:rad(ipt * 2),
            }
        )
        return pipe.new / rm / ext
    end
    
    guidelines.l = pipe.new /
        guidelines.l:withLimits(
            {
                sup = guidelines.l:rad(coor.xy(0, (nbTracks - 1) * dy)),
                mid = guidelines.l:rad(coor.xy(0, -5)),
                inf = guidelines.l:rad(coor.xy(0, 0))
            }
        )
        + (
        isOpen
        and pipe.new /
        guidelines.l:withLimits(
            {
                sup = guidelines.l:rad(coor.xy(0, nbTracks * dy + 5)),
                mid = guidelines.l:rad(coor.xy(0, (nbTracks - 1) * dy)),
                inf = guidelines.l:rad(coor.xy(0, -1))
            }
        )
        or func.map(guidelines.r, function(g) return arc.byOR(g.o + coor.xy(0, (nbTracks - 1) * dy), g.r):withLimits(g:limits()) end)
    )
    local wallOffsets = {
        l = -2.5 - 0.25,
        r = 2.5 + 0.25
    }
    
    local retriveWall = {
        A = function(ls) return ls[params.wallAType + 1] end,
        B = function(ls) return params.wallBType == 0 and ls[params.wallAType + 1] or ls[params.wallBType] end
    }
    local wallHeight = {
        A = func.seq(-1, 15)[params.wallAHeight + 1],
        B = params.wallBHeight == 0 and func.seq(-1, 15)[params.wallAHeight + 1] or func.seq(-1, 15)[params.wallBHeight]
    }
    
    local fzg = function(g) return function(rad) return {z = g:pt(rad).y * slope, s = slope} end end
    
    local function mPlace(fz, mZ)
        return function(fitModel, arcL, arcR, rad1, rad2)
            local z1, z2 = fz(rad1).z, fz(rad2).z
            local size = {
                lb = arcL:pt(rad1):withZ(z1),
                lt = arcL:pt(rad2):withZ(z2),
                rb = arcR:pt(rad1):withZ(z1),
                rt = arcR:pt(rad2):withZ(z2)
            }
            return mZ * fitModel(size)
        end
    end
    
    local makeWallA = function(fz)
        return
            tdp.makeFn(wallHeight.A < 0)(
                retriveWall.A(wallList),
                tdp.fitModel,
                mPlace(
                    fz,
                    retriveWall.A(wallTransList)(wallHeight.A)
                ),
                retriveWall.A(wallWidthList),
                retriveWall.A(wallLengthList)
    )
    end
    
    local makeWallB = function(fz)
        return
            tdp.makeFn(wallHeight.B > 0)(
                retriveWall.B(wallList),
                tdp.fitModel,
                mPlace(
                    fz,
                    retriveWall.B(wallTransList)(wallHeight.B)
                ),
                retriveWall.B(wallWidthList),
                retriveWall.B(wallLengthList)
    )
    end
    
    local makeWallBc = function(fz)
        return
            tdp.makeFn(wallHeight.B < 0)(
                retriveWall.B(wallList),
                tdp.fitModel,
                mPlace(
                    fz,
                    retriveWall.B(wallTransList)(wallHeight.B)
                ),
                retriveWall.B(wallWidthList),
                retriveWall.B(wallLengthList)
    )
    end
    
    local makePaving = function(fz)
        return tdp.makeFn(false)(
            "track_design_patterns/paving_base",
            tdp.fitModel,
            mPlace(fz, coor.transZ(-1e-3)),
            1, 5
    )
    end
    
    local wallGuidelineOffsets = {
        -wallOffsets.l + wallOffset,
        -wallOffsets.r - wallOffset,
        wallOffsets.l - wallOffset
    }
    
    local wallGuidelines = func.map2(
        {
            guidelines.l,
            guidelines.r,
            guidelines.l
        },
        wallGuidelineOffsets,
        function(g, o) return g * pipe.map(function(g) return g + o end) end
    )
    local trackPavingGuidelines =
        {
            pipe.new * func.seqMap({-1, wallOffset}, function(d) return func.map(guidelines.l, function(g) return g + (d - wallOffsets.l) end) end),
            pipe.new * func.seqMap({-1, wallOffset}, function(d) return func.map(guidelines.r, function(g) return g + (-d - wallOffsets.r) end) end),
            pipe.new * func.seqMap({-1, wallOffset}, function(d) return func.map(guidelines.l, function(g) return g + (-d + wallOffsets.l) end) end)
        }
    
    local terrainGuidelines =
        func.map2({
            guidelines.l,
            guidelines.r,
            guidelines.l
        }, wallGuidelineOffsets,
        function(g, o) local f = o > 0 and 1 or -1
            return g * pipe.map(function(g)
                return {
                    ref = {g + o, g},
                    inner = {g + (o - f * 2.5), g + (-o + f * 1.5)},
                    outer = {g + (o + f * 0.25), g},
                    slot = {g + o, g + (-o + f * 2.5)}
                }
            end)
        end
    )
    local polyGen = tdp.polyGen(slope)
    
    local polys = station.mergePoly(
        unpack(
            terrainGuidelines[1] * pipe.map(function(g) return polyGen(wallHeight.A, wallHeight.B, g, retriveWall.A(wallHeightList), "mid", "sup") end)
            + terrainGuidelines[2] * pipe.map(function(g) return polyGen(wallHeight.B, wallHeight.A, g, retriveWall.B(wallHeightList), "mid", "sup") end)
            + terrainGuidelines[3] * pipe.map(function(g) return polyGen(wallHeight.B, wallHeight.A, g, retriveWall.B(wallHeightList), "inf", "mid") end)
    )
    )({less = 1.5})
    
    
    
    local walls = pipe.new
        + {wallHeight.A == 0 and {} or wallGuidelines[1] * pipe.map(function(g) return makeWallA(fzg(g))(g) end) * pipe.map(pipe.select(2)) * pipe.flatten()}
        + {wallHeight.B == 0 and {} or wallGuidelines[3] * pipe.map(function(g) return makeWallBc(fzg(g))(g) end) * pipe.select(1) * pipe.select(1)}
        + {wallHeight.B == 0 and {} or wallGuidelines[2] * pipe.map(function(g) return makeWallB(fzg(g))(g) end) * pipe.map(pipe.select(2)) * pipe.flatten()}
        + {wallHeight.A ~= 0 and trackPavingGuidelines[1] * pipe.map(pipe.map(function(g) return makePaving(fzg(g))(g) end)) * pipe.map(pipe.map(pipe.select(2))) * pipe.flatten() * pipe.flatten() or {}}
        + {wallHeight.B ~= 0 and trackPavingGuidelines[3] * pipe.map(pipe.map(function(g) return makePaving(fzg(g))(g) end)) * pipe.map(pipe.map(pipe.select(1))) * pipe.map(pipe.select(1)) * pipe.flatten() or {}}
        + {wallHeight.B ~= 0 and trackPavingGuidelines[2] * pipe.map(pipe.map(function(g) return makePaving(fzg(g))(g) end)) * pipe.map(pipe.map(pipe.select(2))) * pipe.flatten() * pipe.flatten() or {}}
    
    return
        pipe.new
        * {
            edgeLists = {pipe.new * {edge} * (station.prepareEdges(({false, true, nil})[params.freeNodes + 1])) * trackBuilder.nonAligned()},
            terrainAlignmentLists = polys,
            models = walls * pipe.flatten(),
            groundFaces =
            pipe.new
            / (terrainGuidelines[1] * pipe.map(function(t) return tdp.slotGen(wallHeight.A, t, "mid", "sup") end))
            / (terrainGuidelines[2] * pipe.map(function(t) return tdp.slotGen(wallHeight.B, t, "mid", "sup") end))
            / (terrainGuidelines[3] * pipe.map(function(t) return tdp.slotGen(wallHeight.B, t, "inf", "mid") end))
            * pipe.flatten()
            * pipe.flatten()
            * pipe.map(function(p) return {face = p, modes = {{type = "FILL", key = "hole.lua"}}} end)
        }
        * station.setMirror(params.orientation == 0)
end


return {
    type = "ASSET_DEFAULT",
    description = {
        name = _("Track ladders"),
        description = _("Track ladders used to form a shunting yard or depot.")
    },
    categories = {"track_construction"},
    availability = {
        yearFrom = 1850
    },
    buildMode = "MULTI",
    -- categories = {"misc"},
    order = 27227,
    skipCollision = true,
    autoRemovable = false,
    params = params(),
    updateFn = updateFn
}
