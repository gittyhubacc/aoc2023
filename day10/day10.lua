#!/usr/bin/lua

local dir = {
	north = { 0, -1 },
	south = { 0, 1 },
	west = { -1, 0 },
	east = { 1, 0 }
}

-- test if the delta we used to arrive at ch
-- is appropriate for it's shape
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
	end
end

-- return the direction ch faces
-- when it's approached from dx/dy
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

-- replace the S with the appropriate pipe part
local function replace_s(grid, x, y)
	local linked = {}
	for name, delta in pairs(dir) do
		local dx, dy = table.unpack(delta)
		local ch = grid[y + dy] and grid[y + dy][x + dx] or nil
		linked[name] = appropriate(ch, dx, dy)
	end
	if linked.north then
		if linked.south then
			return '|'
		elseif linked.east then
			return 'L'
		elseif linked.west then
			return 'J'
		end
	elseif linked.south then
		if linked.east then
			return 'F'
		elseif linked.west then
			return '7'
		end
	else
		return '-'
	end
end

-- read input into a grid
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
	grid[sy][sx] = replace_s(grid, sx, sy)
	return grid, sx, sy
end

local function hash(x, y)
	return x .. ',' .. y
end

local function walk_grid(grid, graph, x, y, dx, dy, i)
	local ch = grid[y] and grid[y][x] or nil
	if not ch or not appropriate(ch, dx, dy) then
		return nil, false, i
	end

	local looped = false
	local key = hash(x, y)
	if not graph[key] then
		local node = { ch = ch }
		node.dir = facing(ch, dx, dy)
		local fx, fy = table.unpack(node.dir)
		node.child, looped, i = walk_grid(grid, graph, x + fx, y + fy, fx, fy, i + 1)
		graph[key] = node
	else
		looped = true
	end
	return graph[key], looped, i
end

local function load_graph(grid, x, y)
	local root = {}
	local graph = {}
	graph.root = root
	graph[hash(x, y)] = root
	for name, delta in pairs(dir) do
		local dx, dy = table.unpack(delta)
		local node, loop, i = walk_grid(grid, graph, x + dx, y + dy, dx, dy, 1)
		if loop then
			graph.deep = i
			root.dir = delta
			root[name] = node
			root.ch = grid[y][x]
			break
		end
	end
	return graph
end

-- returns directions from which you are on the "left" of ch
-- takes into consideration the direction ch was facing when it was "laid"
local function left_deltas(ch, d)
	if ch == '|' then
		if d == dir.north then
			return {{1, 0}}
		else
			return {{-1, 0}}
		end
	elseif ch == '-' then
		if d == dir.east then
			return {{0, 1}}
		else
			return {{0, -1}}
		end
	elseif ch == 'L' then
		if d == dir.north then
			return {{1, 0}, {0, -1}}
		else
			return {}
		end
	elseif ch == 'J' then
		if d == dir.west then
			return {{-1, 0}, {0, -1}}
		else
			return {}
		end
	elseif ch == '7' then
		if d == dir.south then
			return {{0, 1}, {-1, 0}}
		else
			return {}
		end
	elseif ch == 'F' then
		if d == dir.east then
			return {{1, 0}, {0, 1}}
		else
			return {}
		end
	end
end


-- is the coordinate passed on the "left" or "right" side of the main loop
local function left_or_right(grid, graph, x, y)
	for _, delta in pairs(dir) do
		local dx, dy = table.unpack(delta)
		local cx, cy = x + dx, y + dy
		while grid[cy] and grid[cy][cx] do
			local node = graph[hash(cx, cy)]
			if node then
				for _, dp in ipairs(left_deltas(node.ch, node.dir)) do
					if dp[1] == dx and dp[2] == dy then
						return true
					end
				end
				return false
			end
			cx = cx + dx
			cy = cy + dy
		end
	end
	-- the case where a cell does not touch the main loop in any of nsew directions
	-- whether it's on the left or right in this case is dependent
	-- on whether we're traversing the main loop clockwise or counter clockwise
	-- which isn't something i figured out how to reliably define
	return graph.root.dir == dir.north or graph.root.dir == dir.east
end

local function count_sides(grid, graph)
	local left = 0
	local right = 0
	for y, row in ipairs(grid) do
		for x, ch in ipairs(row) do
			if not graph[hash(x, y)] then
				if left_or_right(grid, graph, x, y) then
					left = left + 1
				else
					right = right + 1
				end
			end
		end
	end
	return left, right
end

local grid, sx, sy = load_grid(arg[1] or 'input')
local graph = load_graph(grid, sx, sy)
print('part 1: ', math.floor(graph.deep / 2))
print('part 2: ', count_sides(grid, graph))

