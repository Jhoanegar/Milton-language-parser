----------------
-- This script controls various dialogs and other events pertaining to the Talos story
----------------

-- we track which Milton dialog requested the "eye" on this level, so the eye doesn't immediately show for the next one, until a sigil is collected
local strEyeUsedForDialog = ""

-- Check how many tetrominoes has player picked up so far, and make sure dialogs are triggered appropriately.
local function RecheckMiltonTriggers()
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)

  local strEyeRequestedBy = "" -- the eye is not shown, unless a dialog is pending

  if strEyeRequestedBy~="" then
    strEyeUsedForDialog = strEyeRequestedBy
  end

  -- each terminal eligible for Milton's eye
  for i, terminal in ipairs(worldGlobals.miltonTerminals) do
    local var = terminal:GetName().."_SeenTexts"
    -- enable/disable the eye on it, depending on whether a dialog was found and whether player saw the texts on the terminal
    terminal:EnableASCIIAnimation(strEyeRequestedBy~="" or not progress:IsVarSet(var))
  end
end

-- Check if Elohim should play some quote at start of this level
local function RecheckElohim_OnLevelChange()
end

-- Check how many tetrominoes has player picked up so far, and make sure Elohim VO is triggered.
local function RecheckElohimTriggers(tetrominoPickedEvent)
end

local function OnPlayerBorn(eePlayerBorn)
  RunAsync(function()
    -- wait till the player dies
    local player = eePlayerBorn:GetBornPlayer()
    local eePlayerDied = Wait(Event(player.Died))
    -- if he was killed by a mine or a turret
    local killer = eePlayerDied:GetKiller()
    local killerclass = killer:GetClassName()
    if killerclass=="CMinePuppetEntity" or killerclass=="CAutoTurretEntity" then
      -- mark that a VO should be played upon respawn
      local progress = nexGetTalosProgress(worldGlobals.worldInfo)
      progress:SetVar("PlayerKilledByGuardians")
    end
  end)
  
  -- pretend that we are later in the game, and that this terminal was already used in intro,
  -- to make sure none of the milton hinting files appear on the demo terminal
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)
  --progress:SetVar("DemoTerminal_UsedForIntro")
  --progress:SetVar("CommPortal_Cert_COMPLETED")
end

local function HandleTerminalEvents(terminal)
end

local function OnTetrominoAwarded()
  strEyeUsedForDialog = "" -- after a puzzle is solved, Milton may reappear
end

local function OnHelpAltarSeen()
end

local function OnHelpAltarUnavailable()
end

worldGlobals.storyFunctions.OnPlayerBorn = OnPlayerBorn
worldGlobals.storyFunctions.RecheckElohimTriggers = RecheckElohimTriggers
worldGlobals.storyFunctions.RecheckMiltonTriggers = RecheckMiltonTriggers
worldGlobals.storyFunctions.RecheckElohim_OnLevelChange = RecheckElohim_OnLevelChange
worldGlobals.storyFunctions.HandleTerminalEvents = HandleTerminalEvents
worldGlobals.storyFunctions.OnTetrominoAwarded = OnTetrominoAwarded
worldGlobals.storyFunctions.OnHelpAltarSeen = OnHelpAltarSeen
worldGlobals.storyFunctions.OnHelpAltarUnavailable = OnHelpAltarUnavailable
