----------------------------------------------------------------------------------------------------
-- Robomination encounter script
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Robomination", {104, 104}, {0, 548}, {548, 551})
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
    ["Cannon Fire"] = "Cannon Fire",
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
mod:RegisterDefaultSetting("MarkIncineratedPlayer")
mod:RegisterDefaultSetting("SmashWarningSound")
mod:RegisterDefaultSetting("BelchWarningSound")
mod:RegisterDefaultSetting("MidphaseWarningSound")
mod:RegisterDefaultSetting("IncinerationWarningSound")
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
local bMidPhase1Warning, bMidPhase2Warning

local bInMidPhase

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
    bMidPhase1Warning = false
    bMidPhase2Warning = false
    bInMidPhase = false
	mod:AddTimerBar("ARMS", "Next arms", 45, nil)
end

function mod:OnHealthChanged(nId, nPercent, sName)
    if sName == self.L["Robomination"] then
        if nPercent >= 75 and nPercent <= 77 and not bMidPhase1Warning then
            bMidPhase1Warning = true
            mod:AddMsg("MIDPHASEWARNING", self.L["Midphase soon!"], 5, mod:GetSetting("MidphaseWarningSound") and "Algalon")
        elseif nPercent >= 50 and nPercent <= 57 and not bMidPhase2Warning then
            bMidPhase2Warning = true
            mod:AddMsg("MIDPHASEWARNING", self.L["Midphase soon!"], 5, mod:GetSetting("MidphaseWarningSound") and "Algalon")
        end
    end
end

function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
    local tUnit = GameLib.GetUnitById(nId)
    local player = GameLib.GetPlayerUnit()
    if DEBUFF__THE_SKY_IS_FALLING == nSpellId then
        if tUnit == player then
            mod:AddMsg("SMASH", "SMASH ON YOU!", 5, mod:GetSetting("SmashWarningSound") and "RunAway")
        elseif mod:GetDistanceBetweenUnits(player, tUnit) < 10 then
            mod:AddMsg("SMASH", self.L["SMASH NEAR YOU"]:format(sName), 5, mod:GetSetting("SmashWarningSound") and "Info")
        else
            local sName = tUnit:GetName()
            mod:AddMsg("SMASH", self.L["SMASH ON %s!"]:format(sName), 5, mod:GetSetting("SmashWarningSound") and "Info")
        end
        if mod:GetSetting("MarkSmashTarget") then
            core:AddPicture(nId, nId, "Crosshair", 40, nil, nil, nil, "red")
        end
    elseif DEBUFF__INCINERATION_LASER == nSpellId then
        if mod:GetSetting("MarkIncineratedPlayer") then
            core:AddPicture("LASER" .. nId, nId, "Crosshair", 40, nil, nil, nil, "xkcdBrightPurple")
        end
    end
end

function mod:OnDebuffRemove(nId, nSpellId)
    if DEBUFF__THE_SKY_IS_FALLING == nSpellId then
        core:RemovePicture(nId)
    elseif DEBUFF__INCINERATION_LASER == nSpellId then
        core:RemovePicture("LASER" .. nId)
    end
end

function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
    if self.L["Robomination"] == sName then
        if self.L["Noxious Belch"] == sCastName then
            mod:AddMsg("BELCH", "Noxious Belch", 5, mod:GetSetting("BelchWarningSound") and "Beware")
            
            --self:AddPolygon("PLAYER_BELCH", GameLib.GetPlayerUnit():GetPosition(), 8, 0, 3, "xkcdBrightPurple", 16)
        elseif self.L["Incineration Laser"] == sCastName then
            core:AddPolygon("INCINERATION_LASER", nId, 11.2, 0, 4, "xkcdBrightPurple", 16)
            self:ScheduleTimer(core:RemovePolygon("INCINERATION_LASER"), 12)
        end
        
    elseif self.L["Cannon Arm"] == sName then
        if self.L["Cannon Fire"] == sCastName then
            mod:AddMsg("CANNONBLAST", "Interrupt!", 2, mod:GetSetting("CannonArmInterruptSound") and "Alert")
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
    elseif sMessage:find(self.L["The Robomination tries to incinerate %s"]) then
        mod:AddMsg("INCINERATION", "Incineration!", 5, mod:GetSetting("IncinerationWarningSound") and "Inferno")
    end
end

-- Test
function mod:OnUnitCreated(nId, unit, sName)
    local player = GameLib.GetPlayerUnit()
    
    if sName == self.L["Robomination"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        core:AddPixie(unit:GetId(), 2, unit, nil, "Green", 10, 22, 0)
    elseif sName == self.L["Cannon Arm"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if mod:GetSetting("LinesCannonArms") then
            core:AddLineBetweenUnits(nId, player:GetId(), nId, 5, "red")
        end
        if not bInMidPhase then
            mod:AddTimerBar("ARMS", "Next arms", 45, nil)
        end
    elseif sName == self.L["Flailing Arm"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        core:AddPixie(unit:GetId(), 2, unit, nil, "Blue", 10, 22, 0)
        if mod:GetSetting("LinesFlailingArms") then
            core:AddLineBetweenUnits(nId, player:GetId(), nId, 5, "blue")
        end
    elseif sName == self.L["Scanning Eye"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        if mode:GetSetting("LinesScanningEye") then
            core:AddLineBetweenUnits(nId, player:GetId(), nId, 5, "green")
        end
    end
end

function mod:OnUnitDestroyed(nId, unit, sName)
    if sName == self.L["Scanning Eye"] then
        core:RemoveLineBetweenUnits(nId)
        mod:AddTimerBar("ARMS", "Next arms", 6, nil)
    elseif sName == self.L["Cannon Arm"] then
        core:RemoveLineBetweenUnits(nId)
    elseif sName == self.L["Flailing Arm"] then
        core:RemoveLineBetweenUnits(nId)
    end
end
