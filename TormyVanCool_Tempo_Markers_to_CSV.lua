--[[
@description CSV containing Time Markers
@author Tormy Van Cool
@version 1.0
@screenshot
@changelog:
v1.0 (23 july 222)
  + Initial release
]]

---------------------------------------------
-- VARIABLES
---------------------------------------------
local version = "1.0"
local extension = ".csv"
local howmany = reaper.CountTempoTimeSigMarkers(0) -- counts markers QTY
local pj_name_ = reaper.GetProjectName(0, "") -- gets project name
local pj_name = pj_name_.. extension
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1") -- gets project path
local count = 0


---------------------------------------------
-- FILE MANAGEMENT
---------------------------------------------
CSV_file = io.open(pj_path..'\\'..pj_name, "w")

---------------------------------------------
-- CSV HEADER
---------------------------------------------
local CSV_header = 'TIME MARKERS WRAP UP version'..version..'\nby Tormy VAN COOL\n\n\nBPM,TIME POSITION,MEASURE POSITION,BEAT POSITION,TIME SIGNATURE'
CSV_file:write(CSV_header)

---------------------------------------------
-- TEMPO MARKERS PROBING
---------------------------------------------
while count < howmany do
  local retval, timepos, measurepos, beatpos, bpm, timesig_num = reaper.GetTempoTimeSigMarker(0, count) -- Extract markers infos
  csv = '\n' .. bpm .. ',' .. timepos .. ',' .. measurepos .. ',' .. beatpos .. ',' .. timesig_num
  CSV_file:write(csv)
  count = count +1
end

---------------------------------------------
-- FILE CLOSURE
---------------------------------------------
CSV_file:close()
