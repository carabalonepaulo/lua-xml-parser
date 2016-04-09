local Parser = require('parser')

local XmlDocument = {}
XmlDocument.__index = XmlDocument

function XmlDocument:new()
    local self = {}
    self.parser = nil
    self.root = {}
    return setmetatable(self, XmlDocument)
end

function XmlDocument:load(xml)
    self.parser = Parser:new(xml)
    self.root = self.parser:parseNode()
end

function XmlDocument:loadFile(filename)
    local file = io.open(filename, 'r')
    local xml = file:read('*a')
    file:close()
    self:load(xml)
end


--[[local doc = XmlDocument:new()
doc:loadFile('./books.xml')
for _, n in pairs(doc.root.ChildNodes) do print(n.Attributes['author'], n.Attributes['title'], n.Attributes['date'], n.InnerText or '') end]]

