DruidPower.Constants.Options = {
    type = "group",
    childGroups = "tab",
    args = {
        gui = {
            order = 1,
            name = "GUI",
            type = "group",
            args = {
                general = {
                    order = 1,
                    name = "General",
                    type = "group",
                    inline = true,
                    args = {
                        anchor = {
                            order = 1,
                            name = "Show Anchor",
                            type = "toggle",
                            get = function()
                                return DruidPower.optionsDb.profile.showAnchor
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.showAnchor = value
                                DruidPower:UIUpdateAnchor()
                            end
                        },
                        showNumMissing = {
                            order = 2,
                            name = "Show Missing Number",
                            desc = "Show how many people are missing a buff",
                            type = "toggle",
                            get = function()
                                return DruidPower.optionsDb.profile.gui.showNumMissing
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.showNumMissing = value
                                DruidPower:UIUpdateAllGroups()
                            end
                        },
                        showGroupNumber = {
                            order = 3,
                            name = "Show Group Number",
                            desc = "Show the group number on the group buttons",
                            type = "toggle",
                            get = function()
                                return DruidPower.optionsDb.profile.gui.showGroupNumber
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.showGroupNumber = value
                                DruidPower:UIUpdateAllGroups()
                            end
                        },
                    }
                },
                position = {
                    order = 2,
                    name = "Frame Position",
                    type = "group",
                    inline = true,
                    args = {
                        anchor = {
                            order = 1,
                            name = "Anchor",
                            type = "select",
                            values = {
                                BOTTOM      = "BOTTOM",
                                BOTTOMLEFT  = "BOTTOMLEFT",
                                BOTTOMRIGHT = "BOTTOMRIGHT",
                                CENTER      = "CENTER",
                                LEFT        = "LEFT",
                                RIGHT       = "RIGHT",
                                TOP         = "TOP",
                                TOPLEFT     = "TOPLEFT",
                                TOPRIGHT    = "TOPRIGHT"
                            },
                            get = function()
                                return DruidPower.optionsDb.profile.gui.position.point
                            end,
                            set = function(info, value)
                                DruidPower.optionsDb.profile.gui.position.point = value
                                DruidPower:UIUpdateAnchor()
                            end
                        },
                        x = {
                            order = 2,
                            name = "X Position",
                            type = "range",
                            softMin = -1000,
                            softMax = 1000,
                            get = function()
                                return DruidPower.optionsDb.profile.gui.position.x
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.position.x = value
                                DruidPower:UIUpdateAnchor()
                            end
                        },
                        y = {
                            order = 3,
                            name = "Y Position",
                            type = "range",
                            softMin = -1000,
                            softMax = 1000,
                            get = function()
                                return DruidPower.optionsDb.profile.gui.position.y
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.position.y = value
                                DruidPower:UIUpdateAnchor()
                            end
                        },
                        reset = {
                            order = 4,
                            name = "Reset",
                            type = "execute",
                            func = function()
                                DruidPower.optionsDb.profile.gui.position = {
                                    point = "CENTER",
                                    x = 0,
                                    y = 0
                                }
                                DruidPower:UIUpdateAnchor()
                            end
                        }
                    }
                },
                style = {
                    order = 3,
                    name = "Frame Style",
                    type = "group",
                    inline = true,
                    args = {
                        border = {
                            order = 1,
                            name = "Border",
                            type = "select",
                            width = 1.5,
                            dialogControl = "LSM30_Border",
                            values = AceGUIWidgetLSMlists.border,
                            get = function()
                                return DruidPower.optionsDb.profile.gui.style.border.texture
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.style.border.texture = value
                                DruidPower:UIUpdateStyle()
                            end
                        },
                        borderSize = {
                            order = 2,
                            name = "Border Size",
                            type = "range",
                            min = 1,
                            softMax = 20,
                            step = 1,
                            get = function()
                                return DruidPower.optionsDb.profile.gui.style.border.size
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.style.border.size = value
                                DruidPower:UIUpdateStyle()
                            end
                        },
                        borderColor = {
                            order = 3,
                            name = "Border Color",
                            type = "color",
                            get = function()
                                local color = DruidPower.optionsDb.profile.gui.style.border.color
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.gui.style.border.color = { r, g, b, a }
                                DruidPower:UIUpdateStyle()
                            end
                        },
                        background = {
                            order = 4,
                            name = "Background",
                            type = "select",
                            width = 1.5,
                            dialogControl = "LSM30_Statusbar",
                            values = AceGUIWidgetLSMlists.statusbar,
                            get = function()
                                return DruidPower.optionsDb.profile.gui.style.background.texture
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.style.background.texture = value
                                DruidPower:UIUpdateStyle()
                            end
                        },
                        font = {
                            order = 5,
                            name = "Font",
                            type = "select",
                            width = 1.5,
                            dialogControl = "LSM30_Font",
                            values = AceGUIWidgetLSMlists.font,
                            get = function()
                                return DruidPower.optionsDb.profile.gui.style.font
                            end,
                            set = function(_, value)
                                DruidPower.optionsDb.profile.gui.style.font = value
                                DruidPower:UIUpdateStyle()
                            end
                        },
                        reset = {
                            order = 6,
                            name = "Reset",
                            type = "execute",
                            func = function()
                                local copy = DruidPower.Utils:CloneTable(DruidPower.Constants.DefaultDruidPowerDB.profile.gui.style)
                                DruidPower.optionsDb.profile.gui.style = copy
                                DruidPower:UIUpdateStyle()
                            end
                        }
                    }
                }
            }
        },
        colors = {
            order = 2,
            name = "Colors",
            type = "group",
            args = {
                buffState = {
                    order = 1,
                    name = "Buff Button Background",
                    type = "group",
                    inline = true,
                    args = {
                        good = {
                            order = 1,
                            name = "Fully Buffed",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.buffStateGood
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.buffStateGood = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        },
                        some = {
                            order = 2,
                            name = "Partially Buffed",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.buffStateSome
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.buffStateSome = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        },
                        bad = {
                            order = 3,
                            name = "None Buffed",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.buffStateBad
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.buffStateBad = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        }
                    }
                },
                buffDuration = {
                    order = 2,
                    name = "Buff Duration Text",
                    type = "group",
                    inline = true,
                    args = {
                        good = {
                            order = 1,
                            name = "Duration is good",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.buffDurationGood
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.buffDurationGood = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        },
                        bad = {
                            order = 2,
                            name = "Duration is low",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.buffDurationBad
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.buffDurationBad = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        }
                    }
                },
                rangeIndicator = {
                    order = 3,
                    name = "Range Indicator",
                    type = "group",
                    inline = true,
                    args = {
                        inRange = {
                            order = 1,
                            name = "Unit in spell range",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.unitInRange
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.unitInRange = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        },
                        visible = {
                            order = 2,
                            name = "Unit is visible",
                            desc = "Unit is not in spell range but in render range",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.unitVisible
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.unitVisible = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        },
                        outOfRange = {
                            order = 3,
                            name = "Unit is out of range",
                            desc = "Unit is not in spell range and not in render range",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.unitOutOfRange
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.unitOutOfRange = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        }
                    }
                },
                status = {
                    order = 4,
                    name = "Status Text",
                    type = "group",
                    inline = true,
                    args = {
                        textColor = {
                            order = 1,
                            name = "Status Text",
                            desc = "Dead and offline status text color",
                            type = "color",
                            hasAlpha = true,
                            get = function()
                                local color = DruidPower.optionsDb.profile.colors.unitStatus
                                return color[1], color[2], color[3], color[4]
                            end,
                            set = function(_, r, g, b, a)
                                DruidPower.optionsDb.profile.colors.unitStatus = { r, g, b, a }
                                DruidPower:UIUpdateAllGroups()
                            end
                        }
                    }
                },
                reset = {
                    order = 5,
                    name = "Reset",
                    desc = "Reset all colors to default",
                    type = "execute",
                    func = function()
                        local copy = DruidPower.Utils:CloneTable(DruidPower.Constants.DefaultDruidPowerDB.profile.colors)
                        DruidPower.optionsDb.profile.colors = copy
                        DruidPower:UIUpdateAllGroups()
                    end
                },
            }
        }
    },
}
