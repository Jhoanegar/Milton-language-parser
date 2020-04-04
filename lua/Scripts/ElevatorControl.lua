-- no need to create the elevator control function if already created
if worldGlobals.ElevatorControl ~= nil then
  return
end

-- performs all elevator control tasks for given elevator control setup table
function worldGlobals.ElevatorControl(ec)
  assert(ec.numberOfLevels > 1)
  assert(#ec.buttons == ec.numberOfLevels)
  assert(ec.buttonNumbers == nil or #ec.buttonNumbers == ec.numberOfLevels)
  assert(ec.buttonNumbers == nil or type(ec.generateButtonNumbersFunc) == "function")
  assert(#ec.callButtons == ec.numberOfLevels)
  assert(#ec.chaptersOnLevels == ec.numberOfLevels)
  assert(#ec.levelElevatorStartingChapters == ec.numberOfLevels)
  assert(ec.elevator ~= nil)
  assert(#ec.entrances == ec.numberOfLevels)
  assert(ec.callMarkers == nil or #ec.callMarkers == ec.numberOfLevels)
  assert(#ec.levelMarkers == ec.numberOfLevels)
  assert(#ec.doorSound ~= nil)  
  assert(ec.buttonLights == nil or #ec.buttonLights == ec.numberOfLevels)
  assert(ec.callButtonLights == nil or #ec.callButtonLights == ec.numberOfLevels)

  local elevatorBusy = false
  -- sets up available buttons and enables/disables them as necessary
  local function SetupAvailableButtons()
    if elevatorBusy then
      -- disable buttons only if fail sound is not available
      if ec.soundUseFail == nil then
        ec.buttons:DisableUsage()
        ec.callButtons:DisableUsage()
      else
        ec.buttons:EnableUsage()
        ec.callButtons:EnableUsage()
      end
    else
      if ec.levelsPanelModel ~= nil then
        ec.levelsPanelModel:NewClearState(0)
      end
      ec.callButtons:EnableUsage()
      for i=1, ec.numberOfLevels do
        if ec.levelAvailableFunc(i) then
          ec.buttons[i]:EnableUsage()
          if ec.levelsPanelModel ~= nil then
            ec.levelsPanelModel:AddAnim(ec.generateButtonNumbersFunc(i), false, false, 1, 1)
          elseif ec.buttonNumbers ~= nil then
            local numberText = ec.generateButtonNumbersFunc(i)
            ec.buttonNumbers[i]:SetText(ec.buttonNumbersTextEffect, numberText, true)
          end
        else
          if ec.soundUseFail == nil then
            ec.buttons[i]:DisableUsage()
          else
            ec.buttons[i]:EnableUsage()
          end
          if ec.buttonNumbers ~= nil then
            ec.buttonNumbers[i]:SetText(ec.buttonNumbersTextEffect, "", true)
          end
        end
      end
    end
  end
  
  local function SetupLightOnButtons(lights, currentOrTravelledFloor, withDelay)
    if lights == nil then
      return
    end
    
    if withDelay then
      RunAsync(function()
        Wait(Delay(0.2))
        SetupLightOnButtons(lights, currentOrTravelledFloor)
      end)
      return
    end
    
    if lights ~= nil then
      lights:Deactivate()
      lights[currentOrTravelledFloor]:Activate()
    end
  end
  
  local function DeactivateCallButtonLights()
    if ec.callButtonLights ~= nil then
      ec.callButtonLights:Deactivate()
    end
  end
  
  -- set up available buttons for the elevator
  SetupAvailableButtons()
  -- close all entrances
  ec.entrances:PlayAnimStay("Closed")
  -- determine on which level should the elevator initially stay
  local iCurrentElevatorLevel = 1
  local currentChapter = ec.elevator:GetWorldInfo():GetCurrentChapter()
  if currentChapter ~= nil then
    for iLevel, chaptersOnLevel in ipairs(ec.chaptersOnLevels) do
      local found = false
      for _, chapterOnLevel in ipairs(chaptersOnLevel) do
        if chapterOnLevel == currentChapter then
         iCurrentElevatorLevel = iLevel
         found = true
         break
        end
      end
      if found then
        break
      end
    end
  end
  
  -- place the elevator to the current level
  ec.elevator:SetPlacement(mthQuatVect(ec.elevator:GetPlacement():GetQuat(), ec.levelMarkers[iCurrentElevatorLevel]:GetPlacement():GetVect()))
  -- open entrance on the elevator level
  ec.entrances[iCurrentElevatorLevel]:PlayAnimStay("Opened")
  
  -- set entrance test bot call button marker as skippable or not
  if ec.callMarkers ~= nil then
    for iLevel=1, ec.numberOfLevels do
      for _, callMarker in ipairs(ec.callMarkers[iLevel]) do
        if callMarker ~= nil then
          if iLevel == iCurrentElevatorLevel then
            callMarker:SetSkippable(true)
          else
             callMarker:SetSkippable(false)
          end
        end
      end    
    end
  end 
  
  SetupLightOnButtons(ec.buttonLights, iCurrentElevatorLevel)
  DeactivateCallButtonLights()
    
  local function HandleButtonUse(payload, callButtonUsed)
  
    if ec.soundUseFail == nil then
      ec.buttons:DisableUsage()
      ec.callButtons:DisableUsage()
    else
      ec.buttons:EnableUsage()
      ec.callButtons:EnableUsage()
    end
  
    local indexButtonPressed=payload.any.signaledIndex
    -- play the push button animation in any case
    ec.buttons[indexButtonPressed]:PlayAnim("Push")
    ec.callButtons[indexButtonPressed]:PlayAnim("Push")
    
    -- ignore button use if elevator is busy or level is unavailable
    if elevatorBusy or not ec.levelAvailableFunc(indexButtonPressed) then
      if ec.soundUseFail then
        ec.soundUseFail:PlayOnce()
      end
      return
    end
    
    if ec.soundUse then
      ec.soundUse:PlayOnce()
    end
      
    -- if call button was used, light it up now
    if callButtonUsed then
      SetupLightOnButtons(ec.callButtonLights, indexButtonPressed, true)
    end
    
    -- set all entrance test bot call button markers as not skippable
    if ec.callMarkers ~= nil then
      for iLevel=1, ec.numberOfLevels do
        for _, callMarker in ipairs(ec.callMarkers[iLevel]) do
          if callMarker ~= nil then
            callMarker:SetSkippable(false)
          end
        end
      end
    end 
    
    -- if at desired level
    if iCurrentElevatorLevel==indexButtonPressed then
      -- it looks better if longer delay is used for call buttons (otherwise the light deactivates too fast)
      if callButtonUsed then
        Wait(Delay(1.0))
      else
        Wait(Delay(0.5))
      end
      -- unmark the elevator as busy
      elevatorBusy = false
      DeactivateCallButtonLights()
      SetupAvailableButtons()
      -- ignore the button use since the elevator is right where it needs to be
      return
    end
    
    -- mark the elevator as busy now
    elevatorBusy = true

    -- disable buttons only if fail sound is not available
    if ec.soundUseFail == nil then
      ec.buttons:DisableUsage()
      ec.callButtons:DisableUsage()
    else
      ec.buttons:EnableUsage()
      ec.callButtons:EnableUsage()
    end
    SetupLightOnButtons(ec.buttonLights, indexButtonPressed, true)
    ec.entrances[iCurrentElevatorLevel]:PlayAnimStay("Closing")
    ec.doorSound:PlayOnce()
    ec.elevator:CloseDoor()
    if not callButtonUsed then
      SignalEvent(ec.elevator, "ElevatorStartedFrom", iCurrentElevatorLevel)
    end

    Wait(Delay(3.5))
    Wait(ec.elevator:MoveToDestinationEntity(ec.levelMarkers[indexButtonPressed]))
    DeactivateCallButtonLights()
    -- start the chapter corresponding to the level we have reached
    ec.levelElevatorStartingChapters[indexButtonPressed]:Start()
    if not callButtonUsed then
      SignalEvent(ec.elevator, "ElevatorArrivedAt", indexButtonPressed)
    end
    Wait(Delay(1))
    ec.doorSound:PlayOnce()
    ec.elevator:OpenDoor()
    ec.entrances[indexButtonPressed]:PlayAnimStay("Opening")
    Wait(Delay(3))
    iCurrentElevatorLevel = indexButtonPressed
    elevatorBusy = false
    SetupAvailableButtons()
    -- set entrance test bot call button markers as skippable
    if ec.callMarkers ~= nil then
      for _, callMarker in ipairs(ec.callMarkers[iCurrentElevatorLevel]) do
        if callMarker ~= nil then
          callMarker:SetSkippable(true)
        end
      end
    end 
  end

  -- if detector for updating available button is set, we need to set it up
  -- so it updates available buttons whenever activated
  if ec.updateAvailableButtonsDetector ~= nil then
    RunAsync(function()
      RunHandled(
        WaitForever,
        OnEvery(Event(ec.updateAvailableButtonsDetector.Activated)), function()
          ec.updateAvailableButtonsDetector:Recharge()
          SetupAvailableButtons()
        end
      )
    end)
  end
  
  -- handle button use
  RunHandled(
    WaitForever,
    OnEvery(Any(Events(ec.callButtons.Used))),
    function(payload)
      HandleButtonUse(payload, true)
    end,
    OnEvery(Any(Events(ec.buttons.Used))), HandleButtonUse
  )
end