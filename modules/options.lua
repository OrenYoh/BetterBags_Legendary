local addonName, root = ...;
local L = root.L;

---@class BetterBags_Legendary: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

--- BetterBags dependencies
-----------------------------
---@class BetterBags: AceAddon
local BetterBags = LibStub('AceAddon-3.0'):GetAddon("BetterBags")
---@class Categories: AceModule
local categories = BetterBags:GetModule('Categories')
---@class Config: AceModule
local config = BetterBags:GetModule('Config')
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
-----------------------------

local debounceTimer
local refreshButton

local updateSavedVariables = function()
    BetterBags_LegendaryDB = addon.db
end

local updateCategory = function(categoryEnabled, categoryName)
    if debounceTimer then
        debounceTimer:Cancel()
    end

    -- We wait for the value not to be changed for 1 second before refreshing the categories
    debounceTimer = C_Timer.NewTimer(1, function()
        updateSavedVariables()

        if (categoryEnabled) then
            addon:GetOrCreateBetterBagsCategory(categoryName)
            categories:WipeCategory(L["CATEGORY_NAME"])
            categories:WipeCategory(categoryName)
        else
            categories:WipeCategory(L["CATEGORY_NAME"])
            categories:WipeCategory(categoryName)
            categories:DeleteCategory(categoryName)
        end

        events:SendMessage('bags/FullRefreshAll')
        refreshButton:Enable()
    end)
end

--- Options panel
-----------------------------
addon.options = function()
    return {
        legendaryOptions = {
            name = function()
                addon.frame:CreateDescription(L["OPTIONS_DESC"], { top = 20 })
                addon.frame:CreateTitle(L["OPTIONS_INDE_CAT"])

                addon.frame:CreateCheckbox({
                    title = L["OPTIONS_CAT_LEGENDARY"],
                    getValue = function(_)
                        return addon.db.independentLegendary
                    end,
                    setValue = function(_, value)
                        addon.db.independentLegendary = value
                        updateCategory(value, L["OPTIONS_CAT_LEGENDARY"])
                    end
                })

                addon.frame:CreateCheckbox({
                    title = L["OPTIONS_CAT_ARTIFACT"],
                    getValue = function(_)
                        return addon.db.independentArtifact
                    end,
                    setValue = function(_, value)
                        addon.db.independentArtifact = value
                        updateCategory(value, L["OPTIONS_CAT_ARTIFACT"])
                    end
                })

                addon.frame:CreateCheckbox({
                    title = L["OPTIONS_CAT_HEIRLOOM"],
                    getValue = function(_)
                        return addon.db.independentHeirloom
                    end,
                    setValue = function(_, value)
                        addon.db.independentHeirloom = value
                        updateCategory(value, L["OPTIONS_CAT_HEIRLOOM"])
                    end
                })

                addon.frame:CreateCheckbox({
                    title = L["OPTIONS_CAT_TOKEN"],
                    getValue = function(_)
                        return addon.db.independentToken
                    end,
                    setValue = function(_, value)
                        addon.db.independentToken = value
                        updateCategory(value, L["OPTIONS_CAT_TOKEN"])
                    end
                })

                refreshButton = addon.frame:CreateButton({
                    title = L["OPTIONS_REFRESH"],
                    align = "CENTER",
                    disabled = true,
                    onClick = function()
                        refreshButton:Disable()
                        ConsoleExec("reloadui")
                    end
                })
            end,
        }
    }
end
