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
local sqrt = math.sqrt
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
    return tdp.trackType + {
        {
            key = "cot",
            name = _("Turnout #"),
            uiType = "SLIDER",
            values = func.map(func.map(sizeSwitch, math.floor), tostring),
            defaultIndex = 5
        },
        {
            key = "pattern",
            name = _("Pattern"),
            values = {_("X"), _("N"), "½" .. ("N"), "¾" .. ("N")},
            defaultIndex = 1,
        },
        {
            key = "orientation",
            name = _("Orientaion"),
            values = {_("Left"), _("Right")},
            defaultIndex = 1,
        },
        {
            key = "distance",
            name = _("Track Distance"),
            values = {"5", "9", "10", "11.5", "12", "14"},
            defaultIndex = 0,
        },
        {
            key = "slope",
            name = _("Slope") .. "(‰)",
            values = func.map(slopeList, tostring),
            uiType = "SLIDER",
            defaultIndex = (#slopeList - 1) * 0.5
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
    local orientation = params.orientation + 1
    local wallOffset = params.wallOffset * 0.5 + 0.2
    local pattern = params.pattern + 1
    local slope = slopeList[params.slope + 1] * 0.001
    
    local distance = ({5, 9, 10, 11.5, 12, 14})[params.distance + 1]
    local cot = sizeSwitch[params.cot + 1]
    local rad = atan(1 / cot)
    local w = 1.435
    
    local r = w / (1 - cos(rad)) - w * 0.5
    
    local isSimple = (cot == 4) or (cot == 5 and slope > 0.06 and distance == 5)
    
    local x, y, vec, f = unpack(isSimple and
        pipe.exec * function()
            local x = distance * 0.5
            local y = sqrt(r * distance - distance * distance * 0.5)
            local vec = coor.xyz(sin(acos(1 - x / r)), cos(acos(1 - x / r)), 0)
            return {x, y, vec}
        end
        or
        pipe.exec * function()
            local x = distance * 0.5
            local y = r * sin(rad) + (distance * 0.5 - (r - r * cos(rad))) / tan(rad)
            local f = (distance - w) * 0.5 / tan(rad) * 0.5
            local vec = coor.xyz(sin(rad), cos(rad), 0)
            return {x, y, vec, f}
        end
    )
    local sBase = pipe.new
        * {
            {coor.xyz(-x, -y, 0), coor.xyz(-x, -y - 1, 0), coor.xyz(0, -1, 0), coor.xyz(0, -1, 0)},
            {coor.xyz(-x, -y, 0), coor.xyz(-x, 0, 0), coor.xyz(0, 1, 0), coor.xyz(0, 1, 0)},
        }
    
    local base =
        isSimple
        and sBase
        / {coor.xyz(-x, -y, 0), coor.xyz(0, 0, 0), coor.xyz(0, 1, 0), vec}
        or sBase
        / {coor.xyz(-x, -y, 0), vec * -f, coor.xyz(0, 1, 0), vec}
        / {vec * -f, coor.xyz(0, 0, 0), vec, vec}
    
    
    local baseTr = function(tr)
        return function(e)
            return e
                * pipe.map(pipe.map(function(n) return n .. tr * (orientation == 2 and coor.I() or coor.flipX()) end))
                * pipe.map(pipe.map(function(pt) return coor.xyz(pt.x, pt.y, pt.y * slope) end))
        end
    end
    
    local parts = {
        lb = base * baseTr(coor.I()),
        rb = base * baseTr(coor.flipX()),
        lt = base * baseTr(coor.flipY()),
        rt = base * baseTr(coor.flipX() * coor.flipY()),
    }
    
    local s = {
        lb = sBase * baseTr(coor.I()),
        rb = sBase * baseTr(coor.flipX()),
        lt = sBase * baseTr(coor.flipY()),
        rt = sBase * baseTr(coor.flipX() * coor.flipY()),
    }
    
    local edge = pipe.new
        / (
        {
            {
                edge = parts.lb + parts.rb + parts.lt + parts.rt,
                snap = (pipe.new / {false, true} + pipe.rep(isSimple and 2 or 3)({false, false})) * pipe.rep(4) * pipe.flatten()
            },
            {
                edge = parts.lb + s.lt + parts.rt + s.rb,
                snap = (pipe.new / {false, true} + pipe.rep(isSimple and 2 or 3)({false, false}) + {{false, true}, {false, false}}) * pipe.rep(2) * pipe.flatten()
            },
            {
                edge = parts.lb + parts.rt,
                snap = (pipe.new / {false, true} / {false, true} + pipe.rep(isSimple and 1 or 2)({false, false})) * pipe.rep(2) * pipe.flatten()
            },
            {
                edge = parts.lb + parts.rt + s.lt,
                snap =
                pipe.new / {false, true} + pipe.rep(isSimple and 2 or 3)({false, false})
                + pipe.new / {false, true} / {false, true} + pipe.rep(isSimple and 1 or 2)({false, false})
                + {{false, true}, {false, false}}
            }
        }
        )[pattern]
        * station.mergeEdges
    
    local guidelines = {
        l = arc.byOR(coor.xy(-tdp.infi, 0), tdp.infi),
        r = arc.byOR(coor.xy(tdp.infi, 0), tdp.infi)
    }
    
    guidelines.l = guidelines.l:withLimits(
        {
            sup = guidelines.l:rad(coor.xy(-x, y + 1)),
            mid = guidelines.l:rad(coor.xy(-x, 0)),
            inf = guidelines.l:rad(coor.xy(-x, -y - 1))
        }
    )
    guidelines.r = guidelines.r:withLimits(
        {
            sup = guidelines.r:rad(coor.xy(x, y + 1)),
            mid = guidelines.r:rad(coor.xy(x, 0)),
            inf = guidelines.r:rad(coor.xy(x, -y - 1))
        }
    )
    local wallOffsets = {
        l = -x - 2.5 - 0.25,
        r = x + 2.5 + 0.25
    }
    
    local retriveWall = {
        A = function(ls) return ls[params.wallAType + 1] end,
        B = function(ls) return params.wallBType == 0 and ls[params.wallAType + 1] or ls[params.wallBType] end
    }
    local wallHeight = {
        A = func.seq(-1, 15)[params.wallAHeight + 1],
        B = params.wallBHeight == 0 and func.seq(-1, 15)[params.wallAHeight + 1] or func.seq(-1, 15)[params.wallBHeight]
    }
    
    local wallGuidelines = {
        guidelines.l + (-abs(wallOffsets.l - wallOffset)),
        guidelines.r + (-abs(wallOffsets.r + wallOffset))
    }
    
    local trackPavingGuidelines =
        {
            func.seqMap({-1, wallOffset}, function(d) return guidelines.l + (-d + wallOffsets.l) end),
            func.seqMap({-1, wallOffset}, function(d) return guidelines.r + (-d - wallOffsets.r) end)
        }
    
    local terrainGuidelines = pipe.new
        * wallGuidelines
        * pipe.map2({guidelines.l, guidelines.r}, function(g, l)
            return {
                ref = {g, l},
                inner = {g + 1.5, l},
                outer = {g + (-0.25), l},
                slot = {g, g + 2.5}
            }
        end)
    
    local polyGen = tdp.polyGen(slope)
    
    local polys = station.mergePoly(
        polyGen(wallHeight.A, wallHeight.B, terrainGuidelines[1], retriveWall.A(wallHeightList), "inf", "sup"),
        polyGen(wallHeight.B, wallHeight.A, terrainGuidelines[2], retriveWall.B(wallHeightList), "inf", "sup")
    )({less = 1.5})
    
    local fz = function(g) return function(rad) return {z = g:pt(rad).y * slope, s = slope} end end
    
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
    
    local makePaving = function(fz)
        return tdp.makeFn(false)(
            "track_design_patterns/paving_base",
            tdp.fitModel,
            mPlace(fz, coor.transZ(-1e-3)),
            1, 5
    )
    end
    
    local walls = pipe.new
        + {wallHeight.A == 0 and {} or pipe.new * makeWallA(fz(guidelines.l))(wallGuidelines[1]) * (pattern == 3 and pipe.select(({2, 1})[orientation]) or pipe.flatten())}
        + {wallHeight.B == 0 and {} or pipe.new * makeWallB(fz(guidelines.r))(wallGuidelines[2]) * (pattern > 2 and pipe.select(orientation) or pipe.flatten())}
        + {wallHeight.A ~= 0 and pipe.new * trackPavingGuidelines[1] * pipe.map(makePaving(fz(guidelines.l))) * pipe.map(pattern == 3 and pipe.select(({2, 1})[orientation]) or pipe.flatten()) * pipe.flatten() or {}}
        + {wallHeight.B ~= 0 and pipe.new * trackPavingGuidelines[2] * pipe.map(makePaving(fz(guidelines.r))) * pipe.map(pattern > 2 and pipe.select(orientation) or pipe.flatten()) * pipe.flatten() or {}}
    
    return
        pipe.new
        * {
            edgeLists = {pipe.new * {edge} * (station.prepareEdges(({false, true, nil})[params.freeNodes + 1])) * ((wallHeight.A == 0 and wallHeight.B == 0) and trackBuilder.normal() or trackBuilder.nonAligned())},
            terrainAlignmentLists = ((wallHeight.A == 0 and wallHeight.B == 0) and {} or polys),
            models = walls * pipe.flatten(),
            groundFaces =
            pipe.new
            / tdp.slotGen(wallHeight.A, terrainGuidelines[1], "inf", "sup")
            / tdp.slotGen(wallHeight.B, terrainGuidelines[2], "inf", "sup")
            * pipe.flatten()
            * pipe.map(function(p) return {face = p, modes = {{type = "FILL", key = "hole.lua"}}} end)
        }
end


return {
    type = "ASSET_DEFAULT",
    description = {
        name = _("Crossover"),
        description = _("Crossover switch group.")
    },
    categories = {"track_construction"},
    availability = {
        yearFrom = 1850
    },
    buildMode = "MULTI",
    -- categories = {"misc"},
    order = 27226,
    skipCollision = true,
    autoRemovable = false,
    params = params(),
    updateFn = updateFn
}
