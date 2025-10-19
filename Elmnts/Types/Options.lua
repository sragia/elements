---@class Elements
local EL = select(2, ...)

---@class ELDataTypes
local dataTypes = EL:GetModule('data-types')

----------------

---@class ELOptionsTypes
local optionsTypes = EL:GetModule('options-types')

optionsTypes.types = {
    [dataTypes.dataType.STATIC] = {
        options = {
            {
                width = { type = 'range', min = 100, max = 2000, step = 1, order = 1 },
                height = { type = 'range', min = 100, max = 2000, step = 1, order = 2 },
                texturePath = { type = 'editbox', tooltip = 'Example: Interface\\AddOns\\Elmnts\\Textures\\Frame\\Bg.png', order = 3 },
                xOffset = { type = 'range', min = -1000, max = 1000, step = 1, order = 4 },
                yOffset = { type = 'range', min = -1000, max = 1000, step = 1, order = 5 },
                frameStrata = { type = 'dropdown', options = { 'TOOLTIP', 'DIALOG', 'FULLSCREEN', 'HIGH', 'MEDIUM', 'LOW' }, order = 6 },
            }
        }
    }
}