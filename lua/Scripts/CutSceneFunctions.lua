local function CutScene_internal(scriptEntity, chapter, sfx, vox, syncSounds, cutscenefunction)
  assert(scriptEntity~=nil)
  assert(chapter~=nil)
  assert(sfx~=nil)
  assert(vox~=nil)
  assert(type(syncSounds) == "boolean")
  assert(type(cutscenefunction)=="function")
  -- if using version where form of function was: chapter, sfx, vox, cutscenefunction
  if cutscenefunction == nil and type(vox) == "function" then
    cutscenefunction = vox
    vox = sfx
    sfx = chapter
    chapter = scriptEntity
    scriptEntity = nil
  -- else, if version where form of function was: chapter, cutscenefunction
  elseif sfx == nil and vox == nil and cutscenefunction == nil and type(chapter) == "function" then
    cutscenefunction = chapter
    chapter = scriptEntity
    scriptEntity = nil
  end
   
  -- wait until the referent chapter is started but only on host
  -- on remote script will be started when cut scene is started
  if worldGlobals.netIsHost then
    Wait(Event(chapter.Started))
    -- If chapter should trigger auto save, we need to
    -- wait until next frame in order to allow save game
    -- to be performed prior to cut scene start. (Looks better than
    -- seing first cut scene frame blocked for a while.)
    if chapter:ShouldTriggerAutoSave() then
      print("Delaying cut scene since chapter triggers auto save")
      Wait(Delay(0.00001))
    end
  end
  
  -- if in testing mode (unsecure scripting enabled and forcing start from that chapter)
  local chapterName = chapter:GetName()
  function worldGlobals.JogStart()
    if scr_bUnsecureScripting and wld_strPreferredStartChapter == chapterName then
      -- start jogging
      RunAsync(function()
        sim_fJogForward = fTime or 10000
        ren_iRenderingMode = "RSM_NONE"
        -- wait until jogging should be stopped
        Wait(Any(Delay(sim_fJogForward), CustomEvent(worldGlobals.worldInfo, "ScriptStopJogging")))
        -- stop jogging
        sim_fJogForward=0
        ren_iRenderingMode="RSM_NORMAL" 
      end)
    end
  end
  -- declare function that cutscene can call when it wants jogging to end
  function worldGlobals.JogStop()
    SignalEvent(worldGlobals.worldInfo, "ScriptStopJogging")
  end
  
  print("Starting cutscene "..chapterName)
  
  -- begin registering entities for cutscene
  local controller = worldGlobals.worldInfo:GetCutSceneController(); -- controller : CCutSceneController
  controller:BeginCutScene(sfx, vox, syncSounds, scriptEntity)

  worldGlobals.worldInfo:StopDynamicMusics()
  if corIsAppEditor() then EnableMovieExporting() end

  -- run the cutscene in breakable mode
  BreakableRunHandled(cutscenefunction,
  -- when any of started cameras is interrupted
  On(Event(controller.UserBreak)), function()
    -- break the cutscene
    BreakRunHandled()
  end)
  
  if corIsAppEditor() then StopMovieExporting() end
  worldGlobals.worldInfo:StartDynamicMusics()

  -- make sure all registered entities are cleaned up
  controller:EndCutScene()
  
  print("Finished cutscene "..chapterName)
end

function worldGlobals.CutScene(scriptEntity, chapter, sfx, vox, cutscenefunction)
  CutScene_internal(scriptEntity, chapter, sfx, vox, true, cutscenefunction)
end

function worldGlobals.CutScene_NoSoundSync(scriptEntity, chapter, sfx, vox, cutscenefunction)
  CutScene_internal(scriptEntity, chapter, sfx, vox, false, cutscenefunction)
end
