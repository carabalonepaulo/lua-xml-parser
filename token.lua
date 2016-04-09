local Tokens = {
	Label = 1,
	Less = 2,
	Greater = 3,
	Equal = 4,
	String = 5,
	DQuote = 6,
	SQuote = 7,
	Colon = 8,
	LParen = 9,
	RParen = 10,
	InnerText = 11,
    Slash = 12,
	EOF = 13
}

function Token(si, ei, constv, value)
	return setmetatable({ StartIndex = si, EndIndex = ei, Type = constv, Value = value }, {
		__tostring = function (t)
			for k, v in pairs(Tokens) do
				if v == t.Type then return k end
			end
		end
	})
end

return Tokens