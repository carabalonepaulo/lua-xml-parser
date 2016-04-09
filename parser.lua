local Lexer = require('lexer')
local Tokens = require('token')

local Parser = {}
Parser.__index = Parser

function Parser:new(xml)
    local self = {}
    self.index = 2
    self.lexer = Lexer:new(xml)
    self.stack = self.lexer:parse()
    return setmetatable(self, Parser)
end

function Parser:peek(i)
    if not i then i = 0 end
    return self.stack[self.index + i] 
end

function Parser:parseNode()
    local currentNode = {}
    currentNode.Attributes = {}
    currentNode.ChildNodes = {}
    
    while true do
        local token = self:peek()

        if not token then return nil end

        if token[1] == Tokens.Label then
            if self:peek(-1)[1] == Tokens.Less then
                currentNode.Tag = token[2]
            elseif self:peek(-1)[1] == Tokens.Label or self:peek(-1)[1] == Tokens.String then
                if self:peek(1)[1] == Tokens.Equal and self:peek(2)[1] == Tokens.String then
                    currentNode.Attributes[self:peek()[2]] = self:peek(2)[2]
                    self.index = self.index + 1
                end
            end
        elseif self:peek()[1] == Tokens.InnerText then
            currentNode.InnerText = self:peek()[2]:match('^%s+(.-)%s+$')
        elseif self:peek()[1] == Tokens.Less and self:peek(1)[1] == Tokens.Slash then
            return currentNode
        elseif self:peek()[1] == Tokens.Less and self:peek(1)[1] == Tokens.Label then
            self.index = self.index + 1
            local child = self:parseNode()
            table.insert(currentNode.ChildNodes, child)
        elseif self:peek()[1] == Tokens.Slash then
            return currentNode
        end
        self.index = self.index + 1
    end
end

return Parser