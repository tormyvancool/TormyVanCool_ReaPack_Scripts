-- @description Chapter region for podcasts and recorded broadcasts
-- @author Tormy Van Cool
-- @version 2.5.1
-- @screenshot Example: ChapterRegion.lua in action https://github.com/tormyvancool/TormyVanCool_ReaPack_Scripts/Region.gif
-- @about
--   # Chapter Region for Podcasts and Recorded Broadcasts
--
--   It's an ideal feature for Podcasts and Recorded Broadcasts
--   It enables the user to highlight all the embedded songs by just a click.
--
--   By selecting the item of a song, a pop up windows asks to enter: Title and Performer of the song.
--   Automatically the script calculates the duration of the song in second, rounding it up to the 2nd decimal, based on the duration of the item.
--
--   It creates a region with the following line preceded by the ID3 Tag "CHAP="
--   "CHAP=offset|title_of_the_song|Performer_of_the_song|Duration_in_seconds"
--
--   This can be used by any decoder, to get all the CHAP tags inside the Podcast, getting out all the required information to be sent to Collecting Societies for the Rights collection.
--
--   Key features:
--   - It can work also as Armed Action
--   - It creates a region that contains the required Tags without sintaxis errors.
--   - It embeds the ID3 tags while Reaper is rendering the MP3s with Metadata, in automatic way.
-- Ver. 1.0 made by by Tormy Van Cool 01 feb 2021
--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
reaper.Undo_BeginBlock()
local chap = "CHAP="
local pipe = "|"
local LF = "\n"
local extension = ".txt"
local UltraschallLua = "/UserPlugins/ultraschall_api.lua"
local author = reaper.GetSetProjectAuthor(0, 0, '')



--------------------------------------------------------------------
-- Checks whehether the project is saved
-- Assigns the name to the SideCar opening it
--------------------------------------------------------------------
local pj_name_ = reaper.GetProjectName(0, "")
if pj_name_ == "" then 
  reaper.MB("Save the Project, first!",'WARNING',0)
  return
end
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
pj_name_ = string.gsub(string.gsub(pj_name_, ".rpp", ""), ".RPP", "")
local pj_name = pj_name_..extension
SideCar = io.open(pj_path..'\\'..pj_name, "w")


--------------------------------------------------------------------
-- Functions declaration
--------------------------------------------------------------------
function create_region(region_name, region_ID, flag)
 if region_ID ~= "" and flag == true then
    reaper.DeleteProjectMarker(0, region_ID, 1)
 end
 local color = 0
 local ts_start, ts_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
 if ts_start == ts_end then return end
 local item_start = math.floor(ts_start*100) /100
 reaper.AddProjectMarker2(0, true, ts_start, ts_end, chap..item_start..pipe..region_name, -1, color)
end

function get_item_length()
    local A
    local item = reaper.GetSelectedMediaItem(0, 0)
    if item ~= nil then
      A = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    end
  return A
end

function ChapRid(chappy, seed, subs ) -- Get rid of the "CHAP=" ID3 Tag or other stuff to prevent any error by user
  local ridchap
  if subs == nil then subs = "" end
  if chappy == nil then return end
  ridchap = string.gsub (chappy, seed,  subs)
  return ridchap
end

function file_exists(name) -- Checks if mandatory library is installed
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function SecondsToClock(seconds) -- Turns seconds into the format: "hh:mm:ss"
  local seconds = tonumber(seconds)
  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return mins..":"..secs
  end
end

--------------------------------------------------------------------
-- Loads the mandatory library
--------------------------------------------------------------------
if file_exists(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua") == false then 
    local v = [[
              ULTRASCHALL Library should be installed.
              Copy the follwing link
            
              https://github.com/Ultraschall/ultraschall-lua-api-for-reaper/raw/master/ultraschall_api_index.xml
             
              into:
            
              Extensions > ReaPack > Import repositories...
            
              install it and activate it by runinng:
            
              Actions > Script: ultraschall_Add_Developertools_To_Reaper.lua > Run/Close
              ]]
  
    reaper.MB(v,'ATTENTION',0)
    return
  else
    dofile(reaper.GetResourcePath()..UltraschallLua)
end


reaper.Main_OnCommand(40290,0) -- Select the Item

--------------------------------------------------------------------
-- Get the marker position, extract the ID, POSITION and NAME
-- it assign these to a more human readable variables
-- If "markerNAME" is nil, then it assigns a null string
-- to prevent errors
--------------------------------------------------------------------
local offset = 0.01
region_ = ultraschall.GetRegionByTime(reaper.GetCursorPosition(0)+offset)
regionData = Split(region_, LF)
regionID = regionData[1]
regionPOS = regionData[2]
regionNAME = regionData[3]
if regionNAME == nil then -- Converts a "nil" to an empty string
   regionNAME = ""
end


--------------------------------------------------------------------
-- Checks weheather the region belongs to a song
-- TRUE: it belongs to an existent song region
-- FALSE: it doesn't belong to an existent song region
--------------------------------------------------------------------
if string.match(region_, chap) == chap then
    flag = true
  else
    flag = false
end


regionNAME = ChapRid(regionNAME, chap)
regionNAME = Split(regionNAME, pipe)
  
if flag then
 if regionNAME[2] ~= nil then
    SongTitle = regionNAME[2]
    SongPerformer = regionNAME[3]
    
    -- Not mandatory fields
    if regionNAME[3] ~= nil then
      songYear = regionNAME[4]
    else
      songYear = ""
    end
    
    if regionNAME[4] ~= nil then
      songLabel = regionNAME[5]
    else
      songLabel =""
    end
 end
else
  SongTitle = ""
  SongPerformer = ""
  songYear = ""
  songLabel = ""
end

--------------------------------------------------------------------
-- Checks wehether a song is selected
--------------------------------------------------------------------
if get_item_length() == nil then
reaper.MB("SELECT A SONG FIRST!", "WARNING", 0)
return
end

--------------------------------------------------------------------
-- Calcualates the Item Lenght in seconds, rounded up to the
-- first decimal
--------------------------------------------------------------------
local roundup = math.floor(get_item_length() * 10) / 10
itemduration = roundup


--------------------------------------------------------------------
-- Asks for user's inputs
--------------------------------------------------------------------
repeat
retval, InputString=reaper.GetUserInputs("PODCAST/BROADCAST: SONG DATA", 2, "Song Title (Mandatory),separator=\n,extrawidth=400,Performer (Mandatory),Production Year,Label", SongTitle..LF..SongPerformer)
InputString = ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(InputString, pipe), '-'), ':'), '='), '"'), '|') -- No reserved characters can be written
if retval==false then return end
if retval then
  t = {}
  i = 0
  for line in InputString:gmatch("[^" .. LF .. "]*") do
      i = i + 1
      t[i] = line
  end
