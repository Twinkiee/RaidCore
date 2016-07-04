----------------------------------------------------------------------------------------------------
-- Octog encounter script (HE'LL ALWAYS BE OCTOC TO ME!)
--
-- Copyright (C) 2016 Joshua Shaffer
----------------------------------------------------------------------------------------------------
local core = Apollo.GetPackage("Gemini:Addon-1.1").tPackage:GetAddon("RaidCore")
local mod = core:NewEncounter("Octog", 999, 999, 999)
if not mod then return end

mod:RegisterTrigMob("ANY", { "Star-Eater the Voracious" })
mod:RegisterEnglishLocale({
    -- Unit names.
    ["Star-Eater the Voracious"] = "Star-Eater the Voracious",
	["Astral Shard"] = "Astral Shard",
    ["Squirgling"] = "Squirgling",
    ["Chaos Orb"] = "Chaos Orb",
    ["Noxious Ink Pool"] = "Noxious Ink Pool",
    -- Datachron messages.
    -- Cast.
    -- Bar and messages.
})

----------------------------------------------------------------------------------------------------
-- Constants.
----------------------------------------------------------------------------------------------------
local DEBUFF__NOXIOUS_INK = 85533 -- happens the whole fight maybe just a dot or something?
local DEBUFF__SQUINGLING_SMASHER = 86804 --for smashing the squirglings
local DEBUFF__CHAOS_TETHER = 85583 -- related to the orb? maybe this is the buff that kills if you leave?
local DEBUFF__CHAOS_ORB = 85582 -- related to the orb? damage taken increase? has stacks
local DEBUFF__REND = 85443 -- main tank stacking debuff, 2.5% less mitigation per stack
local DEBUFF__SPACE_FIRE = 87159 -- ?

----------------------------------------------------------------------------------------------------
-- Locals.
----------------------------------------------------------------------------------------------------
local bInShardPhase

local tShardIds

local tShardTimer

----------------------------------------------------------------------------------------------------
-- Encounter description.
----------------------------------------------------------------------------------------------------
function mod:OnBossEnable()
    --mod:AddTimerBar("ORBSPAWN", "Orb Spawn", 45, nil) 
    --30s to orb after airlock phase
    bInShardPhase = false
    tShardIds = {}
end

function mod:OnCastStart(nId, sCastName, nCastEndTime, sName)
    --if self.L["Robomination"] == sName then
    --    if self.L["Noxious Belch"] == sCastName then
    --        mod:AddMsg("BELCH", "Noxious Belch", 5, "Beware")
    --    end
    --end
end

function mod:OnUnitCreated(nId, tUnit, sName)
    local player = GameLib.GetPlayerUnit()
    
    if sName == self.L["Star-Eater the Voracious"] then
        core:AddUnit(tUnit)
        core:WatchUnit(tUnit)
    elseif sName == self.L["Squirgling"] then
        --core:AddUnit(tUnit)
        --core:WatchUnit(tUnit)
    elseif sName == self.L["Astral Shard"] then
        if not bInShardPhase then
            mod:AddTimerBar("SHARDWIPE", "Shard Phase Wipe", 25, nil) --seems to be 25s from logs
            ApolloTimer.Create(0.25, true, timerFunc, self)
        end
        --maybe check height here and mark low ones? hrmmm
        
        bInShardPhase = true
        
        tShardIds[nId] = nId;
    end
end

function mod:OnUnitDestroyed(nId, tUnit, sName)
    if sName == self.L["Astral Shard"] then
       tShardIds[nId] = nil;
    end
    
    tShardIds = {}
end

function mod:CheckShards()
    
end

function mod:OnDebuffAdd(nId, nSpellId, nStack, fTimeRemaining)
    --local tUnit = GameLib.GetUnitById(nId)
    --local player = GameLib.GetPlayerUnit()
    
    if DEBUFF__ELECTROSHOCK_VULNERABILITY == nSpellId then
        --if tUnit == player then
            --mod:AddMsg("ORBTARGET", self.L["ORB ON YOU!"], 5, "RunAway")
            --core:AddLineBetweenUnits("ORB", player:GetId(), nOrbId, 2, "red")
            --local chatMessage = tUnit:GetName() .. " got shocked debuff"
            --ChatSystemLib.Command("/p " .. chatMessage)
        --end
    end
end