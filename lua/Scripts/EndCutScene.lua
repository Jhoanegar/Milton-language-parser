--local fJumpForward = 162

local mainDelayer
ClothDesert:Hide()

local function FlyThroughWire(fDuration, bFadeIn, bFadeOut)
  SoundWireTravel:PlayLooping()
  if bFadeIn then
    FadeToWhite:StartAnimation("Off")
  end
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(fDuration-0.1-0.1))
    if bFadeOut then
      FadeToWhite:StartAnimation("TurningOn")
    end
  end)  
  if not CorIsAppVR() then
    Tube:NewClearState(0)
    Tube:AddAnim("ThroughTheWire", false, true, 4, 0.2)
  end
  CameraWire:PlayAnimWait("FlyTroughWire")
  Wait(mainDelayer:Delay(fDuration))  
  SoundWireTravel:Stop()
  CameraWire:Stop()
end

local function HallElectricity(strCameraAnimation)
  ElectricityParticles:Start()
  FakeGI:StartAnimation("TurningOff")
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(0.7))
    ElectricityClosetParticlse:Start()
    ElectricityClosetLight:StartAnimation("TurningOn")
  end)
  ImpulseAnimator:StartAnimation("TurningOn")
  LightMover:PlayAnim("Default")
  LightPulsator:StartAnimation("Pulsating")
  SoundElectricity:PlayLooping()
  
  if CorIsAppVR() then
    CameraHall:PlayAnimWait("Hall_VR") 
  else
    CameraHall:PlayAnimWait(strCameraAnimation)  
  end
  
  Wait(mainDelayer:Delay(1.6-0.1))
  SoundElectricity:Stop()
end

local function MeltingEgypt()
  ClothDesert:Show()
  RunAsync(function()
    SoundMeltdown:PlayOnce()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(2))
    SoundDistortion:PlayOnce()
    Wait(delayerLoc:Delay(2))
    Animator2:StartAnimation("TurningOn")
  end)
  
  EgyptMeltingParticles:Start()
  GroundEater:StartAnimation("TurningOn")
  BackgroundEater:StartAnimation("TurningOn")
  SoundMelting:PlayOnce()
  SoundMelting2:PlayOnce()
  SoundWind:PlayOnce()
  Mover1:PlayAnim("Default")
  Mover2:PlayAnim("Default")
  Mover3:PlayAnim("Default")
  Animator1:StartAnimation("TurningOn")
  
  if CorIsAppVR() then
    Camera:PlayAnimWait("Default_VR")
  else
    Camera:PlayAnimWait("Default")
  end
  
  Wait(mainDelayer:Delay(8.1-0.1)) 
  ClothDesert:Hide()
end

