 
local afDurations = {120, 60}
Camera1:PlayAnimWait("InitialCamera")
Wait(Delay(60))
Camera1:Stop()
while true do
  for i=1,#cameras,1 do
    cameras[i]:PlayAnimWait("Default")
    Wait(Delay(afDurations[i]-0.1))
    cameras[i]:Stop()
  end
end
