local Tokens = require('token')

local Lexer = {}
Lexer.__index = Lexer

function Lexer:new(xml)
	local self = {}
	self.xml = xml
	self.index = 1
	self.stack = {}
	return setmetatable(self, Lexer)	
end

function Lexer:isAlpha(char)
	local c = (char or ''):lower()
	return (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9') or c == '_' or c == '-'
end

function Lexer:nextToken(lt)
	local label, innerTag, lastToken = '', false, lt
	local matchAll, endChar, startIndex = false, '', 0

	while true do
		local char = string.sub(self.xml, self.index, self.index)
		self.index = self.index + 1

		if char:len() == 0 then
			return Tokens.EOF, 'EOF'
		elseif matchAll then
			if char == endChar then
				return Tokens.String, string.sub(self.xml, startIndex, self.index - 2)
			end
		elseif char == '<' then
			if label ~= '' then
				self.index = self.index - 1
				return Tokens.InnerText, label
			end
			return Tokens.Less, char
		elseif char == '>' then
			innerTag = true
			if label ~= '' then
				self.index = self.index - 1
				return Tokens.Label, label
			end
			return Tokens.Greater, char
		elseif char == '/' then
			return Tokens.Slash, char
		elseif char == '=' then
			if label ~= '' then
				self.index = self.index - 1
				return Tokens.Label, label
			end
			return Tokens.Equal, char
		elseif char == '"' or char == "'" then
			matchAll = true
			endChar = char
			startIndex = self.index
		elseif char == ' ' or char == '\n' or char == '\t' then
			if lastToken ~= Tokens.Greater then
				if label ~= '' then return Tokens.Label, label end
			else label = label..char end
		elseif self:isAlpha(char) then
			label = label..char
		end
	end
end

function Lexer:parse()
	self.stack = {}
	local lt = nil
	while true do
		local tk, vl = self:nextToken(lt)
		table.insert(self.stack, { tk, vl })
		lt = tk
		if tk == Tokens.EOF then break end
	end
	return self.stack
end

return Lexer