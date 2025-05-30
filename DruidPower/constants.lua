DruidPower.Constants = {}

DruidPower.Constants.DefaultDruidPowerDB = {
    profile = {
        showAnchor = true,
        colors = {
            buffStateGood = { 0.0, 0.7, 0.0, 0.7 },
            buffStateSome = { 1.0, 1.0, 0.5, 0.7 },
            buffStateBad = { 1.0, 0.0, 0.0, 0.7 },
            buffDurationGood = { 0.0, 1.0, 0.0, 1.0 },
            buffDurationBad = { 1.0, 0.81, 0.29, 1.0 },
            unitInRange = { 0.0, 1.0, 0.0, 1.0 },
            unitVisible = { 1.0, 0.81, 0.29, 1.0 },
            unitOutOfRange = { 1.0, 0.0, 0.0, 1.0 },
            unitStatus = { 1.0, 0.0, 0.0, 1.0 },
        },
        gui = {
            showNumMissing = true,
            showGroupNumber = true,
            position = {
                point = "CENTER",
                x = 0,
                y = 0
            },
            style = {
                font = "Friz Quadrata TT",
                border = {
                    texture = "Blizzard Dialog",
                    size = 3,
                    color = { 1.0, 1.0, 1.0, 1.0 },
                },
                background = {
                    texture = "Blizzard Raid Bar",
                }
            },
        },
    }
}

DruidPower.Constants.DefaultDruidPowerAssignments = {
    profile = {
        thorns = {}
    }
}

DRUIDPOWER_BUFFINDEX_MARK = 1
DRUIDPOWER_BUFFINDEX_GIFT = 2
DRUIDPOWER_BUFFINDEX_THORNS = 3

DruidPower.Constants.Buffs = {
    [DRUIDPOWER_BUFFINDEX_MARK] = {
        1126, -- Mark of the Wild Rank 1
        5232, -- Mark of the Wild Rank 2
        6756, -- Mark of the Wild Rank 3
        5234, -- Mark of the Wild Rank 4
        8907, -- Mark of the Wild Rank 5
        9884, -- Mark of the Wild Rank 6
        9885, -- Mark of the Wild Rank 7
    },
    [DRUIDPOWER_BUFFINDEX_GIFT] = {
        21849, -- Gift of the Wild Rank 1
        21850, -- Gift of the Wild Rank 2
    },
    [DRUIDPOWER_BUFFINDEX_THORNS] = {
        467,  -- Thorns Rank 1
        782,  -- Thorns Rank 2
        1075, -- Thorns Rank 3
        8914, -- Thorns Rank 4
        9756, -- Thorns Rank 5
        9910, -- Thorns Rank 6
    },
}

DruidPower.Constants.BuffSpellInfos = {}

for buffIndex, buffs in ipairs(DruidPower.Constants.Buffs) do
    for i, spellId in ipairs(buffs) do
        if not DruidPower.Constants.BuffSpellInfos[buffIndex] then
            DruidPower.Constants.BuffSpellInfos[buffIndex] = {}
        end
        local name = GetSpellInfo(spellId)
        local rank = C_Spell.GetSpellSubtext(spellId)
        DruidPower.Constants.BuffSpellInfos[buffIndex][i] = {
            spellId = spellId,
            name = name,
            rank = rank,
        }
    end
end

DruidPower.Constants.BuffDurationThreshold = {
    [DRUIDPOWER_BUFFINDEX_MARK] = 20 * 60,   -- 20 minutes
    [DRUIDPOWER_BUFFINDEX_GIFT] = 20 * 60,   -- 20 minutes
    [DRUIDPOWER_BUFFINDEX_THORNS] = 10 * 60, -- 10 minutes
}
