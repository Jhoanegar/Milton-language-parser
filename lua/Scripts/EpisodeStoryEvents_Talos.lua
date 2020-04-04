----------------
-- This script controls various dialogs and other events pertaining to the Talos story
----------------

-- strMDNPattern matching only M/D/N tetrominoes (as we don't care for secrets etc in the story)
local strMDNPattern = "([MDN][IOTLJZS]%d+)"
-- this is set at level start, and prevents Milton from being immediately triggered if certification is not yet completed
local bCertCompletedAtLevelStart = false
-- we track which Milton dialog requested the "eye" on this level, so the eye doesn't immediately show for the next one, until a sigil is collected
local strEyeUsedForDialog = ""

-- Check how many tetrominoes has player picked up so far, and make sure dialogs are triggered appropriately.
local function RecheckMiltonTriggers()
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)

  -- make sure that player cannot re-enter terminal to get Milton immediately after certification
  if not bCertCompletedAtLevelStart then
    -- (but still have to enable the eye for unread texts)
    for i, terminal in ipairs(worldGlobals.miltonTerminals) do
      local var = terminal:GetName().."_SeenTexts"
      terminal:EnableASCIIAnimation(not progress:IsVarSet(var))
    end
  return
  end
  
  local strEyeRequestedBy = "" -- the eye is not shown, unless a dialog is pending

  -- if the player hasn't gone to the tower before entering egypt
  if progress:IsVarSet("Unlocked_DoorEgypt") and not progress:IsVarSet("Unlocked_AnyNexusDoor") and not progress:IsVarSet("Tower1_DONE") then
    -- trigger Milton's dialog to tease player about it
    progress:SetVar("Tower1")
    strEyeRequestedBy = "Tower1"
  end

  -- if the player has gone to the tower before entering medieval
  if not progress:IsVarSet("Unlocked_DoorMedieval") and progress:IsVarSet("Unlocked_AnyNexusDoor") and not progress:IsVarSet("Tower2_DONE") then
    -- trigger Milton's dialog to tease player about it
    progress:SetVar("Tower2")
    strEyeRequestedBy = "Tower2"
  end

  -- if no special-case dialogs have already triggered
  if strEyeRequestedBy == "" then
    -- list of all Milton dialogs, and which tetromino count (All, or Nexus), each of them triggers at
    local aMiltonTriggers = {
      { var="Milton1_1", ctA=  8 , ctN=  3 },
      { var="Milton1_2", ctA= 14 , ctN=  6 },
      { var="Milton2_1", ctA= 21 , ctN= 10 },
      { var="Milton2_2", ctA= 27 , ctN= 13 },
      { var="Milton2_3", ctA= 33 , ctN= 17 },
      { var="Milton2_4", ctA= 40 , ctN= 21 },
      { var="Milton2_5", ctA= 46 , ctN= 25 },
      { var="Milton2_6", ctA= 53 , ctN= 29 },
      { var="Milton3_1", ctA= 59 , ctN= 33 },
      { var="Milton3_2", ctA= 66 , ctN= 36 },
      { var="Milton3_3", ctA= 73 , ctN= 40 },
      { var="Milton3_4", ctA= 79 , ctN= 43 },
      { var="Milton3_5", ctA= 86 , ctN= 47 }
      -- Note: "Milton3_6" is special, that comes at the very end of the game
    }

    -- count all tetrominoes collected by the player so far (sorted by types, ignoring specials and secrets)
    local alltetros = progress:GetInventoryTetrominoes()..progress:GetUsedupTetrominoes()
    local _,ctDoors = string.gsub(alltetros, "D", "")
    local _,ctMechs = string.gsub(alltetros, "M", "")
    local _,ctTalos = string.gsub(alltetros, "N", "")
    local ctAll = ctDoors+ctMechs+ctTalos
    print("tetromino count: A="..ctAll.." N="..ctTalos)
    
    -- iterate through all possible Milton dialogs
    for i,m in ipairs(aMiltonTriggers) do
      -- if the player hasn't already played this dialog
      if not progress:IsVarSet(m.var.."_DONE") then
        -- if that dialog is supposed to be triggered by now
        if ctAll>=m.ctA or ctTalos>=m.ctN then
          -- make sure its var is set
          progress:SetVar(m.var)
          print("triggered dialog: "..m.var)
          -- also enable the Eye of Milton
          strEyeRequestedBy = m.var
        end
        -- only one dialog at a time can be started, so stop iterating
        break
      end
      -- if this dialog already used the eye on this level 
      -- (NOTE, the above check mean that the dialog was already played if we came here)
      if strEyeUsedForDialog == m.var then
        break -- forbid other dialogs from starting on this level until a sigil is picked
      end
    end
  end

  -- if this is the demo level and if Milton not already seen
  if worldGlobals.levelName=="Demo" and not progress:IsVarSet("MiltonDemo_DONE") then
    -- enable milton immediately
    strEyeRequestedBy = "Milton_Demo"
  end
  
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
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)
  local bIsCloudLevel = string.match(worldGlobals.levelName, "^Cloud_._..$")
  local bIsNexusLevel = string.match(worldGlobals.levelName, "^Nexus$")
  
  -- when arriving on Nexus for the first time (exited Cloud_1_01), mark that tutorial is done
  if bIsNexusLevel then
    progress:SetVar("Tutorial_Finished")
  end
  
  --print("LEVEL: "..worldGlobals.levelName.." IsCloud:"..(bIsCloudLevel and 1 or 0).." IsNexus:"..(bIsNexusLevel and 1 or 0))
  -- if this is any other cloud after the first one
  if bIsCloudLevel and worldGlobals.levelName~="Cloud_1_01" then
    -- play the warning against going to tower
    if worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-014_Let_this_be_our_covenant.ogg"), 2) then
      -- mark that we need a special VO on next tetromino
      progress:SetVar("LearningVOOnNextSigil")
      return
    end
  end

  -- starting a cloud level clears the flag so Elohim will play confusion when you go into tower elevator again
  if bIsCloudLevel then
    progress:ClearVar("ElohimLostSubjectPlayed")
  end
  
  local ctStartTetrominoes = 7 -- number of tetrominoes on level #1 (tutorial)
  local ctEndTetrominoes = 90 -- number of main (non-secret) tetrominoes available in the entire game
  -- count total picked tetrominoes
  local strPickedInstances = progress:GetInventoryTetrominoes() .. progress:GetUsedupTetrominoes()
  local ctPickedTotal = 0
  for w in string.gmatch(strPickedInstances, strMDNPattern) do 
    ctPickedTotal = ctPickedTotal+1
  end
  
  -- when all main tetrominoes in the game picked (This has highest precedence)
  if bIsNexusLevel and ctPickedTotal >= ctEndTetrominoes and 
    worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-069_And_so_it_is_done.ogg"), 2) then
    worldGlobals.RequestReviewWhenElohimFinishes()
    progress:SetVar("GatesOfEternityOpened")
    SignalEvent("GatesOfEternityOpened")
    return
  end
  
  -- when all tetrominoes in one of the episodes are picked (This has lower precedence, but still higher than general messages)
  if bIsNexusLevel and progress:IsVarSet("StoryVO_Episode1") and
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-030_Rejoice_child.ogg"), 2) then
    worldGlobals.RequestReviewWhenElohimFinishes()
    return
  end
  if bIsNexusLevel and progress:IsVarSet("StoryVO_Episode2") and
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-033_The_land_of_tombs.ogg"), 2) then
    worldGlobals.RequestReviewWhenElohimFinishes()
    return
  end
  if bIsNexusLevel and progress:IsVarSet("StoryVO_Episode3") and
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-036_Your_faith_has.ogg"), 2) then
    worldGlobals.RequestReviewWhenElohimFinishes()
    return
  end
  
  if bIsNexusLevel and progress:IsVarSet("NihilistFlag") and
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-079_I_fear_the_serpent.ogg"), 1) then
    return
  end
  
  if bIsCloudLevel then
    --print("ENTERED CLOUD: pickedtotal="..ctPickedTotal)
    -- list of VOs that play during the game as you pick new tetrominoes (lowest precedence)
    local storyVOs = {
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-016_These_worlds_and_we.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-017_Long_ago_I_shaped.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-018_I_have_promised.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-019_I_see_all.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-020_You_may_wonder.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-021_You_have_solved.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-022_When_you_overcome.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-023_Chaos_is_that.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-024_Before_the_Age_of_Chaos.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-025_Many_ages_have_passed.ogg"),
      Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-026_My_faith_in_you.ogg")
    }
    
    -- find the first next VO to play
    -- NOTE:
    --   - the +1 part is so that the last one comes at equal space _before_ the end, as there's a special VO for the very end
    --   - the ctStartTetrominoes part makes it start from _after_ the first cloud
    local ctTetrosPerVO = (ctEndTetrominoes-ctStartTetrominoes) / (#storyVOs+1)
    for i,strFile in ipairs(storyVOs) do
      local ctTetrosForThisVO = i*ctTetrosPerVO
      --print("  vo#"..i.." tetros="..ctTetrosForThisVO)
      if ctPickedTotal-ctStartTetrominoes>=ctTetrosForThisVO then
        --print("   SHOULD PLAY")
        if worldGlobals.ElohimSayOnce(strFile, 2) then
          return
        end
      end
    end  
  end

end

-- Check how many tetrominoes has player picked up so far, and make sure Elohim VO is triggered.
local function RecheckElohimTriggers(tetrominoPickedEvent)
  local tetrominoPicked = tetrominoPickedEvent:GetTetromino() -- this is the tetromino that was last picked

  if not string.match(tetrominoPicked, strMDNPattern) then
    return
  end

  local progress = nexGetTalosProgress(worldGlobals.worldInfo)
  -- if we have just exited from tutorial and this is next tetromino after that
  if progress:IsVarSet("LearningVOOnNextSigil") and not progress:IsVarSet("LearningVOOnNextSigil_DONE") then
    -- play VO for end of learning phase
    if worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-015_Good_you_are_learning.ogg"), 2) then
      progress:SetVar("LearningVOOnNextSigil_DONE")
      return
    end
  end

  -- get the table of all tetrominoes in the current episode (where this tetromino is from)
  local tetrominoInstances = prjGetTetrominoInstances(worldGlobals.worldInfo)
  local pickedEpisode = tetrominoInstances:GetInstanceEpisode(tetrominoPicked)
  local aInstancesInEpisode = tetrominoInstances:GetAllInstancesForEpisode(pickedEpisode)
  
  -- make sure none of these interfere with custom scripts for the demo
  if pickedEpisode == "Demo" then
    return
  end
  
  -- filter only those that we are interested in, and transform that into a hashtable for quick lookup
  local hashInstancesInEpisode = {}
  local ctTotalInEpisode = 0
  for k,v in ipairs(aInstancesInEpisode) do
    if string.match(v, strMDNPattern) then
      ctTotalInEpisode = ctTotalInEpisode+1
      hashInstancesInEpisode[v] = true
    end
  end
  
  -- build a table of all tetrominoes currently picked (including those already used up)
  local strPickedInstances = progress:GetInventoryTetrominoes() .. progress:GetUsedupTetrominoes()
  local ctPickedFromEpisode = 0
  local ctPickedTotal = 0
  for w in string.gmatch(strPickedInstances, strMDNPattern) do 
    if hashInstancesInEpisode[w] then
      ctPickedFromEpisode = ctPickedFromEpisode+1
    end
    ctPickedTotal = ctPickedTotal+1
  end
  --print("Picked "..tetrominoPicked.." from episode "..pickedEpisode.." which is "..ctPickedFromEpisode.." / "..ctTotalInEpisode.." = "..(ctPickedFromEpisode/ctTotalInEpisode*100).."%% done now")
  
  -- NOTE: This part of code determines which VOs are eligible to be played, but just schedules them to be played at next level change.

  -- tetrominoes for a particular episode completed  
  if pickedEpisode == "Cloud_1" and ctPickedFromEpisode >= ctTotalInEpisode then
    progress:SetVar("StoryVO_Episode1")
  end
  if pickedEpisode == "Cloud_2" and ctPickedFromEpisode >= ctTotalInEpisode then
    progress:SetVar("StoryVO_Episode2")
  end
  if pickedEpisode == "Cloud_3" and ctPickedFromEpisode >= ctTotalInEpisode then
    progress:SetVar("StoryVO_Episode3")
  end
  
  -- this below does a special check for just the first completed set of Nexus tower tetrominoes
  local _,ctNI = string.gsub(strPickedInstances, "NI", "")
  local _,ctNO = string.gsub(strPickedInstances, "NO", "")
  local _,ctNT = string.gsub(strPickedInstances, "NT", "")
  local _,ctNJ = string.gsub(strPickedInstances, "NJ", "")
  local _,ctNL = string.gsub(strPickedInstances, "NL", "")
  if ctNI>=1 and ctNO>=2 and ctNT>=4 and ctNJ>=1 and ctNL>=1 then
    worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-040_Your_wisdom_grows.ogg"), 4)
  end
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
  
  -- after a respawn, if killed by some "guardian" (turret/mine...)
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)
  if progress:IsVarSet("PlayerKilledByGuardians") then
    progress:ClearVar("PlayerKilledByGuardians") -- needed to make sure it doesn't trigger later if ignore now
    -- send the event, needed by the tutorial
    SignalEvent("PlayerKilledByGuardians")
    -- special VO is played everywhere - but not during the tutorial!
    if progress:IsVarSet("Overlay_Tutorial_14_Barrier_Shown") then
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-037_The_guardians_of_this_land.ogg"), 3)
    end
  end
  
  -- if this is the demo level
  if worldGlobals.levelName=="Demo" then
    -- pretend that we are later in the game, and that this terminal was already used in intro,
    -- to make sure none of the milton hinting files appear on the demo terminal
    progress:SetVar("DemoTerminal_UsedForIntro")
    progress:SetVar("CommPortal_Cert_COMPLETED")
  end
  
  -- if the player hasn't yet finished certification before entering this world, we must not even check for Milton
  -- NOTE: This will prevent player from starting the first Milton immediately after cert. He has to go to next world first.
  bCertCompletedAtLevelStart = progress:IsVarSet("CommPortal_Cert_COMPLETED")
