--[[
@description Chapter region for podcasts and recorded broadcasts retrieving the metadata from the Source file
@author Tormy Van Cool
@version 1.0
@screenshot Example: Podcasts_songs.lua in action https://github.com/tormyvancool/TormyVanCool_ReaPack_Scripts/Region.gif
@changelog:
v1.0 (30 jul 2022)
  + Initial release
@credits: spk77 for have inspired the fundament of the code about retreive MetaDAta from Item https://forum.cockos.com/showpost.php?p=1547440&postcount=2
]]
--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
reaper.Undo_BeginBlock()
local chap = "CHAP="
local pipe = "|"
local LF = "\n"
local debug = false
local extension = ".txt"
local UltraschallLua = "/UserPlugins/ultraschall_api.lua"
local author = reaper.GetSetProjectAuthor(0, 0, '')
local InputString_TITLE, InputString_PERFORMER, InputString_PRODUCTION_YEAR, InputString_LABEL  = '', '', '', ''
local region_, regionData, regionID, regionPOS, regionNAME, pj_name_, pj_name, SideCar, itemduration, warning_ = '', '', '', '', '', '', '', '', '', ''
local item = reaper.GetSelectedMediaItem(0,0) -- get first selected item
-- No selected items
if item == nil then
  msg("No item selected")
return false end

-- Empty item (no takes in item)
local take = reaper.GetActiveTake(item)
if take == nil then
  msg("Empty item?")
return false end
-- create "SourceProperties" array 
--ret, section, start, length, fade, reverse = reaper.BR_GetMediaSourceProperties(take)
local t = {}
local ret = false
ret, t.section, t.start, t.length, t.fade, t.reverse = reaper.BR_GetMediaSourceProperties(take)
if ret == false then
  return false
end

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
SideCar = io.open(pj_path..'\\'..pj_name, "w")
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
--reaper.ShowConsoleMsg("INSTRUCTIONS\n\n\nSONG TITLE and PERFORMER are mandatory fields.\n\nPRODUCTION YEAR and LABEL(s) [Optional fields] check on:\nhttps://www.discogs.com or\nhttps://www.musicbrainz.org\n\nYou can select the links above, copy them and paste into the browser\n\nPRODUCTION LABELS(s):\nin case of multiple labels, separate them by commas")
repeat

reaper.BR_SetMediaSourceProperties(take, false, t.start, t.length, t.fade, false)
    t.take_source = reaper.GetMediaItemTake_Source(take) -- get media source
    t.take_source_filename = reaper.GetMediaSourceFileName(t.take_source, "")  -- get media source filename
    PCM_source = reaper.PCM_Source_CreateFromFileEx(t.take_source_filename,false)
    retval, songPerformer = reaper.GetMediaFileMetadata(PCM_source, "ID3:TPE1")
    retval, songTitle = reaper.GetMediaFileMetadata(PCM_source, "ID3:TIT2")
    retval, songYear = reaper.GetMediaFileMetadata(PCM_source, "ID3:TYER")
    retval, songLabel = reaper.GetMediaFileMetadata(PCM_source, "ID3:TCOP")
    if debug == true then reaper.ShowConsoleMsg(songPerformer..' '..songTitle..' '..songYear..' '..songLabel..'\n') end
    InputString = songTitle..LF..songPerformer..LF..songYear..LF..songLabel
-- retval, InputString=reaper.GetUserInputs("PODCAST/BROADCAST: SONG DATA", 4, "Song Title (Mandatory),separator=\n,extrawidth=400,Performer (Mandatory),Production Year,Label(s) (separated by commas)", SongTitle..LF..SongPerformer..LF..SongYear..LF..SongLabel)
InputString = ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(InputString, pipe), '-'), ':'), '='), '"'), '|'), ';') -- No reserved characters can be written
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
InputString_TITLE = t[1]:upper()
InputString_PERFORMER= t[2]:upper()


--------------------------------------------------------------------
-- Checks for presence of data in not-mandatory fields
--------------------------------------------------------------------
if t[3] ~= "" then
  InputString_PRODUCTION_YEAR = t[3]:upper()
else
  InputString_PRODUCTION_YEAR = 'N/A'
  --InputString_PRODUCTION_YEAR_SideCar = ""
end

if t[4] ~= "" then
  InputString_PRODUCTION_LABEL = t[4]:upper()
else
  InputString_PRODUCTION_LABEL = 'N/A'
  --InputString_PRODUCTION_LABEL_SideCar = ""
end

--------------------------------------------------------------------
-- Creates Region and Titles it
--------------------------------------------------------------------
local song = InputString_TITLE..pipe..InputString_PERFORMER..pipe..InputString_PRODUCTION_YEAR..pipe..InputString_PRODUCTION_LABEL..pipe..itemduration
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
local pj_name_clean = ChapRid(pj_name_:upper(), "-", ">")
local author_clean = ChapRid(author:upper(), "-", "&")
while i < numMarkers-1 do

  local ret, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
  item_start_[i] = math.floor(math.abs(pos))
  
  if string.match(name, chap) and string.match(name, pipe) then
    local SideCar_ = string.match(ChapRid(name, chap, ""), pipe..'(.*)')
    local a, b, c, d, e = string.match(SideCar_, "(.*)|(.*)|(.*)|(.*)|(.*)")
    --[[
      a = title
      b = performer
      c = production year
      d = label(s)
      e = song's duration
    ]]--
    item_end_[i] = item_start_[i] + math.floor(e) + 1
    if item_start_[i-1] == nil then item_start_[i-1] = 0 end
    if item_end_[i-1] == nil then item_end_[i-1] = 0 end    
    local diff = item_start_[i]-item_end_[i-1]
    
    SideCar_ = b..' - '..a..' - '..c..' - '..d..' - '..SecondsToClock(e)
    if item_start_[i] == 0 then item_start_[i] = 1 end
      SideCar_ = item_start_[i]..',1,'..'"'..SideCar_..'"'
    
    if item_end_[i-1] == 0 then item_end_[i-1] = 1 end

    Broadcast_ID = item_end_[i-1]..',1,"'..pj_name_clean..' - '..author_clean..'"'

    if diff  > 7 then
       -- Broadcast_ID = item_end_[i-1]..',1,"'..pj_name_:upper()..' - '..author:upper()..'"'
        SideCar:write( Broadcast_ID..LF )
        SideCar:write( SideCar_..LF )
      else
        SideCar:write( SideCar_..LF )
    end
    
  end
  i = i+1
end
if item_start_[i] == nil and item_end_[i] ~= nil then
  item_end_[i-1] = item_end_[i-1]-5 -- 5 seconds  before EOF returns the Broadcast ID
  if string.find(pj_name_, "-") then
  podcast_part = ' | End '..string.match(pj_name_, "-(.*)")..' >'
  else
  podcast_part = ' | The End >'
  end
  SideCar:write( item_end_[i-1]..',1,"'..pj_name_clean..' - '..author_clean..podcast_part..'"'..LF )
end

SideCar:close()
reaper.Undo_OnStateChangeEx("PODCAST/BROADCAST: SONG DATA", -1, -1)
