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
  
  ------------------------------------------------
  -- CHECK if SWS is INSTALLED and Reaper Version
  ------------------------------------------------
  local test_SWS = reaper.CF_EnumerateActions
  if not test_SWS then
    reaper.MB('Please install or update SWS extension', 'ERROR: SWS IS MISSING', 0)
    exit()
  end
  
  local minVersion = '6.64'
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
    
    reaper.ShowConsoleMsg("1."..renderPath.."\n\n")
  ----------------------------------------------
  -- SCAN RENDERED AUDIO
  -- DIRECTORY = string = Path to the rendered audio files repository
  -- FORMAT = Integer  => 1 = HTML format. 2 = CSV format
  ----------------------------------------------
  function scandir(directory,format)
  reaper.ShowConsoleMsg("2."..directory.."\n\n")
  reaper.ShowConsoleMsg("3."..format.."\n\n")
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
      _OsBasedString = utf8_to_win(directory.."\\ls")
    end
    for filename in popen(_OsBasedString):lines() do
    reaper.ShowConsoleMsg("4."..filename.."\n\n")
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
    reaper.ShowConsoleMsg("5.".._OsBasedString.."\n")
    return t
  end
  reaper.ShowConsoleMsg(scandir(renderPath,2))