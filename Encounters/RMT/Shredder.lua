----------------------------------------------------------------------------------------------------
-- Shredder/Swabbie Ski'Li encounter script
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Shredder", 999, 999, 999)
if not mod then return end

mod:RegisterTrigMob("ANY", { "Swabbie Ski'Li" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["Swabbie Ski'Li"] = "Swabbie Ski'Li",
	["Risen Redmoon Cadet"] = "Risen Redmoon Cadet",
	["Risen Redmoon Plunderer"] = "Risen Redmoon Plunderer",
    ["Noxious Nabber"] = "Noxious Nabber",
    ["Putrid Pouncer"] = "Putrid Pouncer",
    ["Risen Redmoon Grunt"] = "Risen Redmoon Grunt",
    -- Datachron messages.
    -- Cast.
    -- Bar and messages.
})

--Wave 1: Risen Redmoon Cadet x2, Risen Redmoon Plunderer, Noxious Nabber
--Wave 2: Putrid Pouncer, Risen Redmoon Grunt x2

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFF__SCRUBBER_BUBBLES = 77715
local DEBUFF__NECROTIC_OOZE = 84317 --disorient
local DEBUFF__JUNK_TRAP = 86752 -- unknown

local DECK_Y_LOC = 597.88
local SPAWN_1_LOCATION = { x = -20, y = DECK_Y_LOC, z = -811 }
local SPAWN_2_TRIGGER = { x = 0, y = DECK_Y_LOC, z = 0 }
local SPAWN_2_LOCATION = { x = 0, y = DECK_Y_LOC, z = 0 }
local SPAWN_3_TRIGGER = { x = 0, y = DECK_Y_LOC, z = 0 }
local SPAWN_3_LOCATION = { x = 0, y = DECK_Y_LOC, z = 0 }
local SPAWN_TRIGGER_DISTANCE = 10 --How close Swabbie has to get to trigger a spawn warning

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local bWave1Spawned, bWave2Spawned, bWave3Spawned, bMiniSpawned
local tPositionCheckTimer
local nSwabbieSkiLiId


----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
	bWave1Spawned = false
    bWave2Spawned = false
    bWave3Spawned = false
    core:AddPicture("SPAWN", SPAWN_1_LOCATION, "Crosshair", 40, nil, nil, nil, "red")
    mod:AddMsg("WAVE", "Wave 1 Incoming", 5, "Info")
    tPositionCheckTimer = ApolloTimer.Create(.5, true, "OnPositionCheckTimer", self)
end

function mod:OnBossDisable()
    if tPositionCheckTimer then
        tPositionCheckTimer:Stop()
    end
end

function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
end

function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
    --if self.L["Robomination"] == sName then
    --    if self.L["Noxious Belch"] == sCastName then
    --        mod:AddMsg("BELCH", "Noxious Belch", 5, "Beware")
    --    end
    --end
end

function mod:OnUnitCreated(nId, unit, sName)
    local player = GameLib.GetPlayerUnit()
    
    if sName == self.L["Swabbie Ski'Li"] then
        core:AddUnit(unit)
        core:WatchUnit(unit)
        nSwabbieSkiLiId = nId
    elseif sName == self.L["Noxious Nabber"] then
        if not bWave1Spawned then
            core:Print("Wave 1")
            mod:PrintUnitPos(nId)
            --Probably want to watch this for interrupts
            mod:PrintUnitPos(nSwabbieSkiLiId)
            bWave1Spawned = true
            mod:RemoveMsg("WAVE")
            --mod:RemovePicture("SPAWN")
        end
    elseif sName == self.L["Risen Redmoon Cadet"] then
        mod:PrintUnitPos(nId)
    elseif sName == self.L["Risen Redmoon Plunderer"] then
        mod:PrintUnitPos(nId)
    elseif sName == self.L["Putrid Pouncer"] then
        if not bWave2Spawned then
            core:Print("Wave 2")
            mod:PrintUnitPos(nId)
            --Watch for interrupts?
            mod:PrintUnitPos(nSwabbieSkiLiId)
            bWave2Spawned = true
            mod:RemoveMsg("WAVE")
            --mod:RemovePicture("SPAWN")
        end
    elseif sName == self.L["Risen Redmoon Grunt"] then
        mod:PrintUnitPos(nId)
    elseif sName == self.L["Risen Redmoon Cadet"] then
        mod:PrintUnitPos(nId)
    end
end

function mod:OnPositionCheckTimer()
    uSwabbieSkiLi = GameLib.GetUnitById(nSwabbieSkiLiId)
    if uSwabbieSkiLi then
        if not bWave2Spawned then
            if mod:DistanceBetween(uSwabbieSkiLi, SPAWN_2_TRIGGER) < SPAWN_TRIGGER_DISTANCE then
            
            end
        elseif not bWave3Spawned then
            if mod:DistanceBetween(uSwabbieSkiLi, SPAWN_3_TRIGGER) < SPAWN_TRIGGER_DISTANCE then
            
            end
        end
    end
end

function mod:PrintUnitPos(nId)
    local unit = GameLib.GetUnitById(nId)    
    local position = unit:GetPosition()
    core:Print("Location of " .. unit:GetName() .. ": x " .. position.x .. " y " .. position.y .. " z " .. position.z)
end

function mod:DistanceBetween(uUnit, lPosition)
    local v1 = Vector3.new(uUnit:GetPosition())
    local v2 = Vector3.new(lPosition)
    return (v1 - v2):Length()
end
