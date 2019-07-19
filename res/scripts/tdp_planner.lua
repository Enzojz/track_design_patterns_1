local func = require "track_design_patterns/func"
local coor = require "track_design_patterns/coor"
local arc = require "track_design_patterns/coorarc"
local line = require "track_design_patterns/coorline"
local quat = require "track_design_patterns/quaternion"
local station = require "track_design_patterns/stationlib"
local pipe = require "track_design_patterns/pipe"
local tdp = require "track_design_patterns"

local dump = require "luadump"

local tdpp = {}

local unpack = table.unpack
local ma = math
local abs = ma.abs
local ceil = ma.ceil
local floor = ma.floor
local pi = ma.pi
local atan = ma.atan
local pow = ma.pow
local cos = ma.cos
local sin = ma.sin
local asin = ma.asin
local min = ma.min
local atan2 = ma.atan2


local cov = function(m)
    return func.seqMap({0, 3}, function(r)
        return func.seqMap({1, 4}, function(c)
            return m[r * 4 + c]
        end)
    end)
end

tdpp.findMarkers = function(group)
    return pipe.new
        * game.interface.getEntities({pos = {0, 0}, radius = 900000})
        * pipe.map(game.interface.getEntity)
        * pipe.filter(function(data) return data.fileName and string.match(data.fileName, "tdp_planner.con") and data.params and data.params.group == group end)
        * pipe.sort(function(x, y) return x.dateBuilt.year < y.dateBuilt.year or x.dateBuilt.month < y.dateBuilt.month or x.dateBuilt.day < y.dateBuilt.day or x.id < y.id end)
end

local findPreviewsByMarker = function(pos, r)
    return function(con)
        return function(params)
            return pipe.new
                * game.interface.getEntities({pos = {pos.x, pos.y}, radius = r})
                * pipe.map(game.interface.getEntity)
                * pipe.filter(function(data) return data.fileName and string.match(data.fileName, con) and data.params.showPreview and data.params.overrideGr == params.overrideGr end)
        end
    end
end

