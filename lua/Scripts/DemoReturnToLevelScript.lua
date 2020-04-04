 
RunHandled(
  WaitForever,
  On(Event(FinalTarget.ChargedUp)),
  function()
    local progress = nexGetTalosProgress(worldInfo)
    progress:SetVar("CastlePuzzleSolved")
  end,
  
  OnEvery(Event(worldInfo.PlayerBorn)),
  function()
    local progress = nexGetTalosProgress(worldInfo)
    if progress:IsVarSet("CastlePuzzleSolved") then
      EndingPlasmaWall:ForceOpen()
    end
  end
)
