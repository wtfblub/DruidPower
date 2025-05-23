DruidPower.Constants = {}


DruidPower.Constants.DefaultOptions = {
    profile = {
        showAnchor = true,
        framePos = {
            point = "CENTER",
            x = 0,
            y = 0,
        },
    }
}
DruidPower.Constants.DefaultAssignmentOptions = {
    profile = {
        thorns = {}
    }
}

DruidPower.Constants.UI = {
    Colors = {
        MissingBuff = { 1.0, 0.0, 0.0, 0.95 },
        HasBuff = { 0.0, 1.0, 0.0, 0.95 },
        SomeHasBuff = { 1.0, 0.55, 0.19, 0.95 },
        DurationGood = { 0.0, 1.0, 0.0, 1.0 },
        DurationBad = { 1.0, 0.81, 0.29, 1.0 },
        InRange = { 0.0, 1.0, 0.0, 1.0 },
        Visible = { 1.0, 0.81, 0.29, 1.0 },
        OutOfRange = { 1.0, 0.0, 0.0, 1.0 },
        Status = { 1.0, 0.0, 0.0, 1.0 },
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
