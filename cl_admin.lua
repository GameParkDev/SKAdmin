local maxPlayers = 32

function getOnlinePlayers()
  local players = {}
  local me = PlayerId(-1)
  for i=0, maxPlayers, 1 do
    -- if NetworkIsPlayerConnected(i) and i ~= me then
    if NetworkIsPlayerConnected(i) then
      local playerName = GetPlayerName(i)
      local serverID = GetPlayerServerId(i)

      table.insert(players, {
        ['ped'] = GetPlayerPed(i),
        ['name'] = playerName,
        ['id'] = i,
        ['serverID'] = serverID,
      })
    end
  end
  return players
end


function spectatePlayer(targetId)
  local playerPed = GetPlayerPed(-1)
  local targetPed = GetPlayerPed(targetId)

  if not IsScreenFadedOut() and not IsScreenFadingOut() then
    DoScreenFadeOut(1000)
    while (not IsScreenFadedOut()) do
		    Wait(0)
    end

    --local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(targetId),true))

    FreezeEntityPosition(playerPed, true)
    RequestCollisionAtCoord(GetEntityCoords(targetPed))
    NetworkSetInSpectatorMode(true, targetId)

    if(IsScreenFadedOut()) then
      DoScreenFadeIn(1000)
    end

    TriggerClientEvent("chatMessage", -1, "SKAdmin", {255, 0, 0}, "In spectate mode. To exit press BACKSPACE")

    while true do
      Citizen.Wait(0)
      if IsControlJustPressed(3, 177) then

        FreezeEntityPosition(playerPed, false)
        RequestCollisionAtCoord(GetEntityCoords(playerPed))
        NetworkSetInSpectatorMode(0, playerPed)
        break
      end
    end
  end

end

-- TELEPORT TO PLAYER EVENT
function teleportToPlayer(targetId)
  local playerPed = GetPlayerPed(-1)
  local targetPed = GetPlayerPed(targetId)

  NetworkSetInSpectatorMode(false, playerPed) -- turn off spectator mode just in case
  if PlayerId() == targetId then
    drawNotification("~r~This player is you!")
  elseif not NetworkIsPlayerActive(targetId) then
    drawNotification("~r~This player is not in game.")
  else
    local targetCoords = GetEntityCoords(targetPed)
    local targetVeh = GetVehiclePedIsIn(targetPed, False)
    local seat = -1

    drawNotification("~g~Teleporting to " .. GetPlayerName(targetId) .. " (Player " .. targetId .. ").")

    if targetVeh then
      local numSeats = GetVehicleModelNumberOfSeats(GetEntityModel(targetVeh))
      if numSeats > 1 then
        for i=0, numSeats do
          if seat == -1 and IsVehicleSeatFree(targetveh, i) then seat = 1 end
        end
      end
    end
    if seat == -1 then
      SetEntityCoords(playerPed, targetCoords, 1, 0, 0, 1)
    else
      SetPedIntoVehicle(playerPed, targetVeh, seat)
    end
  end
end

function teleportToWayPoint()
  local playerPed =  GetPlayerPed(-1)
  local waypoint = GetFirstBlipInfoId(8)
  Citizen.Trace("Hello!!")
  if DoesBlipExist(waypoint) then
    local coord = Citizen.InvokeNative(0xFA7C7F0AADF25D09, waypoint, Citizen.ResultAsVector())
    if IsPedInAnyVehicle(playerPed, 0) then
      SetEntityCoords(GetVehiclePedIsIn(playerPed), coord, 1, 0, 0, 1)
    else
      SetEntityCoords(playerPed, coord, 1, 0, 0, 1)
    end
    drawNotification("~g~Teleported To Waypoint!")
  else
    drawNotification("~r~No Waypoint Set!")
  end
end
