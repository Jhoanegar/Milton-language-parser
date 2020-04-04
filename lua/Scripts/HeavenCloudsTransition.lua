-- allow player to reach the detector with auto movement
detectorHeaven:SetToucscreenMoveTarget(true)

RunHandled(
  function()
    WaitForever()
  end,
    
  OnEvery(Event(detectorLobby.Activated)),
    function(e) -- e : CActivatedScriptEvent
      local player = e:GetActivator() -- player : CPlayerPuppetEntity
      detectorLobby:Recharge()
      player:Teleport(markerHeaven, false)
    end,
  
  OnEvery(Event(detectorHeaven.Activated)),
    function(e) -- e : CActivatedScriptEvent
      local player = e:GetActivator() -- player : CPlayerPuppetEntity
      detectorHeaven:Recharge()
      player:Teleport(markerLobby, false)
    end
)    




