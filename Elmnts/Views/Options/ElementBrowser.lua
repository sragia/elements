---@class Elements
local EL = select(2, ...)

---@class ELScrollFrame
local scrollFrame = EL:GetModule('scroll-frame')

---@class ELOptionsControl
local optionsControl = EL:GetModule('options-control')

---@class ELElementManager
local elementManager = EL:GetModule('element-manager')

---@class ELButton
local button = EL:GetModule('button')

---@class ELElementItem
local elementItem = EL:GetModule('element-item')

----------------

---@class ELElementBrowser
local elementBrowser = EL:GetModule('element-browser')

elementBrowser.initialized = false
elementBrowser.frame = nil
elementBrowser.items = {}

elementBrowser.Init = function(self)
end

elementBrowser.GetFrame = function(self)
    if (not self.initialized) then
        self.frame = CreateFrame('Frame', nil, UIParent)
        local scrollFrame = scrollFrame:Create()
        scrollFrame:SetParent(self.frame)
        scrollFrame:SetPoint('TOPLEFT', 0, 0)
        scrollFrame:SetPoint('BOTTOMRIGHT', 0, 40)
        self.frame.scroll = scrollFrame

        local newElementButton = button:Create({
            text = 'New Element',
            onClick = function()
                optionsControl:CreateNewElement()
                elementBrowser:Populate()
            end,
            color = {0, 140/255, 2/255, 1}
        }, self.frame)
        newElementButton:SetParent(self.frame)
        newElementButton:SetPoint('BOTTOMLEFT', 0, 0)
        newElementButton:SetPoint('BOTTOMRIGHT', 0, 0)
        newElementButton:SetPoint('BOTTOM', 0, 0)
        
        self.initialized = true
    end

    self:Populate()

    return self.frame
end

elementBrowser.Populate = function(self)
    local elements = optionsControl:GetAllElements()

    for _, frame in ipairs(self.items) do
        frame:Destroy()
    end
    self.items = {}

    for _, element in pairs(elements or {}) do
        local elementItem = elementItem:Create({
            onClick = function() 
                optionsControl:ChangeElement(element.id)
            end
        }, self.frame.scroll.child)
        elementItem:SetData(element)
        element:Observe('name', function(newValue, oldValue)
            local element = elementManager:GetElementById(element.id)
            elementItem:SetData(element)
        end)
        table.insert(self.items, elementItem)
        EL.utils.addDebugTexture(elementItem)
    end
    EL.utils.organizeFramesInList(self.items, 5, self.frame.scroll.child)
end
