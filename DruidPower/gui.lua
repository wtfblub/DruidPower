function DruidPower:UICreate()
    local header = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
    header:ClearAllPoints()
    header:SetPoint(
        self.settings.profile.framePos.point,
        self.settings.profile.framePos.x,
        self.settings.profile.framePos.y
    )
    header:SetSize(85, 15)
    header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8" })
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    header:SetBackdropColor(0.09, 0.09, 0.09, 0.90)
    header:SetBackdropBorderColor(0.0, 0.0, 0.0, 1.0)
    header:SetMovable(true)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", header.StartMoving)
    header:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, _, x, y = self:GetPoint()
        DruidPower.settings.profile.framePos = { point = point, x = x, y = y }
    end)

    if not self.settings.profile.showAnchor then
        header:Hide()
    end

    local headerText = header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    headerText:SetPoint("CENTER", header)
    headerText:SetJustifyH("CENTER")
    headerText:SetJustifyV("MIDDLE")
    headerText:SetText("DruidPower")

    local mainFrame = CreateFrame("Frame", "DruidPowerMainFrame", UIParent, "BackdropTemplate")
    mainFrame.header = header
    mainFrame:SetPoint("BOTTOM", header, "TOP", 0, 1)
    mainFrame:SetSize(100, 100)

    self.UIMainFrame = mainFrame

    local numMembersPerParty = MAX_PARTY_MEMBERS + 1
    local numParties = MAX_RAID_MEMBERS / numMembersPerParty
    for i = 1, numParties do
        if i == 1 then
            mainFrame["group" .. i] = self:UICreateGroupButton(i, mainFrame, "BOTTOM", mainFrame, "BOTTOM")
        else
            mainFrame["group" .. i] = self:UICreateGroupButton(
                i, mainFrame, "BOTTOM", mainFrame["group" .. (i - 1)], "TOP"
            )
        end
    end
end

function DruidPower:UICreateGroupButton(group, parent, point, relativeTo, relativePoint)
    local frame = nil

    frame = CreateFrame(
        "Button", nil, parent,
        "BackdropTemplate, SecureHandlerShowHideTemplate, SecureHandlerEnterLeaveTemplate, SecureHandlerStateTemplate, SecureActionButtonTemplate"
    )
    frame.group = group

    frame:SetPoint(point, relativeTo, relativePoint)
    frame:SetSize(115, 34)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.MissingBuff))
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:EnableMouseWheel(true)
    frame:SetAttribute("type", "macro")
    frame:SetScript("PreClick", function(self, button, down)
        DruidPower:UIGroupPreClick(self)
    end)
    frame:SetScript("OnMouseWheel", function(self, delta)
        DruidPower:ToggleThornsAssignmentForUiGroup(self.group)
    end)
    frame:Hide()

    local groupText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.groupText = groupText
    groupText:SetPoint("BOTTOM", frame, "BOTTOM", 0, 0)
    groupText:SetText(group)

    local markIcon = CreateFrame("Frame", nil, frame)
    frame.markIcon = markIcon
    markIcon:SetPoint("TOPLEFT", 4, -4)
    markIcon:SetSize(16, 16)
    markIcon.tex = markIcon:CreateTexture(nil, "OVERLAY")
    markIcon.tex:SetAllPoints()
    markIcon.tex:SetTexture("Interface\\Icons\\Spell_nature_regeneration")

    local markTimer = markIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.markTimer = markTimer
    markTimer:SetPoint("LEFT", markIcon, "RIGHT", 3, 0)
    markTimer:SetJustifyH("RIGHT")
    markTimer:SetText("60:00")

    -- local markTimer2 = markIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    -- frame.markTimer2 = markTimer2
    -- markTimer2:SetPoint("TOP", markTimer, "BOTTOM", 0, -4)
    -- markTimer2:SetJustifyH("RIGHT")
    -- markTimer2:SetText("30:00")

    local markMissing = markIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.markMissing = markMissing
    markMissing:SetPoint("TOP", markIcon, "BOTTOM", 0, -1)
    markMissing:SetText("2")
    markMissing:SetTextColor(1, 0.79, 0.30)

    local thornsIcon = CreateFrame("Frame", nil, frame)
    frame.thornsIcon = thornsIcon
    thornsIcon:SetPoint("TOPRIGHT", -4, -4)
    thornsIcon:SetSize(16, 16)
    thornsIcon.tex = thornsIcon:CreateTexture(nil, "OVERLAY")
    thornsIcon.tex:SetAllPoints()
    thornsIcon.tex:SetTexture("Interface\\Icons\\Spell_nature_thorns")

    local thornsTimer = thornsIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.thornsTimer = thornsTimer
    thornsTimer:SetPoint("RIGHT", thornsIcon, "LEFT", -3, 0)
    thornsTimer:SetJustifyH("LEFT")
    thornsTimer:SetText("10:00")

    local thornsMissing = thornsIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.thornsMissing = thornsMissing
    thornsMissing:SetPoint("TOP", thornsIcon, "BOTTOM", 0, -1)
    thornsMissing:SetText("2")
    thornsMissing:SetTextColor(1, 0.79, 0.30)

    frame.player1 = self:UICreatePlayerButton(group, 1, "player1", frame, "BOTTOMRIGHT", frame, "BOTTOMLEFT")
    frame.player2 = self:UICreatePlayerButton(group, 2, "player2", frame, "BOTTOM", frame.player1, "TOP")
    frame.player3 = self:UICreatePlayerButton(group, 3, "player3", frame, "BOTTOM", frame.player2, "TOP")
    frame.player4 = self:UICreatePlayerButton(group, 4, "player4", frame, "BOTTOM", frame.player3, "TOP")
    frame.player5 = self:UICreatePlayerButton(group, 5, "player5", frame, "BOTTOM", frame.player4, "TOP")
    frame.players = { frame.player1, frame.player2, frame.player3, frame.player4, frame.player5 }

    frame:Execute("players = table.new()")
    for _, player in pairs(frame.players) do
        frame:SetFrameRef("player", player)
        frame:Execute([[
            table.insert(players, self:GetFrameRef("player"))
        ]])
    end

    frame:SetAttribute("_onenter", [[
        for _, player in pairs(players) do
            if player:GetAttribute("Active") then
                player:Show()
                player:RegisterAutoHide(0.05)
                player:AddToAutoHide(self)
                for _, player2 in pairs(players) do
                    if player ~= player2 then
                        player:AddToAutoHide(player2)
                    end
                end
            end
        end
    ]])

    return frame
