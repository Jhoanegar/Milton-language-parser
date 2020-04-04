if Arranger:IsSolved() then
  DomeCollision:Disappear()
  Dome:PlayAnimStay("Opened")
else
  Wait(Event(Arranger.Solved))
  Dome:PlayAnimStay("Opening")
  Wait(Delay(2))
  DomeCollision:Disappear()
end