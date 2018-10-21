local func = require "track_design_patterns/func"
local coor = require "track_design_patterns/coor"
local arc = require "track_design_patterns/coorarc"
local station = require "track_design_patterns/stationlib"
local pipe = require "track_design_patterns/pipe"
local tdp = {}

local math = math
local pi = math.pi
local abs = math.abs
local ceil = math.ceil
local floor = math.floor

tdp.infi = 1e8


tdp.trackList = {"standard.lua", "high_speed.lua"}
tdp.trackWidthList = {5, 5}
tdp.trackType = pipe.exec * function()
    local list = {
        {
            key = "trackType",
            name = _("Track type"),
            values = {_("Standard"), _("High-speed")},
            yearFrom = 1925,
            yearTo = 0
        },
        {
            key = "catenary",
            name = _("Catenary"),
            values = {_("No"), _("Yes")},
            defaultIndex = 1,
            yearFrom = 1910,
            yearTo = 0
        }
    }
    if (commonapi and commonapi.uiparameter) then
        commonapi.uiparameter.modifyTrackCatenary(list, {selectionlist = tdp.trackList})
        tdp.trackWidthList = func.map(tdp.trackList, function(e) return commonapi.repos.track.getByName(e).data.trackDistance end)
    end
    
    return pipe.new * list
end

local normalizeSize = function(mirrored, size)
    return 
        ((size.lt - size.lb):cross(size.rb - size.lb).z * (mirrored and -1 or 1) < 0)
        and size
        or {
            lt = size.rt,
            lb = size.rb,
            rt = size.lt,
            rb = size.lb
        }
end


tdp.fitModel2D = function(w, h)
    return function(mirrored)
        return function(fitTop, fitLeft)
            return function(size)
                local size = normalizeSize(mirrored, size)
                local s = {
                    coor.xyz(0, 0),
                    coor.xyz(fitLeft and w or -w, 0),
                    coor.xyz(0, fitTop and -h or h),
                }
                
                local t = fitTop and
                    {
                        fitLeft and size.lt or size.rt,
                        fitLeft and size.rt or size.lt,
                        fitLeft and size.lb or size.rb,
                    } or {
                        fitLeft and size.lb or size.rb,
                        fitLeft and size.rb or size.lb,
                        fitLeft and size.lt or size.rt,
                    }
                
                local mX = {
                    {s[1].x, s[1].y, 1},
                    {s[2].x, s[2].y, 1},
                    {s[3].x, s[3].y, 1},
                }
                
                local mU = {
                    t[1].x, t[1].y, 1,
                    t[2].x, t[2].y, 1,
                    t[3].x, t[3].y, 1,
                }
                
                local dX = coor.det(mX)
                
                local miX = coor.minor(mX)
                local mXI = func.mapFlatten(func.seq(1, 3),
                    function(l)
                        return func.seqMap({1, 3}, function(c)
                            return ((l + c) % 2 == 0 and 1 or -1) * coor.det(miX(c, l)) / dX
                        end)
                    end)
                
                local function mul(m1, m2)
                    local m = function(line, col)
                        local l = (line - 1) * 3
                        return m1[l + 1] * m2[col + 0] + m1[l + 2] * m2[col + 3] + m1[l + 3] * m2[col + 6]
                    end
                    return {
                        m(1, 1), m(1, 2), m(1, 3),
                        m(2, 1), m(2, 2), m(2, 3),
                        m(3, 1), m(3, 2), m(3, 3),
                    }
                end
                
                local mXi = mul(mXI, mU)
                
                return coor.I() * {
                    mXi[1], mXi[2], 0, mXi[3],
                    mXi[4], mXi[5], 0, mXi[6],
                    0, 0, 1, 0,
                    mXi[7], mXi[8], 0, mXi[9]
                }
            end
        end
    end
end