end

function DruidPower:UICreatePlayerButton(group, memberIndex, name, parent, point, relativeTo, relativePoint)
    local frame = CreateFrame(
        "Button", nil, parent,
        "BackdropTemplate, SecureActionButtonTemplate"
    )
    frame.group = group
    frame.memberIndex = memberIndex
    frame:SetPoint(point, relativeTo, relativePoint)
    frame:SetSize(115, 34)
    frame:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })
    frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.MissingBuff))
    frame:SetFrameStrata("TOOLTIP")
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    frame:EnableMouseWheel(true)
    frame:SetAttribute("type", "macro")
    frame:SetScript("PreClick", function(self, button, down)
        DruidPower:UIPlayerPreClick(self)
    end)
    frame:SetScript("OnMouseWheel", function(self, delta)
        DruidPower:ToggleThornsAssignmentForUiPlayer(self.group, self.memberIndex)
    end)
    frame:Hide()

    local markIcon = CreateFrame("Frame", nil, frame)
    frame.markIcon = markIcon
    markIcon:SetPoint("TOPLEFT", 4, -4)
    markIcon:SetSize(12, 12)
    markIcon.tex = markIcon:CreateTexture(nil, "OVERLAY")
    markIcon.tex:SetAllPoints()
    markIcon.tex:SetTexture("Interface\\Icons\\Spell_nature_regeneration")

    local markTimer = markIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.markTimer = markTimer
    markTimer:SetPoint("LEFT", markIcon, "RIGHT", 3, 0)
    markTimer:SetJustifyH("LEFT")
    markTimer:SetText("60:00")

    local thornsIcon = CreateFrame("Frame", nil, frame)
    frame.thornsIcon = thornsIcon
    thornsIcon:SetPoint("TOP", markIcon, "BOTTOM", 0, -2)
    thornsIcon:SetSize(12, 12)
    thornsIcon.tex = thornsIcon:CreateTexture(nil, "OVERLAY")
    thornsIcon.tex:SetAllPoints()
    thornsIcon.tex:SetTexture("Interface\\Icons\\Spell_nature_thorns")

    local thornsTimer = thornsIcon:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.thornsTimer = thornsTimer
    thornsTimer:SetPoint("LEFT", thornsIcon, "RIGHT", 3, 0)
    thornsTimer:SetJustifyH("LEFT")
    thornsTimer:SetText("10:00")

    local nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.nameText = nameText
    nameText:SetPoint("BOTTOMRIGHT", -5, 5)
    nameText:SetJustifyH("RIGHT")
    nameText:SetText(name)

    local rangeText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.rangeText = rangeText
    rangeText:SetPoint("TOPRIGHT", -5, -5)
    rangeText:SetJustifyH("RIGHT")
    rangeText:SetText("R")

    local statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.statusText = statusText
    statusText:SetPoint("RIGHT", rangeText, "LEFT", -2, 0)
    statusText:SetJustifyH("RIGHT")
    statusText:SetText("D")
    statusText:SetTextColor(unpack(DruidPower.Constants.UI.Colors.Status))

    local roleIcon = CreateFrame("Frame", nil, frame)
    frame.roleIcon = roleIcon
    roleIcon:SetPoint("RIGHT", statusText, "LEFT", 0, 1)
    roleIcon:SetSize(11, 11)
    roleIcon.tex = roleIcon:CreateTexture(nil, "OVERLAY")
    roleIcon.tex:SetAllPoints()
    roleIcon.tex:SetTexture("Interface\\Groupframe\\UI-Group-MainTankIcon")

    return frame
