-- zoneDetector.lua
-- Minimal continuous watcher using getPlayersInCoords
-- Prompts for the two corner positions, redstone side, and an optional whitelist of player names.

local function promptNumber(label)
  write(label .. ": ")
  return tonumber(read())
end

local function promptPos(name)
  print("Enter " .. name .. " coordinates:")
  return {
    x = promptNumber("  x"),
    y = promptNumber("  y"),
    z = promptNumber("  z")
  }
end

local function promptPlayerNames()
  print("Enter player names to watch (press Enter to finish):")
  local names, set = {}, {}
  while true do
    write("  name: ")
    local n = read()
    if n == "" then break end
    if not set[n] then
      names[#names + 1] = n
      set[n] = true
    end
  end
  return names, set
end

local posA = promptPos("posA")
local posB = promptPos("posB")

write("Redstone side (e.g. back): ")
local SIDE = read()

local watchList, watchSet = promptPlayerNames()
local useWatchList = (#watchList > 0)

local INTERVAL = 0.05 -- seconds between checks
local playerDetector = peripheral.find("playerDetector")

print(string.format(
  "zoneDetector: watching [%d,%d,%d) -> [%d,%d,%d) on side '%s'",
  posA.x, posA.y, posA.z, posB.x, posB.y, posB.z, SIDE
))

if useWatchList then
  print("Watching only: " .. table.concat(watchList, ", "))
else
  print("Watching: anyone")
end

while true do
  local found = playerDetector.getPlayersInCoords(posA, posB)

  local shouldOn = false
  if #found > 0 then
    if useWatchList then
      for i = 1, #found do
        if watchSet[found[i]] then
          shouldOn = true
          break
        end
      end
    else
      shouldOn = true
    end
  end

  redstone.setOutput(SIDE, shouldOn)
  os.sleep(INTERVAL)
end
