--[[
@description Assign Performer and Title to a song's Region
@author Tormy Van Cool
@version 1.3
@screenshot Example:
@changelog:
v1.0 (21 may 2022)
  + Initial release
v1.1 (22 may 2022)
  - NA
  + UNKNOWN
v1.2 (22 may 2022)
  - upper
  + normal
v1.3 (03 october 2022)
  + Forbidden characters list
  + Forbidden characters: /, \
  + version
  + by
]]
--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
reaper.Undo_BeginBlock()
local chap = "CHAP="
local pipe = "|"
local LF = "\n"
local extension = ".txt"
local UltraschallLua = "/UserPlugins/ultraschall_api.lua"
local forbiddenChars = [[
_________________________________________________________
FORBIDDEN CHARS:

These characters will be replaced with a SPACE:

        :
        -
        :
        =
        "
        |
        /
        \
        |
        ;
_________________________________________________________


]]
local author = reaper.GetSetProjectAuthor(0, 0, '')
local InputString_TITLE, InputString_PERFORMER, InputString_PRODUCTION_YEAR, InputString_LABEL  = ""
local region_, regionData, regionID, regionPOS, regionNAME, pj_name_, pj_name, SideCar, itemduration, warning_ = ""
local version = "1.3"
local by = "Tormy Van Cool"
local MainTitle = "SONG DATA LIBRARY - v" .. version .. " by " .. by


--------------------------------------------------------------------
-- Functions declaration
--------------------------------------------------------------------
function create_region(region_name, region_ID, flag)
 if region_ID ~= "" and flag == true then
    reaper.DeleteProjectMarker(0, region_ID, 1)
 end
 local color = reaper.ColorToNative(57,65,34)
 local ts_start, ts_end = reaper.GetSet_LoopTimeRange(false, false, 0, 0, false)
 if ts_start == ts_end then return end
 local item_start = math.floor(ts_start*100) /100
 reaper.AddProjectMarker2(0, true, ts_start, ts_end, region_name, -1, color)
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
  local ridchap = string.gsub (chappy, seed,  subs)
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
    local hours = string.format("%02.f", math.floor(seconds/3600));
    local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return mins..":"..secs
  end
end



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
pj_name = ChapRid(pj_name_..extension, "-", " ")


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
local count = 0
for i in region_:gmatch("|") do
    count = count + 1
end
if count == 5 then
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
      SongYear = regionNAME[4]
    else
      SongYear = ""
    end
    
    if regionNAME[4] ~= nil then
      SongLabel = regionNAME[5]
    else
      SongLabel =""
    end
 end
else
  SongTitle = ""
  SongPerformer = ""
  SongYear = ""
  SongLabel = ""
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
reaper.ShowConsoleMsg("")
reaper.ShowConsoleMsg(MainTitle .. LF .. LF .. LF .. LF .. "INSTRUCTIONS".. LF.. LF.. forbiddenChars .. 
"PERFORMER and SONG TITLE are mandatory fields.\nIn case of multiple performers, separate them with a comma.\n\nPRODUCTION YEAR and LABEL(s) [Optional fields] check on:" .. LF .. 
"https://www.discogs.com or" .. LF .. 
"https://www.musicbrainz.org" .. LF .. LF ..
"You can select the links above, copy them and paste into the browser" .. LF .. LF ..
"PRODUCTION LABELS(s):" .. LF ..
"in case of multiple labels, separate them by commas")
repeat
retval, InputString=reaper.GetUserInputs(MainTitle, 4, "Performer (Mandatory),separator=\n,extrawidth=400,Song Title (Mandatory),Production Year,Label(s) (separated by commas)", SongPerformer..LF..SongTitle..LF..SongYear..LF..SongLabel)
InputString = ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(InputString, pipe), '-'), ':'), '='), '"'), '|'), ';'), '/', ' '), '\\', ' ') -- No reserved characters can be written
if retval==false then return end
if retval then
  t = {}
  i = 0
  for line in InputString:gmatch("[^" .. LF .. "]*") do
      i = i + 1
      t[i] = line
  end
end
if tonumber(t[3]) == nil and t[3] ~= "N/A" and t[3] ~= '' then
  reaper.MB("Error Field YEAR\n\nAccepted only:\n- NUMBERS, i.e. 1995\n- EMPTY FIELD (in case YEAR is unknown)","WARNING",0,0)
  flag = false
 else
  flag = true
end
if t[1]== "" then
  reaper.MB("Field SONG TITLE is MANDATORY","ERROR",0,0)
end
if t[2]== "" then
  reaper.MB("Field PERFORMER is MANDATORY","ERROR",0,0)
end
if string.len(tostring(t[3])) ~= 4 and string.len(tostring(t[3])) > 0 and tostring(t[3]) ~= "N/A" then
   reaper.MB("YEAR must be 4 (four) digits","WARNING",0)
   warning_ = false
else
   warning_ = true
end

until( t[1] ~= "" and t[2]~= "" and flag == true and warning_ == true)
--InputString_PERFORMER = t[1]:upper()
--InputString_TITLE= t[2]:upper()
InputString_PERFORMER = t[1]
InputString_TITLE= t[2]

--------------------------------------------------------------------
-- Checks for presence of data in not-mandatory fields
--------------------------------------------------------------------
if t[3] ~= "" then
  --InputString_PRODUCTION_YEAR = t[3]:upper()
  InputString_PRODUCTION_YEAR = t[3]
else
  InputString_PRODUCTION_YEAR = 'Unknown'
  --InputString_PRODUCTION_YEAR_SideCar = ""
end

if t[4] ~= "" then
  --InputString_PRODUCTION_LABEL = t[4]:upper()
  InputString_PRODUCTION_LABEL = t[4]
else
  InputString_PRODUCTION_LABEL = 'Unknown'
  --InputString_PRODUCTION_LABEL_SideCar = ""
end

--------------------------------------------------------------------
-- Creates Region and Titles it
--------------------------------------------------------------------
local song = InputString_PERFORMER..pipe..InputString_TITLE..pipe..InputString_PRODUCTION_YEAR..pipe..InputString_PRODUCTION_LABEL..pipe..itemduration
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
reaper.Undo_OnStateChangeEx(MainTitle, -1, -1)
