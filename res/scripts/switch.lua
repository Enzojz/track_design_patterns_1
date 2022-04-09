local paramsutil = require "paramsutil"
local func = require "track_design_patterns/func"
local coor = require "track_design_patterns/coor"
local line = require "track_design_patterns/coorline"
local arc = require "track_design_patterns/coorarc"
local trackEdge = require "track_design_patterns/trackedge"
local station = require "track_design_patterns/stationlib"
local pipe = require "track_design_patterns/pipe"
local tdp = require "track_design_patterns"

local math = math
local abs = math.abs
local pi = math.pi
local atan = math.atan
local cos = math.cos
local sin = math.sin

local generateArc = function(fz)
    return function(arc)
        local toXyz = function(pt, z) return coor.xyz(pt.x, pt.y, z) end
        
        local sup = toXyz(arc:pt(arc.sup), fz(arc.sup).z)
        local inf = toXyz(arc:pt(arc.inf), fz(arc.inf).z)
        local mid = toXyz(arc:pt(arc.mid), fz(arc.mid).z)
        
        local vecSup = func.with(arc:tangent(arc.sup), {z = fz(arc.sup).s})
        local vecInf = func.with(arc:tangent(arc.inf), {z = fz(arc.inf).s})
        local vecMid = func.with(arc:tangent(arc.mid), {z = fz(arc.mid).s})
        
        return {
            {inf, mid, vecInf, vecMid},
            {mid, sup, vecMid, vecSup}
        }
    end
end

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

local sizeSwitch = {4.25, 5, 6, 7, 9, 12, 14, 16, 18, 24, 30, 36, 42, 50, 65}

