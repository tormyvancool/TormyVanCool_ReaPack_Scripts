-- https://forum.cockos.com/archive/index.php/t-209658.html
-- https://forum.cockos.com/showthread.php?t=238421
-- https://www.extremraym.com/en/downloads/reascripts-html-export/?fbclid=IwAR1W-wr0qf5M7hUaaTf_ca7WmI98Ty9BsGKXMIB-sHhD6xL5GmcsFxZ9W9k
--[[
IF YU DON'T KEEP UPDATED: DON'T COMPLAIN FOR ISSUES!
@description Exporets project's data related to tracks, into CSV and HTML file
@author Tormy Van Cool
@version 2.2
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
v2.1 (19 may 2021)
  + All Tracks Hierarchy
  + All tracks Statuses
  + Master Channel FX and Notes
  + Precision
  + Project Length HH:MM:SS
v2.1.1 (19 may 2021)
  # Minor bug fixed: when no FX on Master, returned error on variable lineCSV because nil
v2.1.2 (20 may 2021)
  # Tracks in the HIerarchy & Master Channel without FX have not FX Chain indication
v2.2 (24 may 2021)
  # Optimized Code
  + VSTS' Path Detection
  + SUbfolder indication into FFEXed Tracks
  - Table width 90%
  + Table width 100%
  + Num. Items, Num. Markers, Num. Region in Project Data
  # Known issue 1: Paths of LV2 FXes are not detected or correctly detected. WORKS IN PROGRESS. 
  # Known Issue 2: Paths of 32bit FXes are not detected or correctly detected. WORKS IN PROGRESS. 
@credits  Mario Bianchi for his contribution to expedite the process;
          Edgemeal, Meo-Ada Mespotine for the help into extracting directories [t=253830];
          Solger for his help on the color decode [t=253981]
v2.3 (26 may 2021)
  + Project Markers
  + Project Regions
  + Solo in Tracks Hierarchy
  + Mute in Tracks Hierarchy
  # Cosmetic changes on Project Data and Master Channel table
  # Minor issues on CSV format
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

function pj_MarkersRegions(idx)
    
    local a = {}
    a.MR_Number, isrgn, a.MR_Pos, rgnend, MR_Name, a.MR_Markrgnindexnumber, color  = reaper.EnumProjectMarkers3(0, idx)

    if isrgn == true then
        a.MR_Isrgn = "REGION"
      else
        a.MR_Isrgn = "MARKER"
    end

    if MR_Name == '' then
        a.MR_Name = '[No Name]'
      else
        a.MR_Name = MR_Name
    end
    
    if color == 0 then
        a.MR_Color = "-"
        a.MR_ColorR = ''
        a.MR_ColorG = ''
        a.MR_ColorB = ''
      else
        a.MR_Color = color
        a.MR_ColorR, a.MR_ColorG, a.MR_ColorB = reaper.ColorFromNative(color)
    end
    
    if rgnend == 0.0 or (rgnend-a.MR_Pos) < 0.0 then
        a.MR_Rgnend = "-" 
        a.MR_Duration = "-"
      else
        a.MR_Rgnend = rgnend
        a.MR_Duration = rgnend-a.MR_Pos
    end
    
  return a
end

--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
local LF = "\n"
local CSV = ".csv"
local HTML = ".html"
local scriptVersion = "2.3"
local precision = 4
local pj_notes = reaper.GetSetProjectNotes(0, 0, "")
local pj_sampleRate = tonumber(reaper.GetSetProjectInfo(0, "PROJECT_SRATE", 0, 0))
local pj_name_ = reaper.GetProjectName(0, "")
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
local pj_name_ = string.gsub(string.gsub(pj_name_, ".rpp", ""), ".RPP", "")
local date = os.date("%Y-%m-%d %H:%M:%S")
local dateFile = '_' .. os.date("%Y-%m-%d_%H.%M.%S")
local author = reaper.GetSetProjectAuthor(0, 0, '')
local version = reaper.GetAppVersion()
local pj_length=round(reaper.GetProjectLength(),precision)
local totalMediaItems = reaper.CountMediaItems()
local _, totalMarkers, totalRegions = reaper.CountProjectMarkers()
local totalMarkersRegions = totalMarkers+totalRegions

----------------------------------------------
-- FILE OPERATIONS
----------------------------------------------
if pj_name_ == "" then reaper.MB("The project MUST BE SAVED!!","WARNING",0,0) return --goto exit
end
local f_csv=io.open(pj_path .. '/' .. pj_name_ .. dateFile .. CSV,"w")
local f_html=io.open(pj_path .. '/' .. pj_name_ .. dateFile .. HTML,"w")
function WriteFILE(listHTML,listCSV)
   f_csv:write( listCSV..LF )
   f_html:write( listHTML..LF )
end

----------------------------------------------
-- MAIN HEADERS
----------------------------------------------
local PageHeaderCSV = 'PROJECT:'..LF..'Name: '..pj_name_..LF..'Sample Rate: '..pj_sampleRate..'Hz'..LF..'Duration: '..SecondsToHMS(pj_length)..LF..LF..
                      'TOTAL TRACKS: ' .. reaper.CountTracks() ..LF..LF..
                      'DAW:'..LF ..'REAPER v.' .. version ..LF..LF..
                      'CREATED:'..LF .. date ..LF..LF..
                      'AUTHOR:'..LF..author..LF..LF..
                      "Exported with 'EXPORT DATA' v." .. scriptVersion .. " by Tormy Van Cool"..LF..LF
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
     
     table{margin-bottom: 12px; width:100%}
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
     .lv {color: red}
     .label { font-weight: bold; margin-right: 20px;}
     .colorMarkerRegion { width: 1%; }
     .markersregions { margin-top: 10px; background: linear-gradient( 48deg , #2dbbff, transparent); font-weight: bolder; color: #ca5603; font-size: 22px; }
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
        <tr><th colspan="8" class="header">PROJECT DATA<sub>Created: ]] .. date .. 
        ' with \'EXPORT DATA\' v.'.. scriptVersion .. 
        [[ by Tormy Van Cool</sub></th></tr>
      </thead>
      <tbody>
        <tr><td colspan="8" class="centertext markersregions">MAIN DATA</td></tr>
        <tr class="table_header">
          <th>PROJECT</th>
          <th>TOTAL TRACKS</th>
          <th>ITEMS</th>
          <th>MARKERS</th>
          <th>REGIONS</th>
          <th>DAW</th>
          <th>AUTHOR</th>
          <th>NOTES</th>
        </tr>
        <tr><td class="left"><span class="label">Name:</span> ]]..pj_name_..
          '<br/><span class="label">Sample Rate:</span> '..round(pj_sampleRate,0)..
          ' Hz<br/><span class="label">Project Length:</span> '..SecondsToHMS(pj_length)..
          '</td><td class="centertext">'.. reaper.CountTracks() ..
          '</td><td class="centertext">'..totalMediaItems..
          '</td><td class="centertext">'..totalMarkers..
          '</td><td class="centertext">'..totalRegions..
          '</td><td class="centertext">REAPER - v.'..version..
          '</td><td class="centertext">'..author..
          '</td><td>'..pj_notes..
      '</td></tr>'
      
local MarkersRegionsHeaderCSV = 'NAME,COLOR,TYPE,NUMBER,IDX,START POSITION, END POSITION (if Region),DURATION (if Region)\nMARKERS' 
local MarkersRegionsHeaderHTML = '<tr><td colspan="8" class="centertext markersregions">MARKERS</td></tr>'..
      '<tr class="table_header"><th class="centertext">NAME</th>'..
      '<th class="colorMarkerRegion">COLOR</th>'..
      '<th class="centertext">TYPE</th>'..
      '<th class="centertext">NUMBER</th>'..
      '<th class="centertext">IDX</th>'..
      '<th class="centertext">START POSITION</th>'..
      '<th class="centertext">END POSITION (if Region)</th>'..
      '<th class="centertext">DURATION (if Region)</th></tr>'

      WriteFILE(PageHeaderHTML,PageHeaderCSV)
      
      local idx
      if totalMarkersRegions ~= 0 then

        WriteFILE(MarkersRegionsHeaderHTML,MarkersRegionsHeaderCSV)
        for idx = 0,totalMarkersRegions do
          if pj_MarkersRegions(idx).MR_Isrgn == "MARKER" and pj_MarkersRegions(idx).MR_Markrgnindexnumber ~= 0 then
            local lineCSV = pj_MarkersRegions(idx).MR_Name..
                            ',R='..pj_MarkersRegions(idx).MR_ColorR..' G='..pj_MarkersRegions(idx).MR_ColorG..' B='..pj_MarkersRegions(idx).MR_ColorB..
                            ','..pj_MarkersRegions(idx).MR_Isrgn..
                            ','..pj_MarkersRegions(idx).MR_Number..
                            ','..pj_MarkersRegions(idx).MR_Markrgnindexnumber..
                            ','..pj_MarkersRegions(idx).MR_Pos..
                            ','..pj_MarkersRegions(idx).MR_Rgnend..
                            ','..pj_MarkersRegions(idx).MR_Duration
                            
            local lineHTML =  '<tr><td>'..pj_MarkersRegions(idx).MR_Name..'</td>'..
                              '<td style="background-color: rgb('..pj_MarkersRegions(idx).MR_ColorR..
                                    ','..pj_MarkersRegions(idx).MR_ColorG..
                                    ','..pj_MarkersRegions(idx).MR_ColorB..');"></td>'..            
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Isrgn..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Number..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Markrgnindexnumber..'</td>'..
                              '<td class="right">'..pj_MarkersRegions(idx).MR_Pos..'</td>'..
                              '<td class="right">'..pj_MarkersRegions(idx).MR_Rgnend..'</td>'..
                              '<td class="right">'..pj_MarkersRegions(idx).MR_Duration..'</td></tr>'
            WriteFILE(lineHTML,lineCSV) 
          end
        end
        WriteFILE('<tr><td colspan="8" class="centertext markersregions">REGIONS</td></tr>','REGIONS')
        for idx = 0,totalMarkersRegions do
          if pj_MarkersRegions(idx).MR_Isrgn == "REGION" then
            local lineCSV = pj_MarkersRegions(idx).MR_Name..
                            ',R='..pj_MarkersRegions(idx).MR_ColorR..' G='..pj_MarkersRegions(idx).MR_ColorG..' B='..pj_MarkersRegions(idx).MR_ColorB..
                            ','..pj_MarkersRegions(idx).MR_Isrgn..
                            ','..pj_MarkersRegions(idx).MR_Number..
                            ','..pj_MarkersRegions(idx).MR_Markrgnindexnumber..
                            ','..pj_MarkersRegions(idx).MR_Pos..
                            ','..pj_MarkersRegions(idx).MR_Rgnend..
                            ','..pj_MarkersRegions(idx).MR_Duration
                            
            local lineHTML =  '<tr><td>'..pj_MarkersRegions(idx).MR_Name..'</td>'..
                              '<td style="background-color: rgb('..pj_MarkersRegions(idx).MR_ColorR..
                                    ','..pj_MarkersRegions(idx).MR_ColorG..
                                    ','..pj_MarkersRegions(idx).MR_ColorB..');"></td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Isrgn..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Number..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Markrgnindexnumber..'</td>'..
                              '<td class="right">'..pj_MarkersRegions(idx).MR_Pos..'</td>'..
                              '<td class="right">'..pj_MarkersRegions(idx).MR_Rgnend..'</td>'..
                              '<td class="right">'..pj_MarkersRegions(idx).MR_Duration..'</td></tr>'
            WriteFILE(lineHTML,lineCSV) 
          end
        end
      end
local tableftr =       [[</tbody>
    </table>
    <div class="spacer">&nbsp;</div>
]]

  WriteFILE(tableftr,'')
  
----------------------------------------------
-- SPECIALIZED HEADER
----------------------------------------------
local PageHeaderMasterCSV = LF..LF..'MASTER CHANNEL:\nFX NAME,FX En./Byp.,FX On Line/Off Line,FILE NAME'
local PageHeaderMasterHTML = [[
     <table class="center">
      <thead>
        <tr>
          <th colspan="6" class="header">
            <span class="info expandMaster emboss pointer masterMaster">&#x25BC;</span>
            <span class="info collapseMaster engrave pointer masterMaster">&#x25B2;</span>MASTER CHANNEL
          </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header slaveMaster">]]..
        '<th colspan="2" class="statuswidth">TRACK SETTINGS</th>'..
        '<th colspan="4">FX (VSTs)</th></tr>'..
        '<tr class="table_header slaveMaster"><th>CONTROLS</th>'..
        '<th>STATUS</th><th>NAME</th>'..
        '<th class="MasterEnabledOnline">Enabled<br/>Bypassed</th>'..
        '<th class="MasterEnabledOnline">On Line<br/>Off Line</th>'..
        '<th>FILE</th></tr>'
        
local PageHeaderHierarchyCSV = LF..LF..'HIERARCHY:\nNAME,TYPE,SOLO,MUTE,N.ITEMS,TCP,MCP,FX'
local PageHeaderHierarchyHTML = [[
      <table class="center">
      <thead>
        <tr>
          <th colspan="9" class="header">
            <span class="info expandHier emboss pointer masterHier">&#x25BC;</span>
            <span class="info collapseHier engrave pointer masterHier">&#x25B2;</span>TRACKS HIERARCHY
          </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header slaveHier">
          <th>NAME</th>
          <th class="TracksEnabledOnline">TYPE</th>
          <th class="TracksEnabledOnline">SOLO</th>
          <th class="TracksEnabledOnline">MUTE</th>          
          <th class="TracksEnabledOnline">N. ITEMS</th>
          <th class="TracksEnabledOnline">TCP</th>
          <th class="TracksEnabledOnline">MCP</th>
          <th class="TracksEnabledOnline">FXed</th>
          <th class="TracksEnabledOnline">FX CHAIN<br/>Enable/Disabled</th>
        </tr>]]
        
local tableFXTracksHeaderCSV = LF..LF..'EFFECTED TRACKS:\nTRACK IDX,TRACK NAME,TRACK TYPE,NOTES,FX CHAIN En./Dis.,N. ITEMS,SOLO,MUTE,FX/INSTRUMENTS NAME (VST/VSTi),FX En./Byp.,FX OnLine/OffLine,FX File'
local tableFXTracksHeader = [[
    <div class="spacer">&nbsp;</div>
    <table class="center">
      <thead>
        <tr>
          <th colspan="12" class="header">
            <span class="info expand emboss pointer master">&#x25BC;</span>
            <span class="info collapse engrave pointer master">&#x25B2;</span>EFFECTED TRACKS
          </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header slave">
          <th colspan="5">TRACK</th><th colspan="3">STATUS</th>
          <th colspan="4">FX and/or INSTRUMENTS(VST/VSTi)</th>
        </tr>
        <tr class="table_header slave">
          <th>IDX</th>
          <th>NAME</th>
          <th>TYPE</th>
          <th>NOTES</th>
          <th>FX Chain<br/>En./Dis.</th>
          <th>N. ITEMS</th>
          <th>SOLO</th>
          <th>MUTE</th>
          <th>NAME</th>
          <th id="EnDis">Enabled<br/>Bypassed</th>
          <th id="OnOff">On Line<br/>Off Line</th>
          <th>PLUGIN FILE</th>
        </tr>]]
        
local PageHeaderCSVNoted = LF..LF..'NOTED TRACKS:\nTRACK IDX,TRACK NAME,TRACK TYPE,NOTES,N. ITEMS,SOLO,MUTE'
local tableNotedTracksHeader = [[
   <table class="center">
      <thead>
        <tr>
          <th colspan="7" class="header">
            <span class="info expandNoted emboss pointer masterNoted">&#x25BC;</span>
            <span class="info collapseNoted engrave pointer masterNoted">&#x25B2;</span>NOTED TRACKS
          </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header slaveNoted">
          <th colspan="4">TRACK</th><th colspan="3">STATUS</th>
        </tr>
        <tr class="table_header slaveNoted">
          <th class="TracksNoted">IDX</th>
          <th>NAME</th><th class="TracksNoted">TYPE</th>
          <th>NOTES</th><th class="TracksNoted">N. ITEMS</th>
          <th class="TracksNoted">SOLO</th>
          <th class="TracksNoted">MUTE</th>
        </tr>]]
        
local PageHeaderItemsFXedCSV = LF..LF..'EFFECTED ITEMS:\nTRACK NAME,FX,ITEM POSITION,ITEM LENGTH,NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
local PageHeaderItemsFXedHTML = [[ 
    <div class="spacer">&nbsp;</div>
    <table class="center">
      <thead>
        <tr><th colspan="10" class="header">
              <span class="info expandFXedItems emboss pointer masterFXeditems">&#x25BC;</span>
              <span class="info collapseFXedItems engrave pointer masterFXedItems">&#x25B2;</span>EFFECTED ITEMS DATA
            </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header slaveFXedItems">
          <th colspan="5">MAIN DATA</th>
          <th colspan="2">STATUS</th>
          <th colspan="3">SOURCE</th>
        </tr>
        <tr class="table_header slaveFXedItems">
          <th>BELONGIN TO</th>
          <th>FX</th>
          <th class="EffectedItems">POSITION</th>
          <th class="EffectedItems">LENGTH</th>
          <th>NOTES</th>
          <th class="EffectedItems">MUTE</th>
          <th class="EffectedItems">LOCKED</th>
          <th>SOURCE NAME</th>
          <th class="EffectedItems">SAMPLE RATE</th>
          <th class="EffectedItems">BIT DEPTH</th>
        </tr>]]
        
local PageHeaderNotedItemsCSV = LF..LF..'NOTED ITEMS:\nTRACK NAME,ITEM POSITION,ITEM LENGTH,NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
local PageHeaderNotedItemsHTML = [[
    <table class="center">
      <thead>
        <tr><th colspan="9" class="header">
              <span class="info expandNotedItems emboss pointer masterNotedItems">&#x25BC;</span>
              <span class="info collapseNotedItems engrave pointer masterNotedItems">&#x25B2;</span>NOTED ITEMS DATA
            </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header slaveNotedItems">
          <th colspan="4">MAIN DATA</th>
          <th colspan="2">STATUS</th>
          <th colspan="3">SOURCE</th>
        </tr>
        <tr class="table_header slaveNotedItems">
          <th>BELONGIN TO</th><th>POSITION</th>
          <th>LENGTH</th><th>NOTES</th>
          <th class="EffectedItems">MUTE</th>
          <th class="EffectedItems">LOCKED</th>
          <th>SOURCE NAME</th>
          <th class="EffectedItems">SAMPLE RATE</th>
          <th class="EffectedItems">BIT DEPTH</th>
        </tr>]]


local PageFooterHTML = "  \n</body>\n</html>"



----------------------------------------------
-- AUXILIARY FUNCTIONS
----------------------------------------------

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

function getOS()
  local OS = reaper.GetOS()
  local a = {}
  if OS == "Win32" or OS == "Win64" then
    a.slash = '\\'
    a.lv2 = os.getenv("COMMONPROGRAMFILES")..'\\LV2'
  end
  if OS == "OSX32" or OS == "OSX64" or OS == "macOS-arm64" then
    a.slash = '/'
    a.lv2 = os.getenv("HOME")..'/Library/Application Support/LV2'
  end
  if OS == "Other" then
    a.slash = '/'
    a.lv2 = os.getenv("HOME")..'/LV2'
  end
  return a
end


function ScanTracks(tr,ii)

    local retval, flags  = reaper.GetTrackState(tr)
    local a = {}
    
    ----------------------------------------------
    -- ASSIGN BINARY STATES TO VARIABLES
    ----------------------------------------------
    if flags &1 == 1 then a.isFolder = "FOLDER" else a.isFolder = 'Track' end
    if flags &2 == 2 then a.isSelected = "SELECTED" else a.isSelected = '' end
    if flags &4 == 4 then a.isFXChainenabled = '<td class="enabled">Enabled</td>' a.isFXChainenabledCSV = 'E' else a.isFXChainenabled = '<td class="disabled">Disabled</td>' a.isFXChainenabledCSV = 'D' end
    if flags &8 == 8 then a.isMuted = '<td class="mute">M</td>' a.isMutedCSV = "M" else a.isMuted = '<td>&nbsp;</td>' a.isMutedCSV = "" end 
    if flags &16 == 16 then a.isSoloed = '<td class="solo">S</td>' a.isSoloedCSV = "S" else a.isSoloed = '<td>&nbsp;</td>' a.isSoloedCSV = '' end
    if flags &32 == 32 then a.isSipd = "SIP'd" else a.isSipd = '' end
    if flags &64 == 64 then a.isRecArmed = "REC ARMED" else a.isRecArmed = ''end
    if flags &128 == 128 then a.isRecMonitoring = "REC Monitoring ON" else a.isRecMonitoring = ''end
    if flags &256 == 256 then a.isRecAuto = "REC Monitoring AUTO" else a.isRecAuto = ''end
    if flags &512 == 512 then a.isHideTCP = '<td class="mute centertext">HIDDEN</td>' a.isHideTCPCSV = 'H' else a.isHideTCP = '<td class="centertext">VISIBLE</td>' a.isHideTCPCSV = 'V' end
    if flags &1024 == 1024 then a.isHideMCP = '<td class="mute centertext">HIDDEN</td>'  a.isHideMCPCSV = 'H' else a.isHideMCP = '<td class="centertext">VISIBLE</td>'a.isHideMCPCSV = 'V' end
    
    if ii ~= nil then
      local isFXenabled_ = reaper.TrackFX_GetEnabled(tr,ii-1) -- Checks if plugin BLOCKS is Enabled
      local isOffline_ = reaper.TrackFX_GetOffline(tr,ii-1) -- Checks if plugin is OffLine
      local retval, moduleName = reaper.BR_TrackFX_GetFXModuleName(tr,ii-1) -- Retrieves module name. The DLL (SWS mandatory!)
      a.moduleName = moduleName
      
      if isFXenabled_ == true then 
          a.isFXenabled = '<td class="enabled">Enabled</td>' 
          a.isFXenabledCSV = "E"
        else
          a.isFXenabled = '<td class="disabled">Bypassed</td>'
          a.isFXenabledCSV = "BYPASSED"
      end
      
      if isOffline_ == true then 
          a.isOffline = '<td class="offline">OFF Line</td>' 
          a.isOfflineCSV = "OFF"
        else 
          a.isOffline = '<td class="online">On Line</td>'
          a.isOfflineCSV = "On" 
      end
    end
    
    return a
end

function RetrieveVSTPath(track,ii)
  --if ii == nil then ii = '' end
  a = {}
  function GetFolders(path, includeRoot) -- Thanks to Lokasenna [t=206933] -- 
    local t = {}
    local subdirindex, path_child = 0,nil 
    if includeRoot then t[1]= path end 
    repeat
      path_child = reaper.EnumerateSubdirectories(path, subdirindex)
      if path_child then  
        table.insert(t, path .. "/" .. path_child) 
        local tmp = GetFolders(path .. "/" .. path_child)
        for i = 1, #tmp do
          table.insert(t, tmp[i])
        end
      end
      subdirindex = subdirindex+1
    until not path_child
    return t
  end
  
  local resPath = reaper.GetResourcePath()
  local paths = resPath.."/Plugins/FX;"..resPath.."/UserPlugins/FX;" -- REAPER's FX folder paths
  paths = paths..({reaper.BR_Win32_GetPrivateProfileString("REAPER", "vstpath64", "", reaper.get_ini_file())})[2] -- + paths from reaper.ini lv2path_win64
  
 function GetVstPath(filename)
    for path in paths:gmatch("[^;]+") do
      local folders = GetFolders(path, true)
      for i = 1, #folders do
        if reaper.file_exists(folders[i].."/".. filename) then return folders[i] end
      end
    end
  end
  
  -- Get FX (VST/DLL only) names and path on selected track,
  --local track = reaper.GetSelectedTrack(0,0)
  if track then 
    local fx_cnt = reaper.TrackFX_GetCount(track)
    for i = 0, fx_cnt-1 do
      retval, name = reaper.BR_TrackFX_GetFXModuleName(track, i)
      local path = GetVstPath(name)
      
      if path then a.path = path else a.path = ''  end 
      if name then a.name = name else a.name = '' end
      
      -----------------------------      
      local _,FXname=reaper.TrackFX_GetFXName(track,ii-1,"")
      local isVST32 = string.find(FXname, "(x86)")
      local isJS = string.find(FXname, "JS:")
      local isLV2 = string.find(FXname, "LV2:")
      a.FXname = FXname
      if isVST32 == nil then 
          local native = string.find(FXname, "(Cockos)")    
          if native ~= nil  then 
              a.fullPath = reaper.GetExePath()..'\\Plugins\\FX\\'.. ScanTracks(track,ii).moduleName
              a.fullPathCSV = a.fullPath
            elseif isJS then
              a.fullPath = reaper.GetExePath()..'\\Effects\\'.. ScanTracks(track,ii).moduleName
              a.fullPathCSV = a.fullPath
            else
              a.fullPath = a.path..'\\'..a.name
              a.fullPathCSV = a.fullPath
          end
          
          if isLV2 then
              --a.fullPath = a.path..'\\'.. ScanTracks(track,ii).moduleName
              a.fullPath = a.path..getOS().lv2..'\\'..ScanTracks(track,ii).moduleName
              a.fullPathCSV = a.fullPath
          end
          
          if a.path == nil then
            a.fullPath = 'UNKNOWN'
            a.fullPathCSV = 'UNKNOWN'
          end 
        else 
          a.fullPath = '<span class="lv">[PATH NOT AVAILABLE]</span><br/>'..ScanTracks(track,ii).moduleName
          a.fullPathCSV = '[PATH NOT AVAILABLE]'
      end
      -----------------------------
      return a
    end
  end
end

----------------------------------------------
-- MAIN FUNCTIONS
----------------------------------------------
function Master()

    WriteFILE(PageHeaderMasterHTML,PageHeaderMasterCSV)
    local tr = reaper.GetMasterTrack(0)

    for ii=1,reaper.TrackFX_GetCount(tr),1 do
      --if reaper.TrackFX_GetCount(masterChannel) > 0 then FXed = "Yes" else FXed = "No" end
      local _,FXname=reaper.TrackFX_GetFXName(tr,ii-1,"")
      local isMasterFXenabled_ = reaper.TrackFX_GetEnabled(tr,ii-1) -- Checks if plugin BLOCKS is Enabled
      local isMasterOffline_ = reaper.TrackFX_GetOffline(tr,ii-1) -- Checks if plugin is OffLine
      local pathName = RetrieveVSTPath(tr,ii) -- TBI
    
    lineCSV = pathName.FXname..
              ','..ScanTracks(tr,ii).isFXenabledCSV..
              ','..ScanTracks(tr,ii).isOfflineCSV..
              ','..pathName.fullPath
              
    lineHTML = '   <tr class="tracks slaveMaster status"><td colspan="2"></td><td>'..pathName.FXname..
               '</td>'..ScanTracks(tr,ii).isFXenabled..ScanTracks(tr,ii).isOffline..
               '<td>'..pathName.fullPath..
               '</tr>'
    WriteFILE(lineHTML,lineCSV)
  
    end
    if reaper.TrackFX_GetCount(tr) == 0 then 
      FX_ChainEnabled = '<td></td>'
      FX_ChainEnabledCSV = ''
    else
      FX_ChainEnabled = ScanTracks(tr).isFXChainenabled
      FX_ChainEnabledCSV = ScanTracks(tr).isFXChainenabledCSV
    end

    masterNotes = reaper.NF_GetSWSTrackNotes(tr)
    local MasterNotesCSV = ridCommas(masterNotes)
    local line_1 = '<tr class="tracks slaveMaster"><td><b>MUTE</b></td>'..ScanTracks(tr).isMuted..'<td colspan="4" class="centertext markersregions"><b>NOTES</b></td></tr>'
    local line_2 = '<tr class="tracks slaveMaster"><td><b>SOLO</b></td>'..ScanTracks(tr).isSoloed..'<td rowspan="4" colspan="4" class="masterNotes">'..masterNotes..'</td></tr>'
    local line_3 = '<tr class="tracks slaveMaster"><td><b>FX CHAIN</b></td>'..FX_ChainEnabled..'</tr>'
    local line_4 = '<tr class="tracks slaveMaster"><td><b>TCP</b></td>'..ScanTracks(tr).isHideTCP..'</tr>'
    local line_5 = '<tr class="tracks slaveMaster"><td><b>MCP</b></td>'..ScanTracks(tr).isHideMCP..'</tr>'
   
    if lineCSV == nil then lineCSV ='' end
    local csv_1 = '\nMASTER TRACK SETTINGS:\nMUTE,SOLO,FX CHAIN,TCP,MCP,NOTES\n'
    local csv_2 = ScanTracks(tr).isMutedCSV..','..ScanTracks(tr).isSoloedCSV..','..FX_ChainEnabledCSV..','..ScanTracks(tr).isHideTCPCSV..','..ScanTracks(tr).isHideMCPCSV..','..MasterNotesCSV
    WriteFILE(line_1..line_2..line_3..line_4..line_5,lineCSV..','..csv_1..csv_2)
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
    
    if hasFX ~= 0 then 
        FXed = '<td class="yes centertext">Yes</td>' 
        FXedCSV = 'Yes' 
      else 
        FXed = '<td class="no centertext">No</td>' 
        FXedCSV = 'No' 
    end
    --local folderDepth = reaper.GetMediaTrackInfo_Value(tr, "I_FOLDERDEPTH")
    local folderDepth =  15*reaper.GetTrackDepth(tr) 

    ii = folderDepth / 10
    a = recursiveAppend('    ',ii)
    
    if hasFX == 0 then 
        FX_ChainEnabled = '<td></td>'
        FX_ChainEnabledCSV = ''
      else
        FX_ChainEnabled = ScanTracks(tr).isFXChainenabled
        FX_ChainEnabledCSV = ScanTracks(tr).isFXChainenabledCSV
    end      

    if ScanTracks(tr).isFolder == 'FOLDER' then 
        TrackNameHTML = '<b>'..TrackName..'</b>' 
      else 
        TrackNameHTML = TrackName 
    end
    
    if ii > 1 and ScanTracks(tr).isFolder == 'FOLDER' then 
        is_Folder = "SUBFOLDER"
      else
        is_Folder = ScanTracks(tr).isFolder
    end
  
    lineCSV = a..TrackName..
              ','..is_Folder..
              ','..ScanTracks(tr).isSoloedCSV..ScanTracks(tr).isMutedCSV..
              ','..numItems..
              ','..ScanTracks(tr).isHideTCPCSV..
              ','..ScanTracks(tr).isHideMCPCSV..
              ','..FXedCSV..
              ','..FX_ChainEnabledCSV
              
    lineHTML =  '   <tr class="tracks slaveHier"><td><span  style="padding-left:'..folderDepth..
                'px;">'..TrackNameHTML..
                '</span></td><td>'..is_Folder..
                ''..ScanTracks(tr).isSoloed..ScanTracks(tr).isMuted..
                '</td><td class="centertext">'..numItems..
                '</td>'.. ScanTracks(tr).isHideTCP .. ScanTracks(tr).isHideMCP .. FXed ..FX_ChainEnabled..
                '</tr>'
                
    WriteFILE(lineHTML,lineCSV)

  end
  WriteFILE("  </tbody>\n</table>","")
end


function FXedTracks()
  WriteFILE(tableFXTracksHeader,tableFXTracksHeaderCSV)
  local tr =''
  for i=1,reaper.CountTracks(),1 do
  
    tr=reaper.GetTrack(0,i-1)
    
    local folderDepth =  reaper.GetTrackDepth(tr) 
    local _, TrackName = reaper.GetTrackName(tr, "")
    local numItems = reaper.GetTrackNumMediaItems(tr) -- Retreives the number of items on that track
    if numItems == 0 then numItems = '-' end
      
    ----------------------------------------------
    -- PROCESS EFFECTED TRACKS
    ----------------------------------------------
    for ii=1,reaper.TrackFX_GetCount(tr),1 do
    
      if folderDepth > 0 and ScanTracks(tr,ii).isFolder == 'FOLDER' then 
          is_Folder = "SUBFOLDER"
        else
          is_Folder = ScanTracks(tr,ii).isFolder
      end
      
      local pathName = RetrieveVSTPath(tr,ii)
      local trackNotes = reaper.NF_GetSWSTrackNotes(tr)

      ----------------------------------------------
      -- ASSEMBLING CSV and HTML RECORDS
      ----------------------------------------------
      local list = i .. 
                  ','.. ridCommas(TrackName).. 
                  ','.. is_Folder.. 
                  ','.. ridCommas(trackNotes)..
                  ','.. ScanTracks(tr,ii).isFXChainenabledCSV..
                  ','.. numItems..
                  ','.. ScanTracks(tr,ii).isSoloedCSV..
                  ','.. ScanTracks(tr,ii).isMutedCSV..
                  ','.. ridCommas(pathName.FXname)..
                  ','.. ScanTracks(tr,ii).isFXenabledCSV..
                  ','.. ScanTracks(tr,ii).isOfflineCSV..
                  ','.. pathName.fullPathCSV
                  
      local htmlList = '   <tr class="tracks slave"><td class="centertext">'..i..
                       '</td><td>'..TrackName..
                       '</td><td class="centertext">'..is_Folder..
                       '</td><td>'..trackNotes..
                       '</td>'..ScanTracks(tr,ii).isFXChainenabled..
                       '<td class="centertext">'.. numItems ..
                       '</td>' ..ScanTracks(tr,ii).isSoloed..ScanTracks(tr,ii).isMuted..
                       '<td>'..pathName.FXname..ScanTracks(tr,ii).isFXenabled..ScanTracks(tr,ii).isOffline..
                       '</td><td>'..pathName.fullPath..
                       '</td></tr>'
                       
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
    -- PROCESS UNEFFECTED TRACKS: RETRIEVES NOTES
    ---------------------------------------------- 
    trNotes=reaper.GetTrack(0,i-1)
    fxCount = reaper.TrackFX_GetCount(trNotes)
    notFXedNotes = reaper.NF_GetSWSTrackNotes(trNotes)
    
    ----------------------------------------------
    -- ASSEMBLING CSV and HTML RECORDS
    ----------------------------------------------
    if fxCount == 0 and notFXedNotes ~= '' then
      local csvlist = i..
                      ','..ridCommas(TrackName)..
                      ','..ScanTracks(tr).isFolder..
                      ','..ridCommas(notFXedNotes)..
                      ','..numItems..
                      ','..ScanTracks(tr).isSoloedCSV..
                      ','..ScanTracks(tr).isMutedCSV
                      
      local htmlList ='  <tr class="tracks slaveNoted"><td class="centertext">'..i..
                      '</td><td>'..TrackName..
                      '</td><td class="centertext">'..ScanTracks(tr).isFolder..
                      '</td><td>'..notFXedNotes..
                      '</td><td class="centertext">'..numItems .. 
                      '</td>'..ScanTracks(tr).isSoloed..ScanTracks(tr).isMuted..
                      '</tr>'
                      
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
              local pathName = RetrieveVSTPath(itemTrack,fx)
             
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
              lineCSV = ridCommas(itemTrackName)..
                        ','..ridCommas(fx_name)..
                        ','..round(itemPosition,precision)..
                        ','..round(itemLength,precision)..
                        ','..ridCommas(itemNotes)..
                        ','..isMutedCSV..
                        ','..isLockedCSV..
                        ','..itemFilename..
                        ','..sourceSampleRate..
                        ','..bitDepth
                        
              lineHTML = '   <tr class=\"tracks slaveFXedItems\"><td>'..itemTrackName..
                         '</td><td>'..fx_name..
                         '</td><td class="right">'..round(itemPosition,precision)..
                         '</td><td class="right">'..round(itemLength,precision)..
                         '</td><td>'..itemNotes.. 
                         '</td>'..isMutedHTML..isLockedHTML..
                         '<td>'..itemFilename..
                         '</td><td class="centertext">'..sourceSampleRate..
                         '</td><td class="centertext">'..bitDepth..
                         '</td></tr>'
  
              WriteFILE(lineHTML,lineCSV)
  
            end -- for fx
          end
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
              lineCSV = ridCommas(itemTrackName)..
                        ','..round(itemPosition,precision)..
                        ','..round(itemLength,precision)..
                        ','..ridCommas(itemNotes)..
                        ','..isMutedCSV..
                        ','..isLockedCSV..
                        ','..itemFilename..
                        ','..sourceSampleRate..
                        ','..bitDepth
                        
              lineHTML = '   <tr class=\"tracks slaveNotedItems\"><td>'..itemTrackName..
                         '</td><td class="right">'..round(itemPosition,precision)..
                         '</td><td class="right">'..round(itemLength,precision)..
                         '</td><td>'..itemNotes.. 
                         '</td>'..isMutedHTML..isLockedHTML..
                         '<td>'..itemFilename..
                         '</td><td class="centertext">'..sourceSampleRate..
                         '</td><td class="centertext">'..bitDepth..
                         '</td></tr>'
              
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
