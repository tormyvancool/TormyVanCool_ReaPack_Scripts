-- https://forum.cockos.com/archive/index.php/t-209658.html
-- https://forum.cockos.com/showthread.php?t=238421
-- https://www.extremraym.com/en/downloads/reascripts-html-export/?fbclid=IwAR1W-wr0qf5M7hUaaTf_ca7WmI98Ty9BsGKXMIB-sHhD6xL5GmcsFxZ9W9k
-- https://stackoverflow.com/questions/36717078/handle-special-characters-in-lua-file-path-umlauts
--[[
IF YOU DON'T KEEP UPDATED: DON'T COMPLAIN FOR ISSUES!
@description Exporets project's data related to tracks, into CSV and HTML file
@author Tormy Van Cool
@version 3.3
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
v2.3 (26 may 2021)
  + Project Markers
  + Project Regions
  + Solo in Tracks Hierarchy
  + Mute in Tracks Hierarchy
  # Cosmetic changes on Project Data and Master Channel table
  # Minor issues on CSV format
v2.3a
  # Corrections into description
v2.3b
  # Mistyping correction
v2.4
  + Included jQuery base64
v2.5
  + Project MetaData
v2.6
  + Song Title (due new fiels on ALT+ENTER)
v2.7
  + Collapsible MetaData Table
v2.8
  + Check if SWS is installed
  + Check the Reaper version
  + Path into the export box
  # Specified Noted Tracks only
  # Specified Noted Items only
v2.9
  # CSS adaptation
v2.9.1
  # UTF-8 on HTML
v2.9.2
  # HH:MM:SS:FF
  + Project Tempo BPM
v2.9.3
  + URL Encode for spaces
  + Rendered audio: Only Audio Formats
v2.9.4
  + Management UTF8 Characters on file names
  + Metadata: Wavext
  + Metadata: Aswg
  + Metadata: Cafinfo
  + Links to Documentation
  # Mistyping corrections
v3.0
  # Version of Reaper
  + Tempo Markers
v3.1
  + Error travp in case project is not finished
  + export CSV Headers
v3.2
  # Not rading BWF Originator Reference
v3.3
  # Corrected file lsit for Mac
  + Remove cp.bat

@credits  Mario Bianchi for his contribution to expedite the process;
          Edgemeal, Meo-Ada Mespotine for the help into extracting directories [t=253830];
          Solger for his help on the color decode [t=253981]
          Spk77 for the part of the list to explore directories [p=1542391&postcount=3]
          Meo-Ada Mespotine for her suggestion to spot the REAPER.ini to find the correct rendering path [t=259455]
          MPL to give me the shortcut using SWS API isntead ot Reaper to extract the correct name from REAPER.ini [t=259455]
          Yanick & schwa to have given the easiest way to check the installation of SWS. Respectively [p=2495432&postcount=3] [p=1706951&postcount=7]
          Egor Skriptunoff for his precious help to convert special characters UTF8 [https://stackoverflow.com/questions/70170504/lua-how-to-correctly-read-uft8-file-names-and-path-with-accented-letters-and-um]
          Jack London to have highlighted the but on Mac system https://www.youtube.com/watch?v=_VDGMuxJ5xc
          Alb Vedo to have helped me to debug Mac https://www.facebook.com/groups/959114728148422/posts/1453458458714044/
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
  local currentFrameRate = reaper.TimeMap_curFrameRate(0)
  if seconds <= 0 then
    return "00:00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    --secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    secs = string.format("%.3f", (seconds - hours*3600 - mins *60));
    local fps = string.format("%02.f", math.floor(seconds * currentFrameRate % currentFrameRate));
    --return hours..":"..mins..":"..secs..":"..fps
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

---------------------------------------------
-- BASE64 DECODE
---------------------------------------------
function dec(data)
  local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
local LF = "\n"
local CSV = ".csv"
local HTML = ".html"
local scriptVersion = "3.3 FERRETS"
local Creator = "Tormy Van Cool"
local precision = 4
local timeFormat = "(hh:mm:ss,sss)"
local pj_notes = reaper.GetSetProjectNotes(0, 0, "")
local pj_sampleRate = tonumber(reaper.GetSetProjectInfo(0, "PROJECT_SRATE", 0, 0))
local pj_name_ = reaper.GetProjectName(0, "")
local _, pj_title = reaper.GetSetProjectInfo_String(0, "PROJECT_TITLE", '', 0)
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")
--local pj_name_ = string.gsub(string.gsub(pj_name_, ".rpp", ""), ".RPP", "")
local date = os.date("%Y-%m-%d %H:%M:%S")
local dateFile = '_' .. os.date("%Y-%m-%d_%H.%M.%S")
local author = reaper.GetSetProjectAuthor(0, 0, '')
local version = reaper.GetAppVersion()
local pj_length=round(reaper.GetProjectLength(),precision)
local totalMediaItems = reaper.CountMediaItems()
local _, totalMarkers, totalRegions = reaper.CountProjectMarkers()
local totalMarkersRegions = totalMarkers+totalRegions
local nameField_0 = 'Marker N.'
local nameField_1 = 'BPM'
local nameField_2 = 'Time Position'
local nameField_3 = 'Measure Position'
local nameField_4 = 'Beat'
local nameField_5 = 'Beat Position'
local nameField_6 = 'Samples'
local nameField_7 = 'Tempo Fractional'
local nameField_8 = 'Tempo Numerator'
local nameField_9 = 'Tempo Denominator'
local nameField_10 = 'Tempo Linearity'
local reaperURL = "https://www.reaper.fm"
local TormyURL = "https://www.facebook.com/TormyVanCool.MediaProductions"
local TVCEURL = "https://www.facebook.com/vancoolelektroakustik"
local _, RenderDir = reaper.BR_Win32_GetPrivateProfileString('REAPER', 'defrenderpath', '', reaper.get_ini_file())
local _, RencordingDir = reaper.BR_Win32_GetPrivateProfileString('REAPER', 'defrecpath', '', reaper.get_ini_file())
local renderPath = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)\\.*$","%1")..'/'..RenderDir
local SonyASWG = "http://gameaudiopodcast.com/ASWG-R001.pdf"
local AppleCAFINFO = "https://developer.apple.com/library/archive/documentation/MusicAudio/Reference/CAFSpec/CAF_overview/CAF_overview.html"
local BBCID3 = "https://id3.org/"
local BWFDoc = "https://tech.ebu.ch/docs/tech/tech3285.pdf"
local IFFDoc = "https://www.loc.gov/preservation/digital/formats/fdd/fdd000115.shtml"
local CUEDoc = "https://docs.fileformat.com/disc-and-media/cue/"
local VORBISDoc = "https://www.xiph.org/vorbis/doc/v-comment.html"
local AESDoc = "https://www.aes.org/publications/standards/search.cfm?docID=41"
local iXMLDoc = "http://www.gallery.co.uk/ixml/"
local XMPDoc = "https://www.adobe.com/products/xmp.html"
local APEDoc = "https://en.wikipedia.org/wiki/APE_tag"
 reaper.ExecProcess('cmd.exe /C dir "'..renderPath..'" > "'..renderPath..'/test_list.txt"', -1)
    reaper.ShowConsoleMsg(renderPath)