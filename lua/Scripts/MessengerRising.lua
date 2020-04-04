﻿-- this arranger should never save progress as progress
-- should be saved when hint is awarded (otherwise you might not
-- receive the hint if the game is stopped right after solving the arranger)
Arranger:DontSaveProgressWhenSolved()

CoffinLights:Disappear()
if Arranger:IsSolved() then
  Coffin:PlayAnimStay("Opened")
  CoffinLights:Appear()
  character:Disappear(true)
else 
  Coffin:PlayAnimStay("Closed")
  character:PlayLoopingAnim("Ghost_Lying")
  character:EnableAmbientShadow(false)  
  Wait(Event(Arranger.Solved))
  local messengerName = tombstones:GetNextMessengerName()
  RunAsync(function()
    Wait(Delay(1))
    SoundMessengerReleased:PlayOnce()
    local progres = nexGetTalosProgress(worldInfo)
    progres:AddMessengerHint(messengerName, worldInfo)
  end)
  CoffinLights:Appear()
  Wait(Delay(5))
  SoundCoffinOpening:PlayOnce()
  Coffin:PlayAnimStay("CoverRotateOpen")
  character:EnableAmbientShadow(true)
  Wait(Delay(9)) 
  Wait(character:PlayAnim("GhostRising"))
  Wait(Delay(0.25))
  character:SetLookTarget(markerLeft)
  Wait(Delay(0.25))
  character:SetCharacterName(messengerName)
  character:SetLookTarget(nil)
  character:MoveToEntity(marker1)
  Wait(Event(character.GoalPointReached))
  character:MoveToEntity(marker3)
  Wait(Event(character.GoalPointReached))
  character:SetLookTarget(messageMarker) 
  Wait(Delay(0.25))
  character:PlayAnim("QRPaint_Altar")
  Wait(Delay(1))
  character:LeaveTalosMessage(
    "TTRS:RisenMessengerAltar=Welcome, child. I am one of those who elected to remain in the world as a Messenger of the Hidden Words. If you are ever in need, seek us out and cry for help - we will do what we can.", 
    messengerName, "custom",
    messageMarker)
  Wait(Delay(2.5))
  character:SetLookTarget(nil)
  character:MoveToEntity(marker2)
  Wait(Event(character.GoalPointReached))
  Wait(Delay(0.25))
  character:StartFadingOut(1)
  Wait(Delay(1.5))
  character:Disappear(true)
end
  