tdp.fitModel = function(w, h)
    return function(mirrored)
        return function(fitTop, fitLeft)
            return function(size)
                local size = normalizeSize(mirrored, size)
                local s = {
                    coor.xyz(0, 0, 0),
                    coor.xyz(fitLeft and w or -w, 0, 0),
                    coor.xyz(0, fitTop and -h or h, 0),
                    coor.xyz(0, 0, -1)
                }
                
                local t = fitTop and
                    {
                        fitLeft and size.lt or size.rt,
                        fitLeft and size.rt or size.lt,
                        fitLeft and size.lb or size.rb,
                    } or {
                        fitLeft and size.lb or size.rb,
                        fitLeft and size.rb or size.lb,
                        fitLeft and size.lt or size.rt,
                    }
                
                local mX = {
                    {s[1].x, s[1].y, s[1].z, 1},
                    {s[2].x, s[2].y, s[2].z, 1},
                    {s[3].x, s[3].y, s[3].z, 1},
                    {s[4].x, s[4].y, s[4].z, 1}
                }
                
                local mU = {
                    t[1].x, t[1].y, t[1].z, 1,
                    t[2].x, t[2].y, t[2].z, 1,
                    t[3].x, t[3].y, t[3].z, 1,
                    t[1].x, t[1].y, t[1].z - 1, 1
                }
                
                local dX = coor.det(mX)
                
                local miX = coor.minor(mX)
                local mXI = func.mapFlatten(func.seq(1, 4),
                    function(l)
                        return func.seqMap({1, 4}, function(c)
                            return ((l + c) % 2 == 0 and 1 or -1) * coor.det(miX(c, l)) / dX
                        end)
                    end)
                
                return coor.I() * mXI * mU
            end
        end
    end
end

tdp.buildCoors = function(numTracks, groupSize, config)
    config = config or {
        trackWidth = station.trackWidth,
        wallWidth = 0.5
    }
    local function builder(xOffsets, uOffsets, baseX, nbTracks)
        local function caller(n)
            return builder(
                xOffsets + func.seqMap({1, n}, function(n) return baseX - 0.5 * config.trackWidth + n * config.trackWidth end),
                uOffsets + {baseX + n * config.trackWidth + 0.5 * config.wallWidth},
                baseX + n * config.trackWidth + config.wallWidth,
                nbTracks - n)
        end
        if (nbTracks == 0) then
            local offset = function(o) return o - baseX * config.wallWidth end
            return
                {
                    tracks = xOffsets * pipe.map(offset),
                    walls = uOffsets * pipe.map(offset)
                }
        elseif (nbTracks < groupSize) then
            return caller(nbTracks)
        else
            return caller(groupSize)
        end
    end
    return builder(pipe.new, pipe.new * {0.5 * config.wallWidth}, config.wallWidth, numTracks)
end

tdp.normalizeRad = function(rad)
    return (rad < pi * -0.5) and tdp.normalizeRad(rad + pi * 2) or rad
end

tdp.generateArc = function(arc, ext)
    local ext = ext or 5
    local toXyz = function(pt) return coor.xyz(pt.x, pt.y, 0) end
    
    local extArc = arc:extendLimits(ext)
    
    local sup = toXyz(arc:pt(arc.sup))
    local inf = toXyz(arc:pt(arc.inf))
    local mid = toXyz(arc:pt(arc.mid))
    
    local vecSup = arc:tangent(arc.sup)
    local vecInf = arc:tangent(arc.inf)
    local vecMid = arc:tangent(arc.mid)
    
    local supExt = toXyz(extArc:pt(extArc.sup))
    local infExt = toXyz(extArc:pt(extArc.inf))
    
    return {
        {inf, mid, vecInf, vecMid, rad = {arc.inf, arc.mid}},
        {mid, sup, vecMid, vecSup, rad = {arc.mid, arc.sup}},
        {infExt, inf, extArc:tangent(extArc.inf), vecInf, rad = {extArc.inf, arc.inf}},
        {sup, supExt, vecSup, extArc:tangent(extArc.sup), rad = {arc.sup, extArc.sup}}
    }
end


tdp.fArcs = function(offsets, rad, r)
    return pipe.new
        * offsets
        * function(o) return r > 0 and o or o * pipe.map(pipe.neg()) * pipe.rev() end
        * pipe.map(function(x) return
            func.with(
                arc.byOR(
                    coor.xyz(r, 0, 0) .. coor.rotZ(rad),
                    abs(r) - x
                ), {xOffset = r > 0 and x or -x})
        end)
        * function(a) return r > 0 and a or a * pipe.rev() end
end

