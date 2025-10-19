---@class Elements
local EL = select(2, ...)

---@class ELOptionsControl
local optionsControl = EL:GetModule('options-control')

---@class ELElementManager
local elementManager = EL:GetModule('element-manager')

---@class ELDropdownInput
local dropdownInput = EL:GetModule('frame-input-dropdown')

---@class ELEditBoxInput
local editBoxInput = EL:GetModule('edit-box-input')
----------------

---@class ELConfigurationView
local configurationView = EL:GetModule('options-configuration-view')

configurationView.initialized = false
configurationView.frame = nil
configurationView.optionFrames = {}

configurationView.Init = function(self)
    optionsControl:Observe('currentElement', function(newValue, oldValue)
        configurationView:OnElementSwitch(newValue)
    end)
end

configurationView.GetFrame = function(self)
    if (not self.initialized) then
        self.initialized = true
        self.frame = CreateFrame('Frame', nil, UIParent)
        self:SetupDefaultInputs()
    end

    return self.frame
end

configurationView.SetupDefaultInputs = function(self)

    local nameEditBox = editBoxInput:Create({
        label = 'Name',
        onChange = function(frame, value)
            local element = elementManager:GetElementById(optionsControl:GetCurrentElement())
            element:SetValue('name', value)
        end
    }, self.frame)
    nameEditBox:SetPoint('TOPLEFT', 0, 0)
    nameEditBox:SetSize(200, 40)
    nameEditBox:Hide()
    self.frame.nameEditBox = nameEditBox


    local elementTypes = EL:GetAllElementTypes()
    local elementTypeOptions = {}
    for id, elementType in pairs(elementTypes) do
        elementTypeOptions[id] = elementType.name
    end
    local elementTypeDropdown = dropdownInput:Create({
        options = elementTypeOptions,
        initial = 'static',
        onChange = function(value)
            print('type onChange', value)
        end,
        label = 'Type'
    }, self.frame)
    elementTypeDropdown:SetPoint('TOPLEFT', nameEditBox, 'TOPRIGHT', 5, 0)
    elementTypeDropdown:Hide()
    self.frame.elementTypeDropdown = elementTypeDropdown

    local noElementSelected = self.frame:CreateFontString(nil, 'OVERLAY')
    noElementSelected:SetFont(EL.const.fonts.DEFAULT, 10, 'OUTLINE')
    noElementSelected:SetPoint('CENTER')
    noElementSelected:SetWidth(0)
    noElementSelected:SetText('No element selected')
    noElementSelected:SetTextColor(1, 1, 1, 1)
    noElementSelected:Show()
    self.frame.noElementSelected = noElementSelected

    local elementTypeConfigContainer = CreateFrame('Frame', nil, self.frame)
    elementTypeConfigContainer:SetPoint('TOPLEFT', nameEditBox, 'BOTTOMLEFT', 0, -10)
    elementTypeConfigContainer:SetPoint('BOTTOMRIGHT')
    elementTypeConfigContainer:Hide()
    local elementTypeConfigTexture = elementTypeConfigContainer:CreateTexture(nil, 'BACKGROUND')
    elementTypeConfigTexture:SetTexture(EL.const.textures.frame.bg)
    elementTypeConfigTexture:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
    elementTypeConfigTexture:SetTextureSliceMargins(15, 15, 15, 15)
    elementTypeConfigTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
    elementTypeConfigTexture:SetVertexColor(0.1, 0.1, 0.1, 1)
    elementTypeConfigTexture:SetAllPoints()
    elementTypeConfigContainer.texture = elementTypeConfigTexture
    self.frame.elementTypeConfigContainer = elementTypeConfigContainer
end

configurationView.OnElementSelected = function(self, selected)
    if (selected) then
        self.frame.nameEditBox:Show()
        self.frame.elementTypeDropdown:Show()
        self.frame.elementTypeConfigContainer:Show()
        self.frame.noElementSelected:Hide()
    else
        self.frame.nameEditBox:Hide()
        self.frame.elementTypeDropdown:Hide()
        self.frame.elementTypeConfigContainer:Hide()
        self.frame.noElementSelected:Show()
    end
end

configurationView.OnElementSwitch = function(self, id)
    local element = elementManager:GetElementById(id)
    self:OnElementSelected(true)
    self.frame.elementTypeDropdown:SetInputValue(element.type)
    self.frame.nameEditBox:SetEditorValue(element.name)
    self:PopulateElementTypeConfig(element)
end 

configurationView.PopulateElementTypeConfig = function(self, element)
    local elementType = EL:GetElementTypeById(element.type)

    for _, frame in ipairs(self.optionFrames) do
        frame:Destroy()
    end
    self.optionFrames = {}

    for _, option in ipairs(elementType.options) do
        local optionFrame = self:GetOptionFrame(option.type)
        if (optionFrame) then
            table.insert(self.optionFrames, optionFrame)
            optionFrame:SetElementData(option, element)
        end
    end
    EL.utils.organizeFramesInGrid(
        'elementTypeConfig',
        self.optionFrames,
        5,
        self.frame.elementTypeConfigContainer,
        10,
        10
    )
end

configurationView.GetOptionFrame = function(self, optionType)
    return EL.utils.switch(optionType, {
        ['editbox'] = function()
            local f = EL:GetModule('edit-box-input'):Create({
                label = 'Edit Box',
                onChange = function(frame, value)
                    print('editbox onChange', value, frame.element.id)
                end
            })
            f:SetHeight(40)
            
            return f
        end,
        default = function()
            print('unknown option type')
            return nil
        end
    })
end