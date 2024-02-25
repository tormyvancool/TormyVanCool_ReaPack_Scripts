-- https://forum.cockos.com/archive/index.php/t-209658.html
-- https://forum.cockos.com/showthread.php?t=238421
-- https://www.extremraym.com/en/downloads/reascripts-html-export/?fbclid=IwAR1W-wr0qf5M7hUaaTf_ca7WmI98Ty9BsGKXMIB-sHhD6xL5GmcsFxZ9W9k
-- https://stackoverflow.com/questions/36717078/handle-special-characters-in-lua-file-path-umlauts
-- https://forum.cockos.com/showthread.php?t=259730
--[[
IF YOU DON'T KEEP UPDATED: DON'T COMPLAIN FOR ISSUES!
@description Exporets project's data related to tracks, into CSV and HTML file
@author Tormy Van Cool
@version 3.5
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
  + Remove cp.bat
v3.4 (23 feb 2024)
  # Corrected file list for Mac
v3.5
  + Decoding of the wildcards

@credits  Mario Bianchi for his contribution to expedite the process;
          Edgemeal, Meo-Ada Mespotine for the help into extracting directories [t=253830];
          Solger for his help on the color decode [t=253981]
          Spk77 for the part of the list to explore directories [p=1542391&postcount=3]
          Meo-Ada Mespotine for her suggestion to spot the REAPER.ini to find the correct rendering path [t=259455]
          MPL to give me the shortcut using SWS API isntead ot Reaper to extract the correct name from REAPER.ini [t=259455]
          Yanick & schwa to have given the easiest way to check the installation of SWS. Respectively [p=2495432&postcount=3] [p=1706951&postcount=7]
          Egor Skriptunoff for his precious help to convert special characters UTF8 [https://stackoverflow.com/questions/70170504/lua-how-to-correctly-read-uft8-file-names-and-path-with-accented-letters-and-um]
          Jack London to have highlighted the but on Mac system https://www.youtube.com/watch?v=_VDGMuxJ5xc
          Alb Vedo (the_metal_priest) to have helped me to debug Mac https://www.facebook.com/groups/959114728148422/posts/1453458458714044/
          FeedTheCat that have sugegsted the correct line code helping to solve the Mac issue https://forum.cockos.com/showthread.php?p=2761566#post2761566
          Cfillion adn Sexan https://forum.cockos.com/showthread.php?p=2761711#post2761711
          Schwa https://forum.cockos.com/showthread.php?t=282944
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
local scriptVersion = "3.5 FERRETS"
local Creator = "Tormy Van Cool"
local precision = 4
local timeFormat = "(hh:mm:ss,sss)"
local pj_notes = reaper.GetSetProjectNotes(0, 0, "")
local pj_sampleRate = tonumber(reaper.GetSetProjectInfo(0, "PROJECT_SRATE", 0, 0))
local pj_name_ = reaper.GetProjectName(0, "")
local _, pj_title = reaper.GetSetProjectInfo_String(0, "PROJECT_TITLE", '', 0)
local pj_path = reaper.GetProjectPathEx(0 , '' ):gsub("(.*)[\\/].*$","%1")
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
local renderPath = pj_path..'/'..RenderDir
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

------------------------------------------------
-- CHECK if SWS is INSTALLED and Reaper Version
------------------------------------------------
local test_SWS = reaper.CF_EnumerateActions
if not test_SWS then
  reaper.MB('Please install or update SWS extension', 'ERROR: SWS IS MISSING', 0)
  exit()
end

local minVersion = '7.11'
if minVersion > version then
  reaper.MB('your Reaper verions is '..version..'\nPlease update REAPER to the last version!', 'ERROR: REAPER '..version..' OUTDATED', 0)
  exit()
end

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



---------------------------------------------------------------------
-- Converter between win-125x and UTF-8 strings
---------------------------------------------------------------------
-- Written in pure Lua, compatible with Lua 5.1-5.4
-- Usage example:
--    require("win-125x")
--    str_win  = utf8_to_win(str_utf8)
--    str_utf8 = win_to_utf8(str_win)
---------------------------------------------------------------------

local codepage = 1252   -- Set your codepage here

-- The following codepages are supported:
--   874  Thai
--  1250  Central European
--  1251  Cyrillic
--  1252  Western
--  1253  Greek
--  1254  Turkish
--  1255  Hebrew
--  1256  Arabic
--  1257  Baltic
--  1258  Vietnamese

do
   local compressed_mappings = {
      -- Unicode to win-125x mappings are taken from unicode.org, compressed and protected by a checksum
      [874]  =  -- Thai, 97 codepoints above U+007F
         [[!%l+$"""WN^9=&$pqF'oheO#;0l#"hs)mI[=e!ufwkDB#OwLnJ|IRIUz8Q(MMM]],
      [1250] =  -- Central European, 123 codepoints above U+007F
         [[!<2#?v"1(ro;xh/tL_3hC^i;e~PjO"p<I\aTT};]Rb~M7/]&jRjfwuE%AJ)@XfBQy&\jy[V5:]!RtH]m>Yd8m?6LpsUA\V=x'VcMO<Wz+EOO
         0m7U`u|$Y5x?Vk*6+qJ@/0Lie77_b}OEuwv$Qj/w`+J>M*<g2qxD3qEyC&*{VGI'UddQ`GQ)L=lj<{S;Jm),f3yzcQOuxacHSZ{X'XIWzDz!?E
         =U0f]],
      [1251] =  -- Cyrillic, 127 codepoints above U+007F
         [[!-[;_8kMai7j]xB$^n)#7ngrX}_b%{<Cdot;P?2J&00&^wX|;]@N*fjq#ioX'v.&gG@ur~3yi8t1;xn40{G#NX?7+hGC{$D"4#oJ//~kflzs
         "_\z9qP#}1o|@{t`2NrM%t{MW?X9d6o:MqHl6+z]],
      [1252] =  -- Western, 123 codepoints above U+007F
         [[!)W$<c~\OdA5TJ%/J/{:yoE]K[d,c<Mv+gp_[_UuB52c;H&{leFk%Kd8%cHnvLrB[>|:)t.}QH*)]AD|LqjsB+JCdKmbRIjO,]],
      [1253] =  -- Greek, 111 codepoints above U+007F
         [[!./yDCq;#WAuC\C1R{=[n'FpSuc!"R\EZ|4&J?A3-z?*TI?ufbhFq1J!x@Sjff\!G{o^dDXl|8NLZ!$d'8$f^=hh_DPm!<>>bCgV(>erUWhX
         ?R+-JP@4ju:Yw#*C]],
      [1254] =  -- Turkish, 121 codepoints above U+007F
         [[!-(R[SPKY>cgcK5cCs4vk%MuL`yFx^Bl#/!l#M@#yoe|Jx+pxZuvh%r>O</n_gb>hDjmG]j#lA{]2"R-Z@(6Wy:Q~%;327b&fRSkF#BM/d+%
         iWmSx4E*\F_z=s>QeJBqC^]],
      [1255] =  -- Hebrew, 105 codepoints above U+007F
         [[!.b\.H?S\21+7efm'`w&MW_Jg,mRbB;{X@T\3::DC#7<m_cAE!:%C%c7/,./u[8w*h-iwpz03QY,ay%]MI*D]W&]UG^3(=20a7$zG[Ng7MLt
         sXIne(V37A?OO%|Hn13wMh-?^jNzhW`,-]],
      [1256] =  -- Arabic, 128 codepoints above U+007F
         [[!3n8GE$.to/ka%Nx`uOpcib>|9KU-N72!1J4c2NAUE3a,HlOE=M`@rsa||Nh_!og]:dILz9KNlF~vigNH*a0KxwjjfR*]?tO87(a3-RQex^V
         Ww&SY{:AqE|s%}@U8%rKcr0,NCjR:N&L'YyGu<us'sN*1pl=gAXOwSJ[v?f;imBhDu_)d$F8T?%S[]],
      [1257] =  -- Baltic, 116 codepoints above U+007F
         [[!:<_.XQ[;n35s%I?g9)b/7DiGwIR)zy&=6?/3)6iO%rSnC_6yjl'8#zeN0vcW_yX/2*J93+EJVrW,^Rhe,h7wWl"}neF2~F[PyD;BcrG*5=J
         fh<x!FJ?qSw9Xp!;WB3T<J^x?#Ie`xufezR'\I(eED]3d&)VJL$/+$Zf;W^I>L[3D5F<_IcGpn=oX"JR1%arS|FX|dia4]BeF>d5p`EV+:;*I<
         x^Voq{"f]],
      [1258] =  -- Vietnamese, 119 codepoints above U+007F
         [[!3n8C{%C0}&p3gE0~|&RVm9Wr&^ln1}'$gV{bml1oByN*bb:Bm^E;~B3-WjF6Qubq^`Y*6\0^w!DKpK<\7lHVELmSXN{2~B"0C"<1CYN2{$a
         5M?>|7%~qm{pXphwm3$}iyXjBYwtGqxp(f[!g^Ee9H.}1~0H-k-dzNDh1L]],
   }
   local char, byte, gmatch, floor, string_reverse = string.char, string.byte, string.gmatch, math.floor, string.reverse
   local table_insert, table_concat = table.insert, table.concat

   local function decompress_mapping()
      local width, offset, base, CS1, CS2, get_next_char = 1.0, 0.0, 0.0, 7^18, 5^22, gmatch(compressed_mappings[codepage], "%S")
      local mapping, rev_mapping, trees, unicode, ansi, prev_delta_unicode, prev_delta_ansi = {}, {}, {}, 0x7F, 0x7F

      local function decompress_selection(qty, tree)
         while width <= 94^7 do
            width, offset, base = width * 94.0, offset * 94.0 + byte(get_next_char()) - 33.0, (base - floor((base + width - 1) / 94^7) * 94^7) * 94.0
         end
         if qty then
            local big_qty = width % qty
            local small_unit = (width - big_qty) / qty
            local big_unit = small_unit + 1.0
            local offset_small = big_qty * big_unit
            local from, offset_from, left, right
            if offset < offset_small then
               width = big_unit
               offset_from = offset - offset % big_unit
               from = offset_from / big_unit
            else
               width = small_unit
               offset_from = offset - (offset - offset_small) % small_unit
               from = big_qty + (offset_from - offset_small) / small_unit
            end
            local len, leaf = 1.0, from
            if tree then
               leaf, left, right = 4, 0, qty
               repeat
                  local middle = tree[leaf]
                  if from < middle then
                     right = middle
                  else
                     left, leaf = middle, leaf + 1
                  end
                  leaf = tree[leaf + 1]
               until leaf < 0
               from, len = left, right - left
               offset_from = left < big_qty and left * big_unit or offset_small + (left - big_qty) * small_unit
               width = (right < big_qty and right * big_unit or offset_small + (right - big_qty) * small_unit) - offset_from
            end
            base, offset = base + offset_from, offset - offset_from
            CS1, CS2 = (CS1 % 93471801.0) * (CS2 % 93471811.0) + qty, (CS1 % 93471821.0) * (CS2 % 93471831.0) - from * 773.0 - len * 7789.0
            return leaf
         end
         assert((CS1 - CS2) % width == offset)
      end

      local function get_delta(tree_idx)
         local tree = trees[tree_idx]
         local val = tree[3]
         if val == 0.0 then
            local leaf = decompress_selection(tree[1], tree)
            local max_exp_cnt = tree[2]
            val = leaf % max_exp_cnt
            leaf = (leaf - val) / max_exp_cnt + 2.0
            val = 2.0^val
            val = val + decompress_selection(val)
            if leaf ~= 0.0 then
               return leaf * val
            end
         end
         tree[3] = val - 1.0
      end

      for tree_idx = 1, 2 do
         local total_freq = decompress_selection(2^15)
         local max_exp_cnt = decompress_selection(17)
         local tree, qty_for_leaf_info = {total_freq, max_exp_cnt, 0.0}, 3 * max_exp_cnt

         local function build_subtree(left, right, idx)
            local middle, subtree = left + 1
            middle = decompress_selection(right - middle) + middle
            tree[idx], idx = middle, idx + 3
            for next_idx = idx - 2, idx - 1 do
               if decompress_selection(2) == 1 then
                  subtree, idx = idx, build_subtree(left, middle, idx)
               else
                  subtree = decompress_selection(qty_for_leaf_info) - qty_for_leaf_info
               end
               tree[next_idx], left, middle = subtree, middle, right
            end
            return idx
         end

         build_subtree(0, total_freq, 4)
         trees[tree_idx] = tree
      end
      while true do
         local delta = get_delta(1)
         if not delta then
            delta = prev_delta_unicode
         elseif delta == prev_delta_unicode then
            decompress_selection()
            return mapping, rev_mapping
         end
         unicode, prev_delta_unicode, delta = unicode + delta, delta, get_delta(2) or prev_delta_ansi
         ansi, prev_delta_ansi = ansi + delta, delta
         mapping[unicode] = ansi
         rev_mapping[ansi] = unicode
      end
   end

   local map_unicode_to_ansi, map_ansi_to_unicode = decompress_mapping()

   function utf8_to_win(str)
      local result_ansi = {}
      for u in gmatch(str, ".[\128-\191]*") do
         local code = byte(u)%2^(8-#u)
         for j = 2, #u do
            code = (code-2)*64+byte(u,j)
         end
         table_insert(result_ansi, char(code < 128 and code or map_unicode_to_ansi[code] or byte"?"))
      end
      return table_concat(result_ansi)
   end

   function win_to_utf8(str)
      local result_utf8 = {}
      for pos = #str, 1, -1 do
         local code, h = byte(str, pos), 127
         code = code < 128 and code or map_ansi_to_unicode[code] or byte"?"
         while code > h do
            table_insert(result_utf8, char(128 + code%64))
            code, h = floor(code/64), 288067%h
         end
         table_insert(result_utf8, char((127-h)*2+code))
      end
      return string_reverse(table_concat(result_utf8))
   end

end


local function URI(file)
   -- add more special symbols here
   return file:gsub(" ", "%%20")
end

--local bat_file = utf8_to_win("C:\\path\\to\\cp.bat")  -- insert your path here

----------------------------------------------
-- SCAN RENDERED AUDIO
-- DIRECTORY = string = Path to the rendered audio files repository
-- FORMAT = Integer  => 1 = HTML format. 2 = CSV format
----------------------------------------------
function scandir(directory,format)
  local i, t, popen = 0, {}, io.popen, _OsBasedString, bat_file, fileBat, extension
  t = ''
  local OS = reaper.GetOS()
  if OS == "Win32" or OS == "Win64" then
    fileBat = io.open(directory.."\\cp.bat","w")
    if fileBat == nil then
      reaper.MB("YOU WILL RECEIVE AN ERROR\n\nThe project must be finished upfront report export\nIt means:\n- Render the audio files;\n- finish the project;\n- and then export this report", 'WARNING', 0)
    end
    fileBat:write("@chcp %1 >nul") 
    fileBat:close()
    --os.remove(directory.."\\cp.bat")
    bat_file = utf8_to_win(directory.."\\cp.bat")  -- insert your path here
    _OsBasedString = '""'..bat_file..'" 65001 <nul & dir /b "'..utf8_to_win(directory)..'""'    
  else
    _OsBasedString = 'ls "' .. directory..'"'
  end
  for filename in popen(_OsBasedString):lines() do
    extension = filename:match("^.+(%..+)$")
    if extension == ".wav" or
       extension == ".mp3" or
       extension == ".flac" or
       extension == ".mov" or
       extension == ".ogg" or
       extension == ".mp4" then
        if format == 1 then
          t = t..'<tr class="Rendered"><td>'..directory..'</td><td>'..tostring(filename)..'</td><td><audio controls src="'..URI(directory..'/'..filename)..'"/></td></tr>'
        elseif format == 2 then
          t = t..directory..','..filename..','..directory..'/'..filename..LF
        end
        i = i + 1
    end
  end  
  if OS == "Win32" or OS == "Win64" then
    os.remove(directory.."\\cp.bat")
  end
  return t
end

----------------------------------------------
-- PROJECT METADATA
----------------------------------------------

function resolve_wildcard(wildcard)
  ok,restore_path=reaper.GetSetProjectInfo_String(0, "RENDER_FILE", "", 0)
  ok,restore_pattern=reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", "", 0)
  
  reaper.GetSetProjectInfo_String(0, "RENDER_FILE", "C:\\", 1)
  reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", wildcard, 1);
  ok,resolved=reaper.GetSetProjectInfo_String(0, "RENDER_TARGETS", "", 0)
  resolved=string.sub(resolved, 4, string.len(resolved)-4)
  --reaper.ShowConsoleMsg(wildcard .. ' : ' .. resolved.. '\n')

  reaper.GetSetProjectInfo_String(0, "RENDER_FILE", restore_path, 1)
  reaper.GetSetProjectInfo_String(0, "RENDER_PATTERN", restore_pattern, 1)
  return resolved
end

reaper.ShowConsoleMsg('')
function MetaData(Scheme,Category,Description,Meta)
 local retval, valuestrNeedBig = reaper.GetSetProjectInfo_String(0, "RENDER_METADATA", Scheme..":"..Meta, 0)
  local a={}
  --local w =''
  local decoded = ""
  if string.match (valuestrNeedBig, "%$(%w+)") then
    for w in string.gmatch(valuestrNeedBig,"%$(%w+)") do
    wildcard = "$"..w
    --reaper.ShowConsoleMsg(w)
    decoded = decoded .. resolve_wildcard(wildcard)
    valuestrNeedBig = valuestrNeedBig:gsub(wildcard, resolve_wildcard("$"..w))
    end
    else
    decoded = ""
  end
  if valuestrNeedBig ~= nil then
    a[1] = '<tr class="child'..Scheme..'"><td>'..Category..'</td><td>'..Description..'<td class="id3ttl">'..Meta..'</td><td class="" colspan="5">'..valuestrNeedBig..'</td></tr>'
    a[2] = Scheme..','..Category..','..Description..','..Meta..','..valuestrNeedBig..LF
   return a
  else
   return ''
  end
  
end

function MetaMP3(i)
  local meta
   meta = MetaData('ID3',"Title","Title","TIT2")[i]..
    MetaData('ID3',"Title","Description","TIT3")[i]..
    MetaData('ID3',"Artist","Artist","TPE1")[i]..
    MetaData('ID3',"Artist","Album Artist","TPE2")[i]..
    MetaData('ID3',"Musical","Genre","TCON")[i]..
    MetaData('ID3',"Musical","Key","TKEY")[i]..
    MetaData('ID3',"Musical","Tempo","TBPM")[i]..
    MetaData('ID3',"Date","Date YYYY-MM-DD","TDRC")[i]..
    MetaData('ID3',"Date","Date YYYY-MM-DD","TYER")[i]..
    MetaData('ID3',"Date","Recording Time MM:SS","TIME")[i]..
    MetaData('ID3',"Project","Album","TALB")[i]..
    MetaData('ID3',"Comment","Comment","COMM")[i]..
    MetaData('ID3',"","","TXXX")[i]..
    MetaData('ID3',"REAPER","Media Explorer","TXXX:REAPER")[i]..
    MetaData('ID3',"Personnel","Composer","TCOM")[i]..
    MetaData('ID3',"Personnel","Involved People","TIPL")[i]..
    MetaData('ID3',"Personnel","Lyricist","TEXT")[i]..
    MetaData('ID3',"Personnel","Musician Credits","TMCL")[i]..
    MetaData('ID3',"Parts","Track Number","TRCK")[i]..
    MetaData('ID3',"Parts","Chapter<br>[automatic from CHAP= marker region]","CHAP")[i]..
    MetaData('ID3',"Parts","Content Group","TIT1")[i]..
    MetaData('ID3',"Parts","Part Number","TPOS")[i]..
    MetaData('ID3',"Spot","Start Offset [Automatic]","TXXX/TIME-REFERENCE")[i]..
    MetaData('ID3',"Code","ISRC","TSRC")[i]..
    MetaData('ID3',"License","Copyright Mess","TCOP")[i]..
    MetaData('ID3',"Technical","Language","COMM_LANG")[i]..
    MetaData('ID3',"Binary","Image Type","APIC_TYPE")[i]..
    MetaData('ID3',"Binary","Image Description","APIC_DESC")[i]..
    MetaData('ID3',"Binary","Image File","APIC_FILE")[i]
  return tostring(meta)
end


function MetaBWF(i)
  local meta
    meta = MetaData('BWF',"Title","Title","Description")[i]..
    MetaData('BWF',"Date","Date YYYY-MM-DD","OriginationDate")[i]..
    MetaData('BWF',"Date","Recording Time MM:SS","OriginationTime")[i]..
    MetaData('BWF',"Project","Originator","Originator")[i]..
    MetaData('BWF',"Project","Originator Refer","OriginatorReference")[i]..
    MetaData('BWF',"Spot","Start Offset [Automatic]","TimeReference")[i]
  return tostring(meta)
end


function MetaAXML(i)
  local meta
    meta = MetaData('AXML','Code','ISRC','ISRC')[i]
  return tostring(meta)
end


function MetaCART(i)
  local meta
    meta = MetaData('CART','Title','Title','Title')[i]..
    MetaData('CART','Artist','Artist','Artist')[i]..
    MetaData('CART','Musical','Genre','Category')[i]..
    MetaData('CART','Date','Date YYYY-MM-DD','StartDate')[i]..
    MetaData('CART','Date','Date YYYY-MM-DD','EndDate')[i]..
    MetaData('CART','Comment','Comment','TagText')[i]..
    MetaData('CART','Comment','URL','URL')[i]..
    MetaData('CART','Personnel','Client','ClientID')[i]..
    MetaData('CART','Parts','Track Number','CutID')[i]..
    MetaData('CART','Parts','Intro [Automatic from INT1 marker]','INT1')[i]..
    MetaData('CART','Parts','Segue [Automatic from SEG1 marker','SEG1')[i]
  return tostring(meta)
end

function MetaIFF(i)
  local meta
    meta = MetaData('IFF','Title','Title','NAME')[i]..
    MetaData('IFF','Title','Description','ANNO')[i]..
    MetaData('IFF','Artist','Artist','AUTH')[i]..
    MetaData('IFF','License','Copyright Message','COPY')[i]
  return tostring(meta)
end


function MetaCUE(i)
  local meta
    meta= MetaData('CUE','Title','Title','DISC_TITLE')[i]..
    MetaData('CUE','Title','Track Title [Automatic as per render settings]','TRACK_TITLE')[i]..
    MetaData('CUE','Artist','Performer','DISC_PERFORMER')[i]..
    MetaData('CUE','Artist','Track Performer [Automatic from PERF= marker]','TRACK_PERFORMER')[i]..
    MetaData('CUE','Comment','Comment','DISC_REM')[i]..
    MetaData('CUE','Personnel','Songwriter','DISC_SONGWRITER')[i]..
    MetaData('CUE','Personnel','Track Songwriter [Automatic from WRIT= marker]','TRACK_SONGWRITER')[i]..
    MetaData('CUE','Part','Track Numnber','INDEX')[i]..
    MetaData('CUE','Code','Code ISRC [Automatic from ISRC= marker]','TRACK_ISRC')[i]..
    MetaData('CUE','Code','Barcode','DISC_CATALOG')[i]
  return tostring(meta)
end

function MetaINFO(i)
  local meta
    meta = MetaData('INFO','Title','Title','INAM')[i]..
    MetaData('INFO','Title','Description','IKEY')[i]..
    MetaData('INFO','Title','Description','ISBJ')[i]..
    MetaData('INFO','Artist','Artist','IART')[i]..
    MetaData('INFO','Musical','Genre','IGNR')[i]..
    MetaData('INFO','Date','Date YYYY-MM-DD','ICRD')[i]..
    MetaData('INFO','Project','Album','IPRD')[i]..
    MetaData('INFO','Project','Source','ISRC')[i]..
    MetaData('INFO','Comment','Comment','ICMT')[i]..
    MetaData('INFO','Personnel','Engineer','IENG')[i]..
    MetaData('INFO','Parts','Track Numbner','TRCK')[i]..
    MetaData('INFO','License','Copyright Message','ICOP')[i]
  return tostring(meta)
end

function MetaIXML(i)
  local meta
    meta = MetaData('IXML','Title','Title','INAM')[i]..
    MetaData('IXML','Comment','Comment','IKEY')[i]..
    MetaData('IXML','REAPER','Media Explorer','IART')[i]..
    MetaData('IXML','Parts','Circled Take [TRUE or FALSE]','IGNR')[i]..
    MetaData('IXML','Parts','Scene','ICRD')[i]..
    MetaData('IXML','Parts','Sound Roll','IPRD')[i]..
    MetaData('IXML','Parts','Take ID','ISRC')[i]..
    MetaData('IXML','Parts','Unique Identifier','ICMT')[i]
  return tostring(meta)
end

function MetaFLACPIC(i)
  local meta
    meta = MetaData('FLACPIC','Binary','Image Type','APIC_TYPE')[i]..
    MetaData('FLACPIC','Binary','Image Description','APIC_DESC')[i]..
    MetaData('FLACPIC','Binary','Imge File [jpg or png]','APIC_FILE')[i]
  return tostring(meta)
end

function MetaXMP(i)
  local meta
    meta = MetaData('XMP','Title','Title','dc/title')[i]..
    MetaData('XMP','Title','Description','dc/description')[i]..
    MetaData('XMP','Artist','Artist','dm/artist')[i]..
    MetaData('XMP','Musical','Genre','dm/genre')[i]..
    MetaData('XMP','Musical','Key','dm/key')[i]..
    MetaData('XMP','Musical','Tempo','dm/tempo')[i]..
    MetaData('XMP','Musical','Time Signature','dm/timeSignature')[i]..
    MetaData('XMP','Date YYYY-MM-DD','Date','dc/date')[i]..
    MetaData('XMP','Project','Album','dm/album')[i]..
    MetaData('XMP','Comment','Comment','dm/logComment')[i]..
    MetaData('XMP','Personnel','Composer','dm/composer')[i]..
    MetaData('XMP','Personnel','Creator','dc/creator')[i]..
    MetaData('XMP','Personnel','Engineer','dm/engineer')[i]..
    MetaData('XMP','Parts','Track Number','dm/trackNumber')[i]..
    MetaData('XMP','Parts','Markers','dm/markers')[i]..
    MetaData('XMP','Parts','Scene','dm/scene')[i]..
    MetaData('XMP','Spot','Start Offset [automatic]','dm/relativeTimestamp')[i]..
    MetaData('XMP','License','Copyright Message','dm/copyright')[i]..
    MetaData('XMP','Technical','Lanugage [3-characters code like "eng"]','dc/language')[i]
  return tostring(meta)
end


function MetaAPE(i)
  local meta
    meta = MetaData('APE','Title','Title','Title')[i]..
    MetaData('APE','Title','Description','Subtitle')[i]..
    MetaData('APE','Artist','Artist','Artist')[i]..
    MetaData('APE','Musical','Genre','Genre')[i]..
    MetaData('APE','Musical','Key','Key')[i]..
    MetaData('APE','Musical','Tempo','BPM')[i]..
    MetaData('APE','Musical','Time Signature','dm/timeSignature')[i]..
    MetaData('APE','Date YYYY-MM-DD','Date','Record Date')[i]..
    MetaData('APE','Date YYYY-MM-DD','Date','Year')[i]..
    MetaData('APE','Project','Album','Album')[i]..
    MetaData('APE','Comment','Comment','Comment')[i]..
    MetaData('APE','REAPER','Media Explorer','REAPER')[i]..
    MetaData('APE','Personnel','Composer','Composer')[i]..
    MetaData('APE','Personnel','Conductor','Conductor')[i]..
    MetaData('APE','Personnel','Publisher','Publisher')[i]..
    MetaData('APE','Parts','Track Number','Track')[i]..
    MetaData('APE','Code','ISRC','ISRC')[i]..
    MetaData('APE','Code','CATALOG','CATALOG')[i]..
    MetaData('APE','License','Copyright Holder','Copyright')[i]..
    MetaData('APE','Technical','Recording Location','Record Location')[i]..
    MetaData('APE','Technical','Language [3-characters code like "eng"]','Language')[i]
  return tostring(meta)
end


function MetaVORBIS(i)
  local meta
    meta = MetaData('VORBIS','Title','Title','TITLE')[i]..
    MetaData('VORBIS','Title','Description','DESCRIPTION')[i]..
    MetaData('VORBIS','Artist','Artist','ARTIST')[i]..
    MetaData('VORBIS','Artist','Album Artist','ALBUMARTIST')[i]..
    MetaData('VORBIS','Artist','Performer','PERFORMER')[i]..
    MetaData('VORBIS','Musical','Genre','GENRE')[i]..
    MetaData('VORBIS','Musical','Key','KEY')[i]..
    MetaData('VORBIS','Musical','Tempo','BPM')[i]..
    MetaData('VORBIS','Date','Date YYYY-MM-DD','DATE')[i]..
    MetaData('VORBIS','Project','Album','ALBUM')[i]..
    MetaData('VORBIS','Project','Label','LABEL')[i]..
    MetaData('VORBIS','Comment','Comment','COMMENT')[i]..
    MetaData('VORBIS','REAPER','Media Explorer','REAPER')[i]..
    MetaData('VORBIS','Personnel','Author','AUTHOR')[i]..
    MetaData('VORBIS','Personnel','Arranger','ARRANGER')[i]..
    MetaData('VORBIS','Personnel','Enseble','ENSEMBLE')[i]..
    MetaData('VORBIS','Personnel','Composer','COMPOSER')[i]..
    MetaData('VORBIS','Personnel','Conductor','CONDUCTOR')[i]..
    MetaData('VORBIS','Personnel','Lyricist','LYRICIST')[i]..
    MetaData('VORBIS','Personnel','Producer','PRODUCER')[i]..
    MetaData('VORBIS','Personnel','Publisher','PUBLISHER')[i]..
    MetaData('VORBIS','Parts','Track Number','TRACKNUMBER')[i]..
    MetaData('VORBIS','Parts','Chapter [automatic from CHAP= marker/region]','CHAPTER')[i]..
    MetaData('VORBIS','Parts','Disc Number','DISCNUMBER')[i]..
    MetaData('VORBIS','Parts','Number of Work','OPUS')[i]..
    MetaData('VORBIS','Parts','Part','PART')[i]..
    MetaData('VORBIS','Parts','Part Number','PARTNUMBER')[i]..
    MetaData('VORBIS','Parts','Version','VERSION')[i]..
    MetaData('VORBIS','Spot','Start Offset [automatic]','TIME_REFERENCE')[i]..
    MetaData('VORBIS','Code','ISRC','ISRC')[i]..
    MetaData('VORBIS','Code','Barcode','EAN/UPN')[i]..
    MetaData('VORBIS','Code','Catalog Number','LABELNO')[i]..
    MetaData('VORBIS','License','Copyright Holder','COPYRIGHT')[i]..
    MetaData('VORBIS','License','Catalog Number','LICENSE')[i]..
    MetaData('VORBIS','Technical','Recording Location','LOCATION')[i]..
    MetaData('VORBIS','Technical','Language [3-characters code like "eng]','LANGUAGE')[i]..
    MetaData('VORBIS','Technical','Encoding Settings','ENCODING')[i]..
    MetaData('VORBIS','Technical','Encoded by','ENCODED-BY')[i]..
    MetaData('VORBIS','Technical','Original Recording Media','SOURCEMEDIA')[i]
  return tostring(meta)
end

function MetaWAVEXT(i)
  local meta
    meta = MetaData('WAVEXT',"Technical","Channel Confituration<br>[only used if consistent with chnannel count]","channel configuration")[i]
  return tostring(meta)
end

function MetaASWG(i) -- TO BE COMPLETED --
  local meta
    meta = MetaData('ASWG',"General","Title","project")[i]..
    MetaData('ASWG',"General","DescriptionD","session")[i]..
    MetaData('ASWG',"General","Comment","notes")[i]..
    MetaData('ASWG',"Artist","Artist","artist")[i]..
    MetaData('ASWG',"Musical","Genre","genre")[i]..
    MetaData('ASWG',"Musical","Instrument","instrument")[i]..
    MetaData('ASWG',"Musical","Intensity","intensity")[i]..
    MetaData('ASWG',"Musical","Key","inKey")[i]..
    MetaData('ASWG',"Musical","Loop","isLoop")[i]..
    MetaData('ASWG',"Musical","Sub-Genre","subGenre")[i]..
    MetaData('ASWG',"Musical","Tempo","tempo")[i]..
    MetaData('ASWG',"Musical","Time Signature","timeSig")[i]..
    MetaData('ASWG',"Performance","Transcript","text")[i]..
    MetaData('ASWG',"Performance","Actor Gender","actorGender")[i]..
    MetaData('ASWG',"Performance","Actor Name","actorName")[i]..
    MetaData('ASWG',"Performance","Character Age","characterAge")[i]..
    MetaData('ASWG',"Performance","Character Gender","characterGender")[i]..
    MetaData('ASWG',"Performance","Character Name","characterName")[i]..
    MetaData('ASWG',"Performance","Character Role","characterRole")[i]..
    MetaData('ASWG',"Performance","Digalogue Contains Efforts","efforts")[i]..
    MetaData('ASWG',"Performance","Digalogue Effort Type","effortType")[i]..
    MetaData('ASWG',"Performance","Digalogue Emotion","emotion")[i]..
    MetaData('ASWG',"Performance","Digalogue Regional Accent","accent")[i]..
    MetaData('ASWG',"Performance","Digalogue Timing Restriction","timingRestriction")[i]..
    MetaData('ASWG',"Performance","Director","director")[i]..
    MetaData('ASWG',"Performance","Director's Notes","direction")[i]..
    MetaData('ASWG',"Personnel","Composer","composer")[i]..
    MetaData('ASWG',"Personnel","Creator","creatorid")[i]..
    MetaData('ASWG',"Personnel","Editor","editor")[i]..
    MetaData('ASWG',"Personnel","Engineer","recEngineer")[i]..
    MetaData('ASWG',"Personnel","Mixer","mixer")[i]..
    MetaData('ASWG',"Personnel","Music Supervisor","musicSup")[i]..
    MetaData('ASWG',"Personnel","Producer","producer")[i]..
    MetaData('ASWG',"Personnel","Publisher","musicPublisher")[i]..
    MetaData('ASWG',"Project","Cinematic","isCinematic")[i]..
    MetaData('ASWG',"Project","Content Type","contentType")[i]..
    MetaData('ASWG',"Project","Final","isFinal")[i]..
    MetaData('ASWG',"Project","Original","isOst")[i]..
    MetaData('ASWG',"Project","Originator","originator")[i]..
    MetaData('ASWG',"Project","Originator Studio","originatorStudio")[i]..
    MetaData('ASWG',"Project","Reoording Studio","recStudio")[i]..
    MetaData('ASWG',"Project","Song Title","songTitle")[i]..
    MetaData('ASWG',"Project","Source","isSource")[i]..
    MetaData('ASWG',"Project","Version","musicVersion")[i]..
    MetaData('ASWG',"Part","Part Number","orderRef")[i]..
    MetaData('ASWG',"Code","ISRC","isrcId")[i]..
    MetaData('ASWG',"Code","Billing Code","billingCode")[i]..
    MetaData('ASWG',"License","License","isLicensed")[i]..
    MetaData('ASWG',"License","Rights Owner","rightsOwner")[i]..
    MetaData('ASWG',"License","Union Contract","isUnion")[i]..
    MetaData('ASWG',"License","Usage Rights","usageRights")[i]..
    MetaData('ASWG',"Technical","Ambisonic Channel Order","ambisonicChnOrder")[i]..
    MetaData('ASWG',"Technical","Ambisonic Format","ambisonicFormat")[i]..
    MetaData('ASWG',"Technical","Ambisonic Normalization Method","ambisonicNom")[i]..
    MetaData('ASWG',"Technical","Average Zero Cross Rate","zeroCrossRate")[i]..
    MetaData('ASWG',"Technical","Channel Layout Tex [Descriptive text]t","channelConfig")[i]..
    MetaData('ASWG',"Technical","Designed Or Raw","isDesigned")[i]..
    MetaData('ASWG',"Technical","Diegetic","isDiegetic")[i]..
    MetaData('ASWG',"Technical","File State","state")[i]..
    MetaData('ASWG',"Technical","FX Category","category")[i]..
    MetaData('ASWG',"Technical","FX Category ID","catId")[i]..
    MetaData('ASWG',"Technical","FX Chain Name","fxChainName")[i]..
    MetaData('ASWG',"Technical","FX Name","fxName")[i]..
    MetaData('ASWG',"Technical","FX Sub-Category","subCategory")[i]..
    MetaData('ASWG',"Technical","FX Used","fxUsed")[i]..
    MetaData('ASWG',"Technical","Language [eng. spa. ...]","language")[i]..
    MetaData('ASWG',"Technical","LRA Loudness range","loudnessRange")[i]..
    MetaData('ASWG',"Technical","LUFS-I Integrated Loudness","loudness")[i]..
    MetaData('ASWG',"Technical","Maximum Peak Value dBFS","mxPeak")[i]..
    MetaData('ASWG',"Technical","Microphone Configuration","micConfig")[i]..
    MetaData('ASWG',"Technical","Microphone Distance","micDistance")[i]..
    MetaData('ASWG',"Technical","Microphone Type","micType")[i]..
    MetaData('ASWG',"Technical","Peak To Average Power Ratio","papr")[i]..
    MetaData('ASWG',"Technical","Recording Location","impulseLocation")[i]..
    MetaData('ASWG',"Technical","Recording Location","recordingLoc")[i]..
    MetaData('ASWG',"Technical","RMS Power","mspower")[i]..
    MetaData('ASWG',"Technical","Sound effects Library","library")[i]..
    MetaData('ASWG',"Technical","Source IO","sourceId")[i]..
    MetaData('ASWG',"Technical","Spectral Density [24 comma-separated values]","specDensity")[i]..
    MetaData('ASWG',"Technical","User Category","userCategory")[i]..
    MetaData('ASWG',"Technical","User Data","userData")[i]..
    MetaData('ASWG',"Technical","Vendor Category","vendorCategory")[i]
  return tostring(meta)
end

function MetaCAFINFO(i)
  local meta
    meta = MetaData('CAFINFO',"General","Title [$project]","title")[i]
  return tostring(meta)
end

local jQuery = [[LyohIGpRdWVyeSB2My41LjEgfCAoYykgSlMgRm91bmRhdGlvbiBhbmQgb3RoZXIgY29udHJpYnV0b3JzIHwganF1ZXJ5Lm9yZy9saWNlbnNlICovCiFmdW5jdGlvbihlLHQpeyJ1c2Ugc3RyaWN0Ijsib2JqZWN0Ij09dHlwZW9mIG1vZHVsZSYmIm9iamVjdCI9PXR5cGVvZiBtb2R1bGUuZXhwb3J0cz9tb2R1bGUuZXhwb3J0cz1lLmRvY3VtZW50P3QoZSwhMCk6ZnVuY3Rpb24oZSl7aWYoIWUuZG9jdW1lbnQpdGhyb3cgbmV3IEVycm9yKCJqUXVlcnkgcmVxdWlyZXMgYSB3aW5kb3cgd2l0aCBhIGRvY3VtZW50Iik7cmV0dXJuIHQoZSl9OnQoZSl9KCJ1bmRlZmluZWQiIT10eXBlb2Ygd2luZG93P3dpbmRvdzp0aGlzLGZ1bmN0aW9uKEMsZSl7InVzZSBzdHJpY3QiO3ZhciB0PVtdLHI9T2JqZWN0LmdldFByb3RvdHlwZU9mLHM9d
C5zbGljZSxnPXQuZmxhdD9mdW5jdGlvbihlKXtyZXR1cm4gdC5mbGF0LmNhbGwoZSl9OmZ1bmN0aW9uKGUpe3JldHVybiB0LmNvbmNhdC5hcHBseShbXSxlKX0sdT10LnB1c2gsaT10LmluZGV4T2Ysbj17fSxvPW4udG9TdHJpbmcsdj1uLmhhc093blByb3BlcnR5LGE9di50b1N0cmluZyxsPWEuY2FsbChPYmplY3QpLHk9e30sbT1mdW5jdGlvbihlKXtyZXR1cm4iZnVuY3Rpb24iPT10eXBlb2YgZSYmIm51bWJlciIhPXR5cGVvZiBlLm5vZGVUeXBlfSx4PWZ1bmN0aW9uKGUpe3JldHVybiBudWxsIT1lJiZlPT09ZS53aW5kb3d9LEU9Qy5kb2N1bWVudCxjPXt0eXBlOiEwLHNyYzohMCxub25jZTohMCxub01vZHVsZTohMH07ZnVuY3Rpb24gYihlLHQsbil7dmFyIHIsaSxvPShuPW58fEUpLmNyZWF0ZUVsZW1lbnQoInNjcmlwdCIpO2lmKG8udGV4dD1
lLHQpZm9yKHIgaW4gYykoaT10W3JdfHx0LmdldEF0dHJpYnV0ZSYmdC5nZXRBdHRyaWJ1dGUocikpJiZvLnNldEF0dHJpYnV0ZShyLGkpO24uaGVhZC5hcHBlbmRDaGlsZChvKS5wYXJlbnROb2RlLnJlbW92ZUNoaWxkKG8pfWZ1bmN0aW9uIHcoZSl7cmV0dXJuIG51bGw9PWU/ZSsiIjoib2JqZWN0Ij09dHlwZW9mIGV8fCJmdW5jdGlvbiI9PXR5cGVvZiBlP25bby5jYWxsKGUpXXx8Im9iamVjdCI6dHlwZW9mIGV9dmFyIGY9IjMuNS4xIixTPWZ1bmN0aW9uKGUsdCl7cmV0dXJuIG5ldyBTLmZuLmluaXQoZSx0KX07ZnVuY3Rpb24gcChlKXt2YXIgdD0hIWUmJiJsZW5ndGgiaW4gZSYmZS5sZW5ndGgsbj13KGUpO3JldHVybiFtKGUpJiYheChlKSYmKCJhcnJheSI9PT1ufHwwPT09dHx8Im51bWJlciI9PXR5cGVvZiB0JiYwPHQmJnQtMSBpbiBlKX1TL
mZuPVMucHJvdG90eXBlPXtqcXVlcnk6Zixjb25zdHJ1Y3RvcjpTLGxlbmd0aDowLHRvQXJyYXk6ZnVuY3Rpb24oKXtyZXR1cm4gcy5jYWxsKHRoaXMpfSxnZXQ6ZnVuY3Rpb24oZSl7cmV0dXJuIG51bGw9PWU/cy5jYWxsKHRoaXMpOmU8MD90aGlzW2UrdGhpcy5sZW5ndGhdOnRoaXNbZV19LHB1c2hTdGFjazpmdW5jdGlvbihlKXt2YXIgdD1TLm1lcmdlKHRoaXMuY29uc3RydWN0b3IoKSxlKTtyZXR1cm4gdC5wcmV2T2JqZWN0PXRoaXMsdH0sZWFjaDpmdW5jdGlvbihlKXtyZXR1cm4gUy5lYWNoKHRoaXMsZSl9LG1hcDpmdW5jdGlvbihuKXtyZXR1cm4gdGhpcy5wdXNoU3RhY2soUy5tYXAodGhpcyxmdW5jdGlvbihlLHQpe3JldHVybiBuLmNhbGwoZSx0LGUpfSkpfSxzbGljZTpmdW5jdGlvbigpe3JldHVybiB0aGlzLnB1c2hTdGFjayhzLmFwcGx
5KHRoaXMsYXJndW1lbnRzKSl9LGZpcnN0OmZ1bmN0aW9uKCl7cmV0dXJuIHRoaXMuZXEoMCl9LGxhc3Q6ZnVuY3Rpb24oKXtyZXR1cm4gdGhpcy5lcSgtMSl9LGV2ZW46ZnVuY3Rpb24oKXtyZXR1cm4gdGhpcy5wdXNoU3RhY2soUy5ncmVwKHRoaXMsZnVuY3Rpb24oZSx0KXtyZXR1cm4odCsxKSUyfSkpfSxvZGQ6ZnVuY3Rpb24oKXtyZXR1cm4gdGhpcy5wdXNoU3RhY2soUy5ncmVwKHRoaXMsZnVuY3Rpb24oZSx0KXtyZXR1cm4gdCUyfSkpfSxlcTpmdW5jdGlvbihlKXt2YXIgdD10aGlzLmxlbmd0aCxuPStlKyhlPDA/dDowKTtyZXR1cm4gdGhpcy5wdXNoU3RhY2soMDw9biYmbjx0P1t0aGlzW25dXTpbXSl9LGVuZDpmdW5jdGlvbigpe3JldHVybiB0aGlzLnByZXZPYmplY3R8fHRoaXMuY29uc3RydWN0b3IoKX0scHVzaDp1LHNvcnQ6dC5zb3J0L
HNwbGljZTp0LnNwbGljZX0sUy5leHRlbmQ9Uy5mbi5leHRlbmQ9ZnVuY3Rpb24oKXt2YXIgZSx0LG4scixpLG8sYT1hcmd1bWVudHNbMF18fHt9LHM9MSx1PWFyZ3VtZW50cy5sZW5ndGgsbD0hMTtmb3IoImJvb2xlYW4iPT10eXBlb2YgYSYmKGw9YSxhPWFyZ3VtZW50c1tzXXx8e30scysrKSwib2JqZWN0Ij09dHlwZW9mIGF8fG0oYSl8fChhPXt9KSxzPT09dSYmKGE9dGhpcyxzLS0pO3M8dTtzKyspaWYobnVsbCE9KGU9YXJndW1lbnRzW3NdKSlmb3IodCBpbiBlKXI9ZVt0XSwiX19wcm90b19fIiE9PXQmJmEhPT1yJiYobCYmciYmKFMuaXNQbGFpbk9iamVjdChyKXx8KGk9QXJyYXkuaXNBcnJheShyKSkpPyhuPWFbdF0sbz1pJiYhQXJyYXkuaXNBcnJheShuKT9bXTppfHxTLmlzUGxhaW5PYmplY3Qobik/bjp7fSxpPSExLGFbdF09Uy5leHRlbmQ
obCxvLHIpKTp2b2lkIDAhPT1yJiYoYVt0XT1yKSk7cmV0dXJuIGF9LFMuZXh0ZW5kKHtleHBhbmRvOiJqUXVlcnkiKyhmK01hdGgucmFuZG9tKCkpLnJlcGxhY2UoL1xEL2csIiIpLGlzUmVhZHk6ITAsZXJyb3I6ZnVuY3Rpb24oZSl7dGhyb3cgbmV3IEVycm9yKGUpfSxub29wOmZ1bmN0aW9uKCl7fSxpc1BsYWluT2JqZWN0OmZ1bmN0aW9uKGUpe3ZhciB0LG47cmV0dXJuISghZXx8IltvYmplY3QgT2JqZWN0XSIhPT1vLmNhbGwoZSkpJiYoISh0PXIoZSkpfHwiZnVuY3Rpb24iPT10eXBlb2Yobj12LmNhbGwodCwiY29uc3RydWN0b3IiKSYmdC5jb25zdHJ1Y3RvcikmJmEuY2FsbChuKT09PWwpfSxpc0VtcHR5T2JqZWN0OmZ1bmN0aW9uKGUpe3ZhciB0O2Zvcih0IGluIGUpcmV0dXJuITE7cmV0dXJuITB9LGdsb2JhbEV2YWw6ZnVuY3Rpb24oZSx0L
G4pe2IoZSx7bm9uY2U6dCYmdC5ub25jZX0sbil9LGVhY2g6ZnVuY3Rpb24oZSx0KXt2YXIgbixyPTA7aWYocChlKSl7Zm9yKG49ZS5sZW5ndGg7cjxuO3IrKylpZighMT09PXQuY2FsbChlW3JdLHIsZVtyXSkpYnJlYWt9ZWxzZSBmb3IociBpbiBlKWlmKCExPT09dC5jYWxsKGVbcl0scixlW3JdKSlicmVhaztyZXR1cm4gZX0sbWFrZUFycmF5OmZ1bmN0aW9uKGUsdCl7dmFyIG49dHx8W107cmV0dXJuIG51bGwhPWUmJihwKE9iamVjdChlKSk/Uy5tZXJnZShuLCJzdHJpbmciPT10eXBlb2YgZT9bZV06ZSk6dS5jYWxsKG4sZSkpLG59LGluQXJyYXk6ZnVuY3Rpb24oZSx0LG4pe3JldHVybiBudWxsPT10Py0xOmkuY2FsbCh0LGUsbil9LG1lcmdlOmZ1bmN0aW9uKGUsdCl7Zm9yKHZhciBuPSt0Lmxlbmd0aCxyPTAsaT1lLmxlbmd0aDtyPG47cisrKWV
baSsrXT10W3JdO3JldHVybiBlLmxlbmd0aD1pLGV9LGdyZXA6ZnVuY3Rpb24oZSx0LG4pe2Zvcih2YXIgcj1bXSxpPTAsbz1lLmxlbmd0aCxhPSFuO2k8bztpKyspIXQoZVtpXSxpKSE9PWEmJnIucHVzaChlW2ldKTtyZXR1cm4gcn0sbWFwOmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG89MCxhPVtdO2lmKHAoZSkpZm9yKHI9ZS5sZW5ndGg7bzxyO28rKyludWxsIT0oaT10KGVbb10sbyxuKSkmJmEucHVzaChpKTtlbHNlIGZvcihvIGluIGUpbnVsbCE9KGk9dChlW29dLG8sbikpJiZhLnB1c2goaSk7cmV0dXJuIGcoYSl9LGd1aWQ6MSxzdXBwb3J0Onl9KSwiZnVuY3Rpb24iPT10eXBlb2YgU3ltYm9sJiYoUy5mbltTeW1ib2wuaXRlcmF0b3JdPXRbU3ltYm9sLml0ZXJhdG9yXSksUy5lYWNoKCJCb29sZWFuIE51bWJlciBTdHJpbmcgRnVuY3Rpb24gQ
XJyYXkgRGF0ZSBSZWdFeHAgT2JqZWN0IEVycm9yIFN5bWJvbCIuc3BsaXQoIiAiKSxmdW5jdGlvbihlLHQpe25bIltvYmplY3QgIit0KyJdIl09dC50b0xvd2VyQ2FzZSgpfSk7dmFyIGQ9ZnVuY3Rpb24obil7dmFyIGUsZCxiLG8saSxoLGYsZyx3LHUsbCxULEMsYSxFLHYscyxjLHksUz0ic2l6emxlIisxKm5ldyBEYXRlLHA9bi5kb2N1bWVudCxrPTAscj0wLG09dWUoKSx4PXVlKCksQT11ZSgpLE49dWUoKSxEPWZ1bmN0aW9uKGUsdCl7cmV0dXJuIGU9PT10JiYobD0hMCksMH0saj17fS5oYXNPd25Qcm9wZXJ0eSx0PVtdLHE9dC5wb3AsTD10LnB1c2gsSD10LnB1c2gsTz10LnNsaWNlLFA9ZnVuY3Rpb24oZSx0KXtmb3IodmFyIG49MCxyPWUubGVuZ3RoO248cjtuKyspaWYoZVtuXT09PXQpcmV0dXJuIG47cmV0dXJuLTF9LFI9ImNoZWNrZWR8c2V
sZWN0ZWR8YXN5bmN8YXV0b2ZvY3VzfGF1dG9wbGF5fGNvbnRyb2xzfGRlZmVyfGRpc2FibGVkfGhpZGRlbnxpc21hcHxsb29wfG11bHRpcGxlfG9wZW58cmVhZG9ubHl8cmVxdWlyZWR8c2NvcGVkIixNPSJbXFx4MjBcXHRcXHJcXG5cXGZdIixJPSIoPzpcXFxcW1xcZGEtZkEtRl17MSw2fSIrTSsiP3xcXFxcW15cXHJcXG5cXGZdfFtcXHctXXxbXlwwLVxceDdmXSkrIixXPSJcXFsiK00rIiooIitJKyIpKD86IitNKyIqKFsqXiR8IX5dPz0pIitNKyIqKD86JygoPzpcXFxcLnxbXlxcXFwnXSkqKSd8XCIoKD86XFxcXC58W15cXFxcXCJdKSopXCJ8KCIrSSsiKSl8KSIrTSsiKlxcXSIsRj0iOigiK0krIikoPzpcXCgoKCcoKD86XFxcXC58W15cXFxcJ10pKiknfFwiKCg/OlxcXFwufFteXFxcXFwiXSkqKVwiKXwoKD86XFxcXC58W15cXFxcKClbXFxdX
XwiK1crIikqKXwuKilcXCl8KSIsQj1uZXcgUmVnRXhwKE0rIisiLCJnIiksJD1uZXcgUmVnRXhwKCJeIitNKyIrfCgoPzpefFteXFxcXF0pKD86XFxcXC4pKikiK00rIiskIiwiZyIpLF89bmV3IFJlZ0V4cCgiXiIrTSsiKiwiK00rIioiKSx6PW5ldyBSZWdFeHAoIl4iK00rIiooWz4rfl18IitNKyIpIitNKyIqIiksVT1uZXcgUmVnRXhwKE0rInw+IiksWD1uZXcgUmVnRXhwKEYpLFY9bmV3IFJlZ0V4cCgiXiIrSSsiJCIpLEc9e0lEOm5ldyBSZWdFeHAoIl4jKCIrSSsiKSIpLENMQVNTOm5ldyBSZWdFeHAoIl5cXC4oIitJKyIpIiksVEFHOm5ldyBSZWdFeHAoIl4oIitJKyJ8WypdKSIpLEFUVFI6bmV3IFJlZ0V4cCgiXiIrVyksUFNFVURPOm5ldyBSZWdFeHAoIl4iK0YpLENISUxEOm5ldyBSZWdFeHAoIl46KG9ubHl8Zmlyc3R8bGFzdHxudGh8bnR
oLWxhc3QpLShjaGlsZHxvZi10eXBlKSg/OlxcKCIrTSsiKihldmVufG9kZHwoKFsrLV18KShcXGQqKW58KSIrTSsiKig/OihbKy1dfCkiK00rIiooXFxkKyl8KSkiK00rIipcXCl8KSIsImkiKSxib29sOm5ldyBSZWdFeHAoIl4oPzoiK1IrIikkIiwiaSIpLG5lZWRzQ29udGV4dDpuZXcgUmVnRXhwKCJeIitNKyIqWz4rfl18OihldmVufG9kZHxlcXxndHxsdHxudGh8Zmlyc3R8bGFzdCkoPzpcXCgiK00rIiooKD86LVxcZCk/XFxkKikiK00rIipcXCl8KSg/PVteLV18JCkiLCJpIil9LFk9L0hUTUwkL2ksUT0vXig/OmlucHV0fHNlbGVjdHx0ZXh0YXJlYXxidXR0b24pJC9pLEo9L15oXGQkL2ksSz0vXltee10rXHtccypcW25hdGl2ZSBcdy8sWj0vXig/OiMoW1x3LV0rKXwoXHcrKXxcLihbXHctXSspKSQvLGVlPS9bK35dLyx0ZT1uZXcgUmVnRXhwK
CJcXFxcW1xcZGEtZkEtRl17MSw2fSIrTSsiP3xcXFxcKFteXFxyXFxuXFxmXSkiLCJnIiksbmU9ZnVuY3Rpb24oZSx0KXt2YXIgbj0iMHgiK2Uuc2xpY2UoMSktNjU1MzY7cmV0dXJuIHR8fChuPDA/U3RyaW5nLmZyb21DaGFyQ29kZShuKzY1NTM2KTpTdHJpbmcuZnJvbUNoYXJDb2RlKG4+PjEwfDU1Mjk2LDEwMjMmbnw1NjMyMCkpfSxyZT0vKFtcMC1ceDFmXHg3Zl18Xi0/XGQpfF4tJHxbXlwwLVx4MWZceDdmLVx1RkZGRlx3LV0vZyxpZT1mdW5jdGlvbihlLHQpe3JldHVybiB0PyJcMCI9PT1lPyJcdWZmZmQiOmUuc2xpY2UoMCwtMSkrIlxcIitlLmNoYXJDb2RlQXQoZS5sZW5ndGgtMSkudG9TdHJpbmcoMTYpKyIgIjoiXFwiK2V9LG9lPWZ1bmN0aW9uKCl7VCgpfSxhZT1iZShmdW5jdGlvbihlKXtyZXR1cm4hMD09PWUuZGlzYWJsZWQmJiJmaWV
sZHNldCI9PT1lLm5vZGVOYW1lLnRvTG93ZXJDYXNlKCl9LHtkaXI6InBhcmVudE5vZGUiLG5leHQ6ImxlZ2VuZCJ9KTt0cnl7SC5hcHBseSh0PU8uY2FsbChwLmNoaWxkTm9kZXMpLHAuY2hpbGROb2RlcyksdFtwLmNoaWxkTm9kZXMubGVuZ3RoXS5ub2RlVHlwZX1jYXRjaChlKXtIPXthcHBseTp0Lmxlbmd0aD9mdW5jdGlvbihlLHQpe0wuYXBwbHkoZSxPLmNhbGwodCkpfTpmdW5jdGlvbihlLHQpe3ZhciBuPWUubGVuZ3RoLHI9MDt3aGlsZShlW24rK109dFtyKytdKTtlLmxlbmd0aD1uLTF9fX1mdW5jdGlvbiBzZSh0LGUsbixyKXt2YXIgaSxvLGEscyx1LGwsYyxmPWUmJmUub3duZXJEb2N1bWVudCxwPWU/ZS5ub2RlVHlwZTo5O2lmKG49bnx8W10sInN0cmluZyIhPXR5cGVvZiB0fHwhdHx8MSE9PXAmJjkhPT1wJiYxMSE9PXApcmV0dXJuIG47a
WYoIXImJihUKGUpLGU9ZXx8QyxFKSl7aWYoMTEhPT1wJiYodT1aLmV4ZWModCkpKWlmKGk9dVsxXSl7aWYoOT09PXApe2lmKCEoYT1lLmdldEVsZW1lbnRCeUlkKGkpKSlyZXR1cm4gbjtpZihhLmlkPT09aSlyZXR1cm4gbi5wdXNoKGEpLG59ZWxzZSBpZihmJiYoYT1mLmdldEVsZW1lbnRCeUlkKGkpKSYmeShlLGEpJiZhLmlkPT09aSlyZXR1cm4gbi5wdXNoKGEpLG59ZWxzZXtpZih1WzJdKXJldHVybiBILmFwcGx5KG4sZS5nZXRFbGVtZW50c0J5VGFnTmFtZSh0KSksbjtpZigoaT11WzNdKSYmZC5nZXRFbGVtZW50c0J5Q2xhc3NOYW1lJiZlLmdldEVsZW1lbnRzQnlDbGFzc05hbWUpcmV0dXJuIEguYXBwbHkobixlLmdldEVsZW1lbnRzQnlDbGFzc05hbWUoaSkpLG59aWYoZC5xc2EmJiFOW3QrIiAiXSYmKCF2fHwhdi50ZXN0KHQpKSYmKDEhPT1
wfHwib2JqZWN0IiE9PWUubm9kZU5hbWUudG9Mb3dlckNhc2UoKSkpe2lmKGM9dCxmPWUsMT09PXAmJihVLnRlc3QodCl8fHoudGVzdCh0KSkpeyhmPWVlLnRlc3QodCkmJnllKGUucGFyZW50Tm9kZSl8fGUpPT09ZSYmZC5zY29wZXx8KChzPWUuZ2V0QXR0cmlidXRlKCJpZCIpKT9zPXMucmVwbGFjZShyZSxpZSk6ZS5zZXRBdHRyaWJ1dGUoImlkIixzPVMpKSxvPShsPWgodCkpLmxlbmd0aDt3aGlsZShvLS0pbFtvXT0ocz8iIyIrczoiOnNjb3BlIikrIiAiK3hlKGxbb10pO2M9bC5qb2luKCIsIil9dHJ5e3JldHVybiBILmFwcGx5KG4sZi5xdWVyeVNlbGVjdG9yQWxsKGMpKSxufWNhdGNoKGUpe04odCwhMCl9ZmluYWxseXtzPT09UyYmZS5yZW1vdmVBdHRyaWJ1dGUoImlkIil9fX1yZXR1cm4gZyh0LnJlcGxhY2UoJCwiJDEiKSxlLG4scil9ZnVuY
3Rpb24gdWUoKXt2YXIgcj1bXTtyZXR1cm4gZnVuY3Rpb24gZSh0LG4pe3JldHVybiByLnB1c2godCsiICIpPmIuY2FjaGVMZW5ndGgmJmRlbGV0ZSBlW3Iuc2hpZnQoKV0sZVt0KyIgIl09bn19ZnVuY3Rpb24gbGUoZSl7cmV0dXJuIGVbU109ITAsZX1mdW5jdGlvbiBjZShlKXt2YXIgdD1DLmNyZWF0ZUVsZW1lbnQoImZpZWxkc2V0Iik7dHJ5e3JldHVybiEhZSh0KX1jYXRjaChlKXtyZXR1cm4hMX1maW5hbGx5e3QucGFyZW50Tm9kZSYmdC5wYXJlbnROb2RlLnJlbW92ZUNoaWxkKHQpLHQ9bnVsbH19ZnVuY3Rpb24gZmUoZSx0KXt2YXIgbj1lLnNwbGl0KCJ8Iikscj1uLmxlbmd0aDt3aGlsZShyLS0pYi5hdHRySGFuZGxlW25bcl1dPXR9ZnVuY3Rpb24gcGUoZSx0KXt2YXIgbj10JiZlLHI9biYmMT09PWUubm9kZVR5cGUmJjE9PT10Lm5vZGVUeXB
lJiZlLnNvdXJjZUluZGV4LXQuc291cmNlSW5kZXg7aWYocilyZXR1cm4gcjtpZihuKXdoaWxlKG49bi5uZXh0U2libGluZylpZihuPT09dClyZXR1cm4tMTtyZXR1cm4gZT8xOi0xfWZ1bmN0aW9uIGRlKHQpe3JldHVybiBmdW5jdGlvbihlKXtyZXR1cm4iaW5wdXQiPT09ZS5ub2RlTmFtZS50b0xvd2VyQ2FzZSgpJiZlLnR5cGU9PT10fX1mdW5jdGlvbiBoZShuKXtyZXR1cm4gZnVuY3Rpb24oZSl7dmFyIHQ9ZS5ub2RlTmFtZS50b0xvd2VyQ2FzZSgpO3JldHVybigiaW5wdXQiPT09dHx8ImJ1dHRvbiI9PT10KSYmZS50eXBlPT09bn19ZnVuY3Rpb24gZ2UodCl7cmV0dXJuIGZ1bmN0aW9uKGUpe3JldHVybiJmb3JtImluIGU/ZS5wYXJlbnROb2RlJiYhMT09PWUuZGlzYWJsZWQ/ImxhYmVsImluIGU/ImxhYmVsImluIGUucGFyZW50Tm9kZT9lLnBhc
mVudE5vZGUuZGlzYWJsZWQ9PT10OmUuZGlzYWJsZWQ9PT10OmUuaXNEaXNhYmxlZD09PXR8fGUuaXNEaXNhYmxlZCE9PSF0JiZhZShlKT09PXQ6ZS5kaXNhYmxlZD09PXQ6ImxhYmVsImluIGUmJmUuZGlzYWJsZWQ9PT10fX1mdW5jdGlvbiB2ZShhKXtyZXR1cm4gbGUoZnVuY3Rpb24obyl7cmV0dXJuIG89K28sbGUoZnVuY3Rpb24oZSx0KXt2YXIgbixyPWEoW10sZS5sZW5ndGgsbyksaT1yLmxlbmd0aDt3aGlsZShpLS0pZVtuPXJbaV1dJiYoZVtuXT0hKHRbbl09ZVtuXSkpfSl9KX1mdW5jdGlvbiB5ZShlKXtyZXR1cm4gZSYmInVuZGVmaW5lZCIhPXR5cGVvZiBlLmdldEVsZW1lbnRzQnlUYWdOYW1lJiZlfWZvcihlIGluIGQ9c2Uuc3VwcG9ydD17fSxpPXNlLmlzWE1MPWZ1bmN0aW9uKGUpe3ZhciB0PWUubmFtZXNwYWNlVVJJLG49KGUub3duZXJ
Eb2N1bWVudHx8ZSkuZG9jdW1lbnRFbGVtZW50O3JldHVybiFZLnRlc3QodHx8biYmbi5ub2RlTmFtZXx8IkhUTUwiKX0sVD1zZS5zZXREb2N1bWVudD1mdW5jdGlvbihlKXt2YXIgdCxuLHI9ZT9lLm93bmVyRG9jdW1lbnR8fGU6cDtyZXR1cm4gciE9QyYmOT09PXIubm9kZVR5cGUmJnIuZG9jdW1lbnRFbGVtZW50JiYoYT0oQz1yKS5kb2N1bWVudEVsZW1lbnQsRT0haShDKSxwIT1DJiYobj1DLmRlZmF1bHRWaWV3KSYmbi50b3AhPT1uJiYobi5hZGRFdmVudExpc3RlbmVyP24uYWRkRXZlbnRMaXN0ZW5lcigidW5sb2FkIixvZSwhMSk6bi5hdHRhY2hFdmVudCYmbi5hdHRhY2hFdmVudCgib251bmxvYWQiLG9lKSksZC5zY29wZT1jZShmdW5jdGlvbihlKXtyZXR1cm4gYS5hcHBlbmRDaGlsZChlKS5hcHBlbmRDaGlsZChDLmNyZWF0ZUVsZW1lbnQoI
mRpdiIpKSwidW5kZWZpbmVkIiE9dHlwZW9mIGUucXVlcnlTZWxlY3RvckFsbCYmIWUucXVlcnlTZWxlY3RvckFsbCgiOnNjb3BlIGZpZWxkc2V0IGRpdiIpLmxlbmd0aH0pLGQuYXR0cmlidXRlcz1jZShmdW5jdGlvbihlKXtyZXR1cm4gZS5jbGFzc05hbWU9ImkiLCFlLmdldEF0dHJpYnV0ZSgiY2xhc3NOYW1lIil9KSxkLmdldEVsZW1lbnRzQnlUYWdOYW1lPWNlKGZ1bmN0aW9uKGUpe3JldHVybiBlLmFwcGVuZENoaWxkKEMuY3JlYXRlQ29tbWVudCgiIikpLCFlLmdldEVsZW1lbnRzQnlUYWdOYW1lKCIqIikubGVuZ3RofSksZC5nZXRFbGVtZW50c0J5Q2xhc3NOYW1lPUsudGVzdChDLmdldEVsZW1lbnRzQnlDbGFzc05hbWUpLGQuZ2V0QnlJZD1jZShmdW5jdGlvbihlKXtyZXR1cm4gYS5hcHBlbmRDaGlsZChlKS5pZD1TLCFDLmdldEVsZW1lbnR
zQnlOYW1lfHwhQy5nZXRFbGVtZW50c0J5TmFtZShTKS5sZW5ndGh9KSxkLmdldEJ5SWQ/KGIuZmlsdGVyLklEPWZ1bmN0aW9uKGUpe3ZhciB0PWUucmVwbGFjZSh0ZSxuZSk7cmV0dXJuIGZ1bmN0aW9uKGUpe3JldHVybiBlLmdldEF0dHJpYnV0ZSgiaWQiKT09PXR9fSxiLmZpbmQuSUQ9ZnVuY3Rpb24oZSx0KXtpZigidW5kZWZpbmVkIiE9dHlwZW9mIHQuZ2V0RWxlbWVudEJ5SWQmJkUpe3ZhciBuPXQuZ2V0RWxlbWVudEJ5SWQoZSk7cmV0dXJuIG4/W25dOltdfX0pOihiLmZpbHRlci5JRD1mdW5jdGlvbihlKXt2YXIgbj1lLnJlcGxhY2UodGUsbmUpO3JldHVybiBmdW5jdGlvbihlKXt2YXIgdD0idW5kZWZpbmVkIiE9dHlwZW9mIGUuZ2V0QXR0cmlidXRlTm9kZSYmZS5nZXRBdHRyaWJ1dGVOb2RlKCJpZCIpO3JldHVybiB0JiZ0LnZhbHVlPT09b
n19LGIuZmluZC5JRD1mdW5jdGlvbihlLHQpe2lmKCJ1bmRlZmluZWQiIT10eXBlb2YgdC5nZXRFbGVtZW50QnlJZCYmRSl7dmFyIG4scixpLG89dC5nZXRFbGVtZW50QnlJZChlKTtpZihvKXtpZigobj1vLmdldEF0dHJpYnV0ZU5vZGUoImlkIikpJiZuLnZhbHVlPT09ZSlyZXR1cm5bb107aT10LmdldEVsZW1lbnRzQnlOYW1lKGUpLHI9MDt3aGlsZShvPWlbcisrXSlpZigobj1vLmdldEF0dHJpYnV0ZU5vZGUoImlkIikpJiZuLnZhbHVlPT09ZSlyZXR1cm5bb119cmV0dXJuW119fSksYi5maW5kLlRBRz1kLmdldEVsZW1lbnRzQnlUYWdOYW1lP2Z1bmN0aW9uKGUsdCl7cmV0dXJuInVuZGVmaW5lZCIhPXR5cGVvZiB0LmdldEVsZW1lbnRzQnlUYWdOYW1lP3QuZ2V0RWxlbWVudHNCeVRhZ05hbWUoZSk6ZC5xc2E/dC5xdWVyeVNlbGVjdG9yQWxsKGU
pOnZvaWQgMH06ZnVuY3Rpb24oZSx0KXt2YXIgbixyPVtdLGk9MCxvPXQuZ2V0RWxlbWVudHNCeVRhZ05hbWUoZSk7aWYoIioiPT09ZSl7d2hpbGUobj1vW2krK10pMT09PW4ubm9kZVR5cGUmJnIucHVzaChuKTtyZXR1cm4gcn1yZXR1cm4gb30sYi5maW5kLkNMQVNTPWQuZ2V0RWxlbWVudHNCeUNsYXNzTmFtZSYmZnVuY3Rpb24oZSx0KXtpZigidW5kZWZpbmVkIiE9dHlwZW9mIHQuZ2V0RWxlbWVudHNCeUNsYXNzTmFtZSYmRSlyZXR1cm4gdC5nZXRFbGVtZW50c0J5Q2xhc3NOYW1lKGUpfSxzPVtdLHY9W10sKGQucXNhPUsudGVzdChDLnF1ZXJ5U2VsZWN0b3JBbGwpKSYmKGNlKGZ1bmN0aW9uKGUpe3ZhciB0O2EuYXBwZW5kQ2hpbGQoZSkuaW5uZXJIVE1MPSI8YSBpZD0nIitTKyInPjwvYT48c2VsZWN0IGlkPSciK1MrIi1cclxcJyBtc2FsbG93Y
2FwdHVyZT0nJz48b3B0aW9uIHNlbGVjdGVkPScnPjwvb3B0aW9uPjwvc2VsZWN0PiIsZS5xdWVyeVNlbGVjdG9yQWxsKCJbbXNhbGxvd2NhcHR1cmVePScnXSIpLmxlbmd0aCYmdi5wdXNoKCJbKl4kXT0iK00rIiooPzonJ3xcIlwiKSIpLGUucXVlcnlTZWxlY3RvckFsbCgiW3NlbGVjdGVkXSIpLmxlbmd0aHx8di5wdXNoKCJcXFsiK00rIiooPzp2YWx1ZXwiK1IrIikiKSxlLnF1ZXJ5U2VsZWN0b3JBbGwoIltpZH49IitTKyItXSIpLmxlbmd0aHx8di5wdXNoKCJ+PSIpLCh0PUMuY3JlYXRlRWxlbWVudCgiaW5wdXQiKSkuc2V0QXR0cmlidXRlKCJuYW1lIiwiIiksZS5hcHBlbmRDaGlsZCh0KSxlLnF1ZXJ5U2VsZWN0b3JBbGwoIltuYW1lPScnXSIpLmxlbmd0aHx8di5wdXNoKCJcXFsiK00rIipuYW1lIitNKyIqPSIrTSsiKig/OicnfFwiXCIpIik
sZS5xdWVyeVNlbGVjdG9yQWxsKCI6Y2hlY2tlZCIpLmxlbmd0aHx8di5wdXNoKCI6Y2hlY2tlZCIpLGUucXVlcnlTZWxlY3RvckFsbCgiYSMiK1MrIisqIikubGVuZ3RofHx2LnB1c2goIi4jLitbK35dIiksZS5xdWVyeVNlbGVjdG9yQWxsKCJcXFxmIiksdi5wdXNoKCJbXFxyXFxuXFxmXSIpfSksY2UoZnVuY3Rpb24oZSl7ZS5pbm5lckhUTUw9IjxhIGhyZWY9JycgZGlzYWJsZWQ9J2Rpc2FibGVkJz48L2E+PHNlbGVjdCBkaXNhYmxlZD0nZGlzYWJsZWQnPjxvcHRpb24vPjwvc2VsZWN0PiI7dmFyIHQ9Qy5jcmVhdGVFbGVtZW50KCJpbnB1dCIpO3Quc2V0QXR0cmlidXRlKCJ0eXBlIiwiaGlkZGVuIiksZS5hcHBlbmRDaGlsZCh0KS5zZXRBdHRyaWJ1dGUoIm5hbWUiLCJEIiksZS5xdWVyeVNlbGVjdG9yQWxsKCJbbmFtZT1kXSIpLmxlbmd0aCYmd
i5wdXNoKCJuYW1lIitNKyIqWypeJHwhfl0/PSIpLDIhPT1lLnF1ZXJ5U2VsZWN0b3JBbGwoIjplbmFibGVkIikubGVuZ3RoJiZ2LnB1c2goIjplbmFibGVkIiwiOmRpc2FibGVkIiksYS5hcHBlbmRDaGlsZChlKS5kaXNhYmxlZD0hMCwyIT09ZS5xdWVyeVNlbGVjdG9yQWxsKCI6ZGlzYWJsZWQiKS5sZW5ndGgmJnYucHVzaCgiOmVuYWJsZWQiLCI6ZGlzYWJsZWQiKSxlLnF1ZXJ5U2VsZWN0b3JBbGwoIiosOngiKSx2LnB1c2goIiwuKjoiKX0pKSwoZC5tYXRjaGVzU2VsZWN0b3I9Sy50ZXN0KGM9YS5tYXRjaGVzfHxhLndlYmtpdE1hdGNoZXNTZWxlY3Rvcnx8YS5tb3pNYXRjaGVzU2VsZWN0b3J8fGEub01hdGNoZXNTZWxlY3Rvcnx8YS5tc01hdGNoZXNTZWxlY3RvcikpJiZjZShmdW5jdGlvbihlKXtkLmRpc2Nvbm5lY3RlZE1hdGNoPWMuY2FsbCh
lLCIqIiksYy5jYWxsKGUsIltzIT0nJ106eCIpLHMucHVzaCgiIT0iLEYpfSksdj12Lmxlbmd0aCYmbmV3IFJlZ0V4cCh2LmpvaW4oInwiKSkscz1zLmxlbmd0aCYmbmV3IFJlZ0V4cChzLmpvaW4oInwiKSksdD1LLnRlc3QoYS5jb21wYXJlRG9jdW1lbnRQb3NpdGlvbikseT10fHxLLnRlc3QoYS5jb250YWlucyk/ZnVuY3Rpb24oZSx0KXt2YXIgbj05PT09ZS5ub2RlVHlwZT9lLmRvY3VtZW50RWxlbWVudDplLHI9dCYmdC5wYXJlbnROb2RlO3JldHVybiBlPT09cnx8ISghcnx8MSE9PXIubm9kZVR5cGV8fCEobi5jb250YWlucz9uLmNvbnRhaW5zKHIpOmUuY29tcGFyZURvY3VtZW50UG9zaXRpb24mJjE2JmUuY29tcGFyZURvY3VtZW50UG9zaXRpb24ocikpKX06ZnVuY3Rpb24oZSx0KXtpZih0KXdoaWxlKHQ9dC5wYXJlbnROb2RlKWlmKHQ9PT1lK
XJldHVybiEwO3JldHVybiExfSxEPXQ/ZnVuY3Rpb24oZSx0KXtpZihlPT09dClyZXR1cm4gbD0hMCwwO3ZhciBuPSFlLmNvbXBhcmVEb2N1bWVudFBvc2l0aW9uLSF0LmNvbXBhcmVEb2N1bWVudFBvc2l0aW9uO3JldHVybiBufHwoMSYobj0oZS5vd25lckRvY3VtZW50fHxlKT09KHQub3duZXJEb2N1bWVudHx8dCk/ZS5jb21wYXJlRG9jdW1lbnRQb3NpdGlvbih0KToxKXx8IWQuc29ydERldGFjaGVkJiZ0LmNvbXBhcmVEb2N1bWVudFBvc2l0aW9uKGUpPT09bj9lPT1DfHxlLm93bmVyRG9jdW1lbnQ9PXAmJnkocCxlKT8tMTp0PT1DfHx0Lm93bmVyRG9jdW1lbnQ9PXAmJnkocCx0KT8xOnU/UCh1LGUpLVAodSx0KTowOjQmbj8tMToxKX06ZnVuY3Rpb24oZSx0KXtpZihlPT09dClyZXR1cm4gbD0hMCwwO3ZhciBuLHI9MCxpPWUucGFyZW50Tm9kZSx
vPXQucGFyZW50Tm9kZSxhPVtlXSxzPVt0XTtpZighaXx8IW8pcmV0dXJuIGU9PUM/LTE6dD09Qz8xOmk/LTE6bz8xOnU/UCh1LGUpLVAodSx0KTowO2lmKGk9PT1vKXJldHVybiBwZShlLHQpO249ZTt3aGlsZShuPW4ucGFyZW50Tm9kZSlhLnVuc2hpZnQobik7bj10O3doaWxlKG49bi5wYXJlbnROb2RlKXMudW5zaGlmdChuKTt3aGlsZShhW3JdPT09c1tyXSlyKys7cmV0dXJuIHI/cGUoYVtyXSxzW3JdKTphW3JdPT1wPy0xOnNbcl09PXA/MTowfSksQ30sc2UubWF0Y2hlcz1mdW5jdGlvbihlLHQpe3JldHVybiBzZShlLG51bGwsbnVsbCx0KX0sc2UubWF0Y2hlc1NlbGVjdG9yPWZ1bmN0aW9uKGUsdCl7aWYoVChlKSxkLm1hdGNoZXNTZWxlY3RvciYmRSYmIU5bdCsiICJdJiYoIXN8fCFzLnRlc3QodCkpJiYoIXZ8fCF2LnRlc3QodCkpKXRyeXt2Y
XIgbj1jLmNhbGwoZSx0KTtpZihufHxkLmRpc2Nvbm5lY3RlZE1hdGNofHxlLmRvY3VtZW50JiYxMSE9PWUuZG9jdW1lbnQubm9kZVR5cGUpcmV0dXJuIG59Y2F0Y2goZSl7Tih0LCEwKX1yZXR1cm4gMDxzZSh0LEMsbnVsbCxbZV0pLmxlbmd0aH0sc2UuY29udGFpbnM9ZnVuY3Rpb24oZSx0KXtyZXR1cm4oZS5vd25lckRvY3VtZW50fHxlKSE9QyYmVChlKSx5KGUsdCl9LHNlLmF0dHI9ZnVuY3Rpb24oZSx0KXsoZS5vd25lckRvY3VtZW50fHxlKSE9QyYmVChlKTt2YXIgbj1iLmF0dHJIYW5kbGVbdC50b0xvd2VyQ2FzZSgpXSxyPW4mJmouY2FsbChiLmF0dHJIYW5kbGUsdC50b0xvd2VyQ2FzZSgpKT9uKGUsdCwhRSk6dm9pZCAwO3JldHVybiB2b2lkIDAhPT1yP3I6ZC5hdHRyaWJ1dGVzfHwhRT9lLmdldEF0dHJpYnV0ZSh0KToocj1lLmdldEF0dHJ
pYnV0ZU5vZGUodCkpJiZyLnNwZWNpZmllZD9yLnZhbHVlOm51bGx9LHNlLmVzY2FwZT1mdW5jdGlvbihlKXtyZXR1cm4oZSsiIikucmVwbGFjZShyZSxpZSl9LHNlLmVycm9yPWZ1bmN0aW9uKGUpe3Rocm93IG5ldyBFcnJvcigiU3ludGF4IGVycm9yLCB1bnJlY29nbml6ZWQgZXhwcmVzc2lvbjogIitlKX0sc2UudW5pcXVlU29ydD1mdW5jdGlvbihlKXt2YXIgdCxuPVtdLHI9MCxpPTA7aWYobD0hZC5kZXRlY3REdXBsaWNhdGVzLHU9IWQuc29ydFN0YWJsZSYmZS5zbGljZSgwKSxlLnNvcnQoRCksbCl7d2hpbGUodD1lW2krK10pdD09PWVbaV0mJihyPW4ucHVzaChpKSk7d2hpbGUoci0tKWUuc3BsaWNlKG5bcl0sMSl9cmV0dXJuIHU9bnVsbCxlfSxvPXNlLmdldFRleHQ9ZnVuY3Rpb24oZSl7dmFyIHQsbj0iIixyPTAsaT1lLm5vZGVUeXBlO2lmK
Gkpe2lmKDE9PT1pfHw5PT09aXx8MTE9PT1pKXtpZigic3RyaW5nIj09dHlwZW9mIGUudGV4dENvbnRlbnQpcmV0dXJuIGUudGV4dENvbnRlbnQ7Zm9yKGU9ZS5maXJzdENoaWxkO2U7ZT1lLm5leHRTaWJsaW5nKW4rPW8oZSl9ZWxzZSBpZigzPT09aXx8ND09PWkpcmV0dXJuIGUubm9kZVZhbHVlfWVsc2Ugd2hpbGUodD1lW3IrK10pbis9byh0KTtyZXR1cm4gbn0sKGI9c2Uuc2VsZWN0b3JzPXtjYWNoZUxlbmd0aDo1MCxjcmVhdGVQc2V1ZG86bGUsbWF0Y2g6RyxhdHRySGFuZGxlOnt9LGZpbmQ6e30scmVsYXRpdmU6eyI+Ijp7ZGlyOiJwYXJlbnROb2RlIixmaXJzdDohMH0sIiAiOntkaXI6InBhcmVudE5vZGUifSwiKyI6e2RpcjoicHJldmlvdXNTaWJsaW5nIixmaXJzdDohMH0sIn4iOntkaXI6InByZXZpb3VzU2libGluZyJ9fSxwcmVGaWx0ZXI
6e0FUVFI6ZnVuY3Rpb24oZSl7cmV0dXJuIGVbMV09ZVsxXS5yZXBsYWNlKHRlLG5lKSxlWzNdPShlWzNdfHxlWzRdfHxlWzVdfHwiIikucmVwbGFjZSh0ZSxuZSksIn49Ij09PWVbMl0mJihlWzNdPSIgIitlWzNdKyIgIiksZS5zbGljZSgwLDQpfSxDSElMRDpmdW5jdGlvbihlKXtyZXR1cm4gZVsxXT1lWzFdLnRvTG93ZXJDYXNlKCksIm50aCI9PT1lWzFdLnNsaWNlKDAsMyk/KGVbM118fHNlLmVycm9yKGVbMF0pLGVbNF09KyhlWzRdP2VbNV0rKGVbNl18fDEpOjIqKCJldmVuIj09PWVbM118fCJvZGQiPT09ZVszXSkpLGVbNV09KyhlWzddK2VbOF18fCJvZGQiPT09ZVszXSkpOmVbM10mJnNlLmVycm9yKGVbMF0pLGV9LFBTRVVETzpmdW5jdGlvbihlKXt2YXIgdCxuPSFlWzZdJiZlWzJdO3JldHVybiBHLkNISUxELnRlc3QoZVswXSk/bnVsbDooZ
VszXT9lWzJdPWVbNF18fGVbNV18fCIiOm4mJlgudGVzdChuKSYmKHQ9aChuLCEwKSkmJih0PW4uaW5kZXhPZigiKSIsbi5sZW5ndGgtdCktbi5sZW5ndGgpJiYoZVswXT1lWzBdLnNsaWNlKDAsdCksZVsyXT1uLnNsaWNlKDAsdCkpLGUuc2xpY2UoMCwzKSl9fSxmaWx0ZXI6e1RBRzpmdW5jdGlvbihlKXt2YXIgdD1lLnJlcGxhY2UodGUsbmUpLnRvTG93ZXJDYXNlKCk7cmV0dXJuIioiPT09ZT9mdW5jdGlvbigpe3JldHVybiEwfTpmdW5jdGlvbihlKXtyZXR1cm4gZS5ub2RlTmFtZSYmZS5ub2RlTmFtZS50b0xvd2VyQ2FzZSgpPT09dH19LENMQVNTOmZ1bmN0aW9uKGUpe3ZhciB0PW1bZSsiICJdO3JldHVybiB0fHwodD1uZXcgUmVnRXhwKCIoXnwiK00rIikiK2UrIigiK00rInwkKSIpKSYmbShlLGZ1bmN0aW9uKGUpe3JldHVybiB0LnRlc3QoInN
0cmluZyI9PXR5cGVvZiBlLmNsYXNzTmFtZSYmZS5jbGFzc05hbWV8fCJ1bmRlZmluZWQiIT10eXBlb2YgZS5nZXRBdHRyaWJ1dGUmJmUuZ2V0QXR0cmlidXRlKCJjbGFzcyIpfHwiIil9KX0sQVRUUjpmdW5jdGlvbihuLHIsaSl7cmV0dXJuIGZ1bmN0aW9uKGUpe3ZhciB0PXNlLmF0dHIoZSxuKTtyZXR1cm4gbnVsbD09dD8iIT0iPT09cjohcnx8KHQrPSIiLCI9Ij09PXI/dD09PWk6IiE9Ij09PXI/dCE9PWk6Il49Ij09PXI/aSYmMD09PXQuaW5kZXhPZihpKToiKj0iPT09cj9pJiYtMTx0LmluZGV4T2YoaSk6IiQ9Ij09PXI/aSYmdC5zbGljZSgtaS5sZW5ndGgpPT09aToifj0iPT09cj8tMTwoIiAiK3QucmVwbGFjZShCLCIgIikrIiAiKS5pbmRleE9mKGkpOiJ8PSI9PT1yJiYodD09PWl8fHQuc2xpY2UoMCxpLmxlbmd0aCsxKT09PWkrIi0iKSl9f
SxDSElMRDpmdW5jdGlvbihoLGUsdCxnLHYpe3ZhciB5PSJudGgiIT09aC5zbGljZSgwLDMpLG09Imxhc3QiIT09aC5zbGljZSgtNCkseD0ib2YtdHlwZSI9PT1lO3JldHVybiAxPT09ZyYmMD09PXY/ZnVuY3Rpb24oZSl7cmV0dXJuISFlLnBhcmVudE5vZGV9OmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG8sYSxzLHUsbD15IT09bT8ibmV4dFNpYmxpbmciOiJwcmV2aW91c1NpYmxpbmciLGM9ZS5wYXJlbnROb2RlLGY9eCYmZS5ub2RlTmFtZS50b0xvd2VyQ2FzZSgpLHA9IW4mJiF4LGQ9ITE7aWYoYyl7aWYoeSl7d2hpbGUobCl7YT1lO3doaWxlKGE9YVtsXSlpZih4P2Eubm9kZU5hbWUudG9Mb3dlckNhc2UoKT09PWY6MT09PWEubm9kZVR5cGUpcmV0dXJuITE7dT1sPSJvbmx5Ij09PWgmJiF1JiYibmV4dFNpYmxpbmcifXJldHVybiEwfWlmKHU9W20
/Yy5maXJzdENoaWxkOmMubGFzdENoaWxkXSxtJiZwKXtkPShzPShyPShpPShvPShhPWMpW1NdfHwoYVtTXT17fSkpW2EudW5pcXVlSURdfHwob1thLnVuaXF1ZUlEXT17fSkpW2hdfHxbXSlbMF09PT1rJiZyWzFdKSYmclsyXSxhPXMmJmMuY2hpbGROb2Rlc1tzXTt3aGlsZShhPSsrcyYmYSYmYVtsXXx8KGQ9cz0wKXx8dS5wb3AoKSlpZigxPT09YS5ub2RlVHlwZSYmKytkJiZhPT09ZSl7aVtoXT1bayxzLGRdO2JyZWFrfX1lbHNlIGlmKHAmJihkPXM9KHI9KGk9KG89KGE9ZSlbU118fChhW1NdPXt9KSlbYS51bmlxdWVJRF18fChvW2EudW5pcXVlSURdPXt9KSlbaF18fFtdKVswXT09PWsmJnJbMV0pLCExPT09ZCl3aGlsZShhPSsrcyYmYSYmYVtsXXx8KGQ9cz0wKXx8dS5wb3AoKSlpZigoeD9hLm5vZGVOYW1lLnRvTG93ZXJDYXNlKCk9PT1mOjE9P
T1hLm5vZGVUeXBlKSYmKytkJiYocCYmKChpPShvPWFbU118fChhW1NdPXt9KSlbYS51bmlxdWVJRF18fChvW2EudW5pcXVlSURdPXt9KSlbaF09W2ssZF0pLGE9PT1lKSlicmVhaztyZXR1cm4oZC09dik9PT1nfHxkJWc9PTAmJjA8PWQvZ319fSxQU0VVRE86ZnVuY3Rpb24oZSxvKXt2YXIgdCxhPWIucHNldWRvc1tlXXx8Yi5zZXRGaWx0ZXJzW2UudG9Mb3dlckNhc2UoKV18fHNlLmVycm9yKCJ1bnN1cHBvcnRlZCBwc2V1ZG86ICIrZSk7cmV0dXJuIGFbU10/YShvKToxPGEubGVuZ3RoPyh0PVtlLGUsIiIsb10sYi5zZXRGaWx0ZXJzLmhhc093blByb3BlcnR5KGUudG9Mb3dlckNhc2UoKSk/bGUoZnVuY3Rpb24oZSx0KXt2YXIgbixyPWEoZSxvKSxpPXIubGVuZ3RoO3doaWxlKGktLSllW249UChlLHJbaV0pXT0hKHRbbl09cltpXSl9KTpmdW5jdGl
vbihlKXtyZXR1cm4gYShlLDAsdCl9KTphfX0scHNldWRvczp7bm90OmxlKGZ1bmN0aW9uKGUpe3ZhciByPVtdLGk9W10scz1mKGUucmVwbGFjZSgkLCIkMSIpKTtyZXR1cm4gc1tTXT9sZShmdW5jdGlvbihlLHQsbixyKXt2YXIgaSxvPXMoZSxudWxsLHIsW10pLGE9ZS5sZW5ndGg7d2hpbGUoYS0tKShpPW9bYV0pJiYoZVthXT0hKHRbYV09aSkpfSk6ZnVuY3Rpb24oZSx0LG4pe3JldHVybiByWzBdPWUscyhyLG51bGwsbixpKSxyWzBdPW51bGwsIWkucG9wKCl9fSksaGFzOmxlKGZ1bmN0aW9uKHQpe3JldHVybiBmdW5jdGlvbihlKXtyZXR1cm4gMDxzZSh0LGUpLmxlbmd0aH19KSxjb250YWluczpsZShmdW5jdGlvbih0KXtyZXR1cm4gdD10LnJlcGxhY2UodGUsbmUpLGZ1bmN0aW9uKGUpe3JldHVybi0xPChlLnRleHRDb250ZW50fHxvKGUpKS5pb
mRleE9mKHQpfX0pLGxhbmc6bGUoZnVuY3Rpb24obil7cmV0dXJuIFYudGVzdChufHwiIil8fHNlLmVycm9yKCJ1bnN1cHBvcnRlZCBsYW5nOiAiK24pLG49bi5yZXBsYWNlKHRlLG5lKS50b0xvd2VyQ2FzZSgpLGZ1bmN0aW9uKGUpe3ZhciB0O2Rve2lmKHQ9RT9lLmxhbmc6ZS5nZXRBdHRyaWJ1dGUoInhtbDpsYW5nIil8fGUuZ2V0QXR0cmlidXRlKCJsYW5nIikpcmV0dXJuKHQ9dC50b0xvd2VyQ2FzZSgpKT09PW58fDA9PT10LmluZGV4T2YobisiLSIpfXdoaWxlKChlPWUucGFyZW50Tm9kZSkmJjE9PT1lLm5vZGVUeXBlKTtyZXR1cm4hMX19KSx0YXJnZXQ6ZnVuY3Rpb24oZSl7dmFyIHQ9bi5sb2NhdGlvbiYmbi5sb2NhdGlvbi5oYXNoO3JldHVybiB0JiZ0LnNsaWNlKDEpPT09ZS5pZH0scm9vdDpmdW5jdGlvbihlKXtyZXR1cm4gZT09PWF9LGZ
vY3VzOmZ1bmN0aW9uKGUpe3JldHVybiBlPT09Qy5hY3RpdmVFbGVtZW50JiYoIUMuaGFzRm9jdXN8fEMuaGFzRm9jdXMoKSkmJiEhKGUudHlwZXx8ZS5ocmVmfHx+ZS50YWJJbmRleCl9LGVuYWJsZWQ6Z2UoITEpLGRpc2FibGVkOmdlKCEwKSxjaGVja2VkOmZ1bmN0aW9uKGUpe3ZhciB0PWUubm9kZU5hbWUudG9Mb3dlckNhc2UoKTtyZXR1cm4iaW5wdXQiPT09dCYmISFlLmNoZWNrZWR8fCJvcHRpb24iPT09dCYmISFlLnNlbGVjdGVkfSxzZWxlY3RlZDpmdW5jdGlvbihlKXtyZXR1cm4gZS5wYXJlbnROb2RlJiZlLnBhcmVudE5vZGUuc2VsZWN0ZWRJbmRleCwhMD09PWUuc2VsZWN0ZWR9LGVtcHR5OmZ1bmN0aW9uKGUpe2ZvcihlPWUuZmlyc3RDaGlsZDtlO2U9ZS5uZXh0U2libGluZylpZihlLm5vZGVUeXBlPDYpcmV0dXJuITE7cmV0dXJuITB9L
HBhcmVudDpmdW5jdGlvbihlKXtyZXR1cm4hYi5wc2V1ZG9zLmVtcHR5KGUpfSxoZWFkZXI6ZnVuY3Rpb24oZSl7cmV0dXJuIEoudGVzdChlLm5vZGVOYW1lKX0saW5wdXQ6ZnVuY3Rpb24oZSl7cmV0dXJuIFEudGVzdChlLm5vZGVOYW1lKX0sYnV0dG9uOmZ1bmN0aW9uKGUpe3ZhciB0PWUubm9kZU5hbWUudG9Mb3dlckNhc2UoKTtyZXR1cm4iaW5wdXQiPT09dCYmImJ1dHRvbiI9PT1lLnR5cGV8fCJidXR0b24iPT09dH0sdGV4dDpmdW5jdGlvbihlKXt2YXIgdDtyZXR1cm4iaW5wdXQiPT09ZS5ub2RlTmFtZS50b0xvd2VyQ2FzZSgpJiYidGV4dCI9PT1lLnR5cGUmJihudWxsPT0odD1lLmdldEF0dHJpYnV0ZSgidHlwZSIpKXx8InRleHQiPT09dC50b0xvd2VyQ2FzZSgpKX0sZmlyc3Q6dmUoZnVuY3Rpb24oKXtyZXR1cm5bMF19KSxsYXN0OnZlKGZ
1bmN0aW9uKGUsdCl7cmV0dXJuW3QtMV19KSxlcTp2ZShmdW5jdGlvbihlLHQsbil7cmV0dXJuW248MD9uK3Q6bl19KSxldmVuOnZlKGZ1bmN0aW9uKGUsdCl7Zm9yKHZhciBuPTA7bjx0O24rPTIpZS5wdXNoKG4pO3JldHVybiBlfSksb2RkOnZlKGZ1bmN0aW9uKGUsdCl7Zm9yKHZhciBuPTE7bjx0O24rPTIpZS5wdXNoKG4pO3JldHVybiBlfSksbHQ6dmUoZnVuY3Rpb24oZSx0LG4pe2Zvcih2YXIgcj1uPDA/bit0OnQ8bj90Om47MDw9LS1yOyllLnB1c2gocik7cmV0dXJuIGV9KSxndDp2ZShmdW5jdGlvbihlLHQsbil7Zm9yKHZhciByPW48MD9uK3Q6bjsrK3I8dDspZS5wdXNoKHIpO3JldHVybiBlfSl9fSkucHNldWRvcy5udGg9Yi5wc2V1ZG9zLmVxLHtyYWRpbzohMCxjaGVja2JveDohMCxmaWxlOiEwLHBhc3N3b3JkOiEwLGltYWdlOiEwfSliL
nBzZXVkb3NbZV09ZGUoZSk7Zm9yKGUgaW57c3VibWl0OiEwLHJlc2V0OiEwfSliLnBzZXVkb3NbZV09aGUoZSk7ZnVuY3Rpb24gbWUoKXt9ZnVuY3Rpb24geGUoZSl7Zm9yKHZhciB0PTAsbj1lLmxlbmd0aCxyPSIiO3Q8bjt0Kyspcis9ZVt0XS52YWx1ZTtyZXR1cm4gcn1mdW5jdGlvbiBiZShzLGUsdCl7dmFyIHU9ZS5kaXIsbD1lLm5leHQsYz1sfHx1LGY9dCYmInBhcmVudE5vZGUiPT09YyxwPXIrKztyZXR1cm4gZS5maXJzdD9mdW5jdGlvbihlLHQsbil7d2hpbGUoZT1lW3VdKWlmKDE9PT1lLm5vZGVUeXBlfHxmKXJldHVybiBzKGUsdCxuKTtyZXR1cm4hMX06ZnVuY3Rpb24oZSx0LG4pe3ZhciByLGksbyxhPVtrLHBdO2lmKG4pe3doaWxlKGU9ZVt1XSlpZigoMT09PWUubm9kZVR5cGV8fGYpJiZzKGUsdCxuKSlyZXR1cm4hMH1lbHNlIHdoaWx
lKGU9ZVt1XSlpZigxPT09ZS5ub2RlVHlwZXx8ZilpZihpPShvPWVbU118fChlW1NdPXt9KSlbZS51bmlxdWVJRF18fChvW2UudW5pcXVlSURdPXt9KSxsJiZsPT09ZS5ub2RlTmFtZS50b0xvd2VyQ2FzZSgpKWU9ZVt1XXx8ZTtlbHNle2lmKChyPWlbY10pJiZyWzBdPT09ayYmclsxXT09PXApcmV0dXJuIGFbMl09clsyXTtpZigoaVtjXT1hKVsyXT1zKGUsdCxuKSlyZXR1cm4hMH1yZXR1cm4hMX19ZnVuY3Rpb24gd2UoaSl7cmV0dXJuIDE8aS5sZW5ndGg/ZnVuY3Rpb24oZSx0LG4pe3ZhciByPWkubGVuZ3RoO3doaWxlKHItLSlpZighaVtyXShlLHQsbikpcmV0dXJuITE7cmV0dXJuITB9OmlbMF19ZnVuY3Rpb24gVGUoZSx0LG4scixpKXtmb3IodmFyIG8sYT1bXSxzPTAsdT1lLmxlbmd0aCxsPW51bGwhPXQ7czx1O3MrKykobz1lW3NdKSYmKG4mJ
iFuKG8scixpKXx8KGEucHVzaChvKSxsJiZ0LnB1c2gocykpKTtyZXR1cm4gYX1mdW5jdGlvbiBDZShkLGgsZyx2LHksZSl7cmV0dXJuIHYmJiF2W1NdJiYodj1DZSh2KSkseSYmIXlbU10mJih5PUNlKHksZSkpLGxlKGZ1bmN0aW9uKGUsdCxuLHIpe3ZhciBpLG8sYSxzPVtdLHU9W10sbD10Lmxlbmd0aCxjPWV8fGZ1bmN0aW9uKGUsdCxuKXtmb3IodmFyIHI9MCxpPXQubGVuZ3RoO3I8aTtyKyspc2UoZSx0W3JdLG4pO3JldHVybiBufShofHwiKiIsbi5ub2RlVHlwZT9bbl06bixbXSksZj0hZHx8IWUmJmg/YzpUZShjLHMsZCxuLHIpLHA9Zz95fHwoZT9kOmx8fHYpP1tdOnQ6ZjtpZihnJiZnKGYscCxuLHIpLHYpe2k9VGUocCx1KSx2KGksW10sbixyKSxvPWkubGVuZ3RoO3doaWxlKG8tLSkoYT1pW29dKSYmKHBbdVtvXV09IShmW3Vbb11dPWEpKX1
pZihlKXtpZih5fHxkKXtpZih5KXtpPVtdLG89cC5sZW5ndGg7d2hpbGUoby0tKShhPXBbb10pJiZpLnB1c2goZltvXT1hKTt5KG51bGwscD1bXSxpLHIpfW89cC5sZW5ndGg7d2hpbGUoby0tKShhPXBbb10pJiYtMTwoaT15P1AoZSxhKTpzW29dKSYmKGVbaV09ISh0W2ldPWEpKX19ZWxzZSBwPVRlKHA9PT10P3Auc3BsaWNlKGwscC5sZW5ndGgpOnApLHk/eShudWxsLHQscCxyKTpILmFwcGx5KHQscCl9KX1mdW5jdGlvbiBFZShlKXtmb3IodmFyIGksdCxuLHI9ZS5sZW5ndGgsbz1iLnJlbGF0aXZlW2VbMF0udHlwZV0sYT1vfHxiLnJlbGF0aXZlWyIgIl0scz1vPzE6MCx1PWJlKGZ1bmN0aW9uKGUpe3JldHVybiBlPT09aX0sYSwhMCksbD1iZShmdW5jdGlvbihlKXtyZXR1cm4tMTxQKGksZSl9LGEsITApLGM9W2Z1bmN0aW9uKGUsdCxuKXt2YXIgc
j0hbyYmKG58fHQhPT13KXx8KChpPXQpLm5vZGVUeXBlP3UoZSx0LG4pOmwoZSx0LG4pKTtyZXR1cm4gaT1udWxsLHJ9XTtzPHI7cysrKWlmKHQ9Yi5yZWxhdGl2ZVtlW3NdLnR5cGVdKWM9W2JlKHdlKGMpLHQpXTtlbHNle2lmKCh0PWIuZmlsdGVyW2Vbc10udHlwZV0uYXBwbHkobnVsbCxlW3NdLm1hdGNoZXMpKVtTXSl7Zm9yKG49KytzO248cjtuKyspaWYoYi5yZWxhdGl2ZVtlW25dLnR5cGVdKWJyZWFrO3JldHVybiBDZSgxPHMmJndlKGMpLDE8cyYmeGUoZS5zbGljZSgwLHMtMSkuY29uY2F0KHt2YWx1ZToiICI9PT1lW3MtMl0udHlwZT8iKiI6IiJ9KSkucmVwbGFjZSgkLCIkMSIpLHQsczxuJiZFZShlLnNsaWNlKHMsbikpLG48ciYmRWUoZT1lLnNsaWNlKG4pKSxuPHImJnhlKGUpKX1jLnB1c2godCl9cmV0dXJuIHdlKGMpfXJldHVybiBtZS5
wcm90b3R5cGU9Yi5maWx0ZXJzPWIucHNldWRvcyxiLnNldEZpbHRlcnM9bmV3IG1lLGg9c2UudG9rZW5pemU9ZnVuY3Rpb24oZSx0KXt2YXIgbixyLGksbyxhLHMsdSxsPXhbZSsiICJdO2lmKGwpcmV0dXJuIHQ/MDpsLnNsaWNlKDApO2E9ZSxzPVtdLHU9Yi5wcmVGaWx0ZXI7d2hpbGUoYSl7Zm9yKG8gaW4gbiYmIShyPV8uZXhlYyhhKSl8fChyJiYoYT1hLnNsaWNlKHJbMF0ubGVuZ3RoKXx8YSkscy5wdXNoKGk9W10pKSxuPSExLChyPXouZXhlYyhhKSkmJihuPXIuc2hpZnQoKSxpLnB1c2goe3ZhbHVlOm4sdHlwZTpyWzBdLnJlcGxhY2UoJCwiICIpfSksYT1hLnNsaWNlKG4ubGVuZ3RoKSksYi5maWx0ZXIpIShyPUdbb10uZXhlYyhhKSl8fHVbb10mJiEocj11W29dKHIpKXx8KG49ci5zaGlmdCgpLGkucHVzaCh7dmFsdWU6bix0eXBlOm8sbWF0Y
2hlczpyfSksYT1hLnNsaWNlKG4ubGVuZ3RoKSk7aWYoIW4pYnJlYWt9cmV0dXJuIHQ/YS5sZW5ndGg6YT9zZS5lcnJvcihlKTp4KGUscykuc2xpY2UoMCl9LGY9c2UuY29tcGlsZT1mdW5jdGlvbihlLHQpe3ZhciBuLHYseSxtLHgscixpPVtdLG89W10sYT1BW2UrIiAiXTtpZighYSl7dHx8KHQ9aChlKSksbj10Lmxlbmd0aDt3aGlsZShuLS0pKGE9RWUodFtuXSkpW1NdP2kucHVzaChhKTpvLnB1c2goYSk7KGE9QShlLCh2PW8sbT0wPCh5PWkpLmxlbmd0aCx4PTA8di5sZW5ndGgscj1mdW5jdGlvbihlLHQsbixyLGkpe3ZhciBvLGEscyx1PTAsbD0iMCIsYz1lJiZbXSxmPVtdLHA9dyxkPWV8fHgmJmIuZmluZC5UQUcoIioiLGkpLGg9ays9bnVsbD09cD8xOk1hdGgucmFuZG9tKCl8fC4xLGc9ZC5sZW5ndGg7Zm9yKGkmJih3PXQ9PUN8fHR8fGkpO2w
hPT1nJiZudWxsIT0obz1kW2xdKTtsKyspe2lmKHgmJm8pe2E9MCx0fHxvLm93bmVyRG9jdW1lbnQ9PUN8fChUKG8pLG49IUUpO3doaWxlKHM9dlthKytdKWlmKHMobyx0fHxDLG4pKXtyLnB1c2gobyk7YnJlYWt9aSYmKGs9aCl9bSYmKChvPSFzJiZvKSYmdS0tLGUmJmMucHVzaChvKSl9aWYodSs9bCxtJiZsIT09dSl7YT0wO3doaWxlKHM9eVthKytdKXMoYyxmLHQsbik7aWYoZSl7aWYoMDx1KXdoaWxlKGwtLSljW2xdfHxmW2xdfHwoZltsXT1xLmNhbGwocikpO2Y9VGUoZil9SC5hcHBseShyLGYpLGkmJiFlJiYwPGYubGVuZ3RoJiYxPHUreS5sZW5ndGgmJnNlLnVuaXF1ZVNvcnQocil9cmV0dXJuIGkmJihrPWgsdz1wKSxjfSxtP2xlKHIpOnIpKSkuc2VsZWN0b3I9ZX1yZXR1cm4gYX0sZz1zZS5zZWxlY3Q9ZnVuY3Rpb24oZSx0LG4scil7dmFyI
GksbyxhLHMsdSxsPSJmdW5jdGlvbiI9PXR5cGVvZiBlJiZlLGM9IXImJmgoZT1sLnNlbGVjdG9yfHxlKTtpZihuPW58fFtdLDE9PT1jLmxlbmd0aCl7aWYoMjwobz1jWzBdPWNbMF0uc2xpY2UoMCkpLmxlbmd0aCYmIklEIj09PShhPW9bMF0pLnR5cGUmJjk9PT10Lm5vZGVUeXBlJiZFJiZiLnJlbGF0aXZlW29bMV0udHlwZV0pe2lmKCEodD0oYi5maW5kLklEKGEubWF0Y2hlc1swXS5yZXBsYWNlKHRlLG5lKSx0KXx8W10pWzBdKSlyZXR1cm4gbjtsJiYodD10LnBhcmVudE5vZGUpLGU9ZS5zbGljZShvLnNoaWZ0KCkudmFsdWUubGVuZ3RoKX1pPUcubmVlZHNDb250ZXh0LnRlc3QoZSk/MDpvLmxlbmd0aDt3aGlsZShpLS0pe2lmKGE9b1tpXSxiLnJlbGF0aXZlW3M9YS50eXBlXSlicmVhaztpZigodT1iLmZpbmRbc10pJiYocj11KGEubWF0Y2hlc1s
wXS5yZXBsYWNlKHRlLG5lKSxlZS50ZXN0KG9bMF0udHlwZSkmJnllKHQucGFyZW50Tm9kZSl8fHQpKSl7aWYoby5zcGxpY2UoaSwxKSwhKGU9ci5sZW5ndGgmJnhlKG8pKSlyZXR1cm4gSC5hcHBseShuLHIpLG47YnJlYWt9fX1yZXR1cm4obHx8ZihlLGMpKShyLHQsIUUsbiwhdHx8ZWUudGVzdChlKSYmeWUodC5wYXJlbnROb2RlKXx8dCksbn0sZC5zb3J0U3RhYmxlPVMuc3BsaXQoIiIpLnNvcnQoRCkuam9pbigiIik9PT1TLGQuZGV0ZWN0RHVwbGljYXRlcz0hIWwsVCgpLGQuc29ydERldGFjaGVkPWNlKGZ1bmN0aW9uKGUpe3JldHVybiAxJmUuY29tcGFyZURvY3VtZW50UG9zaXRpb24oQy5jcmVhdGVFbGVtZW50KCJmaWVsZHNldCIpKX0pLGNlKGZ1bmN0aW9uKGUpe3JldHVybiBlLmlubmVySFRNTD0iPGEgaHJlZj0nIyc+PC9hPiIsIiMiPT09Z
S5maXJzdENoaWxkLmdldEF0dHJpYnV0ZSgiaHJlZiIpfSl8fGZlKCJ0eXBlfGhyZWZ8aGVpZ2h0fHdpZHRoIixmdW5jdGlvbihlLHQsbil7aWYoIW4pcmV0dXJuIGUuZ2V0QXR0cmlidXRlKHQsInR5cGUiPT09dC50b0xvd2VyQ2FzZSgpPzE6Mil9KSxkLmF0dHJpYnV0ZXMmJmNlKGZ1bmN0aW9uKGUpe3JldHVybiBlLmlubmVySFRNTD0iPGlucHV0Lz4iLGUuZmlyc3RDaGlsZC5zZXRBdHRyaWJ1dGUoInZhbHVlIiwiIiksIiI9PT1lLmZpcnN0Q2hpbGQuZ2V0QXR0cmlidXRlKCJ2YWx1ZSIpfSl8fGZlKCJ2YWx1ZSIsZnVuY3Rpb24oZSx0LG4pe2lmKCFuJiYiaW5wdXQiPT09ZS5ub2RlTmFtZS50b0xvd2VyQ2FzZSgpKXJldHVybiBlLmRlZmF1bHRWYWx1ZX0pLGNlKGZ1bmN0aW9uKGUpe3JldHVybiBudWxsPT1lLmdldEF0dHJpYnV0ZSgiZGlzYWJ
sZWQiKX0pfHxmZShSLGZ1bmN0aW9uKGUsdCxuKXt2YXIgcjtpZighbilyZXR1cm4hMD09PWVbdF0/dC50b0xvd2VyQ2FzZSgpOihyPWUuZ2V0QXR0cmlidXRlTm9kZSh0KSkmJnIuc3BlY2lmaWVkP3IudmFsdWU6bnVsbH0pLHNlfShDKTtTLmZpbmQ9ZCxTLmV4cHI9ZC5zZWxlY3RvcnMsUy5leHByWyI6Il09Uy5leHByLnBzZXVkb3MsUy51bmlxdWVTb3J0PVMudW5pcXVlPWQudW5pcXVlU29ydCxTLnRleHQ9ZC5nZXRUZXh0LFMuaXNYTUxEb2M9ZC5pc1hNTCxTLmNvbnRhaW5zPWQuY29udGFpbnMsUy5lc2NhcGVTZWxlY3Rvcj1kLmVzY2FwZTt2YXIgaD1mdW5jdGlvbihlLHQsbil7dmFyIHI9W10saT12b2lkIDAhPT1uO3doaWxlKChlPWVbdF0pJiY5IT09ZS5ub2RlVHlwZSlpZigxPT09ZS5ub2RlVHlwZSl7aWYoaSYmUyhlKS5pcyhuKSlicmVha
ztyLnB1c2goZSl9cmV0dXJuIHJ9LFQ9ZnVuY3Rpb24oZSx0KXtmb3IodmFyIG49W107ZTtlPWUubmV4dFNpYmxpbmcpMT09PWUubm9kZVR5cGUmJmUhPT10JiZuLnB1c2goZSk7cmV0dXJuIG59LGs9Uy5leHByLm1hdGNoLm5lZWRzQ29udGV4dDtmdW5jdGlvbiBBKGUsdCl7cmV0dXJuIGUubm9kZU5hbWUmJmUubm9kZU5hbWUudG9Mb3dlckNhc2UoKT09PXQudG9Mb3dlckNhc2UoKX12YXIgTj0vXjwoW2Etel1bXlwvXDA+Olx4MjBcdFxyXG5cZl0qKVtceDIwXHRcclxuXGZdKlwvPz4oPzo8XC9cMT58KSQvaTtmdW5jdGlvbiBEKGUsbixyKXtyZXR1cm4gbShuKT9TLmdyZXAoZSxmdW5jdGlvbihlLHQpe3JldHVybiEhbi5jYWxsKGUsdCxlKSE9PXJ9KTpuLm5vZGVUeXBlP1MuZ3JlcChlLGZ1bmN0aW9uKGUpe3JldHVybiBlPT09biE9PXJ9KToic3R
yaW5nIiE9dHlwZW9mIG4/Uy5ncmVwKGUsZnVuY3Rpb24oZSl7cmV0dXJuLTE8aS5jYWxsKG4sZSkhPT1yfSk6Uy5maWx0ZXIobixlLHIpfVMuZmlsdGVyPWZ1bmN0aW9uKGUsdCxuKXt2YXIgcj10WzBdO3JldHVybiBuJiYoZT0iOm5vdCgiK2UrIikiKSwxPT09dC5sZW5ndGgmJjE9PT1yLm5vZGVUeXBlP1MuZmluZC5tYXRjaGVzU2VsZWN0b3IocixlKT9bcl06W106Uy5maW5kLm1hdGNoZXMoZSxTLmdyZXAodCxmdW5jdGlvbihlKXtyZXR1cm4gMT09PWUubm9kZVR5cGV9KSl9LFMuZm4uZXh0ZW5kKHtmaW5kOmZ1bmN0aW9uKGUpe3ZhciB0LG4scj10aGlzLmxlbmd0aCxpPXRoaXM7aWYoInN0cmluZyIhPXR5cGVvZiBlKXJldHVybiB0aGlzLnB1c2hTdGFjayhTKGUpLmZpbHRlcihmdW5jdGlvbigpe2Zvcih0PTA7dDxyO3QrKylpZihTLmNvbnRha
W5zKGlbdF0sdGhpcykpcmV0dXJuITB9KSk7Zm9yKG49dGhpcy5wdXNoU3RhY2soW10pLHQ9MDt0PHI7dCsrKVMuZmluZChlLGlbdF0sbik7cmV0dXJuIDE8cj9TLnVuaXF1ZVNvcnQobik6bn0sZmlsdGVyOmZ1bmN0aW9uKGUpe3JldHVybiB0aGlzLnB1c2hTdGFjayhEKHRoaXMsZXx8W10sITEpKX0sbm90OmZ1bmN0aW9uKGUpe3JldHVybiB0aGlzLnB1c2hTdGFjayhEKHRoaXMsZXx8W10sITApKX0saXM6ZnVuY3Rpb24oZSl7cmV0dXJuISFEKHRoaXMsInN0cmluZyI9PXR5cGVvZiBlJiZrLnRlc3QoZSk/UyhlKTplfHxbXSwhMSkubGVuZ3RofX0pO3ZhciBqLHE9L14oPzpccyooPFtcd1xXXSs+KVtePl0qfCMoW1x3LV0rKSkkLzsoUy5mbi5pbml0PWZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpO2lmKCFlKXJldHVybiB0aGlzO2lmKG49bnx8aiwic3R
yaW5nIj09dHlwZW9mIGUpe2lmKCEocj0iPCI9PT1lWzBdJiYiPiI9PT1lW2UubGVuZ3RoLTFdJiYzPD1lLmxlbmd0aD9bbnVsbCxlLG51bGxdOnEuZXhlYyhlKSl8fCFyWzFdJiZ0KXJldHVybiF0fHx0LmpxdWVyeT8odHx8bikuZmluZChlKTp0aGlzLmNvbnN0cnVjdG9yKHQpLmZpbmQoZSk7aWYoclsxXSl7aWYodD10IGluc3RhbmNlb2YgUz90WzBdOnQsUy5tZXJnZSh0aGlzLFMucGFyc2VIVE1MKHJbMV0sdCYmdC5ub2RlVHlwZT90Lm93bmVyRG9jdW1lbnR8fHQ6RSwhMCkpLE4udGVzdChyWzFdKSYmUy5pc1BsYWluT2JqZWN0KHQpKWZvcihyIGluIHQpbSh0aGlzW3JdKT90aGlzW3JdKHRbcl0pOnRoaXMuYXR0cihyLHRbcl0pO3JldHVybiB0aGlzfXJldHVybihpPUUuZ2V0RWxlbWVudEJ5SWQoclsyXSkpJiYodGhpc1swXT1pLHRoaXMubGVuZ
3RoPTEpLHRoaXN9cmV0dXJuIGUubm9kZVR5cGU/KHRoaXNbMF09ZSx0aGlzLmxlbmd0aD0xLHRoaXMpOm0oZSk/dm9pZCAwIT09bi5yZWFkeT9uLnJlYWR5KGUpOmUoUyk6Uy5tYWtlQXJyYXkoZSx0aGlzKX0pLnByb3RvdHlwZT1TLmZuLGo9UyhFKTt2YXIgTD0vXig/OnBhcmVudHN8cHJldig/OlVudGlsfEFsbCkpLyxIPXtjaGlsZHJlbjohMCxjb250ZW50czohMCxuZXh0OiEwLHByZXY6ITB9O2Z1bmN0aW9uIE8oZSx0KXt3aGlsZSgoZT1lW3RdKSYmMSE9PWUubm9kZVR5cGUpO3JldHVybiBlfVMuZm4uZXh0ZW5kKHtoYXM6ZnVuY3Rpb24oZSl7dmFyIHQ9UyhlLHRoaXMpLG49dC5sZW5ndGg7cmV0dXJuIHRoaXMuZmlsdGVyKGZ1bmN0aW9uKCl7Zm9yKHZhciBlPTA7ZTxuO2UrKylpZihTLmNvbnRhaW5zKHRoaXMsdFtlXSkpcmV0dXJuITB9KX0
sY2xvc2VzdDpmdW5jdGlvbihlLHQpe3ZhciBuLHI9MCxpPXRoaXMubGVuZ3RoLG89W10sYT0ic3RyaW5nIiE9dHlwZW9mIGUmJlMoZSk7aWYoIWsudGVzdChlKSlmb3IoO3I8aTtyKyspZm9yKG49dGhpc1tyXTtuJiZuIT09dDtuPW4ucGFyZW50Tm9kZSlpZihuLm5vZGVUeXBlPDExJiYoYT8tMTxhLmluZGV4KG4pOjE9PT1uLm5vZGVUeXBlJiZTLmZpbmQubWF0Y2hlc1NlbGVjdG9yKG4sZSkpKXtvLnB1c2gobik7YnJlYWt9cmV0dXJuIHRoaXMucHVzaFN0YWNrKDE8by5sZW5ndGg/Uy51bmlxdWVTb3J0KG8pOm8pfSxpbmRleDpmdW5jdGlvbihlKXtyZXR1cm4gZT8ic3RyaW5nIj09dHlwZW9mIGU/aS5jYWxsKFMoZSksdGhpc1swXSk6aS5jYWxsKHRoaXMsZS5qcXVlcnk/ZVswXTplKTp0aGlzWzBdJiZ0aGlzWzBdLnBhcmVudE5vZGU/dGhpcy5ma
XJzdCgpLnByZXZBbGwoKS5sZW5ndGg6LTF9LGFkZDpmdW5jdGlvbihlLHQpe3JldHVybiB0aGlzLnB1c2hTdGFjayhTLnVuaXF1ZVNvcnQoUy5tZXJnZSh0aGlzLmdldCgpLFMoZSx0KSkpKX0sYWRkQmFjazpmdW5jdGlvbihlKXtyZXR1cm4gdGhpcy5hZGQobnVsbD09ZT90aGlzLnByZXZPYmplY3Q6dGhpcy5wcmV2T2JqZWN0LmZpbHRlcihlKSl9fSksUy5lYWNoKHtwYXJlbnQ6ZnVuY3Rpb24oZSl7dmFyIHQ9ZS5wYXJlbnROb2RlO3JldHVybiB0JiYxMSE9PXQubm9kZVR5cGU/dDpudWxsfSxwYXJlbnRzOmZ1bmN0aW9uKGUpe3JldHVybiBoKGUsInBhcmVudE5vZGUiKX0scGFyZW50c1VudGlsOmZ1bmN0aW9uKGUsdCxuKXtyZXR1cm4gaChlLCJwYXJlbnROb2RlIixuKX0sbmV4dDpmdW5jdGlvbihlKXtyZXR1cm4gTyhlLCJuZXh0U2libGluZyI
pfSxwcmV2OmZ1bmN0aW9uKGUpe3JldHVybiBPKGUsInByZXZpb3VzU2libGluZyIpfSxuZXh0QWxsOmZ1bmN0aW9uKGUpe3JldHVybiBoKGUsIm5leHRTaWJsaW5nIil9LHByZXZBbGw6ZnVuY3Rpb24oZSl7cmV0dXJuIGgoZSwicHJldmlvdXNTaWJsaW5nIil9LG5leHRVbnRpbDpmdW5jdGlvbihlLHQsbil7cmV0dXJuIGgoZSwibmV4dFNpYmxpbmciLG4pfSxwcmV2VW50aWw6ZnVuY3Rpb24oZSx0LG4pe3JldHVybiBoKGUsInByZXZpb3VzU2libGluZyIsbil9LHNpYmxpbmdzOmZ1bmN0aW9uKGUpe3JldHVybiBUKChlLnBhcmVudE5vZGV8fHt9KS5maXJzdENoaWxkLGUpfSxjaGlsZHJlbjpmdW5jdGlvbihlKXtyZXR1cm4gVChlLmZpcnN0Q2hpbGQpfSxjb250ZW50czpmdW5jdGlvbihlKXtyZXR1cm4gbnVsbCE9ZS5jb250ZW50RG9jdW1lbnQmJ
nIoZS5jb250ZW50RG9jdW1lbnQpP2UuY29udGVudERvY3VtZW50OihBKGUsInRlbXBsYXRlIikmJihlPWUuY29udGVudHx8ZSksUy5tZXJnZShbXSxlLmNoaWxkTm9kZXMpKX19LGZ1bmN0aW9uKHIsaSl7Uy5mbltyXT1mdW5jdGlvbihlLHQpe3ZhciBuPVMubWFwKHRoaXMsaSxlKTtyZXR1cm4iVW50aWwiIT09ci5zbGljZSgtNSkmJih0PWUpLHQmJiJzdHJpbmciPT10eXBlb2YgdCYmKG49Uy5maWx0ZXIodCxuKSksMTx0aGlzLmxlbmd0aCYmKEhbcl18fFMudW5pcXVlU29ydChuKSxMLnRlc3QocikmJm4ucmV2ZXJzZSgpKSx0aGlzLnB1c2hTdGFjayhuKX19KTt2YXIgUD0vW15ceDIwXHRcclxuXGZdKy9nO2Z1bmN0aW9uIFIoZSl7cmV0dXJuIGV9ZnVuY3Rpb24gTShlKXt0aHJvdyBlfWZ1bmN0aW9uIEkoZSx0LG4scil7dmFyIGk7dHJ5e2UmJm0
oaT1lLnByb21pc2UpP2kuY2FsbChlKS5kb25lKHQpLmZhaWwobik6ZSYmbShpPWUudGhlbik/aS5jYWxsKGUsdCxuKTp0LmFwcGx5KHZvaWQgMCxbZV0uc2xpY2UocikpfWNhdGNoKGUpe24uYXBwbHkodm9pZCAwLFtlXSl9fVMuQ2FsbGJhY2tzPWZ1bmN0aW9uKHIpe3ZhciBlLG47cj0ic3RyaW5nIj09dHlwZW9mIHI/KGU9cixuPXt9LFMuZWFjaChlLm1hdGNoKFApfHxbXSxmdW5jdGlvbihlLHQpe25bdF09ITB9KSxuKTpTLmV4dGVuZCh7fSxyKTt2YXIgaSx0LG8sYSxzPVtdLHU9W10sbD0tMSxjPWZ1bmN0aW9uKCl7Zm9yKGE9YXx8ci5vbmNlLG89aT0hMDt1Lmxlbmd0aDtsPS0xKXt0PXUuc2hpZnQoKTt3aGlsZSgrK2w8cy5sZW5ndGgpITE9PT1zW2xdLmFwcGx5KHRbMF0sdFsxXSkmJnIuc3RvcE9uRmFsc2UmJihsPXMubGVuZ3RoLHQ9ITEpf
XIubWVtb3J5fHwodD0hMSksaT0hMSxhJiYocz10P1tdOiIiKX0sZj17YWRkOmZ1bmN0aW9uKCl7cmV0dXJuIHMmJih0JiYhaSYmKGw9cy5sZW5ndGgtMSx1LnB1c2godCkpLGZ1bmN0aW9uIG4oZSl7Uy5lYWNoKGUsZnVuY3Rpb24oZSx0KXttKHQpP3IudW5pcXVlJiZmLmhhcyh0KXx8cy5wdXNoKHQpOnQmJnQubGVuZ3RoJiYic3RyaW5nIiE9PXcodCkmJm4odCl9KX0oYXJndW1lbnRzKSx0JiYhaSYmYygpKSx0aGlzfSxyZW1vdmU6ZnVuY3Rpb24oKXtyZXR1cm4gUy5lYWNoKGFyZ3VtZW50cyxmdW5jdGlvbihlLHQpe3ZhciBuO3doaWxlKC0xPChuPVMuaW5BcnJheSh0LHMsbikpKXMuc3BsaWNlKG4sMSksbjw9bCYmbC0tfSksdGhpc30saGFzOmZ1bmN0aW9uKGUpe3JldHVybiBlPy0xPFMuaW5BcnJheShlLHMpOjA8cy5sZW5ndGh9LGVtcHR5OmZ
1bmN0aW9uKCl7cmV0dXJuIHMmJihzPVtdKSx0aGlzfSxkaXNhYmxlOmZ1bmN0aW9uKCl7cmV0dXJuIGE9dT1bXSxzPXQ9IiIsdGhpc30sZGlzYWJsZWQ6ZnVuY3Rpb24oKXtyZXR1cm4hc30sbG9jazpmdW5jdGlvbigpe3JldHVybiBhPXU9W10sdHx8aXx8KHM9dD0iIiksdGhpc30sbG9ja2VkOmZ1bmN0aW9uKCl7cmV0dXJuISFhfSxmaXJlV2l0aDpmdW5jdGlvbihlLHQpe3JldHVybiBhfHwodD1bZSwodD10fHxbXSkuc2xpY2U/dC5zbGljZSgpOnRdLHUucHVzaCh0KSxpfHxjKCkpLHRoaXN9LGZpcmU6ZnVuY3Rpb24oKXtyZXR1cm4gZi5maXJlV2l0aCh0aGlzLGFyZ3VtZW50cyksdGhpc30sZmlyZWQ6ZnVuY3Rpb24oKXtyZXR1cm4hIW99fTtyZXR1cm4gZn0sUy5leHRlbmQoe0RlZmVycmVkOmZ1bmN0aW9uKGUpe3ZhciBvPVtbIm5vdGlmeSIsI
nByb2dyZXNzIixTLkNhbGxiYWNrcygibWVtb3J5IiksUy5DYWxsYmFja3MoIm1lbW9yeSIpLDJdLFsicmVzb2x2ZSIsImRvbmUiLFMuQ2FsbGJhY2tzKCJvbmNlIG1lbW9yeSIpLFMuQ2FsbGJhY2tzKCJvbmNlIG1lbW9yeSIpLDAsInJlc29sdmVkIl0sWyJyZWplY3QiLCJmYWlsIixTLkNhbGxiYWNrcygib25jZSBtZW1vcnkiKSxTLkNhbGxiYWNrcygib25jZSBtZW1vcnkiKSwxLCJyZWplY3RlZCJdXSxpPSJwZW5kaW5nIixhPXtzdGF0ZTpmdW5jdGlvbigpe3JldHVybiBpfSxhbHdheXM6ZnVuY3Rpb24oKXtyZXR1cm4gcy5kb25lKGFyZ3VtZW50cykuZmFpbChhcmd1bWVudHMpLHRoaXN9LCJjYXRjaCI6ZnVuY3Rpb24oZSl7cmV0dXJuIGEudGhlbihudWxsLGUpfSxwaXBlOmZ1bmN0aW9uKCl7dmFyIGk9YXJndW1lbnRzO3JldHVybiBTLkRlZmV
ycmVkKGZ1bmN0aW9uKHIpe1MuZWFjaChvLGZ1bmN0aW9uKGUsdCl7dmFyIG49bShpW3RbNF1dKSYmaVt0WzRdXTtzW3RbMV1dKGZ1bmN0aW9uKCl7dmFyIGU9biYmbi5hcHBseSh0aGlzLGFyZ3VtZW50cyk7ZSYmbShlLnByb21pc2UpP2UucHJvbWlzZSgpLnByb2dyZXNzKHIubm90aWZ5KS5kb25lKHIucmVzb2x2ZSkuZmFpbChyLnJlamVjdCk6clt0WzBdKyJXaXRoIl0odGhpcyxuP1tlXTphcmd1bWVudHMpfSl9KSxpPW51bGx9KS5wcm9taXNlKCl9LHRoZW46ZnVuY3Rpb24odCxuLHIpe3ZhciB1PTA7ZnVuY3Rpb24gbChpLG8sYSxzKXtyZXR1cm4gZnVuY3Rpb24oKXt2YXIgbj10aGlzLHI9YXJndW1lbnRzLGU9ZnVuY3Rpb24oKXt2YXIgZSx0O2lmKCEoaTx1KSl7aWYoKGU9YS5hcHBseShuLHIpKT09PW8ucHJvbWlzZSgpKXRocm93IG5ldyBUe
XBlRXJyb3IoIlRoZW5hYmxlIHNlbGYtcmVzb2x1dGlvbiIpO3Q9ZSYmKCJvYmplY3QiPT10eXBlb2YgZXx8ImZ1bmN0aW9uIj09dHlwZW9mIGUpJiZlLnRoZW4sbSh0KT9zP3QuY2FsbChlLGwodSxvLFIscyksbCh1LG8sTSxzKSk6KHUrKyx0LmNhbGwoZSxsKHUsbyxSLHMpLGwodSxvLE0scyksbCh1LG8sUixvLm5vdGlmeVdpdGgpKSk6KGEhPT1SJiYobj12b2lkIDAscj1bZV0pLChzfHxvLnJlc29sdmVXaXRoKShuLHIpKX19LHQ9cz9lOmZ1bmN0aW9uKCl7dHJ5e2UoKX1jYXRjaChlKXtTLkRlZmVycmVkLmV4Y2VwdGlvbkhvb2smJlMuRGVmZXJyZWQuZXhjZXB0aW9uSG9vayhlLHQuc3RhY2tUcmFjZSksdTw9aSsxJiYoYSE9PU0mJihuPXZvaWQgMCxyPVtlXSksby5yZWplY3RXaXRoKG4scikpfX07aT90KCk6KFMuRGVmZXJyZWQuZ2V0U3RhY2t
Ib29rJiYodC5zdGFja1RyYWNlPVMuRGVmZXJyZWQuZ2V0U3RhY2tIb29rKCkpLEMuc2V0VGltZW91dCh0KSl9fXJldHVybiBTLkRlZmVycmVkKGZ1bmN0aW9uKGUpe29bMF1bM10uYWRkKGwoMCxlLG0ocik/cjpSLGUubm90aWZ5V2l0aCkpLG9bMV1bM10uYWRkKGwoMCxlLG0odCk/dDpSKSksb1syXVszXS5hZGQobCgwLGUsbShuKT9uOk0pKX0pLnByb21pc2UoKX0scHJvbWlzZTpmdW5jdGlvbihlKXtyZXR1cm4gbnVsbCE9ZT9TLmV4dGVuZChlLGEpOmF9fSxzPXt9O3JldHVybiBTLmVhY2gobyxmdW5jdGlvbihlLHQpe3ZhciBuPXRbMl0scj10WzVdO2FbdFsxXV09bi5hZGQsciYmbi5hZGQoZnVuY3Rpb24oKXtpPXJ9LG9bMy1lXVsyXS5kaXNhYmxlLG9bMy1lXVszXS5kaXNhYmxlLG9bMF1bMl0ubG9jayxvWzBdWzNdLmxvY2spLG4uYWRkKHRbM
10uZmlyZSksc1t0WzBdXT1mdW5jdGlvbigpe3JldHVybiBzW3RbMF0rIldpdGgiXSh0aGlzPT09cz92b2lkIDA6dGhpcyxhcmd1bWVudHMpLHRoaXN9LHNbdFswXSsiV2l0aCJdPW4uZmlyZVdpdGh9KSxhLnByb21pc2UocyksZSYmZS5jYWxsKHMscyksc30sd2hlbjpmdW5jdGlvbihlKXt2YXIgbj1hcmd1bWVudHMubGVuZ3RoLHQ9bixyPUFycmF5KHQpLGk9cy5jYWxsKGFyZ3VtZW50cyksbz1TLkRlZmVycmVkKCksYT1mdW5jdGlvbih0KXtyZXR1cm4gZnVuY3Rpb24oZSl7clt0XT10aGlzLGlbdF09MTxhcmd1bWVudHMubGVuZ3RoP3MuY2FsbChhcmd1bWVudHMpOmUsLS1ufHxvLnJlc29sdmVXaXRoKHIsaSl9fTtpZihuPD0xJiYoSShlLG8uZG9uZShhKHQpKS5yZXNvbHZlLG8ucmVqZWN0LCFuKSwicGVuZGluZyI9PT1vLnN0YXRlKCl8fG0oaVt
0XSYmaVt0XS50aGVuKSkpcmV0dXJuIG8udGhlbigpO3doaWxlKHQtLSlJKGlbdF0sYSh0KSxvLnJlamVjdCk7cmV0dXJuIG8ucHJvbWlzZSgpfX0pO3ZhciBXPS9eKEV2YWx8SW50ZXJuYWx8UmFuZ2V8UmVmZXJlbmNlfFN5bnRheHxUeXBlfFVSSSlFcnJvciQvO1MuRGVmZXJyZWQuZXhjZXB0aW9uSG9vaz1mdW5jdGlvbihlLHQpe0MuY29uc29sZSYmQy5jb25zb2xlLndhcm4mJmUmJlcudGVzdChlLm5hbWUpJiZDLmNvbnNvbGUud2FybigialF1ZXJ5LkRlZmVycmVkIGV4Y2VwdGlvbjogIitlLm1lc3NhZ2UsZS5zdGFjayx0KX0sUy5yZWFkeUV4Y2VwdGlvbj1mdW5jdGlvbihlKXtDLnNldFRpbWVvdXQoZnVuY3Rpb24oKXt0aHJvdyBlfSl9O3ZhciBGPVMuRGVmZXJyZWQoKTtmdW5jdGlvbiBCKCl7RS5yZW1vdmVFdmVudExpc3RlbmVyKCJET01Db
250ZW50TG9hZGVkIixCKSxDLnJlbW92ZUV2ZW50TGlzdGVuZXIoImxvYWQiLEIpLFMucmVhZHkoKX1TLmZuLnJlYWR5PWZ1bmN0aW9uKGUpe3JldHVybiBGLnRoZW4oZSlbImNhdGNoIl0oZnVuY3Rpb24oZSl7Uy5yZWFkeUV4Y2VwdGlvbihlKX0pLHRoaXN9LFMuZXh0ZW5kKHtpc1JlYWR5OiExLHJlYWR5V2FpdDoxLHJlYWR5OmZ1bmN0aW9uKGUpeyghMD09PWU/LS1TLnJlYWR5V2FpdDpTLmlzUmVhZHkpfHwoUy5pc1JlYWR5PSEwKSE9PWUmJjA8LS1TLnJlYWR5V2FpdHx8Ri5yZXNvbHZlV2l0aChFLFtTXSl9fSksUy5yZWFkeS50aGVuPUYudGhlbiwiY29tcGxldGUiPT09RS5yZWFkeVN0YXRlfHwibG9hZGluZyIhPT1FLnJlYWR5U3RhdGUmJiFFLmRvY3VtZW50RWxlbWVudC5kb1Njcm9sbD9DLnNldFRpbWVvdXQoUy5yZWFkeSk6KEUuYWRkRXZ
lbnRMaXN0ZW5lcigiRE9NQ29udGVudExvYWRlZCIsQiksQy5hZGRFdmVudExpc3RlbmVyKCJsb2FkIixCKSk7dmFyICQ9ZnVuY3Rpb24oZSx0LG4scixpLG8sYSl7dmFyIHM9MCx1PWUubGVuZ3RoLGw9bnVsbD09bjtpZigib2JqZWN0Ij09PXcobikpZm9yKHMgaW4gaT0hMCxuKSQoZSx0LHMsbltzXSwhMCxvLGEpO2Vsc2UgaWYodm9pZCAwIT09ciYmKGk9ITAsbShyKXx8KGE9ITApLGwmJihhPyh0LmNhbGwoZSxyKSx0PW51bGwpOihsPXQsdD1mdW5jdGlvbihlLHQsbil7cmV0dXJuIGwuY2FsbChTKGUpLG4pfSkpLHQpKWZvcig7czx1O3MrKyl0KGVbc10sbixhP3I6ci5jYWxsKGVbc10scyx0KGVbc10sbikpKTtyZXR1cm4gaT9lOmw/dC5jYWxsKGUpOnU/dChlWzBdLG4pOm99LF89L14tbXMtLyx6PS8tKFthLXpdKS9nO2Z1bmN0aW9uIFUoZSx0K
XtyZXR1cm4gdC50b1VwcGVyQ2FzZSgpfWZ1bmN0aW9uIFgoZSl7cmV0dXJuIGUucmVwbGFjZShfLCJtcy0iKS5yZXBsYWNlKHosVSl9dmFyIFY9ZnVuY3Rpb24oZSl7cmV0dXJuIDE9PT1lLm5vZGVUeXBlfHw5PT09ZS5ub2RlVHlwZXx8IStlLm5vZGVUeXBlfTtmdW5jdGlvbiBHKCl7dGhpcy5leHBhbmRvPVMuZXhwYW5kbytHLnVpZCsrfUcudWlkPTEsRy5wcm90b3R5cGU9e2NhY2hlOmZ1bmN0aW9uKGUpe3ZhciB0PWVbdGhpcy5leHBhbmRvXTtyZXR1cm4gdHx8KHQ9e30sVihlKSYmKGUubm9kZVR5cGU/ZVt0aGlzLmV4cGFuZG9dPXQ6T2JqZWN0LmRlZmluZVByb3BlcnR5KGUsdGhpcy5leHBhbmRvLHt2YWx1ZTp0LGNvbmZpZ3VyYWJsZTohMH0pKSksdH0sc2V0OmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpPXRoaXMuY2FjaGUoZSk7aWYoInN0cml
uZyI9PXR5cGVvZiB0KWlbWCh0KV09bjtlbHNlIGZvcihyIGluIHQpaVtYKHIpXT10W3JdO3JldHVybiBpfSxnZXQ6ZnVuY3Rpb24oZSx0KXtyZXR1cm4gdm9pZCAwPT09dD90aGlzLmNhY2hlKGUpOmVbdGhpcy5leHBhbmRvXSYmZVt0aGlzLmV4cGFuZG9dW1godCldfSxhY2Nlc3M6ZnVuY3Rpb24oZSx0LG4pe3JldHVybiB2b2lkIDA9PT10fHx0JiYic3RyaW5nIj09dHlwZW9mIHQmJnZvaWQgMD09PW4/dGhpcy5nZXQoZSx0KToodGhpcy5zZXQoZSx0LG4pLHZvaWQgMCE9PW4/bjp0KX0scmVtb3ZlOmZ1bmN0aW9uKGUsdCl7dmFyIG4scj1lW3RoaXMuZXhwYW5kb107aWYodm9pZCAwIT09cil7aWYodm9pZCAwIT09dCl7bj0odD1BcnJheS5pc0FycmF5KHQpP3QubWFwKFgpOih0PVgodCkpaW4gcj9bdF06dC5tYXRjaChQKXx8W10pLmxlbmd0aDt3a
GlsZShuLS0pZGVsZXRlIHJbdFtuXV19KHZvaWQgMD09PXR8fFMuaXNFbXB0eU9iamVjdChyKSkmJihlLm5vZGVUeXBlP2VbdGhpcy5leHBhbmRvXT12b2lkIDA6ZGVsZXRlIGVbdGhpcy5leHBhbmRvXSl9fSxoYXNEYXRhOmZ1bmN0aW9uKGUpe3ZhciB0PWVbdGhpcy5leHBhbmRvXTtyZXR1cm4gdm9pZCAwIT09dCYmIVMuaXNFbXB0eU9iamVjdCh0KX19O3ZhciBZPW5ldyBHLFE9bmV3IEcsSj0vXig/Olx7W1x3XFddKlx9fFxbW1x3XFddKlxdKSQvLEs9L1tBLVpdL2c7ZnVuY3Rpb24gWihlLHQsbil7dmFyIHIsaTtpZih2b2lkIDA9PT1uJiYxPT09ZS5ub2RlVHlwZSlpZihyPSJkYXRhLSIrdC5yZXBsYWNlKEssIi0kJiIpLnRvTG93ZXJDYXNlKCksInN0cmluZyI9PXR5cGVvZihuPWUuZ2V0QXR0cmlidXRlKHIpKSl7dHJ5e249InRydWUiPT09KGk
9bil8fCJmYWxzZSIhPT1pJiYoIm51bGwiPT09aT9udWxsOmk9PT0raSsiIj8raTpKLnRlc3QoaSk/SlNPTi5wYXJzZShpKTppKX1jYXRjaChlKXt9US5zZXQoZSx0LG4pfWVsc2Ugbj12b2lkIDA7cmV0dXJuIG59Uy5leHRlbmQoe2hhc0RhdGE6ZnVuY3Rpb24oZSl7cmV0dXJuIFEuaGFzRGF0YShlKXx8WS5oYXNEYXRhKGUpfSxkYXRhOmZ1bmN0aW9uKGUsdCxuKXtyZXR1cm4gUS5hY2Nlc3MoZSx0LG4pfSxyZW1vdmVEYXRhOmZ1bmN0aW9uKGUsdCl7US5yZW1vdmUoZSx0KX0sX2RhdGE6ZnVuY3Rpb24oZSx0LG4pe3JldHVybiBZLmFjY2VzcyhlLHQsbil9LF9yZW1vdmVEYXRhOmZ1bmN0aW9uKGUsdCl7WS5yZW1vdmUoZSx0KX19KSxTLmZuLmV4dGVuZCh7ZGF0YTpmdW5jdGlvbihuLGUpe3ZhciB0LHIsaSxvPXRoaXNbMF0sYT1vJiZvLmF0dHJpY
nV0ZXM7aWYodm9pZCAwPT09bil7aWYodGhpcy5sZW5ndGgmJihpPVEuZ2V0KG8pLDE9PT1vLm5vZGVUeXBlJiYhWS5nZXQobywiaGFzRGF0YUF0dHJzIikpKXt0PWEubGVuZ3RoO3doaWxlKHQtLSlhW3RdJiYwPT09KHI9YVt0XS5uYW1lKS5pbmRleE9mKCJkYXRhLSIpJiYocj1YKHIuc2xpY2UoNSkpLFoobyxyLGlbcl0pKTtZLnNldChvLCJoYXNEYXRhQXR0cnMiLCEwKX1yZXR1cm4gaX1yZXR1cm4ib2JqZWN0Ij09dHlwZW9mIG4/dGhpcy5lYWNoKGZ1bmN0aW9uKCl7US5zZXQodGhpcyxuKX0pOiQodGhpcyxmdW5jdGlvbihlKXt2YXIgdDtpZihvJiZ2b2lkIDA9PT1lKXJldHVybiB2b2lkIDAhPT0odD1RLmdldChvLG4pKT90OnZvaWQgMCE9PSh0PVoobyxuKSk/dDp2b2lkIDA7dGhpcy5lYWNoKGZ1bmN0aW9uKCl7US5zZXQodGhpcyxuLGUpfSl
9LG51bGwsZSwxPGFyZ3VtZW50cy5sZW5ndGgsbnVsbCwhMCl9LHJlbW92ZURhdGE6ZnVuY3Rpb24oZSl7cmV0dXJuIHRoaXMuZWFjaChmdW5jdGlvbigpe1EucmVtb3ZlKHRoaXMsZSl9KX19KSxTLmV4dGVuZCh7cXVldWU6ZnVuY3Rpb24oZSx0LG4pe3ZhciByO2lmKGUpcmV0dXJuIHQ9KHR8fCJmeCIpKyJxdWV1ZSIscj1ZLmdldChlLHQpLG4mJighcnx8QXJyYXkuaXNBcnJheShuKT9yPVkuYWNjZXNzKGUsdCxTLm1ha2VBcnJheShuKSk6ci5wdXNoKG4pKSxyfHxbXX0sZGVxdWV1ZTpmdW5jdGlvbihlLHQpe3Q9dHx8ImZ4Ijt2YXIgbj1TLnF1ZXVlKGUsdCkscj1uLmxlbmd0aCxpPW4uc2hpZnQoKSxvPVMuX3F1ZXVlSG9va3MoZSx0KTsiaW5wcm9ncmVzcyI9PT1pJiYoaT1uLnNoaWZ0KCksci0tKSxpJiYoImZ4Ij09PXQmJm4udW5zaGlmdCgia
W5wcm9ncmVzcyIpLGRlbGV0ZSBvLnN0b3AsaS5jYWxsKGUsZnVuY3Rpb24oKXtTLmRlcXVldWUoZSx0KX0sbykpLCFyJiZvJiZvLmVtcHR5LmZpcmUoKX0sX3F1ZXVlSG9va3M6ZnVuY3Rpb24oZSx0KXt2YXIgbj10KyJxdWV1ZUhvb2tzIjtyZXR1cm4gWS5nZXQoZSxuKXx8WS5hY2Nlc3MoZSxuLHtlbXB0eTpTLkNhbGxiYWNrcygib25jZSBtZW1vcnkiKS5hZGQoZnVuY3Rpb24oKXtZLnJlbW92ZShlLFt0KyJxdWV1ZSIsbl0pfSl9KX19KSxTLmZuLmV4dGVuZCh7cXVldWU6ZnVuY3Rpb24odCxuKXt2YXIgZT0yO3JldHVybiJzdHJpbmciIT10eXBlb2YgdCYmKG49dCx0PSJmeCIsZS0tKSxhcmd1bWVudHMubGVuZ3RoPGU/Uy5xdWV1ZSh0aGlzWzBdLHQpOnZvaWQgMD09PW4/dGhpczp0aGlzLmVhY2goZnVuY3Rpb24oKXt2YXIgZT1TLnF1ZXVlKHR
oaXMsdCxuKTtTLl9xdWV1ZUhvb2tzKHRoaXMsdCksImZ4Ij09PXQmJiJpbnByb2dyZXNzIiE9PWVbMF0mJlMuZGVxdWV1ZSh0aGlzLHQpfSl9LGRlcXVldWU6ZnVuY3Rpb24oZSl7cmV0dXJuIHRoaXMuZWFjaChmdW5jdGlvbigpe1MuZGVxdWV1ZSh0aGlzLGUpfSl9LGNsZWFyUXVldWU6ZnVuY3Rpb24oZSl7cmV0dXJuIHRoaXMucXVldWUoZXx8ImZ4IixbXSl9LHByb21pc2U6ZnVuY3Rpb24oZSx0KXt2YXIgbixyPTEsaT1TLkRlZmVycmVkKCksbz10aGlzLGE9dGhpcy5sZW5ndGgscz1mdW5jdGlvbigpey0tcnx8aS5yZXNvbHZlV2l0aChvLFtvXSl9OyJzdHJpbmciIT10eXBlb2YgZSYmKHQ9ZSxlPXZvaWQgMCksZT1lfHwiZngiO3doaWxlKGEtLSkobj1ZLmdldChvW2FdLGUrInF1ZXVlSG9va3MiKSkmJm4uZW1wdHkmJihyKyssbi5lbXB0eS5hZ
GQocykpO3JldHVybiBzKCksaS5wcm9taXNlKHQpfX0pO3ZhciBlZT0vWystXT8oPzpcZCpcLnwpXGQrKD86W2VFXVsrLV0/XGQrfCkvLnNvdXJjZSx0ZT1uZXcgUmVnRXhwKCJeKD86KFsrLV0pPXwpKCIrZWUrIikoW2EteiVdKikkIiwiaSIpLG5lPVsiVG9wIiwiUmlnaHQiLCJCb3R0b20iLCJMZWZ0Il0scmU9RS5kb2N1bWVudEVsZW1lbnQsaWU9ZnVuY3Rpb24oZSl7cmV0dXJuIFMuY29udGFpbnMoZS5vd25lckRvY3VtZW50LGUpfSxvZT17Y29tcG9zZWQ6ITB9O3JlLmdldFJvb3ROb2RlJiYoaWU9ZnVuY3Rpb24oZSl7cmV0dXJuIFMuY29udGFpbnMoZS5vd25lckRvY3VtZW50LGUpfHxlLmdldFJvb3ROb2RlKG9lKT09PWUub3duZXJEb2N1bWVudH0pO3ZhciBhZT1mdW5jdGlvbihlLHQpe3JldHVybiJub25lIj09PShlPXR8fGUpLnN0eWxlLmR
pc3BsYXl8fCIiPT09ZS5zdHlsZS5kaXNwbGF5JiZpZShlKSYmIm5vbmUiPT09Uy5jc3MoZSwiZGlzcGxheSIpfTtmdW5jdGlvbiBzZShlLHQsbixyKXt2YXIgaSxvLGE9MjAscz1yP2Z1bmN0aW9uKCl7cmV0dXJuIHIuY3VyKCl9OmZ1bmN0aW9uKCl7cmV0dXJuIFMuY3NzKGUsdCwiIil9LHU9cygpLGw9biYmblszXXx8KFMuY3NzTnVtYmVyW3RdPyIiOiJweCIpLGM9ZS5ub2RlVHlwZSYmKFMuY3NzTnVtYmVyW3RdfHwicHgiIT09bCYmK3UpJiZ0ZS5leGVjKFMuY3NzKGUsdCkpO2lmKGMmJmNbM10hPT1sKXt1Lz0yLGw9bHx8Y1szXSxjPSt1fHwxO3doaWxlKGEtLSlTLnN0eWxlKGUsdCxjK2wpLCgxLW8pKigxLShvPXMoKS91fHwuNSkpPD0wJiYoYT0wKSxjLz1vO2MqPTIsUy5zdHlsZShlLHQsYytsKSxuPW58fFtdfXJldHVybiBuJiYoYz0rY3x8K
3V8fDAsaT1uWzFdP2MrKG5bMV0rMSkqblsyXTorblsyXSxyJiYoci51bml0PWwsci5zdGFydD1jLHIuZW5kPWkpKSxpfXZhciB1ZT17fTtmdW5jdGlvbiBsZShlLHQpe2Zvcih2YXIgbixyLGksbyxhLHMsdSxsPVtdLGM9MCxmPWUubGVuZ3RoO2M8ZjtjKyspKHI9ZVtjXSkuc3R5bGUmJihuPXIuc3R5bGUuZGlzcGxheSx0Pygibm9uZSI9PT1uJiYobFtjXT1ZLmdldChyLCJkaXNwbGF5Iil8fG51bGwsbFtjXXx8KHIuc3R5bGUuZGlzcGxheT0iIikpLCIiPT09ci5zdHlsZS5kaXNwbGF5JiZhZShyKSYmKGxbY109KHU9YT1vPXZvaWQgMCxhPShpPXIpLm93bmVyRG9jdW1lbnQscz1pLm5vZGVOYW1lLCh1PXVlW3NdKXx8KG89YS5ib2R5LmFwcGVuZENoaWxkKGEuY3JlYXRlRWxlbWVudChzKSksdT1TLmNzcyhvLCJkaXNwbGF5Iiksby5wYXJlbnROb2R
lLnJlbW92ZUNoaWxkKG8pLCJub25lIj09PXUmJih1PSJibG9jayIpLHVlW3NdPXUpKSkpOiJub25lIiE9PW4mJihsW2NdPSJub25lIixZLnNldChyLCJkaXNwbGF5IixuKSkpO2ZvcihjPTA7YzxmO2MrKyludWxsIT1sW2NdJiYoZVtjXS5zdHlsZS5kaXNwbGF5PWxbY10pO3JldHVybiBlfVMuZm4uZXh0ZW5kKHtzaG93OmZ1bmN0aW9uKCl7cmV0dXJuIGxlKHRoaXMsITApfSxoaWRlOmZ1bmN0aW9uKCl7cmV0dXJuIGxlKHRoaXMpfSx0b2dnbGU6ZnVuY3Rpb24oZSl7cmV0dXJuImJvb2xlYW4iPT10eXBlb2YgZT9lP3RoaXMuc2hvdygpOnRoaXMuaGlkZSgpOnRoaXMuZWFjaChmdW5jdGlvbigpe2FlKHRoaXMpP1ModGhpcykuc2hvdygpOlModGhpcykuaGlkZSgpfSl9fSk7dmFyIGNlLGZlLHBlPS9eKD86Y2hlY2tib3h8cmFkaW8pJC9pLGRlPS88K
FthLXpdW15cL1wwPlx4MjBcdFxyXG5cZl0qKS9pLGhlPS9eJHxebW9kdWxlJHxcLyg/OmphdmF8ZWNtYSlzY3JpcHQvaTtjZT1FLmNyZWF0ZURvY3VtZW50RnJhZ21lbnQoKS5hcHBlbmRDaGlsZChFLmNyZWF0ZUVsZW1lbnQoImRpdiIpKSwoZmU9RS5jcmVhdGVFbGVtZW50KCJpbnB1dCIpKS5zZXRBdHRyaWJ1dGUoInR5cGUiLCJyYWRpbyIpLGZlLnNldEF0dHJpYnV0ZSgiY2hlY2tlZCIsImNoZWNrZWQiKSxmZS5zZXRBdHRyaWJ1dGUoIm5hbWUiLCJ0IiksY2UuYXBwZW5kQ2hpbGQoZmUpLHkuY2hlY2tDbG9uZT1jZS5jbG9uZU5vZGUoITApLmNsb25lTm9kZSghMCkubGFzdENoaWxkLmNoZWNrZWQsY2UuaW5uZXJIVE1MPSI8dGV4dGFyZWE+eDwvdGV4dGFyZWE+Iix5Lm5vQ2xvbmVDaGVja2VkPSEhY2UuY2xvbmVOb2RlKCEwKS5sYXN0Q2hpbGQ
uZGVmYXVsdFZhbHVlLGNlLmlubmVySFRNTD0iPG9wdGlvbj48L29wdGlvbj4iLHkub3B0aW9uPSEhY2UubGFzdENoaWxkO3ZhciBnZT17dGhlYWQ6WzEsIjx0YWJsZT4iLCI8L3RhYmxlPiJdLGNvbDpbMiwiPHRhYmxlPjxjb2xncm91cD4iLCI8L2NvbGdyb3VwPjwvdGFibGU+Il0sdHI6WzIsIjx0YWJsZT48dGJvZHk+IiwiPC90Ym9keT48L3RhYmxlPiJdLHRkOlszLCI8dGFibGU+PHRib2R5Pjx0cj4iLCI8L3RyPjwvdGJvZHk+PC90YWJsZT4iXSxfZGVmYXVsdDpbMCwiIiwiIl19O2Z1bmN0aW9uIHZlKGUsdCl7dmFyIG47cmV0dXJuIG49InVuZGVmaW5lZCIhPXR5cGVvZiBlLmdldEVsZW1lbnRzQnlUYWdOYW1lP2UuZ2V0RWxlbWVudHNCeVRhZ05hbWUodHx8IioiKToidW5kZWZpbmVkIiE9dHlwZW9mIGUucXVlcnlTZWxlY3RvckFsbD9lLnF1Z
XJ5U2VsZWN0b3JBbGwodHx8IioiKTpbXSx2b2lkIDA9PT10fHx0JiZBKGUsdCk/Uy5tZXJnZShbZV0sbik6bn1mdW5jdGlvbiB5ZShlLHQpe2Zvcih2YXIgbj0wLHI9ZS5sZW5ndGg7bjxyO24rKylZLnNldChlW25dLCJnbG9iYWxFdmFsIiwhdHx8WS5nZXQodFtuXSwiZ2xvYmFsRXZhbCIpKX1nZS50Ym9keT1nZS50Zm9vdD1nZS5jb2xncm91cD1nZS5jYXB0aW9uPWdlLnRoZWFkLGdlLnRoPWdlLnRkLHkub3B0aW9ufHwoZ2Uub3B0Z3JvdXA9Z2Uub3B0aW9uPVsxLCI8c2VsZWN0IG11bHRpcGxlPSdtdWx0aXBsZSc+IiwiPC9zZWxlY3Q+Il0pO3ZhciBtZT0vPHwmIz9cdys7LztmdW5jdGlvbiB4ZShlLHQsbixyLGkpe2Zvcih2YXIgbyxhLHMsdSxsLGMsZj10LmNyZWF0ZURvY3VtZW50RnJhZ21lbnQoKSxwPVtdLGQ9MCxoPWUubGVuZ3RoO2Q8aDt
kKyspaWYoKG89ZVtkXSl8fDA9PT1vKWlmKCJvYmplY3QiPT09dyhvKSlTLm1lcmdlKHAsby5ub2RlVHlwZT9bb106byk7ZWxzZSBpZihtZS50ZXN0KG8pKXthPWF8fGYuYXBwZW5kQ2hpbGQodC5jcmVhdGVFbGVtZW50KCJkaXYiKSkscz0oZGUuZXhlYyhvKXx8WyIiLCIiXSlbMV0udG9Mb3dlckNhc2UoKSx1PWdlW3NdfHxnZS5fZGVmYXVsdCxhLmlubmVySFRNTD11WzFdK1MuaHRtbFByZWZpbHRlcihvKSt1WzJdLGM9dVswXTt3aGlsZShjLS0pYT1hLmxhc3RDaGlsZDtTLm1lcmdlKHAsYS5jaGlsZE5vZGVzKSwoYT1mLmZpcnN0Q2hpbGQpLnRleHRDb250ZW50PSIifWVsc2UgcC5wdXNoKHQuY3JlYXRlVGV4dE5vZGUobykpO2YudGV4dENvbnRlbnQ9IiIsZD0wO3doaWxlKG89cFtkKytdKWlmKHImJi0xPFMuaW5BcnJheShvLHIpKWkmJmkucHVza
ChvKTtlbHNlIGlmKGw9aWUobyksYT12ZShmLmFwcGVuZENoaWxkKG8pLCJzY3JpcHQiKSxsJiZ5ZShhKSxuKXtjPTA7d2hpbGUobz1hW2MrK10paGUudGVzdChvLnR5cGV8fCIiKSYmbi5wdXNoKG8pfXJldHVybiBmfXZhciBiZT0vXmtleS8sd2U9L14oPzptb3VzZXxwb2ludGVyfGNvbnRleHRtZW51fGRyYWd8ZHJvcCl8Y2xpY2svLFRlPS9eKFteLl0qKSg/OlwuKC4rKXwpLztmdW5jdGlvbiBDZSgpe3JldHVybiEwfWZ1bmN0aW9uIEVlKCl7cmV0dXJuITF9ZnVuY3Rpb24gU2UoZSx0KXtyZXR1cm4gZT09PWZ1bmN0aW9uKCl7dHJ5e3JldHVybiBFLmFjdGl2ZUVsZW1lbnR9Y2F0Y2goZSl7fX0oKT09KCJmb2N1cyI9PT10KX1mdW5jdGlvbiBrZShlLHQsbixyLGksbyl7dmFyIGEscztpZigib2JqZWN0Ij09dHlwZW9mIHQpe2ZvcihzIGluInN0cml
uZyIhPXR5cGVvZiBuJiYocj1yfHxuLG49dm9pZCAwKSx0KWtlKGUscyxuLHIsdFtzXSxvKTtyZXR1cm4gZX1pZihudWxsPT1yJiZudWxsPT1pPyhpPW4scj1uPXZvaWQgMCk6bnVsbD09aSYmKCJzdHJpbmciPT10eXBlb2Ygbj8oaT1yLHI9dm9pZCAwKTooaT1yLHI9bixuPXZvaWQgMCkpLCExPT09aSlpPUVlO2Vsc2UgaWYoIWkpcmV0dXJuIGU7cmV0dXJuIDE9PT1vJiYoYT1pLChpPWZ1bmN0aW9uKGUpe3JldHVybiBTKCkub2ZmKGUpLGEuYXBwbHkodGhpcyxhcmd1bWVudHMpfSkuZ3VpZD1hLmd1aWR8fChhLmd1aWQ9Uy5ndWlkKyspKSxlLmVhY2goZnVuY3Rpb24oKXtTLmV2ZW50LmFkZCh0aGlzLHQsaSxyLG4pfSl9ZnVuY3Rpb24gQWUoZSxpLG8pe28/KFkuc2V0KGUsaSwhMSksUy5ldmVudC5hZGQoZSxpLHtuYW1lc3BhY2U6ITEsaGFuZGxlc
jpmdW5jdGlvbihlKXt2YXIgdCxuLHI9WS5nZXQodGhpcyxpKTtpZigxJmUuaXNUcmlnZ2VyJiZ0aGlzW2ldKXtpZihyLmxlbmd0aCkoUy5ldmVudC5zcGVjaWFsW2ldfHx7fSkuZGVsZWdhdGVUeXBlJiZlLnN0b3BQcm9wYWdhdGlvbigpO2Vsc2UgaWYocj1zLmNhbGwoYXJndW1lbnRzKSxZLnNldCh0aGlzLGksciksdD1vKHRoaXMsaSksdGhpc1tpXSgpLHIhPT0obj1ZLmdldCh0aGlzLGkpKXx8dD9ZLnNldCh0aGlzLGksITEpOm49e30sciE9PW4pcmV0dXJuIGUuc3RvcEltbWVkaWF0ZVByb3BhZ2F0aW9uKCksZS5wcmV2ZW50RGVmYXVsdCgpLG4udmFsdWV9ZWxzZSByLmxlbmd0aCYmKFkuc2V0KHRoaXMsaSx7dmFsdWU6Uy5ldmVudC50cmlnZ2VyKFMuZXh0ZW5kKHJbMF0sUy5FdmVudC5wcm90b3R5cGUpLHIuc2xpY2UoMSksdGhpcyl9KSxlLnN
0b3BJbW1lZGlhdGVQcm9wYWdhdGlvbigpKX19KSk6dm9pZCAwPT09WS5nZXQoZSxpKSYmUy5ldmVudC5hZGQoZSxpLENlKX1TLmV2ZW50PXtnbG9iYWw6e30sYWRkOmZ1bmN0aW9uKHQsZSxuLHIsaSl7dmFyIG8sYSxzLHUsbCxjLGYscCxkLGgsZyx2PVkuZ2V0KHQpO2lmKFYodCkpe24uaGFuZGxlciYmKG49KG89bikuaGFuZGxlcixpPW8uc2VsZWN0b3IpLGkmJlMuZmluZC5tYXRjaGVzU2VsZWN0b3IocmUsaSksbi5ndWlkfHwobi5ndWlkPVMuZ3VpZCsrKSwodT12LmV2ZW50cyl8fCh1PXYuZXZlbnRzPU9iamVjdC5jcmVhdGUobnVsbCkpLChhPXYuaGFuZGxlKXx8KGE9di5oYW5kbGU9ZnVuY3Rpb24oZSl7cmV0dXJuInVuZGVmaW5lZCIhPXR5cGVvZiBTJiZTLmV2ZW50LnRyaWdnZXJlZCE9PWUudHlwZT9TLmV2ZW50LmRpc3BhdGNoLmFwcGx5K
HQsYXJndW1lbnRzKTp2b2lkIDB9KSxsPShlPShlfHwiIikubWF0Y2goUCl8fFsiIl0pLmxlbmd0aDt3aGlsZShsLS0pZD1nPShzPVRlLmV4ZWMoZVtsXSl8fFtdKVsxXSxoPShzWzJdfHwiIikuc3BsaXQoIi4iKS5zb3J0KCksZCYmKGY9Uy5ldmVudC5zcGVjaWFsW2RdfHx7fSxkPShpP2YuZGVsZWdhdGVUeXBlOmYuYmluZFR5cGUpfHxkLGY9Uy5ldmVudC5zcGVjaWFsW2RdfHx7fSxjPVMuZXh0ZW5kKHt0eXBlOmQsb3JpZ1R5cGU6ZyxkYXRhOnIsaGFuZGxlcjpuLGd1aWQ6bi5ndWlkLHNlbGVjdG9yOmksbmVlZHNDb250ZXh0OmkmJlMuZXhwci5tYXRjaC5uZWVkc0NvbnRleHQudGVzdChpKSxuYW1lc3BhY2U6aC5qb2luKCIuIil9LG8pLChwPXVbZF0pfHwoKHA9dVtkXT1bXSkuZGVsZWdhdGVDb3VudD0wLGYuc2V0dXAmJiExIT09Zi5zZXR1cC5
jYWxsKHQscixoLGEpfHx0LmFkZEV2ZW50TGlzdGVuZXImJnQuYWRkRXZlbnRMaXN0ZW5lcihkLGEpKSxmLmFkZCYmKGYuYWRkLmNhbGwodCxjKSxjLmhhbmRsZXIuZ3VpZHx8KGMuaGFuZGxlci5ndWlkPW4uZ3VpZCkpLGk/cC5zcGxpY2UocC5kZWxlZ2F0ZUNvdW50KyssMCxjKTpwLnB1c2goYyksUy5ldmVudC5nbG9iYWxbZF09ITApfX0scmVtb3ZlOmZ1bmN0aW9uKGUsdCxuLHIsaSl7dmFyIG8sYSxzLHUsbCxjLGYscCxkLGgsZyx2PVkuaGFzRGF0YShlKSYmWS5nZXQoZSk7aWYodiYmKHU9di5ldmVudHMpKXtsPSh0PSh0fHwiIikubWF0Y2goUCl8fFsiIl0pLmxlbmd0aDt3aGlsZShsLS0paWYoZD1nPShzPVRlLmV4ZWModFtsXSl8fFtdKVsxXSxoPShzWzJdfHwiIikuc3BsaXQoIi4iKS5zb3J0KCksZCl7Zj1TLmV2ZW50LnNwZWNpYWxbZF18f
Ht9LHA9dVtkPShyP2YuZGVsZWdhdGVUeXBlOmYuYmluZFR5cGUpfHxkXXx8W10scz1zWzJdJiZuZXcgUmVnRXhwKCIoXnxcXC4pIitoLmpvaW4oIlxcLig/Oi4qXFwufCkiKSsiKFxcLnwkKSIpLGE9bz1wLmxlbmd0aDt3aGlsZShvLS0pYz1wW29dLCFpJiZnIT09Yy5vcmlnVHlwZXx8biYmbi5ndWlkIT09Yy5ndWlkfHxzJiYhcy50ZXN0KGMubmFtZXNwYWNlKXx8ciYmciE9PWMuc2VsZWN0b3ImJigiKioiIT09cnx8IWMuc2VsZWN0b3IpfHwocC5zcGxpY2UobywxKSxjLnNlbGVjdG9yJiZwLmRlbGVnYXRlQ291bnQtLSxmLnJlbW92ZSYmZi5yZW1vdmUuY2FsbChlLGMpKTthJiYhcC5sZW5ndGgmJihmLnRlYXJkb3duJiYhMSE9PWYudGVhcmRvd24uY2FsbChlLGgsdi5oYW5kbGUpfHxTLnJlbW92ZUV2ZW50KGUsZCx2LmhhbmRsZSksZGVsZXRlIHV
bZF0pfWVsc2UgZm9yKGQgaW4gdSlTLmV2ZW50LnJlbW92ZShlLGQrdFtsXSxuLHIsITApO1MuaXNFbXB0eU9iamVjdCh1KSYmWS5yZW1vdmUoZSwiaGFuZGxlIGV2ZW50cyIpfX0sZGlzcGF0Y2g6ZnVuY3Rpb24oZSl7dmFyIHQsbixyLGksbyxhLHM9bmV3IEFycmF5KGFyZ3VtZW50cy5sZW5ndGgpLHU9Uy5ldmVudC5maXgoZSksbD0oWS5nZXQodGhpcywiZXZlbnRzIil8fE9iamVjdC5jcmVhdGUobnVsbCkpW3UudHlwZV18fFtdLGM9Uy5ldmVudC5zcGVjaWFsW3UudHlwZV18fHt9O2ZvcihzWzBdPXUsdD0xO3Q8YXJndW1lbnRzLmxlbmd0aDt0Kyspc1t0XT1hcmd1bWVudHNbdF07aWYodS5kZWxlZ2F0ZVRhcmdldD10aGlzLCFjLnByZURpc3BhdGNofHwhMSE9PWMucHJlRGlzcGF0Y2guY2FsbCh0aGlzLHUpKXthPVMuZXZlbnQuaGFuZGxlcnMuY
2FsbCh0aGlzLHUsbCksdD0wO3doaWxlKChpPWFbdCsrXSkmJiF1LmlzUHJvcGFnYXRpb25TdG9wcGVkKCkpe3UuY3VycmVudFRhcmdldD1pLmVsZW0sbj0wO3doaWxlKChvPWkuaGFuZGxlcnNbbisrXSkmJiF1LmlzSW1tZWRpYXRlUHJvcGFnYXRpb25TdG9wcGVkKCkpdS5ybmFtZXNwYWNlJiYhMSE9PW8ubmFtZXNwYWNlJiYhdS5ybmFtZXNwYWNlLnRlc3Qoby5uYW1lc3BhY2UpfHwodS5oYW5kbGVPYmo9byx1LmRhdGE9by5kYXRhLHZvaWQgMCE9PShyPSgoUy5ldmVudC5zcGVjaWFsW28ub3JpZ1R5cGVdfHx7fSkuaGFuZGxlfHxvLmhhbmRsZXIpLmFwcGx5KGkuZWxlbSxzKSkmJiExPT09KHUucmVzdWx0PXIpJiYodS5wcmV2ZW50RGVmYXVsdCgpLHUuc3RvcFByb3BhZ2F0aW9uKCkpKX1yZXR1cm4gYy5wb3N0RGlzcGF0Y2gmJmMucG9zdERpc3B
hdGNoLmNhbGwodGhpcyx1KSx1LnJlc3VsdH19LGhhbmRsZXJzOmZ1bmN0aW9uKGUsdCl7dmFyIG4scixpLG8sYSxzPVtdLHU9dC5kZWxlZ2F0ZUNvdW50LGw9ZS50YXJnZXQ7aWYodSYmbC5ub2RlVHlwZSYmISgiY2xpY2siPT09ZS50eXBlJiYxPD1lLmJ1dHRvbikpZm9yKDtsIT09dGhpcztsPWwucGFyZW50Tm9kZXx8dGhpcylpZigxPT09bC5ub2RlVHlwZSYmKCJjbGljayIhPT1lLnR5cGV8fCEwIT09bC5kaXNhYmxlZCkpe2ZvcihvPVtdLGE9e30sbj0wO248dTtuKyspdm9pZCAwPT09YVtpPShyPXRbbl0pLnNlbGVjdG9yKyIgIl0mJihhW2ldPXIubmVlZHNDb250ZXh0Py0xPFMoaSx0aGlzKS5pbmRleChsKTpTLmZpbmQoaSx0aGlzLG51bGwsW2xdKS5sZW5ndGgpLGFbaV0mJm8ucHVzaChyKTtvLmxlbmd0aCYmcy5wdXNoKHtlbGVtOmwsaGFuZ
GxlcnM6b30pfXJldHVybiBsPXRoaXMsdTx0Lmxlbmd0aCYmcy5wdXNoKHtlbGVtOmwsaGFuZGxlcnM6dC5zbGljZSh1KX0pLHN9LGFkZFByb3A6ZnVuY3Rpb24odCxlKXtPYmplY3QuZGVmaW5lUHJvcGVydHkoUy5FdmVudC5wcm90b3R5cGUsdCx7ZW51bWVyYWJsZTohMCxjb25maWd1cmFibGU6ITAsZ2V0Om0oZSk/ZnVuY3Rpb24oKXtpZih0aGlzLm9yaWdpbmFsRXZlbnQpcmV0dXJuIGUodGhpcy5vcmlnaW5hbEV2ZW50KX06ZnVuY3Rpb24oKXtpZih0aGlzLm9yaWdpbmFsRXZlbnQpcmV0dXJuIHRoaXMub3JpZ2luYWxFdmVudFt0XX0sc2V0OmZ1bmN0aW9uKGUpe09iamVjdC5kZWZpbmVQcm9wZXJ0eSh0aGlzLHQse2VudW1lcmFibGU6ITAsY29uZmlndXJhYmxlOiEwLHdyaXRhYmxlOiEwLHZhbHVlOmV9KX19KX0sZml4OmZ1bmN0aW9uKGUpe3J
ldHVybiBlW1MuZXhwYW5kb10/ZTpuZXcgUy5FdmVudChlKX0sc3BlY2lhbDp7bG9hZDp7bm9CdWJibGU6ITB9LGNsaWNrOntzZXR1cDpmdW5jdGlvbihlKXt2YXIgdD10aGlzfHxlO3JldHVybiBwZS50ZXN0KHQudHlwZSkmJnQuY2xpY2smJkEodCwiaW5wdXQiKSYmQWUodCwiY2xpY2siLENlKSwhMX0sdHJpZ2dlcjpmdW5jdGlvbihlKXt2YXIgdD10aGlzfHxlO3JldHVybiBwZS50ZXN0KHQudHlwZSkmJnQuY2xpY2smJkEodCwiaW5wdXQiKSYmQWUodCwiY2xpY2siKSwhMH0sX2RlZmF1bHQ6ZnVuY3Rpb24oZSl7dmFyIHQ9ZS50YXJnZXQ7cmV0dXJuIHBlLnRlc3QodC50eXBlKSYmdC5jbGljayYmQSh0LCJpbnB1dCIpJiZZLmdldCh0LCJjbGljayIpfHxBKHQsImEiKX19LGJlZm9yZXVubG9hZDp7cG9zdERpc3BhdGNoOmZ1bmN0aW9uKGUpe3Zva
WQgMCE9PWUucmVzdWx0JiZlLm9yaWdpbmFsRXZlbnQmJihlLm9yaWdpbmFsRXZlbnQucmV0dXJuVmFsdWU9ZS5yZXN1bHQpfX19fSxTLnJlbW92ZUV2ZW50PWZ1bmN0aW9uKGUsdCxuKXtlLnJlbW92ZUV2ZW50TGlzdGVuZXImJmUucmVtb3ZlRXZlbnRMaXN0ZW5lcih0LG4pfSxTLkV2ZW50PWZ1bmN0aW9uKGUsdCl7aWYoISh0aGlzIGluc3RhbmNlb2YgUy5FdmVudCkpcmV0dXJuIG5ldyBTLkV2ZW50KGUsdCk7ZSYmZS50eXBlPyh0aGlzLm9yaWdpbmFsRXZlbnQ9ZSx0aGlzLnR5cGU9ZS50eXBlLHRoaXMuaXNEZWZhdWx0UHJldmVudGVkPWUuZGVmYXVsdFByZXZlbnRlZHx8dm9pZCAwPT09ZS5kZWZhdWx0UHJldmVudGVkJiYhMT09PWUucmV0dXJuVmFsdWU/Q2U6RWUsdGhpcy50YXJnZXQ9ZS50YXJnZXQmJjM9PT1lLnRhcmdldC5ub2RlVHlwZT9
lLnRhcmdldC5wYXJlbnROb2RlOmUudGFyZ2V0LHRoaXMuY3VycmVudFRhcmdldD1lLmN1cnJlbnRUYXJnZXQsdGhpcy5yZWxhdGVkVGFyZ2V0PWUucmVsYXRlZFRhcmdldCk6dGhpcy50eXBlPWUsdCYmUy5leHRlbmQodGhpcyx0KSx0aGlzLnRpbWVTdGFtcD1lJiZlLnRpbWVTdGFtcHx8RGF0ZS5ub3coKSx0aGlzW1MuZXhwYW5kb109ITB9LFMuRXZlbnQucHJvdG90eXBlPXtjb25zdHJ1Y3RvcjpTLkV2ZW50LGlzRGVmYXVsdFByZXZlbnRlZDpFZSxpc1Byb3BhZ2F0aW9uU3RvcHBlZDpFZSxpc0ltbWVkaWF0ZVByb3BhZ2F0aW9uU3RvcHBlZDpFZSxpc1NpbXVsYXRlZDohMSxwcmV2ZW50RGVmYXVsdDpmdW5jdGlvbigpe3ZhciBlPXRoaXMub3JpZ2luYWxFdmVudDt0aGlzLmlzRGVmYXVsdFByZXZlbnRlZD1DZSxlJiYhdGhpcy5pc1NpbXVsYXRlZ
CYmZS5wcmV2ZW50RGVmYXVsdCgpfSxzdG9wUHJvcGFnYXRpb246ZnVuY3Rpb24oKXt2YXIgZT10aGlzLm9yaWdpbmFsRXZlbnQ7dGhpcy5pc1Byb3BhZ2F0aW9uU3RvcHBlZD1DZSxlJiYhdGhpcy5pc1NpbXVsYXRlZCYmZS5zdG9wUHJvcGFnYXRpb24oKX0sc3RvcEltbWVkaWF0ZVByb3BhZ2F0aW9uOmZ1bmN0aW9uKCl7dmFyIGU9dGhpcy5vcmlnaW5hbEV2ZW50O3RoaXMuaXNJbW1lZGlhdGVQcm9wYWdhdGlvblN0b3BwZWQ9Q2UsZSYmIXRoaXMuaXNTaW11bGF0ZWQmJmUuc3RvcEltbWVkaWF0ZVByb3BhZ2F0aW9uKCksdGhpcy5zdG9wUHJvcGFnYXRpb24oKX19LFMuZWFjaCh7YWx0S2V5OiEwLGJ1YmJsZXM6ITAsY2FuY2VsYWJsZTohMCxjaGFuZ2VkVG91Y2hlczohMCxjdHJsS2V5OiEwLGRldGFpbDohMCxldmVudFBoYXNlOiEwLG1ldGFLZXk
6ITAscGFnZVg6ITAscGFnZVk6ITAsc2hpZnRLZXk6ITAsdmlldzohMCwiY2hhciI6ITAsY29kZTohMCxjaGFyQ29kZTohMCxrZXk6ITAsa2V5Q29kZTohMCxidXR0b246ITAsYnV0dG9uczohMCxjbGllbnRYOiEwLGNsaWVudFk6ITAsb2Zmc2V0WDohMCxvZmZzZXRZOiEwLHBvaW50ZXJJZDohMCxwb2ludGVyVHlwZTohMCxzY3JlZW5YOiEwLHNjcmVlblk6ITAsdGFyZ2V0VG91Y2hlczohMCx0b0VsZW1lbnQ6ITAsdG91Y2hlczohMCx3aGljaDpmdW5jdGlvbihlKXt2YXIgdD1lLmJ1dHRvbjtyZXR1cm4gbnVsbD09ZS53aGljaCYmYmUudGVzdChlLnR5cGUpP251bGwhPWUuY2hhckNvZGU/ZS5jaGFyQ29kZTplLmtleUNvZGU6IWUud2hpY2gmJnZvaWQgMCE9PXQmJndlLnRlc3QoZS50eXBlKT8xJnQ/MToyJnQ/Mzo0JnQ/MjowOmUud2hpY2h9fSxTL
mV2ZW50LmFkZFByb3ApLFMuZWFjaCh7Zm9jdXM6ImZvY3VzaW4iLGJsdXI6ImZvY3Vzb3V0In0sZnVuY3Rpb24oZSx0KXtTLmV2ZW50LnNwZWNpYWxbZV09e3NldHVwOmZ1bmN0aW9uKCl7cmV0dXJuIEFlKHRoaXMsZSxTZSksITF9LHRyaWdnZXI6ZnVuY3Rpb24oKXtyZXR1cm4gQWUodGhpcyxlKSwhMH0sZGVsZWdhdGVUeXBlOnR9fSksUy5lYWNoKHttb3VzZWVudGVyOiJtb3VzZW92ZXIiLG1vdXNlbGVhdmU6Im1vdXNlb3V0Iixwb2ludGVyZW50ZXI6InBvaW50ZXJvdmVyIixwb2ludGVybGVhdmU6InBvaW50ZXJvdXQifSxmdW5jdGlvbihlLGkpe1MuZXZlbnQuc3BlY2lhbFtlXT17ZGVsZWdhdGVUeXBlOmksYmluZFR5cGU6aSxoYW5kbGU6ZnVuY3Rpb24oZSl7dmFyIHQsbj1lLnJlbGF0ZWRUYXJnZXQscj1lLmhhbmRsZU9iajtyZXR1cm4gbiY
mKG49PT10aGlzfHxTLmNvbnRhaW5zKHRoaXMsbikpfHwoZS50eXBlPXIub3JpZ1R5cGUsdD1yLmhhbmRsZXIuYXBwbHkodGhpcyxhcmd1bWVudHMpLGUudHlwZT1pKSx0fX19KSxTLmZuLmV4dGVuZCh7b246ZnVuY3Rpb24oZSx0LG4scil7cmV0dXJuIGtlKHRoaXMsZSx0LG4scil9LG9uZTpmdW5jdGlvbihlLHQsbixyKXtyZXR1cm4ga2UodGhpcyxlLHQsbixyLDEpfSxvZmY6ZnVuY3Rpb24oZSx0LG4pe3ZhciByLGk7aWYoZSYmZS5wcmV2ZW50RGVmYXVsdCYmZS5oYW5kbGVPYmopcmV0dXJuIHI9ZS5oYW5kbGVPYmosUyhlLmRlbGVnYXRlVGFyZ2V0KS5vZmYoci5uYW1lc3BhY2U/ci5vcmlnVHlwZSsiLiIrci5uYW1lc3BhY2U6ci5vcmlnVHlwZSxyLnNlbGVjdG9yLHIuaGFuZGxlciksdGhpcztpZigib2JqZWN0Ij09dHlwZW9mIGUpe2ZvcihpI
GluIGUpdGhpcy5vZmYoaSx0LGVbaV0pO3JldHVybiB0aGlzfXJldHVybiExIT09dCYmImZ1bmN0aW9uIiE9dHlwZW9mIHR8fChuPXQsdD12b2lkIDApLCExPT09biYmKG49RWUpLHRoaXMuZWFjaChmdW5jdGlvbigpe1MuZXZlbnQucmVtb3ZlKHRoaXMsZSxuLHQpfSl9fSk7dmFyIE5lPS88c2NyaXB0fDxzdHlsZXw8bGluay9pLERlPS9jaGVja2VkXHMqKD86W149XXw9XHMqLmNoZWNrZWQuKS9pLGplPS9eXHMqPCEoPzpcW0NEQVRBXFt8LS0pfCg/OlxdXF18LS0pPlxzKiQvZztmdW5jdGlvbiBxZShlLHQpe3JldHVybiBBKGUsInRhYmxlIikmJkEoMTEhPT10Lm5vZGVUeXBlP3Q6dC5maXJzdENoaWxkLCJ0ciIpJiZTKGUpLmNoaWxkcmVuKCJ0Ym9keSIpWzBdfHxlfWZ1bmN0aW9uIExlKGUpe3JldHVybiBlLnR5cGU9KG51bGwhPT1lLmdldEF0dHJ
pYnV0ZSgidHlwZSIpKSsiLyIrZS50eXBlLGV9ZnVuY3Rpb24gSGUoZSl7cmV0dXJuInRydWUvIj09PShlLnR5cGV8fCIiKS5zbGljZSgwLDUpP2UudHlwZT1lLnR5cGUuc2xpY2UoNSk6ZS5yZW1vdmVBdHRyaWJ1dGUoInR5cGUiKSxlfWZ1bmN0aW9uIE9lKGUsdCl7dmFyIG4scixpLG8sYSxzO2lmKDE9PT10Lm5vZGVUeXBlKXtpZihZLmhhc0RhdGEoZSkmJihzPVkuZ2V0KGUpLmV2ZW50cykpZm9yKGkgaW4gWS5yZW1vdmUodCwiaGFuZGxlIGV2ZW50cyIpLHMpZm9yKG49MCxyPXNbaV0ubGVuZ3RoO248cjtuKyspUy5ldmVudC5hZGQodCxpLHNbaV1bbl0pO1EuaGFzRGF0YShlKSYmKG89US5hY2Nlc3MoZSksYT1TLmV4dGVuZCh7fSxvKSxRLnNldCh0LGEpKX19ZnVuY3Rpb24gUGUobixyLGksbyl7cj1nKHIpO3ZhciBlLHQsYSxzLHUsbCxjPTAsZ
j1uLmxlbmd0aCxwPWYtMSxkPXJbMF0saD1tKGQpO2lmKGh8fDE8ZiYmInN0cmluZyI9PXR5cGVvZiBkJiYheS5jaGVja0Nsb25lJiZEZS50ZXN0KGQpKXJldHVybiBuLmVhY2goZnVuY3Rpb24oZSl7dmFyIHQ9bi5lcShlKTtoJiYoclswXT1kLmNhbGwodGhpcyxlLHQuaHRtbCgpKSksUGUodCxyLGksbyl9KTtpZihmJiYodD0oZT14ZShyLG5bMF0ub3duZXJEb2N1bWVudCwhMSxuLG8pKS5maXJzdENoaWxkLDE9PT1lLmNoaWxkTm9kZXMubGVuZ3RoJiYoZT10KSx0fHxvKSl7Zm9yKHM9KGE9Uy5tYXAodmUoZSwic2NyaXB0IiksTGUpKS5sZW5ndGg7YzxmO2MrKyl1PWUsYyE9PXAmJih1PVMuY2xvbmUodSwhMCwhMCkscyYmUy5tZXJnZShhLHZlKHUsInNjcmlwdCIpKSksaS5jYWxsKG5bY10sdSxjKTtpZihzKWZvcihsPWFbYS5sZW5ndGgtMV0ub3d
uZXJEb2N1bWVudCxTLm1hcChhLEhlKSxjPTA7YzxzO2MrKyl1PWFbY10saGUudGVzdCh1LnR5cGV8fCIiKSYmIVkuYWNjZXNzKHUsImdsb2JhbEV2YWwiKSYmUy5jb250YWlucyhsLHUpJiYodS5zcmMmJiJtb2R1bGUiIT09KHUudHlwZXx8IiIpLnRvTG93ZXJDYXNlKCk/Uy5fZXZhbFVybCYmIXUubm9Nb2R1bGUmJlMuX2V2YWxVcmwodS5zcmMse25vbmNlOnUubm9uY2V8fHUuZ2V0QXR0cmlidXRlKCJub25jZSIpfSxsKTpiKHUudGV4dENvbnRlbnQucmVwbGFjZShqZSwiIiksdSxsKSl9cmV0dXJuIG59ZnVuY3Rpb24gUmUoZSx0LG4pe2Zvcih2YXIgcixpPXQ/Uy5maWx0ZXIodCxlKTplLG89MDtudWxsIT0ocj1pW29dKTtvKyspbnx8MSE9PXIubm9kZVR5cGV8fFMuY2xlYW5EYXRhKHZlKHIpKSxyLnBhcmVudE5vZGUmJihuJiZpZShyKSYmeWUod
mUociwic2NyaXB0IikpLHIucGFyZW50Tm9kZS5yZW1vdmVDaGlsZChyKSk7cmV0dXJuIGV9Uy5leHRlbmQoe2h0bWxQcmVmaWx0ZXI6ZnVuY3Rpb24oZSl7cmV0dXJuIGV9LGNsb25lOmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG8sYSxzLHUsbCxjPWUuY2xvbmVOb2RlKCEwKSxmPWllKGUpO2lmKCEoeS5ub0Nsb25lQ2hlY2tlZHx8MSE9PWUubm9kZVR5cGUmJjExIT09ZS5ub2RlVHlwZXx8Uy5pc1hNTERvYyhlKSkpZm9yKGE9dmUoYykscj0wLGk9KG89dmUoZSkpLmxlbmd0aDtyPGk7cisrKXM9b1tyXSx1PWFbcl0sdm9pZCAwLCJpbnB1dCI9PT0obD11Lm5vZGVOYW1lLnRvTG93ZXJDYXNlKCkpJiZwZS50ZXN0KHMudHlwZSk/dS5jaGVja2VkPXMuY2hlY2tlZDoiaW5wdXQiIT09bCYmInRleHRhcmVhIiE9PWx8fCh1LmRlZmF1bHRWYWx1ZT1zLmR
lZmF1bHRWYWx1ZSk7aWYodClpZihuKWZvcihvPW98fHZlKGUpLGE9YXx8dmUoYykscj0wLGk9by5sZW5ndGg7cjxpO3IrKylPZShvW3JdLGFbcl0pO2Vsc2UgT2UoZSxjKTtyZXR1cm4gMDwoYT12ZShjLCJzY3JpcHQiKSkubGVuZ3RoJiZ5ZShhLCFmJiZ2ZShlLCJzY3JpcHQiKSksY30sY2xlYW5EYXRhOmZ1bmN0aW9uKGUpe2Zvcih2YXIgdCxuLHIsaT1TLmV2ZW50LnNwZWNpYWwsbz0wO3ZvaWQgMCE9PShuPWVbb10pO28rKylpZihWKG4pKXtpZih0PW5bWS5leHBhbmRvXSl7aWYodC5ldmVudHMpZm9yKHIgaW4gdC5ldmVudHMpaVtyXT9TLmV2ZW50LnJlbW92ZShuLHIpOlMucmVtb3ZlRXZlbnQobixyLHQuaGFuZGxlKTtuW1kuZXhwYW5kb109dm9pZCAwfW5bUS5leHBhbmRvXSYmKG5bUS5leHBhbmRvXT12b2lkIDApfX19KSxTLmZuLmV4dGVuZ
Ch7ZGV0YWNoOmZ1bmN0aW9uKGUpe3JldHVybiBSZSh0aGlzLGUsITApfSxyZW1vdmU6ZnVuY3Rpb24oZSl7cmV0dXJuIFJlKHRoaXMsZSl9LHRleHQ6ZnVuY3Rpb24oZSl7cmV0dXJuICQodGhpcyxmdW5jdGlvbihlKXtyZXR1cm4gdm9pZCAwPT09ZT9TLnRleHQodGhpcyk6dGhpcy5lbXB0eSgpLmVhY2goZnVuY3Rpb24oKXsxIT09dGhpcy5ub2RlVHlwZSYmMTEhPT10aGlzLm5vZGVUeXBlJiY5IT09dGhpcy5ub2RlVHlwZXx8KHRoaXMudGV4dENvbnRlbnQ9ZSl9KX0sbnVsbCxlLGFyZ3VtZW50cy5sZW5ndGgpfSxhcHBlbmQ6ZnVuY3Rpb24oKXtyZXR1cm4gUGUodGhpcyxhcmd1bWVudHMsZnVuY3Rpb24oZSl7MSE9PXRoaXMubm9kZVR5cGUmJjExIT09dGhpcy5ub2RlVHlwZSYmOSE9PXRoaXMubm9kZVR5cGV8fHFlKHRoaXMsZSkuYXBwZW5kQ2h
pbGQoZSl9KX0scHJlcGVuZDpmdW5jdGlvbigpe3JldHVybiBQZSh0aGlzLGFyZ3VtZW50cyxmdW5jdGlvbihlKXtpZigxPT09dGhpcy5ub2RlVHlwZXx8MTE9PT10aGlzLm5vZGVUeXBlfHw5PT09dGhpcy5ub2RlVHlwZSl7dmFyIHQ9cWUodGhpcyxlKTt0Lmluc2VydEJlZm9yZShlLHQuZmlyc3RDaGlsZCl9fSl9LGJlZm9yZTpmdW5jdGlvbigpe3JldHVybiBQZSh0aGlzLGFyZ3VtZW50cyxmdW5jdGlvbihlKXt0aGlzLnBhcmVudE5vZGUmJnRoaXMucGFyZW50Tm9kZS5pbnNlcnRCZWZvcmUoZSx0aGlzKX0pfSxhZnRlcjpmdW5jdGlvbigpe3JldHVybiBQZSh0aGlzLGFyZ3VtZW50cyxmdW5jdGlvbihlKXt0aGlzLnBhcmVudE5vZGUmJnRoaXMucGFyZW50Tm9kZS5pbnNlcnRCZWZvcmUoZSx0aGlzLm5leHRTaWJsaW5nKX0pfSxlbXB0eTpmdW5jd
Glvbigpe2Zvcih2YXIgZSx0PTA7bnVsbCE9KGU9dGhpc1t0XSk7dCsrKTE9PT1lLm5vZGVUeXBlJiYoUy5jbGVhbkRhdGEodmUoZSwhMSkpLGUudGV4dENvbnRlbnQ9IiIpO3JldHVybiB0aGlzfSxjbG9uZTpmdW5jdGlvbihlLHQpe3JldHVybiBlPW51bGwhPWUmJmUsdD1udWxsPT10P2U6dCx0aGlzLm1hcChmdW5jdGlvbigpe3JldHVybiBTLmNsb25lKHRoaXMsZSx0KX0pfSxodG1sOmZ1bmN0aW9uKGUpe3JldHVybiAkKHRoaXMsZnVuY3Rpb24oZSl7dmFyIHQ9dGhpc1swXXx8e30sbj0wLHI9dGhpcy5sZW5ndGg7aWYodm9pZCAwPT09ZSYmMT09PXQubm9kZVR5cGUpcmV0dXJuIHQuaW5uZXJIVE1MO2lmKCJzdHJpbmciPT10eXBlb2YgZSYmIU5lLnRlc3QoZSkmJiFnZVsoZGUuZXhlYyhlKXx8WyIiLCIiXSlbMV0udG9Mb3dlckNhc2UoKV0pe2U
9Uy5odG1sUHJlZmlsdGVyKGUpO3RyeXtmb3IoO248cjtuKyspMT09PSh0PXRoaXNbbl18fHt9KS5ub2RlVHlwZSYmKFMuY2xlYW5EYXRhKHZlKHQsITEpKSx0LmlubmVySFRNTD1lKTt0PTB9Y2F0Y2goZSl7fX10JiZ0aGlzLmVtcHR5KCkuYXBwZW5kKGUpfSxudWxsLGUsYXJndW1lbnRzLmxlbmd0aCl9LHJlcGxhY2VXaXRoOmZ1bmN0aW9uKCl7dmFyIG49W107cmV0dXJuIFBlKHRoaXMsYXJndW1lbnRzLGZ1bmN0aW9uKGUpe3ZhciB0PXRoaXMucGFyZW50Tm9kZTtTLmluQXJyYXkodGhpcyxuKTwwJiYoUy5jbGVhbkRhdGEodmUodGhpcykpLHQmJnQucmVwbGFjZUNoaWxkKGUsdGhpcykpfSxuKX19KSxTLmVhY2goe2FwcGVuZFRvOiJhcHBlbmQiLHByZXBlbmRUbzoicHJlcGVuZCIsaW5zZXJ0QmVmb3JlOiJiZWZvcmUiLGluc2VydEFmdGVyOiJhZ
nRlciIscmVwbGFjZUFsbDoicmVwbGFjZVdpdGgifSxmdW5jdGlvbihlLGEpe1MuZm5bZV09ZnVuY3Rpb24oZSl7Zm9yKHZhciB0LG49W10scj1TKGUpLGk9ci5sZW5ndGgtMSxvPTA7bzw9aTtvKyspdD1vPT09aT90aGlzOnRoaXMuY2xvbmUoITApLFMocltvXSlbYV0odCksdS5hcHBseShuLHQuZ2V0KCkpO3JldHVybiB0aGlzLnB1c2hTdGFjayhuKX19KTt2YXIgTWU9bmV3IFJlZ0V4cCgiXigiK2VlKyIpKD8hcHgpW2EteiVdKyQiLCJpIiksSWU9ZnVuY3Rpb24oZSl7dmFyIHQ9ZS5vd25lckRvY3VtZW50LmRlZmF1bHRWaWV3O3JldHVybiB0JiZ0Lm9wZW5lcnx8KHQ9QyksdC5nZXRDb21wdXRlZFN0eWxlKGUpfSxXZT1mdW5jdGlvbihlLHQsbil7dmFyIHIsaSxvPXt9O2ZvcihpIGluIHQpb1tpXT1lLnN0eWxlW2ldLGUuc3R5bGVbaV09dFtpXTt
mb3IoaSBpbiByPW4uY2FsbChlKSx0KWUuc3R5bGVbaV09b1tpXTtyZXR1cm4gcn0sRmU9bmV3IFJlZ0V4cChuZS5qb2luKCJ8IiksImkiKTtmdW5jdGlvbiBCZShlLHQsbil7dmFyIHIsaSxvLGEscz1lLnN0eWxlO3JldHVybihuPW58fEllKGUpKSYmKCIiIT09KGE9bi5nZXRQcm9wZXJ0eVZhbHVlKHQpfHxuW3RdKXx8aWUoZSl8fChhPVMuc3R5bGUoZSx0KSksIXkucGl4ZWxCb3hTdHlsZXMoKSYmTWUudGVzdChhKSYmRmUudGVzdCh0KSYmKHI9cy53aWR0aCxpPXMubWluV2lkdGgsbz1zLm1heFdpZHRoLHMubWluV2lkdGg9cy5tYXhXaWR0aD1zLndpZHRoPWEsYT1uLndpZHRoLHMud2lkdGg9cixzLm1pbldpZHRoPWkscy5tYXhXaWR0aD1vKSksdm9pZCAwIT09YT9hKyIiOmF9ZnVuY3Rpb24gJGUoZSx0KXtyZXR1cm57Z2V0OmZ1bmN0aW9uKCl7a
WYoIWUoKSlyZXR1cm4odGhpcy5nZXQ9dCkuYXBwbHkodGhpcyxhcmd1bWVudHMpO2RlbGV0ZSB0aGlzLmdldH19fSFmdW5jdGlvbigpe2Z1bmN0aW9uIGUoKXtpZihsKXt1LnN0eWxlLmNzc1RleHQ9InBvc2l0aW9uOmFic29sdXRlO2xlZnQ6LTExMTExcHg7d2lkdGg6NjBweDttYXJnaW4tdG9wOjFweDtwYWRkaW5nOjA7Ym9yZGVyOjAiLGwuc3R5bGUuY3NzVGV4dD0icG9zaXRpb246cmVsYXRpdmU7ZGlzcGxheTpibG9jaztib3gtc2l6aW5nOmJvcmRlci1ib3g7b3ZlcmZsb3c6c2Nyb2xsO21hcmdpbjphdXRvO2JvcmRlcjoxcHg7cGFkZGluZzoxcHg7d2lkdGg6NjAlO3RvcDoxJSIscmUuYXBwZW5kQ2hpbGQodSkuYXBwZW5kQ2hpbGQobCk7dmFyIGU9Qy5nZXRDb21wdXRlZFN0eWxlKGwpO249IjElIiE9PWUudG9wLHM9MTI9PT10KGUubWFyZ2l
uTGVmdCksbC5zdHlsZS5yaWdodD0iNjAlIixvPTM2PT09dChlLnJpZ2h0KSxyPTM2PT09dChlLndpZHRoKSxsLnN0eWxlLnBvc2l0aW9uPSJhYnNvbHV0ZSIsaT0xMj09PXQobC5vZmZzZXRXaWR0aC8zKSxyZS5yZW1vdmVDaGlsZCh1KSxsPW51bGx9fWZ1bmN0aW9uIHQoZSl7cmV0dXJuIE1hdGgucm91bmQocGFyc2VGbG9hdChlKSl9dmFyIG4scixpLG8sYSxzLHU9RS5jcmVhdGVFbGVtZW50KCJkaXYiKSxsPUUuY3JlYXRlRWxlbWVudCgiZGl2Iik7bC5zdHlsZSYmKGwuc3R5bGUuYmFja2dyb3VuZENsaXA9ImNvbnRlbnQtYm94IixsLmNsb25lTm9kZSghMCkuc3R5bGUuYmFja2dyb3VuZENsaXA9IiIseS5jbGVhckNsb25lU3R5bGU9ImNvbnRlbnQtYm94Ij09PWwuc3R5bGUuYmFja2dyb3VuZENsaXAsUy5leHRlbmQoeSx7Ym94U2l6aW5nUmVsa
WFibGU6ZnVuY3Rpb24oKXtyZXR1cm4gZSgpLHJ9LHBpeGVsQm94U3R5bGVzOmZ1bmN0aW9uKCl7cmV0dXJuIGUoKSxvfSxwaXhlbFBvc2l0aW9uOmZ1bmN0aW9uKCl7cmV0dXJuIGUoKSxufSxyZWxpYWJsZU1hcmdpbkxlZnQ6ZnVuY3Rpb24oKXtyZXR1cm4gZSgpLHN9LHNjcm9sbGJveFNpemU6ZnVuY3Rpb24oKXtyZXR1cm4gZSgpLGl9LHJlbGlhYmxlVHJEaW1lbnNpb25zOmZ1bmN0aW9uKCl7dmFyIGUsdCxuLHI7cmV0dXJuIG51bGw9PWEmJihlPUUuY3JlYXRlRWxlbWVudCgidGFibGUiKSx0PUUuY3JlYXRlRWxlbWVudCgidHIiKSxuPUUuY3JlYXRlRWxlbWVudCgiZGl2IiksZS5zdHlsZS5jc3NUZXh0PSJwb3NpdGlvbjphYnNvbHV0ZTtsZWZ0Oi0xMTExMXB4Iix0LnN0eWxlLmhlaWdodD0iMXB4IixuLnN0eWxlLmhlaWdodD0iOXB4IixyZS5
hcHBlbmRDaGlsZChlKS5hcHBlbmRDaGlsZCh0KS5hcHBlbmRDaGlsZChuKSxyPUMuZ2V0Q29tcHV0ZWRTdHlsZSh0KSxhPTM8cGFyc2VJbnQoci5oZWlnaHQpLHJlLnJlbW92ZUNoaWxkKGUpKSxhfX0pKX0oKTt2YXIgX2U9WyJXZWJraXQiLCJNb3oiLCJtcyJdLHplPUUuY3JlYXRlRWxlbWVudCgiZGl2Iikuc3R5bGUsVWU9e307ZnVuY3Rpb24gWGUoZSl7dmFyIHQ9Uy5jc3NQcm9wc1tlXXx8VWVbZV07cmV0dXJuIHR8fChlIGluIHplP2U6VWVbZV09ZnVuY3Rpb24oZSl7dmFyIHQ9ZVswXS50b1VwcGVyQ2FzZSgpK2Uuc2xpY2UoMSksbj1fZS5sZW5ndGg7d2hpbGUobi0tKWlmKChlPV9lW25dK3QpaW4gemUpcmV0dXJuIGV9KGUpfHxlKX12YXIgVmU9L14obm9uZXx0YWJsZSg/IS1jW2VhXSkuKykvLEdlPS9eLS0vLFllPXtwb3NpdGlvbjoiYWJzb
2x1dGUiLHZpc2liaWxpdHk6ImhpZGRlbiIsZGlzcGxheToiYmxvY2sifSxRZT17bGV0dGVyU3BhY2luZzoiMCIsZm9udFdlaWdodDoiNDAwIn07ZnVuY3Rpb24gSmUoZSx0LG4pe3ZhciByPXRlLmV4ZWModCk7cmV0dXJuIHI/TWF0aC5tYXgoMCxyWzJdLShufHwwKSkrKHJbM118fCJweCIpOnR9ZnVuY3Rpb24gS2UoZSx0LG4scixpLG8pe3ZhciBhPSJ3aWR0aCI9PT10PzE6MCxzPTAsdT0wO2lmKG49PT0ocj8iYm9yZGVyIjoiY29udGVudCIpKXJldHVybiAwO2Zvcig7YTw0O2ErPTIpIm1hcmdpbiI9PT1uJiYodSs9Uy5jc3MoZSxuK25lW2FdLCEwLGkpKSxyPygiY29udGVudCI9PT1uJiYodS09Uy5jc3MoZSwicGFkZGluZyIrbmVbYV0sITAsaSkpLCJtYXJnaW4iIT09biYmKHUtPVMuY3NzKGUsImJvcmRlciIrbmVbYV0rIldpZHRoIiwhMCxpKSk
pOih1Kz1TLmNzcyhlLCJwYWRkaW5nIituZVthXSwhMCxpKSwicGFkZGluZyIhPT1uP3UrPVMuY3NzKGUsImJvcmRlciIrbmVbYV0rIldpZHRoIiwhMCxpKTpzKz1TLmNzcyhlLCJib3JkZXIiK25lW2FdKyJXaWR0aCIsITAsaSkpO3JldHVybiFyJiYwPD1vJiYodSs9TWF0aC5tYXgoMCxNYXRoLmNlaWwoZVsib2Zmc2V0Iit0WzBdLnRvVXBwZXJDYXNlKCkrdC5zbGljZSgxKV0tby11LXMtLjUpKXx8MCksdX1mdW5jdGlvbiBaZShlLHQsbil7dmFyIHI9SWUoZSksaT0oIXkuYm94U2l6aW5nUmVsaWFibGUoKXx8bikmJiJib3JkZXItYm94Ij09PVMuY3NzKGUsImJveFNpemluZyIsITEsciksbz1pLGE9QmUoZSx0LHIpLHM9Im9mZnNldCIrdFswXS50b1VwcGVyQ2FzZSgpK3Quc2xpY2UoMSk7aWYoTWUudGVzdChhKSl7aWYoIW4pcmV0dXJuIGE7YT0iY
XV0byJ9cmV0dXJuKCF5LmJveFNpemluZ1JlbGlhYmxlKCkmJml8fCF5LnJlbGlhYmxlVHJEaW1lbnNpb25zKCkmJkEoZSwidHIiKXx8ImF1dG8iPT09YXx8IXBhcnNlRmxvYXQoYSkmJiJpbmxpbmUiPT09Uy5jc3MoZSwiZGlzcGxheSIsITEscikpJiZlLmdldENsaWVudFJlY3RzKCkubGVuZ3RoJiYoaT0iYm9yZGVyLWJveCI9PT1TLmNzcyhlLCJib3hTaXppbmciLCExLHIpLChvPXMgaW4gZSkmJihhPWVbc10pKSwoYT1wYXJzZUZsb2F0KGEpfHwwKStLZShlLHQsbnx8KGk/ImJvcmRlciI6ImNvbnRlbnQiKSxvLHIsYSkrInB4In1mdW5jdGlvbiBldChlLHQsbixyLGkpe3JldHVybiBuZXcgZXQucHJvdG90eXBlLmluaXQoZSx0LG4scixpKX1TLmV4dGVuZCh7Y3NzSG9va3M6e29wYWNpdHk6e2dldDpmdW5jdGlvbihlLHQpe2lmKHQpe3ZhciBuPUJ
lKGUsIm9wYWNpdHkiKTtyZXR1cm4iIj09PW4/IjEiOm59fX19LGNzc051bWJlcjp7YW5pbWF0aW9uSXRlcmF0aW9uQ291bnQ6ITAsY29sdW1uQ291bnQ6ITAsZmlsbE9wYWNpdHk6ITAsZmxleEdyb3c6ITAsZmxleFNocmluazohMCxmb250V2VpZ2h0OiEwLGdyaWRBcmVhOiEwLGdyaWRDb2x1bW46ITAsZ3JpZENvbHVtbkVuZDohMCxncmlkQ29sdW1uU3RhcnQ6ITAsZ3JpZFJvdzohMCxncmlkUm93RW5kOiEwLGdyaWRSb3dTdGFydDohMCxsaW5lSGVpZ2h0OiEwLG9wYWNpdHk6ITAsb3JkZXI6ITAsb3JwaGFuczohMCx3aWRvd3M6ITAsekluZGV4OiEwLHpvb206ITB9LGNzc1Byb3BzOnt9LHN0eWxlOmZ1bmN0aW9uKGUsdCxuLHIpe2lmKGUmJjMhPT1lLm5vZGVUeXBlJiY4IT09ZS5ub2RlVHlwZSYmZS5zdHlsZSl7dmFyIGksbyxhLHM9WCh0KSx1P
UdlLnRlc3QodCksbD1lLnN0eWxlO2lmKHV8fCh0PVhlKHMpKSxhPVMuY3NzSG9va3NbdF18fFMuY3NzSG9va3Nbc10sdm9pZCAwPT09bilyZXR1cm4gYSYmImdldCJpbiBhJiZ2b2lkIDAhPT0oaT1hLmdldChlLCExLHIpKT9pOmxbdF07InN0cmluZyI9PT0obz10eXBlb2YgbikmJihpPXRlLmV4ZWMobikpJiZpWzFdJiYobj1zZShlLHQsaSksbz0ibnVtYmVyIiksbnVsbCE9biYmbj09biYmKCJudW1iZXIiIT09b3x8dXx8KG4rPWkmJmlbM118fChTLmNzc051bWJlcltzXT8iIjoicHgiKSkseS5jbGVhckNsb25lU3R5bGV8fCIiIT09bnx8MCE9PXQuaW5kZXhPZigiYmFja2dyb3VuZCIpfHwobFt0XT0iaW5oZXJpdCIpLGEmJiJzZXQiaW4gYSYmdm9pZCAwPT09KG49YS5zZXQoZSxuLHIpKXx8KHU/bC5zZXRQcm9wZXJ0eSh0LG4pOmxbdF09bikpfX0
sY3NzOmZ1bmN0aW9uKGUsdCxuLHIpe3ZhciBpLG8sYSxzPVgodCk7cmV0dXJuIEdlLnRlc3QodCl8fCh0PVhlKHMpKSwoYT1TLmNzc0hvb2tzW3RdfHxTLmNzc0hvb2tzW3NdKSYmImdldCJpbiBhJiYoaT1hLmdldChlLCEwLG4pKSx2b2lkIDA9PT1pJiYoaT1CZShlLHQscikpLCJub3JtYWwiPT09aSYmdCBpbiBRZSYmKGk9UWVbdF0pLCIiPT09bnx8bj8obz1wYXJzZUZsb2F0KGkpLCEwPT09bnx8aXNGaW5pdGUobyk/b3x8MDppKTppfX0pLFMuZWFjaChbImhlaWdodCIsIndpZHRoIl0sZnVuY3Rpb24oZSx1KXtTLmNzc0hvb2tzW3VdPXtnZXQ6ZnVuY3Rpb24oZSx0LG4pe2lmKHQpcmV0dXJuIVZlLnRlc3QoUy5jc3MoZSwiZGlzcGxheSIpKXx8ZS5nZXRDbGllbnRSZWN0cygpLmxlbmd0aCYmZS5nZXRCb3VuZGluZ0NsaWVudFJlY3QoKS53aWR0a
D9aZShlLHUsbik6V2UoZSxZZSxmdW5jdGlvbigpe3JldHVybiBaZShlLHUsbil9KX0sc2V0OmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpPUllKGUpLG89IXkuc2Nyb2xsYm94U2l6ZSgpJiYiYWJzb2x1dGUiPT09aS5wb3NpdGlvbixhPShvfHxuKSYmImJvcmRlci1ib3giPT09Uy5jc3MoZSwiYm94U2l6aW5nIiwhMSxpKSxzPW4/S2UoZSx1LG4sYSxpKTowO3JldHVybiBhJiZvJiYocy09TWF0aC5jZWlsKGVbIm9mZnNldCIrdVswXS50b1VwcGVyQ2FzZSgpK3Uuc2xpY2UoMSldLXBhcnNlRmxvYXQoaVt1XSktS2UoZSx1LCJib3JkZXIiLCExLGkpLS41KSkscyYmKHI9dGUuZXhlYyh0KSkmJiJweCIhPT0oclszXXx8InB4IikmJihlLnN0eWxlW3VdPXQsdD1TLmNzcyhlLHUpKSxKZSgwLHQscyl9fX0pLFMuY3NzSG9va3MubWFyZ2luTGVmdD0kZSh5LnJ
lbGlhYmxlTWFyZ2luTGVmdCxmdW5jdGlvbihlLHQpe2lmKHQpcmV0dXJuKHBhcnNlRmxvYXQoQmUoZSwibWFyZ2luTGVmdCIpKXx8ZS5nZXRCb3VuZGluZ0NsaWVudFJlY3QoKS5sZWZ0LVdlKGUse21hcmdpbkxlZnQ6MH0sZnVuY3Rpb24oKXtyZXR1cm4gZS5nZXRCb3VuZGluZ0NsaWVudFJlY3QoKS5sZWZ0fSkpKyJweCJ9KSxTLmVhY2goe21hcmdpbjoiIixwYWRkaW5nOiIiLGJvcmRlcjoiV2lkdGgifSxmdW5jdGlvbihpLG8pe1MuY3NzSG9va3NbaStvXT17ZXhwYW5kOmZ1bmN0aW9uKGUpe2Zvcih2YXIgdD0wLG49e30scj0ic3RyaW5nIj09dHlwZW9mIGU/ZS5zcGxpdCgiICIpOltlXTt0PDQ7dCsrKW5baStuZVt0XStvXT1yW3RdfHxyW3QtMl18fHJbMF07cmV0dXJuIG59fSwibWFyZ2luIiE9PWkmJihTLmNzc0hvb2tzW2krb10uc2V0PUplK
X0pLFMuZm4uZXh0ZW5kKHtjc3M6ZnVuY3Rpb24oZSx0KXtyZXR1cm4gJCh0aGlzLGZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG89e30sYT0wO2lmKEFycmF5LmlzQXJyYXkodCkpe2ZvcihyPUllKGUpLGk9dC5sZW5ndGg7YTxpO2ErKylvW3RbYV1dPVMuY3NzKGUsdFthXSwhMSxyKTtyZXR1cm4gb31yZXR1cm4gdm9pZCAwIT09bj9TLnN0eWxlKGUsdCxuKTpTLmNzcyhlLHQpfSxlLHQsMTxhcmd1bWVudHMubGVuZ3RoKX19KSwoKFMuVHdlZW49ZXQpLnByb3RvdHlwZT17Y29uc3RydWN0b3I6ZXQsaW5pdDpmdW5jdGlvbihlLHQsbixyLGksbyl7dGhpcy5lbGVtPWUsdGhpcy5wcm9wPW4sdGhpcy5lYXNpbmc9aXx8Uy5lYXNpbmcuX2RlZmF1bHQsdGhpcy5vcHRpb25zPXQsdGhpcy5zdGFydD10aGlzLm5vdz10aGlzLmN1cigpLHRoaXMuZW5kPXIsdGh
pcy51bml0PW98fChTLmNzc051bWJlcltuXT8iIjoicHgiKX0sY3VyOmZ1bmN0aW9uKCl7dmFyIGU9ZXQucHJvcEhvb2tzW3RoaXMucHJvcF07cmV0dXJuIGUmJmUuZ2V0P2UuZ2V0KHRoaXMpOmV0LnByb3BIb29rcy5fZGVmYXVsdC5nZXQodGhpcyl9LHJ1bjpmdW5jdGlvbihlKXt2YXIgdCxuPWV0LnByb3BIb29rc1t0aGlzLnByb3BdO3JldHVybiB0aGlzLm9wdGlvbnMuZHVyYXRpb24/dGhpcy5wb3M9dD1TLmVhc2luZ1t0aGlzLmVhc2luZ10oZSx0aGlzLm9wdGlvbnMuZHVyYXRpb24qZSwwLDEsdGhpcy5vcHRpb25zLmR1cmF0aW9uKTp0aGlzLnBvcz10PWUsdGhpcy5ub3c9KHRoaXMuZW5kLXRoaXMuc3RhcnQpKnQrdGhpcy5zdGFydCx0aGlzLm9wdGlvbnMuc3RlcCYmdGhpcy5vcHRpb25zLnN0ZXAuY2FsbCh0aGlzLmVsZW0sdGhpcy5ub3csd
GhpcyksbiYmbi5zZXQ/bi5zZXQodGhpcyk6ZXQucHJvcEhvb2tzLl9kZWZhdWx0LnNldCh0aGlzKSx0aGlzfX0pLmluaXQucHJvdG90eXBlPWV0LnByb3RvdHlwZSwoZXQucHJvcEhvb2tzPXtfZGVmYXVsdDp7Z2V0OmZ1bmN0aW9uKGUpe3ZhciB0O3JldHVybiAxIT09ZS5lbGVtLm5vZGVUeXBlfHxudWxsIT1lLmVsZW1bZS5wcm9wXSYmbnVsbD09ZS5lbGVtLnN0eWxlW2UucHJvcF0/ZS5lbGVtW2UucHJvcF06KHQ9Uy5jc3MoZS5lbGVtLGUucHJvcCwiIikpJiYiYXV0byIhPT10P3Q6MH0sc2V0OmZ1bmN0aW9uKGUpe1MuZnguc3RlcFtlLnByb3BdP1MuZnguc3RlcFtlLnByb3BdKGUpOjEhPT1lLmVsZW0ubm9kZVR5cGV8fCFTLmNzc0hvb2tzW2UucHJvcF0mJm51bGw9PWUuZWxlbS5zdHlsZVtYZShlLnByb3ApXT9lLmVsZW1bZS5wcm9wXT1lLm5
vdzpTLnN0eWxlKGUuZWxlbSxlLnByb3AsZS5ub3crZS51bml0KX19fSkuc2Nyb2xsVG9wPWV0LnByb3BIb29rcy5zY3JvbGxMZWZ0PXtzZXQ6ZnVuY3Rpb24oZSl7ZS5lbGVtLm5vZGVUeXBlJiZlLmVsZW0ucGFyZW50Tm9kZSYmKGUuZWxlbVtlLnByb3BdPWUubm93KX19LFMuZWFzaW5nPXtsaW5lYXI6ZnVuY3Rpb24oZSl7cmV0dXJuIGV9LHN3aW5nOmZ1bmN0aW9uKGUpe3JldHVybi41LU1hdGguY29zKGUqTWF0aC5QSSkvMn0sX2RlZmF1bHQ6InN3aW5nIn0sUy5meD1ldC5wcm90b3R5cGUuaW5pdCxTLmZ4LnN0ZXA9e307dmFyIHR0LG50LHJ0LGl0LG90PS9eKD86dG9nZ2xlfHNob3d8aGlkZSkkLyxhdD0vcXVldWVIb29rcyQvO2Z1bmN0aW9uIHN0KCl7bnQmJighMT09PUUuaGlkZGVuJiZDLnJlcXVlc3RBbmltYXRpb25GcmFtZT9DLnJlcXVlc
3RBbmltYXRpb25GcmFtZShzdCk6Qy5zZXRUaW1lb3V0KHN0LFMuZnguaW50ZXJ2YWwpLFMuZngudGljaygpKX1mdW5jdGlvbiB1dCgpe3JldHVybiBDLnNldFRpbWVvdXQoZnVuY3Rpb24oKXt0dD12b2lkIDB9KSx0dD1EYXRlLm5vdygpfWZ1bmN0aW9uIGx0KGUsdCl7dmFyIG4scj0wLGk9e2hlaWdodDplfTtmb3IodD10PzE6MDtyPDQ7cis9Mi10KWlbIm1hcmdpbiIrKG49bmVbcl0pXT1pWyJwYWRkaW5nIituXT1lO3JldHVybiB0JiYoaS5vcGFjaXR5PWkud2lkdGg9ZSksaX1mdW5jdGlvbiBjdChlLHQsbil7Zm9yKHZhciByLGk9KGZ0LnR3ZWVuZXJzW3RdfHxbXSkuY29uY2F0KGZ0LnR3ZWVuZXJzWyIqIl0pLG89MCxhPWkubGVuZ3RoO288YTtvKyspaWYocj1pW29dLmNhbGwobix0LGUpKXJldHVybiByfWZ1bmN0aW9uIGZ0KG8sZSx0KXt2YXI
gbixhLHI9MCxpPWZ0LnByZWZpbHRlcnMubGVuZ3RoLHM9Uy5EZWZlcnJlZCgpLmFsd2F5cyhmdW5jdGlvbigpe2RlbGV0ZSB1LmVsZW19KSx1PWZ1bmN0aW9uKCl7aWYoYSlyZXR1cm4hMTtmb3IodmFyIGU9dHR8fHV0KCksdD1NYXRoLm1heCgwLGwuc3RhcnRUaW1lK2wuZHVyYXRpb24tZSksbj0xLSh0L2wuZHVyYXRpb258fDApLHI9MCxpPWwudHdlZW5zLmxlbmd0aDtyPGk7cisrKWwudHdlZW5zW3JdLnJ1bihuKTtyZXR1cm4gcy5ub3RpZnlXaXRoKG8sW2wsbix0XSksbjwxJiZpP3Q6KGl8fHMubm90aWZ5V2l0aChvLFtsLDEsMF0pLHMucmVzb2x2ZVdpdGgobyxbbF0pLCExKX0sbD1zLnByb21pc2Uoe2VsZW06byxwcm9wczpTLmV4dGVuZCh7fSxlKSxvcHRzOlMuZXh0ZW5kKCEwLHtzcGVjaWFsRWFzaW5nOnt9LGVhc2luZzpTLmVhc2luZy5fZ
GVmYXVsdH0sdCksb3JpZ2luYWxQcm9wZXJ0aWVzOmUsb3JpZ2luYWxPcHRpb25zOnQsc3RhcnRUaW1lOnR0fHx1dCgpLGR1cmF0aW9uOnQuZHVyYXRpb24sdHdlZW5zOltdLGNyZWF0ZVR3ZWVuOmZ1bmN0aW9uKGUsdCl7dmFyIG49Uy5Ud2VlbihvLGwub3B0cyxlLHQsbC5vcHRzLnNwZWNpYWxFYXNpbmdbZV18fGwub3B0cy5lYXNpbmcpO3JldHVybiBsLnR3ZWVucy5wdXNoKG4pLG59LHN0b3A6ZnVuY3Rpb24oZSl7dmFyIHQ9MCxuPWU/bC50d2VlbnMubGVuZ3RoOjA7aWYoYSlyZXR1cm4gdGhpcztmb3IoYT0hMDt0PG47dCsrKWwudHdlZW5zW3RdLnJ1bigxKTtyZXR1cm4gZT8ocy5ub3RpZnlXaXRoKG8sW2wsMSwwXSkscy5yZXNvbHZlV2l0aChvLFtsLGVdKSk6cy5yZWplY3RXaXRoKG8sW2wsZV0pLHRoaXN9fSksYz1sLnByb3BzO2ZvcighZnV
uY3Rpb24oZSx0KXt2YXIgbixyLGksbyxhO2ZvcihuIGluIGUpaWYoaT10W3I9WChuKV0sbz1lW25dLEFycmF5LmlzQXJyYXkobykmJihpPW9bMV0sbz1lW25dPW9bMF0pLG4hPT1yJiYoZVtyXT1vLGRlbGV0ZSBlW25dKSwoYT1TLmNzc0hvb2tzW3JdKSYmImV4cGFuZCJpbiBhKWZvcihuIGluIG89YS5leHBhbmQobyksZGVsZXRlIGVbcl0sbyluIGluIGV8fChlW25dPW9bbl0sdFtuXT1pKTtlbHNlIHRbcl09aX0oYyxsLm9wdHMuc3BlY2lhbEVhc2luZyk7cjxpO3IrKylpZihuPWZ0LnByZWZpbHRlcnNbcl0uY2FsbChsLG8sYyxsLm9wdHMpKXJldHVybiBtKG4uc3RvcCkmJihTLl9xdWV1ZUhvb2tzKGwuZWxlbSxsLm9wdHMucXVldWUpLnN0b3A9bi5zdG9wLmJpbmQobikpLG47cmV0dXJuIFMubWFwKGMsY3QsbCksbShsLm9wdHMuc3RhcnQpJiZsL
m9wdHMuc3RhcnQuY2FsbChvLGwpLGwucHJvZ3Jlc3MobC5vcHRzLnByb2dyZXNzKS5kb25lKGwub3B0cy5kb25lLGwub3B0cy5jb21wbGV0ZSkuZmFpbChsLm9wdHMuZmFpbCkuYWx3YXlzKGwub3B0cy5hbHdheXMpLFMuZngudGltZXIoUy5leHRlbmQodSx7ZWxlbTpvLGFuaW06bCxxdWV1ZTpsLm9wdHMucXVldWV9KSksbH1TLkFuaW1hdGlvbj1TLmV4dGVuZChmdCx7dHdlZW5lcnM6eyIqIjpbZnVuY3Rpb24oZSx0KXt2YXIgbj10aGlzLmNyZWF0ZVR3ZWVuKGUsdCk7cmV0dXJuIHNlKG4uZWxlbSxlLHRlLmV4ZWModCksbiksbn1dfSx0d2VlbmVyOmZ1bmN0aW9uKGUsdCl7bShlKT8odD1lLGU9WyIqIl0pOmU9ZS5tYXRjaChQKTtmb3IodmFyIG4scj0wLGk9ZS5sZW5ndGg7cjxpO3IrKyluPWVbcl0sZnQudHdlZW5lcnNbbl09ZnQudHdlZW5lcnN
bbl18fFtdLGZ0LnR3ZWVuZXJzW25dLnVuc2hpZnQodCl9LHByZWZpbHRlcnM6W2Z1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG8sYSxzLHUsbCxjLGY9IndpZHRoImluIHR8fCJoZWlnaHQiaW4gdCxwPXRoaXMsZD17fSxoPWUuc3R5bGUsZz1lLm5vZGVUeXBlJiZhZShlKSx2PVkuZ2V0KGUsImZ4c2hvdyIpO2ZvcihyIGluIG4ucXVldWV8fChudWxsPT0oYT1TLl9xdWV1ZUhvb2tzKGUsImZ4IikpLnVucXVldWVkJiYoYS51bnF1ZXVlZD0wLHM9YS5lbXB0eS5maXJlLGEuZW1wdHkuZmlyZT1mdW5jdGlvbigpe2EudW5xdWV1ZWR8fHMoKX0pLGEudW5xdWV1ZWQrKyxwLmFsd2F5cyhmdW5jdGlvbigpe3AuYWx3YXlzKGZ1bmN0aW9uKCl7YS51bnF1ZXVlZC0tLFMucXVldWUoZSwiZngiKS5sZW5ndGh8fGEuZW1wdHkuZmlyZSgpfSl9KSksdClpZihpPXRbc
l0sb3QudGVzdChpKSl7aWYoZGVsZXRlIHRbcl0sbz1vfHwidG9nZ2xlIj09PWksaT09PShnPyJoaWRlIjoic2hvdyIpKXtpZigic2hvdyIhPT1pfHwhdnx8dm9pZCAwPT09dltyXSljb250aW51ZTtnPSEwfWRbcl09diYmdltyXXx8Uy5zdHlsZShlLHIpfWlmKCh1PSFTLmlzRW1wdHlPYmplY3QodCkpfHwhUy5pc0VtcHR5T2JqZWN0KGQpKWZvcihyIGluIGYmJjE9PT1lLm5vZGVUeXBlJiYobi5vdmVyZmxvdz1baC5vdmVyZmxvdyxoLm92ZXJmbG93WCxoLm92ZXJmbG93WV0sbnVsbD09KGw9diYmdi5kaXNwbGF5KSYmKGw9WS5nZXQoZSwiZGlzcGxheSIpKSwibm9uZSI9PT0oYz1TLmNzcyhlLCJkaXNwbGF5IikpJiYobD9jPWw6KGxlKFtlXSwhMCksbD1lLnN0eWxlLmRpc3BsYXl8fGwsYz1TLmNzcyhlLCJkaXNwbGF5IiksbGUoW2VdKSkpLCgiaW5
saW5lIj09PWN8fCJpbmxpbmUtYmxvY2siPT09YyYmbnVsbCE9bCkmJiJub25lIj09PVMuY3NzKGUsImZsb2F0IikmJih1fHwocC5kb25lKGZ1bmN0aW9uKCl7aC5kaXNwbGF5PWx9KSxudWxsPT1sJiYoYz1oLmRpc3BsYXksbD0ibm9uZSI9PT1jPyIiOmMpKSxoLmRpc3BsYXk9ImlubGluZS1ibG9jayIpKSxuLm92ZXJmbG93JiYoaC5vdmVyZmxvdz0iaGlkZGVuIixwLmFsd2F5cyhmdW5jdGlvbigpe2gub3ZlcmZsb3c9bi5vdmVyZmxvd1swXSxoLm92ZXJmbG93WD1uLm92ZXJmbG93WzFdLGgub3ZlcmZsb3dZPW4ub3ZlcmZsb3dbMl19KSksdT0hMSxkKXV8fCh2PyJoaWRkZW4iaW4gdiYmKGc9di5oaWRkZW4pOnY9WS5hY2Nlc3MoZSwiZnhzaG93Iix7ZGlzcGxheTpsfSksbyYmKHYuaGlkZGVuPSFnKSxnJiZsZShbZV0sITApLHAuZG9uZShmdW5jd
Glvbigpe2ZvcihyIGluIGd8fGxlKFtlXSksWS5yZW1vdmUoZSwiZnhzaG93IiksZClTLnN0eWxlKGUscixkW3JdKX0pKSx1PWN0KGc/dltyXTowLHIscCksciBpbiB2fHwodltyXT11LnN0YXJ0LGcmJih1LmVuZD11LnN0YXJ0LHUuc3RhcnQ9MCkpfV0scHJlZmlsdGVyOmZ1bmN0aW9uKGUsdCl7dD9mdC5wcmVmaWx0ZXJzLnVuc2hpZnQoZSk6ZnQucHJlZmlsdGVycy5wdXNoKGUpfX0pLFMuc3BlZWQ9ZnVuY3Rpb24oZSx0LG4pe3ZhciByPWUmJiJvYmplY3QiPT10eXBlb2YgZT9TLmV4dGVuZCh7fSxlKTp7Y29tcGxldGU6bnx8IW4mJnR8fG0oZSkmJmUsZHVyYXRpb246ZSxlYXNpbmc6biYmdHx8dCYmIW0odCkmJnR9O3JldHVybiBTLmZ4Lm9mZj9yLmR1cmF0aW9uPTA6Im51bWJlciIhPXR5cGVvZiByLmR1cmF0aW9uJiYoci5kdXJhdGlvbiBpbiB
TLmZ4LnNwZWVkcz9yLmR1cmF0aW9uPVMuZnguc3BlZWRzW3IuZHVyYXRpb25dOnIuZHVyYXRpb249Uy5meC5zcGVlZHMuX2RlZmF1bHQpLG51bGwhPXIucXVldWUmJiEwIT09ci5xdWV1ZXx8KHIucXVldWU9ImZ4Iiksci5vbGQ9ci5jb21wbGV0ZSxyLmNvbXBsZXRlPWZ1bmN0aW9uKCl7bShyLm9sZCkmJnIub2xkLmNhbGwodGhpcyksci5xdWV1ZSYmUy5kZXF1ZXVlKHRoaXMsci5xdWV1ZSl9LHJ9LFMuZm4uZXh0ZW5kKHtmYWRlVG86ZnVuY3Rpb24oZSx0LG4scil7cmV0dXJuIHRoaXMuZmlsdGVyKGFlKS5jc3MoIm9wYWNpdHkiLDApLnNob3coKS5lbmQoKS5hbmltYXRlKHtvcGFjaXR5OnR9LGUsbixyKX0sYW5pbWF0ZTpmdW5jdGlvbih0LGUsbixyKXt2YXIgaT1TLmlzRW1wdHlPYmplY3QodCksbz1TLnNwZWVkKGUsbixyKSxhPWZ1bmN0aW9uK
Cl7dmFyIGU9ZnQodGhpcyxTLmV4dGVuZCh7fSx0KSxvKTsoaXx8WS5nZXQodGhpcywiZmluaXNoIikpJiZlLnN0b3AoITApfTtyZXR1cm4gYS5maW5pc2g9YSxpfHwhMT09PW8ucXVldWU/dGhpcy5lYWNoKGEpOnRoaXMucXVldWUoby5xdWV1ZSxhKX0sc3RvcDpmdW5jdGlvbihpLGUsbyl7dmFyIGE9ZnVuY3Rpb24oZSl7dmFyIHQ9ZS5zdG9wO2RlbGV0ZSBlLnN0b3AsdChvKX07cmV0dXJuInN0cmluZyIhPXR5cGVvZiBpJiYobz1lLGU9aSxpPXZvaWQgMCksZSYmdGhpcy5xdWV1ZShpfHwiZngiLFtdKSx0aGlzLmVhY2goZnVuY3Rpb24oKXt2YXIgZT0hMCx0PW51bGwhPWkmJmkrInF1ZXVlSG9va3MiLG49Uy50aW1lcnMscj1ZLmdldCh0aGlzKTtpZih0KXJbdF0mJnJbdF0uc3RvcCYmYShyW3RdKTtlbHNlIGZvcih0IGluIHIpclt0XSYmclt0XS5
zdG9wJiZhdC50ZXN0KHQpJiZhKHJbdF0pO2Zvcih0PW4ubGVuZ3RoO3QtLTspblt0XS5lbGVtIT09dGhpc3x8bnVsbCE9aSYmblt0XS5xdWV1ZSE9PWl8fChuW3RdLmFuaW0uc3RvcChvKSxlPSExLG4uc3BsaWNlKHQsMSkpOyFlJiZvfHxTLmRlcXVldWUodGhpcyxpKX0pfSxmaW5pc2g6ZnVuY3Rpb24oYSl7cmV0dXJuITEhPT1hJiYoYT1hfHwiZngiKSx0aGlzLmVhY2goZnVuY3Rpb24oKXt2YXIgZSx0PVkuZ2V0KHRoaXMpLG49dFthKyJxdWV1ZSJdLHI9dFthKyJxdWV1ZUhvb2tzIl0saT1TLnRpbWVycyxvPW4/bi5sZW5ndGg6MDtmb3IodC5maW5pc2g9ITAsUy5xdWV1ZSh0aGlzLGEsW10pLHImJnIuc3RvcCYmci5zdG9wLmNhbGwodGhpcywhMCksZT1pLmxlbmd0aDtlLS07KWlbZV0uZWxlbT09PXRoaXMmJmlbZV0ucXVldWU9PT1hJiYoaVtlX
S5hbmltLnN0b3AoITApLGkuc3BsaWNlKGUsMSkpO2ZvcihlPTA7ZTxvO2UrKyluW2VdJiZuW2VdLmZpbmlzaCYmbltlXS5maW5pc2guY2FsbCh0aGlzKTtkZWxldGUgdC5maW5pc2h9KX19KSxTLmVhY2goWyJ0b2dnbGUiLCJzaG93IiwiaGlkZSJdLGZ1bmN0aW9uKGUscil7dmFyIGk9Uy5mbltyXTtTLmZuW3JdPWZ1bmN0aW9uKGUsdCxuKXtyZXR1cm4gbnVsbD09ZXx8ImJvb2xlYW4iPT10eXBlb2YgZT9pLmFwcGx5KHRoaXMsYXJndW1lbnRzKTp0aGlzLmFuaW1hdGUobHQociwhMCksZSx0LG4pfX0pLFMuZWFjaCh7c2xpZGVEb3duOmx0KCJzaG93Iiksc2xpZGVVcDpsdCgiaGlkZSIpLHNsaWRlVG9nZ2xlOmx0KCJ0b2dnbGUiKSxmYWRlSW46e29wYWNpdHk6InNob3cifSxmYWRlT3V0OntvcGFjaXR5OiJoaWRlIn0sZmFkZVRvZ2dsZTp7b3BhY2l
0eToidG9nZ2xlIn19LGZ1bmN0aW9uKGUscil7Uy5mbltlXT1mdW5jdGlvbihlLHQsbil7cmV0dXJuIHRoaXMuYW5pbWF0ZShyLGUsdCxuKX19KSxTLnRpbWVycz1bXSxTLmZ4LnRpY2s9ZnVuY3Rpb24oKXt2YXIgZSx0PTAsbj1TLnRpbWVycztmb3IodHQ9RGF0ZS5ub3coKTt0PG4ubGVuZ3RoO3QrKykoZT1uW3RdKSgpfHxuW3RdIT09ZXx8bi5zcGxpY2UodC0tLDEpO24ubGVuZ3RofHxTLmZ4LnN0b3AoKSx0dD12b2lkIDB9LFMuZngudGltZXI9ZnVuY3Rpb24oZSl7Uy50aW1lcnMucHVzaChlKSxTLmZ4LnN0YXJ0KCl9LFMuZnguaW50ZXJ2YWw9MTMsUy5meC5zdGFydD1mdW5jdGlvbigpe250fHwobnQ9ITAsc3QoKSl9LFMuZnguc3RvcD1mdW5jdGlvbigpe250PW51bGx9LFMuZnguc3BlZWRzPXtzbG93OjYwMCxmYXN0OjIwMCxfZGVmYXVsdDo0M
DB9LFMuZm4uZGVsYXk9ZnVuY3Rpb24ocixlKXtyZXR1cm4gcj1TLmZ4JiZTLmZ4LnNwZWVkc1tyXXx8cixlPWV8fCJmeCIsdGhpcy5xdWV1ZShlLGZ1bmN0aW9uKGUsdCl7dmFyIG49Qy5zZXRUaW1lb3V0KGUscik7dC5zdG9wPWZ1bmN0aW9uKCl7Qy5jbGVhclRpbWVvdXQobil9fSl9LHJ0PUUuY3JlYXRlRWxlbWVudCgiaW5wdXQiKSxpdD1FLmNyZWF0ZUVsZW1lbnQoInNlbGVjdCIpLmFwcGVuZENoaWxkKEUuY3JlYXRlRWxlbWVudCgib3B0aW9uIikpLHJ0LnR5cGU9ImNoZWNrYm94Iix5LmNoZWNrT249IiIhPT1ydC52YWx1ZSx5Lm9wdFNlbGVjdGVkPWl0LnNlbGVjdGVkLChydD1FLmNyZWF0ZUVsZW1lbnQoImlucHV0IikpLnZhbHVlPSJ0IixydC50eXBlPSJyYWRpbyIseS5yYWRpb1ZhbHVlPSJ0Ij09PXJ0LnZhbHVlO3ZhciBwdCxkdD1TLmV
4cHIuYXR0ckhhbmRsZTtTLmZuLmV4dGVuZCh7YXR0cjpmdW5jdGlvbihlLHQpe3JldHVybiAkKHRoaXMsUy5hdHRyLGUsdCwxPGFyZ3VtZW50cy5sZW5ndGgpfSxyZW1vdmVBdHRyOmZ1bmN0aW9uKGUpe3JldHVybiB0aGlzLmVhY2goZnVuY3Rpb24oKXtTLnJlbW92ZUF0dHIodGhpcyxlKX0pfX0pLFMuZXh0ZW5kKHthdHRyOmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG89ZS5ub2RlVHlwZTtpZigzIT09byYmOCE9PW8mJjIhPT1vKXJldHVybiJ1bmRlZmluZWQiPT10eXBlb2YgZS5nZXRBdHRyaWJ1dGU/Uy5wcm9wKGUsdCxuKTooMT09PW8mJlMuaXNYTUxEb2MoZSl8fChpPVMuYXR0ckhvb2tzW3QudG9Mb3dlckNhc2UoKV18fChTLmV4cHIubWF0Y2guYm9vbC50ZXN0KHQpP3B0OnZvaWQgMCkpLHZvaWQgMCE9PW4/bnVsbD09PW4/dm9pZCBTLnJlb
W92ZUF0dHIoZSx0KTppJiYic2V0ImluIGkmJnZvaWQgMCE9PShyPWkuc2V0KGUsbix0KSk/cjooZS5zZXRBdHRyaWJ1dGUodCxuKyIiKSxuKTppJiYiZ2V0ImluIGkmJm51bGwhPT0ocj1pLmdldChlLHQpKT9yOm51bGw9PShyPVMuZmluZC5hdHRyKGUsdCkpP3ZvaWQgMDpyKX0sYXR0ckhvb2tzOnt0eXBlOntzZXQ6ZnVuY3Rpb24oZSx0KXtpZigheS5yYWRpb1ZhbHVlJiYicmFkaW8iPT09dCYmQShlLCJpbnB1dCIpKXt2YXIgbj1lLnZhbHVlO3JldHVybiBlLnNldEF0dHJpYnV0ZSgidHlwZSIsdCksbiYmKGUudmFsdWU9biksdH19fX0scmVtb3ZlQXR0cjpmdW5jdGlvbihlLHQpe3ZhciBuLHI9MCxpPXQmJnQubWF0Y2goUCk7aWYoaSYmMT09PWUubm9kZVR5cGUpd2hpbGUobj1pW3IrK10pZS5yZW1vdmVBdHRyaWJ1dGUobil9fSkscHQ9e3NldDp
mdW5jdGlvbihlLHQsbil7cmV0dXJuITE9PT10P1MucmVtb3ZlQXR0cihlLG4pOmUuc2V0QXR0cmlidXRlKG4sbiksbn19LFMuZWFjaChTLmV4cHIubWF0Y2guYm9vbC5zb3VyY2UubWF0Y2goL1x3Ky9nKSxmdW5jdGlvbihlLHQpe3ZhciBhPWR0W3RdfHxTLmZpbmQuYXR0cjtkdFt0XT1mdW5jdGlvbihlLHQsbil7dmFyIHIsaSxvPXQudG9Mb3dlckNhc2UoKTtyZXR1cm4gbnx8KGk9ZHRbb10sZHRbb109cixyPW51bGwhPWEoZSx0LG4pP286bnVsbCxkdFtvXT1pKSxyfX0pO3ZhciBodD0vXig/OmlucHV0fHNlbGVjdHx0ZXh0YXJlYXxidXR0b24pJC9pLGd0PS9eKD86YXxhcmVhKSQvaTtmdW5jdGlvbiB2dChlKXtyZXR1cm4oZS5tYXRjaChQKXx8W10pLmpvaW4oIiAiKX1mdW5jdGlvbiB5dChlKXtyZXR1cm4gZS5nZXRBdHRyaWJ1dGUmJmUuZ2V0Q
XR0cmlidXRlKCJjbGFzcyIpfHwiIn1mdW5jdGlvbiBtdChlKXtyZXR1cm4gQXJyYXkuaXNBcnJheShlKT9lOiJzdHJpbmciPT10eXBlb2YgZSYmZS5tYXRjaChQKXx8W119Uy5mbi5leHRlbmQoe3Byb3A6ZnVuY3Rpb24oZSx0KXtyZXR1cm4gJCh0aGlzLFMucHJvcCxlLHQsMTxhcmd1bWVudHMubGVuZ3RoKX0scmVtb3ZlUHJvcDpmdW5jdGlvbihlKXtyZXR1cm4gdGhpcy5lYWNoKGZ1bmN0aW9uKCl7ZGVsZXRlIHRoaXNbUy5wcm9wRml4W2VdfHxlXX0pfX0pLFMuZXh0ZW5kKHtwcm9wOmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG89ZS5ub2RlVHlwZTtpZigzIT09byYmOCE9PW8mJjIhPT1vKXJldHVybiAxPT09byYmUy5pc1hNTERvYyhlKXx8KHQ9Uy5wcm9wRml4W3RdfHx0LGk9Uy5wcm9wSG9va3NbdF0pLHZvaWQgMCE9PW4/aSYmInNldCJpbiB
pJiZ2b2lkIDAhPT0ocj1pLnNldChlLG4sdCkpP3I6ZVt0XT1uOmkmJiJnZXQiaW4gaSYmbnVsbCE9PShyPWkuZ2V0KGUsdCkpP3I6ZVt0XX0scHJvcEhvb2tzOnt0YWJJbmRleDp7Z2V0OmZ1bmN0aW9uKGUpe3ZhciB0PVMuZmluZC5hdHRyKGUsInRhYmluZGV4Iik7cmV0dXJuIHQ/cGFyc2VJbnQodCwxMCk6aHQudGVzdChlLm5vZGVOYW1lKXx8Z3QudGVzdChlLm5vZGVOYW1lKSYmZS5ocmVmPzA6LTF9fX0scHJvcEZpeDp7ImZvciI6Imh0bWxGb3IiLCJjbGFzcyI6ImNsYXNzTmFtZSJ9fSkseS5vcHRTZWxlY3RlZHx8KFMucHJvcEhvb2tzLnNlbGVjdGVkPXtnZXQ6ZnVuY3Rpb24oZSl7dmFyIHQ9ZS5wYXJlbnROb2RlO3JldHVybiB0JiZ0LnBhcmVudE5vZGUmJnQucGFyZW50Tm9kZS5zZWxlY3RlZEluZGV4LG51bGx9LHNldDpmdW5jdGlvbihlK
Xt2YXIgdD1lLnBhcmVudE5vZGU7dCYmKHQuc2VsZWN0ZWRJbmRleCx0LnBhcmVudE5vZGUmJnQucGFyZW50Tm9kZS5zZWxlY3RlZEluZGV4KX19KSxTLmVhY2goWyJ0YWJJbmRleCIsInJlYWRPbmx5IiwibWF4TGVuZ3RoIiwiY2VsbFNwYWNpbmciLCJjZWxsUGFkZGluZyIsInJvd1NwYW4iLCJjb2xTcGFuIiwidXNlTWFwIiwiZnJhbWVCb3JkZXIiLCJjb250ZW50RWRpdGFibGUiXSxmdW5jdGlvbigpe1MucHJvcEZpeFt0aGlzLnRvTG93ZXJDYXNlKCldPXRoaXN9KSxTLmZuLmV4dGVuZCh7YWRkQ2xhc3M6ZnVuY3Rpb24odCl7dmFyIGUsbixyLGksbyxhLHMsdT0wO2lmKG0odCkpcmV0dXJuIHRoaXMuZWFjaChmdW5jdGlvbihlKXtTKHRoaXMpLmFkZENsYXNzKHQuY2FsbCh0aGlzLGUseXQodGhpcykpKX0pO2lmKChlPW10KHQpKS5sZW5ndGgpd2h
pbGUobj10aGlzW3UrK10paWYoaT15dChuKSxyPTE9PT1uLm5vZGVUeXBlJiYiICIrdnQoaSkrIiAiKXthPTA7d2hpbGUobz1lW2ErK10pci5pbmRleE9mKCIgIitvKyIgIik8MCYmKHIrPW8rIiAiKTtpIT09KHM9dnQocikpJiZuLnNldEF0dHJpYnV0ZSgiY2xhc3MiLHMpfXJldHVybiB0aGlzfSxyZW1vdmVDbGFzczpmdW5jdGlvbih0KXt2YXIgZSxuLHIsaSxvLGEscyx1PTA7aWYobSh0KSlyZXR1cm4gdGhpcy5lYWNoKGZ1bmN0aW9uKGUpe1ModGhpcykucmVtb3ZlQ2xhc3ModC5jYWxsKHRoaXMsZSx5dCh0aGlzKSkpfSk7aWYoIWFyZ3VtZW50cy5sZW5ndGgpcmV0dXJuIHRoaXMuYXR0cigiY2xhc3MiLCIiKTtpZigoZT1tdCh0KSkubGVuZ3RoKXdoaWxlKG49dGhpc1t1KytdKWlmKGk9eXQobikscj0xPT09bi5ub2RlVHlwZSYmIiAiK3Z0KGkpK
yIgIil7YT0wO3doaWxlKG89ZVthKytdKXdoaWxlKC0xPHIuaW5kZXhPZigiICIrbysiICIpKXI9ci5yZXBsYWNlKCIgIitvKyIgIiwiICIpO2khPT0ocz12dChyKSkmJm4uc2V0QXR0cmlidXRlKCJjbGFzcyIscyl9cmV0dXJuIHRoaXN9LHRvZ2dsZUNsYXNzOmZ1bmN0aW9uKGksdCl7dmFyIG89dHlwZW9mIGksYT0ic3RyaW5nIj09PW98fEFycmF5LmlzQXJyYXkoaSk7cmV0dXJuImJvb2xlYW4iPT10eXBlb2YgdCYmYT90P3RoaXMuYWRkQ2xhc3MoaSk6dGhpcy5yZW1vdmVDbGFzcyhpKTptKGkpP3RoaXMuZWFjaChmdW5jdGlvbihlKXtTKHRoaXMpLnRvZ2dsZUNsYXNzKGkuY2FsbCh0aGlzLGUseXQodGhpcyksdCksdCl9KTp0aGlzLmVhY2goZnVuY3Rpb24oKXt2YXIgZSx0LG4scjtpZihhKXt0PTAsbj1TKHRoaXMpLHI9bXQoaSk7d2hpbGUoZT1
yW3QrK10pbi5oYXNDbGFzcyhlKT9uLnJlbW92ZUNsYXNzKGUpOm4uYWRkQ2xhc3MoZSl9ZWxzZSB2b2lkIDAhPT1pJiYiYm9vbGVhbiIhPT1vfHwoKGU9eXQodGhpcykpJiZZLnNldCh0aGlzLCJfX2NsYXNzTmFtZV9fIixlKSx0aGlzLnNldEF0dHJpYnV0ZSYmdGhpcy5zZXRBdHRyaWJ1dGUoImNsYXNzIixlfHwhMT09PWk/IiI6WS5nZXQodGhpcywiX19jbGFzc05hbWVfXyIpfHwiIikpfSl9LGhhc0NsYXNzOmZ1bmN0aW9uKGUpe3ZhciB0LG4scj0wO3Q9IiAiK2UrIiAiO3doaWxlKG49dGhpc1tyKytdKWlmKDE9PT1uLm5vZGVUeXBlJiYtMTwoIiAiK3Z0KHl0KG4pKSsiICIpLmluZGV4T2YodCkpcmV0dXJuITA7cmV0dXJuITF9fSk7dmFyIHh0PS9cci9nO1MuZm4uZXh0ZW5kKHt2YWw6ZnVuY3Rpb24obil7dmFyIHIsZSxpLHQ9dGhpc1swXTtyZ
XR1cm4gYXJndW1lbnRzLmxlbmd0aD8oaT1tKG4pLHRoaXMuZWFjaChmdW5jdGlvbihlKXt2YXIgdDsxPT09dGhpcy5ub2RlVHlwZSYmKG51bGw9PSh0PWk/bi5jYWxsKHRoaXMsZSxTKHRoaXMpLnZhbCgpKTpuKT90PSIiOiJudW1iZXIiPT10eXBlb2YgdD90Kz0iIjpBcnJheS5pc0FycmF5KHQpJiYodD1TLm1hcCh0LGZ1bmN0aW9uKGUpe3JldHVybiBudWxsPT1lPyIiOmUrIiJ9KSksKHI9Uy52YWxIb29rc1t0aGlzLnR5cGVdfHxTLnZhbEhvb2tzW3RoaXMubm9kZU5hbWUudG9Mb3dlckNhc2UoKV0pJiYic2V0ImluIHImJnZvaWQgMCE9PXIuc2V0KHRoaXMsdCwidmFsdWUiKXx8KHRoaXMudmFsdWU9dCkpfSkpOnQ/KHI9Uy52YWxIb29rc1t0LnR5cGVdfHxTLnZhbEhvb2tzW3Qubm9kZU5hbWUudG9Mb3dlckNhc2UoKV0pJiYiZ2V0ImluIHImJnZ
vaWQgMCE9PShlPXIuZ2V0KHQsInZhbHVlIikpP2U6InN0cmluZyI9PXR5cGVvZihlPXQudmFsdWUpP2UucmVwbGFjZSh4dCwiIik6bnVsbD09ZT8iIjplOnZvaWQgMH19KSxTLmV4dGVuZCh7dmFsSG9va3M6e29wdGlvbjp7Z2V0OmZ1bmN0aW9uKGUpe3ZhciB0PVMuZmluZC5hdHRyKGUsInZhbHVlIik7cmV0dXJuIG51bGwhPXQ/dDp2dChTLnRleHQoZSkpfX0sc2VsZWN0OntnZXQ6ZnVuY3Rpb24oZSl7dmFyIHQsbixyLGk9ZS5vcHRpb25zLG89ZS5zZWxlY3RlZEluZGV4LGE9InNlbGVjdC1vbmUiPT09ZS50eXBlLHM9YT9udWxsOltdLHU9YT9vKzE6aS5sZW5ndGg7Zm9yKHI9bzwwP3U6YT9vOjA7cjx1O3IrKylpZigoKG49aVtyXSkuc2VsZWN0ZWR8fHI9PT1vKSYmIW4uZGlzYWJsZWQmJighbi5wYXJlbnROb2RlLmRpc2FibGVkfHwhQShuLnBhc
mVudE5vZGUsIm9wdGdyb3VwIikpKXtpZih0PVMobikudmFsKCksYSlyZXR1cm4gdDtzLnB1c2godCl9cmV0dXJuIHN9LHNldDpmdW5jdGlvbihlLHQpe3ZhciBuLHIsaT1lLm9wdGlvbnMsbz1TLm1ha2VBcnJheSh0KSxhPWkubGVuZ3RoO3doaWxlKGEtLSkoKHI9aVthXSkuc2VsZWN0ZWQ9LTE8Uy5pbkFycmF5KFMudmFsSG9va3Mub3B0aW9uLmdldChyKSxvKSkmJihuPSEwKTtyZXR1cm4gbnx8KGUuc2VsZWN0ZWRJbmRleD0tMSksb319fX0pLFMuZWFjaChbInJhZGlvIiwiY2hlY2tib3giXSxmdW5jdGlvbigpe1MudmFsSG9va3NbdGhpc109e3NldDpmdW5jdGlvbihlLHQpe2lmKEFycmF5LmlzQXJyYXkodCkpcmV0dXJuIGUuY2hlY2tlZD0tMTxTLmluQXJyYXkoUyhlKS52YWwoKSx0KX19LHkuY2hlY2tPbnx8KFMudmFsSG9va3NbdGhpc10uZ2V
0PWZ1bmN0aW9uKGUpe3JldHVybiBudWxsPT09ZS5nZXRBdHRyaWJ1dGUoInZhbHVlIik/Im9uIjplLnZhbHVlfSl9KSx5LmZvY3VzaW49Im9uZm9jdXNpbiJpbiBDO3ZhciBidD0vXig/OmZvY3VzaW5mb2N1c3xmb2N1c291dGJsdXIpJC8sd3Q9ZnVuY3Rpb24oZSl7ZS5zdG9wUHJvcGFnYXRpb24oKX07Uy5leHRlbmQoUy5ldmVudCx7dHJpZ2dlcjpmdW5jdGlvbihlLHQsbixyKXt2YXIgaSxvLGEscyx1LGwsYyxmLHA9W258fEVdLGQ9di5jYWxsKGUsInR5cGUiKT9lLnR5cGU6ZSxoPXYuY2FsbChlLCJuYW1lc3BhY2UiKT9lLm5hbWVzcGFjZS5zcGxpdCgiLiIpOltdO2lmKG89Zj1hPW49bnx8RSwzIT09bi5ub2RlVHlwZSYmOCE9PW4ubm9kZVR5cGUmJiFidC50ZXN0KGQrUy5ldmVudC50cmlnZ2VyZWQpJiYoLTE8ZC5pbmRleE9mKCIuIikmJihkP
ShoPWQuc3BsaXQoIi4iKSkuc2hpZnQoKSxoLnNvcnQoKSksdT1kLmluZGV4T2YoIjoiKTwwJiYib24iK2QsKGU9ZVtTLmV4cGFuZG9dP2U6bmV3IFMuRXZlbnQoZCwib2JqZWN0Ij09dHlwZW9mIGUmJmUpKS5pc1RyaWdnZXI9cj8yOjMsZS5uYW1lc3BhY2U9aC5qb2luKCIuIiksZS5ybmFtZXNwYWNlPWUubmFtZXNwYWNlP25ldyBSZWdFeHAoIihefFxcLikiK2guam9pbigiXFwuKD86LipcXC58KSIpKyIoXFwufCQpIik6bnVsbCxlLnJlc3VsdD12b2lkIDAsZS50YXJnZXR8fChlLnRhcmdldD1uKSx0PW51bGw9PXQ/W2VdOlMubWFrZUFycmF5KHQsW2VdKSxjPVMuZXZlbnQuc3BlY2lhbFtkXXx8e30scnx8IWMudHJpZ2dlcnx8ITEhPT1jLnRyaWdnZXIuYXBwbHkobix0KSkpe2lmKCFyJiYhYy5ub0J1YmJsZSYmIXgobikpe2ZvcihzPWMuZGVsZWd
hdGVUeXBlfHxkLGJ0LnRlc3QocytkKXx8KG89by5wYXJlbnROb2RlKTtvO289by5wYXJlbnROb2RlKXAucHVzaChvKSxhPW87YT09PShuLm93bmVyRG9jdW1lbnR8fEUpJiZwLnB1c2goYS5kZWZhdWx0Vmlld3x8YS5wYXJlbnRXaW5kb3d8fEMpfWk9MDt3aGlsZSgobz1wW2krK10pJiYhZS5pc1Byb3BhZ2F0aW9uU3RvcHBlZCgpKWY9byxlLnR5cGU9MTxpP3M6Yy5iaW5kVHlwZXx8ZCwobD0oWS5nZXQobywiZXZlbnRzIil8fE9iamVjdC5jcmVhdGUobnVsbCkpW2UudHlwZV0mJlkuZ2V0KG8sImhhbmRsZSIpKSYmbC5hcHBseShvLHQpLChsPXUmJm9bdV0pJiZsLmFwcGx5JiZWKG8pJiYoZS5yZXN1bHQ9bC5hcHBseShvLHQpLCExPT09ZS5yZXN1bHQmJmUucHJldmVudERlZmF1bHQoKSk7cmV0dXJuIGUudHlwZT1kLHJ8fGUuaXNEZWZhdWx0UHJld
mVudGVkKCl8fGMuX2RlZmF1bHQmJiExIT09Yy5fZGVmYXVsdC5hcHBseShwLnBvcCgpLHQpfHwhVihuKXx8dSYmbShuW2RdKSYmIXgobikmJigoYT1uW3VdKSYmKG5bdV09bnVsbCksUy5ldmVudC50cmlnZ2VyZWQ9ZCxlLmlzUHJvcGFnYXRpb25TdG9wcGVkKCkmJmYuYWRkRXZlbnRMaXN0ZW5lcihkLHd0KSxuW2RdKCksZS5pc1Byb3BhZ2F0aW9uU3RvcHBlZCgpJiZmLnJlbW92ZUV2ZW50TGlzdGVuZXIoZCx3dCksUy5ldmVudC50cmlnZ2VyZWQ9dm9pZCAwLGEmJihuW3VdPWEpKSxlLnJlc3VsdH19LHNpbXVsYXRlOmZ1bmN0aW9uKGUsdCxuKXt2YXIgcj1TLmV4dGVuZChuZXcgUy5FdmVudCxuLHt0eXBlOmUsaXNTaW11bGF0ZWQ6ITB9KTtTLmV2ZW50LnRyaWdnZXIocixudWxsLHQpfX0pLFMuZm4uZXh0ZW5kKHt0cmlnZ2VyOmZ1bmN0aW9uKGU
sdCl7cmV0dXJuIHRoaXMuZWFjaChmdW5jdGlvbigpe1MuZXZlbnQudHJpZ2dlcihlLHQsdGhpcyl9KX0sdHJpZ2dlckhhbmRsZXI6ZnVuY3Rpb24oZSx0KXt2YXIgbj10aGlzWzBdO2lmKG4pcmV0dXJuIFMuZXZlbnQudHJpZ2dlcihlLHQsbiwhMCl9fSkseS5mb2N1c2lufHxTLmVhY2goe2ZvY3VzOiJmb2N1c2luIixibHVyOiJmb2N1c291dCJ9LGZ1bmN0aW9uKG4scil7dmFyIGk9ZnVuY3Rpb24oZSl7Uy5ldmVudC5zaW11bGF0ZShyLGUudGFyZ2V0LFMuZXZlbnQuZml4KGUpKX07Uy5ldmVudC5zcGVjaWFsW3JdPXtzZXR1cDpmdW5jdGlvbigpe3ZhciBlPXRoaXMub3duZXJEb2N1bWVudHx8dGhpcy5kb2N1bWVudHx8dGhpcyx0PVkuYWNjZXNzKGUscik7dHx8ZS5hZGRFdmVudExpc3RlbmVyKG4saSwhMCksWS5hY2Nlc3MoZSxyLCh0fHwwKSsxK
X0sdGVhcmRvd246ZnVuY3Rpb24oKXt2YXIgZT10aGlzLm93bmVyRG9jdW1lbnR8fHRoaXMuZG9jdW1lbnR8fHRoaXMsdD1ZLmFjY2VzcyhlLHIpLTE7dD9ZLmFjY2VzcyhlLHIsdCk6KGUucmVtb3ZlRXZlbnRMaXN0ZW5lcihuLGksITApLFkucmVtb3ZlKGUscikpfX19KTt2YXIgVHQ9Qy5sb2NhdGlvbixDdD17Z3VpZDpEYXRlLm5vdygpfSxFdD0vXD8vO1MucGFyc2VYTUw9ZnVuY3Rpb24oZSl7dmFyIHQ7aWYoIWV8fCJzdHJpbmciIT10eXBlb2YgZSlyZXR1cm4gbnVsbDt0cnl7dD0obmV3IEMuRE9NUGFyc2VyKS5wYXJzZUZyb21TdHJpbmcoZSwidGV4dC94bWwiKX1jYXRjaChlKXt0PXZvaWQgMH1yZXR1cm4gdCYmIXQuZ2V0RWxlbWVudHNCeVRhZ05hbWUoInBhcnNlcmVycm9yIikubGVuZ3RofHxTLmVycm9yKCJJbnZhbGlkIFhNTDogIitlKSx
0fTt2YXIgU3Q9L1xbXF0kLyxrdD0vXHI/XG4vZyxBdD0vXig/OnN1Ym1pdHxidXR0b258aW1hZ2V8cmVzZXR8ZmlsZSkkL2ksTnQ9L14oPzppbnB1dHxzZWxlY3R8dGV4dGFyZWF8a2V5Z2VuKS9pO2Z1bmN0aW9uIER0KG4sZSxyLGkpe3ZhciB0O2lmKEFycmF5LmlzQXJyYXkoZSkpUy5lYWNoKGUsZnVuY3Rpb24oZSx0KXtyfHxTdC50ZXN0KG4pP2kobix0KTpEdChuKyJbIisoIm9iamVjdCI9PXR5cGVvZiB0JiZudWxsIT10P2U6IiIpKyJdIix0LHIsaSl9KTtlbHNlIGlmKHJ8fCJvYmplY3QiIT09dyhlKSlpKG4sZSk7ZWxzZSBmb3IodCBpbiBlKUR0KG4rIlsiK3QrIl0iLGVbdF0scixpKX1TLnBhcmFtPWZ1bmN0aW9uKGUsdCl7dmFyIG4scj1bXSxpPWZ1bmN0aW9uKGUsdCl7dmFyIG49bSh0KT90KCk6dDtyW3IubGVuZ3RoXT1lbmNvZGVVUklDb
21wb25lbnQoZSkrIj0iK2VuY29kZVVSSUNvbXBvbmVudChudWxsPT1uPyIiOm4pfTtpZihudWxsPT1lKXJldHVybiIiO2lmKEFycmF5LmlzQXJyYXkoZSl8fGUuanF1ZXJ5JiYhUy5pc1BsYWluT2JqZWN0KGUpKVMuZWFjaChlLGZ1bmN0aW9uKCl7aSh0aGlzLm5hbWUsdGhpcy52YWx1ZSl9KTtlbHNlIGZvcihuIGluIGUpRHQobixlW25dLHQsaSk7cmV0dXJuIHIuam9pbigiJiIpfSxTLmZuLmV4dGVuZCh7c2VyaWFsaXplOmZ1bmN0aW9uKCl7cmV0dXJuIFMucGFyYW0odGhpcy5zZXJpYWxpemVBcnJheSgpKX0sc2VyaWFsaXplQXJyYXk6ZnVuY3Rpb24oKXtyZXR1cm4gdGhpcy5tYXAoZnVuY3Rpb24oKXt2YXIgZT1TLnByb3AodGhpcywiZWxlbWVudHMiKTtyZXR1cm4gZT9TLm1ha2VBcnJheShlKTp0aGlzfSkuZmlsdGVyKGZ1bmN0aW9uKCl7dmF
yIGU9dGhpcy50eXBlO3JldHVybiB0aGlzLm5hbWUmJiFTKHRoaXMpLmlzKCI6ZGlzYWJsZWQiKSYmTnQudGVzdCh0aGlzLm5vZGVOYW1lKSYmIUF0LnRlc3QoZSkmJih0aGlzLmNoZWNrZWR8fCFwZS50ZXN0KGUpKX0pLm1hcChmdW5jdGlvbihlLHQpe3ZhciBuPVModGhpcykudmFsKCk7cmV0dXJuIG51bGw9PW4/bnVsbDpBcnJheS5pc0FycmF5KG4pP1MubWFwKG4sZnVuY3Rpb24oZSl7cmV0dXJue25hbWU6dC5uYW1lLHZhbHVlOmUucmVwbGFjZShrdCwiXHJcbiIpfX0pOntuYW1lOnQubmFtZSx2YWx1ZTpuLnJlcGxhY2Uoa3QsIlxyXG4iKX19KS5nZXQoKX19KTt2YXIganQ9LyUyMC9nLHF0PS8jLiokLyxMdD0vKFs/Jl0pXz1bXiZdKi8sSHQ9L14oLio/KTpbIFx0XSooW15cclxuXSopJC9nbSxPdD0vXig/OkdFVHxIRUFEKSQvLFB0PS9eXC9cL
y8sUnQ9e30sTXQ9e30sSXQ9IiovIi5jb25jYXQoIioiKSxXdD1FLmNyZWF0ZUVsZW1lbnQoImEiKTtmdW5jdGlvbiBGdChvKXtyZXR1cm4gZnVuY3Rpb24oZSx0KXsic3RyaW5nIiE9dHlwZW9mIGUmJih0PWUsZT0iKiIpO3ZhciBuLHI9MCxpPWUudG9Mb3dlckNhc2UoKS5tYXRjaChQKXx8W107aWYobSh0KSl3aGlsZShuPWlbcisrXSkiKyI9PT1uWzBdPyhuPW4uc2xpY2UoMSl8fCIqIiwob1tuXT1vW25dfHxbXSkudW5zaGlmdCh0KSk6KG9bbl09b1tuXXx8W10pLnB1c2godCl9fWZ1bmN0aW9uIEJ0KHQsaSxvLGEpe3ZhciBzPXt9LHU9dD09PU10O2Z1bmN0aW9uIGwoZSl7dmFyIHI7cmV0dXJuIHNbZV09ITAsUy5lYWNoKHRbZV18fFtdLGZ1bmN0aW9uKGUsdCl7dmFyIG49dChpLG8sYSk7cmV0dXJuInN0cmluZyIhPXR5cGVvZiBufHx1fHxzW25
dP3U/IShyPW4pOnZvaWQgMDooaS5kYXRhVHlwZXMudW5zaGlmdChuKSxsKG4pLCExKX0pLHJ9cmV0dXJuIGwoaS5kYXRhVHlwZXNbMF0pfHwhc1siKiJdJiZsKCIqIil9ZnVuY3Rpb24gJHQoZSx0KXt2YXIgbixyLGk9Uy5hamF4U2V0dGluZ3MuZmxhdE9wdGlvbnN8fHt9O2ZvcihuIGluIHQpdm9pZCAwIT09dFtuXSYmKChpW25dP2U6cnx8KHI9e30pKVtuXT10W25dKTtyZXR1cm4gciYmUy5leHRlbmQoITAsZSxyKSxlfVd0LmhyZWY9VHQuaHJlZixTLmV4dGVuZCh7YWN0aXZlOjAsbGFzdE1vZGlmaWVkOnt9LGV0YWc6e30sYWpheFNldHRpbmdzOnt1cmw6VHQuaHJlZix0eXBlOiJHRVQiLGlzTG9jYWw6L14oPzphYm91dHxhcHB8YXBwLXN0b3JhZ2V8ListZXh0ZW5zaW9ufGZpbGV8cmVzfHdpZGdldCk6JC8udGVzdChUdC5wcm90b2NvbCksZ2xvY
mFsOiEwLHByb2Nlc3NEYXRhOiEwLGFzeW5jOiEwLGNvbnRlbnRUeXBlOiJhcHBsaWNhdGlvbi94LXd3dy1mb3JtLXVybGVuY29kZWQ7IGNoYXJzZXQ9VVRGLTgiLGFjY2VwdHM6eyIqIjpJdCx0ZXh0OiJ0ZXh0L3BsYWluIixodG1sOiJ0ZXh0L2h0bWwiLHhtbDoiYXBwbGljYXRpb24veG1sLCB0ZXh0L3htbCIsanNvbjoiYXBwbGljYXRpb24vanNvbiwgdGV4dC9qYXZhc2NyaXB0In0sY29udGVudHM6e3htbDovXGJ4bWxcYi8saHRtbDovXGJodG1sLyxqc29uOi9cYmpzb25cYi99LHJlc3BvbnNlRmllbGRzOnt4bWw6InJlc3BvbnNlWE1MIix0ZXh0OiJyZXNwb25zZVRleHQiLGpzb246InJlc3BvbnNlSlNPTiJ9LGNvbnZlcnRlcnM6eyIqIHRleHQiOlN0cmluZywidGV4dCBodG1sIjohMCwidGV4dCBqc29uIjpKU09OLnBhcnNlLCJ0ZXh0IHhtbCI
6Uy5wYXJzZVhNTH0sZmxhdE9wdGlvbnM6e3VybDohMCxjb250ZXh0OiEwfX0sYWpheFNldHVwOmZ1bmN0aW9uKGUsdCl7cmV0dXJuIHQ/JHQoJHQoZSxTLmFqYXhTZXR0aW5ncyksdCk6JHQoUy5hamF4U2V0dGluZ3MsZSl9LGFqYXhQcmVmaWx0ZXI6RnQoUnQpLGFqYXhUcmFuc3BvcnQ6RnQoTXQpLGFqYXg6ZnVuY3Rpb24oZSx0KXsib2JqZWN0Ij09dHlwZW9mIGUmJih0PWUsZT12b2lkIDApLHQ9dHx8e307dmFyIGMsZixwLG4sZCxyLGgsZyxpLG8sdj1TLmFqYXhTZXR1cCh7fSx0KSx5PXYuY29udGV4dHx8dixtPXYuY29udGV4dCYmKHkubm9kZVR5cGV8fHkuanF1ZXJ5KT9TKHkpOlMuZXZlbnQseD1TLkRlZmVycmVkKCksYj1TLkNhbGxiYWNrcygib25jZSBtZW1vcnkiKSx3PXYuc3RhdHVzQ29kZXx8e30sYT17fSxzPXt9LHU9ImNhbmNlbGVkI
ixUPXtyZWFkeVN0YXRlOjAsZ2V0UmVzcG9uc2VIZWFkZXI6ZnVuY3Rpb24oZSl7dmFyIHQ7aWYoaCl7aWYoIW4pe249e307d2hpbGUodD1IdC5leGVjKHApKW5bdFsxXS50b0xvd2VyQ2FzZSgpKyIgIl09KG5bdFsxXS50b0xvd2VyQ2FzZSgpKyIgIl18fFtdKS5jb25jYXQodFsyXSl9dD1uW2UudG9Mb3dlckNhc2UoKSsiICJdfXJldHVybiBudWxsPT10P251bGw6dC5qb2luKCIsICIpfSxnZXRBbGxSZXNwb25zZUhlYWRlcnM6ZnVuY3Rpb24oKXtyZXR1cm4gaD9wOm51bGx9LHNldFJlcXVlc3RIZWFkZXI6ZnVuY3Rpb24oZSx0KXtyZXR1cm4gbnVsbD09aCYmKGU9c1tlLnRvTG93ZXJDYXNlKCldPXNbZS50b0xvd2VyQ2FzZSgpXXx8ZSxhW2VdPXQpLHRoaXN9LG92ZXJyaWRlTWltZVR5cGU6ZnVuY3Rpb24oZSl7cmV0dXJuIG51bGw9PWgmJih2Lm1
pbWVUeXBlPWUpLHRoaXN9LHN0YXR1c0NvZGU6ZnVuY3Rpb24oZSl7dmFyIHQ7aWYoZSlpZihoKVQuYWx3YXlzKGVbVC5zdGF0dXNdKTtlbHNlIGZvcih0IGluIGUpd1t0XT1bd1t0XSxlW3RdXTtyZXR1cm4gdGhpc30sYWJvcnQ6ZnVuY3Rpb24oZSl7dmFyIHQ9ZXx8dTtyZXR1cm4gYyYmYy5hYm9ydCh0KSxsKDAsdCksdGhpc319O2lmKHgucHJvbWlzZShUKSx2LnVybD0oKGV8fHYudXJsfHxUdC5ocmVmKSsiIikucmVwbGFjZShQdCxUdC5wcm90b2NvbCsiLy8iKSx2LnR5cGU9dC5tZXRob2R8fHQudHlwZXx8di5tZXRob2R8fHYudHlwZSx2LmRhdGFUeXBlcz0odi5kYXRhVHlwZXx8IioiKS50b0xvd2VyQ2FzZSgpLm1hdGNoKFApfHxbIiJdLG51bGw9PXYuY3Jvc3NEb21haW4pe3I9RS5jcmVhdGVFbGVtZW50KCJhIik7dHJ5e3IuaHJlZj12LnVyb
CxyLmhyZWY9ci5ocmVmLHYuY3Jvc3NEb21haW49V3QucHJvdG9jb2wrIi8vIitXdC5ob3N0IT1yLnByb3RvY29sKyIvLyIrci5ob3N0fWNhdGNoKGUpe3YuY3Jvc3NEb21haW49ITB9fWlmKHYuZGF0YSYmdi5wcm9jZXNzRGF0YSYmInN0cmluZyIhPXR5cGVvZiB2LmRhdGEmJih2LmRhdGE9Uy5wYXJhbSh2LmRhdGEsdi50cmFkaXRpb25hbCkpLEJ0KFJ0LHYsdCxUKSxoKXJldHVybiBUO2ZvcihpIGluKGc9Uy5ldmVudCYmdi5nbG9iYWwpJiYwPT1TLmFjdGl2ZSsrJiZTLmV2ZW50LnRyaWdnZXIoImFqYXhTdGFydCIpLHYudHlwZT12LnR5cGUudG9VcHBlckNhc2UoKSx2Lmhhc0NvbnRlbnQ9IU90LnRlc3Qodi50eXBlKSxmPXYudXJsLnJlcGxhY2UocXQsIiIpLHYuaGFzQ29udGVudD92LmRhdGEmJnYucHJvY2Vzc0RhdGEmJjA9PT0odi5jb250ZW5
0VHlwZXx8IiIpLmluZGV4T2YoImFwcGxpY2F0aW9uL3gtd3d3LWZvcm0tdXJsZW5jb2RlZCIpJiYodi5kYXRhPXYuZGF0YS5yZXBsYWNlKGp0LCIrIikpOihvPXYudXJsLnNsaWNlKGYubGVuZ3RoKSx2LmRhdGEmJih2LnByb2Nlc3NEYXRhfHwic3RyaW5nIj09dHlwZW9mIHYuZGF0YSkmJihmKz0oRXQudGVzdChmKT8iJiI6Ij8iKSt2LmRhdGEsZGVsZXRlIHYuZGF0YSksITE9PT12LmNhY2hlJiYoZj1mLnJlcGxhY2UoTHQsIiQxIiksbz0oRXQudGVzdChmKT8iJiI6Ij8iKSsiXz0iK0N0Lmd1aWQrKytvKSx2LnVybD1mK28pLHYuaWZNb2RpZmllZCYmKFMubGFzdE1vZGlmaWVkW2ZdJiZULnNldFJlcXVlc3RIZWFkZXIoIklmLU1vZGlmaWVkLVNpbmNlIixTLmxhc3RNb2RpZmllZFtmXSksUy5ldGFnW2ZdJiZULnNldFJlcXVlc3RIZWFkZXIoIklmL
U5vbmUtTWF0Y2giLFMuZXRhZ1tmXSkpLCh2LmRhdGEmJnYuaGFzQ29udGVudCYmITEhPT12LmNvbnRlbnRUeXBlfHx0LmNvbnRlbnRUeXBlKSYmVC5zZXRSZXF1ZXN0SGVhZGVyKCJDb250ZW50LVR5cGUiLHYuY29udGVudFR5cGUpLFQuc2V0UmVxdWVzdEhlYWRlcigiQWNjZXB0Iix2LmRhdGFUeXBlc1swXSYmdi5hY2NlcHRzW3YuZGF0YVR5cGVzWzBdXT92LmFjY2VwdHNbdi5kYXRhVHlwZXNbMF1dKygiKiIhPT12LmRhdGFUeXBlc1swXT8iLCAiK0l0KyI7IHE9MC4wMSI6IiIpOnYuYWNjZXB0c1siKiJdKSx2LmhlYWRlcnMpVC5zZXRSZXF1ZXN0SGVhZGVyKGksdi5oZWFkZXJzW2ldKTtpZih2LmJlZm9yZVNlbmQmJighMT09PXYuYmVmb3JlU2VuZC5jYWxsKHksVCx2KXx8aCkpcmV0dXJuIFQuYWJvcnQoKTtpZih1PSJhYm9ydCIsYi5hZGQodi5
jb21wbGV0ZSksVC5kb25lKHYuc3VjY2VzcyksVC5mYWlsKHYuZXJyb3IpLGM9QnQoTXQsdix0LFQpKXtpZihULnJlYWR5U3RhdGU9MSxnJiZtLnRyaWdnZXIoImFqYXhTZW5kIixbVCx2XSksaClyZXR1cm4gVDt2LmFzeW5jJiYwPHYudGltZW91dCYmKGQ9Qy5zZXRUaW1lb3V0KGZ1bmN0aW9uKCl7VC5hYm9ydCgidGltZW91dCIpfSx2LnRpbWVvdXQpKTt0cnl7aD0hMSxjLnNlbmQoYSxsKX1jYXRjaChlKXtpZihoKXRocm93IGU7bCgtMSxlKX19ZWxzZSBsKC0xLCJObyBUcmFuc3BvcnQiKTtmdW5jdGlvbiBsKGUsdCxuLHIpe3ZhciBpLG8sYSxzLHUsbD10O2h8fChoPSEwLGQmJkMuY2xlYXJUaW1lb3V0KGQpLGM9dm9pZCAwLHA9cnx8IiIsVC5yZWFkeVN0YXRlPTA8ZT80OjAsaT0yMDA8PWUmJmU8MzAwfHwzMDQ9PT1lLG4mJihzPWZ1bmN0aW9uK
GUsdCxuKXt2YXIgcixpLG8sYSxzPWUuY29udGVudHMsdT1lLmRhdGFUeXBlczt3aGlsZSgiKiI9PT11WzBdKXUuc2hpZnQoKSx2b2lkIDA9PT1yJiYocj1lLm1pbWVUeXBlfHx0LmdldFJlc3BvbnNlSGVhZGVyKCJDb250ZW50LVR5cGUiKSk7aWYocilmb3IoaSBpbiBzKWlmKHNbaV0mJnNbaV0udGVzdChyKSl7dS51bnNoaWZ0KGkpO2JyZWFrfWlmKHVbMF1pbiBuKW89dVswXTtlbHNle2ZvcihpIGluIG4pe2lmKCF1WzBdfHxlLmNvbnZlcnRlcnNbaSsiICIrdVswXV0pe289aTticmVha31hfHwoYT1pKX1vPW98fGF9aWYobylyZXR1cm4gbyE9PXVbMF0mJnUudW5zaGlmdChvKSxuW29dfSh2LFQsbikpLCFpJiYtMTxTLmluQXJyYXkoInNjcmlwdCIsdi5kYXRhVHlwZXMpJiYodi5jb252ZXJ0ZXJzWyJ0ZXh0IHNjcmlwdCJdPWZ1bmN0aW9uKCl7fSk
scz1mdW5jdGlvbihlLHQsbixyKXt2YXIgaSxvLGEscyx1LGw9e30sYz1lLmRhdGFUeXBlcy5zbGljZSgpO2lmKGNbMV0pZm9yKGEgaW4gZS5jb252ZXJ0ZXJzKWxbYS50b0xvd2VyQ2FzZSgpXT1lLmNvbnZlcnRlcnNbYV07bz1jLnNoaWZ0KCk7d2hpbGUobylpZihlLnJlc3BvbnNlRmllbGRzW29dJiYobltlLnJlc3BvbnNlRmllbGRzW29dXT10KSwhdSYmciYmZS5kYXRhRmlsdGVyJiYodD1lLmRhdGFGaWx0ZXIodCxlLmRhdGFUeXBlKSksdT1vLG89Yy5zaGlmdCgpKWlmKCIqIj09PW8pbz11O2Vsc2UgaWYoIioiIT09dSYmdSE9PW8pe2lmKCEoYT1sW3UrIiAiK29dfHxsWyIqICIrb10pKWZvcihpIGluIGwpaWYoKHM9aS5zcGxpdCgiICIpKVsxXT09PW8mJihhPWxbdSsiICIrc1swXV18fGxbIiogIitzWzBdXSkpeyEwPT09YT9hPWxbaV06ITAhP
T1sW2ldJiYobz1zWzBdLGMudW5zaGlmdChzWzFdKSk7YnJlYWt9aWYoITAhPT1hKWlmKGEmJmVbInRocm93cyJdKXQ9YSh0KTtlbHNlIHRyeXt0PWEodCl9Y2F0Y2goZSl7cmV0dXJue3N0YXRlOiJwYXJzZXJlcnJvciIsZXJyb3I6YT9lOiJObyBjb252ZXJzaW9uIGZyb20gIit1KyIgdG8gIitvfX19cmV0dXJue3N0YXRlOiJzdWNjZXNzIixkYXRhOnR9fSh2LHMsVCxpKSxpPyh2LmlmTW9kaWZpZWQmJigodT1ULmdldFJlc3BvbnNlSGVhZGVyKCJMYXN0LU1vZGlmaWVkIikpJiYoUy5sYXN0TW9kaWZpZWRbZl09dSksKHU9VC5nZXRSZXNwb25zZUhlYWRlcigiZXRhZyIpKSYmKFMuZXRhZ1tmXT11KSksMjA0PT09ZXx8IkhFQUQiPT09di50eXBlP2w9Im5vY29udGVudCI6MzA0PT09ZT9sPSJub3Rtb2RpZmllZCI6KGw9cy5zdGF0ZSxvPXMuZGF0YSx
pPSEoYT1zLmVycm9yKSkpOihhPWwsIWUmJmx8fChsPSJlcnJvciIsZTwwJiYoZT0wKSkpLFQuc3RhdHVzPWUsVC5zdGF0dXNUZXh0PSh0fHxsKSsiIixpP3gucmVzb2x2ZVdpdGgoeSxbbyxsLFRdKTp4LnJlamVjdFdpdGgoeSxbVCxsLGFdKSxULnN0YXR1c0NvZGUodyksdz12b2lkIDAsZyYmbS50cmlnZ2VyKGk/ImFqYXhTdWNjZXNzIjoiYWpheEVycm9yIixbVCx2LGk/bzphXSksYi5maXJlV2l0aCh5LFtULGxdKSxnJiYobS50cmlnZ2VyKCJhamF4Q29tcGxldGUiLFtULHZdKSwtLVMuYWN0aXZlfHxTLmV2ZW50LnRyaWdnZXIoImFqYXhTdG9wIikpKX1yZXR1cm4gVH0sZ2V0SlNPTjpmdW5jdGlvbihlLHQsbil7cmV0dXJuIFMuZ2V0KGUsdCxuLCJqc29uIil9LGdldFNjcmlwdDpmdW5jdGlvbihlLHQpe3JldHVybiBTLmdldChlLHZvaWQgMCx0L
CJzY3JpcHQiKX19KSxTLmVhY2goWyJnZXQiLCJwb3N0Il0sZnVuY3Rpb24oZSxpKXtTW2ldPWZ1bmN0aW9uKGUsdCxuLHIpe3JldHVybiBtKHQpJiYocj1yfHxuLG49dCx0PXZvaWQgMCksUy5hamF4KFMuZXh0ZW5kKHt1cmw6ZSx0eXBlOmksZGF0YVR5cGU6cixkYXRhOnQsc3VjY2VzczpufSxTLmlzUGxhaW5PYmplY3QoZSkmJmUpKX19KSxTLmFqYXhQcmVmaWx0ZXIoZnVuY3Rpb24oZSl7dmFyIHQ7Zm9yKHQgaW4gZS5oZWFkZXJzKSJjb250ZW50LXR5cGUiPT09dC50b0xvd2VyQ2FzZSgpJiYoZS5jb250ZW50VHlwZT1lLmhlYWRlcnNbdF18fCIiKX0pLFMuX2V2YWxVcmw9ZnVuY3Rpb24oZSx0LG4pe3JldHVybiBTLmFqYXgoe3VybDplLHR5cGU6IkdFVCIsZGF0YVR5cGU6InNjcmlwdCIsY2FjaGU6ITAsYXN5bmM6ITEsZ2xvYmFsOiExLGNvbnZ
lcnRlcnM6eyJ0ZXh0IHNjcmlwdCI6ZnVuY3Rpb24oKXt9fSxkYXRhRmlsdGVyOmZ1bmN0aW9uKGUpe1MuZ2xvYmFsRXZhbChlLHQsbil9fSl9LFMuZm4uZXh0ZW5kKHt3cmFwQWxsOmZ1bmN0aW9uKGUpe3ZhciB0O3JldHVybiB0aGlzWzBdJiYobShlKSYmKGU9ZS5jYWxsKHRoaXNbMF0pKSx0PVMoZSx0aGlzWzBdLm93bmVyRG9jdW1lbnQpLmVxKDApLmNsb25lKCEwKSx0aGlzWzBdLnBhcmVudE5vZGUmJnQuaW5zZXJ0QmVmb3JlKHRoaXNbMF0pLHQubWFwKGZ1bmN0aW9uKCl7dmFyIGU9dGhpczt3aGlsZShlLmZpcnN0RWxlbWVudENoaWxkKWU9ZS5maXJzdEVsZW1lbnRDaGlsZDtyZXR1cm4gZX0pLmFwcGVuZCh0aGlzKSksdGhpc30sd3JhcElubmVyOmZ1bmN0aW9uKG4pe3JldHVybiBtKG4pP3RoaXMuZWFjaChmdW5jdGlvbihlKXtTKHRoaXMpL
ndyYXBJbm5lcihuLmNhbGwodGhpcyxlKSl9KTp0aGlzLmVhY2goZnVuY3Rpb24oKXt2YXIgZT1TKHRoaXMpLHQ9ZS5jb250ZW50cygpO3QubGVuZ3RoP3Qud3JhcEFsbChuKTplLmFwcGVuZChuKX0pfSx3cmFwOmZ1bmN0aW9uKHQpe3ZhciBuPW0odCk7cmV0dXJuIHRoaXMuZWFjaChmdW5jdGlvbihlKXtTKHRoaXMpLndyYXBBbGwobj90LmNhbGwodGhpcyxlKTp0KX0pfSx1bndyYXA6ZnVuY3Rpb24oZSl7cmV0dXJuIHRoaXMucGFyZW50KGUpLm5vdCgiYm9keSIpLmVhY2goZnVuY3Rpb24oKXtTKHRoaXMpLnJlcGxhY2VXaXRoKHRoaXMuY2hpbGROb2Rlcyl9KSx0aGlzfX0pLFMuZXhwci5wc2V1ZG9zLmhpZGRlbj1mdW5jdGlvbihlKXtyZXR1cm4hUy5leHByLnBzZXVkb3MudmlzaWJsZShlKX0sUy5leHByLnBzZXVkb3MudmlzaWJsZT1mdW5jdGl
vbihlKXtyZXR1cm4hIShlLm9mZnNldFdpZHRofHxlLm9mZnNldEhlaWdodHx8ZS5nZXRDbGllbnRSZWN0cygpLmxlbmd0aCl9LFMuYWpheFNldHRpbmdzLnhocj1mdW5jdGlvbigpe3RyeXtyZXR1cm4gbmV3IEMuWE1MSHR0cFJlcXVlc3R9Y2F0Y2goZSl7fX07dmFyIF90PXswOjIwMCwxMjIzOjIwNH0senQ9Uy5hamF4U2V0dGluZ3MueGhyKCk7eS5jb3JzPSEhenQmJiJ3aXRoQ3JlZGVudGlhbHMiaW4genQseS5hamF4PXp0PSEhenQsUy5hamF4VHJhbnNwb3J0KGZ1bmN0aW9uKGkpe3ZhciBvLGE7aWYoeS5jb3JzfHx6dCYmIWkuY3Jvc3NEb21haW4pcmV0dXJue3NlbmQ6ZnVuY3Rpb24oZSx0KXt2YXIgbixyPWkueGhyKCk7aWYoci5vcGVuKGkudHlwZSxpLnVybCxpLmFzeW5jLGkudXNlcm5hbWUsaS5wYXNzd29yZCksaS54aHJGaWVsZHMpZm9yK
G4gaW4gaS54aHJGaWVsZHMpcltuXT1pLnhockZpZWxkc1tuXTtmb3IobiBpbiBpLm1pbWVUeXBlJiZyLm92ZXJyaWRlTWltZVR5cGUmJnIub3ZlcnJpZGVNaW1lVHlwZShpLm1pbWVUeXBlKSxpLmNyb3NzRG9tYWlufHxlWyJYLVJlcXVlc3RlZC1XaXRoIl18fChlWyJYLVJlcXVlc3RlZC1XaXRoIl09IlhNTEh0dHBSZXF1ZXN0IiksZSlyLnNldFJlcXVlc3RIZWFkZXIobixlW25dKTtvPWZ1bmN0aW9uKGUpe3JldHVybiBmdW5jdGlvbigpe28mJihvPWE9ci5vbmxvYWQ9ci5vbmVycm9yPXIub25hYm9ydD1yLm9udGltZW91dD1yLm9ucmVhZHlzdGF0ZWNoYW5nZT1udWxsLCJhYm9ydCI9PT1lP3IuYWJvcnQoKToiZXJyb3IiPT09ZT8ibnVtYmVyIiE9dHlwZW9mIHIuc3RhdHVzP3QoMCwiZXJyb3IiKTp0KHIuc3RhdHVzLHIuc3RhdHVzVGV4dCk6dCh
fdFtyLnN0YXR1c118fHIuc3RhdHVzLHIuc3RhdHVzVGV4dCwidGV4dCIhPT0oci5yZXNwb25zZVR5cGV8fCJ0ZXh0Iil8fCJzdHJpbmciIT10eXBlb2Ygci5yZXNwb25zZVRleHQ/e2JpbmFyeTpyLnJlc3BvbnNlfTp7dGV4dDpyLnJlc3BvbnNlVGV4dH0sci5nZXRBbGxSZXNwb25zZUhlYWRlcnMoKSkpfX0sci5vbmxvYWQ9bygpLGE9ci5vbmVycm9yPXIub250aW1lb3V0PW8oImVycm9yIiksdm9pZCAwIT09ci5vbmFib3J0P3Iub25hYm9ydD1hOnIub25yZWFkeXN0YXRlY2hhbmdlPWZ1bmN0aW9uKCl7ND09PXIucmVhZHlTdGF0ZSYmQy5zZXRUaW1lb3V0KGZ1bmN0aW9uKCl7byYmYSgpfSl9LG89bygiYWJvcnQiKTt0cnl7ci5zZW5kKGkuaGFzQ29udGVudCYmaS5kYXRhfHxudWxsKX1jYXRjaChlKXtpZihvKXRocm93IGV9fSxhYm9ydDpmdW5jd
Glvbigpe28mJm8oKX19fSksUy5hamF4UHJlZmlsdGVyKGZ1bmN0aW9uKGUpe2UuY3Jvc3NEb21haW4mJihlLmNvbnRlbnRzLnNjcmlwdD0hMSl9KSxTLmFqYXhTZXR1cCh7YWNjZXB0czp7c2NyaXB0OiJ0ZXh0L2phdmFzY3JpcHQsIGFwcGxpY2F0aW9uL2phdmFzY3JpcHQsIGFwcGxpY2F0aW9uL2VjbWFzY3JpcHQsIGFwcGxpY2F0aW9uL3gtZWNtYXNjcmlwdCJ9LGNvbnRlbnRzOntzY3JpcHQ6L1xiKD86amF2YXxlY21hKXNjcmlwdFxiL30sY29udmVydGVyczp7InRleHQgc2NyaXB0IjpmdW5jdGlvbihlKXtyZXR1cm4gUy5nbG9iYWxFdmFsKGUpLGV9fX0pLFMuYWpheFByZWZpbHRlcigic2NyaXB0IixmdW5jdGlvbihlKXt2b2lkIDA9PT1lLmNhY2hlJiYoZS5jYWNoZT0hMSksZS5jcm9zc0RvbWFpbiYmKGUudHlwZT0iR0VUIil9KSxTLmFqYXh
UcmFuc3BvcnQoInNjcmlwdCIsZnVuY3Rpb24obil7dmFyIHIsaTtpZihuLmNyb3NzRG9tYWlufHxuLnNjcmlwdEF0dHJzKXJldHVybntzZW5kOmZ1bmN0aW9uKGUsdCl7cj1TKCI8c2NyaXB0PiIpLmF0dHIobi5zY3JpcHRBdHRyc3x8e30pLnByb3Aoe2NoYXJzZXQ6bi5zY3JpcHRDaGFyc2V0LHNyYzpuLnVybH0pLm9uKCJsb2FkIGVycm9yIixpPWZ1bmN0aW9uKGUpe3IucmVtb3ZlKCksaT1udWxsLGUmJnQoImVycm9yIj09PWUudHlwZT80MDQ6MjAwLGUudHlwZSl9KSxFLmhlYWQuYXBwZW5kQ2hpbGQoclswXSl9LGFib3J0OmZ1bmN0aW9uKCl7aSYmaSgpfX19KTt2YXIgVXQsWHQ9W10sVnQ9Lyg9KVw/KD89JnwkKXxcP1w/LztTLmFqYXhTZXR1cCh7anNvbnA6ImNhbGxiYWNrIixqc29ucENhbGxiYWNrOmZ1bmN0aW9uKCl7dmFyIGU9WHQucG9wK
Cl8fFMuZXhwYW5kbysiXyIrQ3QuZ3VpZCsrO3JldHVybiB0aGlzW2VdPSEwLGV9fSksUy5hamF4UHJlZmlsdGVyKCJqc29uIGpzb25wIixmdW5jdGlvbihlLHQsbil7dmFyIHIsaSxvLGE9ITEhPT1lLmpzb25wJiYoVnQudGVzdChlLnVybCk/InVybCI6InN0cmluZyI9PXR5cGVvZiBlLmRhdGEmJjA9PT0oZS5jb250ZW50VHlwZXx8IiIpLmluZGV4T2YoImFwcGxpY2F0aW9uL3gtd3d3LWZvcm0tdXJsZW5jb2RlZCIpJiZWdC50ZXN0KGUuZGF0YSkmJiJkYXRhIik7aWYoYXx8Impzb25wIj09PWUuZGF0YVR5cGVzWzBdKXJldHVybiByPWUuanNvbnBDYWxsYmFjaz1tKGUuanNvbnBDYWxsYmFjayk/ZS5qc29ucENhbGxiYWNrKCk6ZS5qc29ucENhbGxiYWNrLGE/ZVthXT1lW2FdLnJlcGxhY2UoVnQsIiQxIityKTohMSE9PWUuanNvbnAmJihlLnVybCs
9KEV0LnRlc3QoZS51cmwpPyImIjoiPyIpK2UuanNvbnArIj0iK3IpLGUuY29udmVydGVyc1sic2NyaXB0IGpzb24iXT1mdW5jdGlvbigpe3JldHVybiBvfHxTLmVycm9yKHIrIiB3YXMgbm90IGNhbGxlZCIpLG9bMF19LGUuZGF0YVR5cGVzWzBdPSJqc29uIixpPUNbcl0sQ1tyXT1mdW5jdGlvbigpe289YXJndW1lbnRzfSxuLmFsd2F5cyhmdW5jdGlvbigpe3ZvaWQgMD09PWk/UyhDKS5yZW1vdmVQcm9wKHIpOkNbcl09aSxlW3JdJiYoZS5qc29ucENhbGxiYWNrPXQuanNvbnBDYWxsYmFjayxYdC5wdXNoKHIpKSxvJiZtKGkpJiZpKG9bMF0pLG89aT12b2lkIDB9KSwic2NyaXB0In0pLHkuY3JlYXRlSFRNTERvY3VtZW50PSgoVXQ9RS5pbXBsZW1lbnRhdGlvbi5jcmVhdGVIVE1MRG9jdW1lbnQoIiIpLmJvZHkpLmlubmVySFRNTD0iPGZvcm0+PC9mb
3JtPjxmb3JtPjwvZm9ybT4iLDI9PT1VdC5jaGlsZE5vZGVzLmxlbmd0aCksUy5wYXJzZUhUTUw9ZnVuY3Rpb24oZSx0LG4pe3JldHVybiJzdHJpbmciIT10eXBlb2YgZT9bXTooImJvb2xlYW4iPT10eXBlb2YgdCYmKG49dCx0PSExKSx0fHwoeS5jcmVhdGVIVE1MRG9jdW1lbnQ/KChyPSh0PUUuaW1wbGVtZW50YXRpb24uY3JlYXRlSFRNTERvY3VtZW50KCIiKSkuY3JlYXRlRWxlbWVudCgiYmFzZSIpKS5ocmVmPUUubG9jYXRpb24uaHJlZix0LmhlYWQuYXBwZW5kQ2hpbGQocikpOnQ9RSksbz0hbiYmW10sKGk9Ti5leGVjKGUpKT9bdC5jcmVhdGVFbGVtZW50KGlbMV0pXTooaT14ZShbZV0sdCxvKSxvJiZvLmxlbmd0aCYmUyhvKS5yZW1vdmUoKSxTLm1lcmdlKFtdLGkuY2hpbGROb2RlcykpKTt2YXIgcixpLG99LFMuZm4ubG9hZD1mdW5jdGlvbih
lLHQsbil7dmFyIHIsaSxvLGE9dGhpcyxzPWUuaW5kZXhPZigiICIpO3JldHVybi0xPHMmJihyPXZ0KGUuc2xpY2UocykpLGU9ZS5zbGljZSgwLHMpKSxtKHQpPyhuPXQsdD12b2lkIDApOnQmJiJvYmplY3QiPT10eXBlb2YgdCYmKGk9IlBPU1QiKSwwPGEubGVuZ3RoJiZTLmFqYXgoe3VybDplLHR5cGU6aXx8IkdFVCIsZGF0YVR5cGU6Imh0bWwiLGRhdGE6dH0pLmRvbmUoZnVuY3Rpb24oZSl7bz1hcmd1bWVudHMsYS5odG1sKHI/UygiPGRpdj4iKS5hcHBlbmQoUy5wYXJzZUhUTUwoZSkpLmZpbmQocik6ZSl9KS5hbHdheXMobiYmZnVuY3Rpb24oZSx0KXthLmVhY2goZnVuY3Rpb24oKXtuLmFwcGx5KHRoaXMsb3x8W2UucmVzcG9uc2VUZXh0LHQsZV0pfSl9KSx0aGlzfSxTLmV4cHIucHNldWRvcy5hbmltYXRlZD1mdW5jdGlvbih0KXtyZXR1cm4gU
y5ncmVwKFMudGltZXJzLGZ1bmN0aW9uKGUpe3JldHVybiB0PT09ZS5lbGVtfSkubGVuZ3RofSxTLm9mZnNldD17c2V0T2Zmc2V0OmZ1bmN0aW9uKGUsdCxuKXt2YXIgcixpLG8sYSxzLHUsbD1TLmNzcyhlLCJwb3NpdGlvbiIpLGM9UyhlKSxmPXt9OyJzdGF0aWMiPT09bCYmKGUuc3R5bGUucG9zaXRpb249InJlbGF0aXZlIikscz1jLm9mZnNldCgpLG89Uy5jc3MoZSwidG9wIiksdT1TLmNzcyhlLCJsZWZ0IiksKCJhYnNvbHV0ZSI9PT1sfHwiZml4ZWQiPT09bCkmJi0xPChvK3UpLmluZGV4T2YoImF1dG8iKT8oYT0ocj1jLnBvc2l0aW9uKCkpLnRvcCxpPXIubGVmdCk6KGE9cGFyc2VGbG9hdChvKXx8MCxpPXBhcnNlRmxvYXQodSl8fDApLG0odCkmJih0PXQuY2FsbChlLG4sUy5leHRlbmQoe30scykpKSxudWxsIT10LnRvcCYmKGYudG9wPXQudG9
wLXMudG9wK2EpLG51bGwhPXQubGVmdCYmKGYubGVmdD10LmxlZnQtcy5sZWZ0K2kpLCJ1c2luZyJpbiB0P3QudXNpbmcuY2FsbChlLGYpOigibnVtYmVyIj09dHlwZW9mIGYudG9wJiYoZi50b3ArPSJweCIpLCJudW1iZXIiPT10eXBlb2YgZi5sZWZ0JiYoZi5sZWZ0Kz0icHgiKSxjLmNzcyhmKSl9fSxTLmZuLmV4dGVuZCh7b2Zmc2V0OmZ1bmN0aW9uKHQpe2lmKGFyZ3VtZW50cy5sZW5ndGgpcmV0dXJuIHZvaWQgMD09PXQ/dGhpczp0aGlzLmVhY2goZnVuY3Rpb24oZSl7Uy5vZmZzZXQuc2V0T2Zmc2V0KHRoaXMsdCxlKX0pO3ZhciBlLG4scj10aGlzWzBdO3JldHVybiByP3IuZ2V0Q2xpZW50UmVjdHMoKS5sZW5ndGg/KGU9ci5nZXRCb3VuZGluZ0NsaWVudFJlY3QoKSxuPXIub3duZXJEb2N1bWVudC5kZWZhdWx0Vmlldyx7dG9wOmUudG9wK24uc
GFnZVlPZmZzZXQsbGVmdDplLmxlZnQrbi5wYWdlWE9mZnNldH0pOnt0b3A6MCxsZWZ0OjB9OnZvaWQgMH0scG9zaXRpb246ZnVuY3Rpb24oKXtpZih0aGlzWzBdKXt2YXIgZSx0LG4scj10aGlzWzBdLGk9e3RvcDowLGxlZnQ6MH07aWYoImZpeGVkIj09PVMuY3NzKHIsInBvc2l0aW9uIikpdD1yLmdldEJvdW5kaW5nQ2xpZW50UmVjdCgpO2Vsc2V7dD10aGlzLm9mZnNldCgpLG49ci5vd25lckRvY3VtZW50LGU9ci5vZmZzZXRQYXJlbnR8fG4uZG9jdW1lbnRFbGVtZW50O3doaWxlKGUmJihlPT09bi5ib2R5fHxlPT09bi5kb2N1bWVudEVsZW1lbnQpJiYic3RhdGljIj09PVMuY3NzKGUsInBvc2l0aW9uIikpZT1lLnBhcmVudE5vZGU7ZSYmZSE9PXImJjE9PT1lLm5vZGVUeXBlJiYoKGk9UyhlKS5vZmZzZXQoKSkudG9wKz1TLmNzcyhlLCJib3JkZXJ
Ub3BXaWR0aCIsITApLGkubGVmdCs9Uy5jc3MoZSwiYm9yZGVyTGVmdFdpZHRoIiwhMCkpfXJldHVybnt0b3A6dC50b3AtaS50b3AtUy5jc3MociwibWFyZ2luVG9wIiwhMCksbGVmdDp0LmxlZnQtaS5sZWZ0LVMuY3NzKHIsIm1hcmdpbkxlZnQiLCEwKX19fSxvZmZzZXRQYXJlbnQ6ZnVuY3Rpb24oKXtyZXR1cm4gdGhpcy5tYXAoZnVuY3Rpb24oKXt2YXIgZT10aGlzLm9mZnNldFBhcmVudDt3aGlsZShlJiYic3RhdGljIj09PVMuY3NzKGUsInBvc2l0aW9uIikpZT1lLm9mZnNldFBhcmVudDtyZXR1cm4gZXx8cmV9KX19KSxTLmVhY2goe3Njcm9sbExlZnQ6InBhZ2VYT2Zmc2V0IixzY3JvbGxUb3A6InBhZ2VZT2Zmc2V0In0sZnVuY3Rpb24odCxpKXt2YXIgbz0icGFnZVlPZmZzZXQiPT09aTtTLmZuW3RdPWZ1bmN0aW9uKGUpe3JldHVybiAkKHRoa
XMsZnVuY3Rpb24oZSx0LG4pe3ZhciByO2lmKHgoZSk/cj1lOjk9PT1lLm5vZGVUeXBlJiYocj1lLmRlZmF1bHRWaWV3KSx2b2lkIDA9PT1uKXJldHVybiByP3JbaV06ZVt0XTtyP3Iuc2Nyb2xsVG8obz9yLnBhZ2VYT2Zmc2V0Om4sbz9uOnIucGFnZVlPZmZzZXQpOmVbdF09bn0sdCxlLGFyZ3VtZW50cy5sZW5ndGgpfX0pLFMuZWFjaChbInRvcCIsImxlZnQiXSxmdW5jdGlvbihlLG4pe1MuY3NzSG9va3Nbbl09JGUoeS5waXhlbFBvc2l0aW9uLGZ1bmN0aW9uKGUsdCl7aWYodClyZXR1cm4gdD1CZShlLG4pLE1lLnRlc3QodCk/UyhlKS5wb3NpdGlvbigpW25dKyJweCI6dH0pfSksUy5lYWNoKHtIZWlnaHQ6ImhlaWdodCIsV2lkdGg6IndpZHRoIn0sZnVuY3Rpb24oYSxzKXtTLmVhY2goe3BhZGRpbmc6ImlubmVyIithLGNvbnRlbnQ6cywiIjoib3V
0ZXIiK2F9LGZ1bmN0aW9uKHIsbyl7Uy5mbltvXT1mdW5jdGlvbihlLHQpe3ZhciBuPWFyZ3VtZW50cy5sZW5ndGgmJihyfHwiYm9vbGVhbiIhPXR5cGVvZiBlKSxpPXJ8fCghMD09PWV8fCEwPT09dD8ibWFyZ2luIjoiYm9yZGVyIik7cmV0dXJuICQodGhpcyxmdW5jdGlvbihlLHQsbil7dmFyIHI7cmV0dXJuIHgoZSk/MD09PW8uaW5kZXhPZigib3V0ZXIiKT9lWyJpbm5lciIrYV06ZS5kb2N1bWVudC5kb2N1bWVudEVsZW1lbnRbImNsaWVudCIrYV06OT09PWUubm9kZVR5cGU/KHI9ZS5kb2N1bWVudEVsZW1lbnQsTWF0aC5tYXgoZS5ib2R5WyJzY3JvbGwiK2FdLHJbInNjcm9sbCIrYV0sZS5ib2R5WyJvZmZzZXQiK2FdLHJbIm9mZnNldCIrYV0sclsiY2xpZW50IithXSkpOnZvaWQgMD09PW4/Uy5jc3MoZSx0LGkpOlMuc3R5bGUoZSx0LG4saSl9L
HMsbj9lOnZvaWQgMCxuKX19KX0pLFMuZWFjaChbImFqYXhTdGFydCIsImFqYXhTdG9wIiwiYWpheENvbXBsZXRlIiwiYWpheEVycm9yIiwiYWpheFN1Y2Nlc3MiLCJhamF4U2VuZCJdLGZ1bmN0aW9uKGUsdCl7Uy5mblt0XT1mdW5jdGlvbihlKXtyZXR1cm4gdGhpcy5vbih0LGUpfX0pLFMuZm4uZXh0ZW5kKHtiaW5kOmZ1bmN0aW9uKGUsdCxuKXtyZXR1cm4gdGhpcy5vbihlLG51bGwsdCxuKX0sdW5iaW5kOmZ1bmN0aW9uKGUsdCl7cmV0dXJuIHRoaXMub2ZmKGUsbnVsbCx0KX0sZGVsZWdhdGU6ZnVuY3Rpb24oZSx0LG4scil7cmV0dXJuIHRoaXMub24odCxlLG4scil9LHVuZGVsZWdhdGU6ZnVuY3Rpb24oZSx0LG4pe3JldHVybiAxPT09YXJndW1lbnRzLmxlbmd0aD90aGlzLm9mZihlLCIqKiIpOnRoaXMub2ZmKHQsZXx8IioqIixuKX0saG92ZXI
6ZnVuY3Rpb24oZSx0KXtyZXR1cm4gdGhpcy5tb3VzZWVudGVyKGUpLm1vdXNlbGVhdmUodHx8ZSl9fSksUy5lYWNoKCJibHVyIGZvY3VzIGZvY3VzaW4gZm9jdXNvdXQgcmVzaXplIHNjcm9sbCBjbGljayBkYmxjbGljayBtb3VzZWRvd24gbW91c2V1cCBtb3VzZW1vdmUgbW91c2VvdmVyIG1vdXNlb3V0IG1vdXNlZW50ZXIgbW91c2VsZWF2ZSBjaGFuZ2Ugc2VsZWN0IHN1Ym1pdCBrZXlkb3duIGtleXByZXNzIGtleXVwIGNvbnRleHRtZW51Ii5zcGxpdCgiICIpLGZ1bmN0aW9uKGUsbil7Uy5mbltuXT1mdW5jdGlvbihlLHQpe3JldHVybiAwPGFyZ3VtZW50cy5sZW5ndGg/dGhpcy5vbihuLG51bGwsZSx0KTp0aGlzLnRyaWdnZXIobil9fSk7dmFyIEd0PS9eW1xzXHVGRUZGXHhBMF0rfFtcc1x1RkVGRlx4QTBdKyQvZztTLnByb3h5PWZ1bmN0aW9uK
GUsdCl7dmFyIG4scixpO2lmKCJzdHJpbmciPT10eXBlb2YgdCYmKG49ZVt0XSx0PWUsZT1uKSxtKGUpKXJldHVybiByPXMuY2FsbChhcmd1bWVudHMsMiksKGk9ZnVuY3Rpb24oKXtyZXR1cm4gZS5hcHBseSh0fHx0aGlzLHIuY29uY2F0KHMuY2FsbChhcmd1bWVudHMpKSl9KS5ndWlkPWUuZ3VpZD1lLmd1aWR8fFMuZ3VpZCsrLGl9LFMuaG9sZFJlYWR5PWZ1bmN0aW9uKGUpe2U/Uy5yZWFkeVdhaXQrKzpTLnJlYWR5KCEwKX0sUy5pc0FycmF5PUFycmF5LmlzQXJyYXksUy5wYXJzZUpTT049SlNPTi5wYXJzZSxTLm5vZGVOYW1lPUEsUy5pc0Z1bmN0aW9uPW0sUy5pc1dpbmRvdz14LFMuY2FtZWxDYXNlPVgsUy50eXBlPXcsUy5ub3c9RGF0ZS5ub3csUy5pc051bWVyaWM9ZnVuY3Rpb24oZSl7dmFyIHQ9Uy50eXBlKGUpO3JldHVybigibnVtYmVyIj0
9PXR8fCJzdHJpbmciPT09dCkmJiFpc05hTihlLXBhcnNlRmxvYXQoZSkpfSxTLnRyaW09ZnVuY3Rpb24oZSl7cmV0dXJuIG51bGw9PWU/IiI6KGUrIiIpLnJlcGxhY2UoR3QsIiIpfSwiZnVuY3Rpb24iPT10eXBlb2YgZGVmaW5lJiZkZWZpbmUuYW1kJiZkZWZpbmUoImpxdWVyeSIsW10sZnVuY3Rpb24oKXtyZXR1cm4gU30pO3ZhciBZdD1DLmpRdWVyeSxRdD1DLiQ7cmV0dXJuIFMubm9Db25mbGljdD1mdW5jdGlvbihlKXtyZXR1cm4gQy4kPT09UyYmKEMuJD1RdCksZSYmQy5qUXVlcnk9PT1TJiYoQy5qUXVlcnk9WXQpLFN9LCJ1bmRlZmluZWQiPT10eXBlb2YgZSYmKEMualF1ZXJ5PUMuJD1TKSxTfSk7Cg==]]


local TormyLOGO = [[iVBORw0KGgoAAAANSUhEUgAAAGcAAAByCAMAAAB5hD/jAAABgmlDQ1BzUkdCIElFQzYxOTY2LTIuMQAAKJF1kb9LQlEUxz9qkqRRUEFDg4Q1WZRB1NKglAXVoAZZLfryR6D2eE8JaQ1ahYKopV9D/QW1Bs1BUBRBtAXNRS0lr/MyUCLP5dzzud97z+Hec8EayShZvWEAsrm8Fgr63fPRBXfjM07sdODDEVN0dSY8EaGufdxhMeNNn1mr/rl/zbmc0BWwOITHFFXLC08KT6/lVZO3hduVdGxZ+FTYq8kFhW9NPV7hF5NTFf4yWYuEAmBtFXanajhew0paywrLy/FkMwXl9z7mS1yJ3FxYYrd4FzohgvhxM8U4AYYZZFTmYfqkP/2yok7+wE/+LKuSq8isUkRjhRRp8nhFLUj1hMSk6AkZGYpm///2VU8O+SrVXX6wPxnGWw80bkG5ZBifh4ZRPgLbI1zkqvmrBzDyLnqpqnn2oWUDzi6rWnwHzjeh80GNabEfySZuTSbh9QSao9B2DU2LlZ797nN8D5F
1+aor2N2DXjnfsvQNYv1n5L4Jy7gAAAAJcEhZcwAACxMAAAsTAQCanBgAAAL3UExURQAAAP////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////xjeeXgAAAD8dFJOUwABAgMEBQYHCAkKCwwNDg8QERITFBUWFxgZGhscH
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]]


local TVCELogo = [[iVBORw0KGgoAAAANSUhEUgAAAI8AAACOCAMAAAA/4asEAAABgmlDQ1BzUkdCIElFQzYxOTY2LTIuMQAAKJF1kb9LQlEUxz9qkqRRUEFDg4Q1WZRB1NKglAXVoAZZLfryR6D2eE8JaQ1ahYKopV9D/QW1Bs1BUBRBtAXNRS0lr/MyUCLP5dzzud97z+Hec8EayShZvWEAsrm8Fgr63fPRBXfjM07sdODDEVN0dSY8EaGufdxhMeNNn1mr/rl/zbmc0BWwOITHFFXLC08KT6/lVZO3hduVdGxZ+FTYq8kFhW9NPV7hF5NTFf4yWYuEAmBtFXanajhew0paywrLy/FkMwXl9z7mS1yJ3FxYYrd4FzohgvhxM8U4AYYZZFTmYfqkP/2yok7+wE/+LKuSq8isUkRjhRRp8nhFLUj1hMSk6AkZGYpm///2VU8O+SrVXX6wPxnGWw80bkG5ZBifh4ZRPgLbI1zkqvmrBzDyLnqpqnn2oWUDzi6rWnwHzjeh80GNabEfySZuTSbh9QSao9B2DU2LlZ797nN8D5F1
+aor2N2DXjnfsvQNYv1n5L4Jy7gAAAAJcEhZcwAALiMAAC4jAXilP3YAAAMAUExURQAAAP/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////wc9CwgAAAD/dFJOUwABAgMEBQYHCAkKCwwNDg8QERITFB
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]]


local REAPERLogo = [[iVBORw0KGgoAAAANSUhEUgAAAGQAAABrCAYAAACBtCeBAAAFoGlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS41LjAiPgogPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4KICA8cmRmOkRlc2NyaXB0aW9uIHJkZjphYm91dD0iIgogICAgeG1sbnM6dGlmZj0iaHR0cDovL25zLmFkb2JlLmNvbS90aWZmLzEuMC8iCiAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyIKICAgIHhtbG5zOnBob3Rvc2hvcD0iaHR0cDovL25zLmFkb2JlLm
NvbS9waG90b3Nob3AvMS4wLyIKICAgIHhtbG5zOnhtcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyIKICAgIHhtbG5zOnhtcE1NPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvbW0vIgogICAgeG1sbnM6c3RFdnQ9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9zVHlwZS9SZXNvdXJjZUV2ZW50IyIKICAgdGlmZjpJbWFnZUxlbmd0aD0iMTA3IgogICB0aWZmOkltYWdlV2lkdGg9IjEwMCIKICAgdGlmZjpSZXNvbHV0aW9uVW5pdD0iMiIKICAgdGlmZjpYUmVzb2x1dGlvbj0iMzAwLzEiCiAgIHRpZmY6WVJlc29sdXRpb249IjMwMC8xIgogICBleGlmOlBpeGVsWERpbWVuc2lvbj0iMTAwIgogICBleGlmOlBpeGVsWURpbWVuc2lvbj0iMTA3IgogICBleGlmOkNvbG9yU3BhY2U9IjEiCiAgIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiC
iAgIHBob3Rvc2hvcDpJQ0NQcm9maWxlPSJzUkdCIElFQzYxOTY2LTIuMSIKICAgeG1wOk1vZGlmeURhdGU9IjIwMjEtMTEtMDVUMjM6NDU6MzArMDE6MDAiCiAgIHhtcDpNZXRhZGF0YURhdGU9IjIwMjEtMTEtMDVUMjM6NDU6MzArMDE6MDAiPgogICA8dGlmZjpCaXRzUGVyU2FtcGxlPgogICAgPHJkZjpTZXE+CiAgICAgPHJkZjpsaT44PC9yZGY6bGk+CiAgICA8L3JkZjpTZXE+CiAgIDwvdGlmZjpCaXRzUGVyU2FtcGxlPgogICA8dGlmZjpZQ2JDclN1YlNhbXBsaW5nPgogICAgPHJkZjpTZXE+CiAgICAgPHJkZjpsaT4yPC9yZGY6bGk+CiAgICAgPHJkZjpsaT4yPC9yZGY6bGk+CiAgICA8L3JkZjpTZXE+CiAgIDwvdGlmZjpZQ2JDclN1YlNhbXBsaW5nPgogICA8eG1wTU06SGlzdG9yeT4KICAgIDxyZGY6U2VxPgogICAgIDxyZGY6bGkKICAgICAg
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]]

----------------------------------------------
-- MAIN HEADERS
----------------------------------------------
      
local metaDataCSV = MetaMP3(2)..
                    MetaBWF(2)..
                    MetaAXML(2)..
                    MetaCART(2)..
                    MetaIFF(2)..
                    MetaCUE(2)..
                    MetaINFO(2)..
                    MetaIXML(2)..
                    MetaFLACPIC(2)..
                    MetaXMP(2)..
                    MetaAPE(2)..
                    MetaVORBIS(2)..
                    MetaWAVEXT(2)..
                    MetaASWG(2)..
                    MetaCAFINFO(2)
                    
local PageHeaderCSV = 'PROJECT:'..LF..'Name: '..pj_name_..LF..'Sample Rate: '..pj_sampleRate..'Hz'..LF..'Duration: '..SecondsToHMS(pj_length)..LF..LF..
                      'TOTAL TRACKS: ' .. reaper.CountTracks() ..LF..LF..
                      'DAW:'..LF ..'REAPER v.' .. version ..LF..LF..
                      'CREATED:'..LF .. date ..LF..LF..
                      'AUTHOR:'..LF..Creator..LF..LF..
                      "Exported with 'EXPORT DATA' v." .. scriptVersion .. " by "..Creator..LF..LF..'CATEGORY,DESCRIPTION,META [FORMAT],TAG CODE,VALUE'..LF..metaDataCSV..LF..LF..
                      'RENDERED AUDIO'..LF..'PATH,FILE NAME,FULL PATH'..LF..scandir(renderPath,2)
local PageHeaderHTML = [[
<html lang="en">
  <head>
  <meta charset="utf-8"/>
     <script>]].. dec(jQuery)..[[</script>
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
     th.mainHeader, th.header { background: #2db1ef; color: white; font-size: 51px; position: relative;}
     th.mainHeader{ height: 150px; }
     th.header { height: 81px; }
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
     img#TormyLOGO { position: absolute; left: 20px; top: 19px; width: 100px;}
     img#TVCELogo { width: 120px; position: absolute; left: 139px; top: 15px;}
     img#REAPERLogo {position: absolute; top: 12px; right: 20px; }
     th#PlayerAudio { width: 200; }
     .LinkTitle{color: red}
     
     
     .modal {
       display: none; /* Hidden by default */
       position: fixed; /* Stay in place */
       z-index: 1; /* Sit on top */
       padding-top: 100px; /* Location of the box */
       left: 0;
       top: 0;
       width: 100%; /* Full width */
       height: 100%; /* Full height */
       overflow: auto; /* Enable scroll if needed */
       background-color: rgb(0,0,0); /* Fallback color */
       background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
     }
     
     /* Modal Content */
     .modal-content {
       background-color: #fefefe;
       margin: auto;
       padding: 20px;
       border: 1px solid #888;
       width: 80%;
     }
     
     /* The Close Button */
     .close {
       color: #aaaaaa;
       float: right;
       font-size: 28px;
       font-weight: bold;
     }
     
     .close:hover,
     .close:focus {
       color: #000;
       text-decoration: none;
       cursor: pointer;
     }
     </style>
     <script>
      $(document).ready(function() {
          $("tr.slave").hide()
          $("span.collapseMetaData").hide()
          $("tr.MetaData").hide()
          $("span.collapseRendered").hide()
          $("tr.Rendered").hide()
          $("tr.slaveNoted").hide()
          $("tr.slaveFXedItems").hide()
          $("span.collapse").hide()
          $("span.collapseNoted").hide()
          $("span.collapseFXedItems").hide()
          $("tr.slaveNotedItems").hide()
          $("span.collapseNotedItems").hide()
          $("tr.slaveTempoMarkers").hide()
          $("span.collapseTempoMarkers").hide()
          $("tr.slaveHier").hide()
          $("span.collapseHier").hide()
          $("tr.slaveMaster").hide()
          $("span.collapseMaster").hide()
          
          // METADATA
          $("tr.childID3").hide()
          $("span.collapseID3").hide()
          $("tr.childBWF").hide()
          $("span.collapseBWF").hide()
          $("tr.childAXML").hide()
          $("span.collapseAXML").hide()
          $("tr.childCART").hide()
          $("span.collapseCART").hide()
          $("tr.childIFF").hide()
          $("span.collapseIFF").hide()
          $("tr.childCUE").hide()
          $("span.collapseCUE").hide()
          $("tr.childINFO").hide()
          $("span.collapseINFO").hide()
          $("tr.childIXML").hide()
          $("span.collapseIXML").hide()
          $("tr.childFLACPIC").hide()
          $("span.collapseFLACPIC").hide()
          $("tr.childXMP").hide()
          $("span.collapseXMP").hide()
          $("tr.childAPE").hide()
          $("span.collapseAPE").hide()
          $("tr.childVORBIS").hide()
          $("span.collapseVORBIS").hide()
          $("tr.childWAVEXT").hide()
          $("span.collapseWAVEXT").hide()
          $("tr.childASWG").hide()
          $("span.collapseASWG").hide()
          $("tr.childCAFINFO").hide()
          $("span.collapseCAFINFO").hide()
          
          
          $(".masterRendered").click(function() {
             $("tr.Rendered").toggle(500);
             $("span.collapseRendered").toggle(500)
             $("span.expandRendered").toggle(500)
          });
          
          $(".masterMetaData").click(function() {
             $("tr.metaData").toggle(500);
             $("span.collapseMetaData").toggle(500)
             $("span.expandmetaData").toggle(500)
          });
          
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
          
          $(".masterTempoMarkers").click(function() {
             $("tr.slaveTempoMarkers").toggle(500);
             $("span.collapseTempoMarkers").toggle(500)
             $("span.expandTempoMarkers").toggle(500)
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
                                        
          $(".catID3").click(function () { 
             $(".childID3").toggle(500);
             $("span.collapseID3").toggle(500)
             $("span.expandID3").toggle(500)
          });
                                        
          $(".catBWF").click(function () { 
             $(".childBWF").toggle(500);
             $("span.collapseBWF").toggle(500)
             $("span.expandBWF").toggle(500)
          });
                                        
          $(".catAXML").click(function () { 
             $(".childAXML").toggle(500);
             $("span.collapseAXML").toggle(500)
             $("span.expandAXML").toggle(500)
          });
                                        
          $(".catCART").click(function () { 
             $(".childCART").toggle(500);
             $("span.collapseCART").toggle(500)
             $("span.expandCART").toggle(500)
          });
          
          $(".catIFF").click(function () { 
             $(".childIFF").toggle(500);
             $("span.collapseIFF").toggle(500)
             $("span.expandIFF").toggle(500)
          });
          
          $(".catCUE").click(function () { 
             $(".childCUE").toggle(500);
             $("span.collapseCUE").toggle(500)
             $("span.expandCUE").toggle(500)
          });      
          
          $(".catINFO").click(function () { 
             $(".childINFO").toggle(500);
             $("span.collapseINFO").toggle(500)
             $("span.expandINFO").toggle(500)
          });     
          
          $(".catIXML").click(function () { 
             $(".childIXML").toggle(500);
             $("span.collapseIXML").toggle(500)
             $("span.expandIXML").toggle(500)
          });     
          
          $(".catFLACPIC").click(function () { 
             $(".childFLACPIC").toggle(500);
             $("span.collapseFLACPIC").toggle(500)
             $("span.expandFLACPIC").toggle(500)
          });     
          
          $(".catXMP").click(function () { 
             $(".childXMP").toggle(500);
             $("span.collapseXMP").toggle(500)
             $("span.expandXMP").toggle(500)
          });    
          
          $(".catAPE").click(function () { 
             $(".childAPE").toggle(500);
             $("span.collapseAPE").toggle(500)
             $("span.expandAPE").toggle(500)
          });   
          
          $(".catVORBIS").click(function () { 
             $(".childVORBIS").toggle(500);
             $("span.collapseVORBIS").toggle(500)
             $("span.expandVORBIS").toggle(500)
          }); 
          
          $(".catWAVEXT").click(function () { 
             $(".childWAVEXT").toggle(500);
             $("span.collapseWAVEXT").toggle(500)
             $("span.expandWAVEXT").toggle(500)
          });
          
          $(".catASWG").click(function () { 
             $(".childASWG").toggle(500);
             $("span.collapseASWG").toggle(500)
             $("span.expandASWG").toggle(500)
          });
          
          $(".catCAFINFO").click(function () { 
             $(".childCAFINFO").toggle(500);
             $("span.collapseCAFINFO").toggle(500)
             $("span.expandCAFINFO").toggle(500)
          });
      });
          
      
    
    </script>
  </head>
  <body> 
    <table class="center">
      <thead>
        <tr><th colspan="8" class="mainHeader">
        <a href="]]..TormyURL..[[" target="_blank"><img id="TormyLOGO" src="data:image/png;base64, ]]..TormyLOGO..[[" /></a>
        <a href="]]..TVCEURL..[[" target="_blank"><img id="TVCELogo" src="data:image/png;base64, ]]..TVCELogo..[[" /></a>
        <a href="]]..reaperURL..[[" target="_blank"><img id="REAPERLogo" src="data:image/png;base64, ]]..REAPERLogo..[[" /></a>
        PROJECT DATA<sub>Created: ]] .. date .. 
        [[ with 'EXPORT DATA' v.]].. scriptVersion .. 
        [[ by ]]..Creator..[[</sub></th></tr>
      </thead>
      <tbody>
        <tr><td colspan="8" class="centertext markersregions">MAIN DATA</td></tr>
        <tr class="table_header">
          <th id="hd_project">PROJECT</th>
          <th id="hd_total">TOTAL TRACKS</th>
          <th id="hd_items">ITEMS</th>
          <th id="hd_markers">MARKERS</th>
          <th id="hd_regions">REGIONS</th>
          <th id="hd_notes"colspan="3">NOTES</th>
        </tr>
        <tr><td class="left"><span class="label">Name:</span> ]]..pj_name_..
          '<br/><span class="label">Song Title:</span> '..pj_title..
          '<br/><span class="label">Song Author:</span> '..author..
          '<br/><span class="label">DAW Version:</span> '..version..
          '<br/><span class="label">Sample Rate:</span> '..round(pj_sampleRate,0)..' Hz'..
          '<br/><span class="label">Project Length:</span> '..SecondsToHMS(pj_length)..
          '<br/><span class="label">Project BPM (Tempo):</span> '..reaper.Master_GetTempo(0)..'</td>'..
          '<td class="centertext">'.. reaper.CountTracks() ..'</td>'..
          '<td class="centertext">'..totalMediaItems..'</td>'..
          '<td class="centertext">'..totalMarkers..'</td>'..
          '<td class="centertext">'..totalRegions..'</td>'..
          '<td colspan="3">'..pj_notes..[[
      </td></tr>]]
      
local PageHeaderMetaDataHTML =[[
     <table class="center">
      <thead>
        <tr>
          <th colspan="6" class="header">
          <span class="info expandMetaData emboss pointer masterMetaData">&#x25BC;</span>
          <span class="info collapsemetaData engrave pointer masterMetaData">&#x25B2;</span>
          METADATA
          </th>
        </tr>
      </thead>
      <tbody>
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandID3 emboss pointer catID3">&#x25BC;</span>
      <span class="info collapseID3 engrave pointer catID3">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..BBCID3..[[">ID3</a> (IDentify an MP3) (No User Defined)</td></tr>
      <tr class="table_header childID3">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>ID3</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaMP3(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandBWF emboss pointer catBWF">&#x25BC;</span>
      <span class="info collapseBWF engrave pointer catBWF">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..BWFDoc..[[">BWF</a> (Broadcast Wave Format)</td></tr>
      <tr class="table_header childBWF">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>BWF</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaBWF(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandAXML emboss pointer catAXML">&#x25BC;</span>
      <span class="info collapseAXML engrave pointer catAXML">&#x25B2;</span>
      AXML (Audio eXtended Markup Language)</td></tr>
      <tr class="table_header childAXML">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>AXML</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaAXML(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandCART emboss pointer catCART">&#x25BC;</span>
      <span class="info collapseCART engrave pointer catCART">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..AESDoc..[[">CART<a> (AES46-2002)</td></tr>
      <tr class="table_header childCART">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>CART</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaCART(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandIFF emboss pointer catIFF">&#x25BC;</span>
      <span class="info collapseIFF engrave pointer catIFF">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..IFFDoc..[[">IFF</a> (Interchange File Format)</td></tr>
      <tr class="table_header childIFF">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>IFF</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaIFF(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandCUE emboss pointer catCUE">&#x25BC;</span>
      <span class="info collapseCUE engrave pointer catCUE">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..CUEDoc..[[">CUE</a> (Cue Sheet)</td></tr>
      <tr class="table_header childCUE">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>CUE</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaCUE(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandINFO emboss pointer catINFO">&#x25BC;</span>
      <span class="info collapseINFO engrave pointer catINFO">&#x25B2;</span>
      INFO</td></tr>
      <tr class="table_header childINFO">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>INFO</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaINFO(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandIXML emboss pointer catIXML">&#x25BC;</span>
      <span class="info collapseIXML engrave pointer catIXML">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..iXMLDoc..[[">IXML</a> (No User Defined)</td></tr>
      <tr class="table_header childIXML">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>IXML</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaIXML(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandFLACPIC emboss pointer catFLACPIC">&#x25BC;</span>
      <span class="info collapseFLACPIC engrave pointer catFLACPIC">&#x25B2;</span>
      FLACPIC (FLAC Picture)</td></tr>
      <tr class="table_header childFLACPIC">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>FLACPIC</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaFLACPIC(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandXMP emboss pointer catXMP">&#x25BC;</span>
      <span class="info collapseXMP engrave pointer catXMP">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..XMPDoc..[[">XMP</a> (eXtensible Meta Platform)</td></tr>
      <tr class="table_header childXMP">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>XMP</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaXMP(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandAPE emboss pointer catAPE">&#x25BC;</span>
      <span class="info collapseAPE engrave pointer catAPE">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..APEDoc..[[">APE</a> (No User Defined)</td></tr>
      <tr class="table_header childAPE">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>APE</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaAPE(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandVORBIS emboss pointer catVORBIS">&#x25BC;</span>
      <span class="info collapseVORBIS engrave pointer catVORBIS">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..VORBISDoc..[[">VORBIS</a> (No User Defined)</td></tr>
      <tr class="table_header childVORBIS">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>VORBIS</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaVORBIS(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandWAVEXT emboss pointer catWAVEXT">&#x25BC;</span>
      <span class="info collapseWAVEXT engrave pointer catWAVEXT">&#x25B2;</span>
      <a class="LinkTitle" href="#">WAVEXT</a> (S.M.P.T.E.)</td></tr>
      <tr class="table_header childWAVEXT">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>METAWAVEXT</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaWAVEXT(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandASWG emboss pointer catASWG">&#x25BC;</span>
      <span class="info collapseASWG engrave pointer catASWG">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..SonyASWG..[[">ASWG</a> (Sony Audio Standard Working Group)</td></tr>
      <tr class="table_header childASWG">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>ASWG</th>
        <th colspan="5">VALUE</th>
      </tr>
      
      
      ]]..MetaASWG(1)..[[
      <tr class="MetaData"><td colspan="8" class="centertext markersregions">
      <span class="info expandCAFINFO emboss pointer catCAFINFO">&#x25BC;</span>
      <span class="info collapseCAFINFO engrave pointer catCAFINFO">&#x25B2;</span>
      <a class="LinkTitle" target="_blank" href="]]..AppleCAFINFO..[[">CAFINFO</a> (Core Audio Format - Apple standard))</td></tr>
      <tr class="table_header childCAFINFO">
        <th>CATEGORY</th>
        <th>DESCRIPTION</th>
        <th>CAFINFO</th>
        <th colspan="5">VALUE</th>
      </tr>
      ]]..MetaCAFINFO(1)
                    

local MarkersRegionsHeaderCSV = 'NAME,COLOR,TYPE,NUMBER,IDX,START POSITION '..timeFormat..', END POSITION (if Region)  '..timeFormat..',DURATION (if Region) '..timeFormat..LF..'MARKERS' 
local MarkersRegionsHeaderHTML = '<tr><td colspan="8" class="centertext markersregions">MARKERS</td></tr>'..
      '<tr class="table_header"><th class="centertext">NAME</th>'..
      '<th class="colorMarkerRegion">COLOR</th>'..
      '<th class="centertext">TYPE</th>'..
      '<th class="centertext">NUMBER</th>'..
      '<th class="centertext">IDX</th>'..
      '<th class="centertext">START POSITION<br>'..timeFormat..'</th>'..
      '<th class="centertext">END POSITION (if Region)<br>'..timeFormat..'</th>'..
      '<th class="centertext">DURATION (if Region)<br>'..timeFormat..'</th></tr>'

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
                            ','..SecondsToHMS(pj_MarkersRegions(idx).MR_Pos)..
                            ','..pj_MarkersRegions(idx).MR_Rgnend..
                            ','..pj_MarkersRegions(idx).MR_Duration
                            
            local lineHTML =  '<tr><td>'..pj_MarkersRegions(idx).MR_Name..'</td>'..
                              '<td style="background-color: rgb('..pj_MarkersRegions(idx).MR_ColorR..
                                    ','..pj_MarkersRegions(idx).MR_ColorG..
                                    ','..pj_MarkersRegions(idx).MR_ColorB..');"></td>'..            
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Isrgn..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Number..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Markrgnindexnumber..'</td>'..
                              '<td class="right">'..SecondsToHMS(pj_MarkersRegions(idx).MR_Pos)..'</td>'..
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
                            ','..SecondsToHMS(pj_MarkersRegions(idx).MR_Pos)..
                            ','..SecondsToHMS(pj_MarkersRegions(idx).MR_Rgnend)..
                            ','..SecondsToHMS(pj_MarkersRegions(idx).MR_Duration)
                            
            local lineHTML =  '<tr><td>'..pj_MarkersRegions(idx).MR_Name..'</td>'..
                              '<td style="background-color: rgb('..pj_MarkersRegions(idx).MR_ColorR..
                                    ','..pj_MarkersRegions(idx).MR_ColorG..
                                    ','..pj_MarkersRegions(idx).MR_ColorB..');"></td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Isrgn..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Number..'</td>'..
                              '<td class="centertext">'..pj_MarkersRegions(idx).MR_Markrgnindexnumber..'</td>'..
                              '<td class="right">'..SecondsToHMS(pj_MarkersRegions(idx).MR_Pos)..'</td>'..
                              '<td class="right">'..SecondsToHMS(pj_MarkersRegions(idx).MR_Rgnend)..'</td>'..
                              '<td class="right">'..SecondsToHMS(pj_MarkersRegions(idx).MR_Duration)..'</td></tr>'
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

local PageHeaderAudioCSV = ''
local PageHeaderAudioHTML =[[
     <table class="center">
      <thead>
        <tr>
          <th colspan="6" class="header">
          <span class="info expandRendered emboss pointer masterRendered">&#x25BC;</span>
          <span class="info collapseRendered engrave pointer masterRendered">&#x25B2;</span>
          RENDERED AUDIO
          </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header Rendered">]]..
        '<th id="PathAudio">FILE PATH</th>'..
        '<th id="NameAudio">FILE NAME</th>'..
        '<th id="PlayerAudio">PLAYER</th></tr>'..
        scandir(renderPath,1)..'</tbody></table><div class="spacer">&nbsp;</div>'


local PageHeaderMasterCSV = LF..LF..'MASTER CHANNEL:'..LF..'FX NAME,FX En./Byp.,FX On Line/Off Line,FILE NAME'
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
        
local PageHeaderHierarchyCSV = LF..LF..'HIERARCHY:'..LF..'NAME,TYPE,SOLO,MUTE,N.ITEMS,TCP,MCP,FX'
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
        
local tableFXTracksHeaderCSV = LF..LF..'EFFECTED TRACKS:'..LF..'TRACK IDX,TRACK NAME,TRACK TYPE,NOTES,FX CHAIN En./Dis.,N. ITEMS,SOLO,MUTE,FX/INSTRUMENTS NAME (VST/VSTi),FX En./Byp.,FX OnLine/OffLine,FX File'
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
        
local PageHeaderCSVNoted = LF..LF..'NOTED TRACKS:'..LF..'TRACK IDX,TRACK NAME,TRACK TYPE,NOTES,N. ITEMS,SOLO,MUTE'
local tableNotedTracksHeader = [[
   <table class="center">
      <thead>
        <tr>
          <th colspan="7" class="header">
            <span class="info expandNoted emboss pointer masterNoted">&#x25BC;</span>
            <span class="info collapseNoted engrave pointer masterNoted">&#x25B2;</span>NOTED TRACKS (Only noted! No FX)
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
        
local PageHeaderItemsFXedCSV = LF..LF..'EFFECTED ITEMS:'..LF..'TRACK NAME,FX,ITEM POSITION '..timeFormat..',ITEM LENGTH <br>'..timeFormat..',NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
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
          <th class="EffectedItems">POSITION<br>]]..timeFormat..[[</th>
          <th class="EffectedItems">LENGTH<br>]]..timeFormat..[[</th>
          <th>NOTES</th>
          <th class="EffectedItems">MUTE</th>
          <th class="EffectedItems">LOCKED</th>
          <th>SOURCE NAME</th>
          <th class="EffectedItems">SAMPLE RATE</th>
          <th class="EffectedItems">BIT DEPTH</th>
        </tr>]]
        
local PageHeaderNotedItemsCSV = LF..LF..'NOTED ITEMS:'..LF..'TRACK NAME,ITEM POSITION '..timeFormat..',ITEM LENGTH '..timeFormat..',NOTE,MUTE,LOCKED,SOURCE FILE NAME,SAMPLE RATE,BIT DEPTH'
local PageHeaderNotedItemsHTML = [[
    <table class="center">
      <thead>
        <tr><th colspan="9" class="header">
              <span class="info expandNotedItems emboss pointer masterNotedItems">&#x25BC;</span>
              <span class="info collapseNotedItems engrave pointer masterNotedItems">&#x25B2;</span>NOTED ITEMS DATA (Only noted! No FX)
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
          <th>BELONGIN TO</th><th>POSITION<br>]]..timeFormat..[[</th>
          <th>LENGTH<br>]]..timeFormat..[[</th><th>NOTES</th>
          <th class="EffectedItems">MUTE</th>
          <th class="EffectedItems">LOCKED</th>
          <th>SOURCE NAME</th>
          <th class="EffectedItems">SAMPLE RATE</th>
          <th class="EffectedItems">BIT DEPTH</th>
        </tr>]]


    
local PageHeaderCSVTempo = LF..LF..'TEMPO MARKERS:'..LF..'TRACK IDX,TRACK NAME,TRACK TYPE,NOTES,N. ITEMS,SOLO,MUTE'
local tableTempoMarkersHeader = [[
    <table class="center">
      <thead>
        <tr>
          <th colspan="9" class="header">
            <span class="info expandTempoMarkers emboss pointer masterTempoMarkers">&#x25BC;</span>
            <span class="info collapseTempoMarkers engrave pointer masterTempoMarkers">&#x25B2;</span>TEMPO MARKERS
          </th>
        </tr>
      </thead>
      <tbody>
        <tr class="table_header slaveTempoMarkers">
          <th>Marker N.</th>
          <th>BPM</th>
          <th>Time Position</th>
          <th>Measure Position</th>
          <th>Beat</th>
          <th>Beat Position</th>
          <th>Samples</th>
          <th>Tempo Fractional</th>
          <th>Tempo Linearity</th>
        </tr>]]

local PageFooterHTML = "  "..LF.."</body>"..LF.."</html>"



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


function pj_tempo_Markers()
  WriteFILE(tableTempoMarkersHeader,PageHeaderCSVTempo)
  local howmany = reaper.CountTempoTimeSigMarkers(0) -- counts markers QTY
  local count = 0
  local ConsMsg = ''
  local separator = ','
  local NS = 'Not Set'
  
  ----------------------------------------------
  -- DEDICATED FILES
  ----------------------------------------------
  local fileName = "Tempo_Markers"
  local CSV_name = fileName .. ".csv"
  local TXT_name = fileName .. ".txt"
  
  local CSV_file = io.open(pj_path..'\\'..CSV_name, "w")
  local TXT_file = io.open(pj_path..'\\'..TXT_name, "w")

  --local CSV_header = LF .. 'TEMPO MARKERS'
  local CSV_header = nameField_0 .. separator .. 
               nameField_1 .. separator .. 
               nameField_2 .. separator .. 
               nameField_3 .. separator .. 
               nameField_4 .. separator ..
               nameField_5 .. separator .. 
               nameField_6 .. separator .. 
               nameField_8 .. separator .. 
               nameField_9 .. separator ..
               nameField_10 .. LF
  local TXT_header = 'TEMPO MARKERS version '.. scriptVersion .. LF .. 'by ' .. Creator .. LF .. LF
  TXT_file:write(TXT_header)
  CSV_file:write(CSV_header)
  WriteFILE('',CSV_header)

  while count < howmany do
    local retval, timepos, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo = reaper.GetTempoTimeSigMarker(0, count) -- Extract markers infos
    local fractional, curveType, tempoType = ''
    if timesig_num < 0 or timesig_denom < 0  then 
      fractional = NS
    else
      fractional = timesig_num.."/"..timesig_denom
    end
    if lineartempo == true then
      curveType = "Linear"
      tempoType = "1"
    else
      curveType = "Square"
      tempoType = "0"
    end
    local SampleQTY = reaper.format_timestr_pos( timepos, "", 4 )
    local Beat = reaper.format_timestr_pos( timepos, "", 2 )
    local csv = count .. separator .. 
                bpm .. separator .. 
                timepos .. separator .. 
                measurepos .. separator .. 
                Beat .. separator .. 
                beatpos .. separator .. 
                SampleQTY .. separator .. 
                timesig_num .. separator .. 
                timesig_denom .. separator ..
                tempoType .. LF
    local html = '<tr class="slaveTempoMarkers"><td class="right">'..count..
                     '</td><td class="right">'..bpm..
                     '</td><td class="right">'..SecondsToHMS(timepos)..
                     '</td><td class="right">'..SecondsToHMS(measurepos)..
                     '</td><td class="right">'..Beat..
                     '</td><td class="right">'..SecondsToHMS(beatpos)..
                     '</td><td class="right">'..SampleQTY..
                     '</td><td class="right">'..fractional..
                     '</td><td class="right">'..curveType..
                     "</td></tr>"
    local txt = nameField_0 .. ': '.. count .. LF ..
                nameField_1 .. ': ' .. bpm .. LF ..
                nameField_2 .. ': ' .. SecondsToHMS(timepos) .. LF ..
                nameField_3 .. ': ' .. SecondsToHMS(measurepos) .. LF ..
                nameField_4 .. ': ' .. Beat .. LF .. 
                nameField_5 .. ': ' .. SecondsToHMS(beatpos) .. LF ..
                nameField_6 .. ': ' .. SampleQTY .. LF ..
                nameField_7 .. ': ' .. fractional .. LF ..
                nameField_10 .. ': ' .. curveType .. LF .. LF
    ConsMsg = ConsMsg .. txt
    count = count +1
    CSV_file:write(csv)
    TXT_file:write(txt)
    WriteFILE(html,csv:gsub(LF,''))
  end
  CSV_file:close()
  TXT_file:close()
  -- reaper.ShowConsoleMsg(TXT_header .. LF .. ConsMsg)
end
----------------------------------------------
-- MAIN FUNCTIONS
----------------------------------------------
function Master()
    WriteFILE(PageHeaderMetaDataHTML,'')
    WriteFILE(PageHeaderAudioHTML,'')
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
    local csv_1 = LF..'MASTER TRACK SETTINGS:'..LF..'MUTE,SOLO,FX CHAIN,TCP,MCP,NOTES'..LF
    local csv_2 = ScanTracks(tr).isMutedCSV..','..ScanTracks(tr).isSoloedCSV..','..FX_ChainEnabledCSV..','..ScanTracks(tr).isHideTCPCSV..','..ScanTracks(tr).isHideMCPCSV..','..MasterNotesCSV
    WriteFILE(line_1..line_2..line_3..line_4..line_5,lineCSV..','..csv_1..csv_2)
    WriteFILE("  </tbody>"..LF.."</table>","")
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
  WriteFILE("  </tbody>"..LF.."</table>","")
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
  WriteFILE("  </tbody>"..LF.."</table>","")
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
  WriteFILE("  </tbody>"..LF.."</table>","")
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
                         '</td><td class="right">'..SecondsToHMS(round(itemPosition,precision))..
                         '</td><td class="right">'..SecondsToHMS(round(itemLength,precision))..
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
  WriteFILE("  </tbody>"..LF.."</table>","")
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
                        ','..SecondsToHMS(round(itemPosition,precision))..
                        ','..SecondsToHMS(round(itemLength,precision))..
                        ','..ridCommas(itemNotes)..
                        ','..isMutedCSV..
                        ','..isLockedCSV..
                        ','..itemFilename..
                        ','..sourceSampleRate..
                        ','..bitDepth
                        
              lineHTML = '   <tr class=\"tracks slaveNotedItems\"><td>'..itemTrackName..
                         '</td><td class="right">'..SecondsToHMS(round(itemPosition,precision))..
                         '</td><td class="right">'..SecondsToHMS(round(itemLength,precision))..
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
  WriteFILE("  </tbody>"..LF.."</table>"..LF..'<div class="spacer">&nbsp;</div>',"")
  reaper.UpdateArrange()
end


function closeFiles()
  f_csv:close()
  f_html:write( PageFooterHTML..LF )
  f_html:close()
  reaper.MB("Files CSV and HTML saved into the Project Folder:"..LF..LF..pj_path,"FILES EXPORT: DONE",0,0)
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
pj_tempo_Markers()
closeFiles()