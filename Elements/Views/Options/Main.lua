---@class Elements
local EL = select(2, ...)

---@class ELMainOptionsView
local mainOptionsView = EL:GetModule('main-options-view')

---@class Window
local window = EL:GetModule('window-frame')


mainOptionsView.Init = function(self)
    self.window = window:Create({
        title = 'Elements',
        size = {500, 500},
    })

    EL.utils.addDebugTexture(self.window.container)
end

mainOptionsView.Show = function(self)
    self.window:ShowWindow()
end