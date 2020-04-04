worldGlobals.worldInfo = worldInfo
worldGlobals.levelChanged = not not levelChanged

worldGlobals.inMenuSimulation = worldInfo:IsMenuSimulationWorld()

-- set global whether we're on remote interface (much faster than calling function every time)
worldGlobals.netIsRemote = worldInfo:NetIsRemote()
-- for ease of use, create netIsHost as negation of netIsRemote
worldGlobals.netIsHost = not worldGlobals.netIsRemote
-- this file is just a hub for various collections of scripts that are needed on all (or most) worlds
dofile("Content/Talos/Scripts/CutSceneFunctions.lua")

if CorIsAppVR(void) then
  dofile("Content/Talos/Scripts/ControllerHints.lua")
  worldGlobals.strHomeToResetHint = "TTRS:Hint.HoldToResetVRScript=Press the button on your hand to reset"
else
  worldGlobals.strHomeToResetHint = "TTRS:Hint.HoldToReset=Hold {plcmdHome} to reset"
end

-- add functions to this array if you need to do Wait or RunHandled inside the called scripts
-- that will prevent the "attempt to yield across metamethod/C-call boundary" error
worldGlobals.worldFunctionsToExecute = {}

-- execute scripts which are not intended for menu simulations
if not worldGlobals.inMenuSimulation then
  dofile("Content/Talos/Scripts/TurretScripts.lua")
  dofile("Content/Talos/Scripts/DoorScripts.lua")
  dofile("Content/Talos/Scripts/TalosStoryEvents.lua")
  -- logic for unlocking paint items
  dofile("Content/Talos/Scripts/PaintItemUnlocking.lua")
  -- logic for unlocking player messages
  dofile("Content/Talos/Scripts/PlayerMessagesUnlocking.lua")
  local episodeWorldScript = worldInfo:GetTalosEpisodeWorldScript();
  if episodeWorldScript ~= "" then
    dofile(episodeWorldScript)
  end
end

for i, f in ipairs(worldGlobals.worldFunctionsToExecute) do
  RunAsync(f)
end