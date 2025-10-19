---@class Elements
local EL = select(2, ...)

----------------

---@class ELDataTypes
local dataTypes = EL:GetModule('data-types')

dataTypes.dataType = {
    STATIC = 'static',
    UNIT = 'unit',
}

dataTypes.types = {
    {
        id = 'stagger',
        type = dataTypes.dataType.UNIT,
        name = 'Stagger',
        unitEvents = {'UNIT_ABSORB_AMOUNT_CHANGED'}
    },
    {
        id = 'static',
        type = dataTypes.dataType.STATIC,
        name = 'Static'
    }
}

dataTypes.GetById = function(self, id)
    return self.types[id]
end