end

function DruidPower:UIRosterUpdate()
    if InCombatLockdown() then return end

    self:UILayoutReset()
    self:UIUpdateAllGroups(true)
end

function DruidPower:UIGetGroupFrame(group)
    return self.UIMainFrame["group" .. group]
end

function DruidPower:UIGetPlayerFrame(group, memberIndex)
    if type(group) == "number" then
        local frame = self.UIMainFrame["group" .. group]
        if frame then
            return frame["player" .. memberIndex]
        end

        return nil
    end

    return group["player" .. memberIndex]
end

function DruidPower:UILayoutReset()
    if InCombatLockdown() then return end

    local numMembersPerParty = MAX_PARTY_MEMBERS + 1
    local numParties = MAX_RAID_MEMBERS / numMembersPerParty

    for group = 1, numParties do
        local frame = self:UIGetGroupFrame(group)
        if frame then
            frame:Hide()
            for i = 1, numMembersPerParty do
                local playerFrame = self:UIGetPlayerFrame(frame, i)
                if playerFrame then
                    playerFrame:SetAttribute("Active", false)
                end
            end
        end
    end
end

function DruidPower:UIUpdateAllGroups(isRosterUpdate)
    if #self.roster == 0 then return end

    local numMembersPerParty = MAX_PARTY_MEMBERS + 1
    local numParties = MAX_RAID_MEMBERS / numMembersPerParty

    for group = 1, numParties do
        self:UIUpdateGroup(group, isRosterUpdate)
    end
end

