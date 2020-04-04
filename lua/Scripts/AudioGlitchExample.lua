--sfx_fAttenuationByVoiceOver=0.05
assert(compositeEntity ~= nil)
assert(compositeEntity.OnActivated ~= nil)

local function HideAudioLog()
  Chair:Disappear()
  Detector:Deactivate()
  Wait(Delay(0.1))
  soundGlitch:Stop()
  particlesGlitch:Terminate()
  lightGlitch:Deactivate()
end

local function ShowAudioLog()
  Detector:EnableTouchAutoMoveTarget(true);
  -- the glitch sound plays all the time, but has limited range, so you can hear it when you get near, before touching
  soundGlitch:PlayLooping()
  Chair:Appear()
  soundGlitch:PlayLooping()
  particlesGlitch:Start()
  lightGlitch:Activate()
end

-- Wait and print a message if voiceover is currently prevented
local function WaitIfVoiceoverPrevented()
  if overlayTerminal:VoiceoverPrevented() then
    overlayTerminal:AddTerminalText("AudioLog_Paused")
    while overlayTerminal:VoiceoverPrevented() do
      Wait(Delay(1))
    end
    overlayTerminal:ClearTexts()
  end
end

local function DisplayOverlayText(filename)
  local terminalval = filename:gsub("[^%w]", "_");
  print("overlay text", terminalval)
  overlayTerminal:ClearTexts()
  overlayTerminal:EnableOverlayRendering(true)
  -- wait if voiceover is currently prevented
  WaitIfVoiceoverPrevented()
  -- show overlay text for the audio log
  overlayTerminal:AddTerminalText(terminalval)

  -- clear text when terminal is done typing or if voiceover is stopped
  RunAsync(function()
    local journal = worldGlobals.worldInfo:GetJournalTerminal()
    RunHandled(function() WaitForever() end,
      -- overlay message should hide
      On(CustomEvent(overlayTerminal, "TerminalEvent_1")), function()
        overlayTerminal:ClearTexts()
      end,
      -- voiceover sound has finished playing
      On(Event(journal.VoiceoverFinished)), function()
        -- notify the player if voiceover was prevented
        if overlayTerminal:VoiceoverPrevented() then
          overlayTerminal:ClearTexts()
          overlayTerminal:EnableOverlayRendering(true)
          overlayTerminal:AddTerminalText("AudioLog_Interrupted")
          Wait(CustomEvent(overlayTerminal, "TerminalEvent_2"))
        end
        -- disable overlay
        overlayTerminal:ClearTexts()
        overlayTerminal:EnableOverlayRendering(false)
      end
    )
  end)
end

if compositeEntity:AudioLogHeard() then
  Chair:Disappear()
  lightGlitch:Deactivate()
  Detector:Deactivate()
else
  ShowAudioLog()
  while true do
    Wait(Event(Detector.Activated))
    -- play the audio log sound and note when it has finished
    RunAsync(function()
      -- notify the audio log entity that it got activated
      compositeEntity:OnActivated()
      local filepath = compositeEntity:GetAudioLogFilePath()
      local filename = string.match(filepath, "([^/%.]+)%.[^/%.]+$")
      conLogF("Listened to audiolog: "..filename.."\n")
      DisplayOverlayText(filename)
      -- play the log using the journal terminal so it doesn't interfere with journal log playback
      local journal = worldGlobals.worldInfo:GetJournalTerminal()
      journal:RequestVoiceoverPlayback(filepath);
      Wait(Event(journal.VoiceoverFinished))
      
      -- notify the audio log entity whether audio log finished playing
      compositeEntity:OnFinishedPlaying()
    end)
    HideAudioLog()
    break
  end
end