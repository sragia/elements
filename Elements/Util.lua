---@class Elements
local EL = select(2, ...)

local randCharSet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

-- Proper base64 decoder for Lua
local function decodeBase64(encodedString)
    -- Base64 character set
    local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local b64dec = {}
    for i = 1, #b64chars do
        b64dec[string.sub(b64chars, i, i)] = i - 1
    end

    -- Remove any whitespace and padding
    encodedString = encodedString:gsub("%s+", "")

    -- Add padding if needed
    local padding = 4 - (#encodedString % 4)
    if padding < 4 then
        encodedString = encodedString .. string.rep("=", padding)
    end

    -- Decode base64
    local result = {}
    local i = 1
    while i <= #encodedString do
        local a = b64dec[encodedString:sub(i, i)] or 0
        local b = b64dec[encodedString:sub(i + 1, i + 1)] or 0
        local c = b64dec[encodedString:sub(i + 2, i + 2)] or 0
        local d = b64dec[encodedString:sub(i + 3, i + 3)] or 0

        table.insert(result, string.char(bit.lshift(a, 2) + bit.rshift(b, 4)))
        if encodedString:sub(i + 2, i + 2) ~= "=" then
            table.insert(result, string.char(bit.lshift(bit.band(b, 15), 4) + bit.rshift(c, 2)))
        end
        if encodedString:sub(i + 3, i + 3) ~= "=" then
            table.insert(result, string.char(bit.lshift(bit.band(c, 3), 6) + d))
        end

        i = i + 4
    end

    return table.concat(result)
end

-- Simple JSON to Lua table converter
local function jsonToLuaTable(jsonString)
    -- Convert JSON to Lua table format manually
    local luaString = jsonString

    -- Convert arrays
    luaString = luaString:gsub('%[', '{'):gsub('%]', '}')

    -- Convert objects
    luaString = luaString:gsub('"([^"]+)"%s*:%s*"([^"]*)"', '["%1"] = "%2"')
    luaString = luaString:gsub('"([^"]+)"%s*:%s*{', '["%1"] = {')
    luaString = luaString:gsub('"([^"]+)"%s*:%s*([^,}]+)', '["%1"] = %2')

    -- Convert boolean values
    luaString = luaString:gsub('true', 'true'):gsub('false', 'false')
    luaString = luaString:gsub('null', 'nil')

    -- Convert empty strings in arrays
    luaString = luaString:gsub('""', '""')

    -- Try to load and execute
    local success, result = pcall(function()
        return loadstring('return ' .. luaString)()
    end)

    if success then
        return result
    else
        print("Failed to parse as Lua:", result)
        return nil
    end
end


EL.utils = {
    isEmpty = function(t)
        for _ in pairs(t) do
            return false
        end
        return true
    end,
    spairs = function(t, order)
        -- collect the keys
        local keys = {}
        for k in pairs(t) do
            keys[#keys + 1] = k
        end

        -- if order function given, sort by it by passing the table and keys a, b,
        -- otherwise just sort the keys
        if order then
            table.sort(
                keys,
                function(a, b)
                    return order(t, a, b)
                end
            )
        else
            table.sort(keys)
        end

        -- return the iterator function
        local i = 0
        return function()
            i = i + 1
            if keys[i] then
                return keys[i], t[keys[i]]
            end
        end
    end,
    getKeys = function(t)
        local keys = {}
        for k in pairs(t) do
            keys[#keys + 1] = k
        end
        return keys
    end,
    deepCloneTable = function(orig)
        local orig_type = type(orig)
        local copy
        if orig_type == 'table' then
            copy = {}
            for orig_key, orig_value in next, orig, nil do
                copy[EL.utils.deepCloneTable(orig_key)] = EL.utils.deepCloneTable(orig_value)
            end
            setmetatable(copy, EL.utils.deepCloneTable(getmetatable(orig)))
        else -- number, string, boolean, etc
            copy = orig
        end
        return copy
    end,
    animation = {
        getAnimationGroup = function(f)
            return f:CreateAnimationGroup();
        end,
        fade = function(f, duration, from, to, ag)
            ag = ag or f:CreateAnimationGroup()
            local fade = ag:CreateAnimation('Alpha')
            fade:SetFromAlpha(from or 0)
            fade:SetToAlpha(to or 1)
            fade:SetDuration(duration or 1)
            fade:SetSmoothing((from > to) and 'OUT' or 'IN')
            local finishScript = ag:GetScript('OnFinished')
            ag:SetScript(
                'OnFinished',
                function(...)
                    if (finishScript) then finishScript(...) end
                    f:SetAlpha(to)
                end
            )
            return ag
        end,
        diveIn = function(f, duration, xOff, yOff, smoothing, ag)
            ag = ag or f:CreateAnimationGroup()
            local translate = ag:CreateAnimation('Translation')
            translate:SetOffset(xOff, -yOff)
            translate:SetDuration(duration)
            translate:SetSmoothing(smoothing)
            ag:SetScript('OnPlay', function()
                if (smoothing == 'OUT') then
                    return
                end

                for i = 1, f:GetNumPoints() do
                    local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
                    f:SetPoint(point, relativeTo, relativePoint, xOfs + xOff, yOfs + yOff)
                end
            end)
            local finishScript = ag:GetScript('OnFinished')
            ag:SetScript('OnFinished', function(...)
                if (finishScript) then finishScript(...) end

                if (smoothing == 'OUT') then
                    return
                end

                for i = 1, f:GetNumPoints() do
                    local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
                    f:SetPoint(point, relativeTo, relativePoint, xOfs - xOff, yOfs - yOff)
                end
            end)

            return ag
        end,
        move = function(f, duration, xOff, yOff, ag)
            ag = ag or f:CreateAnimationGroup()
            local translate = ag:CreateAnimation('Translation')
            translate:SetOffset(xOff, yOff)
            translate:SetDuration(duration)
            local finishScript = ag:GetScript('OnFinished')
            ag:SetScript('OnFinished', function(...)
                if (finishScript) then finishScript(...) end

                for i = 1, f:GetNumPoints() do
                    local point, relativeTo, relativePoint, xOfs, yOfs = f:GetPoint(i)
                    f:SetPoint(point, relativeTo, relativePoint, xOfs + xOff, yOfs + yOff)
                end
            end)

            return ag
        end
    },
    addObserver = function(t, force)
        if (t.observable and not force) then
            return t
        end

        t.observable = {}
        t.Observe = function(_, key, onChangeFunc)
            if (type(key) == 'table') then
                for _, k in ipairs(key) do
                    t.observable[k] = t.observable[k] or {}
                    table.insert(t.observable[k], onChangeFunc)
                end
            else
                t.observable[key] = t.observable[key] or {}
                table.insert(t.observable[key], onChangeFunc)
            end
        end
        t.SetValue = function(_, key, value)
            local oldValue = t[key]
            t[key] = value
            if (t.observable[key]) then
                for _, func in ipairs(t.observable[key]) do
                    func(value, oldValue)
                end
            end
        end

        t.ClearObservable = function(self)
            self.observable = {}
        end

        return t
    end,
    printOut = function(outputString)
        print("|cffc334eb[Elements]|r " .. outputString)
    end,
    addDebugTexture = function(frame)
        local tex = frame:CreateTexture()
        tex:SetTexture(EL.const.textures.frame.bg)
        tex:SetTexCoord(0.49, 0.51, 0.49, 0.51)
        tex:SetVertexColor(1, 0, 0, 1)
        tex:SetAllPoints()
    end,
    debugWithDevTools = function(data)
        C_Timer.After(1, function()
            if (not DevTool) then
                print('DEBUG no devtool')
                return
            end
            if (DevTool.AddData) then
                DevTool:AddData(data)
            elseif (DevTool_AddData) then
                DevTool_AddData(data)
            else
                print('Devtool Available but no AddData function')
            end
        end)
    end,
    suggestMatch = function(userInput, source)
        local suggestions = {}
        for _, data in pairs(source) do
            local matchinString = (data.id or '')
            local matchStart, matchEnd = string.find(string.lower(matchinString), string.lower(userInput), 1, true)
            if matchStart ~= nil then
                table.insert(suggestions,
                    {
                        str = matchinString,
                        score = matchEnd - matchStart + 1 + (matchStart - 1) / #matchinString,
                        data = data
                    })
            else
                local words = {}
                for word in string.gmatch(string.lower(userInput), '%S+') do
                    table.insert(words, word)
                end
                local pattern = ''
                for j = 1, #words do
                    pattern = pattern .. words[j] .. '%S*'
                end
                local phraseStart, phraseEnd = string.find(string.lower(matchinString), pattern, 1, true)
                if phraseStart ~= nil then
                    table.insert(suggestions, {
                        str = matchinString,
                        score = phraseEnd - phraseStart + 1 +
                            (phraseStart - 1) / #matchinString,
                        data = data
                    })
                end
            end
        end
        table.sort(suggestions, function(a, b) return a.score < b.score end)
        return suggestions
    end,
    switch = function(condition, cases)
        return (cases[condition] or cases.default)()
    end,
    generateRandomString = function(length)
        length = length or 10
        local output = ""
        for i = 1, length do
            local rand = math.random(#randCharSet)
            output = output .. string.sub(randCharSet, rand, rand)
        end
        return output
    end,
    compareSemver = function(v1, v2)
        -- -1 - older
        -- 0 - equal
        -- 1 - newer
        local function splitVersion(version)
            return version:match("(%d+)%.(%d+)%.(%d+)")
        end

        local major1, minor1, patch1 = splitVersion(v1)
        local major2, minor2, patch2 = splitVersion(v2)
        if (not tonumber(major1) or not tonumber(major2)) then
            return 0
        end

        if tonumber(major1) > tonumber(major2) then
            return 1
        elseif tonumber(major1) < tonumber(major2) then
            return -1
        else
            if tonumber(minor1) > tonumber(minor2) then
                return 1
            elseif tonumber(minor1) < tonumber(minor2) then
                return -1
            else
                if tonumber(patch1) > tonumber(patch2) then
                    return 1
                elseif tonumber(patch1) < tonumber(patch2) then
                    return -1
                else
                    return 0
                end
            end
        end
    end,
    decodeFromGoogleSheets = function(encodedString)
        -- Decode base64
        local decoded = decodeBase64(encodedString)
        if not decoded or #decoded == 0 then
            print("Failed to decode base64")
            return nil
        end

        -- Convert JSON to Lua table
        local success, data = pcall(function()
            return jsonToLuaTable(decoded)
        end)

        if not success or not data then
            print("JSON parsing failed")
            print("Error:", data)
            return nil
        end

        return data
    end,
    arrayIndexForvalue = function(arr, value)
        for index, val in ipairs(arr) do
            if val == value then
                return index + 1
            end
        end
        return nil
    end,
    findGroupForPlayer = function(playerName)
        for i = 1, GetNumGroupMembers() do
            local name, _, group = GetRaidRosterInfo(i)
            if (Ambiguate(name, 'short') == playerName) then
                return group
            end
        end
    end
}