tdp.makeFn = function(rot180)
    local m = rot180 and coor.flipX() * coor.flipY() or coor.I()
    return function(model, fitModel, mPlace, w, l, eW)
        local l = l or 5
        local eW = eW or w
        local fitTopLeft = fitModel(w, l)(false)(true, true)
        local fitBottomRight = fitModel(w, l)(false)(false, false)
        return function(obj)
            local coordsGen = arc.coords(obj, l)
            local inner = obj + (- eW * 0.5)
            local outer = obj + (eW * 0.5)
            local function makeModel(seq, scale)
                return pipe.new * func.map(func.interlace(seq, {"i", "s"}), 
                function(rad)
                    return {
                        station.newModel(model .. (rot180 and "_br.mdl" or "_tl.mdl"),
                        m * mPlace(fitTopLeft, inner, outer, rad.i, rad.s)
                    ),
                        station.newModel(model .. (rot180 and "_tl.mdl" or "_br.mdl"),
                        m * mPlace(fitBottomRight, inner, outer, rad.i, rad.s)
                    )
                }
                end) * pipe.flatten()
            end
            return {
                makeModel(coordsGen(tdp.normalizeRad(obj.inf), tdp.normalizeRad(obj.mid))),
                makeModel(coordsGen(tdp.normalizeRad(obj.mid), tdp.normalizeRad(obj.sup)))
            }
        end
    end
end

local biLatCoords = function(length, from, to)
    return function(l, ...)
        local nSeg = (function(x) return (x < 1 or (x % 1 > 0.5)) and ceil(x) or floor(x) end)(abs((from(l) - to(l)) * l.r))
        local rst = pipe.new * {l, ...}
        return table.unpack(
            func.map(rst,
                function(s) 
                    local radF, radT = from(s), to(s)
                    local lscale = (radF - radT) * s.r / (nSeg * length)
                    return abs(lscale) < 1e-5 and pipe.new * {} or pipe.new * func.seqMap({0, nSeg},
                    function(n) 
                        local rad = radF + n * ((radT - radF) / nSeg)
                        return func.with(s:pt(rad):withZ(0), {rad = rad}) end)
                end)
    )
    end
end

tdp.generatePolyArc = function(groups, from, to)
    local groupI, groupO = groups[1], groups[#groups]
    return function(extLon, extLat)
            local coorO, coorI = biLatCoords(5, function(s) return tdp.normalizeRad(s[from]) end, function(s) return tdp.normalizeRad(s[to]) end)(
                    (groupO + extLat):extendLimits(extLon), 
                    (groupI + (-extLat)):extendLimits(extLon)
                )

            return 
                pipe.new *
                pipe.mapn(func.interlace(coorO, {"i", "s"}), func.interlace(coorI, {"i", "s"}))
                (function(o, i) return { o.i, o.s, i.s, i.i } end)
    end
end

tdp.generatePolyArcFn = function(groups, from, to)
    local groupI, groupO = groups[1], groups[#groups]
    return function(extLon, extLat)
            local coorO, coorI = biLatCoords(5, from, to)(
                    (groupO + extLat):extendLimits(extLon), 
                    (groupI + (-extLat)):extendLimits(extLon)
                )

            return 
                pipe.new *
                pipe.mapn(func.interlace(coorO, {"i", "s"}), func.interlace(coorI, {"i", "s"}))
                (function(o, i) return { o.i, o.s, i.s, i.i } end)
    end
end

function tdp.polyGen(slope)
    return function(wallHeight, refHeight, guidelines, wHeight, fr, to)
        local f = function(s) return s.g and
            tdp.generatePolyArc(s.g, fr, to)(-0.2, 0)
            * pipe.map(pipe.map(s.fz))
            * station.projectPolys(coor.I())
            or {}
        end
        local polyGen = function(l, e, g)
            return wallHeight == 0 and f(e) or (wallHeight > 0 and f(g) or f(l))
        end
        return {
            slot = polyGen(
                {},
                {},
                {g = guidelines.outer, fz = function(p) return coor.transZ(p.y * slope)(p) end}
            ),
            equal = polyGen(
                {},
                refHeight > 0 and {} or {g = guidelines.ref, fz = function(p) return coor.transZ(p.y * slope)(p) end},
                {}
            ),
            less = polyGen(
                {g = guidelines.outer, fz = function(p) return coor.transZ(p.y * slope)(p) end},
                refHeight > 0 and {g = guidelines.ref, fz = function(p) return coor.transZ(p.y * slope)(p) end} or {},
                {g = guidelines.outer, fz = function(p) return coor.transZ(p.y * slope + wallHeight)(p) end}
            ),
            greater = polyGen(
                {g = guidelines.outer, fz = function(p) return coor.transZ(p.y * slope - wHeight)(p) end},
                refHeight > 0 and {g = guidelines.ref, fz = function(p) return coor.transZ(p.y * slope)(p) end} or {},
                refHeight >= 0 and {g = guidelines.outer, fz = function(p) return coor.transZ(p.y * slope)(p) end} or
                {g = guidelines.outer, fz = function(p) return coor.transZ(p.y * slope - wHeight + wallHeight)(p) end}
        )
        }
    end
end


return tdp
