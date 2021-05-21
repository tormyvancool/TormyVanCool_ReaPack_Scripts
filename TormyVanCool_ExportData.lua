-- https://forum.cockos.com/archive/index.php/t-209658.html
-- https://forum.cockos.com/showthread.php?t=238421
-- https://www.extremraym.com/en/downloads/reascripts-html-export/?fbclid=IwAR1W-wr0qf5M7hUaaTf_ca7WmI98Ty9BsGKXMIB-sHhD6xL5GmcsFxZ9W9k
--[[
@description Exporets project's data related to tracks, into CSV and HTML file
@author Tormy Van Cool
@version 2.1
@screenshot
@changelog:
v1.0 (18 may 2021)
  + Initial release
v1.0.1 (18 may 2021)
  + Added pop-up when files are saved
v1.0.2 (18 may 2021)
  + Pup up if project is not saved
v1.0.3 (18 may 2021)
  + Date to file names 
  + Creation date into files 
  + Version into files 
v1.0.4 (18 may 2021)
  + Project Notes
  + Track Notes
  + Project Sample Rate
v2.0 (18 may 2021)
  + Expandable/Collapsible Tables
  + Odd/Even on Mute flag
  + Odd/Even on Solo flag
  + Only noted tracks
  - Pipe separated Values
  + Comma Separated Values
  + Effected items 
  + Noted items 
v2.0.1 (18 may 2021)
  # Buf Fix: all FX where displayed as Disalbed
v2.0.2 (18 may 2021)
  + FX Chain Status
v2.1
  + All Tracks Hierarchy
  + All tracks Statuses
  + Master Channel FX and Notes
  + Precision
  + Project Length HH:MM:SS
@credits Mario Bianchi for his contribution to expedite the process
]]--

----------------------------------------------
-- NUMERICAL FUNCTIONS
----------------------------------------------
function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function SecondsToHMS(seconds)
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
-- Script Initialization
--------------------------------------------------------------------
local LF = "\n"
local CSV = ".csv"
local HTML = ".html"
local scriptVersion = "2.1"
local precision = 4
local pj_notes = reaper.GetSetProjectNotes(0, 0, "")
local pj_sampleRate = reaper.GetSetProjectInfo(0, "PROJECT_SRATE", 0, 0)
local pj_name_ = reaper.GetProjectName(0, "")
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
local pj_name_ = string.gsub(string.gsub(pj_name_, ".rpp", ""), ".RPP", "")
local date = os.date("%Y-%m-%d %H:%M:%S")
local dateFile = '_' .. os.date("%Y-%m-%d_%H.%M.%S")
local f_csv=io.open(pj_path .. '\\' .. pj_name_ .. dateFile .. CSV,"w")
local f_html=io.open(pj_path .. '\\' .. pj_name_ .. dateFile .. HTML,"w")
local author = reaper.GetSetProjectAuthor(0, 0, '')
local version = reaper.GetAppVersion()
local pj_length=round(reaper.GetProjectLength(),precision)


