---@class Elements
local EL = select(2, ...)

---@class Window
local window = EL:GetModule('window-frame')

---@class ELElementBrowser
local elementBrowser = EL:GetModule('element-browser')

---@class OptionsControl
local control = EL:GetModule('options-control')

---@class ELConfigurationView
local configurationView = EL:GetModule('options-configuration-view')

----------------

---@class ELMainOptionsView
local mainOptionsView = EL:GetModule('main-options-view')

mainOptionsView.initialized = false
mainOptionsView.window = nil
mainOptionsView.browserContainer = nil

mainOptionsView.InitializeFrame = function(self)
    if (not self.initialized) then
        self.initialized = true
        self.window = window:Create({
            title = 'elmnts',
            size = {1200, 800},
        });
        self:AddElementBrowser()
        self:AddConfigurationView()
    end
end

mainOptionsView.AddElementBrowser = function(self)
    if not self.window then return end
    local container = CreateFrame('Frame', nil, self.window.container)
    container:SetPoint('TOPLEFT', 0, 0)
    container:SetPoint('BOTTOMRIGHT', self.window.container, 'BOTTOMLEFT', 200, 0)

    local browser = elementBrowser:GetFrame()
    browser:SetParent(container)
    browser:SetAllPoints()
    browser.scroll:UpdateScrollChild(container:GetWidth() - 20, container:GetHeight())
    self.browserContainer = container
end

mainOptionsView.AddConfigurationView = function(self)
    if not self.window then return end
    local container = CreateFrame('Frame', nil, self.window.container)
    container:SetPoint('TOPLEFT', self.browserContainer , 'TOPRIGHT', 25, 0)
    container:SetPoint('BOTTOMRIGHT')
    local configuration = configurationView:GetFrame()
    configuration:SetParent(container)
    configuration:SetAllPoints()
end


mainOptionsView.Show = function(self)
    self:InitializeFrame()
    self.window:ShowWindow()
end