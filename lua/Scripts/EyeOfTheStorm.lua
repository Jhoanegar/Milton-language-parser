StormPowerAnimator:StartAnimation("Off")
--EyeOfTheStormModels:Disappear()
Wait(Event(PlasmaBarrier_BossStart.BarrierPassed))
--EyeOfTheStormModels:Appear()
EyeOfTheStormParticles:Start()
GarbageParticles:Start()
EyeOfTheStormSounds:PlayLoopingFadeIn(4)
penKiller:SetActive(true)
EyeOfTheStormMover:PlayAnim("Default")
StormPowerAnimator:StartAnimation("TurningOn")

local FlyingModel
local iCurentSound = 1
local bWaitBefore = false

local function AssignQV(qv1, qv2)
  qv1.vx = qv2.vx
  qv1.vy = qv2.vy
  qv1.vz = qv2.vz
  qv1.qh = qv2.qh
  qv1.qp = qv2.qp
  qv1.qb = qv2.qb
end 

local function Rnd(fMin, fMax)
  return fMin+mthRndF()*(fMax-fMin)
end 

local function PlateFlyAway()

  -- get plate placement
  if bWaitBefore then
    Wait(Delay(0.5))
  end

  -- penPlate : CStaticModelEntity
  local penPlate = FlyingModel
  local qvOrg = penPlate:GetPlacement()

  -- play shake/flyaway sound
  local penNextSound = FlyAwaySounds[iCurentSound]
  -- penNextSound : CStaticSoundEntity
  penNextSound:SetPlacement(qvOrg)
  penNextSound:PlayOnce()
  iCurentSound = iCurentSound+1
  if iCurentSound == #FlyAwaySounds+1 then
    iCurentSound = 1
  end
  
  local penDirectionMarker = GetClosestEntity(penPlate, "CPathMarkerEntity", 3)
  local tmStart = worldInfo:GetTimePassedFromTimer() 
  local qvNow = qvOrg
  local fOrgX = qvOrg.vx
  local fOrgY = qvOrg.vy
  local fOrgZ = qvOrg.vz
  local fOrgH = qvOrg.qh
  local fOrgP = qvOrg.qp
  local fOrgB = qvOrg.qb
  local vMoveSpeed = mthVector3f(10.0+mthRndF()*5, 50+mthAbsF(mthRndF())*20, 10.0+mthRndF()*5)
  if penDirectionMarker~=nil then
    local qvDirection = penDirectionMarker:GetPlacement()
    local vEuler = mthVector3f(qvDirection.qh, qvDirection.qp, qvDirection.qb)
    local vFront = mthEulerToDirectionVector(vEuler)
    vMoveSpeed.x = vFront.x*100
    vMoveSpeed.z = vFront.z*100
  end
  local vRotSpeed = mthVector3f(
    mthDegToRad(mthRndF()*60),
    mthDegToRad(1800+mthAbsF(mthRndF())*180),
    mthDegToRad(900+mthAbsF(mthRndF()*120)))
  local fTime = 0
  local fFlayAwayDelay = 1.1
  while fTime<5 do
    Wait(Delay(0.01))
    fTime = worldInfo:GetTimePassedFromTimer()-tmStart
    local fShake = mthClampF(mthPowAF(fTime,2), 0, 1)
    local fFlyAwayLinear = mthClampF(fTime-fFlayAwayDelay, 0, 100000)
    local fFlyAwayPow = mthPowAF(fFlyAwayLinear,2)
    qvNow.vx = fOrgX+vMoveSpeed.x*fFlyAwayPow
    qvNow.vy = fOrgY+vMoveSpeed.y*fFlyAwayLinear+fShake*0.1
    qvNow.vz = fOrgZ+vMoveSpeed.z*fFlyAwayPow
    -- non linear time speedup
    qvNow.qh = fOrgH+vRotSpeed.x*fFlyAwayLinear
    qvNow.qp = fOrgP+mthDegToRad(mthSinF(fTime*40)*5*fShake)+vRotSpeed.y*fFlyAwayLinear
    qvNow.qb = fOrgB+mthDegToRad(mthSinF(fTime*60)*3*fShake)+vRotSpeed.z*fFlyAwayLinear
    penPlate:SetPlacement(qvNow)
  end
  penPlate:ApplyDamageTool("", "Explosion", "", "", 10000) 
end

RunAsync(function()
  local ctSounds = #Sounds
  while true do
    for i=1, ctSounds do
      local fRndDelay = 0.1+mthRndF()*0.4
      Wait(Delay(fRndDelay))
      if mthRndF()>0.3 then
        -- Sound : CStaticSoundEntity
        local Sound = Sounds[i]
        Sound:SetVolume(0.5+mthRndF(0.5))
        Sound:PlayOnce()
      end
    end
  end
end)

worldInfo:ActivateTimer(1000000)
local ctModels = #FlyingModels

RunHandled(
  WaitForever,
  OnEvery(Event(Glither.Glitch)),
    function(eGlitch)
      -- eGlitch : CGlitchScriptEvent
      local penGlitchMdl = eGlitch:GetGlitchTarget()
      if penGlitchMdl ~= nil then
        -- deduce how far we are from the killer plane
        local penPlayer = worldInfo:GetClosestPlayer(bossPuzzleStart, 1000000)
        -- penPlayer : CPlayerPuppetEntity
        local qvPlayer = penPlayer:GetPlacement()
        local qvKiller = penKiller:GetPlacement()
        local fKillDistance = mthAbsF(qvPlayer.vy-qvKiller.vy)
        -- select if we will fly off the plate
        local fFlyOffChance = mthClampF(fKillDistance-5, 0, 100000)/15
        if mthRndF()>fFlyOffChance then
          -- apply plate flyoff
          FlyingModel = penGlitchMdl
          bWaitBefore = true
          RunAsync(PlateFlyAway)
        end
        -- calculate delay to the next glitch
        local fMinGlitchDelay = mthClampF(fKillDistance-5, 0, 100000)/15
        Glither:SetNextGlitchWaitPeriod(fMinGlitchDelay, fMinGlitchDelay*1.25)
      end
    end,
    On(CustomEvent("DestroyingSimulation")),
    function()
      CameraSimlationDistroyed:PlayAnimWait("DestroyingSimulation")
      MetalBending:PlayOnce()
      EyeOfTheStormSounds:PlayLooping()
      EyeOfTheStormMover:PlayAnim("DestroyingSimulation")
      SimulationDestructionParticles:Start()
      for i,p in ipairs(EOSFlyingModels) do
        FlyingModel = p
        bWaitBefore = false
        RunAsync(PlateFlyAway)
        Wait(Delay(0.05+mthRndF(0.0125)))
      end
  end
)
