#!/usr/bin/lua

local words = {
	'one',
	'two',
	'three',
	'four',
	'five',
	'six',
	'seven',
	'eight',
	'nine'
}

local part1 = 0
local part2 = 0
for line in io.lines(arg[1] or 'input') do
	local digits = {}
	local digits2 = {}
	local line2 = line
	for value, word in ipairs(words) do
		line2 = string.gsub(line2, word, word .. value .. word)
	end
	for digit in string.gmatch(line, '%d') do
		digits[#digits+1] = digit
	end
	for digit in string.gmatch(line2, '%d') do
		digits2[#digits2+1] = digit
	end
	part1 = part1 + (digits[1] * 10) + digits[#digits]
	part2 = part2 + (digits2[1] * 10) + digits2[#digits2]
end
print('part 1: ', part1)
print('part 2: ', part2)
