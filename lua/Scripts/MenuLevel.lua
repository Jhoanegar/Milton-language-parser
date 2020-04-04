local ctCameras = #Cameras
while true do
  for i=1,ctCameras,1 do
    Wait(Cameras[i]:PlayAnimWait("Default"))
  end
end
