--[[
@description CSV containing Time Markers
@author Tormy Van Cool
@version 1.2
@screenshot
@changelog:
v1.0 (23 july 2022)
  + Initial release
v1.1 (23 july 2022)
  # Time in format HH:mm:ss
v1.2 (23 july 2022)
  # Exports with predetermined and univocal file_name
  - Time in format HH:mm:ss
  + Time in format HH:mm:ss in console
  + Line number
  + Fractional Value
  + Info Pop Up
  - Commas
  + Tabs
  + Beat
]]

---------------------------------------------
-- VARIABLES
---------------------------------------------
local version = "1.2"
local extension = ".csv"
local LF = '\n'
local tab = '\t'
local howmany = reaper.CountTempoTimeSigMarkers(0) -- counts markers QTY
local pj_name_ = reaper.GetProjectName(0, "") -- gets project name
local pj_name = "Tempo_Markers".. extension
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1") -- gets project path
local count = 0
local ConsMsg = ''


---------------------------------------------
-- FILE MANAGEMENT
---------------------------------------------
CSV_file = io.open(pj_path..'\\'..pj_name, "w")

---------------------------------------------
-- CSV HEADER
---------------------------------------------
local CSV_header = 'TEMPO MARKERS WRAP UP version '..version.. LF ..'by Tormy VAN COOL'
CSV_file:write(CSV_header)


---------------------------------------------
-- FUNCTIONS
---------------------------------------------
function SecondsToClock(seconds) -- Turns seconds into the format: "hh:mm:ss"
  local seconds = tonumber(seconds)
  if seconds <= 0 then
    return "00:00:00";
  else
    local hours = string.format("%02.f", math.floor(seconds/3600));
    local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    local secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

---------------------------------------------
-- TEMPO MARKERS PROBING
---------------------------------------------
while count < howmany do
  local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker(0, count) -- Extract markers infos
  SampleQTY = reaper.format_timestr_pos( timepos, "", 4 )
  Beat = reaper.format_timestr_pos( timepos, "", 2 )
  csv =  count .. tab .. bpm .. tab .. timepos .. tab .. measurepos .. tab .. beatpos .. tab .. SampleQTY .. tab .. timesig_num ..'\\'.. timesig_denom .. LF
  ConsMsg = ConsMsg .. 'N: '.. count .. LF ..
            'BPM: ' .. bpm .. LF ..
            'Time Position: ' .. SecondsToClock(timepos) .. LF ..
            'Measure Position: ' .. SecondsToClock(measurepos) .. LF ..
            'Beat: ' .. Beat .. LF .. 
            'Beat Position: ' .. SecondsToClock(beatpos) .. LF ..
            'Samples: ' .. SampleQTY .. LF ..
            'Fractional: ' .. timesig_num ..'\\'.. timesig_denom .. LF .. LF
  CSV_file:write(csv)
  count = count +1
end

---------------------------------------------
-- FILE CLOSURE
---------------------------------------------
CSV_file:close()
reaper.MB("File Path: " .. pj_path .. "Saved" ..LF .. "CSV File: "  .. pj_name  , "Saved CSV" ,0)
reaper.ShowConsoleMsg('')
reaper.ShowConsoleMsg(CSV_header .. LF .. LF .. ConsMsg)
