#!/usr/bin/lua

local function increment_copies(copies, idx, inc)
	copies[idx] = (copies[idx] or 0) + (inc or 1)
end

local function day4(path)
	local part1 = 0
	local part2 = 0
	local copies = {}
	local copy_idx = 1

	for line in io.lines(path) do
		increment_copies(copies, copy_idx)

		local numbers = string.gsub(line, '%d+:', 'who cares')
		local sep = string.find(numbers, '|')

		local score = 0
		local matches = 0
		local position = 1
		local winners = {}
		for match in string.gmatch(numbers, '(%d+)') do
			local location = string.find(numbers, match, position)
			if location < sep then
				winners[match] = true
			elseif winners[match] then
				if score < 1 then score = 1
				else score = score * 2 end
				matches = matches + 1
			end
			position = location + 2
		end
		part1 = part1 + score

		for i = matches, 1, -1 do
			increment_copies(copies, copy_idx + i, copies[copy_idx])
			matches = matches - 1
		end
		part2 = part2 + copies[copy_idx]
		copy_idx = copy_idx + 1
	end

	print('part 1: ', part1)
	print('part 2: ', part2)
end

day4(arg[1] or 'input')
