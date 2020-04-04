-- Control a turret using a switch.
function worldGlobals.TurretSwitchControl(turret, switch, initialstate)
  -- if not specified, assume default state is enabled
  local state = initialstate
  if state==nil then
    state = true
  end
  
  RunAsync(function()

    -- after the entities are set up...
    Wait(Delay(0.001))

    -- ...put the switch into initial state
    switch:EnableUsage() 
    if state then
      switch:PlayAnimStay("On_Pose")
    else
      switch:PlayAnimStay("Off_Pose")
      turret:Disable();
    end
  
    RunHandled(
      function()
        WaitForever()
      end,
    
      -- whenever the switch is toggled
      OnEvery (Event(switch.Used)),
        function()
          -- make sure it is not used again while animating
          switch:DisableUsage()
          -- if currently on
          if state then
            -- move to off position
            switch:PlayAnimStay("Off")
            Wait(Delay(0.3))
            -- and disable the turret
            turret:Disable();
          -- if currently off
          else
            -- move to on position
            switch:PlayAnimStay("On")
            Wait(Delay(0.3))
            -- and enable the turret
            turret:Enable();
          end
          -- toggle the state
          state = not state
		  -- if currently enabled, or playing single player
		  -- NOTE: We don't allow turning turrets back on (once they were turned off) in coop, to prevent griefing.
		  if state or worldGlobals.worldInfo:GetGameMode()=="SinglePlayer" then
		    -- allow the players to toggle the switch again
		    switch:EnableUsage()
		  end
        end  
    )
  end)
end
