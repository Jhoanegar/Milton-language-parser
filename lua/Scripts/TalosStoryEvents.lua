
local function DummyFunction() end

-- story functions that respond to certain events
worldGlobals.storyFunctions = {}
worldGlobals.storyFunctions.OnPlayerBorn = DummyFunction
worldGlobals.storyFunctions.RecheckElohimTriggers = DummyFunction
worldGlobals.storyFunctions.RecheckMiltonTriggers = DummyFunction
worldGlobals.storyFunctions.RecheckElohim_OnLevelChange = DummyFunction
worldGlobals.storyFunctions.HandleTerminalEvents = DummyFunction
worldGlobals.storyFunctions.OnHelpAltarSeen = DummyFunction
worldGlobals.storyFunctions.OnHelpAltarUnavailable = DummyFunction
worldGlobals.storyFunctions.OnTetrominoAwarded = DummyFunction

-- list of all terminals in the current world where Milton's eye may appear. this excludes floor terminals and ending terminals
worldGlobals.miltonTerminals = NewGroupVar()
local elohimIsSpeaking = false -- used to prevent Elohim from interrupting his own lines

worldGlobals.DidElohimSay = function(filename)
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)
  local var = string.match(filename, "([^/]+)%.[^%.]+$")
  return progress:IsVarSet(var)
end

worldGlobals.IsElohimSpeakingNow = function()
  return elohimIsSpeaking
end


-- This function is added to world globals, and can be used by per-world scripts as well, in order to consistently play Elohim VO on different triggers.
-- optional optDelay param specifies how lojng to wait before playing
-- optional optWithEffect  param speficies whether to use full version of effect (with postprocessing, background sounds, etc) or not
-- this function exits immediately and returns whether it will play it or not, even if delay is given
worldGlobals.ElohimSayOnce = function(filename, optDelay, optWithEffect)
  if worldGlobals.elohimSpeak == nil then
    conErrorF("ElohimSayOnce invoked but elohimSpeak is unavailable!\n")
    return
  end

  -- in case two VOs are trying to interrupt, don't play the second one
  if elohimIsSpeaking then
    return false
  end
  
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)
  if progress==nil then
    conErrorF("Cannot make Elohim say '"..filename.."' because TalosProgress object is not found.")
    return false
  end
  
  -- variable used to make sure we only play this once is derived from the filename
  local var = string.match(filename, "([^/]+)%.[^%.]+$")
  if progress:IsVarSet(var) then
    return false
  end
  progress:SetVar(var)
  
  RunAsync(function()
    if optDelay then
      Wait(Delay(optDelay))
    end      
    conLogF("Elohim speaks: "..var.."\n")
    elohimIsSpeaking = true
    if optWithEffect then
      worldGlobals.elohimSpeak:StartWithDelayedObtain(filename)  
    else
      worldGlobals.elohimSpeak:StartSimpleWithDelayedObtain(filename)  
    end
    Wait(Event(worldGlobals.elohimSpeak.Finished))
    elohimIsSpeaking = false
  end)
  return true
end

-- update variables to run the intro dialogs before first Milton starts
local function RecheckMLAIntro_OnTerminalStart()
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)
  
  -- intro starts in the "query" phase, transitions to "busy" once "run mla" is actually used
  if not progress:IsVarSet("MLAIntro_Initialized") then
    progress:SetVar("MLAIntro_PhaseQuery")
    progress:SetVar("MLAIntro_Initialized")
  end

  if not progress:IsVarSet("$(Terminal)_UsedInIntro") and not progress:IsVarSet("CommPortal_Cert_COMPLETED") then
    progress:SetVar("$(Terminal)_UsedInIntro")

    -- this makes sure that on the next terminal after "run mla" is used, you get the CommPortal sequence
    if progress:IsVarSet("MLAIntro_PhaseBusy") then
      progress:ClearVar("MLAIntro_PhaseBusy")
      progress:SetVar("MLAIntro_PhaseCommPortal")
    -- this section makes sure that if you visit 3 different terminals and still didn't do the "mla run" with Query mode, it will force CommPortal onto you anyway on the third
    elseif not progress:IsVarSet("MLAIntro_Term1") then
      progress:SetVar("MLAIntro_Term1")
    elseif not progress:IsVarSet("MLAIntro_Term2") then
      progress:SetVar("MLAIntro_Term2")
    else
      progress:SetVar("MLAIntro_PhaseCommPortal")
    end
  end
end

