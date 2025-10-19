---@class Elements
local EL = select(2, ...)

EL.ELEMENT_BASE = {
    options = {
        {name = 'width', type = 'range', min = 100, max = 2000, step = 1, label = 'Width', width = 25},
        {name = 'height', type = 'range', min = 100, max = 2000, step = 1, label = 'Height', width = 25},
        {name = 'xOffset', type = 'range', min = -1000, max = 1000, step = 1, label = 'X Offset', width = 25},
        {name = 'yOffset', type = 'range', min = -1000, max = 1000, step = 1, label = 'Y Offset', width = 25},
        {name = 'frameStrata', type = 'dropdown', options = { 'TOOLTIP', 'DIALOG', 'FULLSCREEN', 'HIGH', 'MEDIUM', 'LOW' }, label = 'Frame Strata', width = 25},
    }
}