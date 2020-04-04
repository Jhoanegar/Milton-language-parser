-- Part of this script controls whether Gates of Eternity are open
-- it should really be in a separate script, but it is hard to detach now without losing vars.

-- initially close the Gates of Eternity door
GatesOfEternityFlare:Deactivate()
SmokeParticles:Start()
Door:Lock()
OpenedHeavenDoorGlow:Disappear()
ClosedHeavenDoorGlow:Appear()
HeavenGatesLight:Deactivate()

RunHandled(
  function()
    WaitForever()
  end,
  OnEvery(Any(Event(worldInfo.PlayerBorn), CustomEvent("TetrominoAwarded"))), function(playerBornPayload)
    local ctAnimators = #LobyNumberAnimators
    for i=1, ctAnimators do
      local Animator = LobyNumberAnimators[i]
      -- Animator : CEventAnimatorEntity
      local Sign = LobyNumberSigns[i]
      -- Sign : CTetrominoSignEntity
      if(Sign:IsSolved()) then
        Animator:StartAnimation("Off")
      else
        Animator:StartAnimation("On")
      end
    end
    local progress = nexGetTalosProgress(worldGlobals.worldInfo)
    if progress:IsVarSet("GatesOfEternityOpened") then
      SignalEvent("GatesOfEternityOpened")
    end
  end,
  On(CustomEvent("GatesOfEternityOpened")), function()
    Door:AssureOpened()
    GatesOfEternityParticles:Start()
    GatesOfEternityFlare:Activate()
    SmokeParticles:Stop()
    ClosedHeavenDoorGlow:Disappear()
    OpenedHeavenDoorGlow:Appear()
    HeavenGatesLight:Activate()
  end
)