end

local function HandleTerminalEvents(terminal)
  if worldGlobals.elohimSpeak == nil then
    return
  end
  -- Processing Elohim-Milton interaction VOs.... see the %h1, %h2, ... markers in the Milton3_5.dlg
  RunHandled(function() WaitForever() end,
    OnEvery(CustomEvent(terminal, "TerminalHaltEvent_1")), function()
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-072_My_child_you_are_in_danger.ogg"), 0)
    end,
    OnEvery(CustomEvent(terminal, "TerminalHaltEvent_2")), function()
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-073_Enough.ogg"), 0)
    end,
    OnEvery(CustomEvent(terminal, "TerminalHaltEvent_3")), function()
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-074_You_have_done_well.ogg"), 0)
    end,
    OnEvery(CustomEvent(terminal, "TerminalHaltEvent_4")), function()
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-075_Look_within_you.ogg"), 0)
    end,
    OnEvery(CustomEvent(terminal, "TerminalHaltEvent_5")), function()
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-076_Have_faith.ogg"), 0)
    end,
    OnEvery(CustomEvent(terminal, "TerminalHaltEvent_6")), function()
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-077_You_have_already_chosen.ogg"), 0)
    end,
    -- this is for the Milton2_4.dlg
    OnEvery(CustomEvent(terminal, "TerminalHaltEvent_7")), function()
      worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-078_Do_not_think.ogg"), 0)
    end,
    -- this does resuming for all of the halts above
    OnEvery(Event(worldGlobals.elohimSpeak.Finished)), function()
      terminal:ResumeHalted()
    end
  )
end

local function OnTetrominoAwarded()
  strEyeUsedForDialog = "" -- after a puzzle is solved, Milton may reappear
end

local function OnHelpAltarSeen()
  worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-038_Here_those_who_are.ogg"), 0)
end

local function OnHelpAltarUnavailable()
  worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-039_The_counsel_of_my.ogg"), 0)
end

worldGlobals.storyFunctions.OnPlayerBorn = OnPlayerBorn
worldGlobals.storyFunctions.RecheckElohimTriggers = RecheckElohimTriggers
worldGlobals.storyFunctions.RecheckMiltonTriggers = RecheckMiltonTriggers
worldGlobals.storyFunctions.RecheckElohim_OnLevelChange = RecheckElohim_OnLevelChange
worldGlobals.storyFunctions.HandleTerminalEvents = HandleTerminalEvents
worldGlobals.storyFunctions.OnTetrominoAwarded = OnTetrominoAwarded
worldGlobals.storyFunctions.OnHelpAltarSeen = OnHelpAltarSeen
worldGlobals.storyFunctions.OnHelpAltarUnavailable = OnHelpAltarUnavailable
