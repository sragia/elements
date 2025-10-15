---@class Elements
local EL = select(2, ...)
local moduleName = 'frame-input-dropdown'

---@class DropdownOptions : {initial: string, onChange: function, options: table, label: string, width?: number, height?: number}

---@class DropdownInput
local dropdown = EL:GetModule(moduleName)

dropdown.Init = function(self)
    self.pool = CreateFramePool('Frame', UIParent)
    self.optionItemPool = CreateFramePool('Frame', UIParent)
end

local function CreateOption(f, frameOptions)
    local option = dropdown.optionItemPool:Acquire()
    option:SetSize(
        frameOptions.width or 205,
        frameOptions.height or 30
    )

    if (not option.valueDisplay) then
        local valueDisplay = option:CreateFontString(nil, 'OVERLAY')
        option.valueDisplay = valueDisplay
        valueDisplay:SetFont(EL.const.fonts.DEFAULT, 10, 'OUTLINE')
        valueDisplay:SetPoint('LEFT', 10, 0)
        valueDisplay:SetWidth(0)

        option.SetOption = function(self, value, label)
            option.value = value
            option.valueDisplay:SetText(label)
        end

        local tex = option:CreateTexture(nil, 'BACKGROUND')
        tex:SetTexture(EL.const.textures.frame.bg)
        tex:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
        tex:SetTextureSliceMargins(15, 15, 15, 15)
        tex:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
        tex:SetVertexColor(0.15, 0.15, 0.15, 1)
        tex:SetAllPoints()
        option.texture = tex
    end
    option:SetScript('OnMouseDown', function(self)
        f:SetInputValue(self.value)
        f:SetValue('isOpen', false)
    end)

    if (not option.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, option)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        option.hoverContainer = hoverContainer
        hoverBorder:SetTexture(EL.const.textures.frame.inputs.editboxHover)
        hoverBorder:SetTexCoord(6 / 512, 506 / 512, 5 / 64, 58 / 64)
        hoverBorder:SetAllPoints()
        hoverContainer:SetAlpha(0)
        option.animDur = 0.15
        option.onHover = EL.utils.animation.fade(hoverContainer, option.animDur, 0, 1)
        option.onHoverLeave = EL.utils.animation.fade(hoverContainer, option.animDur, 1, 0)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)
    end

    option:SetScript('OnEnter', function(self)
        self.onHover:Play()
    end)
    option:SetScript('OnLeave', function(self) self.onHoverLeave:Play() end)
    return option
end

local function PopulateOptions(f, options, frameOptions)
    dropdown.optionItemPool:ReleaseAll()
    local previous
    local count = 0
    for value, label in pairs(options) do
        count = count + 1
        local option = CreateOption(f, frameOptions)
        option:SetOption(value, label)
        option:SetPoint('TOPLEFT',
            previous or f.optionContainer,
            previous and 'BOTTOMLEFT' or 'TOPLEFT',
            0,
            previous and -5 or 0
        )
        option:SetParent(f.optionContainer)
        option:Show()
        previous = option
    end
    f.optionContainer:SetHeight(70 * count)
end

