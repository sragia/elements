---@class Elements
local EL = select(2, ...)

---@class Data
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
    ElementsData = self.data
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
