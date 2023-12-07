#!/usr/bin/lua

local type = {
	five_kind = 7,
	four_kind = 6,
	full_house = 5,
	three_kind = 4,
	two_pair = 3,
	one_pair = 2,
	high_card = 1
}

local function strength(hand)
	local cards = {}
	for card in string.gmatch(hand, '%w') do
		cards[card] = (cards[card] or 0) + 1
	end

	local jokers = 0
	local quads = {}
	local triples = {}
	local doubles = {}
	for card, copies in pairs(cards) do
		if card == 'J' then
			jokers = copies
		elseif copies == 5 then
			return type.five_kind
		elseif copies == 4 then
			quads[#quads+1] = card
		elseif copies == 3 then
			triples[#triples+1] = card
		elseif copies == 2 then
			doubles[#doubles+1] = card
		end
	end

	if #quads > 0 then
		return jokers > 0
			and type.five_kind
			or type.four_kind
	elseif #doubles == 1 and #triples == 1 then
		return type.full_house
	elseif #triples == 1 then
		if jokers == 2 then
			return type.five_kind
		elseif jokers == 1 then
			return type.four_kind
		end
		return type.three_kind
	elseif #doubles == 2 then
		if jokers == 1 then
			return type.full_house
		end
		return type.two_pair
	elseif #doubles == 1 then
		if jokers == 3 then
			return type.five_kind
		elseif jokers == 2 then
			return type.four_kind
		elseif jokers == 1 then
			return type.three_kind
		end
		return type.one_pair
	elseif #doubles == 0 and #triples == 0 then
		if jokers == 5 or jokers == 4 then
			return type.five_kind
		elseif jokers == 3 then
			return type.four_kind
		elseif jokers == 2 then
			return type.three_kind
		elseif jokers == 1 then
			return type.one_pair
		end
		return type.high_card
	end
end

local card_value = {
	['A'] = 12,
	['K'] = 11,
	['Q'] = 10,
	['T'] = 9,
	['9'] = 8,
	['8'] = 7,
	['7'] = 6,
	['6'] = 5,
	['5'] = 4,
	['4'] = 3,
	['3'] = 2,
	['2'] = 1,
	['J'] = 0
}

local function tiebreak(left, right)
	for i = 1, 5 do
		local l = string.match(left, '%w', i)
		local r = string.match(right, '%w', i)
		if l ~= r then return card_value[l] < card_value[r] end
	end
end

local hands = {}
for line in io.lines(arg[1] or 'input') do
	local hand, score = string.match(line, '(%w+) (%d+)')
	hands[#hands+1] = {
		hand = hand,
		score = tonumber(score),
		strength = strength(hand)
	}
end

table.sort(hands, function(left, right)
	if left.strength == right.strength then
		return tiebreak(left.hand, right.hand)
	end
	return left.strength < right.strength
end)

local part2 = 0
for i, v in ipairs(hands) do
	part2 = part2 + (v.score * i)
end
print(part2)

