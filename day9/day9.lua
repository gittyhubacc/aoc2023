#!/usr/bin/lua

local function day9(seq, dir)
	local diff = {}
	local all_zero = true
	for i = 1, #seq - 1 do
		diff[#diff + 1] = seq[i + 1] - seq[i]
		all_zero = all_zero and diff[#diff] == 0
	end
	if all_zero then return 0 else
		local op = (-1 + (dir*2))
		local idx = 1 + (dir * (#diff - 1))
		return diff[idx] + (op * day9(diff, dir))
	end
end

local part1 = 0
local part2 = 0
local dir = { future = 1, past = 0 }
for line in io.lines(arg[1] or 'input') do
	local seq = {}
	for match in string.gmatch(line, '-?%d+') do
		seq[#seq+1] = tonumber(match)
	end
	part1 = part1 + (seq[#seq] + day9(seq, dir.future))
	part2 = part2 + (seq[1] - day9(seq, dir.past))
end
print('part 1: ', part1)
print('part 2: ', part2)
