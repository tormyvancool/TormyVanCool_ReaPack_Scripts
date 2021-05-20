-- https://forum.cockos.com/archive/index.php/t-209658.html
-- https://forum.cockos.com/showthread.php?t=238421
-- https://www.extremraym.com/en/downloads/reascripts-html-export/?fbclid=IwAR1W-wr0qf5M7hUaaTf_ca7WmI98Ty9BsGKXMIB-sHhD6xL5GmcsFxZ9W9k
--[[
@description Exporets project's data related to tracks, into CSV and HTML file
@author Tormy Van Cool
@version 2.0
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
v1.0.4
  + Project Notes
  + Track Notes
  + Project Sample Rate
v2.0
  + Expandable/Collapsible Tables
  + Odd/Even on Mute flag
  + Odd/Even on Solo flag
  + Only noted tracks
  - Pipe separated Values
  + Comma Separated Values
  + Effected items 
  + Noted items 
@credits Mario Bianchi for his contribution to expedite the process
]]--

--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
local LF = "\n"
local CSV = ".csv"
local HTML = ".html"
local scriptVersion = "2.0"
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
local PageHeaderHTML = [[
<html>
  <head>
     <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
     <title>]] .. pj_name_ .. [[</title>
     <style>
     body {font-family: Helvetica, sans-serif;}
     span.info {position: absolute; left: 0; }
     .emboss {text-shadow: -2px 2px 4px rgb(0 0 0 / 50%), 2px -2px 0 rgb(255 255 255 / 90%);}
     .engrave {color: transparent; background: #8e8e8e; -webkit-background-clip: text; text-shadow: 2px 5px 5px rgb(255 255 255 / 30%);}
     .pointer {cursor: pointer;}
     .table_header{background: #0057a1 !important; color: white;}
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
     sub { font-size: 12px; float: right; position: absolute; bottom: 10px; right: 10px; }
     .spacer{width: 100%;height:50px}
     .right{text-align: right;}
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
        <tr><td class="centertext">Name: ]]..pj_name_..[[<br/>Sample Rate: ]]..pj_sampleRate..[[Hz</td><td class="centertext">]].. reaper.CountTracks() ..[[</td><td class="centertext">REAPER - v.]]..version..[[</td><td class="centertext">]]..author..[[</td><td>]]..pj_notes..[[</td></tr>
      </tbody>
    </table> ]]

  
  
----------------------------------------------
-- SPECIALIZED HEADER
----------------------------------------------
local PageHeaderCSV = 'EFFECTED TRACKS:\nTRACK IDX,TRACK NAME,TRACK TYPE,NOTES,N. ITEMS,SOLO,MUTE,FX/INSTRUMENTS NAME (VST/VSTi),FX En./Byp.,FX OnLine/OffLine,FX File'
local tableFXTracksHeader = [[<table class="center">
      <div class="spacer">&nbsp;</div>
      <thead>
        <tr><th colspan="11" class="header"><span class="info expand emboss pointer master">&#x25BC;</span><span class="info collapse engrave pointer master">&#x25B2;</span>EFFECTED TRACKS</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slave"><th colspan="4">TRACK</th><th colspan="3">STATUS</th><th colspan="4">FX and/or INSTRUMENTS(VST/VSTi)</th></tr>
        <tr class="table_header slave"><th>IDX</th><th>NAME</th><th>TYPE</th><th>NOTES</th><th>N. ITEMS</th><th>SOLO</th><th>MUTE</th><th>NAME</th><th id="EnDis">Enabled<br/>Bypassed</th><th id="OnOff">Online<br/>Offline</th><td>PLUGIN FILE</td></tr>
]]
local PageHeaderCSVNoted = LF..LF..'NOTED TRACKS:\nTRACK IDX,TRACK NAME,TRACK TYPE,NOTES,N. ITEMS,SOLO,MUTE'
local tableNotedTracksHeader = [[<table class="center">
      <thead>
        <tr><th colspan="7" class="header"><span class="info expandNoted emboss pointer masterNoted">&#x25BC;</span><span class="info collapseNoted engrave pointer masterNoted">&#x25B2;</span>NOTED TRACKS</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveNoted"><th colspan="4">TRACK</th><th colspan="3">STATUS</th></tr>
        <tr class="table_header slaveNoted"><th>IDX</th><th>NAME</th><th>TYPE</th><th>NOTES</th><th>N. ITEMS</th><th>SOLO</th><th>MUTE</th></tr>
]]
local PageHeaderItemsFXedCSV = LF..LF..'EFFECTED ITEMS:\nTRACK NAME,FX,ITEM POSITION,ITEM LENGTH,NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
local PageHeaderItemsFXedHTML = [[
    <div class="spacer">&nbsp;</div>
    <table class="center">
      <thead>
        <tr><th colspan="11" class="header"><span class="info expandFXedItems emboss pointer masterFXeditems">&#x25BC;</span><span class="info collapseFXedItems engrave pointer masterFXedItems">&#x25B2;</span>EFFECTED ITEMS DATA</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveFXedItems"><th colspan="5">MAIN DATA</th><th colspan="2">STATUS</th><th colspan="3">SOURCE</th></tr>
        <tr class="table_header slaveFXedItems"><th>BELONGIN TO</th><th>FX</th><th>POSITION</th><th>LENGTH</th><th>NOTES</th><th>MUTE</th><th>LOCKED</th><th>SOURCE NAME</th><th>SAMPLE RATE</th><th>BIT DEPTH</th></tr>
]]
local PageHeaderNotedItemsCSV = LF..LF..'NOTED ITEMS:\nTRACK NAME,ITEM POSITION,ITEM LENGTH,NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
local PageHeaderNotedItemsHTML = [[
    <table class="center">
      <thead>
        <tr><th colspan="10" class="header"><span class="info expandNotedItems emboss pointer masterNotedItems">&#x25BC;</span><span class="info collapseNotedItems engrave pointer masterNotedItems">&#x25B2;</span>NOTED ITEMS DATA</th></tr>
      </thead>
      <tbody>
        <tr class="table_header slaveNotedItems"><th colspan="4">MAIN DATA</th><th colspan="2">STATUS</th><th colspan="3">SOURCE</th></tr>
        <tr class="table_header slaveNotedItems"><th>BELONGIN TO</th><th>POSITION</th><th>LENGTH</th><th>NOTES</th><th>MUTE</th><th>LOCKED</th><th>SOURCE NAME</th><th>SAMPLE RATE</th><th>BIT DEPTH</th></tr>
]]



local PageFooterHTML = "  \n</body>\n</html>"
local PageFooterCSV = LF..",,,,,,,,,,Exported with 'EXPORT DATA' v." .. scriptVersion .. " by Tormy Van Cool"
if pj_name_ == "" then reaper.MB("The project MUST BE SAVED!!","WARNING",0,0) goto exit
end

f_csv:write( 'PROJECT:'..LF..'Name: '..pj_name_..LF..'Sample Rate: '..pj_sampleRate..'Hz'..LF..LF )
f_csv:write( 'TOTAL TRACKS: ' .. reaper.CountTracks() ..LF..LF )
f_csv:write( 'DAW:'..LF ..'REAPER v.' .. version ..LF..LF )
f_csv:write( 'CREATED:'..LF .. date ..LF..LF )
f_csv:write( 'AUTHOR:'..LF..author..LF..LF )

f_html:write( PageHeaderHTML..LF )


----------------------------------------------
-- FUNCTIONS
----------------------------------------------
function WriteFILE(listHTML,listCSV)
   f_csv:write( listCSV..LF )
   f_html:write( listHTML..LF )
end

function ridCommas(a)
   a_ = a:gsub(","," - ")
   return a_
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
    -- PROCESS EFFECTED TRACKS
    ----------------------------------------------
    for ii=1,reaper.TrackFX_GetCount(tr),1 do
  
      local ok,FXname=reaper.TrackFX_GetFXName(tr,ii-1,"")
      local isFXenabled_ = reaper.TrackFX_GetEnabled(tr,ii-1) -- Checks if plugin BLOCKS is Enabled
      local isOffline_ = reaper.TrackFX_GetOffline(tr,ii-1) -- Checks if plugin is OffLine
      local retval, moduleName = reaper.BR_TrackFX_GetFXModuleName(tr,ii-1) -- Retrieves module name. The DLL (SWS mandatory!)
      if numItems == 0 then numItems = '-' end

      local trackNotes = reaper.NF_GetSWSTrackNotes(tr)
      


       ----------------------------------------------
       -- ASSEMBLING CSV and HTML RECORDS
       ----------------------------------------------
       local list = i  .. ',' .. ridCommas(TrackName)  .. ',' .. isFolder .. ','.. ridCommas(trackNotes) .. ',' .. numItems .. ',' .. isSoloedCSV .. ',' .. isMutedCSV .. ',' .. ridCommas(FXname) .. ',' .. isFXenabledCSV .. ',' .. isOfflineCSV ..','.. moduleName
       local htmlList = '   <tr class=\"tracks slave\"><td class="centertext">'..i.."</td><td>"..TrackName..'</td><td class="centertext">'..isFolder..'</td><td>'..trackNotes..'</td><td class="centertext">' .. numItems .. "</td>" ..isSoloed..isMuted.."<td>"..FXname..isFXenabled..isOffline.."</td><td>"..moduleName.."</td></tr>"
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
    
    if isFXenabled_ == true then isFXenabled = '<td class="enabled">Enabled</td>' isFXenabledCSV = "E" else isFXenabled = '<td class="disabled">Bypassed</td>'isFXenabledCSV = "BYPASSED" end
    if isOffline_ == true then isOffline = '<td class="offline">OFF Line</td>' isOfflineCSV = "OFF" else isOffline = '<td class="online">On Line</td>'isOfflineCSV = "On" end
    
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
              lineCSV = ridCommas(itemTrackName) ..','.. ridCommas(fx_name) ..','.. itemPosition ..','.. itemLength ..','.. ridCommas(itemNotes) ..',' .. isMutedCSV ..','.. isLockedCSV ..','.. itemFilename ..','.. sourceSampleRate ..','.. bitDepth
              lineHTML = '   <tr class=\"tracks slaveFXedItems\"><td>' .. itemTrackName ..'</td><td>'.. fx_name ..'</td><td class="right">'.. itemPosition ..'</td><td class="right">'.. itemLength ..'</td><td>' .. itemNotes .. '</td>' .. isMutedHTML .. isLockedHTML ..'<td>'.. itemFilename ..'</td><td class="centertext">'.. sourceSampleRate ..'</td><td class="centertext">'.. bitDepth ..'</td></tr>'
  
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
              lineCSV = ridCommas(itemTrackName) ..','.. itemPosition ..','.. itemLength ..','.. ridCommas(itemNotes) ..',' .. isMutedCSV ..','.. isLockedCSV ..','.. itemFilename ..','.. sourceSampleRate ..','.. bitDepth
              lineHTML = '   <tr class=\"tracks slaveNotedItems\"><td>' .. itemTrackName ..'</td><td class="right">'.. itemPosition ..'</td><td class="right">'.. itemLength ..'</td><td>' .. itemNotes .. '</td>' .. isMutedHTML .. isLockedHTML ..'<td>'.. itemFilename ..'</td><td class="centertext">'.. sourceSampleRate ..'</td><td class="centertext">'.. bitDepth ..'</td></tr>'
              
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
FXedTracks()
NotedTracks()
FXedItems()
NotedItems()
closeFiles()
  reaper.MB("Files .CSV and HTML saved\ninto the Project Folder","DONE",0,0)
::exit::
