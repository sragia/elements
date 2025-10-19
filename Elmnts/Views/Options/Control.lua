---@class Elements
local EL = select(2, ...)

---@class ELData
local data = EL:GetModule('data')

---@class ELElementManager
local elementManager = EL:GetModule('element-manager')

----------------

---@class ELOptionsControl
local optionsControl = EL:GetModule('options-control')

optionsControl.currentElement = nil

optionsControl.Init = function(self)
    EL.utils.addObserver(self)
end

optionsControl.ChangeElement = function(self, id)
    self:SetValue('currentElement', id)
end

optionsControl.GetCurrentElement = function(self)
    return self.currentElement
end

optionsControl.GetAllElements = function(self)
    return data:GetDataByKey('elements')
end

optionsControl.CreateNewElement = function(self)
    local newElement = elementManager:Create()
    return newElement
end