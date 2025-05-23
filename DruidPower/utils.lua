DruidPower.Utils = {}

function DruidPower.Utils:ShortenString(str, length)
    if #str > length then
        return string.sub(str, 1, length)
    else
        return str
    end
end

function DruidPower.Utils:ShortenPlayerName(str)
    return self:ShortenString(str, 11)
end

function DruidPower.Utils:FindBuffBySpellId(unitId, spellId)
    local i = 1
    local aura = C_UnitAuras.GetBuffDataByIndex(unitId, i)
    while aura do
        if aura.spellId == spellId then
            return aura
        end

        i = i + 1
        aura = C_UnitAuras.GetBuffDataByIndex(unitId, i)
    end

    return nil
end

function DruidPower.Utils:GetBuffDurationLeft(aura)
    return math.max(0, aura.expirationTime - GetTime())
end

function DruidPower.Utils:FormatExpiration(expirationTime)
    return self:FormatDuration(math.max(0, expirationTime - GetTime()))
end

function DruidPower.Utils:FormatDuration(duration)
    if duration == 0 then
        return "00:00"
    end

    local mins = math.floor(duration / 60)
    local secs = math.floor(duration % 60)
    return string.format("%02d:%02d", mins, secs)
end

function DruidPower.Utils:DurationColor(duration, maxDuration)
    local percent = math.max(0, math.min(1, duration / maxDuration))
    if percent > 0.5 then
        return DruidPower.Constants.UI.Colors.DurationGood
    else
        return DruidPower.Constants.UI.Colors.DurationBad
    end
end

local buffOfInterestCache = {}
function DruidPower.Utils:IsBuffOfInterest(spellId)
    local cacheValue = buffOfInterestCache[spellId]
    if cacheValue == false then
        return false
    end

    if cacheValue ~= nil then
        return true, cacheValue
    end

    local buffIndex = self:GetBuffIndexFromSpellId(spellId)
    if buffIndex then
        buffOfInterestCache[spellId] = buffIndex
        return true, buffIndex
    end

    buffOfInterestCache[spellId] = false
    return false
end

function DruidPower.Utils:GetBuffIndexFromSpellId(spellId)
    for buffIndex, allBuffRanks in pairs(DruidPower.Constants.Buffs) do
        for _, buff in pairs(allBuffRanks) do
            if buff == spellId then
                return buffIndex
            end
        end
    end

    return nil
end

function DruidPower.Utils:GetMaxRankSpell(buffIndex)
    local spells = DruidPower.Constants.BuffSpellInfos[buffIndex]
    local spell = nil
    for i = #spells, 1, -1 do
        if IsSpellKnown(spells[i].spellId) then
            return spells[i]
        end
    end

    return nil
end

function DruidPower.Utils:ClearTable(table)
    for k in pairs(table) do
        table[k] = nil
    end
end
