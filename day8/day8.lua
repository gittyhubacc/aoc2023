#!/usr/bin/lua

local function gcd(a, b)
	return b == 0 and a or gcd(b, a % b)
end
local function lcm(a, b)
	return math.floor((a * b) / gcd(a, b))
end

local function find_steps(directions, nodes, start, pattern)
	local idx = 1
	local steps = 0
	local cursor = start
	while not string.match(cursor, pattern) do
		local dir = directions[idx]
		cursor = nodes[cursor][dir]
		steps = steps + 1
		idx = idx + 1
		if idx > #directions then
			idx = 1
		end
	end
	return steps
end

local function day8(path)
	local iterator = io.lines(path)

	local nodes = {}
	local directions = {}
	local directions_str = iterator()
	for direction in string.gmatch(directions_str, '[LR]') do
		directions[#directions+1] = direction
	end
	local pattern = '(%w+) = %((%w+), (%w+)%)'
	for line in iterator do
		local name, left, right = string.match(line, pattern)
		if name and left and right then
			nodes[name] = { L = left, R = right }
		end
	end

	print('part 1: ', find_steps(directions, nodes, 'AAA', 'ZZZ'))

	local part2 = 1
	for name, node in pairs(nodes) do
		if string.match(name, '%w%wA') then
			local factor = find_steps(directions, nodes, name, '%w%wZ')
			part2 = lcm(part2, factor)
		end
	end
	print('part 2: ', part2)
end
day8(arg[1] or 'input')

