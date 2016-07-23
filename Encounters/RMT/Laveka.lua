----------------------------------------------------------------------------------------------------
-- Laveka encounter script
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Laveka", 999, 999, 999)
if not mod then return end

mod:RegisterTrigMob("ANY", { "Laveka the Dark-Hearted" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["Laveka the Dark-Hearted"] = "Laveka the Dark-Hearted",
    ["Shade of Laveka"] = "Shade of Laveka",
    -- Datachron messages.
    ["Death is only the beginning..."] = "Death is only the beginning...",
    ["Welcome back to the land of the Living"] = "Welcome back to the land of the Living",
    -- Cast.
    -- Bar and messages.
})


----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFF__REALM_OF_THE_DEAD = 0000

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
	--mod:AddTimerBar("ARMS", "Next arms", 45, nil)
end

function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
    -- local tUnit = GameLib.GetUnitById(nId)
    -- if DEBUFF__THE_SKY_IS_FALLING == nSpellId then
        -- local sName = tUnit:GetName()
        -- if tUnit == GetPlayerUnit() then
            -- mod:AddMsg("SMASH", "SMASH ON YOU!", 5, "RunAway")
        -- else
            -- mod:AddMsg("SMASH", self.L["SMASH ON %s!"]:format(sName), 5, "Info")
        -- end
        -- if true then -- mod:GetSetting("") then
            -- core:MarkUnit(tUnit, nil, self.L["SMASH"]) 
        -- end
    -- end
end


function mod:OnDebuffRemove(nId, nSpellId)
    -- if nSpellId == DEBUFF__THE_SKY_IS_FALLING then
        -- core:DropMark(nId)
    -- end
end

function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
    -- core:Print(sCastName .. " x " .. sName)
    -- if self.L["Laveka the Dark-Hearted"] == sName then
        -- if self.L["Noxious Belch"] == sCastName then
            -- mod:AddMsg("BELCH", "Noxious Belch", 5, mod:GetSetting("foo") and "Beware")
            -- mod:AddMsg("BELCH", "Noxious Belch", 5, "Beware")
            
            -- self:AddPolygon("PLAYER_BELCH", GameLib.GetPlayerUnit():GetPosition(), 8, 0, 3, "xkcdBrightPurple", 16)
        -- end
    -- end
end

function mod:OnUnitCreated(nId, unit, sName)
    local player = GameLib.GetPlayerUnit()
    
    if sName == self.L["Laveka the Dark-Hearted"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
    -- elseif sName == self.L["Cannon Arm"] then
        -- core:AddLineBetweenUnits("CANNON", player:GetId(), nId, 2, "red")
        -- mod:AddTimerBar("ARMS", "Next arms", 45, nil)
    -- elseif sName == self.L["Flailing Arm"] then
        -- core:AddLineBetweenUnits("FLAIL", player:GetId(), nId, 2, "blue")
    end
end