function DruidPower:UIUpdateGroup(group, isRosterUpdate)
    local numMembersPerParty = MAX_PARTY_MEMBERS + 1

    local frame = self.UIMainFrame["group" .. group]
    if not frame then
        return
    end

    if #self.roster == 0 then
        return
    end

    local buffInfo = {}
    for i, v in pairs(DruidPower.Constants.Buffs) do
        buffInfo[i] = {
            numShouldHaveBuff = 0,
            numHasBuff = 0,
            minDuration = 0,
        }
    end

    local hasAnyGroupMembers = false
    local actualGroup = group
    for rosterIndex, player in pairs(self.roster) do
        if player and player.uiGroupIndex == group then
            hasAnyGroupMembers = true
            actualGroup = player.group
            self:UIUpdatePlayer(player, isRosterUpdate)
            for buffIndex, _ in pairs(DruidPower.Constants.Buffs) do
                local buff = player.buffs[buffIndex]

                -- Do not track thorns when their assignment is turned off
                local shouldTrackBuff = buffIndex ~= DRUIDPOWER_BUFFINDEX_THORNS or player.thornsAssignment
                if shouldTrackBuff and buffIndex ~= DRUIDPOWER_BUFFINDEX_GIFT then
                    buffInfo[buffIndex].numShouldHaveBuff = buffInfo[buffIndex].numShouldHaveBuff + 1
                end

                if buffIndex == DRUIDPOWER_BUFFINDEX_GIFT then
                    buffIndex = DRUIDPOWER_BUFFINDEX_MARK
                end

                if shouldTrackBuff and buff then
                    buffInfo[buffIndex].numHasBuff = buffInfo[buffIndex].numHasBuff + 1

                    local duration = self.Utils:GetBuffDurationLeft(buff)
                    if buffInfo[buffIndex].minDuration == 0 or (duration > 0 and duration < buffInfo[buffIndex].minDuration) then
                        buffInfo[buffIndex].minDuration = duration
                    end
                end
            end
        end
    end

    if not hasAnyGroupMembers and not InCombatLockdown() then
        frame:Hide()
        for _, playerFrame in pairs(frame.players) do
            playerFrame:SetAttribute("Active", false)
            playerFrame:Hide()
        end
        return
    end

    if isRosterUpdate and not InCombatLockdown() then
        frame:Show()
        frame.groupText:SetText(actualGroup)
        self:UIGroupPreClick(frame)
    end

    local numTotalHasBuff = 0
    local numTotalNeedBuff = 0
    for _, info in pairs(buffInfo) do
        numTotalHasBuff = numTotalHasBuff + info.numHasBuff
        numTotalNeedBuff = numTotalNeedBuff + info.numShouldHaveBuff
    end

    if numTotalHasBuff == numTotalNeedBuff then
        frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.HasBuff))
    elseif numTotalHasBuff == 0 then
        frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.MissingBuff))
    else
        frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.SomeHasBuff))
    end

    for buffIndex, _ in pairs(DruidPower.Constants.Buffs) do
        local numShouldHaveBuff = buffInfo[buffIndex].numShouldHaveBuff
        local numHasBuff = buffInfo[buffIndex].numHasBuff
        local minDuration = buffInfo[buffIndex].minDuration

        if numHasBuff < numShouldHaveBuff then
            if buffIndex == DRUIDPOWER_BUFFINDEX_THORNS then
                frame.thornsMissing:SetText(numShouldHaveBuff - numHasBuff)
                frame.thornsMissing:Show()
                frame.thornsIcon:Show()
            elseif buffIndex == DRUIDPOWER_BUFFINDEX_MARK then
                frame.markMissing:SetText(numShouldHaveBuff - numHasBuff)
                frame.markMissing:Show()
            end
        else
            if buffIndex == DRUIDPOWER_BUFFINDEX_THORNS then
                frame.thornsMissing:Hide()
                if numShouldHaveBuff == 0 then
                    frame.thornsIcon:Hide()
                else
                    frame.thornsIcon:Show()
                end
            elseif buffIndex == DRUIDPOWER_BUFFINDEX_MARK then
                frame.markMissing:Hide()
            end
        end

        if numHasBuff > 0 then
            if buffIndex == DRUIDPOWER_BUFFINDEX_THORNS then
                if minDuration > 0 then
                    frame.thornsTimer:SetText(DruidPower.Utils:FormatDuration(minDuration))
                    frame.thornsTimer:SetTextColor(
                        unpack(DruidPower.Utils:DurationColor(
                            minDuration,
                            DruidPower.Constants.BuffDurationThreshold[buffIndex]
                        ))
                    )
                    frame.thornsTimer:Show()
                else
                    frame.thornsTimer:Hide()
                end
            elseif buffIndex == DRUIDPOWER_BUFFINDEX_MARK then
                if minDuration > 0 then
                    frame.markTimer:SetText(DruidPower.Utils:FormatDuration(minDuration))
                    frame.markTimer:SetTextColor(
                        unpack(DruidPower.Utils:DurationColor(
                            minDuration,
                            DruidPower.Constants.BuffDurationThreshold[buffIndex]
                        ))
                    )
                    frame.markTimer:Show()
                else
                    frame.markTimer:Hide()
                end
            end
        else
            if buffIndex == DRUIDPOWER_BUFFINDEX_THORNS then
                frame.thornsTimer:Hide()
            elseif buffIndex == DRUIDPOWER_BUFFINDEX_MARK then
                frame.markTimer:Hide()
            end
        end
    end
end

