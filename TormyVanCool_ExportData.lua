-- https://forum.cockos.com/archive/index.php/t-209658.html
-- https://forum.cockos.com/showthread.php?t=238421
-- https://www.extremraym.com/en/downloads/reascripts-html-export/?fbclid=IwAR1W-wr0qf5M7hUaaTf_ca7WmI98Ty9BsGKXMIB-sHhD6xL5GmcsFxZ9W9k
--[[
@description Exporets project's data related to tracks, into CSV and HTML file
@author Tormy Van Cool
@version 1.0.1
@screenshot
@changelog:
v1.0 (18 may 2021)
  + Initial release
v1.0.1 (18 may 2021)
  + Added pop-up when files are saved
v1.0.2 (18 may 2021)
  + Pup up if project is not saved
@credits Mario Bianchi for his contribution to expedite the process
]]--

--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
local PageHeaderCSV = 'TRACK IDX|TRACK NAME|TRACK TYPE|N. ITEMS|SOLO|MUTE|FX/INSTRUMENTS NAME (VST/VSTi)|FX En./Byp.|FX OnLine/OffLine|FX File'
local LF = "\n"
local CSV = ".csv"
local HTML = ".html"
local pj_name_ = reaper.GetProjectName(0, "")
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
local pj_name_ = string.gsub(string.gsub(pj_name_, ".rpp", ""), ".RPP", "")
local f_csv=io.open(pj_path .. '\\' .. pj_name_..CSV,"w")
local f_html=io.open(pj_path .. '\\' .. pj_name_..HTML,"w")
local author = reaper.GetSetProjectAuthor(0, 0, '')
local version = reaper.GetAppVersion()
local PageHeaderHTML = [[
<html>
  <head>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
     <title>]] .. pj_name_ .. [[</title>
     <style>
     body {font-family: Helvetica, sans-serif;}
     #table_header{background: #0057a1; color: white;}
     table{margin-bottom: 120px; width:100%}
     td.solo {background: #ffc107;text-align: center; }
     td.mute {background: red;text-align: center; color: white; }
     tr:nth-child(even) td.disabled { background: #018aff; color: white; text-align: center; }
     tr:nth-child(odd) td.disabled { background: #37a3ff; color: white; text-align: center; }
     tr:nth-child(even) td.enabled { background: #1ec600; color: white; text-align: center; }
     tr:nth-child(odd) td.enabled { background: #2bec08; color: white; text-align: center; }
     td.offline { background: #3a3a3a; color: #ffd400; text-align: center; }
     td.online { text-align: center; }
     tr:nth-child(even) {background: #dddddd}
     tr:nth-child(odd) {background: #f1f1f1}
     th, tr, td {padding: 10px 20px 10px 20px;}
     th.header { background: #2db1ef; color: white; font-size: 51px; position: relative; }
     thead th:first-of-type{ border-top-left-radius: 10px; }
     thead th:last-of-type{ border-top-right-radius: 10px; }
     tr:last-child td:first-child { border-bottom-left-radius: 10px; }
     tr:last-child td:last-child { border-bottom-right-radius: 10px; }
     .center { margin-left: auto; margin-right: auto; }
     .centertext {text-align: center;}
     sub { font-size: 12px; float: right; position: absolute; bottom: 10px; right: 10px; }
     </style>
  </head>
  <body> 
    <table class="center">
      <thead>
        <tr><th colspan="4" class="header">PROJECT DATA</th></tr>
      </thead>
      <tbody>
        <tr id="table_header"><th>PROJECT NAME</th><th>TOTAL TRACKS</th><th>DAW</th><th>AUTHOR</th></th></tr>
        <tr><td class="centertext">]]..pj_name_..[[</td><td class="centertext">]].. reaper.CountTracks() ..[[</td><td class="centertext">REAPER - v.]]..version..[[</td><td class="centertext">]]..author..[[</td></tr>
      </tbody>
    </table>
    <table class="center">
      <thead>
        <tr><th colspan="10" class="header">EFFECTED TRACKS DATA<sub>Exported with 'EXPORT DATA' script by Tormy Van Cool</sub></th></tr>
      </thead>
      <tbody>
        <tr id="table_header"><th colspan="3">TRACK</th><th colspan="3">STATUS</th><th colspan="4">FX and/or INSTRUMENTS(VST/VSTi)</th></tr>
        <tr id="table_header"><th>IDX</th><th>NAME</th><th>TYPE</th><th>N. ITEMS</th><th>SOLO</th><th>MUTE</th><th>NAME</th><th id="EnDis">Enabled<br/>Bypassed</th><th id="OnOff">Online<br/>Offline</th><th>PLUGIN FILE</th></tr>
]]
local PageFooterHTML = "  </tbody>\n</table>\n</html>"
local PageFooterCSV = LF.."|||||||||Exported with 'EXPORT DATA' script by Tormy Van Cool"
if pj_name_ == "" then reaper.MB("The project MUST BE SAVED!!","WARNING",0,0) goto exit
end

f_csv:write( 'PROJECT:'..LF..pj_name_..LF..LF )
f_csv:write( 'TOTAL TRACKS: ' .. reaper.CountTracks() ..LF..LF )
f_csv:write( 'DAW:'..LF ..'REAPER v.' .. version ..LF..LF )
f_csv:write( 'AUTHOR:'..LF..author..LF..LF..PageHeaderCSV..LF )

f_html:write( PageHeaderHTML..LF )


----------------------------------------------
-- FUNCTIONS
----------------------------------------------
function WriteCSV(list)
   f_csv:write( list..LF )
end

function WriteHTML(list)
   f_html:write( list..LF )
end

function main()

  local tr =''
  for i=1,reaper.CountTracks(),1 do
  
    tr=reaper.GetTrack(0,i-1)

    for ii=1,reaper.TrackFX_GetCount(tr),1 do
  
      local ok,FXname=reaper.TrackFX_GetFXName(tr,ii-1,"")
      local _, TrackName = reaper.GetTrackName(tr, "")
      local isFXenabled_ = reaper.TrackFX_GetEnabled(tr,ii-1) -- Checks if plugin BLOCKS is Enabled
      local isOffline_ = reaper.TrackFX_GetOffline(tr,ii-1) -- Checks if plugin is OffLine
      local retval, moduleName = reaper.BR_TrackFX_GetFXModuleName(tr,ii-1) -- Retrieves module name. The DLL (SWS mandatory!)
      local numItems = reaper.GetTrackNumMediaItems(tr) -- Retreives the number of items on that track
      if numItems == 0 then numItems = '-' end
      local retval, flags  = reaper.GetTrackState(tr)
      
      ----------------------------------------------
      -- ASSIGN BINARY STATES TO VARIABLES
      ----------------------------------------------
      if flags &1 == 1 then isFolder = "FOLDER" else isFolder = 'Track' end
      if flags &2 == 2 then isSelected = "SELECTED" else isSelected = '' end
      if flags &4 == 4 then isFXChainenabled = '<td class="enabled">E</td>' else isFXCHainenabled = '<td class="disabled">D</td>' end
      if flags &8 == 8 then isMuted = '<td class="mute">M</td>' isMutedCSV = "M" else isMuted = '<td>&nbsp;</td>' isMutedCSV = "" end 
      if flags &16 == 16 then isSoloed = '<td class="solo">S</td>' isSoloedCSV = "S" else isSoloed = '<td>&nbsp;</td>' isSoloedCSV = '' end
      if flags &32 == 32 then isSipd = "SIP'd" else isSipd = '' end
      if flags &64 == 64 then isRecArmed = "REC ARMED" else isRecArmed = ''end
      if flags &128 == 128 then isRecMonitoring = "REC Monitoring ON" else isRecMonitoring = ''end
      if flags &256 == 256 then isRecAuto = "REC Monitoring AUTO" else isRecAuto = ''end
      if flags &512 == 512 then isHideTCP = "HIDE from TCP" else isHideTCP = ''end
      if flags &1024 == 1024 then isHideMCP = "HIDE from MCP" else isHideMCP = ''end
      
      if isFXenabled_ == true then isFXenabled = '<td class="enabled">Enabled</td>' isFXenabledCSV = "E" else isFXenabled = '<td class="disabled">Bypassed</td>'isFXenabledCSV = "BYPASSED" end
      if isOffline_ == true then isOffline = '<td class="offline">OFF Line</td>' isOfflineCSV = "OFF" else isOffline = '<td class="online">On Line</td>'isOfflineCSV = "On" end

 
       ----------------------------------------------
       -- ASSEMBLING CSV and HTML RECORDS
       ----------------------------------------------
       local list = i  .. '|' .. TrackName  .. '|' .. isFolder .. '|'.. numItems .. '|' .. isSoloedCSV .. '|' .. isMutedCSV .. '|' .. FXname .. '|' .. isFXenabledCSV .. '|' .. isOfflineCSV .. '|' .. moduleName
       local htmlList = '   <tr class=\"tracks\"><td class="centertext">'..i.."</td><td>"..TrackName..'</td><td class="centertext">'..isFolder..'</td><td class="centertext">' .. numItems .. "</td>" ..isSoloed..isMuted.."<td>"..FXname..isFXenabled..isOffline.."</td><td>"..moduleName.."</td></tr>"
       WriteCSV(list)
       WriteHTML(htmlList)

      --[[
      if name=="JS: dummy" then
    
      local val=reaper.TrackFX_GetParam(tr, 0, 0)
        if val==0 then --// checks FX param for desired value
          local _, name = reaper.GetTrackName(tr, "")
          reaper.ShowConsoleMsg("Found FX on track: " .. name)
          --[deselect other tracks, select tr, show selected track fx chain] *****
      end
      end
      ]]--
    end
  end
 
  ----------------------------------------------
  -- CLOSES FILES
  ----------------------------------------------
  f_csv:write( PageFooterCSV..LF )
  f_csv:close()
  f_html:write( PageFooterHTML..LF )
  f_html:close()

  reaper.MB("Files .CSV and HTML saved\ninto the Project Folder","DONE",0,0)

end
----------------------------------------------
-- MAIN CALL FOR SCRIPT FIRE UP
----------------------------------------------
main()
::exit::
