-- control door via reader which can be used to unlock the door once key card is picked up (otherwise it plays error sound)
-- keyCard - item which needs to be picked
-- reader - static model ("Game scripting" enabled)
-- door - door entity (must be locked)
function worldGlobals.KeyCardReaderControl(keyCard, reader, door)
  RunAsync(function()
    local keyPicked = false
    reader:EnableUsage()
    print("started")
    
    RunHandled(
      WaitForever,
      On(Event(keyCard.Picked)),
      function()
        print("key picked")
        keyPicked = true
      end,
      OnEvery(Event(reader.Used)),
      function()
        print("reader used")
        if keyPicked then
          door:Unlock()
          reader:PlayAnimStay("Unlock")
        else
          reader:EnableUsage()
          reader:PlayAnim("Error")
        end
      end
    )
  end)
end

-- control door which can be unlocked once key is picked up (otherwise it plays locked animation)
-- key - item which needs to be picked
-- door - door entity (must be locked)
function worldGlobals.KeyDoorControl(key, door)
  RunAsync(function()
    local keyPicked = false
    door:EnableUsage()
    RunHandled(
      WaitForever,
      OnEvery(Event(door.Used)),
      function(e) -- e : CUsedScriptEvent
		-- user : CPlayerPuppetEntity
		local user=e:GetUser()
        if(keyPicked) then
          door:DisableUsage()
		else
		  door:DisableUsage()
		  Wait(Delay(3.5))
		  door:EnableUsage()
        end
      end,
      On(Event(key.Picked)),
      function()
        keyPicked = true
        door:Unlock()
      end)
    end)
end

-- control door via aggregator which can be used to unlock the door once key is picked up (otherwise it plays error sound)
-- the aggregator is used to track key status and display in on player's HUD
-- key - item which needs to be picked
-- aggregator - key aggregator entity
-- door - door entity (must be locked)
-- plasmaBarrier - plasma barrier which serves as entrance/exit to/from the puzzle
function worldGlobals.KeyDoorAggregatorControl(key, door, aggregator, plasmaBarrier)
  RunAsync(function()
    local chapterStart = plasmaBarrier:GetStartChapter()
    local chapterEnd = plasmaBarrier:GetEndChapter()
    local doorOpened = false
    local keyPicked = false
    door:AssureLocked()
    door:EnableUsage()
    door:EnableLookedAtNotification()
    if not(IsDeleted(key)) then
      aggregator:AddKey(key)
    end
    aggregator:ShowHudInfo(false)
       
    RunHandled(
      WaitForever,
      
      OnEvery(Event(key.Picked)),
      function()
        keyPicked = true
        door:Unlock()
      end,   
      
      OnEvery(Event(door.Used)),
      function()
        if(keyPicked) then
          doorOpened = true
          door:DisableUsage()
          Wait(Delay(0.5))
          aggregator:ShowHudInfo(false)
        else
          door:DisableUsage()
          Wait(Delay(3.5))
          door:EnableUsage()
        end
      end,

      OnEvery(Event(chapterStart.Started)),
      function()
        if doorOpened then
          return
        end
        aggregator:Reset()
        if not(IsDeleted(key)) then
          aggregator:AddKey(key)
        end
        aggregator:ShowHudInfo(true)
      end,
      
      OnEvery(Event(plasmaBarrier.BarrierPassed)),
      function(eBarrierPassed)
        local startedChapter = eBarrierPassed:GetStartedChapter()
        if startedChapter == chapterEnd then
          if not(doorOpened) then
            keyPicked = false
            aggregator:Reset()
            if not(IsDeleted(key)) then
              key:Unhide()
            end
            door:AssureLocked()
            door:EnableUsage()
            door:EnableLookedAtNotification()
          end
          aggregator:ShowHudInfo(false)
        end
      end
    )
  end)
end
