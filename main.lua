-- main.lua
-- Loads config from config.lua; if missing/invalid, prompts and overwrites config.lua.

local CONFIG_FILE = "config.lua"

local cfg
if fs.exists(CONFIG_FILE) then
  local ok, loaded = pcall(dofile, CONFIG_FILE)
  if ok and type(loaded) == "table" then
    cfg = loaded
  end
end

if not (cfg and cfg.posA and cfg.posB and cfg.SIDE and cfg.posA.x and cfg.posA.y and cfg.posA.z and cfg.posB.x and cfg.posB.y and cfg.posB.z) then
  cfg = { posA = {}, posB = {}, players = {} }

  print("Enter posA:")
  write("  x: ") cfg.posA.x = tonumber(read())
  write("  y: ") cfg.posA.y = tonumber(read())
  write("  z: ") cfg.posA.z = tonumber(read())

  print("Enter posB:")
  write("  x: ") cfg.posB.x = tonumber(read())
  write("  y: ") cfg.posB.y = tonumber(read())
  write("  z: ") cfg.posB.z = tonumber(read())

  write("Redstone side (e.g. back): ")
  cfg.SIDE = read()

  print("Enter player names to watch (press Enter on empty line to finish):")
  while true do
    write("  name: ")
    local n = read()
    if n == "" then break end
    cfg.players[#cfg.players + 1] = n
  end

  local f = fs.open(CONFIG_FILE, "w")
  f.write("return {\n")
  f.write(string.format("  posA = { x = %d, y = %d, z = %d },\n", cfg.posA.x, cfg.posA.y, cfg.posA.z))
  f.write(string.format("  posB = { x = %d, y = %d, z = %d },\n", cfg.posB.x, cfg.posB.y, cfg.posB.z))
  f.write(string.format("  SIDE = %q,\n", cfg.SIDE))
  f.write("  players = {")
  for i = 1, #cfg.players do
    f.write(string.format("%q", cfg.players[i]))
    if i < #cfg.players then f.write(", ") end
  end
  f.write(" },\n")
  f.write("}\n")
  f.close()
end

local playerSet = {}
for i = 1, #(cfg.players or {}) do
  playerSet[cfg.players[i]] = true
end
local usePlayerList = cfg.players and #cfg.players > 0

local INTERVAL = 0.1
local playerDetector = peripheral.find("playerDetector")

print(string.format(
  "zoneDetector: watching [%d,%d,%d) -> [%d,%d,%d) on side '%s'",
  cfg.posA.x, cfg.posA.y, cfg.posA.z, cfg.posB.x, cfg.posB.y, cfg.posB.z, cfg.SIDE
))

while true do
  local found = playerDetector.getPlayersInCoords(cfg.posA, cfg.posB)

  local on = false
  if #found > 0 then
    if usePlayerList then
      for i = 1, #found do
        if playerSet[found[i]] then
          on = true
          break
        end
      end
    else
      on = true
    end
  end

  redstone.setOutput(cfg.SIDE, on)
  os.sleep(INTERVAL)
end
