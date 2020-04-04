-- levels for all cloud files, indexed per episode
local allEpisodeClouds = {
  -- episode 1
  {
    "Cloud_1_01.wld",
    "Cloud_1_02.wld",
    "Cloud_1_03.wld",
    "Cloud_1_04.wld",
    "Cloud_1_05.wld",
    "Cloud_1_06.wld",
    "Cloud_1_07.wld",
    "Cloud_1_08.wld",
    "Islands_02.wld",
    "DeveloperIsland.wld",
    -- these levels belong to the episode but should not be cached along with it
    dontCache = {
      ["Cloud_1_08.wld"] = true,
      ["DeveloperIsland.wld"] = true,
    },
  },
  -- episode 2
  {
    "Cloud_2_01.wld",
    "Cloud_2_02.wld",
    "Cloud_2_03.wld",
    "Cloud_2_04.wld",
    "Cloud_2_05.wld",
    "Cloud_2_06.wld",
    "Cloud_2_07.wld",
    "Cloud_2_08.wld",
    "Islands_03.wld",
    dontCache = {
      ["Cloud_2_08.wld"] = true,
    },
  },
  -- episode 3
  {
    "Cloud_3_01.wld",
    "Cloud_3_02.wld",
    "Cloud_3_03.wld",
    "Cloud_3_04.wld",
    "Cloud_3_05.wld",
    "Cloud_3_06.wld",
    "Cloud_3_07.wld",
    "Cloud_3_08.wld",
    "Islands_01.wld",
    dontCache = {
      ["Cloud_3_08.wld"] = true,
    },
  },
  
  -- fake episode 4 (ending cut scene)
  {
    "EndOfGameCS.wld",
    dontCache = {
      ["EndOfGameCS.wld"] = true,
    },
  },
}

-- base path for all the levels, used to form the cloud path
local baseWorldPath = "Content/Talos/Levels/"
-- we can use both the world cache or world info for world cache interface
local worldCacheInterface
local AddToWorldCache
local AddToWorldCache_AsHighPriority
local RemoveFromWorldCache
if globals ~= nil then
  worldCacheInterface = globals.worldCache
  AddToWorldCache = function(level)
    worldCacheInterface:AddToCache(level)
  end
  AddToWorldCache_AsHighPriority = function(level)
    worldCacheInterface:AddToCache_AsHighPriority(level)
  end
  RemoveFromWorldCache = function(level)
    worldCacheInterface:RemoveFromCache(level)
  end
else
  worldCacheInterface = worldGlobals.worldInfo
  AddToWorldCache = function(level)
    worldCacheInterface:AddToWorldCache(level)
  end
  AddToWorldCache_AsHighPriority = function(level)
    worldCacheInterface:AddToWorldCache_AsHighPriority(level)
  end
  RemoveFromWorldCache = function(level)
    worldCacheInterface:RemoveFromWorldCache(level)
  end
end

-- Adds levels from episode with specified index to cache, removing levels from all other episodes from cache
local function addEpisodeToWorldCache(desiredEpisodeIndex)
  -- episode is recognized as a valid episode
  if desiredEpisodeIndex > 0 and desiredEpisodeIndex <= #allEpisodeClouds then
    -- Nexus level should always be in world cache (and as high priority)
    AddToWorldCache_AsHighPriority("Content/Talos/Levels/Nexus.wld")
  end
  for episodeIndex, episodeLevels in ipairs(allEpisodeClouds) do
    if episodeIndex == desiredEpisodeIndex then
      for _, levelName in ipairs(episodeLevels) do
        if episodeLevels.dontCache == nil or not episodeLevels.dontCache[levelName] then
          AddToWorldCache(baseWorldPath .. levelName)
        end
      end
    else
      for _, levelName in ipairs(episodeLevels) do
        RemoveFromWorldCache(baseWorldPath .. levelName)
      end
    end
  end
end

local function getWorldEpisode(levelFullPath)
  local levelWithoutPathPrefix = string.match(levelFullPath, "Content/Talos/Levels/(.+)")
  if levelWithoutPathPrefix == nil then
    -- invalid episode
    return -1
  end
  for episodeIndex, episodeClouds in pairs(allEpisodeClouds) do
    for _, cloud in ipairs(episodeClouds) do
      if cloud == levelWithoutPathPrefix then
        return episodeIndex
      end
    end
  end
  -- not found - invalid episode
  return -1
end

if worldGlobals ~= nil then
  worldGlobals.addEpisodeToWorldCache = addEpisodeToWorldCache
  worldGlobals.getWorldEpisode = getWorldEpisode
else
  globals.addEpisodeToWorldCache = addEpisodeToWorldCache
  globals.getWorldEpisode = getWorldEpisode
end