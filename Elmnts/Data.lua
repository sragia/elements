---@class Elements
local EL = select(2, ...)

---@class ELData
local data = EL:GetModule('data')

data.data = {
    showMinimap = true,
    disableDuplicateCheck = false
}

data.Init = function(self)
    if (ElementsData) then
        self.data = ElementsData
    end
end

data.Save = function(self)
    self:RemoveElementObservers()
    ElementsData = self.data
end

data.RemoveElementObservers = function(self)
    if (not self.data.elements) then return end
    for _, element in pairs(self.data.elements) do
        element.observable = nil
    end
end

data.SetData = function(self, data)
    self.data = data
end

data.SetDataByKey = function(self, key, data)
    self.data[key] = data;
end

data.GetDataByKey = function(self, key)
    return self.data[key];
end

data.AddDataToKey = function(self, key, data)
    self.data[key] = self.data[key] or {}
    table.insert(self.data[key], data)
end