---@class Elements
local EL = select(2, ...)

---@class Data
local data = EL:GetModule('data')
---@class MainOptionsView
local mainOptionsView = EL:GetModule('main-options-view')

----------------

---@class Cmd
local cmd = EL:GetModule('cmd')

local libDB = LibStub("LibDBIcon-1.0")
local libDataBroker = LibStub("LibDataBroker-1.1")

SLASH_ELEMENTSEXALITY = '/elmnt'
function SlashCmdList.ELEMENTSEXALITY(msg)
    if (msg == 'test') then
        EL.utils.printOut('Test')
    else
        mainOptionsView:Show()
    end
end

local dataBroker = libDataBroker:NewDataObject('NHF Aura Manager', {
    type = "data source",
    text = 'NHF Aura Manager',
    icon = [[Interface\AddOns\NHFAuraManager\Textures\logo.png]],
    OnClick = function(self, button)
        if (button == 'LeftButton') then
            manager:Show()
        elseif (button == 'RightButton') then
            cmdMenu:ShowMenu(self)
        end
    end
})

cmd.Init = function(self)
    local showMinimap = data:GetDataByKey('showMinimap')
    libDB:Register('NHF Aura Manager', dataBroker, { show = showMinimap })
    self:RefreshMinimap();
end

cmd.RefreshMinimap = function(self)
    local showMinimap = data:GetDataByKey('showMinimap')
    if (showMinimap) then
        C_Timer.After(1, function()
            libDB:Show('NHF Aura Manager')
        end)
    else
        C_Timer.After(1, function()
            libDB:Hide('NHF Aura Manager')
        end)
    end
end