end
until( t[1] ~= "" and t[2]~= "" )
InputString_TITLE = t[1]:upper()
InputString_PERFORMER= t[2]:upper()


--------------------------------------------------------------------
-- Checks for presence of data in not-mandatory fields
--------------------------------------------------------------------
-- if t[3] ~= "" then
--     InputString_PRODUCTION_YEAR = pipe..t[3]:upper()
--     --InputString_PRODUCTION_YEAR_SideCar = ' - '..t[3]:upper()
--   else
--     InputString_PRODUCTION_YEAR = pipe..t[3]:upper()
--     --InputString_PRODUCTION_YEAR_SideCar = ""
-- end

-- if t[4] ~= "" then
--    InputString_PRODUCTION_LABEL = pipe..t[4]:upper()
--    --InputString_PRODUCTION_LABEL_SideCar = ' - '..t[4]:upper()
--   else
--    InputString_PRODUCTION_LABEL = pipe..t[4]:upper()
--    --InputString_PRODUCTION_LABEL_SideCar = ""
-- end


--------------------------------------------------------------------
-- Creates Region and Titles it
--------------------------------------------------------------------
local song = InputString_TITLE..pipe..InputString_PERFORMER..pipe..itemduration
create_region(song, regionID, flag)
reaper.Main_OnCommand(40020,0)


--------------------------------------------------------------------
-- Estabilshes how many markers/regions are located into the project
--------------------------------------------------------------------
numMarkers = 0
repeat
  mkr = reaper.EnumProjectMarkers(numMarkers)
  numMarkers = numMarkers+1
until mkr == 0
i = 0


--------------------------------------------------------------------
-- Writes the SideCar file down, all the regions with a name
-- starting with "CHAP="
--------------------------------------------------------------------
local item_start_ = {}
local item_end_ = {}

while i < numMarkers-1 do

  local ret, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
  item_start_[i] = math.floor(math.abs(pos))
  
  if string.match(name, chap) and string.match(name, pipe) then
    local SideCar_ = string.match(ChapRid(name, chap, ""), pipe..'(.*)')
    local a, b, c = string.match(SideCar_, "(.*)|(.*)|(.*)")
    item_end_[i] = item_start_[i] + math.floor(c) + 1
    if item_start_[i-1] == nil then item_start_[i-1] = 0 end
    if item_end_[i-1] == nil then item_end_[i-1] = 0 end    
    local diff = item_start_[i]-item_end_[i-1]
    
    SideCar_ = a..' - '..b..' - '..SecondsToClock(c)
    if item_start_[i] == 0 then item_start_[i] = 1 end
    SideCar_ = item_start_[i]..',1,'..'"'..SideCar_..'"'
    
    if item_end_[i-1] == 0 then item_end_[i-1] = 1 end

      Broadcast_ID = item_end_[i-1]..',1,"'..pj_name_:upper()..' - '..author:upper()..'"'

    if diff  > 15 then
       -- Broadcast_ID = item_end_[i-1]..',1,"'..pj_name_:upper()..' - '..author:upper()..'"'
        SideCar:write( Broadcast_ID..LF )
        SideCar:write( SideCar_..LF )
      else
        SideCar:write( SideCar_..LF )
    end
    
  end
  i = i+1
end
if item_start_[i] == nil then
  item_end_[i-1] = item_end_[i-1]-3 -- 3 seconds  before EOF returns the Broadcast ID
  SideCar:write( item_end_[i-1]..',1,"'..pj_name_:upper()..' - '..author:upper()..' >"'..LF )
end

SideCar:close()
reaper.Undo_OnStateChangeEx("PODCAST/BROADCAST: SONG DATA", -1, -1)