function DruidPower:UIUpdatePlayer(player, isRosterUpdate)
    local frame = self:UIGetPlayerFrame(player.uiGroupIndex, player.uiMemberIndex)
    if not frame then
        return
    end

    if isRosterUpdate and not InCombatLockdown() then
        frame:SetAttribute("Active", true)
        -- If the member menu is open then show the new member immediately
        local players = frame:GetParent()["players"]
        if players then
            for _, v in pairs(players) do
                if v:IsShown() then
                    frame:Show()
                    break
                end
            end
        end
        DruidPower:UIPlayerPreClick(frame)
    end

    local name = DruidPower.Utils:ShortenPlayerName(player.name)
    local colorHex = select(4, GetClassColor(string.upper(player.class)))
    frame.nameText:SetText("|c" .. colorHex .. name .. "|r")

    if player.isInRange then
        frame.rangeText:SetTextColor(unpack(DruidPower.Constants.UI.Colors.InRange))
    else
        if player.isVisible then
            frame.rangeText:SetTextColor(unpack(DruidPower.Constants.UI.Colors.Visible))
        else
            frame.rangeText:SetTextColor(unpack(DruidPower.Constants.UI.Colors.OutOfRange))
        end
    end

    if player.isDead then
        frame.statusText:SetText("D")
        frame.statusText:Show()
    elseif not player.online then
        frame.statusText:SetText("OFF")
        frame.statusText:Show()
    else
        frame.statusText:Hide()
    end

    if player.role == "maintank" or player.role == "TANK" then
        frame.roleIcon:Show()
    else
        frame.roleIcon:Hide()
    end

    local markBuff = player.buffs[DRUIDPOWER_BUFFINDEX_MARK]
    local giftBuff = player.buffs[DRUIDPOWER_BUFFINDEX_GIFT]
    local thornsBuff = player.buffs[DRUIDPOWER_BUFFINDEX_THORNS]

    if (markBuff or giftBuff) and (thornsBuff or not player.thornsAssignment) then
        frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.HasBuff))
    elseif (markBuff or giftBuff) or (thornsBuff and player.thornsAssignment) then
        frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.SomeHasBuff))
    else
        frame:SetBackdropColor(unpack(DruidPower.Constants.UI.Colors.MissingBuff))
    end

    if markBuff or giftBuff then
        local buff
        local buffIndex
        if markBuff then
            buff = markBuff
            buffIndex = DRUIDPOWER_BUFFINDEX_MARK
        else
            buff = giftBuff
            buffIndex = DRUIDPOWER_BUFFINDEX_GIFT
        end

        local duration = self.Utils:GetBuffDurationLeft(buff)
        frame.markIcon:SetAlpha(1.0)
        frame.markTimer:SetText(DruidPower.Utils:FormatDuration(duration))
        frame.markTimer:SetTextColor(
            unpack(DruidPower.Utils:DurationColor(
                duration,
                DruidPower.Constants.BuffDurationThreshold[buffIndex]
            ))
        )
        frame.markTimer:Show()
    else
        frame.markIcon:SetAlpha(0.5)
        frame.markTimer:Hide()
    end

    if player.thornsAssignment then
        frame.thornsIcon:Show()
        local thornsBuff = player.buffs[DRUIDPOWER_BUFFINDEX_THORNS]
        if thornsBuff then
            local duration = self.Utils:GetBuffDurationLeft(thornsBuff)
            frame.thornsIcon:SetAlpha(1.0)
            frame.thornsTimer:SetText(DruidPower.Utils:FormatDuration(duration))
            frame.thornsTimer:SetTextColor(
                unpack(DruidPower.Utils:DurationColor(
                    duration,
                    DruidPower.Constants.BuffDurationThreshold[DRUIDPOWER_BUFFINDEX_THORNS]
                ))
            )
            frame.thornsTimer:Show()
        else
            frame.thornsIcon:SetAlpha(0.5)
            frame.thornsTimer:Hide()
        end
    else
        frame.thornsIcon:Hide()
        frame.thornsTimer:Hide()
    end
end

