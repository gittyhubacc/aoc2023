#!/usr/bin/lua

local function create_interval(start_str, len_str)
	local len = tonumber(len_str)
	local start = tonumber(start_str)
	return {
		min = start,
		max = start + (len - 1)
	}
end

local function read_part1_seed_intervals(line)
	local intervals = {}
	for seed in string.gmatch(line, '%d+') do
		intervals[#intervals+1] = create_interval(seed, 1)
	end
	return intervals
end

local function read_part2_seed_intervals(line)
	local intervals = {}
	for start, len in string.gmatch(line, '(%d+) (%d+)') do
		intervals[#intervals+1] = create_interval(start, len)
	end
	return intervals
end

local function advance_interval(i, min, max, delta)
	local results = {}
	if min <= i.min and i.max <= max then
		results[#results+1] = {
			eligible = false,
			min = i.min + delta,
			max = i.max + delta
		}
	elseif i.min <= min and max <= i.max then
		results[#results+1] = {
			eligible = true,
			min = i.min,
			max = min - 1
		}
		results[#results+1] = {
			eligible = false,
			min = min + delta,
			max = max + delta
		}
		results[#results+1] = {
			eligible = true,
			min = max + 1,
			max = i.max
		}
	elseif min <= i.min and max >= i.min and max <= i.max then
		results[#results+1] = {
			eligible = false,
			min = i.min + delta,
			max = max + delta
		}
		results[#results+1] = {
			eligible = true,
			min = max + 1,
			max = i.max
		}
	elseif min >= i.min and i.max >= min and i.max <= max then
		results[#results+1] = {
			eligible = true,
			min = i.min,
			max = min - 1
		}
		results[#results+1] = {
			eligible = false,
			min = min + delta,
			max = i.max + delta
		}
	else
		results[#results+1] = i
	end
	return results
end

local map_pattern = '(%d+) (%d+) (%d+)'
local function advance_intervals(intervals, line)
	if string.match(line, ':') then
		for _, interval in ipairs(intervals) do
			interval.eligible = true
		end
		return intervals
	end

	local dest, src, len = string.match(line, map_pattern)
	if not dest or not src or not len then
		return intervals
	end

	local new_intervals = {}
	local min = tonumber(src)
	local delta = tonumber(dest) - min
	local max = min + (tonumber(len) - 1)

	for _, interval in ipairs(intervals) do
		if interval.eligible then
			local results = advance_interval(interval, min, max, delta)
			for _, new_interval in ipairs(results) do
				new_intervals[#new_intervals+1] = new_interval
			end
		else
			new_intervals[#new_intervals+1] = interval
		end
	end

	return new_intervals
end

local function solve_intervals(intervals)
	local min = nil
	for _, interval in ipairs(intervals) do
		if not min or min > interval.min then
			min = interval.min
		end
	end
	return min
end

local function day5(path)
	local lines = io.lines(path)
	local seed_data = lines()
	local intervals1 = read_part1_seed_intervals(seed_data)
	local intervals2 = read_part2_seed_intervals(seed_data)
	for line in lines do
		intervals1 = advance_intervals(intervals1, line)
		intervals2 = advance_intervals(intervals2, line)
	end
	print('part 1: ', solve_intervals(intervals1))
	print('part 2: ', solve_intervals(intervals2))
end

day5(arg[1] or 'input')
