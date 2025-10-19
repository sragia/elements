---@class Elements
local EL = select(2, ...)

----------------

---@class ELElementItem
local elementItem = EL:GetModule('element-item')

elementItem.pool = {}

elementItem.Init = function(self)
    self.pool = CreateFramePool('Button', UIParent)
end

local function ConfigureFrame(f)
    EL.utils.addObserver(f)
    f:SetHeight(30)

    local text = f:CreateFontString(nil, 'OVERLAY')
    text:SetFont(EL.const.fonts.DEFAULT, 11, 'OUTLINE')
    text:SetPoint('CENTER')
    text:SetWidth(0)
    f.text = text

    f.SetData = function(self, data)
        self.data = data
        self.text:SetText(data.name)
    end

    f.SetOnClick = function(self, onClick)
        f:SetScript('OnClick', onClick)
    end
    f.configured = true
end

elementItem.Create = function(self, options, parent)
    local f = self.pool:Acquire()
    if (not f.configured) then
        ConfigureFrame(f)
    end
    f:SetOnClick(options.onClick)

    f.Destroy = function(self)
        self.data = nil
        elementItem.pool:Release(self)
    end

    if (parent) then
        f:SetParent(parent)
    else
        f:SetParent(nil)
    end

    return f
end