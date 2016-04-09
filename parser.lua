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

function Parser:skip(i)
    self.index = self.index + i
end

function Parser:parseNode()
    local currentNode = {}
    currentNode.Attributes = {}
    currentNode.ChildNodes = {}
    
    while true do
        if not self:peek() then return nil end
        
        if self:peek().Type == Tokens.Label then
            if self:peek(-1).Type == Tokens.Less then
                currentNode.Tag = self:peek().Value
            elseif self:peek(-1).Type == Tokens.Label or self:peek(-1).Type == Tokens.String then
                if self:peek(1).Type == Tokens.Equal and self:peek(2).Type == Tokens.String then
                    currentNode.Attributes[self:peek().Value] = self:peek(2).Value
                    self:skip(1)
                end
            end
        elseif self:peek().Type == Tokens.Greater then
            if self:peek(1).Type == Tokens.InnerText then
                currentNode.InnerText = self:peek(1).Value
            end
        elseif self:peek().Type == Tokens.Less and self:peek(1).Type == Tokens.Slash then
            return currentNode   
        elseif self:peek().Type == Tokens.Less and self:peek(1).Type == Tokens.Label then
            self:skip(1)
            local child = self:parseNode()
            table.insert(currentNode.ChildNodes, child)
        elseif self:peek().Type == Tokens.Slash and (self:peek(-1).Type == Tokens.String or self:peek(-1).Type == Tokens.Label) then
            return currentNode 
        end
        self:skip(1)
    end
end

local file = io.open('./books.xml', 'r')
local xml = file:read('*a')
file:close()

local st = os.clock()
local doc
for i = 0, 10000 do
    doc = Parser:new(xml)
end
print(os.clock() - st)

--return Parser