----------------------------------------------
-- MAIN HEADERS
----------------------------------------------
local PageHeaderHTML = [[
<html>
  <head>
     <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
     <title>]] .. pj_name_ .. [[</title>
     <style>
     body {font-family: Helvetica, sans-serif; background: blanchedalmond;}
     td.masterrnotes { width: 87%; }
     span.info {position: absolute; left: 0; }
     .emboss {text-shadow: -2px 2px 4px rgb(0 0 0 / 50%), 2px -2px 0 rgb(255 255 255 / 90%);}
     .engrave {color: transparent; background: #8e8e8e; -webkit-background-clip: text; text-shadow: 2px 5px 5px rgb(255 255 255 / 30%);}
     .pointer {cursor: pointer;}
     .table_header{background: #0057a1 !important; color: white;}
     .statuswidth{width: 13%;}
     .MasterEnabledOnline, .TracksEnabledOnline, .TracksNoted, .EffectedItems { width: 6%; }
     
     table{margin-bottom: 12px; width:90%}
     tr:nth-child(even) td.solo {background: #ffc107;text-align: center; }   
     tr:nth-child(odd) td.solo {background: #ffd149;text-align: center; }
     tr:nth-child(even) td.mute { background: red;text-align: center;color: white; }
     tr:nth-child(odd) td.mute {background: #ef5656;text-align: center;color: white; }
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
     .left{text-align: left;}
     sub { font-size: 12px; float: right; position: absolute; bottom: 10px; right: 10px; }
     .spacer{width: 100%;height:50px}
     .right{text-align: right;}
     .yes { background-color: yellow; }
     </style>
     <script>
      $(document).ready(function() {
          $("tr.slave").hide()
          $("tr.slaveNoted").hide()
          $("tr.slaveFXedItems").hide()
          $("span.collapse").hide()
          $("span.collapseNoted").hide()
          $("span.collapseFXedItems").hide()
          $("tr.slaveNotedItems").hide()
          $("span.collapseNotedItems").hide()
          $("tr.slaveHier").hide()
          $("span.collapseHier").hide()
          $("tr.slaveMaster").hide()
          $("span.collapseMaster").hide()
          
          $(".master").click(function() {
              $("tr.slave").toggle(500);
              $("span.collapse").toggle(500)
              $("span.expand").toggle(500)
          });
          
          $(".masterNoted").click(function() {
              $("tr.slaveNoted").toggle(500);
              $("span.collapseNoted").toggle(500)
              $("span.expandNoted").toggle(500)
          });
          
          $(".masterFXedItems").click(function() {
              $("tr.slaveFXedItems").toggle(500);
              $("span.collapseFXedItems").toggle(500)
              $("span.expandFXedItems").toggle(500)
          });
          
          $(".masterNotedItems").click(function() {
              $("tr.slaveNotedItems").toggle(500);
              $("span.collapseNotedItems").toggle(500)
              $("span.expandNotedItems").toggle(500)
          });          
          
          $(".masterHier").click(function() {
              $("tr.slaveHier").toggle(500);
              $("span.collapseHier").toggle(500)
              $("span.expandHier").toggle(500)
          });
          
          $(".masterMaster").click(function() {
              $("tr.slaveMaster").toggle(500);
              $("span.collapseMaster").toggle(500)
              $("span.expandMaster").toggle(500)
          });
      });
    </script>
  </head>
  <body> 
    <table class="center">
      <thead>
        <tr><th colspan="5" class="header">PROJECT DATA<sub>Created: ]] .. date .. [[ with 'EXPORT DATA' v.]].. scriptVersion .. [[ by Tormy Van Cool</sub></th></tr>
      </thead>
      <tbody>
        <tr class="table_header"><th>PROJECT</th><th>TOTAL TRACKS</th><th>DAW</th><th>AUTHOR</th><th>NOTES</th></tr>
        <tr><td class="left">Name: ]]..pj_name_..[[<br/>Sample Rate: ]]..round(pj_sampleRate,1)..[[Hz<br/>Project Length: ]]..SecondsToHMS(pj_length)..[[</td><td class="centertext">]].. reaper.CountTracks() ..[[</td><td class="centertext">REAPER - v.]]..version..[[</td><td class="centertext">]]..author..[[</td><td>]]..pj_notes..[[</td></tr>
      </tbody>
    </table>
    <div class="spacer">&nbsp;</div>
    ]]

  
  
----------------------------------------------
-- SPECIALIZED HEADER
----------------------------------------------
local PageHeaderMasterCSV = LF..LF..'MASTER CHANNEL:\nFX NAME,FX En./Byp.,FX On Line/Off Line,FILE NAME'
local PageHeaderMasterHTML = [[
     <table class="center">
      <thead>
        <tr class="masterMaster"><th colspan="6" class="header"><span class="info emboss pointer expandMaster">&#x25BC;</span><span class="info engrave pointer collapseMaster">&#x25B2;</span>MASTER CHANNEL</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveMaster"><th colspan="2" class="statuswidth">TRACK SETTINGS</th><th colspan="4">FX (VSTs)</th></tr>
        <tr class="table_header slaveMaster"><th>CONTROLS</th><th>STATUS</th><th>NAME</th><th class="MasterEnabledOnline">Enabled<br/>Bypassed</th><th class="MasterEnabledOnline">On Line<br/>Off Line</th><th>FILE</th></tr>
]]
local PageHeaderHierarchyCSV = LF..LF..'HIERARCHY:\nNAME,TYPE,N.ITEMS,TCP,MCP,FX'
local PageHeaderHierarchyHTML = [[
      <table class="center">
      <thead>
        <tr class="masterHier"><th colspan="7" class="header"><span class="info emboss pointer expandHier">&#x25BC;</span><span class="info engrave pointer collapseHier">&#x25B2;</span>TRACKS HIERARCHY</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveHier"><th>NAME</th><th class="TracksEnabledOnline">TYPE</th><th class="TracksEnabledOnline">N. ITEMS</th><th class="TracksEnabledOnline">TCP</th><th class="TracksEnabledOnline">MCP</th><th class="TracksEnabledOnline">FXed</th><th class="TracksEnabledOnline">FX CHAIN<br/>Enable/Disabled</tr>
]]
local PageHeaderCSV = LF..LF..'EFFECTED TRACKS:\nTRACK IDX,TRACK NAME,TRACK TYPE,NOTES,FX CHAIN En./Dis.,N. ITEMS,SOLO,MUTE,FX/INSTRUMENTS NAME (VST/VSTi),FX En./Byp.,FX OnLine/OffLine,FX File'
local tableFXTracksHeader = [[
    <div class="spacer">&nbsp;</div>
    <table class="center">
      <thead>
        <tr><th colspan="12" class="header"><span class="info expand emboss pointer master">&#x25BC;</span><span class="info collapse engrave pointer master">&#x25B2;</span>EFFECTED TRACKS</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slave"><th colspan="5">TRACK</th><th colspan="3">STATUS</th><th colspan="4">FX and/or INSTRUMENTS(VST/VSTi)</th></tr>
        <tr class="table_header slave"><th>IDX</th><th>NAME</th><th>TYPE</th><th>NOTES</th><th>FX Chain<br/>En./Dis.</th><th>N. ITEMS</th><th>SOLO</th><th>MUTE</th><th>NAME</th><th id="EnDis">Enabled<br/>Bypassed</th><th id="OnOff">On Line<br/>Off Line</th><th>PLUGIN FILE</th></tr>
]]
local PageHeaderCSVNoted = LF..LF..'NOTED TRACKS:\nTRACK IDX,TRACK NAME,TRACK TYPE,NOTES,N. ITEMS,SOLO,MUTE'
local tableNotedTracksHeader = [[
   <table class="center">
      <thead>
        <tr><th colspan="7" class="header"><span class="info expandNoted emboss pointer masterNoted">&#x25BC;</span><span class="info collapseNoted engrave pointer masterNoted">&#x25B2;</span>NOTED TRACKS</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveNoted"><th colspan="4">TRACK</th><th colspan="3">STATUS</th></tr>
        <tr class="table_header slaveNoted"><th class="TracksNoted">IDX</th><th>NAME</th><th class="TracksNoted">TYPE</th><th>NOTES</th><th class="TracksNoted">N. ITEMS</th><th class="TracksNoted">SOLO</th><th class="TracksNoted">MUTE</th></tr>
]]
local PageHeaderItemsFXedCSV = LF..LF..'EFFECTED ITEMS:\nTRACK NAME,FX,ITEM POSITION,ITEM LENGTH,NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
local PageHeaderItemsFXedHTML = [[ 
    <div class="spacer">&nbsp;</div>
    <table class="center">
      <thead>
        <tr><th colspan="10" class="header"><span class="info expandFXedItems emboss pointer masterFXeditems">&#x25BC;</span><span class="info collapseFXedItems engrave pointer masterFXedItems">&#x25B2;</span>EFFECTED ITEMS DATA</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveFXedItems"><th colspan="5">MAIN DATA</th><th colspan="2">STATUS</th><th colspan="3">SOURCE</th></tr>
        <tr class="table_header slaveFXedItems"><th>BELONGIN TO</th><th>FX</th><th class="EffectedItems">POSITION</th><th class="EffectedItems">LENGTH</th><th>NOTES</th><th class="EffectedItems">MUTE</th><th class="EffectedItems">LOCKED</th><th>SOURCE NAME</th><th class="EffectedItems">SAMPLE RATE</th><th class="EffectedItems">BIT DEPTH</th></tr>
]]
local PageHeaderNotedItemsCSV = LF..LF..'NOTED ITEMS:\nTRACK NAME,ITEM POSITION,ITEM LENGTH,NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
local PageHeaderNotedItemsHTML = [[
    <table class="center">
      <thead>
        <tr><th colspan="9" class="header"><span class="info expandNotedItems emboss pointer masterNotedItems">&#x25BC;</span><span class="info collapseNotedItems engrave pointer masterNotedItems">&#x25B2;</span>NOTED ITEMS DATA</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveNotedItems"><th colspan="4">MAIN DATA</th><th colspan="2">STATUS</th><th colspan="3">SOURCE</th></tr>
        <tr class="table_header slaveNotedItems"><th>BELONGIN TO</th><th>POSITION</th><th>LENGTH</th><th>NOTES</th><th class="EffectedItems">MUTE</th><th class="EffectedItems">LOCKED</th><th>SOURCE NAME</th><th class="EffectedItems">SAMPLE RATE</th><th class="EffectedItems">BIT DEPTH</th></tr>
]]

local PageFooterHTML = "  \n</body>\n</html>"
local PageFooterCSV = LF..",,,,,,,,,,,Exported with 'EXPORT DATA' v." .. scriptVersion .. " by Tormy Van Cool"
if pj_name_ == "" then reaper.MB("The project MUST BE SAVED!!","WARNING",0,0) return --goto exit
end


----------------------------------------------
-- FILES INITIALIZATION
----------------------------------------------
f_csv:write( 'PROJECT:'..LF..'Name: '..pj_name_..LF..'Sample Rate: '..pj_sampleRate..'Hz'..LF..'Duration: '..SecondsToHMS(pj_length)..LF..LF )
f_csv:write( 'TOTAL TRACKS: ' .. reaper.CountTracks() ..LF..LF )
f_csv:write( 'DAW:'..LF ..'REAPER v.' .. version ..LF..LF )
f_csv:write( 'CREATED:'..LF .. date ..LF..LF )
f_csv:write( 'AUTHOR:'..LF..author..LF..LF )
f_html:write( PageHeaderHTML..LF )

----------------------------------------------
-- MAIN FUNCTIONS
----------------------------------------------
function WriteFILE(listHTML,listCSV)
   f_csv:write( listCSV..LF )
   f_html:write( listHTML..LF )
end

function ridCommas(a)
   a_ = a:gsub(","," - ")
   return a_
end

function recursiveAppend(var,ii)
local t = {}
    for i = 1, ii do
        table.insert(t, tostring(var))
    end
    local a = table.concat(t)
    return a
end

function Master()

  WriteFILE(PageHeaderMasterHTML,PageHeaderMasterCSV)
  local masterChannel = reaper.GetMasterTrack(0)
  local retval, masterFlags  = reaper.GetTrackState(masterChannel)
    if masterFlags &8 == 8 then isMasterMuted = '<td class="mute centertext">M</td>' isMasterMutedCSV = "M" else isMasterMuted = '<td>&nbsp;</td>' isMasterMutedCSV = "" end 
    if masterFlags &16 == 16 then isMasterSoloed = '<td class="solo centertext">S</td>' isMasterSoloedCSV = "S" else isMasterSoloed = '<td>&nbsp;</td>' isMasterSoloedCSV = '' end
    if masterFlags &32 == 32 then isMastreSipd = "SIP'd" else isMastreSipd = '' end
    if masterFlags &4 == 4 then isMasterFXChainenabled_ = '<td class="enabled centertext">Enabled</td>' isMasterFXChainenabledCSV_ = 'E' else isMasterFXChainenabled_ = '<td class="disabled">Disabled</td>' isMasterFXChainenabledCSV_ = 'D' end
    if masterFlags &512 == 512 then isHideTCP = '<td class="mute centertext">HIDDEN</td>' isHideTCPCSV = 'H' else isHideTCP = '<td class="centertext">VISIBLE</td>' isHideTCPCSV = 'V' end
    if masterFlags &1024 == 1024 then isHideMCP = '<td class="mute centertext">HIDDEN</td>'  isHideMCPCSV = 'H' else isHideMCP = '<td class="centertext">VISIBLE</td>'isHideMCPCSV = 'V' end
  
  for ii=1,reaper.TrackFX_GetCount(masterChannel),1 do
    --if reaper.TrackFX_GetCount(masterChannel) > 0 then FXed = "Yes" else FXed = "No" end
    local ok,FXname=reaper.TrackFX_GetFXName(masterChannel,ii-1,"")
    local isMasterFXenabled_ = reaper.TrackFX_GetEnabled(masterChannel,ii-1) -- Checks if plugin BLOCKS is Enabled
    local isMasterOffline_ = reaper.TrackFX_GetOffline(masterChannel,ii-1) -- Checks if plugin is OffLine
    local retval, moduleName = reaper.BR_TrackFX_GetFXModuleName(masterChannel,ii-1) -- Retrieves module name. The DLL (SWS mandatory!)

    if isMasterFXenabled_ == true then isMasterFXenabled = '<td class="enabled centertext">Enabled</td>' isMasterFXenabledCSV = "E" else isMasterFXenabled = '<td class="disabled cenertext">Bypassed</td>'isMasterFXenabledCSV = "BYPASSED" end
    if isMasterOffline_ == true then isMasterOffline = '<td class="offline centertext">OFF Line</td>' isMasterOfflineCSV = "OFF Line" else isMasterOffline = '<td class="online centertext">On Line</td>'isMasterOfflineCSV = "On Line" end
  
  
  lineCSV = FXname..','..isMasterFXenabledCSV..','..isMasterOfflineCSV..','..moduleName
  lineHTML = '   <tr class="tracks slaveMaster status"><td colspan="2"></td><td>'..FXname..'</td>'..isMasterFXenabled..isMasterOffline..'<td>'..moduleName..'</tr>'
  WriteFILE(lineHTML,lineCSV)

  end

   masterNotes = reaper.NF_GetSWSTrackNotes(masterChannel)
   local MasterNotesCSV = ridCommas(masterNotes)
   local line_1 = '<tr class="tracks slaveMaster"><td><b>MUTE</b></td>'..isMasterMuted..'<td colspan="4" class="centertext"><b>NOTES</b></td></tr>'
   local line_2 = '<tr class="tracks slaveMaster"><td><b>SOLO</b></td>'..isMasterSoloed..'<td rowspan="4" colspan="4" class="masterNotes">'..masterNotes..'</td></tr>'
   local line_3 = '<tr class="tracks slaveMaster"><td><b>FX CHAIN</b></td>'..isMasterFXChainenabled_..'</tr>'
   local line_4 = '<tr class="tracks slaveMaster"><td><b>TCP</b></td>'..isHideTCP..'</tr>'
   local line_5 = '<tr class="tracks slaveMaster"><td><b>MCP</b></td>'..isHideMCP..'</tr>'
   local csv_1 = '\nMASTER TRACK SETTINGS:\nMUTE,SOLO,FX CHAIN,TCP,MCP,NOTES\n'
   local csv_2 = isMasterMutedCSV..','..isMasterSoloedCSV..','..isMasterFXChainenabledCSV_..','..isHideTCPCSV..','..isHideMCPCSV..','..MasterNotesCSV
   WriteFILE(line_1..line_2..line_3..line_4..line_5,lineCSV..','..csv_1..csv_2)
    -- ridCommas(MasterNotes)  
   WriteFILE("  </tbody>\n</table>","")
end



function Hierarchical()
  WriteFILE(PageHeaderHierarchyHTML,PageHeaderHierarchyCSV)
  for i= 1, reaper.CountTracks() do 
  
    tr=reaper.GetTrack(0,i-1)
 
    local _, TrackName = reaper.GetTrackName(tr, "")
    local numItems = reaper.GetTrackNumMediaItems(tr) -- Retreives the number of items on that track
    if numItems == 0 then numItems = '-' end
    local retval, flags  = reaper.GetTrackState(tr)
    local hasFX = reaper.TrackFX_GetCount(tr)
    if hasFX ~= 0 then FXed = '<td class="yes centertext">Yes</td>' FXedCSV = 'Yes' else FXed = '<td class="no centertext">No</td>' FXedCSV = 'No' end
    --local folderDepth = reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH")
    local folderDepth =  15*reaper.GetTrackDepth(tr)
    
    
    ----------------------------------------------
    -- ASSIGN BINARY STATES TO VARIABLES
    ----------------------------------------------
    if flags &1 == 1 then isFolder = "FOLDER" else isFolder = 'Track' end
    if flags &2 == 2 then isSelected = "SELECTED" else isSelected = '' end
    if flags &4 == 4 then isFXChainenabled_ = '<td class="disabled">Disabled</td>' isFXChainenabledCSV_ = 'D' else isFXChainenabled_ = '<td class="enabled">Enabled</td>' isFXChainenabledCSV_ = 'E' end
    if flags &8 == 8 then isMuted = '<td class="mute">M</td>' isMutedCSV = "M" else isMuted = '<td>&nbsp;</td>' isMutedCSV = "" end 
    if flags &16 == 16 then isSoloed = '<td class="solo">S</td>' isSoloedCSV = "S" else isSoloed = '<td>&nbsp;</td>' isSoloedCSV = '' end
    if flags &32 == 32 then isSipd = "SIP'd" else isSipd = '' end
    if flags &64 == 64 then isRecArmed = "REC ARMED" else isRecArmed = ''end
    if flags &128 == 128 then isRecMonitoring = "REC Monitoring ON" else isRecMonitoring = ''end
    if flags &256 == 256 then isRecAuto = "REC Monitoring AUTO" else isRecAuto = ''end
    if flags &512 == 512 then isHideTCP = '<td class="mute centertext">HIDDEN</td>' isHideTCPCSV = 'H' else isHideTCP = '<td class="centertext">VISIBLE</td>' isHideTCPCSV = 'V' end
    if flags &1024 == 1024 then isHideMCP = '<td class="mute centertext">HIDDEN</td>'  isHideMCPCSV = 'H' else isHideMCP = '<td class="centertext">VISIBLE</td>'isHideMCPCSV = 'V' end
    
    ii = folderDepth / 10
    a = recursiveAppend('    ',ii)
    
    if isFolder == 'FOLDER' then TrackNameHTML = '<b>'..TrackName..'</b>' else TrackNameHTML = TrackName end
    if ii > 1 and isFolder == 'FOLDER' then isFolder = "SUBFOLDER" end
    lineCSV = a..TrackName..','..isFolder..','..numItems..','..isHideTCPCSV..','..isHideMCPCSV..','..FXedCSV
    lineHTML = '   <tr class=\"tracks slaveHier\"><td><span  style="padding-left:'..folderDepth..'px;">' .. TrackNameHTML ..'</span></td><td>'.. isFolder ..'</td><td class="centertext">'.. numItems ..'</td>'.. isHideTCP .. isHideMCP .. FXed ..isFXChainenabled_..'</tr>'
    WriteFILE(lineHTML,lineCSV)

  end
  WriteFILE("  </tbody>\n</table>","")
end


function FXedTracks()
  WriteFILE(tableFXTracksHeader,PageHeaderCSV)
  local tr =''
  for i=1,reaper.CountTracks(),1 do
  
    tr=reaper.GetTrack(0,i-1)
    
    local _, TrackName = reaper.GetTrackName(tr, "")
    local numItems = reaper.GetTrackNumMediaItems(tr) -- Retreives the number of items on that track
    local retval, flags  = reaper.GetTrackState(tr)

    
    ----------------------------------------------
    -- ASSIGN BINARY STATES TO VARIABLES
    ----------------------------------------------
    if flags &1 == 1 then isFolder = "FOLDER" else isFolder = 'Track' end
    if flags &2 == 2 then isSelected = "SELECTED" else isSelected = '' end
    if flags &4 == 4 then isFXChainenabled_ = '<td class="enabled">Enabled</td>' isFXChainenabledCSV_ = 'E' else isFXChainenabled_ = '<td class="disabled">Disabled</td>' isFXChainenabledCSV_ = 'D' end
    if flags &8 == 8 then isMuted = '<td class="mute">M</td>' isMutedCSV = "M" else isMuted = '<td>&nbsp;</td>' isMutedCSV = "" end 
    if flags &16 == 16 then isSoloed = '<td class="solo">S</td>' isSoloedCSV = "S" else isSoloed = '<td>&nbsp;</td>' isSoloedCSV = '' end
    if flags &32 == 32 then isSipd = "SIP'd" else isSipd = '' end
    if flags &64 == 64 then isRecArmed = "REC ARMED" else isRecArmed = ''end
    if flags &128 == 128 then isRecMonitoring = "REC Monitoring ON" else isRecMonitoring = ''end
    if flags &256 == 256 then isRecAuto = "REC Monitoring AUTO" else isRecAuto = ''end
    if flags &512 == 512 then isHideTCP = "HIDE from TCP" else isHideTCP = ''end
    if flags &1024 == 1024 then isHideMCP = "HIDE from MCP" else isHideMCP = ''end


    ----------------------------------------------
    -- PROCESS EFFECTED TRACKS
    ----------------------------------------------
    for ii=1,reaper.TrackFX_GetCount(tr),1 do
  
      local ok,FXname=reaper.TrackFX_GetFXName(tr,ii-1,"")
      local isFXenabled_ = reaper.TrackFX_GetEnabled(tr,ii-1) -- Checks if plugin BLOCKS is Enabled
      local isOffline_ = reaper.TrackFX_GetOffline(tr,ii-1) -- Checks if plugin is OffLine
      local retval, moduleName = reaper.BR_TrackFX_GetFXModuleName(tr,ii-1) -- Retrieves module name. The DLL (SWS mandatory!)
      if numItems == 0 then numItems = '-' end
      
      if isFXenabled_ == true then isFXenabled = '<td class="enabled">Enabled</td>' isFXenabledCSV = "E" else isFXenabled = '<td class="disabled">Bypassed</td>'isFXenabledCSV = "BYPASSED" end
      if isOffline_ == true then isOffline = '<td class="offline">OFF Line</td>' isOfflineCSV = "OFF" else isOffline = '<td class="online">On Line</td>'isOfflineCSV = "On" end
      local trackNotes = reaper.NF_GetSWSTrackNotes(tr)
      


       ----------------------------------------------
       -- ASSEMBLING CSV and HTML RECORDS
       ----------------------------------------------
       local list = i  .. ',' .. ridCommas(TrackName)  .. ',' .. isFolder .. ','.. ridCommas(trackNotes) ..','.. isFXChainenabledCSV_ .. ',' .. numItems .. ',' .. isSoloedCSV .. ',' .. isMutedCSV .. ',' .. ridCommas(FXname) .. ',' .. isFXenabledCSV .. ',' .. isOfflineCSV ..','.. moduleName
       local htmlList = '   <tr class=\"tracks slave\"><td class="centertext">'..i.."</td><td>"..TrackName..'</td><td class="centertext">'..isFolder..'</td><td>'..trackNotes..'</td>'..isFXChainenabled_..'<td class="centertext">' .. numItems .. "</td>" ..isSoloed..isMuted.."<td>"..FXname..isFXenabled..isOffline.."</td><td>"..moduleName.."</td></tr>"
       WriteFILE(htmlList,list)

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
  WriteFILE("  </tbody>\n</table>","")

end

function NotedTracks()
  WriteFILE(tableNotedTracksHeader,PageHeaderCSVNoted)
  for i=1,reaper.CountTracks(),1 do
  
    tr=reaper.GetTrack(0,i-1)
    
    local _, TrackName = reaper.GetTrackName(tr, "")
    local numItems = reaper.GetTrackNumMediaItems(tr) -- Retreives the number of items on that track
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
    
    ----------------------------------------------
    -- PROCESS UNEFFECTED TRACKS: RETRIEVES NOTES
    ---------------------------------------------- 
    trNotes=reaper.GetTrack(0,i-1)
    fxCount = reaper.TrackFX_GetCount(trNotes)
    notFXedNotes = reaper.NF_GetSWSTrackNotes(trNotes)
    
    
    ----------------------------------------------
    -- ASSEMBLING CSV and HTML RECORDS
    ----------------------------------------------
    if fxCount == 0 and notFXedNotes ~= '' then
      local csvlist = i  .. ',' .. ridCommas(TrackName)  .. ',' .. isFolder .. ','.. ridCommas(notFXedNotes) .. ',' .. numItems .. ',' .. isSoloedCSV .. ',' .. isMutedCSV
      local htmlList = '   <tr class=\"tracks slaveNoted\"><td class="centertext">'..i.."</td><td>"..TrackName..'</td><td class="centertext">'..isFolder..'</td><td>'..notFXedNotes..'</td><td class="centertext">' .. numItems .. "</td>" ..isSoloed..isMuted.."</tr>"
      WriteFILE(htmlList,csvlist)
     end
  end
  WriteFILE("  </tbody>\n</table>","")
end

function FXedItems()
  WriteFILE(PageHeaderItemsFXedHTML,PageHeaderItemsFXedCSV)
  reaper.Main_OnCommand(40289, 0) -- Item: Unselect all items
  local itemcount = reaper.CountMediaItems(0)
  if itemcount ~= nil then
    for i = 1, itemcount do
      item = reaper.GetMediaItem(0, i - 1)
      if item ~= nil then
        takecount = reaper.CountTakes(item)
        for j = 1, takecount do
          take = reaper.GetTake(item, j - 1)
  
          if reaper.BR_GetTakeFXCount(take) ~= 0 then
          local retval, itemNotes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES",0,0)
            fx_count = reaper.TakeFX_GetCount(take)
            for fx = 1, fx_count do           
              _, fx_name = reaper.TakeFX_GetFXName(take, fx-1, '')


              ------------------------------------------
              -- RETRIEVES PARAMETERS
              ------------------------------------------
              local itemTrack = reaper.GetMediaItem_Track(item)
              local retval, itemTrackName = reaper.GetTrackName(itemTrack)
              -- local retval, string_str = reaper.GetItemStateChunk(item, "", 0)
              local itemPosition = reaper.GetMediaItemInfo_Value(item,"D_POSITION") -- seconds
              local itemLength = reaper.GetMediaItemInfo_Value(item,"D_LENGTH") -- seconds
              local isMuted = reaper.GetMediaItemInfo_Value(item,"B_MUTE_ACTUAL") -- 0.0 or 1.0 
              local isLocked = reaper.GetMediaItemInfo_Value(item,"C_LOCK") -- 0.0 or 1.0
 
             
              ------------------------------------------
              -- CSV and HTML DATA PREPARATION
              ------------------------------------------
              if isMuted == 0.0 then 
                  isMutedCSV = "M" 
                  isMutedHTML = '<td class="mute">'.."M"..'</td>'
                else 
                  isMutedCSV = ""
                  isMutedHTML = '<td>&nbsp;</td>'
              end
              
              if isLocked == 0.0 then 
                  isLockedCSV = "L" 
                  isLockedHTML = '<td class="disabled">'.."LOCKED"..'</td>'
                else 
                  isLockedCSV = ""
                  isLockedHTML = '<td>&nbsp;</td>'
              end
              
              
              ------------------------------------------
              -- RETRIEVES FILE DATA
              ------------------------------------------
              local itemTake = reaper.GetActiveTake(item)
              local itemSource = reaper.GetMediaItemTake_Source(itemTake)
              local itemFilename = reaper.GetMediaSourceFileName(itemSource, "")
              local sourceSampleRate = reaper.GetMediaSourceSampleRate(itemSource)
              local bitDepth = reaper.CF_GetMediaSourceBitDepth(itemSource)
              if bitDepth == nil or bitDepth == 0 then bitDepth = "N/A" end
              
              
              ----------------------------------------------
              -- ASSEMBLING CSV and HTML RECORDS
              ----------------------------------------------
              lineCSV = ridCommas(itemTrackName) ..','.. ridCommas(fx_name) ..','.. round(itemPosition,precision) ..','.. round(itemLength,precision) ..','.. ridCommas(itemNotes) ..',' .. isMutedCSV ..','.. isLockedCSV ..','.. itemFilename ..','.. sourceSampleRate ..','.. bitDepth
              lineHTML = '   <tr class=\"tracks slaveFXedItems\"><td>' .. itemTrackName ..'</td><td>'.. fx_name ..'</td><td class="right">'.. round(itemPosition,precision) ..'</td><td class="right">'.. round(itemLength,precision) ..'</td><td>' .. itemNotes .. '</td>' .. isMutedHTML .. isLockedHTML ..'<td>'.. itemFilename ..'</td><td class="centertext">'.. sourceSampleRate ..'</td><td class="centertext">'.. bitDepth ..'</td></tr>'
  
              WriteFILE(lineHTML,lineCSV)
  
            end -- for fx
          end
   --[[
          local retval, itemNotes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES",0,0)
          if reaper.BR_GetTakeFXCount(take) == 0 and itemNotes ~= "" then
          savePorcadia("PORCADIA","PORCADIA")
          reaper.ShowConsoleMsg(' '..itemNotes)
          end
  ]]
        end -- for
      end
    end -- for
  end
  WriteFILE("  </tbody>\n</table>","")
  reaper.UpdateArrange()
end

function NotedItems()
  WriteFILE(PageHeaderNotedItemsHTML,PageHeaderNotedItemsCSV)
  local itemcount = reaper.CountMediaItems(0)
  if itemcount ~= nil then
    for i = 1, itemcount do
      item = reaper.GetMediaItem(0, i - 1)
      if item ~= nil then
        takecount = reaper.CountTakes(item)
        for j = 1, takecount do
          take = reaper.GetTake(item, j - 1)
          
          local retval, itemNotes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES",0,0)
          if reaper.BR_GetTakeFXCount(take) == 0 and itemNotes ~= "" then

              ------------------------------------------
              -- RETRIEVES PARAMETERS
              ------------------------------------------
              local itemTrack = reaper.GetMediaItem_Track(item)
              local retval, itemTrackName = reaper.GetTrackName(itemTrack)
              -- local retval, string_str = reaper.GetItemStateChunk(item, "", 0)
              local itemPosition = reaper.GetMediaItemInfo_Value(item,"D_POSITION") -- seconds
              local itemLength = reaper.GetMediaItemInfo_Value(item,"D_LENGTH") -- seconds
              local isMuted = reaper.GetMediaItemInfo_Value(item,"B_MUTE_ACTUAL") -- 0.0 or 1.0 
              local isLocked = reaper.GetMediaItemInfo_Value(item,"C_LOCK") -- 0.0 or 1.0
              
              
              ------------------------------------------
              -- CSV and HTML DATA PREPARATION
              ------------------------------------------
              if isMuted == 0.0 then 
                  isMutedCSV = "M" 
                  isMutedHTML = '<td class="mute">'.."M"..'</td>'
                else 
                  isMutedCSV = ""
                  isMutedHTML = '<td>&nbsp;</td>'
              end
              
              if isLocked == 0.0 then 
                  isLockedCSV = "L" 
                  isLockedHTML = '<td class="disabled">'.."LOCKED"..'</td>'
                else 
                  isLockedCSV = ""
                  isLockedHTML = '<td>&nbsp;</td>'
              end
              
              
              
              ------------------------------------------
              -- RETRIEVES FILE DATA
              ------------------------------------------
              local itemTake = reaper.GetActiveTake(item)
              local itemSource = reaper.GetMediaItemTake_Source(itemTake)
              local itemFilename = reaper.GetMediaSourceFileName(itemSource, "")
              local sourceSampleRate = reaper.GetMediaSourceSampleRate(itemSource)
              local bitDepth = reaper.CF_GetMediaSourceBitDepth(itemSource)
              if bitDepth == nil or bitDepth == 0 then bitDepth = "N/A" end
              
              
              ----------------------------------------------
              -- ASSEMBLING CSV and HTML RECORDS
              ----------------------------------------------
              lineCSV = ridCommas(itemTrackName) ..','.. round(itemPosition,precision) ..','.. round(itemLength,precision) ..','.. ridCommas(itemNotes) ..',' .. isMutedCSV ..','.. isLockedCSV ..','.. itemFilename ..','.. sourceSampleRate ..','.. bitDepth
              lineHTML = '   <tr class=\"tracks slaveNotedItems\"><td>' .. itemTrackName ..'</td><td class="right">'.. round(itemPosition,precision) ..'</td><td class="right">'.. round(itemLength,precision) ..'</td><td>' .. itemNotes .. '</td>' .. isMutedHTML .. isLockedHTML ..'<td>'.. itemFilename ..'</td><td class="centertext">'.. sourceSampleRate ..'</td><td class="centertext">'.. bitDepth ..'</td></tr>'
              
              WriteFILE(lineHTML,lineCSV)
          end 
        end --for
      end
    end --for
  end
  WriteFILE("  </tbody>\n</table>","")
  reaper.UpdateArrange()
end


function closeFiles()
  f_csv:write( PageFooterCSV..LF )
  f_csv:close()
  f_html:write( PageFooterHTML..LF )
  f_html:close()
end
----------------------------------------------
-- MAIN CALL FOR SCRIPT FIRE UP
----------------------------------------------
Master()
Hierarchical()
FXedTracks()
NotedTracks()
FXedItems()
NotedItems()
closeFiles()
  reaper.MB("Files .CSV and HTML saved\ninto the Project Folder","DONE",0,0)
::exit::
