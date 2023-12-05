#!/usr/bin/lua


local phase = {
	read_header = 1,
	read_map = 2
}

local function read_header(state, line)
	local match = string.match(line, '([%s%a-]+):')
	if match == 'seeds' then
		for seed in string.gmatch(line, '%d+') do
			state.seeds[#state.seeds+1] = tonumber(seed)
		end
		for start_match, len_match in string.gmatch(line, '(%d+) (%d+)') do
			local start = tonumber(start_match)
			local len = tonumber(len_match) - 1
			for i = start, start + len do
				print(i)
				state.seeds2[#state.seeds2+1] = i
			end
		end
		return phase.read_header
	end

	local src, dest = string.match(line, '(%a+)%-to%-(%a+)')
	if src and dest then
		state.reading_src = src
		state.reading_dest = dest
		--print('reading map: ' .. (src or 'nil') .. ' to ' .. (dest or 'nil'))
		return phase.read_map
	end
end

local function read_map(state, line)
	local pattern =  '(%d+)%s*(%d+)%s*(%d+)'
	local dest_match, src_match, len_match = string.match(line, pattern)

	local dest_start = tonumber(dest_match)
	local src_start = tonumber(src_match)
	local len = tonumber(len_match)
	local delta = dest_start - src_start

	local reading_dest = state.reading_dest
	local predecessor = state.maps[state.reading_src]
	state.maps[state.reading_src] = function(input)
		if input >= src_start and input <= src_start + (len - 1) then
			return reading_dest, input + delta
		elseif predecessor then
			return predecessor(input)
		else
			return reading_dest, input
		end
	end

	return phase.read_map
end

local phases = {
	read_header,
	read_map
}

local function day5(path)
	local state = {
		maps = {},
		seeds = {},
		seeds2 = {},
		reading_src = nil,
		reading_dest = nil,
		phase = phase.read_header
	}

	for line in io.lines(path) do
		if string.match(line, '^%s*$') then
			state.phase = phase.read_header
		else
			state.phase = phases[state.phase](state, line)
		end
	end
	local part1 = nil
	for _, seed in ipairs(state.seeds) do
		local value = seed
		local type = 'seed'
		while type ~= 'location' do
			type, value = state.maps[type](value)
		end
		if not part1 or part1 > value then
			part1 = value
		end
	end
	print('part 1: ', part1)
	local part2 = nil
	for _, seed in ipairs(state.seeds2) do
		local value = seed
		local type = 'seed'
		while type ~= 'location' do
			type, value = state.maps[type](value)
		end
		if not part2 or part2 > value then
			part2 = value
		end
	end
	print('part 2: ', part2)
end

day5(arg[1] or 'input')