tdpp.displace = function(config, trackCoords)
    local tc = trackCoords * pipe.filter(pipe.noop())
    local disp =
        config.pattern and config.pattern.m and trackCoords[config.pattern.m]
        or tc[(pipe.new
        / function() return 1 end
        / function() return ceil(#tc * 0.5) end
        / function() return #tc end
        * pipe.select(config.varRefPos + 2))()]
    return station.setTransform(coor.trans(-disp))
end

tdpp.updatePreview = function(params, config, arcPacker, buildStation)
    local nbTracks = tdpm.trackNumberList[params.nbTracks + 1]
    
    local track, platform, entry, trackCoords =
        buildStation(nbTracks,
            arcPacker,
            config,
            params.hasLeftPlatform == 0,
            params.hasRightPlatform == 0,
            tdp.buildPreview
    )
    local radius2String = function(r) return abs(r) > 1e6 and (r > 0 and "+∞" or "-∞") or tostring(floor(r * 10) * 0.1) end
    local fPos = function(w) return coor.transX(-0.5 * w) * coor.rotX(-pi * 0.5) * coor.rotZ(pi * 0.5) * coor.transZ(3) end
    local rtext = livetext(7, 0)(
        config.r
        and ("R" .. radius2String(config.r))
        or ("R" .. radius2String(config.rA) .. " / " .. radius2String(config.rB))
    )(fPos)
    local ltext = livetext(7, -1)("L" .. tostring(floor(config.length * 10) * 0.1))(fPos)
    local stext = livetext(7, -2)("S" .. tostring(floor(config.slope * 10000) * 0.1) .. "‰")(fPos)
    return pipe.new * {
        models = pipe.new + ltext + rtext + stext,
        terrainAlignmentLists = {{type = "EQUAL", faces = {}}},
        groundFaces = track
        * pipe.map(pipe.select("equal"))
        * pipe.filter(pipe.noop())
        * pipe.flatten()
        * pipe.map(function(f) return {
            {face = f, modes = {{type = "FILL", key = "fill_red"}}},
        } end)
        * pipe.flatten()
        + platform
        * pipe.map(pipe.select("equal"))
        * pipe.filter(pipe.noop())
        * pipe.flatten()
        * pipe.map(function(f) return {
            {face = f, modes = {{type = "FILL", key = "fill_blue"}}},
        } end)
        * pipe.flatten()
        +
        (
        entry * pipe.map(pipe.map(pipe.select("equal")))
        + entry * pipe.map(pipe.map(pipe.select("slot")))
        )
        * pipe.flatten()
        * pipe.filter(pipe.noop())
        * pipe.flatten()
        * pipe.map(function(f) return {
            {face = f, modes = {{type = "FILL", key = "fill_yellow"}}},
        } end)
        * pipe.flatten()
    }
    * tdpp.displace(config, trackCoords)
end

local retriveInfo = function(info)
    if (info) then
        return {
            radius = tonumber(info:match("(%d+)")),
        }
    else
        return {}
    end
end

local function findCircle(posS, posE, vecS, vecE, r)
    local lnS = line.byVecPt(vecS, posS)
    local lnE = line.byVecPt(vecE, posE)
    local x = lnS - lnE
    
    local dXS = (x - posS):length()
    local dXE = (x - posE):length()
    
    if (abs(dXS / dXE - 1) < 0.005) then
        local lnPS = line.pend(lnS, posS)
        local lnPE = line.pend(lnE, posE)
        local o = lnPS - lnPE
        local vecOS = o - posS
        local vecOE = o - posE
        local radius = vecOS:length()
        local result = pipe.new
        if (r and radius > r) then
            local vecO = (x - o):normalized()
            o = o + vecO * (radius - r)
            local lnPS = line.pend(lnS, o)
            local lnPE = line.pend(lnE, o)
            local posS = lnPS - lnS
            local posE = lnPE - lnE
            vecOS = o - posS
            vecOE = o - posE
            local rad = asin(vecOS:normalized():cross(vecOE:normalized()))
            local length = abs(rad * r)
            local f = rad > 0 and 1 or -1
            return {
                f = -f,
                radius = r,
                length = length,
                vec = vecS,
                pos = posS
            }, posS, posE, true, true
        else
            local rad = asin(vecOS:normalized():cross(vecOE:normalized()))
            local length = abs(rad * radius)
            local f = rad > 0 and 1 or -1
            return {
                f = -f,
                radius = radius,
                length = length,
                vec = vecS,
                pos = posS
            }, posS, posE, false, false
        end
    else
        if (dXS > dXE) then
            local ret, posS, posE = findCircle(posS + vecS * (dXS - dXE), posE, vecS, vecE, r)
            return ret, posS, posE, true, false
        else
            local ret, posS, posE = findCircle(posS, posE + vecE * (dXE - dXS), vecS, vecE, r)
            return ret, posS, posE, true, false
        end
    end
end

local solve = function(s, e, r)
    local posS, rotS, _ = coor.decomposite(s.transf)
    local posE, rotE, _ = coor.decomposite(e.transf)
    local vecS = coor.xyz(1, 0, 0) .. rotS
    local vecE = coor.xyz(1, 0, 0) .. rotE
    posS = posS:withZ(0)
    posE = posE:withZ(0)
    vecS = vecS:withZ(0):normalized()
    vecE = vecE:withZ(0):normalized() 
    -- Work on horizon plan, recalculate Z at last
    local lnS = line.byVecPt(vecS, posS)
    local lnE = line.byVecPt(vecE, posE)
    local m = (posE + posS) * 0.5
    local vecES = posE - posS
    local x = lnS - lnE
    
    if (x) then
        local vecXS = x - posS
        local vecXE = x - posE
        
        local u = vecXS:length()
        local v = vecXE:length()
        
        local co = vecXS:normalized():dot(vecXE:normalized())
        local function straightResult(posS, posE)
            local length = (posE - posS):length()
            return {
                f = 1,
                radius = tdp.infi,
                length = length,
                vec = (posE - posS):normalized(),
                pos = posS
            }
        end
        if (vecXE:dot(vecE) > 0 and vecXS:dot(vecS) > 0) then
            local ret, posCS, posCE, extS, extE = findCircle(posS, posE, vecS, vecE, r)
            return pipe.new
                / (extS and straightResult(posCS, posS))
                / ret
                / (extE and straightResult(posCE, posE))
        -- elseif ((vecXE:dot(vecE) < 0 and vecXS:dot(vecS) > 0)) then
        -- elseif ((vecXS:dot(vecS) < 0 and vecXE:dot(vecE) > 0)) then
        end
    else
        local lnPenE = line.pend(lnE, posE)
        local posP = lnPenE - lnS
        local vecEP = posE - posP
        if (vecEP:length() < 1e-3) then
            local length = vecES:length()
            return pipe.new /
                {
                    f = 1,
                    radius = tdp.infi,
                    length = length,
                    pos = posS,
                    vec = vecS
                }
        else
            local mRot = quat.byVec(vecS, vecES:normalized()):mRot()
            local vecT = vecES .. mRot
            local lnT = line.byVecPt(vecT, m)
            local ret1, posCS1, posCE1, extS1, extE1 = findCircle(posS, m, vecS, -vecT, r)
            local ret2, posCS2, posCE2, extS2, extE2 = findCircle(m, posE, vecT, vecE, r)
            return pipe.new
                / (extS1 and straightResult(posCS1, posS))
                / ret1
                / (
                (extE1 and extS2)
                and straightResult(posCE1, posCS2)
                or (
                (extE1 and not extS2)
                and straightResult(posCE1, m)
                or (
                (not extE1 and extS2) and straightResult(m, posCS2)
                )
                )
                )
                / ret2
                / (extE2 and straightResult(posCE2, posE))
        end
    end
end

tdpp.solve = solve

local retriveParams = function(markers, r)
    local s, e = unpack(markers)
    
    local posS, _, _ = coor.decomposite(s.transf)
    local posE, _, _ = coor.decomposite(e.transf)
    local pos = (posE + posS) * 0.5
    
    local con = "parallel_tracks.con"
    local findPreviewsByMarker = function(params)
        return pipe.new
            * game.interface.getEntities({pos = {pos.x, pos.y}, radius = (posE - posS):length()})
            * pipe.map(game.interface.getEntity)
            * pipe.filter(function(data) return data.fileName and string.match(data.fileName, con) and data.params.showPreview and data.params.overrideGr == params.overrideGr end)
    end
    
    local results = solve(s, e, r) * pipe.filter(pipe.noop())

    local totalLength = results * pipe.fold(0, function(sum, r) return sum + r.length end)
    local results = results * pipe.fold({totalLength, pipe.new * {}}, function(result, seg)
        local restLength, results = unpack(result)
        return {
            restLength - seg.length,
            results / func.with(seg, {
                pos = seg.pos:withZ(posE.z + restLength / totalLength * (posS.z - posE.z)),
                vec = seg.vec:withZ(0):normalized(),
                slopeA = (posE - posS).z / totalLength,
                slopeB = (posE - posS).z / totalLength
            })
        }
    end) * pipe.select(2)
    
    return findPreviewsByMarker, con, results
end

local refineParams = function(params, markers)
    local info = retriveInfo(
        markers
        * pipe.filter(function(m) return string.find(m.name, "#", 0, true) == 1, 1 end)
        * pipe.map(pipe.select("name")) * pipe.select(1)
    )
    local findPreviewsByMarker, con, results = retriveParams(markers, info.radius or nil)
    return findPreviewsByMarker, "track_design_patterns/" .. con, results
end

local findPreviewInstance = function(params)
    return pipe.new
        * game.interface.getEntities({pos = {0, 0}, radius = 900000})
        * pipe.map(game.interface.getEntity)
        * pipe.filter(function(data) return data.params and data.params.seed == params.seed end)
end

tdpp.updatePlanner = function(params, markers)
    if (params.override == 1) then
        local findPreviewsByMarker, con, results = refineParams(params, markers)
        
        local pre = findPreviewsByMarker(params)
        local _ = pre * pipe.map(pipe.select("id")) * pipe.forEach(game.interface.bulldoze)
        
        local _ = results * pipe.forEach(function(r)
            local previewParams = func.with(station.pureParams(params),
                {
                    showPreview = true,
                    overrideParams = {
                        radius = r.f * r.radius,
                        length = r.length,
                        slopeA = r.slopeA,
                        slopeB = r.slopeB
                    }
                })
            local transf = quat.byVec(coor.xyz(0, 1, 0), (r.vec):withZ(0)):mRot() * coor.trans(r.pos)
            local id = game.interface.buildConstruction(
                con,
                previewParams,
                transf
            )
            game.interface.setPlayer(id, game.interface.getPlayer())
        end)
    else
        local pre = #markers == 2 and retriveParams(markers)(params) or findPreviewInstance(params)
        if (params.override == 2) then
            local _ = markers * pipe.map(function(m) return m.id end) * pipe.forEach(game.interface.bulldoze)
            func.forEach(pre, function(pre)
                game.interface.upgradeConstruction(
                    pre.id,
                    pre.fileName,
                    func.with(station.pureParams(pre.params),
                        {
                            override = 2,
                            showPreview = false,
                            isBuild = true,
                        })
            )
            end)
        elseif (params.override == 3) then
            local _ = pre * pipe.map(pipe.select("id")) * pipe.forEach(game.interface.bulldoze)
        end
    end
    
    return {
        models = {
            {
                id = "asset/icon/marker_question.mdl",
                transf = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
            }
        },
        cost = 0,
        bulldozeCost = 0,
        maintenanceCost = 0,
        terrainAlignmentLists = {{type = "EQUAL", faces = {}}}
    }
end


return tdpp
