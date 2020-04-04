local function HandlePlayerMessagesUnlocking()
  RunHandled(
    WaitForever,
    OnEvery(CustomEvent("TetrominoAwarded")),
    function(e)
      local progress = nexGetTalosProgress(worldGlobals.worldInfo)
      
      -- count all solved tetrominos
      local usedUpTetrominoes = progress:GetUsedupTetrominoes()
      local alltetros = progress:GetInventoryTetrominoes()..usedUpTetrominoes
      local _,ctDoors = string.gsub(alltetros, "D", "")
      local _,ctMechs = string.gsub(alltetros, "M", "")
      local _,ctTalos = string.gsub(alltetros, "N", "")
      local ctAll = ctDoors + ctMechs + ctTalos
      -- if all tetrominos have been picked up
      if ctAll == 101 then
        -- unlock the required player message
        talUnlockPlayerMessage(worldGlobals.worldInfo, prjTalosDefaultEpisodeID(worldGlobals.worldInfo), 507)
      -- if player has solved 2/3 of all puzzles
      elseif ctAll > 101*2/3 then
        -- unlock the required player message
        talUnlockPlayerMessage(worldGlobals.worldInfo, prjTalosDefaultEpisodeID(worldGlobals.worldInfo), 509)
      end
      
      -- if we have used no hints and we have heard elohim speak about the messengers and we have been awarded a nexus tetromino
      if string.match(e:GetTetromino(), "^N") then
        -- if all nexus tetrominos have been picked
        if ctTalos == 49 then
          -- if no hints have been used
          if progress:GetUsedMessengerHintsCount() == 0 then
            -- unlock the required player message if we have heard elohim speak about the messengers
            if progress:IsVarSet("Elohim-038_Here_those_who_are") then
              talUnlockPlayerMessage(worldGlobals.worldInfo, prjTalosDefaultEpisodeID(worldGlobals.worldInfo), 505)
            end
            -- award the achievement for picking up all the tower tetrominoes without using a hint
            worldGlobals.worldInfo:AwardAchievementToAllPlayers("Solipsist")
          end
          -- if no nexus tetromino has been used yet
          if string.find(usedUpTetrominoes, "N") == nil then
            -- award the achievement for picking up all the tower tetrominoes without using one
            worldGlobals.worldInfo:AwardAchievementToAllPlayers("HedgingMyBets")
          end
        end        
      end
    end
  )
end

table.insert(worldGlobals.worldFunctionsToExecute, HandlePlayerMessagesUnlocking)