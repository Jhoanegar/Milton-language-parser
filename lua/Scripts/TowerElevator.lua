 -- set up elevator control function if necessary
if worldGlobals.ElevatorControl == nil then
  dofile("Content/Talos/Scripts/ElevatorControl.lua")
end

local ec = {}
-- total number of levels for the elevator
ec.numberOfLevels = 7
-- function for calculating whether a level is available or not
ec.levelAvailableFunc = function(levelNumber)
  -- floors below level 2 are always available
  if levelNumber < 3 then
    return true
  -- other floors are available when their variable is set
  else
    local strVar = "Floor"..(levelNumber-1).."Unlocked"
    return ctdIsVarSet(worldInfo, strVar)
  end
end
-- buttons inside the elevator (group var ordered the same as the floors)
ec.buttons = buttons
-- model which plays animation for enabled buttons (may not be set)
ec.levelsPanelModel = elevatorPanel
ec.generateButtonNumbersFunc = function(levelNumber)
  return levelNumber - 1
end
ec.buttonLights = buttonLights
ec.callButtonLights = callButtonLights
-- button used to call the elevator to the required level (group var ordered the same as the floors)
ec.callButtons = elevatorCallButtons
-- chapters on all levels (used to determine on which level should we place an elevator depending on current chapter)
-- if list is empty for a level, that level will be used when no other level chapters match the current chapter
ec.chaptersOnLevels = {{}, level1Chapters, level2Chapters,
  level3Chapters, level4Chapters, level5Chapters, {chapterLevel06}}
-- chapter that will be triggered once the el   evator reaches its level
ec.levelElevatorStartingChapters = {chapterLevel00, chapterLevel01, chapterLevel02,
  chapterLevel03, chapterLevel04, chapterLevel05, chapterLevel06}
-- elevator entity controlled by the elevator control
ec.elevator = elevator
-- all entrances to the elevator (opened when elevator is at one of them)
ec.entrances = elevatorEntrances
-- all test bot markers that call the elevator (set to skippable when elevator is at them)
ec.callMarkers = {{elevator0to1}, {elevator1to0, elevator1to2, elevator1to5},
  {elevator2to3}, {elevator3to1, elevator3to4}, {elevator4to5}, {}, {}}
-- elevator position markers for all levels
ec.levelMarkers = markers
-- sound played when doors are opened
ec.doorSound = doorSound
ec.updateAvailableButtonsDetector = elevatorDetector
-- button successful use sound
ec.soundUse = soundUse
-- button failed use sound
ec.soundUseFail = soundUseFail

-- start the elevator control
worldGlobals.ElevatorControl(ec)