---@class Elements
local EL = select(2, ...)

---@class ELData
local data = EL:GetModule('data')

---@class ELDataTypes
local dataTypes = EL:GetModule('data-types')

----------------

---@class ELElementManager
local elementManager = EL:GetModule('element-manager')

elementManager.elements = {}

elementManager.Init = function(self)
    EL.utils.addObserver(self)
    self.elements = data:GetDataByKey('elements') or {}
    self:AddObservers()
end

--- Creates new empty element
---@param self ELElementManager
---@return table
elementManager.Create = function(self)
    local newElement = {
        id = self:GetUniqueId(),
        name = 'New Element',
        type = dataTypes.dataType.STATIC,
    }
    data:AddDataToKey('elements', newElement)
    self:SetValue('elements', data:GetDataByKey('elements'))
    EL.utils.addObserver(newElement)
    return newElement
end

elementManager.GetElementById = function(self, id)
    local _, element = FindInTableIf(self.elements, function(element) return element.id == id end)
    return element
end

elementManager.GetUniqueId = function(self)
    local id = EL.utils.generateRandomString(20)
    local elements = data:GetDataByKey('elements')
    while elements and elements[id] do
        id = EL.utils.generateRandomString(20)
    end
    return id
end

elementManager.AddObservers = function(self)
    for _, element in pairs(self.elements) do
        EL.utils.addObserver(element)
    end
end