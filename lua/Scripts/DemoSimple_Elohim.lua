RunHandled(WaitForever,
  On(Event(Detector_FirstYard_Exit.Activated)), function()
    Wait(Delay(1))
    worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-001_Behold_child.ogg"))
  end,
  On(Event(Arranger.Solved)), function()
    Wait(Delay(1))
    worldGlobals.ElohimSayOnce(Depfile("Content/Talos/Locales/enu/Sounds/Voiceovers/Elohim/Elohim-012_Step_into_the_light.ogg"))
  end
)