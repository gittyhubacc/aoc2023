#!/usr/bin/lua

local function day3(path)
	local y = 1
	local poi = {}
	local symbols = {}
	for line in io.lines(path) do
		local start = 0
		for match in string.gmatch(line, '%d+') do
			local left, right = string.find(line, match, start)
			for yi = y - 1, y + 1 do
				for xi = left - 1, right + 1 do
					if not poi[yi] then
						poi[yi] = {}
					end
					if not poi[yi][xi] then
						poi[yi][xi] = {
							hits = 0,
							part1 = 0,
							part2 = 1
						}
					end

					local p = poi[yi][xi]
					local n = tonumber(match)
					p.hits = p.hits + 1
					p.part1 = p.part1 + n
					p.part2 = p.part2 * n
				end
			end
			start = right
		end

		start = 0
		symbols[y] = {}
		for match in string.gmatch(line, '[^%d.]') do
			local x = string.find(line, '%' .. match, start)
			symbols[y][x] = match
			start = x + 1
		end

		y = y + 1
	end

	local part1 = 0
	local part2 = 0
	for yi, row in pairs(symbols) do
		for xi, symbol in pairs(row) do
			local p = poi[yi][xi]
			if p then
				part1 = part1 + p.part1
				if symbol == '*' and p.hits == 2 then
					part2 = part2 + p.part2
				end
			end
		end
	end
	print('part 1: ', part1)
	print('part 2: ', part2)
end

day3(arg[1] or 'input')
