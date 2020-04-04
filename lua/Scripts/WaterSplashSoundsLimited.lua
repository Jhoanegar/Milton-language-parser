local eePlayerBorn = Wait(Event(worldInfo.PlayerBorn))
-- player : CPlayerPuppetEntity
local player = eePlayerBorn:GetBornPlayer()
local bAboveLastFrame = 1     -- used to track history of bAbove to detect when it's changed
local bAbove = 1      -- tracks if player is above or below the water surface
local waterLevel = waterMarker:GetPlacement().vy - 1.3543512   -- marker to define water level
                                                 -- numerical offset for player viewpoint

RunHandled(WaitForever,
OnEvery(CustomEvent("OnStep")),   -- run the check on each frame
function()
  local vPlayer = player:GetPlacement():GetVect()   -- if player isn't in detector, abort
  if detector:IsPointInArea(vPlayer, player:GetNavigationRadius()) then
      else
      return
  end             
  local velocity = player:GetLinearVelocity()
  local altitude = player:GetPlacement().vy
  if altitude < waterLevel then   -- check altitude to detect if player is above or below water
    bAbove = 0
    else
    bAbove = 1
  end
    
  if bAbove ~= bAboveLastFrame then   -- if above/below water status was changed since last frame:
    if velocity.y < -5 then           -- play apropriate sound for curent direction and speed
      DiveInSound:PlayOnce()
    end
    if velocity.y > -5 and velocity.y < 5 then
      if bAbove == 1 then 
        DiveSlowSound:PlayOnce()    -- 2 version of same sound to avoid canceling
      else                          -- each other out when played in succesion
        DiveSlowSound2:PlayOnce()
      end
    end    
    if velocity.y > 5 then 
      DiveOutSound:PlayOnce()
    end
  end
  bAboveLastFrame = bAbove    -- remember curent bAbove water value to compare with next frame
end
)
  
