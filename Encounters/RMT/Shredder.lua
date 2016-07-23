----------------------------------------------------------------------------------------------------
-- Shredder/Swabbie Ski'Li encounter script
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Shredder", 999, 999, 999)
local Log = Apollo.GetPackage("Log-1.0").tPackage
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

--Wave 1 North: Risen Redmoon Grunt x1, Risen Redmoon Cadet x2, Putrid Pouncer x1
--Wave 1 South: Risen Redmoon Grunt x2, Risen Redmoon Cadet x2, Risen Redmoon Plunderer x1
--Wave 2 North: Risen Redmoon Plunderer x3, Noxious Nabber x1
--Wave 2 South: Risen Redmoon Plunderer x3, Noxious Nabber x1
--Wave 3 A: Risen Redmoon Grunt x2, Risen Redmoon Cadet x2, Risen Redmoon Plunderer x1
--Wave 3 B: Risen Redmoon Grunt x1, Risen Redmoon Cadet x2, Putrid Pouncer x1

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFF__SCRUBBER_BUBBLES = 77715
local DEBUFF__NECROTIC_OOZE = 84317 --disorient
local DEBUFF__JUNK_TRAP = 86752 -- unknown

local SPAWN_TRIGGER_DISTANCE = 5 --How close Swabbie has to get to trigger a spawn warning

local DECK_Y_LOC = 598
local SPAWN_1_TRIGGER = Vector3.New(-20, DECK_Y_LOC, -809)
local SPAWN_1_LOCATION_A = Vector3.New(-20, DECK_Y_LOC, -882)
local SPAWN_1_LOCATION_B = Vector3.New(-20, DECK_Y_LOC, -959)
local SPAWN_2_TRIGGER = Vector3.New(-20, DECK_Y_LOC, -809) --Wrong????
local SPAWN_2_LOCATION_A = Vector3.New(-20, DECK_Y_LOC, -807)
local SPAWN_2_LOCATION_B = Vector3.New(-20, DECK_Y_LOC, -958)
local SPAWN_3_TRIGGER = Vector3.New(0, DECK_Y_LOC, 0)
local SPAWN_3_LOCATION_A = Vector3.New(-20, DECK_Y_LOC, -809)
local SPAWN_3_LOCATION_B = Vector3.New(-20, DECK_Y_LOC, -882)

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
    core:AddPicture("SPAWNA", SPAWN_1_LOCATION_A, "Crosshair", 40, nil, nil, nil, "red")
    core:AddPicture("SPAWNB", SPAWN_1_LOCATION_B, "Crosshair", 40, nil, nil, nil, "red")
    mod:AddMsg("WAVE", "Wave 1 Incoming", 5, "Info")
    tPositionCheckTimer = ApolloTimer.Create(.5, true, "OnPositionCheckTimer", self)
end

function mod:OnBossDisable()
    if tPositionCheckTimer then
        tPositionCheckTimer:Stop()
        tPositionCheckTimer = nil
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
        mod:PrintUnitPos(nId)
    elseif sName == self.L["Risen Redmoon Cadet"] then
        mod:PrintUnitPos(nId)
    elseif sName == self.L["Risen Redmoon Plunderer"] then
        mod:PrintUnitPos(nId)
        if not bWave1Spawned then
            bWave1Spawned = true
            mod:PrintUnitPos(nSwabbieSkiLiId)
            core:RemovePicture("SPAWNA")
            core:RemovePicture("SPAWNB")
        elseif not bWave3Spawned then
            bWave3Spawned = true
            mod:PrintUnitPos(nSwabbieSkiLiId)
            core:RemovePicture("SPAWNA")
            core:RemovePicture("SPAWNB")
        end
    elseif sName == self.L["Putrid Pouncer"] then
        mod:PrintUnitPos(nId)
        if not bWave2Spawned then
            bWave2Spawned = true
            mod:PrintUnitPos(nSwabbieSkiLiId)
            core:RemovePicture("SPAWNA")
            core:RemovePicture("SPAWNB")
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
        if not bWave1Spawned then
            -- if mod:DistanceBetween(uSwabbieSkiLi, SPAWN_1_TRIGGER) < SPAWN_TRIGGER_DISTANCE then
                -- core:AddPicture("SPAWNA", SPAWN_1_LOCATION_A, "Crosshair", 40, nil, nil, nil, "red")
                -- core:AddPicture("SPAWNB", SPAWN_1_LOCATION_B, "Crosshair", 40, nil, nil, nil, "red")
                --mod:AddMsg("WAVE", "Wave 1 Incoming", 5, "Info")
            -- end
        elseif not bWave2Spawned then
            if mod:DistanceBetween(uSwabbieSkiLi, SPAWN_2_TRIGGER) < SPAWN_TRIGGER_DISTANCE then
                core:AddPicture("SPAWNA", SPAWN_2_LOCATION_A, "Crosshair", 40, nil, nil, nil, "red")
                core:AddPicture("SPAWNB", SPAWN_2_LOCATION_B, "Crosshair", 40, nil, nil, nil, "red")
                mod:AddMsg("WAVE", "Wave 2 Incoming", 5, "Info")
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
    Log:Add("ChannelCommStatus", "SpawnPosition - " .. unit:GetName() .. ": x " .. position.x .. " y " .. position.y .. " z " .. position.z)
    --core:Print("Location of " .. unit:GetName() .. ": x " .. position.x .. " y " .. position.y .. " z " .. position.z)
end

function mod:DistanceBetween(uUnit, vPosition)
    local v1 = Vector3.new(uUnit:GetPosition())
    return (v1 - v2):Length()
end
