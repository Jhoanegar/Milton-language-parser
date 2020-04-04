RunHandled(
  WaitForever,
  
  OnEvery(Event(worldGlobals.worldInfo.PlayerBorn)),
  function(eePlayerBorn)
    local player = eePlayerBorn:GetBornPlayer()

    if vrGetDeviceName()=="Rift" then
      -- left Oculus controller

      vrAddControllerHintLeft(player, "TFE_MoveL", "TTRS:TFE.HUD.HintWeaponMove=Move", 1, 0, .6)
      vrAddControllerHintLeft(player, "TFE_WeaponSelectL", "TTRS:TFE.HUD.HintUseJump=Jump", -1, 0, 0.6)
      vrAddControllerHintLeft(player, "TFE_FireL", "TTRS:TFE.HUD.HintFire=Use", 0, -1, 0.5)
      vrAddControllerHintLeft(player, "TFE_UseJumpL", "TTRS:TFE.HUD.HintFire=Use", -1, 0, 0.5)
      --vrAddControllerHintLeft(player, "TFE_UseJumpL", "TTRS:TFE.HUD.HintUseJump=Jump", -1, 0, 0.75)
      vrAddControllerHintLeft(player, "TFE_FastMoveL", "TTRS:TFE.HUD.Teleport=Teleport", -1, 0, 0.75)
      vrAddControllerHintLeft(player, "MenuL", "TTRS:TFE.HUD.HintWeaponsOptions=Menu", 1, 0, 0.75)

      -- right Oculus controller
      vrAddControllerHintRight(player, "TFE_MoveR", "TTRS:TFE.HUD.HintWeaponMove=Move", -1, 0, .6)
      vrAddControllerHintRight(player, "TFE_WeaponSelectR", "TTRS:TFE.HUD.HintUseJump=Jump", 1, 0, 0.6)
      vrAddControllerHintRight(player, "TFE_FireR", "TTRS:TFE.HUD.HintFire=Use", 0, -1, 0.5)
      vrAddControllerHintRight(player, "TFE_UseJumpR", "TTRS:TFE.HUD.HintFire=Use", 1, 0, 0.5)
      vrAddControllerHintRight(player, "TFE_FastMoveR", "TTRS:TFE.HUD.Teleport=Teleport", 1, 0, 0.75) 
      --,vrAddControllerHintRight(player, "MenuR", "TTRS:TFE.HUD.HintWeaponsOptions=Menu", 1, 0, 0.75)      
    elseif vrGetDeviceName()=="WindowsMR" then
      -- left WindowsMR controller
      vrAddControllerHintLeft(player, "TFE_MoveStickL", "TTRS:TFE.HUD.HintWeaponMove=Move", -1, 0, .6)
      vrAddControllerHintLeft(player, "TFE_WeaponSelectL", "TTRS:TFE.HUD.HintWeaponsOptions=Menu", 1, 0, .6)
      vrAddControllerHintLeft(player, "TFE_FireL", "TTRS:TFE.HUD.HintFire=Use", 0, -1, 0.5)
      vrAddControllerHintLeft(player, "TFE_UseJumpL", "TTRS:TFE.HUD.HintUseJump=Jump", -1, 0, 0.6)
      vrAddControllerHintLeft(player, "TFE_FastMoveL", "TTRS:TFE.HUD.Teleport=Teleport", 1, 0, 0.75)        
      -- right WindowsMR controller
      vrAddControllerHintRight(player, "TFE_MoveStickR", "TTRS:TFE.HUD.HintWeaponMove=Move", 1, 0, .6)
      vrAddControllerHintRight(player, "TFE_WeaponSelectR", "TTRS:TFE.HUD.HintWeaponsOptions=Menu", -1, 0, .6)
      vrAddControllerHintRight(player, "TFE_FireR", "TTRS:TFE.HUD.HintFire=Use", 0, -1, 0.5)
      vrAddControllerHintRight(player, "TFE_UseJumpR", "TTRS:TFE.HUD.HintUseJump=Jump", 1, 0, 0.6)
      vrAddControllerHintRight(player, "TFE_FastMoveR", "TTRS:TFE.HUD.Teleport=Teleport", -1, 0, 0.75)        
    else
      -- left Vive controller
      vrAddControllerHintLeft(player, "Talos_MoveL", "TTRS:Talos.HUD.HintMove=Move", 1, 0, .6)
      vrAddControllerHintLeft(player, "Talos_MenuL", "TTRS:Talos.HUD.HintMenu=Menu", 1, 0, 1)
      vrAddControllerHintLeft(player, "Talos_UseL", "TTRS:Talos.HUD.HintUse=Use", -1, 0, 0.5)
      vrAddControllerHintLeft(player, "Talos_JumpL", "TTRS:Talos.HUD.HintJump=Jump", -1, 0, 0.75)
      -- right Vive controller
      vrAddControllerHintRight(player, "Talos_MoveR", "TTRS:Talos.HUD.HintWeaponMove=Move", -1, 0, .6)
      vrAddControllerHintRight(player, "Talos_MenuR", "TTRS:Talos.HUD.HintWeaponsOptions=Menu", -1, 0, 1)
      vrAddControllerHintRight(player, "Talos_UseR", "TTRS:Talos.HUD.HintFire=Use", 1, 0, 0.5)
      vrAddControllerHintRight(player, "Talos_JumpR", "TTRS:Talos.HUD.HintUseJump=Jump", 1, 0, 0.75)
    end
  end
)