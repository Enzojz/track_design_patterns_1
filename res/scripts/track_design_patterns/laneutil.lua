local vec3 = require "vec3"

local laneutil = { }
local function calcScale(dist, angle)
	if (angle < .001) then
		return dist
	end
	
	local pi = 3.14159
	local pi2 = pi / 2	
	local sqrt2 = 1.41421
	
	local scale = 1.0
	if (angle >= pi2) then 
		scale = 1.0 + (sqrt2 - 1.0) * ((angle - pi2) / pi2)
	end

	return .5 * dist / math.cos(.5 * pi - .5 * angle) * angle * scale
end

function laneutil.makeLanes(input)
	local result = { }
	
	for i = 1, #input do
		local entry = input[i]
	
		local p0 = entry[1]
		local p1 = entry[2]
		local t0 = entry[3]
		local t1 = entry[4]
		local width = entry[5]

		p0 = vec3.new(p0[1], p0[2], p0[3])
		p1 = vec3.new(p1[1], p1[2], p1[3])
		
		t0 = vec3.normalize(vec3.new(t0[1], t0[2], t0[3]))
		t1 = vec3.normalize(vec3.new(t1[1], t1[2], t1[3]))
		
		local length = vec3.distance(p0, p1)
		local angle = vec3.angleUnit(t0, t1)
		
		local scale = calcScale(length, angle)
		
		t0 = vec3.mul(scale, t0)
		t1 = vec3.mul(scale, t1)
		
		table.insert(result, { { p0.x, p0.y, p0.z }, { t0.x, t0.y, t0.z }, width } )
		table.insert(result, { { p1.x, p1.y, p1.z }, { t1.x, t1.y, t1.z }, width } )
	end	
	
	return result
end

return laneutil