-- this function is ran asynchronously when a puzzle is entered, it monitors for puzzle play time and related VOs
local function PuzzleWatcher(ePuzzleEntered)
  -- nothing to do if there's no elohim speak available in this world
  -- (DLC doesn't necessarilly have elohim speak)
  if worldGlobals.elohimSpeak == nil then
    return
  end
  local puzzleName = ePuzzleEntered:GetPuzzleName()
  local tetromino = ePuzzleEntered:GetTetrominoName()
  local puzzleMedianDuration = ePuzzleEntered:GetMedianDuration()
  local puzzleTimeout = puzzleMedianDuration*2 -- how long to wait before Elohim tells you that you should move along
  local puzzleMinimumTimeout = 10*60 -- for shorter puzzles, a minimum has to be imposed otherwise Elohim comments before the player even thinks he is stuck
  if puzzleTimeout<puzzleMinimumTimeout then
    puzzleTimeout = puzzleMinimumTimeout
  end
  local sessionDuration = ePuzzleEntered:GetPuzzleSessionDuration()
  local puzzleHeader = "PUZZLE: "..puzzleName.."@"..worldGlobals.levelName.."("..tetromino..")"
  
  -- log that the puzzle has started (or continued)
  if sessionDuration>0 then
    conLogF(puzzleHeader.." Continuing, time: "..string.format("%.2f", sessionDuration).."\n")
  else
    conLogF(puzzleHeader.." Started\n")
  end
  
  local waitDuration = puzzleTimeout - sessionDuration
  if not waitDuration or waitDuration<=0 then
    conWarningF(puzzleHeader.." Invalid puzzle median wait duration. puzzleMedianDuration="..(puzzleMedianDuration or "nil").." waitDuration="..(waitDuration or "nil").." \n")
    waitDuration = 3600  -- in case something is wrong with the calculation, the On(Delay()) below will not cause an error, but just wait for one hour
  end

  --print ("Entered puzzle: "..ePuzzleEntered:GetPuzzleName().." ("..ePuzzleEntered:GetTetrominoName()..") sessiontime: "..ePuzzleEntered:GetPuzzleSessionDuration().." median: "..ePuzzleEntered:GetMedianDuration().." mech: "..ePuzzleEntered:GetNeededMechanics())
  local elohimGaveTheGiveUpHint = false
  BreakableRunHandled(function()
    end,
    -- log puzzle exits/completion, and break out of the loop on those events
    On(CustomEvent("PuzzleExit")), function()
      conLogF(puzzleHeader.." Exited\n")
      -- award the achievement when player exits and elohim told him to give up
      if elohimGaveTheGiveUpHint then
        worldGlobals.worldInfo:AwardAchievementToAllPlayers("KnowYourLimits")
      end
      BreakRunHandled()
    end,
    On(CustomEvent("PuzzleSolved")), function()
      conLogF(puzzleHeader.." Solved\n")
      BreakRunHandled()
    end,
    -- heartbeat - uncomment for debugging
    --[[    OnEvery(Delay(1)), function()
      print("HB")
    end, --]]
    -- if the player has been trying to solve one puzzle for too long
    On(Delay(waitDuration)), function()
      -- if we didn't warn for not to try too much in this puzzle before
      local var = "TimeoutWarning_"..puzzleName
      local progress = nexGetTalosProgress(worldGlobals.worldInfo)
      if not progress:IsVarSet(var) then
        -- try to play one from the set of warnings
        if     worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-041_My_child_there_is_no_shame.ogg"), 0) then
          -- set that elohim told the player's he's stuck
          progress:SetVar("PM_HeardStuckNotification")
          elohimGaveTheGiveUpHint = true
        elseif worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-042_If_the_answer_does_not_come_to_you.ogg"), 0) then
          -- Unlock player message for Elohim telling you you're stuck 2 times
          talUnlockPlayerMessage(worldGlobals.worldInfo, prjTalosDefaultEpisodeID(worldGlobals.worldInfo), 500)
          elohimGaveTheGiveUpHint = true
        elseif worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-043_When_the_truth.ogg"), 0) then
          elohimGaveTheGiveUpHint = true
        elseif worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-044_If_this_trial_seems.ogg"), 0) then
          -- Unlock player message for Elohim telling you you're stuck 4 times
          talUnlockPlayerMessage(worldGlobals.worldInfo, prjTalosDefaultEpisodeID(worldGlobals.worldInfo), 501)
          elohimGaveTheGiveUpHint = true
        end
      end
    end
  )
end

table.insert(worldGlobals.worldFunctionsToExecute, function()
  local levelFileName = worldGlobals.worldInfo:GetWorldFileName() or ""
  worldGlobals.levelName = string.match(levelFileName, "([^/]+)%.[^%.]+$") or ""
  
  -- whenever a puzzle is entered, run a function on it to monitor for puzzle play time
  -- NOTE: This must be first, as the event is sent at the same time when player is born, if player spawns inside the puzzle.
  --   if we wait for PlayerBorn first, we miss this event.
  RunAsync(function()
    RunHandled(WaitForever,
      -- when player enters a puzzle
      OnEvery(CustomEvent("PuzzleEnter")), function(e) PuzzleWatcher(e) end
    )
  end)

  -- for the talos progress object to get initialized (NOTE: we also use the player event for the below parallel task)
  local eePlayerBorn = Wait(Event(worldGlobals.worldInfo.PlayerBorn))
  local progress = nexGetTalosProgress(worldGlobals.worldInfo)

  worldGlobals.storyFunctions.OnPlayerBorn(eePlayerBorn)
  
  -- find the terminal that is not overlay, not from Nexus floors, not from endings
  local terminals = worldGlobals.worldInfo:GetAllEntitiesOfClass("CComputerTerminalEntity")
  worldGlobals.miltonTerminals = NewGroupVar()
  for i,t in ipairs(terminals) do
    if not t:IsOverlayTerminal() and not string.match(t:GetName(), ".*Floor.*") and not string.match(t:GetName(), ".*Ending.*") then
      table.insert(worldGlobals.miltonTerminals, t)
    end
  end
  
  -- only if level was actually changed from one to another (i.e not when resuming a savegame, resetting, ...)
  if worldGlobals.levelChanged then
    -- check for new quotes and similar that happen on level change
    worldGlobals.storyFunctions.RecheckElohim_OnLevelChange()
  end

  -- recheck triggers on each world loading
  worldGlobals.storyFunctions.RecheckMiltonTriggers()
  
  -- for each milton terminal 
  for i, terminal in ipairs(worldGlobals.miltonTerminals) do
    RunAsync(function()
        -- when user exits the terminal 
      RunHandled(function() WaitForever() end,
        OnEvery(CustomEvent(terminal, "Started")), function()
          -- update variables to run the intro dialogs before first Milton starts
          RecheckMLAIntro_OnTerminalStart()
        end,
        OnEvery(CustomEvent(terminal, "Stopped")), function()
          -- recheck triggers (this should turn off the Eye of Milton, if done)
          worldGlobals.storyFunctions.RecheckMiltonTriggers()
        end
      )
    end)
    RunAsync(function() worldGlobals.storyFunctions.HandleTerminalEvents(terminal) end)
  end

  -- while the world is played....  
  RunHandled(function() WaitForever() end,

  -- when a tetromino is awarded
    OnEvery(CustomEvent("TetrominoAwarded")), function(e)
      conInfoF("Picked: "..e:GetTetromino() .. "\n")
      worldGlobals.storyFunctions.OnTetrominoAwarded(e)
      -- recheck triggers 
      worldGlobals.storyFunctions.RecheckMiltonTriggers()
      worldGlobals.storyFunctions.RecheckElohimTriggers(e)
    end,

    -- when a lock is solved
    OnEvery(CustomEvent("TetrominoLockSolved")), function(e)
      local progress = nexGetTalosProgress(worldGlobals.worldInfo)
      local strName = e:GetLock()
      local p = e:GetPlayer()
      -- print("TetrominoLockSolved "..strName)
      -- print("inventory: "..nexGetTalosProgress(p):GetInventoryTetrominoes())
      -- print("used: "..nexGetTalosProgress(p):GetUsedupTetrominoes())
      -- store that info into variables for easier querying later
      progress:SetVar("Unlocked_"..strName)
      -- if a Nexus lock was solved
      if string.match(strName, "^Nexus.$") then
        -- mark that the player has "been to the tower" so Milton can react to that
        progress:SetVar("Unlocked_AnyNexusDoor")
      end
    end,
    -- when player sees the help altar for the first time
    OnEvery(CustomEvent("HelpAltarSeen")), worldGlobals.storyFunctions.OnHelpAltarSeen,
    -- when player cannot use the help altar (no messengers unlocked)
    OnEvery(CustomEvent("HelpAltarUnavailable")), worldGlobals.storyFunctions.OnHelpAltarUnavailable
  )
  
end)

-- Requests an app review from the user after elohim stops talking
worldGlobals.RequestReviewWhenElohimFinishes = function()
  RunAsync(function()
    if worldGlobals.elohimSpeak == nil then
      return
    end
    Wait(Event(worldGlobals.elohimSpeak.Finished))
    Wait(Delay(2))
    sysRequestReview()
  end)
end
