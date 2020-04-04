-- in this script, we check if the started world is from an episode and from which episode
-- if world is from a valid episode, all levels from that episode will be precached (and levels from other episodes will be uncached)
local worldFilename = worldCache:GetCurrentWorldPath()
-- nothing to do for nexus as nexus has its in world script which handles world caching
if worldFilename == "Content/Talos/Levels/Nexus.wld" then
  return
end
-- set up the world caching script for world globals
globals.worldCache = worldCache
dofile("Content/Talos/Scripts/WorldCaching.lua")

local episodeIndex = globals.getWorldEpisode(worldFilename)
conLogF("Executing episode auto level caching for " .. worldFilename .. ": episode is " .. episodeIndex .. "\n")
-- if episode is valid
if episodeIndex ~= -1 then
  -- add episode to world cache
  globals.addEpisodeToWorldCache(episodeIndex)
-- if episode is not valid
else
  conLogF("Removing all episodes from world cache\n")
  globals.addEpisodeToWorldCache(-1)
end
-- release the caching function as we don't want it to remain in globals
globals.addEpisodeToWorldCache = nil
globals.worldCache = nil
worldCache = nil
