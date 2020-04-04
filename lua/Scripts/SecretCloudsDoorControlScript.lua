
local strPickedInstances = nexGetTalosProgress(worldInfo):GetInventoryTetrominoes() .. nexGetTalosProgress(worldInfo):GetUsedupTetrominoes()

if string.match(strPickedInstances, "(%*)") then 
  StarDoors:AssureOpened()
end