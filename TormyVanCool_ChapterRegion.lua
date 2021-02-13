-- Ver. 2.0 by Tormy Van Cool
--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
reaper.Undo_BeginBlock()
chap = "CHAP="
pipe = "|"
LF = "\n"
extention = ".PodcastSideCar.txt"
UltraschallLua = "/UserPlugins/ultraschall_api.lua"


--------------------------------------------------------------------
-- Checks whehether the project is saved
-- Assigns the name to the SideCar opening it
--------------------------------------------------------------------
local pj_name=reaper.GetProjectName(0, "")
if pj_name == "" then 
  reaper.MB("Save the Project, first!",'WARNING',0)
  return
end
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
pj_name = string.gsub(string.gsub(pj_name, ".rpp", ""), ".RPP", "")..extention
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
 if regionNAME[1] ~= nil then
    SongTitle = ChapRid(regionNAME[1], "Title:")
    SongPerformer = ChapRid(regionNAME[2], "Performer:")
    
    -- Not mandatory fields
    if regionNAME[3] ~= nil then
      songYear = ChapRid(regionNAME[3], "Year:")
    else
      songYear = ""
    end
    
    if regionNAME[4] ~= nil then
      songLabel = ChapRid(regionNAME[4], "Label:")
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
itemduration ='Duration:'..roundup


--------------------------------------------------------------------
-- Asks for user's inputs
--------------------------------------------------------------------
repeat
retval, InputString=reaper.GetUserInputs("PODCAST/BROADCAST: SONG DATA", 4, "Song Title (Mandatory),separator=\n,extrawidth=400,Performer (Mandatory),Production Year,Label", SongTitle..LF..SongPerformer..LF..songYear..LF..songLabel)
InputString = ChapRid(ChapRid(ChapRid(ChapRid(ChapRid(InputString, pipe), '-'), ':'), '='), '"') -- No reserved characters can be written
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
InputString_TITLE='Title:'..t[1]:upper()
InputString_PERFORMER='Performer:'..t[2]:upper()


--------------------------------------------------------------------
-- Checks for presence of data in not-mandatory fields
--------------------------------------------------------------------
if t[3] ~= "" then
    InputString_PRODUCTION_YEAR = pipe..'Year:'..t[3]:upper()
    --InputString_PRODUCTION_YEAR_SideCar = ' - '..t[3]:upper()
  else
    InputString_PRODUCTION_YEAR = pipe..'Year:'..t[3]:upper()
    --InputString_PRODUCTION_YEAR_SideCar = ""
end

if t[4] ~= "" then
    InputString_PRODUCTION_LABEL = pipe..'Label:'..t[4]:upper()
    --InputString_PRODUCTION_LABEL_SideCar = ' - '..t[4]:upper()
   else
    InputString_PRODUCTION_LABEL = pipe..'Label:'..t[4]:upper()
    --InputString_PRODUCTION_LABEL_SideCar = ""
end


--------------------------------------------------------------------
-- Creates Region and Titles it
--------------------------------------------------------------------
local song = chap..InputString_TITLE..pipe..InputString_PERFORMER..InputString_PRODUCTION_YEAR..InputString_PRODUCTION_LABEL..pipe..itemduration
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
while i < numMarkers-1 do
  local ret, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(i)
  local item_start = math.floor(math.abs(pos))
  if string.match(name, chap) and string.match(name, pipe) then
    SideCar_ = ChapRid(name, chap, "")
    SideCar_ = ChapRid(SideCar_, "Title:", "")
    SideCar_ = ChapRid(SideCar_, "Performer:", "")
    SideCar_ = ChapRid(SideCar_, "Duration:", "")
    SideCar_ = ChapRid(SideCar_, "Year:"..pipe, "")
    SideCar_ = ChapRid(SideCar_, "Label:"..pipe, "")
    SideCar_ = ChapRid(SideCar_, "Year:", "")
    SideCar_ = ChapRid(SideCar_, "Label:", "")
    SideCar_ = ChapRid(SideCar_, pipe, " - ")
    SideCar_ = item_start..',1,'..'"'..SideCar_..'"'
    SideCar:write( SideCar_..LF )
  end
  i = i+1
end

SideCar:close()
reaper.Undo_OnStateChangeEx("PODCAST/BROADCAST: SONG DATA", -1, -1)
