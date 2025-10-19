local addonName = ...

---@class Elements
local EL = select(2, ...)

local initIndx = 0

EL.modules = {}
EL.elements = {}
EL.dataProviders = {}

---Get and Initialize a module
---@param self Elements
---@param id any
---@return unknown
EL.GetModule = function(self, id)
    if (not self.modules[id]) then
        initIndx = initIndx + 1
        self.modules[id] = {
            _index = initIndx
        }
    end

    return self.modules[id]
end

EL.InitModules = function(self)
    for _, module in EL.utils.spairs(self.modules, function(t, a, b) return t[a]._index < t[b]._index end) do
        if (module.Init) then
            module:Init()
        end
    end
end

EL.RegisterElementType = function(self, id, elementData)
    self.elements[id] = elementData
end

EL.RegisterDataProviderType = function(self, id, dataProviderData)
    self.dataProviders[id] = dataProviderData
end

EL.GetElementTypeById = function(self, id)
    if (self.elements[id]) then
        return self.elements[id]
    end
    return nil
end

EL.GetAllElementTypes = function(self)
    return self.elements
end

EL.GetDataProviderTypeById = function(self, id)
    if (self.dataProviders[id]) then
        return self.dataProviders[id]
    end
    return nil
end

EL.handler = CreateFrame('Frame')
EL.handler:RegisterEvent('ADDON_LOADED')
EL.handler:RegisterEvent('PLAYER_LOGOUT')

EL.handler:SetScript('OnEvent', function(self, event, ...)
    if (event == 'ADDON_LOADED' and ... == addonName) then
        EL:InitModules()
    elseif (event == 'PLAYER_LOGOUT') then
        EL:GetModule('data'):Save()
    end
end)
