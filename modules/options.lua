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
---@class Events: AceModule
local events = BetterBags:GetModule('Events')
-----------------------------

local debounceTimer
local pendingCategories = {}

local updateSavedVariables = function()
    BetterBags_LegendaryDB = addon.db
end

local updateCategory = function(categoryEnabled, categoryName)
    if debounceTimer then
        debounceTimer:Cancel()
    end

    -- store the latest requested state for this category
    pendingCategories[categoryName] = categoryEnabled

    -- We wait for the value not to be changed for 1 second before refreshing the categories
    debounceTimer = C_Timer.NewTimer(1, function()
        updateSavedVariables()

        -- Process all pending category updates
        for name, enabled in pairs(pendingCategories) do
            if (enabled) then
                addon:GetOrCreateBetterBagsCategory(name)
            end
            categories:WipeCategory(addon.context:Copy(), L["CATEGORY_NAME"])
            categories:WipeCategory(addon.context:Copy(), name)
            if (not enabled) then
                categories:DeleteCategory(addon.context:Copy(), name)
            end
        end

        -- clear the pending table
        for k in pairs(pendingCategories) do
            pendingCategories[k] = nil
        end

        events:SendMessage(addon.context:Copy(), 'bags/FullRefreshAll')
    end)
end

--- Options panel
-----------------------------
addon.options = {
    a = {
        type = "description",
        order = 1,
        name = L["OPTIONS_DESC"],
    },
    b = {
        type = "toggle",
        order = 2,
        width = "full",
        name = L["OPTIONS_CAT_LEGENDARY"],
        get = function() return addon.db.independentLegendary end,
        set = function(_, value)
            addon.db.independentLegendary = value
            updateCategory(value, L["OPTIONS_CAT_LEGENDARY"])
        end
    },
    c = {
        type = "toggle",
        order = 3,
        width = "full",
        name = L["OPTIONS_CAT_ARTIFACT"],
        get = function() return addon.db.independentArtifact end,
        set = function(_, value)
            addon.db.independentArtifact = value
            updateCategory(value, L["OPTIONS_CAT_ARTIFACT"])
        end
    },
    d = {
        type = "toggle",
        order = 4,
        width = "full",
        name = L["OPTIONS_CAT_HEIRLOOM"],
        get = function() return addon.db.independentHeirloom end,
        set = function(_, value)
            addon.db.independentHeirloom = value
            updateCategory(value, L["OPTIONS_CAT_HEIRLOOM"])
        end
    },
    e = {
        type = "toggle",
        order = 5,
        width = "full",
        name = L["OPTIONS_CAT_TOKEN"],
        get = function() return addon.db.independentToken end,
        set = function(_, value)
            addon.db.independentToken = value
            updateCategory(value, L["OPTIONS_CAT_TOKEN"])
        end
    }
}
