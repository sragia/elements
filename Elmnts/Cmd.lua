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

SLASH_ELMNTS1 = '/elmnts'
function SlashCmdList.ELMNTS(msg)
    if (msg == 'test') then
        EL.utils.printOut('Test')
    else
        mainOptionsView:Show()
    end
end

local dataBroker = libDataBroker:NewDataObject('elmnts', {
    type = "data source",
    text = 'elmnts',
    icon = [[Interface\AddOns\Elmnts\Assets\Images\logo_icon.png]],
    OnClick = function(self, button)
        if (button == 'LeftButton') then
            mainOptionsView:Show()
        elseif (button == 'RightButton') then
            mainOptionsView:Show()
        end
    end
})

cmd.Init = function(self)
    local showMinimap = data:GetDataByKey('showMinimap')
    libDB:Register('elmnts', dataBroker, { show = showMinimap })
    self:RefreshMinimap();
end

cmd.RefreshMinimap = function(self)
    local showMinimap = data:GetDataByKey('showMinimap')
    if (showMinimap) then
        C_Timer.After(1, function()
            libDB:Show('Elements')
        end)
    else
        C_Timer.After(1, function()
            libDB:Hide('Elements')
        end)
    end
end
