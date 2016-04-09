local Tokens = require('token')

local Lexer = {}
Lexer.__index = Lexer

function Lexer:new(xml)
	local self = {}
	self.xml = xml
	self.index = 1
	self.stack = {}
	self.lastToken = nil
	return setmetatable(self, Lexer)	
end

function Lexer:isAlpha(char)
	local c = (char or ''):lower()
	return (c >= 'a' and c <= 'z') or (c >= '0' and c <= '9') or c == '_' or c == '-'
end

function Lexer:isWhiteSpace(c)
    return c == ' ' or c == '\n' or c == '\t'
end

function Lexer:peek(i)
	if not i then i = 0 end
	if self.index + i > self.xml:len() then return nil end
	return self.xml:sub(self.index + i, self.index + i)
end

function Lexer:nextToken()
	local token, text = nil, self.xml
	local st, word = self.index, ''
	local matchAll, endChar = false, nil

	while true do
		local char = self:peek()
		
		if char == nil then return Token(self.index, self.index, Tokens.EOF)
		elseif matchAll then
			if char == endChar then return Token(st, self.index, Tokens.String, text:sub(st + 1, self.index - 1)) end
		elseif char == '<' then
			return Token(self.index, self.index, Tokens.Less)
		elseif char == '>' then
			return Token(self.index, self.index, Tokens.Greater)
		elseif char == '=' then
			return Token(self.index, self.index, Tokens.Equal)
		elseif char == ':' then
			return Token(self.index, self.index, Tokens.Colon)
		elseif char == '(' then
			return Token(self.index, self.index, Tokens.LParen)
		elseif char == ')' then
			return Token(self.index, self.index, Tokens.RParen)
        elseif char == '/' then
            return Token(self.index, self.index, Tokens.Slash)
		elseif self:isAlpha(char) then
            local count = -1
            local lastChar = self:peek(count)
            if self:isWhiteSpace(lastChar) then
                while true do
                    lastChar = self:peek(count)
                    if self:isWhiteSpace(lastChar) then count = count - 1
                    else break end
                end
            end
            
			if lastChar == '>' then
				st = self.index
				while true do
					local char = self:peek()
					if char == '<' then
						self.index = self.index - 1
						return Token(st, self.index, Tokens.InnerText, self.xml:sub(st, self.index))
					end
					self.index = self.index + 1
				end
			end

			if st == 0 then st = self.index end
			word = word..char
			local nc = self:peek(1)
			if not self:isAlpha(nc) or self:isWhiteSpace(char) then return Token(st, self.index, Tokens.Label, word) end
		elseif char == '"' then
			if matchAll == false then
				endChar = '"'
				matchAll = true
                st = self.index
			end
		elseif char == "'" then
			if matchAll == false then
				endChar = "'"
				matchAll = true
                st = self.index
			end
		elseif self:isWhiteSpace(char) and word ~= '' then
			return Token(st, self.index, Tokens.Label, word)
		end
		self.index = self.index + 1
	end
end

function Lexer:parse()
	self.stack = {}
	while true do
		self.lastToken = self:nextToken ()
		table.insert(self.stack, self.lastToken)

		if self.lastToken.Type == Tokens.EOF then break
		else self.index = self.lastToken.EndIndex + 1 end
	end
	return self.stack
end

--[[local lexer = Lexer:new('<livro><name attr="atributo de teste">Nome do carinha</name></livro>')
local stack = lexer:parse()
for _, i in pairs(stack) do print(i.StartIndex, i.Type, i.Value or '') end]]

return Lexer