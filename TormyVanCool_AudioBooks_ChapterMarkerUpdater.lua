-- @description Chapter Marker Updater for Audiobooks
-- @author Tormy Van Cool
-- @version 2.1
-- @about
--   # Chapter Marker Updater for Audiobooks
--
--   The script, updates the PROJECT_NAME.SideCar.txt file, when markers are renamed and/or moved.
--   Just calling the script, it remove the old file, with a new updated one.
--
--   Once done, it returns a popup window that informs the users, that everything is perfectly done.
-- versions
--[[
  1.0 Initial release
  2.0 + Code rewritten from scratch
  2.1 - removed reaper.ShowConsoleMsg()
]]
--------------------------------------------------------------------
-- Gets the project's name and open the SideCr file to be ovewritten
--------------------------------------------------------------------
chap = "CHAP="
extension = ".txt"
pipe = "|"
LF = "\n"

local pj_name=reaper.GetProjectName(0, "")
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
pj_name = string.gsub(string.gsub(pj_name, ".rpp", ""), ".RPP", "")..extension
SideCar = io.open(pj_path..'\\'..pj_name, "w")


--------------------------------------------------------------------
-- Turns the seconds into the format: hh:mm:ss
--------------------------------------------------------------------
function SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

--------------------------------------------------------------------
-- Get rid of the "CHAP=" ID3 Tag
--------------------------------------------------------------------
function ChapRid(chappy, seed, subs) -- Get rid of the "CHAP=" ID3 Tag or other stuff to prevent any error by user
  local ridchap
  if subs == nil then subs = "" end
  if chappy == nil then return end
  ridchap = string.gsub (chappy, seed,  subs)
  return ridchap
end

function Round(seed, precision)
  local roundup = math.floor(seed * precision) / precision
  return roundup
end
--------------------------------------------------------------------
-- Estabilshes how many markers/regions are located into the project
--------------------------------------------------------------------
numMarkers = 0

repeat
  mkr = reaper.EnumProjectMarkers(numMarkers)
  numMarkers = numMarkers+1
until mkr == 0

i = 0

while i < numMarkers-1 do
  local ret, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
  if string.match(name, chap) then
    local SideCar_ = Round(pos,100)..',1,'..'"'..string.match(name, "|(.*)")..'"'..LF
    SideCar:write( SideCar_ )
  end
  i = i+1
end

--------------------------------------------------------------------
-- Closes file and returns feedback to user
--------------------------------------------------------------------
SideCar:close()
reaper.MB(pj_name..LF..LF.."SUCCESSFULLY UPDATED", "Audiobook's SIDECAR and MIDSTREAM TAGS Updated", 0)


