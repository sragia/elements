---@class Elements
local EL = select(2, ...)

local static = {
    id = 'static',
    name = 'Static'
}
MergeTable(static, EL.ELEMENT_BASE)

table.insert(static.options, {
    type = 'editbox',
    name = 'texturePath',
    label = 'Texture Path',
    tooltip = 'Example: Interface\\AddOns\\Elmnts\\Textures\\Frame\\Bg.png',
    width = 25,
})


EL:RegisterElementType(static.id, static)