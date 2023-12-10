#!/usr/bin/lua

local function load_grid(path)
	local y = 1
	local sx, sy
	local grid = {}
	for line in io.lines(path) do
		local x = 1
		grid[y] = {}
		for d in line:gmatch('.') do
			grid[y][x] = d
			if d == 'S' then
				sx = x
				sy = y
			end
			x = x + 1
		end
		y = y + 1
	end
	return grid, sx, sy
end

local dir = {
	north = { 0, -1 },
	south = { 0, 1 },
	west = { -1, 0 },
	east = { 1, 0 }
}

local function facing(ch, dx, dy)
	if ch == '|' then
		return dy == 1 and dir.south or dir.north
	elseif ch == '-' then
		return dx == 1 and dir.east or dir.west
	elseif ch == 'L' then
		return dx == -1 and dir.north or dir.east
	elseif ch == 'J' then
		return dx == 1 and dir.north or dir.west
	elseif ch == '7' then
		return dx == 1 and dir.south or dir.west
	elseif ch == 'F' then
		return dx == -1 and dir.south or dir.east
	end
end

local function appropriate(ch, dx, dy)
	if ch == '|' then
		return dx == 0
	elseif ch == '-' then
		return dy == 0
	elseif ch == 'L' then
		return dx == -1 or dy == 1
	elseif ch == 'J' then
		return dx == 1 or dy == 1
	elseif ch == '7' then
		return dx == 1 or dy == -1
	elseif ch == 'F' then
		return dx == -1 or dy == -1
	else
		return ch == 'S'
	end
end

local function hash(x, y)
	return x .. ',' .. y
end

local function reverse_hash(h)
	return string.match(h, '(%d+),(%d+)')
end

local function walk_grid(grid, graph, rx, ry, dx, dy, i)
	local x = rx + dx
	local y = ry + dy
	local ch = grid[y] and grid[y][x] or nil
	if not ch or not appropriate(ch, dx, dy) then
		return nil, false, i
	end
	local looped = false
	if ch ~= 'S' then
		local node = { ch = ch }
		local fx, fy = table.unpack(facing(ch, dx, dy))
		node.child, looped, i = walk_grid(grid, graph, x, y, fx, fy, i + 1)
		graph[hash(x,y)] = node
	else
		looped = true
	end
	return graph[hash(x,y)], looped, i
end

local function load_graph(grid, x, y)
	local root = {}
	local graph = {}
	graph[hash(x,y)] = root
	local printed = false
	for name, delta in pairs(dir) do
		local dx, dy = table.unpack(delta)
		local node, loop, i = walk_grid(grid, graph, x, y, dx, dy, 1)
		if loop then
			root[name] = node
			if not printed then
				printed = true
				print('part 1: ', math.floor(i / 2))
			end
		end
	end
	return graph
end

local function add_to_group(grid, graph, group, group_map, x, y)
	if not grid[y] or not grid[y][x] then
		return
	end
	group[hash(x,y)] = group
	group_map[hash(x,y)] = group
	for ny = -1, 1 do
		for nx = -1, 1 do
			local idx = hash((x + nx) ,(y + ny))
			if not graph[idx] and not group_map[idx] and (x ~= 0 and y ~= 0) then
				add_to_group(grid, graph, group, group_map, x + nx, y + ny)
			end
		end
	end
end

local function crossed(ch, dx, dy)
	if ch == '-' then
		return dy ~= 0
	elseif ch == '|' then
		return dx ~= 0
	end
	return false
end

local function can_escape(grid, graph, x, y)
	for name, delta in pairs(dir) do
		local bad_dir = false
		local dx, dy = table.unpack(delta)
		local cx, cy = x + dx, y + dy
		while grid[cy] and grid[cy][cx] do
			local ch = grid[cy][cx]
			local node = graph[hash(cx, cy)]
			if node and crossed(node.ch, dx, dy) then
				--print('crossed at: ' .. cx .. ', ' .. cy, node.ch)
				--print('dx,dy = ', dx, dy)
				bad_dir = true
				break
			end
			cx = cx + dx
			cy = cy + dy
		end
		if not bad_dir then
			print('group can escape! ', x, y)
			return true
		end
	end
	return false
end

local grid, sx, sy = load_grid(arg[1] or 'input')
local graph = load_graph(grid, sx, sy)
local group_map = {}
local groups = {}
for y, row in ipairs(grid) do
	for x, ch in ipairs(row) do
		if not graph[hash(x,y)] and not group_map[hash(x,y)] then
			local group = {}
			groups[#groups+1] = group
			add_to_group(grid, graph, group, group_map, x, y)
		end
	end
end

local part2 = 0
print('found ' .. #groups .. ' groups')
for i, group in ipairs(groups) do
	local group_total = 0
	local group_inside = true
	for key, _ in pairs(group) do
		group_total = group_total + 1
		local x, y = reverse_hash(key)
		if group_inside and can_escape(grid, graph, x, y) then
			group_inside = false
		end
	end
	if group_inside then
		part2 = part2 + group_total
	end
end
print('part 2: ', part2)





