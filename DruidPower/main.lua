---@class DruidPower
DruidPower = LibStub("AceAddon-3.0"):NewAddon(
    "DruidPower",
    "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0"
)

local AceGUI = LibStub("AceGUI-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

function DruidPower:OnInitialize()
    self.debug = false
    self.debugPerf = false
    self.optionsDb = AceDB:New("DruidPowerDB", DruidPower.Constants.DefaultDruidPowerDB, true)
    self.assignmentsDb = AceDB:New("DruidPowerAssignments", DruidPower.Constants.DefaultDruidPowerAssignments, true)
    AceConfig:RegisterOptionsTable(DruidPower.name, DruidPower.Constants.Options)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(DruidPower.name)
    self.roster = {}
    self.isDruid = select(2, UnitClass("player")) == "DRUID"
    self:RegisterChatCommand(string.lower(DruidPower.name), "OnCommand")
    LibStub("LibClassicDurations"):Register(DruidPower.name)

    -- Cleanup old assignments
    if self.assignmentsDb.profile.thorns then
        for guid, _ in pairs(self.assignmentsDb.profile.thorns) do
            local v = self.assignmentsDb.profile.thorns[guid]
            if not v or type(v) ~= "number" or (time() - v >= DruidPower.Constants.ThornsAssignmentTimeout) then
                self.assignmentsDb.profile.thorns[guid] = nil
            end
        end
    end
end

function DruidPower:OnEnable()
    if not self.isDruid then
        self:Print("You are not a druid. Addon disabled.")
        return
    end

    self:RegisterBucketEvent(
        {
            "PLAYER_ENTERING_WORLD",
            "GROUP_ROSTER_UPDATE",
            "GROUP_JOINED",
            "GROUP_LEFT",
            "PLAYER_REGEN_ENABLED", -- Update roster when leaving combat
            "ZONE_CHANGED_NEW_AREA",
            "SPELLS_CHANGED"
        },
        1,
        "RosterUpdate"
    )

    self:UICreate()
    self:ScanTimer()
end

function DruidPower:OnDisable()
    if self.scanTimer then
        self.scanTimer:Cancel()
    end
end

function DruidPower:OnCommand(input)
    if InCombatLockdown() then
        self:Print("You are currently in combat.")
        return
    end

    local subcmd, args = self:GetArgs(input, 1)
    if subcmd then
        subcmd = string.lower(subcmd)
    end

    if not subcmd then
        AceConfigDialog:Open(DruidPower.name)
    elseif subcmd == "anchor" then
        self.optionsDb.profile.showAnchor = not self.optionsDb.profile.showAnchor
        self:NotifyOptionChanged()
        self:UIUpdateAnchor()
    elseif subcmd == "reset" then
        self.optionsDb.profile = DruidPower.Utils:CloneTable(DruidPower.Constants.DefaultDruidPowerDB.profile)
        self.UIMainFrame.header:ClearAllPoints()
        self.UIMainFrame.header:SetPoint("CENTER", 0, 0)
        ReloadUI()
    else
        self:Print("Available commands:")
        self:Print("/druidpower anchor > Toggles the anchor")
        self:Print("/druidpower reset > Resets the frame position")
    end
end

function DruidPower:ScanTimer()
    local now = time()
    for key, value in pairs(self.roster) do
        if value then
            self:ScanUnit(value, now)
            self:ScanUnitBuffs(value)
        end
    end

    self:UIUpdateAllGroups()

    if not self.scanTimer then
        self.scanTimer = self:ScheduleRepeatingTimer("ScanTimer", 1, self)
    end
end

function DruidPower:RosterUpdate()
    if InCombatLockdown() then return end

    local rosterUpdatePerf = DruidPower.Utils:PerformanceProfile("RosterUpdate")
    local scanUnitBuffsPerf = DruidPower.Utils:PerformanceProfile("ScanUnitBuffs_Total")
    local scanUnitPerf = DruidPower.Utils:PerformanceProfile("ScanUnit_Total")
    local now = time()

    table.wipe(self.roster)

    if IsInRaid() then
        local groupPositionCounter = {}
        for i = 1, MAX_RAID_MEMBERS do
            local name, _, group, _, class, _, _, online, isDead, role = GetRaidRosterInfo(i)
            if name and class then
                -- the api does not provide a way to get a members position in a group
                -- so we use a counter to assign the position based on the order of their raid id
                if groupPositionCounter[group] == nil then
                    groupPositionCounter[group] = 0
                end
                groupPositionCounter[group] = groupPositionCounter[group] + 1

                self.roster[i] = {
                    guid = UnitGUID("raid" .. i),
                    id = "raid" .. i,
                    name = name,
                    group = group,
                    memberIndex = 6 - groupPositionCounter[group], -- substract from 6 to reverse order
                    class = class,
                    online = online,
                    isDead = isDead,
                    role = role,
                }

                scanUnitBuffsPerf:Restart()
                self:ScanUnitBuffs(self.roster[i])
                scanUnitBuffsPerf:Add()

                scanUnitPerf:Restart()
                self:ScanUnit(self.roster[i], now)
                scanUnitPerf:Add()
            end
        end
    else
        if IsInGroup() then
            for i = 1, MAX_PARTY_MEMBERS do
                local name = UnitName("party" .. i)
                local class = UnitClass("party" .. i)
                if name and class then
                    self.roster[i + 1] = {
                        guid = UnitGUID("party" .. i),
                        id = "party" .. i,
                        name = name,
                        group = 1,
                        memberIndex = i + 1,
                        class = class,
                    }
                    scanUnitBuffsPerf:Restart()
                    self:ScanUnitBuffs(self.roster[i + 1])
                    scanUnitBuffsPerf:Add()

                    scanUnitPerf:Restart()
                    self:ScanUnit(self.roster[i + 1], now)
                    scanUnitPerf:Add()
                end
            end
        end

        self.roster[1] = {
            guid = UnitGUID("player"),
            id = "player",
            name = UnitName("player"),
            group = 1,
            memberIndex = 1,
            class = UnitClass("player"),
        }
        scanUnitBuffsPerf:Restart()
        self:ScanUnitBuffs(self.roster[1])
        scanUnitBuffsPerf:Add()

        scanUnitPerf:Restart()
        self:ScanUnit(self.roster[1], now)
        scanUnitPerf:Add()
    end

    -- assign each member an index for the ui so the ui wont show holes when a group isnt full
    -- sorted by their actual group position
    -- do the same for groups so the ui doesnt show holes when groups inbetween are empty

    local groups = {}
    local groupMembers = {}
    for _, player in pairs(self.roster) do
        if not groupMembers[player.group] then
            groupMembers[player.group] = {}
        end


        local shouldAddGroup = true
        for _, v in pairs(groups) do
            if v == player.group then
                shouldAddGroup = false
                break
            end
        end

        if shouldAddGroup then
            table.insert(groups, player.group)
        end
        table.insert(groupMembers[player.group], player.memberIndex)
    end

    -- assign ui group index
    table.sort(groups)
    for uiGroupIndex, groupIndex in ipairs(groups) do
        for _, player in pairs(self.roster) do
            if player.group == groupIndex then
                player.uiGroupIndex = uiGroupIndex
            end
        end
    end

    -- assign ui member index
    for group, members in pairs(groupMembers) do
        table.sort(members)
        for uiMemberIndex, memberIndex in ipairs(members) do
            for _, player in pairs(self.roster) do
                if player.group == group and player.memberIndex == memberIndex then
                    player.uiMemberIndex = uiMemberIndex
                    break
                end
            end
        end
    end

    rosterUpdatePerf:Report()
    scanUnitBuffsPerf:ReportTotal()
    scanUnitPerf:ReportTotal()

    local uiRosterUpdatePerf = DruidPower.Utils:PerformanceProfile("UIRosterUpdate")
    self:UIRosterUpdate()
    uiRosterUpdatePerf:Report()
end

function DruidPower:ScanUnitBuffs(player)
    player.buffs = player.buffs or {}
    table.wipe(player.buffs)

    local auras = DruidPower.Utils:GetUnitBuffs(player.id)
    for buffIndex, allBuffRanks in pairs(DruidPower.Constants.Buffs) do
        local aura
        for _, buffId in pairs(allBuffRanks) do
            aura = auras[buffId]
            if aura then
                break
            end
        end

        if aura then
            player.buffs[buffIndex] = aura
        end
    end
end

function DruidPower:ScanUnit(player, now)
    player.buffs = player.buffs or {}
    player.online = UnitIsConnected(player.id)
    player.isDead = UnitIsDeadOrGhost(player.id)
    if not IsInRaid() then
        player.role = UnitGroupRolesAssigned(player.id)
    end
    player.isInRange = IsSpellInRange(DruidPower.Constants.BuffSpellInfos[DRUIDPOWER_BUFFINDEX_MARK][1].name, player.id) == 1
    player.isVisible = UnitIsVisible(player.id)
    player.isAFK = UnitIsAFK(player.id)

    local thornsAssignment = self.assignmentsDb.profile.thorns[player.guid]
    if thornsAssignment == nil then
        player.thornsAssignment = false
    else
        player.thornsAssignment = true
        self.assignmentsDb.profile.thorns[player.guid] = now or time()
    end
end

function DruidPower:FindPlayerInRosterByUnitId(unitId)
    for _, player in pairs(self.roster) do
        if player.id == unitId then
            return player
        end
    end

    return nil
end

function DruidPower:FindPlayerInRosterByUiIndex(group, memberIndex)
    for _, player in pairs(self.roster) do
        if player.uiGroupIndex == group and player.uiMemberIndex == memberIndex then
            return player
        end
    end

    return nil
end

function DruidPower:FindPlayersInRosterByUiIndex(group)
    local players = {}
    for _, player in pairs(self.roster) do
        if player.uiGroupIndex == group then
            table.insert(players, player)
        end
    end

    return players
end

function DruidPower:ToggleThornsAssignmentForUiGroup(uiGroupIndex)
    self:ToggleThornsAssignment(function(player)
        return player.uiGroupIndex == uiGroupIndex
    end)
end

function DruidPower:ToggleThornsAssignmentForUiPlayer(uiGroupIndex, uiMemberIndex)
    self:ToggleThornsAssignment(function(player)
        return player.uiGroupIndex == uiGroupIndex and player.uiMemberIndex == uiMemberIndex
    end)
end

function DruidPower:ToggleThornsAssignment(filter)
    for _, player in pairs(self.roster) do
        if filter(player) then
            player.thornsAssignment = not player.thornsAssignment
            local now = time() or 0
            if player.thornsAssignment and now > 0 then
                self.assignmentsDb.profile.thorns[player.guid] = now
            else
                self.assignmentsDb.profile.thorns[player.guid] = nil
            end
        end
    end

    self:UIUpdateAllGroups(false)
end

function DruidPower:NotifyOptionChanged()
    AceConfigRegistry:NotifyChange(DruidPower.name)
end
