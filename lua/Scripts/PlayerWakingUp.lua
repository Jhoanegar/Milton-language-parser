WakingUpFlareAnimator:StartAnimation("Off")
--skip WakingUp in VR
if not CorIsAppVR() then
  
  local bornPlayer = nil
  local finished = false
  
  local function FinishAnim()
    if finished then
      return
    end
    finished = true
    if not IsDeleted(bornPlayer) and bornPlayer:IsAlive() then
      bornPlayer:SetFirstPersonAvatarMode(false);  
    end
    startChapter:Start()
    WakingUpFlareAnimator:StartAnimation("Off")  
  end
  
  local function HandleInterrupt()
    Wait(Event(bornPlayer.FirstPersonAvatarInterrupted))
    FinishAnim()
    WakingUpLightnessPPAnimator:Stop()
    WakingUpFXPPAnimator:Stop()
    WakingUpFlareAnimator:Stop()
  end
  
  RunHandled(WaitForever,
        
    On(Event(wakingUpChapter.Started)), function()
      -- playerBornPayload : CPlayerBornScriptEvent
      local playerBornPayload = Wait(Event(worldInfo.PlayerBorn))
  
      -- bornPlayer : CPlayerPuppetEntity
      bornPlayer = playerBornPayload:GetBornPlayer()
      WakingUpFlareAnimator:StartAnimation("On")
      RunAsync(HandleInterrupt)        
      WakingUpLightnessPPAnimator:StartAnimation("On")
      WakingUpFXPPAnimator:StartAnimation("On")
      bornPlayer:SetFirstPersonAvatarMode(true);
      WakingUpLightnessPPAnimator:StartAnimation("TurningOff")
      WakingUpFXPPAnimator:StartAnimation("TurningOff")
      RunAsync(function()
        Wait(Delay(12))
        if not finished then
          SoundJump:PlayOnce()
        end
      end)
      Wait(bornPlayer:PlayAnim("WakeUp"));
      FinishAnim()
    end
  )
else
  Wait(Event(wakingUpChapter.Started))
  --start chapter
  startChapter:Start()
end