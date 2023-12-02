#!/usr/bin/lua

-- i'm unsure of whether or not these values are specific to me or not
local max = {
	red = 12,
	green = 13,
	blue = 14
}

local part1 = 0
local part2 = 0
for line in io.lines(arg[1] or 'input') do
	local id = string.match(line, 'Game (%d+): ')
	local min = { red = nil, green = nil, blue = nil }
	local _, upper = string.find(line, id)
	line = string.sub(line, upper + 3)

	local impossible = false
	for numstr, color in string.gmatch(line, '(%d+) (%w+)') do
		local num = tonumber(numstr)
		if max[color] < num then
			impossible = true
		end
		if not min[color] or min[color] < num then
			min[color] = num
		end
	end
	if not impossible then
		part1 = part1 + id
	end
	part2 = part2 + (min.green * min.red * min.blue)
end
print('part 1:', part1)
print('part 2:', part2)