local function ConfigureFrame(f, options)
    EL.utils.addObserver(f)
    f:SetSize(options.width or 200, options.height or 70)
    f:SetFrameStrata('TOOLTIP')
    f.isOpen = false
    f.onChange = options.onChange
    f.options = options.options

    if (not f.valueDisplay) then
        local valueDisplay = f:CreateFontString(nil, 'OVERLAY')
        f.valueDisplay = valueDisplay
        valueDisplay:SetFont(EL.const.fonts.DEFAULT, 10, 'OUTLINE')
        valueDisplay:SetPoint('LEFT', 10, 0)
        valueDisplay:SetWidth(0)
        valueDisplay:SetText(' ')
        f:Observe('value', function(value)
            local label = f.options[value] or value
            valueDisplay:SetText(label ~= '' and label or ' ')
        end)

        f.SetInputValue = function(self, value)
            self:SetValue('value', value)
            if (self.onChange) then
                self.onChange(value)
            end
        end

        f:SetScript('OnMouseDown', function()
            f:SetValue('isOpen', not f.isOpen)
        end)

        local tex = f:CreateTexture(nil, 'BACKGROUND')
        tex:SetTexture(EL.const.textures.frame.bg)
        tex:SetTexCoord(7 / 512, 505 / 512, 7 / 512, 505 / 512)
        tex:SetTextureSliceMargins(15, 15, 15, 15)
        tex:SetTextureSliceMode(Enum.UITextureSliceMode.Tiled)
        tex:SetVertexColor(0.25, 0.25, 0.25, 0.6)
        tex:SetAllPoints()
        f.texture = tex
    end

    if (not f.chevron) then
        local chevron = f:CreateTexture(nil, 'OVERLAY')
        chevron:SetSize(12, 12)
        chevron:SetPoint('RIGHT', -10, 0)
        chevron:SetTexture(EL.const.textures.frame.inputs.chevronDown)
        f:Observe('isOpen', function(value)
            if (value) then
                f.optionContainer:Show()
                PopulateOptions(f, f.options, options)
                chevron:SetRotation(math.rad(180))
            else
                f.optionContainer:Hide()
                chevron:SetRotation(math.rad(0))
            end
        end)
    end

    if (not f.label and options.label) then
        local textFrame = f:CreateFontString(nil, 'OVERLAY')
        textFrame:SetFont(EL.const.fonts.DEFAULT, 10, 'OUTLINE')
        textFrame:SetPoint('BOTTOMLEFT', f.valueDisplay, 'TOPLEFT', 0, 16)
        textFrame:SetWidth(0)
        f.label = textFrame
        textFrame:SetText(options.label)
    end

    if (not f.hoverContainer) then
        local hoverContainer = CreateFrame('Frame', nil, f)
        hoverContainer:SetAllPoints()
        local hoverBorder = hoverContainer:CreateTexture()
        hoverContainer.border = hoverBorder
        f.hoverContainer = hoverContainer
        hoverBorder:SetTexture(EL.const.textures.frame.inputs.editboxHover)
        hoverBorder:SetTexCoord(6 / 512, 506 / 512, 5 / 64, 58 / 64)
        hoverBorder:SetAllPoints()
        hoverContainer:SetAlpha(0)
        f.animDur = 0.15
        f.onHover = EL.utils.animation.fade(hoverContainer, f.animDur, 0, 1)
        f.onHoverLeave = EL.utils.animation.fade(hoverContainer, f.animDur, 1, 0)
        hoverBorder:SetVertexColor(1, 0.84, 0, 1)
    end

    f:SetScript('OnEnter', function(self)
        self.onHover:Play()
    end)
    f:SetScript('OnLeave', function(self) self.onHoverLeave:Play() end)
    if (not f.optionContainer) then
        local optionContainer = CreateFrame('Frame', nil, UIParent)
        optionContainer:SetHeight(1)
        optionContainer:SetPoint('TOPLEFT', f, 'BOTTOMLEFT', 0, -5)
        optionContainer:SetPoint('TOPRIGHT', f, 'BOTTOMRIGHT', 0, -5)
        optionContainer:SetFrameStrata('FULLSCREEN_DIALOG')
        optionContainer:SetFrameLevel(99)
        f.optionContainer = optionContainer
        optionContainer:Hide()
        optionContainer:SetScript('OnEnter', function() end)
        optionContainer:SetScript('OnLeave', function() end)
    end

    if (options.initial) then
        f:SetValue('value', options.initial)
    end

    f.SetOptions = function(self, newOptions)
        self.options = newOptions
    end
end


---@param self ELDropdownInput
---@param options DropdownOptions
---@param parent FRAME
---@return FRAME
dropdown.Create = function(self, options, parent)
    local input = self.pool:Acquire()
    ConfigureFrame(input, options)
    if (parent) then
        input:SetParent(parent)
    else
        input:SetParent(nil)
    end
    input.Destroy = function(self)
        self.pool:Release(self)
    end
    input:Show()
    return input
end
