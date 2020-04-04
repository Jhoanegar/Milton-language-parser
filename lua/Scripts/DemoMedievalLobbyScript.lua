endDoor:EnableUsage()

RunHandled(WaitForever,
 OnEvery (Any(
  Event(Chapter_DemoEnd.Started),
  Event(Chapter_DemoSecretLevel.Started))),
  function()
    Wait(Delay(5))    
    worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-DemoEnding.ogg"))
  end,
  
  On(Event(endDoor.Used)),
  function()   
    -- end level    
    EventAnimatorDarkening:StartAnimation("Darkening")
    for i=1, 10 do
      worldInfo:SetMusicVolume("Exploration", 1-i/10)
      Wait(Delay(0.5))
    end
    Wait(Delay(0.1))
    DemoEndLogo_Chapter:Start()
  end
)
