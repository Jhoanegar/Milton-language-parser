 -- send event when view probe is triggered (needed for story events)
RunAsync(function()
  Wait(Delay(0.5))
  viewProbe:EnableForAllCurrentPlayers()
  
  Wait(Event(viewProbe.LookedAt))
  viewProbe:DisableForAllCurrentPlayers()
  SignalEvent("HelpAltarSeen")
  print("HelpAltarSeen")
end)

local tryAgain = true
local hintUsageConfirmed = false

local usedPayload = Wait(CustomEvent(compositeEntity, "Used"))
local user = usedPayload:GetUser()

while tryAgain do
  tryAgain = false
  -- user : CPlayerPuppetEntity
  local currentChapter = worldGlobals.worldInfo:GetCurrentChapter()
  -- currentChapter : CChapterInfoEntity
  user:LeaveTalosMessageFromCategory(
    "Help", "help altar temp", messageMarker, floorMarker, stepBackMarker)
  Wait(Delay(4.0)) -- this waits until the message is painted by player's hand
  
  -- talosProgress : CTalosProgress
  local talosProgress = nexGetTalosProgress(worldGlobals.worldInfo)
  
  -- if puzzle is already solved, we need only to reply
  -- with a message saying that this is not needed
  local messengerSignature = talosProgress:GetCurrentMessengerSignature()
  if compositeEntity:IsPuzzleSolved() then
    compositeEntity:LeaveRandomTalosMessageFromCategory(
      "HintOnSolvedPuzzle", messengerSignature, "help altar temp", messageResponseMarker);
    return
  end
  
  -- if player has no hints available
  if talosProgress:GetMessengerHintsCount() <= 0 then
    local usedAllTheHints = talosProgress:GetUsedMessengerHintsCount() == 3
    Wait(Delay(1)) -- give some time so response is not unnaturally to quick
    -- if player has used up all the hints
    if usedAllTheHints then
      -- show a message saying that there are no more hints available
      compositeEntity:LeaveRandomTalosMessageFromCategory(
        "HintWhenNoMoreHintsRemain", messengerSignature, "help altar temp", messageResponseMarker);
    else
      -- show message saying that player should find more hints 
      compositeEntity:LeaveRandomTalosMessageFromCategory(
        "HintNeedToUnlockHints", messengerSignature, "help altar temp", messageResponseMarker);
      SignalEvent("HelpAltarUnavailable")
    end
    return
  end
  
  Wait(Delay(0.5))
  
  -- angel : CGhostPuppetEntity
  local angel = angelSpawner:SpawnOne()
  angel:SetFade(0.0)
  angel:SetLookTarget(messageResponseMarker)
  angel:StartFadingIn(1.0)
  Wait(Delay(1.5))
  angel:SetCharacterName(messengerSignature)
  angel:PlayAnim("QRPaint_Altar")
  Wait(Delay(0.3))
  -- unlock corresponding player message (when you have used up a hint)
  talUnlockPlayerMessage(worldGlobals.worldInfo, prjTalosDefaultEpisodeID(worldGlobals.worldInfo), 506)
  
  -- set the variable for confirming hint usage
  if hintUsageConfirmed then
    talosProgress:SetVar("Hint_AreYouSureUsed")
  end
  
  local hintText
  local messageType = "help altar hint"
  if currentChapter:GetName()~="109" then
    if not talosProgress:IsVarSet("Hint_AreYouSureUsed") then
      hintText = "TTRS:MessengerHint.AreYouSure=There aren't many of us left in this world. Be sure you really need our help before you proceed."
      messageType = "help altar are you sure"
      tryAgain = true
    else
      talosProgress:SpendMessengerHint()
      hintText = compositeEntity:GetMessage();
      compositeEntity:MarkAsUsed()
    end
  else
    hintText = compositeEntity:GetMessage();
    compositeEntity:MarkAsUsed()
  end
  
  
  angel:LeaveTalosMessage(
    hintText,
    messengerSignature,
    messageType,
    messageResponseMarker)
  RunAsync(function()
    Wait(Delay(4.5))
    angel:SetLookTarget(nil)
    angel:StartFadingOut(1.0)
    Wait(Delay(1.1))
    angel:Despawn()
  end)
  
  -- if we should try again    
  if tryAgain then
    -- wait until the message is viewed or too much time has passed
    -- before reenabling usage on the help altar
    -- (we need to wait on the marker as object as the marker passed to LeaveTalosMessage function is set as event object
    Wait(CustomEvent(messageResponseMarker, "HelpAltarIAmSure"))
    -- mark the hint usage as confirmed for next try
    hintUsageConfirmed = true
  end
end







