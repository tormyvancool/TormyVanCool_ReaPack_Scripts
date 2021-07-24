-- @description Update Podcasts Songs after have imported and adapted
-- @author Tormy Van Cool
-- @version 1.0
--------------------------------------------------------------------
-- Gets the project's name and open the SideCr file to be ovewritten
--------------------------------------------------------------------
reaper.Undo_BeginBlock()
chap = "CHAP="
extension = ".txt"
pipe = "|"
LF = "\n"

local pj_name=reaper.GetProjectName(0, "")
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
pj_name = string.gsub(string.gsub(pj_name, ".rpp", ""), ".RPP", "")..extension
SideCar = io.open(pj_path..'\\'..pj_name, "w")

----------------------------------
-- FUNCTIONS
----------------------------------
function ChapRid(chappy, seed, subs) -- Get rid of the "CHAP=" ID3 Tag or other stuff to prevent any error by user
  local ridchap
  if subs == nil then subs = "" end
  if chappy == nil then return end
  ridchap = string.gsub (chappy, seed,  subs)
  return ridchap
end

function Round(seed, precision) -- Round up with X precision: 10 = 1 figeur aftr comma, 100 = 2figures after comma and so on
  local roundup = math.floor(seed * precision) / precision
  return roundup
end

function SecondsToClock(seconds) -- Turns seconds into the format: "hh:mm:ss". Parameters: integer seconds
  local seconds = tonumber(seconds)
  if seconds <= 0 then
    return "00:00:00";
  else
    local hours = string.format("%02.f", math.floor(seconds/3600));
    local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return mins..":"..secs
  end
end

function IsSong(region_) -- Chek if the region is a song: has 5 | ? If yes: it's a song. Parameters: string region_
  local count = 0
  for i in region_:gmatch("|") do
      count = count + 1
  end
  if count == 5 then
      flag = true
    else
      flag = false
  end
  return flag
end

function create_region(ts_start, ts_end, region_name, region_ID, flag) -- Parameters: string region_name, integer region_ID, boolean flag
 if region_ID ~= "" and flag == true then
    reaper.DeleteProjectMarker(0, region_ID, 1)
 end
 if ts_start == ts_end then return end
 local item_start = math.floor(ts_start*100) /100
 reaper.AddProjectMarker(0, true, ts_start, ts_end, region_name, region_ID)
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
  local ret, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers2(0,i)
  
  if isrgn then
    if IsSong(name) then
    local NewName = string.match(name, "|(.*)|(.*)")
      NewName_Region = chap..Round(pos, 100)..pipe..NewName..pipe..Round(rgnend, 10)
        i = i+1
        create_region(pos, rgnend, NewName_Region, i, true )
        local SideCar_ = Round(pos,100)..',1,'..'"'..ChapRid(ChapRid(NewName, pipe, " - "), chap, '')..' - '..SecondsToClock(rgnend)..'"'..LF
        SideCar:write( SideCar_ )
      else
        i = i+1
    end -- IsSong
  end -- isrgn
end

--------------------------------------------------------------------
-- Closes file and returns feedback to user
--------------------------------------------------------------------
SideCar:close()
reaper.MB(pj_name.." and MIDSTRAM TAGS"..LF..LF.."SUCCESSFULLY UPDATED", "PODCASTS Updater", 0)
reaper.Undo_OnStateChangeEx("PODCASTS UPDATER", -1, -1)