local function params()
    local sp = "·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·:·\n"
    return tdp.trackType + {
        {
            key = "nbTracks",
            name = _("Number of tracks"),
            values = func.seqMap({1, 10}, tostring),
            defaultIndex = 0
        },
        {
            key = "type",
            name = _("Type"),
            values = {_("Left"), _("Wye"), _("Right")},
            defaultIndex = 0
        },
        {
            key = "compa",
            name = _("Compactness"),
            values = {_("Extra loose"), _("Loose"), _("Standard"), _("Medium"), _("Compact"), _("Complete")},
            uiType = "SLIDER",
            defaultIndex = 2,
        },
        {
            key = "cot",
            name = _("Turnout #"),
            uiType = "SLIDER",
            values = func.map(func.map(sizeSwitch, math.floor), tostring),
            defaultIndex = 5
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
            name = _("Wall B") .. " " .. _("Type"),
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
            name = _("Wall A") .. " " .. _("Type"),
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
    local offsets = tdp.buildCoors(nbTracks, nbTracks)
    local wallOffset = params.wallOffset * 0.5 + 0.2
    
    local cot = sizeSwitch[params.cot + 1]
    local rad = atan(1 / cot) * (params.type == 1 and 0.5 or 1)
    local r = 1.435 / (1 - cos(rad)) - 1.435 * 0.5 + 2.5 * (nbTracks - 1)
    
    local radious = {
        l = params.type == 2 and tdp.infi or r,
        r = params.type == 0 and tdp.infi or r
    }
    
    local compactness = params.compa == 5 and nil or ({2, 1, 0, -1, -1.5})[params.compa + 1]
    
    local guidelines = {
        l = arc.byOR(coor.xy(-radious.l, 0), radious.l),
        r = arc.byOR(coor.xy(radious.r, 0), radious.r),
    }
    
    local initRad = {
        l = 0,
        r = pi
    }
    
    local finalRad, interRad = (function()
        local limArc = {
            l = guidelines.l + 2.5 * nbTracks + (compactness or 0),
            r = guidelines.r + 2.5 * nbTracks + (compactness or 0),
        }
        
        return {
            l = limArc.l:rad((func.filter(limArc.l - limArc.r, function(p) return p.y > 0 end))[1]),
            r = limArc.r:rad((func.filter(limArc.l - limArc.r, function(p) return p.y > 0 end))[1])
        },
        {
            l = guidelines.l:rad((func.filter(guidelines.l - (guidelines.r + 2.5 * nbTracks), function(p) return p.y > 0 end))[1]),
            r = guidelines.r:rad((func.filter(guidelines.r - (guidelines.l + 2.5 * nbTracks), function(p) return p.y > 0 end))[1]),
        }
    end)()
    
    local radc = 5 / tdp.infi
    
    guidelines = {
        l = guidelines.l:withLimits({
            sup = finalRad.l,
            mid = interRad.l,
            inf = initRad.l
        }),
        r = guidelines.r:withLimits({
            sup = finalRad.r,
            mid = interRad.r,
            inf = initRad.r
        }),
        c = arc.byOR(coor.xy(-tdp.infi, 0), tdp.infi):withLimits({
            sup = radc,
            mid = 0,
            inf = -radc
        }),
        complementary = compactness and {
            l = guidelines.l:withLimits({
                sup = finalRad.l,
                mid = interRad.l,
                inf = initRad.l
            }),
            r = guidelines.r:withLimits({
                sup = finalRad.r,
                mid = interRad.r,
                inf = initRad.r
            })
        } or {
            l = arc.byOR(guidelines.l.o + (guidelines.l:pt(interRad.l) - guidelines.l.o) * 2, guidelines.l.r):withLimits({
                sup = initRad.l + pi,
                mid = interRad.l + pi,
                inf = interRad.l + (interRad.l - initRad.l) + pi
            }),
            r = arc.byOR(guidelines.r.o + (guidelines.r:pt(interRad.r) - guidelines.r.o) * 2, guidelines.r.r):withLimits({
                sup = initRad.r - pi,
                mid = interRad.r - pi,
                inf = interRad.r + (interRad.r - initRad.r) - pi
            }),
        }
    }
    
    local slope = slopeList[params.slope + 1] * 0.001
    
    local fz = function(g) return function(rad) return {z = g:pt(rad).y * slope, s = slope} end end
    
    
    local arcs = offsets.tracks
        * pipe.map(function(o) return {
            l = guidelines.l + o,
            r = guidelines.r + (-o),
            c = guidelines.c + o,
            complementary = {
                l = guidelines.complementary.l + (compactness and o or -o),
                r = guidelines.complementary.r + (compactness and -o or o)
            }
        } end
        )
        * function(g)
            local l = g * pipe.map(pipe.select("l"))
            local r = g * pipe.map(pipe.select("r"))
            local complementary = {
                l = g * pipe.map(pipe.select("complementary")) * pipe.map(pipe.select("l")),
                r = g * pipe.map(pipe.select("complementary")) * pipe.map(pipe.select("r"))
            }
            local groupIntersection = function(g, y)
                local ptInLimite = function(ar, li, pt)
                    local v1 = ar:pt(ar[li[1]]) - pt
                    local v2 = ar:pt(ar[li[2]]) - pt
                    return (v1.x * v2.x + v1.y * v2.y) < 0
                end
                local intersections = function(arcl, liml, arcr, limr)
                    return pipe.new
                        * func.filter(arcl - arcr, function(pt) return ptInLimite(arcl, liml, pt) and ptInLimite(arcr, limr, pt) end)
                        * pipe.map(function(pt) return {rad = arcl:rad(pt), g = arcl} end)
                end
                return
                    func.filter({
                        intersections(g.i, {"inf", "mid"}, y.i, {"inf", "mid"}),
                        intersections(g.i, {"inf", "mid"}, y.s, {"mid", "sup"}),
                        intersections(g.s, {"mid", "sup"}, y.i, {"inf", "mid"}),
                        intersections(g.s, {"mid", "sup"}, y.s, {"mid", "sup"})
                    }, function(x) return #x > 0 end)[1][1]
            end
            local toXyz = function(pt, z) return coor.xyz(pt.x, pt.y, z) end
            return
                {
                    c = g * pipe.map(pipe.select("c")) * pipe.map(function(g) return generateArc(fz(g))(g) end) * pipe.map(pipe.select(1)),
                    l = l
                    * pipe.zip(complementary.l, {"i", "s"})
                    * pipe.mapi(function(g, i)
                        local rads = r
                            * pipe.zip(complementary.r, {"i", "s"})
                            * pipe.range(1, i - 1)
                            * pipe.map(function(y) return groupIntersection(g, y) end)
                        
                        return (pipe.new +
                            (compactness == nil and ((#rads > 0 and rads[1].g ~= g.s) or (#rads == 0))
                            and {{rad = g.s.sup, g = g.s}, {rad = g.s.mid, g = g.s}}
                            or {{rad = g.s.sup, g = g.s}}
                            )
                            + rads
                            + {{rad = g.i.inf, g = g.i}}
                            )
                            * pipe.rev()
                            * pipe.map(function(p)
                                local pt = p.g:pt(p.rad)
                                local vec = p.g:tangent(p.rad)
                                local zs = fz(p.g)(p.rad)
                                return {p = toXyz(pt, zs.z), v = toXyz(vec, zs.s)}
                            end)
                    end),
                    
                    r = r
                    * pipe.zip(complementary.r, {"i", "s"})
                    * pipe.mapi(function(g, i)
                        local rads = l
                            * pipe.zip(complementary.l, {"i", "s"})
                            * pipe.range(i + 1, #l)
                            * pipe.map(function(y) return groupIntersection(g, y) end)
                        
                        return (pipe.new +
                            {{rad = g.i.inf, g = g.i}}
                            + rads
                            + (compactness == nil and ((#rads > 0 and rads[1].g ~= g.s) or (#rads == 0))
                            and {{rad = g.s.mid, g = g.s}, {rad = g.s.sup, g = g.s}}
                            or {{rad = g.s.sup, g = g.s}}
                            )
                            )
                            * pipe.map(function(p)
                                local pt = p.g:pt(p.rad)
                                local vec = p.g:tangent(p.rad)
                                local zs = fz(p.g)(p.rad)
                                return {p = toXyz(pt, zs.z), v = toXyz(vec, zs.s)}
                            end)
                    end)
                }
        end
        * function(g)
            local r = g.r
                * pipe.mapi(function(p, i) return
                    p * pipe.range(#(g.r) - i + 2, #p)
                    * pipe.fold(p * pipe.range(1, #(g.r) - i + 1),
                        function(rs, s)
                            local v = s.p - rs[#rs].p
                            return (v:length() < 0.3 / sin(rad) or (v.x * s.v.x + v.y * s.v.y) < 0) and rs or rs / s end)
                end)
                * pipe.map(pipe.interlace({"l", "r"}))
                * pipe.map(pipe.map(function(s) return {s.l.p, s.r.p, s.l.v, s.r.v} end))
            local l = g.l
                * pipe.mapi(function(p, i) return
                    p * pipe.range(i + 1, #p)
                    * pipe.fold(p * pipe.range(1, i),
                        function(rs, s)
                            local v = s.p - rs[#rs].p
                            return (v:length() < 0.3 / sin(rad) or (v.x * s.v.x + v.y * s.v.y) < 0) and rs or rs / s end)
                end)
                * pipe.mapi(function(l, i) return
                    l * pipe.range(1, i)
                    * pipe.mapi(function(s, j) return {p = g.r[i - j + 1][j].p, v = s.v} end)
                    + l * pipe.range(i + 1, #l)
                end)
                * pipe.map(pipe.interlace({"l", "r"}))
                * pipe.map(pipe.map(function(s) return {s.l.p, s.r.p, s.l.v, s.r.v} end))
            local c = g.c
                * pipe.mapi(function(c, i)
                    return {c[1], l[i][1][1], c[3], c[4]}
                end)
            return (l + r)
                * pipe.map(function(a) return {
                    edge = pipe.new * a,
                    snap = pipe.new * func.seq(1, #a - 1) * pipe.map(function(_) return {false, false} end) / {false, true}
                } end)
                / {
                    edge = c,
                    snap = c * pipe.map(function(_) return {true, false} end)
                }
        end
        * station.mergeEdges
    
    local retriveWall = {
        A = function(ls) return ls[params.wallAType + 1] end,
        B = function(ls) return params.wallBType == 0 and ls[params.wallAType + 1] or ls[params.wallBType] end
    }
    
    
    local wallHeight = {
        A = func.seq(-1, 15)[params.wallAHeight + 1],
        B = params.wallBHeight == 0 and func.seq(-1, 15)[params.wallAHeight + 1] or func.seq(-1, 15)[params.wallBHeight]
    }
    
    local wallGuidelineOffsets = {
        (-abs(offsets.walls[1] - wallOffset)),
            (-abs(offsets.walls[2] + wallOffset)),
            (compactness and 1 or -1) * (-abs(offsets.walls[1] - wallOffset)),
            (compactness and 1 or -1) * (-abs(offsets.walls[2] + wallOffset)),
            (-abs(offsets.walls[1] - wallOffset)),
            (abs(offsets.walls[2] + wallOffset))
    }
    
    local wallGuidelines = func.map2({
        guidelines.l,
        guidelines.r,
        guidelines.complementary.l,
        guidelines.complementary.r,
        guidelines.c,
        guidelines.c
    }, wallGuidelineOffsets, function(g, o) return g + o end)
    
    local trackPavingGuidelines =
        {
            func.seqMap({-1, wallOffset}, function(d) return guidelines.l + (-d + offsets.walls[1]) end),
            func.seqMap({-1, wallOffset}, function(d) return guidelines.r + (-d - offsets.walls[#offsets.walls]) end),
            func.seqMap({-1, wallOffset}, function(d) return guidelines.complementary.l + (compactness and 1 or -1) * (-d + offsets.walls[1]) end),
            func.seqMap({-1, wallOffset}, function(d) return guidelines.complementary.r + (compactness and 1 or -1) * (-d - offsets.walls[#offsets.walls]) end),
            func.seqMap({-1, wallOffset}, function(d) return guidelines.c + (-d + offsets.walls[1]) end),
            func.seqMap({-1, wallOffset}, function(d) return guidelines.c + (d + offsets.walls[#offsets.walls]) end)
        }
    
    
    local terrainGuidelines =
        func.map2({
            guidelines.l,
            guidelines.r,
            guidelines.complementary.l,
            guidelines.complementary.r,
            guidelines.c,
            guidelines.c
        }, wallGuidelineOffsets,
        function(g, o)
            local f = o > 0 and 1 or -1
            return {
                ref = {g + o, g},
                inner = {g + (o - f * 2.5), g + (-o + f * 1.5)},
                outer = {g + (o + f * 0.25), g},
                slot = {g + o, g + (-o + f * 2.5)}
            }
        end)
    
    local polyGen = tdp.polyGen(slope)
    
    local pointTerrain = pipe.exec * function()
        local lp = guidelines.l + offsets.tracks[#offsets.tracks]
        local rp = guidelines.r + (-offsets.tracks[1])
        
        local lpc = guidelines.complementary.l + (compactness and 1 or -1) * offsets.tracks[#offsets.tracks]
        local rpc = guidelines.complementary.r + (compactness and 1 or -1) * (-offsets.tracks[1])
        
        local int = func.max(lp - rp, function(l, r) return l.y < r.y end)
        local radlp = lp:rad(int)
        local radrp = rp:rad(int)
        
        lp = lp:withLimits({inf = radlp, mid = 0.5 * (radlp + lp.mid), sup = lp.mid})
        rp = rp:withLimits({inf = radrp, mid = 0.5 * (radrp + rp.mid), sup = rp.mid})
        
        return {
            platform = (
            tdp.generatePolyArc({lp, lp + 2.5 + (compactness or 0)}, "inf", "sup")(-0.2, 0)
            + tdp.generatePolyArc({rp, rp + 2.5 + (compactness or 0)}, "inf", "sup")(-0.2, 0)
            + tdp.generatePolyArc({lpc, lpc + (compactness and (2.5 + compactness) or -2.5)}, "mid", "sup")(-0.2, 0)
            + tdp.generatePolyArc({rpc, rpc + (compactness and (2.5 + compactness) or -2.5)}, "mid", "sup")(-0.2, 0)
            )
            * pipe.map(pipe.map(function(p) return coor.transZ(p.y * slope)(p) end)) * station.projectPolys(coor.I())
        }
    
    end
    
    local polys = station.mergePoly(
        polyGen(wallHeight.A, wallHeight.B, terrainGuidelines[1], retriveWall.A(wallHeightList), "inf", "mid"),
        polyGen(wallHeight.B, wallHeight.A, terrainGuidelines[2], retriveWall.B(wallHeightList), "inf", "mid"),
        polyGen(wallHeight.A, wallHeight.B, terrainGuidelines[3], retriveWall.A(wallHeightList), "mid", "sup"),
        polyGen(wallHeight.B, wallHeight.A, terrainGuidelines[4], retriveWall.B(wallHeightList), "mid", "sup"),
        polyGen(wallHeight.A, wallHeight.B, terrainGuidelines[5], retriveWall.A(wallHeightList), "inf", "mid"),
        polyGen(wallHeight.B, wallHeight.A, terrainGuidelines[6], retriveWall.B(wallHeightList), "inf", "mid"),
        pointTerrain
    )({less = 1.5})
    
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
        + {wallHeight.A == 0 and {} or pipe.new * makeWallA(fz(guidelines.l))(wallGuidelines[1]) * pipe.select(1)}
        + {wallHeight.B == 0 and {} or pipe.new * makeWallB(fz(guidelines.r))(wallGuidelines[2]) * pipe.select(1)}
        + {wallHeight.A == 0 and {} or pipe.new * makeWallA(fz(guidelines.complementary.l), compactness == nil)(wallGuidelines[3]) * pipe.select(2)}
        + {wallHeight.B == 0 and {} or pipe.new * makeWallB(fz(guidelines.complementary.r), compactness == nil)(wallGuidelines[4]) * pipe.select(2)}
        + {wallHeight.A == 0 and {} or pipe.new * makeWallA(fz(guidelines.c))(wallGuidelines[5]) * pipe.select(1)}
        + {wallHeight.B == 0 and {} or pipe.new * makeWallB(fz(guidelines.c))(wallGuidelines[6]) * pipe.select(1)}
        
        + {wallHeight.A ~= 0 and pipe.new * trackPavingGuidelines[1] * pipe.map(makePaving(fz(guidelines.l))) * pipe.map(pipe.select(1)) * pipe.flatten() or {}}
        + {wallHeight.B ~= 0 and pipe.new * trackPavingGuidelines[2] * pipe.map(makePaving(fz(guidelines.r))) * pipe.map(pipe.select(1)) * pipe.flatten() or {}}
        + {wallHeight.A ~= 0 and pipe.new * trackPavingGuidelines[3] * pipe.map(makePaving(fz(guidelines.complementary.l))) * pipe.map(pipe.select(2)) * pipe.flatten() or {}}
        + {wallHeight.B ~= 0 and pipe.new * trackPavingGuidelines[4] * pipe.map(makePaving(fz(guidelines.complementary.r))) * pipe.map(pipe.select(2)) * pipe.flatten() or {}}
        + {wallHeight.A ~= 0 and pipe.new * trackPavingGuidelines[5] * pipe.map(makePaving(fz(guidelines.c))) * pipe.map(pipe.select(1)) * pipe.flatten() or {}}
        + {wallHeight.B ~= 0 and pipe.new * trackPavingGuidelines[6] * pipe.map(makePaving(fz(guidelines.c))) * pipe.map(pipe.select(1)) * pipe.flatten() or {}}
    
    return
        pipe.new
        * {
            edgeLists = {pipe.new * {arcs} * (station.prepareEdges(({false, true, nil})[params.freeNodes + 1])) * ((wallHeight.A == 0 and wallHeight.B == 0) and trackBuilder.normal() or trackBuilder.nonAligned())},
            terrainAlignmentLists = ((wallHeight.A == 0 and wallHeight.B == 0) and {} or polys),
            models = walls * pipe.flatten(),
            groundFaces = pipe.new
            / tdp.slotGen(wallHeight.A, terrainGuidelines[1], "inf", "mid")
            / tdp.slotGen(wallHeight.B, terrainGuidelines[2], "inf", "mid")
            / tdp.slotGen(wallHeight.A, terrainGuidelines[3], "mid", "sup")
            / tdp.slotGen(wallHeight.B, terrainGuidelines[4], "mid", "sup")
            / tdp.slotGen(wallHeight.A, terrainGuidelines[5], "inf", "mid")
            / tdp.slotGen(wallHeight.B, terrainGuidelines[6], "inf", "mid")
            * pipe.flatten()
            * pipe.map(function(p) return {face = p, modes = {{type = "FILL", key = "hole.lua"}}} end)
        }
end


return {
    type = "TRACK_CONSTRUCTION",
    description = {
        name = _("Switches"),
        description = _("Switch on one track or switch group on many tracks.")
    },
    categories = {"track_construction"},
    availability = {
        yearFrom = 1850
    },
    buildMode = "MULTI",
    -- categories = {"misc"},
    order = 27225,
    skipCollision = true,
    autoRemovable = false,
    params = params(),
    updateFn = function(params, closureParams) return updateFn(params, closureParams) end,
    update = updateFn
}
