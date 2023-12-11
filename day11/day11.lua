#!/usr/bin/lua

local function load_planets(path)
	local y = 1
	local planets = {}
	for line in io.lines(path) do
		local x = 1
		for match in line:gmatch('.') do
			if match == '#' then
				planets[#planets+1] = { x = x, y = y }
			end
			x = x + 1
		end
		y = y + 1
	end
	return planets
end

local function expand(planets, factor)
	local new_planets = {}
	local hit = { x = {}, y = {} }
	for _, p in ipairs(planets) do
		hit.x[p.x] = true
		hit.y[p.y] = true
	end

	for _, p in ipairs(planets) do
		local new_x = p.x
		local new_y = p.y
		for x = 1, p.x do
			if not hit.x[x] then
				new_x = new_x + factor
			end
		end
		for y = 1, p.y do
			if not hit.y[y] then
				new_y = new_y + factor
			end
		end
		new_planets[#new_planets+1] = { x = new_x, y = new_y }
	end

	return new_planets
end

local function distance(a, b)
	return math.abs((b.y - a.y)) + math.abs((b.x - a.x))
end

local function solution(planets)
	local rv = 0
	for a, planet_a in ipairs(planets) do
		for b, planet_b in ipairs(planets) do
			if a ~= b then
				rv = rv + distance(planet_a, planet_b)
			end
		end
	end
	return math.floor(rv / 2)
end

local planets = load_planets(arg[2] or 'input')
print('part 1: ', solution(expand(planets, 1)))
print('part 2: ', solution(expand(planets, tonumber(arg[1]))))