function DruidPower:UIGroupPreClick(frame)
    if InCombatLockdown() then return end

    frame:UnwrapScript(frame, "OnClick")
    frame:SetAttribute("spellName1", nil)
    frame:SetAttribute("spellName2", nil)
    frame:SetAttribute("shift-spellName1", nil)

    frame:SetAttribute("macrotext1", nil)
    frame:SetAttribute("macrotext2", nil)
    frame:SetAttribute("shift-macrotext1", nil)

    local players = self:FindPlayersInRosterByUiIndex(frame.group)
    if #players == 0 then
        return
    end

    local names = {}
    for _, player in pairs(players) do
        if player.isInRange and player.online and not player.isDead and not player.isAFK then
            table.insert(names, player.name)
        end
    end

    local markSpell = self.Utils:GetMaxRankSpell(DRUIDPOWER_BUFFINDEX_MARK)
    local giftSpell = self.Utils:GetMaxRankSpell(DRUIDPOWER_BUFFINDEX_GIFT)
    local thornsSpell = self.Utils:GetMaxRankSpell(DRUIDPOWER_BUFFINDEX_THORNS)

    if markSpell then
        local name
        if markSpell.rank then
            name = markSpell.name .. "(" .. markSpell.rank .. ")"
        else
            name = markSpell.name
        end
        frame:SetAttribute("spellName1", name)
    end

    if giftSpell then
        local name
        if giftSpell.rank then
            name = giftSpell.name .. "(" .. giftSpell.rank .. ")"
        else
            name = giftSpell.name
        end
        frame:SetAttribute("shift-spellName1", name)
    end

    if thornsSpell then
        local name
        if thornsSpell.rank then
            name = thornsSpell.name .. "(" .. thornsSpell.rank .. ")"
        else
            name = thornsSpell.name
        end
        frame:SetAttribute("spellName2", name)
    end

    frame:Execute("names = newtable([=[" .. strjoin("]=],[=[", unpack(names)) .. "]=])\n")
    frame:WrapScript(frame, "OnClick", [=[
        local spellName = nil
        local name = nil
        local macroName = nil

        if not names or #names == 0 then
            return
        end

        if SecureCmdOptionParse("[btn:1]") then
            spellName = self:GetAttribute("spellName1")
            local index = self:GetAttribute("index1")
            if not index or index > #names then
                index = 1
            end

            name = names[index]
            self:SetAttribute("index1", index + 1)
            macroName = "macrotext1"
        end

        if SecureCmdOptionParse("[btn:2]") then
            spellName = self:GetAttribute("spellName2")
            local index = self:GetAttribute("index2")
            if not index or index > #names then
                index = 1
            end

            name = names[index]
            self:SetAttribute("index2", index + 1)
            macroName = "macrotext2"
        end

        if SecureCmdOptionParse("[mod:shift,btn:1]") then
            spellName = self:GetAttribute("shift-spellName1")
            local index = self:GetAttribute("shift-index1")
            if not index or index > #names then
                index = 1
            end

            name = names[index]
            self:SetAttribute("shift-index1", index + 1)
            macroName = "shift-macrotext1"
        end

        if name and SecureCmdOptionParse("[@" .. name .. ",help,nodead]") then
            local macro = string.format("/cast [@%s,help,nodead] %s", name, spellName)
            self:SetAttribute(macroName, macro)
        end
    ]=])
end

function DruidPower:UIPlayerPreClick(frame)
    if InCombatLockdown() then return end

    frame:SetAttribute("macrotext1", nil)
    frame:SetAttribute("macrotext2", nil)
    frame:SetAttribute("shift-macrotext1", nil)

    local player = self:FindPlayerInRosterByUiIndex(frame.group, frame.memberIndex)
    if not player then
        return
    end

    local markSpell = self.Utils:GetMaxRankSpell(DRUIDPOWER_BUFFINDEX_MARK)
    local giftSpell = self.Utils:GetMaxRankSpell(DRUIDPOWER_BUFFINDEX_GIFT)
    local thornsSpell = self.Utils:GetMaxRankSpell(DRUIDPOWER_BUFFINDEX_THORNS)

    if markSpell then
        local macro
        if markSpell.rank then
            macro = string.format("/cast [@%s,help,nodead] %s(%s)", player.name, markSpell.name, markSpell.rank)
        else
            macro = string.format("/cast [@%s,help,nodead] %s", player.name, markSpell.name)
        end
        frame:SetAttribute("macrotext1", macro)
    end

    if giftSpell then
        local macro
        if giftSpell.rank then
            macro = string.format("/cast [@%s,help,nodead] %s(%s)", player.name, giftSpell.name, giftSpell.rank)
        else
            macro = string.format("/cast [@%s,help,nodead] %s", player.name, giftSpell.name)
        end
        frame:SetAttribute("shift-macrotext1", macro)
    end

    if thornsSpell then
        local macro
        if thornsSpell.rank then
            macro = string.format("/cast [@%s,help,nodead] %s(%s)", player.name, thornsSpell.name, thornsSpell.rank)
        else
            macro = string.format("/cast [@%s,help,nodead] %s", player.name, thornsSpell.name)
        end
        frame:SetAttribute("macrotext2", macro)
    end
end