worldGlobals.CutScene(thisScript, Chapter, sndFX, sndVoice, function()
  
  StartPrecachingSequence(thisScript, tpsTexturePrecache)
  
  if CorIsAppVR() then
    --hide laser pointer
    CameraLaserPointer:DisableLeftHandLaserPointer()
    CameraLaserPointer:DisableRightHandLaserPointer()
    --hide fake background in VR
    Fake_background_tower_dissapear:Disappear()
    Fake_sky:Disappear()
    --deactivate flares
    FlaresToHide:Deactivate()
    FlareSurgeryLamp:Deactivate()
    PET_Flare_1:Deactivate()
    PET_Flare_2:Deactivate()
    Distant_city_background_flare:Deactivate()
  end  
  --EnableMovieExporting()
  --SetMovieSegmentDesc("EndOfGameCS")
  local Cameras = worldInfo:GetAllEntitiesOfClass("CAnimatedCameraEntity")
  local ctCameras = #Cameras
  for i=1, ctCameras do
    local CSCamera = Cameras[i]
    -- CSCamera : CAnimatedCameraEntity
    CSCamera:DisableUserBreak()
  end

  if scr_bUnsecureScripting then
    --sim_fJogForward = fJumpForward
  end
  
  -- restore terminal text to the setting from the end of Nexus level (stored in progress misc string)
  local progress = nexGetTalosProgress(worldInfo)
  Terminal:SetImmediateText(progress:GetMiscString())  
     
  -- appear objects used in cut scenes
  PetLightAnimator:StartAnimation("Off")
  Wire:Appear()
  if CorIsAppVR() then
    Tube_VR:Appear()
    Wire_VR:Appear()  
    Tube:Disappear()
    TravelTube:Disappear()
  else
    Tube:Appear()
    TravelTube:Appear()
    Tube_VR:Disappear()
    Wire_VR:Disappear()   
  end
  
  RobotOnATable:Appear()
  AnimatorDarkeness:StartAnimation("Off")
  FirstTwoReckAnimators:StartAnimation("Off")
  TurningOnRecks:StartAnimation("Off")
  ToolkitLightsAnimator:StartAnimation("Off")
  FaceSideSpotLightAnimator:StartAnimation("Off")
  TopSpotLight:Deactivate()
  WireSpotLight:Deactivate()
  LabWire2:Appear()
  FlarePulsator2:StartAnimation("Off")
  AnimatorTerminalLight:StartAnimation("Off")
  RobotEyeOpeningAnimator:StartAnimation("Off")
  FirstTwoRecksTurningOnLight:StartAnimation("Off")
  FirstIdleRecksSceneLight:StartAnimation("Off")  
  DataCenterWireFastLight:Deactivate()
  ShockwavePower:StartAnimation("Off")
  WireFastLight:Deactivate()

  -- wait all halt events cast by the terminals
  RunAsync(function()
    while true do
      Wait(CustomEvent(Terminal, "TerminalHaltEvent_1"))
    end
  end)
  
  -- racks in idle mode, only few lamps turned on
  FirstIdleRecksSceneLight:StartAnimation("On")
  if CorIsAppVR() then
    CameraTerminal:PlayAnimWait("TerminalScreen")
--    CameraDataCenterPieceful:PlayAnimWait("Default_VR")
  else
    CameraDataCenterIdle:PlayAnimWait("DataCenterIdle")
  end
  mainDelayer = scrCreatePreciseDelayer() 
  Wait(mainDelayer:Delay(6.1-0.1))
  Terminal:AddTerminalText("Ending_Tower_Upload_part2")
  FirstIdleRecksSceneLight:StartAnimation("Off")  
  
  -- terminal: waking up mainframe
  if not CorIsAppVR() then
    AnimatorDarkeness:StartAnimation("TurningOff1")
    CameraTerminal:PlayAnimWait("TerminalScreen")
  end
  Terminal:ResumeHalted()
  Wait(mainDelayer:Delay(4.0)) 
  AnimatorDarkeness:StartAnimation("TurningOn2")
  Wait(mainDelayer:Delay(2.0))
  AnimatorDarkeness:StartAnimation("Off")
  
  -- data center two racks waking up
  FirstTwoRecksTurningOnLight:StartAnimation("On")
  CameraTerminal:Stop()
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(1.0)) 
    ReckAnimator:StartAnimation("TurningOn")
    RunAsync(function()
      local delayerLoc = scrCreatePreciseDelayer() 
      Wait(delayerLoc:Delay(3.0))
      FastLightReckAnimator1:StartAnimation("On")
    end)
    Wait(delayerLoc:Delay(4.6)) 
    ReckAnimators2:StartAnimation("On")
  end)
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(1.1))
    SoundWakingUp:PlayOnce()
  end)
  
  if CorIsAppVR() then
    CameraDataCenterPieceful:PlayAnimWait("Default_VR")
  else
    CameraDataCenterPieceful:PlayAnimWait("Default")
  end
  
  Wait(mainDelayer:Delay(6.1-0.1))
  FirstTwoRecksTurningOnLight:StartAnimation("Off")
  
  -- data center rack array turning on
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(0.4)) 
    local ctRecks = #TurningOnRecks
    for i=ctRecks,1,-1 do
      local ReckToTurnOn = TurningOnRecks[i]
      ReckToTurnOn:StartAnimation("On")
      local SoundOfReckTurningOn = ReckTurnOnSounds[i]
      SoundOfReckTurningOn:PlayOnce()
      local fDelay = mthClampDnF(mthPowAF(i,1.5)*0.0095, 0.2)
      Wait(delayerLoc:Delay(fDelay)) 
    end
  end)
  if CorIsAppVR() then
    CameraDataCenterPieceful:Stop() --stop current animation.
    CameraDataCenterPieceful:PlayAnimWait("Default_VR")
  else
    CameraDataCenter:PlayAnimWait("IAN")
  end
  Wait(mainDelayer:Delay(7.1-0.1))
  
  -- "jump" into terminal
  if CorIsAppVR() then
    CameraTerminal:PlayAnimWait("TerminalScreen_VR")  
  else
    CameraTerminal:PlayAnimWait("TerminalScreen")  
  end

  Terminal:ResumeHalted()
  RunAsync(function()
    SoundBuildup:PlayOnce()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(3))
    UploadShaker:StartShaking()
  end)
  Wait(mainDelayer:Delay(3))
  --stop terminal camera
  if not CorIsAppVR() then
    CameraTerminal:Stop()
  end
  SoundUploading:PlayOnce()
  --start terminal camera
  if not CorIsAppVR() then
    CameraTerminal:PlayAnimWait("TerminalScreen")
  end
  
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(2.3))
    Particles:Start()
  end)
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(2.0))
    Refractor:Appear()
    RefractionPowerAnimator:StartAnimation("TurningOn")
  end)
  --skip "Upload" camera anim on VR
  if not CorIsAppVR() then 
  CameraTerminal:Stop()
  CameraTerminal:PlayAnimWait("StartingToUpload")
  end
  
  Wait(mainDelayer:Delay(3.1-0.1))
  
  -- 1st person wire
  FlyThroughWire(1.5, false, true)
  Terminal:ClearTexts()

  -- data center, electricity traveling on the floor
  DataCenterElectricityImpulseAnimator:StartAnimation("TurningOn")
  ElectricityWireParticles:Start()
  ElectricityMover:PlayAnim("Default")
  SoundOfElectricity:PlayLooping()
  DataCenterWireFastLight:Activate()
  if CorIsAppVR() then
    CameraDataCenterPieceful:PlayAnimWait("Default_VR")
  else
    CameraDataCenter:PlayAnimWait("Recks2")
  end
  Wait(mainDelayer:Delay(1.8-0.1))
  DataCenterWireFastLight:Deactivate()
  ElectricityWireParticles:Stop()
  SoundOfElectricity:Stop()
  
  -- toolkit and hand
  RunAsync(function()
    Wait(Delay(2.0))
    LCDDisplay:AddTerminalText("Ending_Tower_Downloading_Parameters")
  end)
  ToolkitLightsAnimator:StartAnimation("On")
  if CorIsAppVR() then
    CameraToolkitAndHand:PlayAnimWait("Toolkit_VR")
  else
    CameraToolkitAndHand:PlayAnimWait("Toolkit")
  end

  Wait(mainDelayer:Delay(10.1-0.1))
  ToolkitLightsAnimator:StartAnimation("Off")
  
  -- 1st person wire
  FlyThroughWire(2, true, true)

  -- hall - away from user, electricity traveling
  HallElectricity("Hall")
  
  -- lab reveal
  TopSpotLight:Activate()
  if CorIsAppVR() then
    CameraToolkitAndHand:Stop()
    CameraToolkitAndHand:PlayAnimWait("Toolkit2_VR")
  else
    CameraRobotReveal2:PlayAnimWait("LeftHandPivot2")   
  end
  Wait(mainDelayer:Delay(11.1-0.1))
  TopSpotLight:Deactivate()
  
  -- 1st person wire
  FlyThroughWire(1, true, true)

  -- electricity traveling trough hall from left to right
  HallElectricity("Hall2b")
  
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(8.0))
    FlarePulsator2:StartAnimation("Pulsating")
    LabWireImpulseMover2:StartAnimation("TurningOn")
    ElectricitySound2:PlayLooping()
    ElectricityLabWireParticles2:Start()
    ElectricityLabMover2:PlayAnim("LabWire")
    WireFastLight:Activate()
    Wait(delayerLoc:Delay(2.5))
    WireFastLight:Deactivate()
    FlarePulsator2:StartAnimation("Off")
    LabWireImpulseMover2:StartAnimation("Off")
    ElectricityLabWireParticles2:Stop()
    ElectricitySound2:Stop()
    SoundTerminalTurningOn:PlayOnce()
    AnimatorTerminalLight:StartAnimation("On")
    LabTerminal:AddTerminalText("Ending_Tower_Upload_OverScreen_part1")
  end)  
  
  -- lab terminal booting up
  WireSpotLight:Activate()
  if CorIsAppVR() then
    CameraLabTerminalReveal:PlayAnimWait("TeminalReveal_VR")
  else
    CameraLabTerminalReveal:PlayAnimWait("TeminalReveal")  
  end

  Wait(mainDelayer:Delay(22.5))
  AnimatorTerminalLight:StartAnimation("Off")
  
  -- destruction Medieval
  OverlayTerminal:EnableOverlayRendering(true)
  OverlayTerminal:AddTerminalText("Ending_Tower_Upload_OverScreen_part2")
  worldGlobals.MedievalMeltdown(mainDelayer)

  -- tower destruction
  worldGlobals.TowerCollapse(mainDelayer)

  -- destruction Egypt
  MeltingEgypt()
  
  -- tower eating. Have a nice day.
  TowerEaterAnimator:StartAnimation("TowerDissapeear")
  TowerEaterMover:PlayAnim("Default")
  RunAsync(function()
    EatingParticles:Start()
    Wait(Delay(3))
    RefractionParticles:Stop()
    Wait(Delay(9))
    OverlayTerminal:FadeOutText(3)
  end)
  RunAsync(function()
    EatingSound:PlayOnce()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(1.7))
    DustParticles:Start()
    ShockwaveParticles:Start()
    ShockwaveRefractionMover:PlayAnim("Default")
    ShockwavePower:StartAnimation("TurningOn")
    Wait(delayerLoc:Delay(1.0))
    ShockwaveDust:Start()
    Wait(delayerLoc:Delay(0.1))
    ShockwaveShaker:StartShaking()
   end)
  if CorIsAppVR() then
    CameraTowerEater:PlayAnimWait("TowerEating_VR")   
  else
    CameraTowerEater:PlayAnimWait("TowerEating")   
  end

  Wait(mainDelayer:Delay(16.1-0.1))
  OverlayTerminal:ClearTexts()
  OverlayTerminal:EnableOverlayRendering(false)

  -- black screen
  CameraBlackScreen:PlayAnimWait("Default")
  Wait(mainDelayer:Delay(2.0))
  
  -- robot opening the eyes
  RobotOnATable:Disappear()
  RobotHead:Appear()
  
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(6))
    SoundEyesOpening:PlayOnce()
    RobotEyeOpeningAnimator:StartAnimation("TurningOn")
    Wait(delayerLoc:Delay(1))
    RobotHead:NewClonedState(0)  
    RobotHead:AddAnimation("ShutterOpening", false, false, 4, 1)
    IrisIlluminationAnimator:StartAnimation("TurningOn")
    SoundIrisOpening:PlayOnce()
    
    Wait(delayerLoc:Delay(0.25))
    IrisAnimator1:StartAnimation("Rotate1")
    IrisAnimator2:StartAnimation("Rotate2")
    
    Wait(delayerLoc:Delay(1))
    RobotHead:NewClonedState(0.1)
    RobotHead:AddAnimation("Eyes_Left", false, false, 1, 1)
    
    Wait(delayerLoc:Delay(1))
    RobotHead:NewClonedState(0.2)
    RobotHead:AddAnimation("Eyes_Right", false, false, 1, 0.75)
        
  end)

  if CorIsAppVR() then
    CameraToolkitAndHand:Stop()
    CameraToolkitAndHand:PlayAnimWait("Toolkit3_VR")
  else
    FaceSideSpotLightAnimator:StartAnimation("On")
    CameraRobotOpeningEyes:PlayAnimWait("EyesOpening")  
  end

  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(2.0))
    EyesOpeningTerminal:EnableOverlayRendering(true)
    EyesOpeningTerminal:AddTerminalText("Ending_Tower_Eyes_Opening")
    end)
  Wait(mainDelayer:Delay(10.1-0.1))

  RobotOnATable:Appear()
  RobotHead:Disappear()

  FaceSideSpotLightAnimator:StartAnimation("Off")
  if not CorIsAppVR() then
    RobotEyeOpeningAnimator:StartAnimation("Off")
  end

  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(5.5))
    PetLightAnimator:StartAnimation("TurningOn")
    AnimatorEarsIllumination:StartAnimation("On")
    PETTurningOnParticles:Start()
  end)
  
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(5.5))
    TurningOnPET:PlayOnce()
  end)
  
  RunAsync(function()
    Wait(Delay(3.0))
    RobotOnATable:NewClonedState(0.05)
    RobotOnATable:AddAnimation("L_Index_Twitch", false, false, 1, 0.2)
    RobotOnATable:AddAnimation("L_Middle_Twitch", false, false, 1, 0.05)
    Wait(Delay(0.05))
    RobotOnATable:NewClonedState(0.4)
    RobotOnATable:RemoveAnimation("L_Index_Twitch")
    RobotOnATable:RemoveAnimation("L_Middle_Twitch")
    Wait(Delay(1))
    RobotOnATable:NewClonedState(0.05)
    RobotOnATable:AddAnimation("L_Index_Twitch", false, false, 1, 0.3)
    RobotOnATable:AddAnimation("L_Middle_Twitch", false, false, 1, 0.1)
    Wait(Delay(0.1))
    RobotOnATable:NewClonedState(0.2)
    RobotOnATable:RemoveAnimation("L_Index_Twitch")
    RobotOnATable:RemoveAnimation("L_Middle_Twitch")
    Wait(Delay(0.25))
    RobotOnATable:NewClonedState(0.05)
    RobotOnATable:RemoveAnimation("L_Index_Twitch")
    RobotOnATable:RemoveAnimation("L_Middle_Twitch")
    RobotOnATable:AddAnimation("L_Index_Twitch", false, false, 1, 0.4)
    RobotOnATable:AddAnimation("L_Middle_Twitch", false, false, 1, 0.2)
    Wait(Delay(0.05))
    RobotOnATable:NewClonedState(0.5)
    RobotOnATable:RemoveAnimation("L_Index_Twitch")
    RobotOnATable:RemoveAnimation("L_Middle_Twitch")
    Wait(Delay(1))
    RobotOnATable:NewClonedState(0.6)
    RobotOnATable:AddAnimation("L_Index_Twitch", false, false, 1, 0.8)
    RobotOnATable:AddAnimation("L_Middle_Twitch", false, false, 1, 0.7)
    RobotOnATable:AddAnimation("L_Ringer_Twitch", false, false, 1, 0.6)
    RobotOnATable:AddAnimation("L_Pinky_Twitch", false, false, 1, 0.5) 
    Wait(Delay(1.4))
    RobotOnATable:NewClonedState(1.2)
    RobotOnATable:RemoveAnimation("L_Index_Twitch")
    RobotOnATable:RemoveAnimation("L_Middle_Twitch")
    RobotOnATable:RemoveAnimation("L_Ringer_Twitch")
    RobotOnATable:RemoveAnimation("L_Pinky_Twitch")       
  end)
  if not CorIsAppVR() then
    CameraPETLight:PlayAnimWait("PETLight")
  end
  Wait(mainDelayer:Delay(10.1-0.1))
  EyesOpeningTerminal:EnableOverlayRendering(false)
  PETTurningOnParticles:Stop()
  --now disable fake eye spotlight in VR to hide "light" mismatch.
  if CorIsAppVR() then
    RobotEyeOpeningAnimator:StartAnimation("Off")
  end  
  
  -- sitting up
  if not CorIsAppVR() then
    FlareSurgeryLamp:Activate()
  end
  RunAsync(function()
    local delayerLoc = scrCreatePreciseDelayer() 
    Wait(delayerLoc:Delay(5.0))
    RobotOnATable:NewClearState(0)
    RobotOnATable:AddAnimation("SitUp_EndScene", false, false, 1, 1)
    Wait(delayerLoc:Delay(4.0))
    RobotOnATable:NewClearState(0)
    RobotOnATable:AddAnimation("SitUp_LookLeft", false, false, 0.6, 1)
  end)
  PETParticles:Stop()
  if not CorIsAppVR() then
    CameraWakeUp:PlayAnimWait("WakeUpV4")  
  end
  Wait(mainDelayer:Delay(12.1-0.1))
  FlareSurgeryLamp:Deactivate()  
  -- see if cat has been freed
  local progress = nexGetTalosProgress(worldInfo)
  local bHasCat = progress:IsVarSet("KittenFree")
        
  --skip sit down in VR
  if not CorIsAppVR() then
    -- getting down from the table
    RobotOnATable:NewClearState(0)
    RobotOnATable:AddAnimation("SitDown", false, false, .3, 1)
    CameraWakeUp:Stop()
    CameraWakeUp:PlayAnimWait("SitDown")  

    Wait(mainDelayer:Delay(8.1-0.1))
    
    -- walking away from the table
    RunAsync(function()
      Wait(Delay(5))
      if bHasCat then
        SoundKittenMeow:PlayOnce()
      end
    end)
    
    RobotOnATable:Disappear()  
    RobotLabWalking:Appear()
    RobotLabWalking:NewClearState(0)
    RobotLabWalking:AddAnimation("Walk_SS3", true, false, .5, 1)
    LabWalkAnimator:PlayAnim("RobotLabWalk")
    CameraLabWalk:PlayAnimWait("RobotLabWalkV2")
    if bHasCat then
      LabCatMover:PlayAnim("LabCat")
      LabCat:Appear()
      LabCat:NewClearState(0)
      LabCat:AddAnimation("Cat_Walk_01", true, false, 1, 1)
    end
    Wait(mainDelayer:Delay(6.1-0.1))
  end
  -- opening the door
  DoorSpotlightAnimator:StartAnimation("TurningOn")
  RobotOpeningDoor:Appear()
  RobotOpeningDoor:NewClearState(0)

  if bHasCat then
    RobotOpeningDoor:AddAnimation("Walk_With_Cat_02", true, false, .35, 1)
    RobotOpeningDoor:ShowAttachment("Cat")
  else 
    RobotOpeningDoor:AddAnimation("Walk_SS3", true, false, .35, 1)
  end
  
  RobotOpeningDoorMover:PlayAnim("TroughTheDoorNew")
  Door:Appear()
  Door:NewClearState(0)
  Door:AddAnimation("OpenLastCS", false, false, 1, 1)
  if CorIsAppVR() then
    CameraOpenDoors:PlayAnimWait("OpeningDoors_VR")
  else
    CameraOpenDoors:PlayAnimWait("OpeningDoors")
  end
  --this is last scene in VR, wait 5 extra seconds for fade.
  if CorIsAppVR() then
    Wait(mainDelayer:Delay(12.1-0.1))  
  else
    Wait(mainDelayer:Delay(7.1-0.1))  
  end

  
  --skip dam scene in VR
  if not CorIsAppVR() then
    -- dam
    RobotDamMover:PlayAnim("Dam")
    RunAsync(function() 
      RobotDam:Appear()
      RobotDam:NewClearState(0)
      if bHasCat then
        RobotDam:AddAnimation("Walk_With_Cat_02", true, false, .5, 1)
        RobotDam:ShowAttachment("Cat")
        local delayerLoc = scrCreatePreciseDelayer() 
        Wait(Delay(10.0))
        RobotDam:NewClonedState(2.0)
        RobotDam:AddAnimation("LookingAround01", false, false, 1, 0.8)
        Wait(Delay(6))
        RobotDam:NewClonedState(1.0)
        RobotDam:RemoveAnimation("Walk_With_Cat_02")
        RobotDam:RemoveAnimation("LookingAround01")
        RobotDam:AddAnimation("IdleWithCat", true, false, 1, 1)
        RobotDam:AddAnimation("LookingAround02", false, false, 1, 0.8)
      else
        RobotDam:AddAnimation("Walk_SS3", true, false, .5, 1)
        local delayerLoc = scrCreatePreciseDelayer() 
        Wait(Delay(10.0))
        RobotDam:NewClonedState(2.0)
        RobotDam:AddAnimation("LookingAround01", false, false, 1, 0.8)
        Wait(Delay(6))
        RobotDam:NewClonedState(1.0)
        RobotDam:RemoveAnimation("Walk_SS3")
        RobotDam:RemoveAnimation("LookingAround01")
        RobotDam:AddAnimation("Idle", true, false, 1, 1)
        RobotDam:AddAnimation("IdleToGrabFence_Pose2", false, false, 1, 1)
        RobotDam:AddAnimation("LookingAround02", false, false, 1, 0.8)
      end
    end)
      CameraDam:PlayAnimWait("Dam")
      Wait(mainDelayer:Delay(50.1-0.1))    
  end
  
  RunAsync(function() 
    if CorIsAppVR() then
      Wait(Delay(50))
    end
    Wait(Delay(5))
    MusicEndCredits:PlayLooping()
  end)
  -- distant city
  terminalCredits:EnableOverlayRendering(true)
  terminalCredits:AddTerminalText("crPrintAll")
  RunAsync(function() 
    Wait(CustomEvent(terminalCredits, "TerminalEvent_2"))
    terminalCredits:EnableOverlayRendering(false)
  end)
  
  -- one last review request
  sysRequestReview()
    
  if CorIsAppVR() then
    CameraDistantCity:PlayAnimWait("DistantCity_VR")    
  else
    CameraDistantCity:PlayAnimWait("DistantCity")
  end


  Wait(mainDelayer:Delay(242))
  -- play the eye animation in case we internalized Milton
  if progress ~= nil and progress:IsVarSet("MiltonInternalisedFlag") then
    RunAsync(function()
      Wait(Delay(1.0))
      terminalCredits:EnableASCIIAnimation(true)
      terminalCredits:EnableOverlayRendering(true)
      Wait(Delay(5))
      terminalCredits:EnableASCIIAnimation(false)
      terminalCredits:EnableOverlayRendering(false)
    end)
  end
  
  local fDuration = 8
  for i=1,10*fDuration do
    Wait(Delay(0.1))
    MusicEndCredits:SetVolume(1.0-i/(10*fDuration))
  end
  Wait(Delay(2.0))
end)
EndGameChapter:Start()