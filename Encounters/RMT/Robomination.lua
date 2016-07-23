----------------------------------------------------------------------------------------------------
-- Robomination encounter script
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Robomination", 999, 999, 999)
if not mod then return end

mod:RegisterTrigMob("ANY", { "Robomination" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["Robomination"] = "Robomination",
	["Cannon Arm"] = "Cannon Arm",
	["Flailing Arm"] = "Flailing Arm",
    ["Scanning Eye"] = "Scanning Eye",
    ["Trash Compactor"] = "Trash Compactor", --What are these? live 5.5 seconds
    -- Datachron messages.
    ["Robomination Tries to crush %s"] = "Robomination Tries to crush",
    ["The Robomination sinks down into the trash"] = "The Robomination sinks down into the trash",
    ["The Robomination erupts back into the fight!"] = "The Robomination erupts back into the fight!",
    ["The Robomination tries to incinerate %s"] = "The Robomination tries to incinerate",
    -- Cast.
	["Noxious Belch"] = "Noxious Belch",
    ["Incineration Laser"] = "Incineration Laser",
    ["Cannon Blast"] = "Cannon Blast",
    -- Bar and messages.
    ["SMASH"] = "SMASH",
	["SMASH ON YOU"] = "SMASH ON YOU",
    ["SMASH NEAR YOU"] = "SMASH NEAR YOU",
    ["SMASH ON %s!"] = "SMASH ON %s!",
    ["Midphase soon!"] = "Midphase soon!",
})

mod:RegisterDefaultSetting("LinesFlailingArms", false)
mod:RegisterDefaultSetting("LinesCannonArms")
mod:RegisterDefaultSetting("LinesScanningEye")
mod:RegisterDefaultSetting("MarkSmashTarget")
mod:RegisterDefaultSetting("SmashWarningSound")
mod:RegisterDefaultSetting("BelchWarningSound")
mod:RegisterDefaultSetting("MidphaseWarningSound")
mod:RegisterDefaultSetting("CannonArmInterruptSound", false)

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFF__ATOMIC_SPEAR = 70161 --Tank debuff of some sort?
local DEBUFF__THE_SKY_IS_FALLING = 75126 --Smash target
local DEBUFF__INCINERATION_LASER = 75496 --Laser target, rooted till someone else steps into the beam
local DEBUFF__MELTED_ARMOR = 83814 --Has stacks, 65% extra damage from laser per stack
local DEBUFF__TRACTOR_BEAM = 75623 --Yoink!
local DEBUFF__DISCHARGE = 84304 --Something the eye casts during mid phase maybe?

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local bMidPhase1

local bInMidPhase

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
    bMidPhase1 = false
    bInMidPhase = false
	mod:AddTimerBar("ARMS", "Next arms", 45, nil)
end

function mod:OnHealthChanged(nId, nPercent, sName)
    if sName == self.L["Star-Eater the Voracious"] then
        if nPercent >= 75 and nPercent <= 77 and not bMidPhase1 then
            bMidPhase1 = true
            mod:AddMsg("MIDPHASEWARNING", self.L["Midphase soon!"], 5, mod:GetSetting("MidphaseWarningSound") and "Algalon")
        -- elseif nPercent >= 35 and nPercent <= 37 and not bShard2Warning then
            -- bShard2Warning = true
            -- mod:AddMsg("SHARDWARNING", self.L["Shard phase soon!"], 5, mod:GetSetting("MidphaseWarningSound") and "Algalon")
        end
    end
end

function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
    local tUnit = GameLib.GetUnitById(nId)
    local player = GameLib.GetPlayerUnit()
    if DEBUFF__THE_SKY_IS_FALLING == nSpellId then
        if tUnit == player then
            mod:AddMsg("SMASH", "SMASH ON YOU!", 5, mod:GetSetting("SmashWarningSound") and "RunAway")
        elseif mod:GetDistanceBetweenUnits(player, tUnit) < 8 then
            mod:AddMsg("SMASH", self.L["SMASH NEAR YOU"]:format(sName), 5, mod:GetSetting("SmashWarningSound") and "Info")
        else
            local sName = tUnit:GetName()
            mod:AddMsg("SMASH", self.L["SMASH ON %s!"]:format(sName), 5, mod:GetSetting("SmashWarningSound") and "Info")
        end
        if mod:GetSetting("MarkSmashTarget") then
            core:MarkUnit(tUnit, nil, self.L["SMASH"]) 
        end
    elseif DEBUFF__INCINERATION_LASER == nSpellId then
        
    end
end


function mod:OnDebuffRemove(nId, nSpellId)
    if nSpellId == DEBUFF__THE_SKY_IS_FALLING then
        core:DropMark(nId)
    end
end

function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
    if self.L["Robomination"] == sName then
        if self.L["Noxious Belch"] == sCastName then
            mod:AddMsg("BELCH", "Noxious Belch", 5, mod:GetSetting("BelchWarningSound") and "Beware")
            
            --self:AddPolygon("PLAYER_BELCH", GameLib.GetPlayerUnit():GetPosition(), 8, 0, 3, "xkcdBrightPurple", 16)
        end
    elseif self.L["Cannon Arm"] == sName then
        if self.L["Cannon Blast"] == sCastName then
            mod:AddMsg("CANNONBLAST", "Interrupt!", 5, mod:GetSetting("CannonArmInterruptSound") and "Alert")
        end
    end
end

function mod:OnDatachron(sMessage)
    if sMessage == self.L["The Robomination sinks down into the trash"] then
        bInMidPhase = true
        mod:AddMsg("MIDPHASE", "Get to center!", 5, "Info")
        mod:RemoveTimerBar("ARMS")
    elseif sMessage == self.L["The Robomination erupts back into the fight!"] then
        bInMidPhase = false
        mod:AddTimerBar("ARMS", "Next arms", 45, nil)
    end
end

function mod:OnUnitCreated(nId, unit, sName)
    local player = GameLib.GetPlayerUnit()
    
    if sName == self.L["Robomination"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
    elseif sName == self.L["Cannon Arm"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if mod:GetSetting("LinesCannonArms") then
            core:AddLineBetweenUnits("CANNON", player:GetId(), nId, 5, "red")
        end
        if not bInMidPhase then
            mod:AddTimerBar("ARMS", "Next arms", 45, nil)
        end
    elseif sName == self.L["Flailing Arm"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if mod:GetSetting("LinesFlailingArms") then
            core:AddLineBetweenUnits("FLAIL", player:GetId(), nId, 5, "blue")
        end
    elseif sName == self.L["Scanning Eye"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if mode:GetSetting("LinesScanningEye") then
            core:AddLineBetweenUnits("EYE", player:GetId(), nId, 5, "green")
        end
    end
end
