--[[
    https://gist.github.com/obikag/6118422
@description Imports Tempo Markers
@author Tormy Van Cool
@version 1.0
@screenshot
@credits: obikag https://gist.github.com/obikag
@changelog:
v1.0 (27 july 2022)
  + Initial release
v1.1 (03 august 2022)
  + avoid line headers
  + version
v1.2 (03 august 2022)
  + gradual change
]]--
local version = "Tempo Markers Import: v1.2"
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")..'/'
local filepath = pj_path..'Tempo_Markers.csv'
local i = 0
local LF = "\n"
local debug = false
TempoMarkersCSV = {}
TempoMarkersCSV.__index = TempoMarkersCSV
reaper.ShowConsoleMsg('')


--Create new object
function TempoMarkersCSV.new()
    self = setmetatable({},TempoMarkersCSV)
      self.csv_table = {}
      return self
end

-------------------------------------------------------
-- Load CSV File into multidimensional table.
-- parmeter: filepath is the location of the csv file
-- returns: True is file exists and has been loaded
-------------------------------------------------------
function TempoMarkersCSV:load_csvfile(filepath)
	local file = io.open(filepath,"r")
	if file then
		for line in file:lines() do
			local temp = {}
			for item in string.gmatch(line,"[^,]*") do --does not work for strings containing ','
				if item ~= "" then
					item = item:gsub(",","")
					item = item:gsub("^%s*(.-)%s*$", "%1") -- remove trailing white spaces
					table.insert(temp,item)
				end
			end
			table.insert(self.csv_table, temp)
            i = i+1
		end
	else
        reaper.MB(filepath.." doesn't exist", version..' - WARNING', 0)
		return false
	end
	return true
end


-------------------------------------------------------
-- Displays the attribute in a particular row and column of the table
-- parameter: row is the row number in the table
-- parameter: column is the column number in the table
-- returns: string value of the attribute
-------------------------------------------------------
function TempoMarkersCSV:get_attribute(row, column)
	if next(self.csv_table) ~= nil then
		if row > #self.csv_table or row < 0 then
            reaper.MB("Row is outside of allowed range", version..' - WARNING', 0)
		else
			row_attr = self.csv_table[row]
			if column > #row_attr or column < 0 then
                reaper.MB("Column is outside of allowed range", version..' - WARNING', 0)
			else
				return row_attr[column]
			end
		end
	else
        reaper.MB(filepath.." doesn't contain required data", version..' - WARNING', 0)
	end
	return "No Attribute found"
end
local csv = TempoMarkersCSV.new()

function Main()
    csv:load_csvfile(filepath)
    local a = 2 -- avoid header line
    local retval = false
    while a <= i do
        local lineartempo = false
        local ptidx = csv:get_attribute(a,1)
        local bpm = csv:get_attribute(a,2) -- From Function 2
        local timepos = csv:get_attribute(a,3) -- From Funtcion 3
        local measurepos = csv:get_attribute(a,4) -- From Function 4
        local Beat = csv:get_attribute(a,5)
        local beatpos = csv:get_attribute(a,6) -- From Function 6
        local SampleQTY = csv:get_attribute(a,7)
        local timesig_num = csv:get_attribute(a,8) -- From Function 8
        local timesig_denom = csv:get_attribute(a,9)  -- From Function 9
        local tempoType = csv:get_attribute(a,10)  -- From Function Lineartempo Boolean
        if tempoType == "0" then
            lineartempo = false
        else
            lineartempo = true 
        end
    retval = reaper.SetTempoTimeSigMarker(0, -1, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo) 
    
        if debug == true then
            reaper.ShowConsoleMsg(ptidx..','..
                                    bpm..', '..
                                    timepos..', '..', '..
                                    measurepos..', '..
                                    Beat..', '..
                                    beatpos..', '..
                                    SampleQTY..', '..
                                    timesig_num.. ','..
                                    timesig_denom.. ', '..
                                    tempoType..', '..' rztzz\n') -- Row Col
        end
    a = a+1
    end
    if retval == true then
        reaper.MB("Tempo Markers Succesfully Created"..LF.."Click on OK and then click into the project, to see the Tempo Envelope", version..' - OK', 0)
    else
        reaper.MB("An error occurred", version..' - WARNING', 0)
    end
end

Main()