-- @description YOUTUBE Downloader
-- @about Import VIDEOs directly in TimeLine from YouTUBE, VIMEO, PATREONS and thousand other ones.
-- @author Tormy Van Cool
-- @version 2.8
-- @Changelog:
-- 2.4 2024-29-10 # Adjusted header style for production
-- 1.0 2024-26-10
--     # First Release
-- 1.1 2024-26-10
--     + Processes Notifications
--     - /Video/
--     + /Videos/
-- 1.2 2024-26-10
--     - --merge-output-format mp4
--     + -S vcodec:h264,res,acodec:aac
-- 1.3 2024-26-10
--     - 10
--     + 2
-- 1.4 2024-26-10
--     - 2
--     + 5
-- 1.5 2024-26-10
--     - 5
--     + 1
--     # Unified Update
-- 1.6 2024-26-10 - 1
--     + 2
--     + Version
-- 1.7 2024-27-10
--     - 'start "" "' from all O.S.s
--     + 'start "UPDATE & DOWNLOAD" "' Win
-- 1.8 2024-27-10
--     - GGGGG = ''
--     - 1
--     + Start = '"'
--     + 2
-- 1.9 2024-27-10
--     + Check saved project
--     - 1
--     + 2
-- 2.0 2024-27-10
--     - "chmod +x " ..  MainPath
--     + 'chmod +x "' ..  MainPath .. '"'
--     # Ordered Variables
--     - 2
--     + 1
--     + Apple Trial
-- 2.3 2024-27-10
--     # Linux execution correction
--     + Credits
--     # 2.1 and 2.2 just trials due issues with Linux and Apple
-- 2.31 2024-28-10
--     # Binaries directly form the source
-- 2.32 2024-28-10
--     - yt-dlp
--     + yt-dlp_linux
-- 2.4 2024-29-10
--     # Adjusted header style for production
-- 2.5 2024-11-04
--     - Various 
--     + VideoPath = 'Video'
-- 2.6 2024-11-05
--     + check for temrination of temporary file upfrotn import the video
-- 2.7 2024-11-05
--     - Check Routine
-- 2.8 2024-11-06
--     + Detects Nework Interruptions during download
--     + Removes leftovers
--     + URLs as filename: forbidden
--     + Limitation to only alphanumerical characters
-- @about:
-- # Import VIDEOs directly in TimeLine from YouTUBE, VIMEO, PATREONS and thousand other ones.
-- 
--    Key Features:
-- 
--    - 4 click operation: Start the script, enter the URL, give a title, click on OK
--    - Import any Video in TimeLine by giving just the URL
--    - Videos are saved into the project folder under the dedicated /Videos/ folder
--    - Videos are imported into a new track, having the given name, and at the cursor position
--    - Auto-update of the binaries "yt-dlp" each time the script is invoked, to ensure top quality at each use
--    - Compatible with about thousand platforms included:
--    - YouTUBE
--    - Vimeo
--    - Patreons
--    and several other ones ...
-- 
--   [Full list here](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md)
-- @Credits:
--    Stefano marcantoni and Talagan - to have helped for MAC implementation
--    Paolo Saggese - to have helped for Linux implementation
-- @provides
--   [windows] yt-dlp/yt-dlp.exe https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe
--   [linux] yt-dlp/yt-dlp_linux https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp
--   [darwin] yt-dlp/yt-dlp_macos https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_macos

reaper.ClearConsole()

---------------------------------------------
-- MAIN VARIABLES
---------------------------------------------
local LF = "\n"
local pipe = "|"
local colon = ":"
local quote = '"'
local slash = '\\'
local backslash = '/'
local clock = os.clock
local debug = false
local ver = 2.8
local InputVariable = ""
local dlpWin = 'yt-dlp.exe'
local dlpMac = 'yt-dlp_macos'
local dlpLnx = 'yt-dlp_linux'
local version = reaper.GetAppVersion()
local pj_name_ = reaper.GetProjectName(0, "")
local ProjDir = reaper.GetProjectPathEx(0)
local ResourcePATH = reaper.GetResourcePath()
local VideoPath = 'Video'
local CallPath = ResourcePATH .. '/Scripts/Tormy Van Cool ReaPack Scripts/' .. VideoPath .. '/yt-dlp/' -- Get FullPath to yt-dlp

---------------------------------------------
-- FUNCTIONS
---------------------------------------------
      
      -- SLEEP(SECONDS)
      function sleep(n)
        local t0 = clock()
        while clock() - t0 <= n do end
      end
      
      -- IDENTIFIES THE O.S.
      function getOS()
        local OS = reaper.GetOS()
        local a = {}
        local MainPath = ''
        if OS == "Win32" or OS == "Win64" then
          MainPath = '"' .. ResourcePATH .. '/Scripts/Tormy Van Cool ReaPack Scripts/' .. VideoPath .. '/yt-dlp/' .. dlpWin .. '"'
          Start = 'start /b /wait "UPDATE & DOWNLOAD" '
          OpSys = 1
        end
        if OS == "OSX32" or OS == "OSX64" or OS == "macOS-arm64" then
          MainPath  = './yt-dlp_macos'
          Start = 'cd "' .. CallPath .. '" && chmod +x ' .. dlpMac .. ' && '
          os.execute('chmod +x "' ..  MainPath .. '"')
          OpSys = 2
        end
        if OS == "Other" then
         -- MainPath = ResourcePATH .. '/Scripts/Tormy Van Cool ReaPack Scripts/Various/yt-dlp/' .. dlpLnx .. '"'
         -- Start = '"'
         -- os.execute('chmod +x "' ..  MainPath .. '"')
          MainPath = '"' .. ResourcePATH .. '/Scripts/Tormy Van Cool ReaPack Scripts/' .. VideoPath .. '/yt-dlp/' .. dlpLnx .. '"'
          Start = ''
          os.execute('chmod +x ' ..  MainPath)
          OpSys = 3
        end
        return MainPath
      end
      
      local MainPath = getOS()

      -- FILTER OUT PROHIITED CHARACTERS
      function GetRid(chappy, seed, subs) -- Get rid of not-admitted characters to prevent any error by user
        local ridchap
        if subs == nil then subs = "" end
        if chappy == nil then return end
        local ridchap = string.gsub (chappy, seed,  subs)
        return ridchap
      end

      -- CHECK FOR URL VALIDITY
      function is_valid_url(url)
        -- Pattern to match a basic URL structure
        local pattern = "^https?://[%w-_%.%?%.:/%+=&]+$"
        return url:match(pattern) ~= nil
      end

      local minVersion = '7.27'
      if minVersion > version then
        reaper.MB('your Reaper verions is '..version..'\nPlease update REAPER to the last version!', 'ERROR: REAPER '..version..' OUTDATED', 0)
        goto done
      end
---------------------------------------------
-- INTERACTIONS
---------------------------------------------

      -- CHECK WHETHER PROJECT IS SAVED
      if pj_name_ == "" then 
        reaper.MB("YOU MUST SAVE THE PROJECT FIRST! Then relaunch this script!",'WARNING',0)
        return
      end

      -- GET URL
      repeat
      retval, url=reaper.GetUserInputs("DOWNLOAD VIDEO", 1, "Paste URL,extrawidth=400", InputVariable)
      if retval==false then return end
      if retval then
        t = {}
        i = 0
        for line in url:gmatch("[^" .. LF .. "]*") do
            i = i + 1
            t[i] = line
        end
      end
      if t[1]== "" then
        reaper.MB("VIDEO URL is MANDATORY","ERROR",0,0)
      end
      if is_valid_url(t[1]) == false then
        reaper.MB("URL NOT VALID","ERROR",0,0)
      end
      until( t[1] ~= "" and is_valid_url(t[1]) == true)
      
      
      -- GET FILENAME
      repeat
      retval_1, FileName=reaper.GetUserInputs("DOWNLOAD VIDEO", 1, "Insert FILE NAME,extrawidth=400", InputVariable)
      FileName = GetRid(GetRid(GetRid(GetRid(GetRid(FileName, pipe), colon), quote), slash), backslash) -- No reserved characters can be written
      FileName = FileName:gsub("http", "")

      if retval_1==false then return end
      if retval_1 then
        t = {}
        i = 0
        for line in FileName:gmatch("[^" .. LF .. "]*") do
            i = i + 1
            t[i] = line
        end
      end
      
      -- NO EMPTY TITLE ADMITTED
      if t[1]== "" then
        reaper.MB("VIDEO TITLE is MANDATORY","ERROR",0,0)
      end
      
      -- NO URLS AND NOT ALPHANUMERICAL CHARACTERS ADMITTED
      if t[1]:match("[^%w%s]") then
        reaper.MB("ONLY ALPHANUMERIC CHARACTERS ADMITTED","ERROR",0,0)
        t[1]=""
      end
      until( t[1] ~= "")
      reaper.MB("STARTED THE FOLLOWING PROCESSES v" .. ver .. ":\n\n1. Update YT-DLP\n2. Downlaod the video: " ..url .. "\n3. Naming the video: " .. FileName .. ".mp4 \n4. Saving the video into " .. ProjDir .. "/Videos/\n5. Import the video into the project\n\nHEY it will take a little while. DON'T PANIC!\n\nCLICK ON \"OK\" TO CONTINUE", "PROCESS STARTED. PROCESSES LISTED HERE BELOW",0)

---------------------------------------------
-- ARGS & TRIGGERS
---------------------------------------------

      if FileName ~= "" 
        then
          if string.find(FileName, ".mp4") == nil then
            FileTemp = FileName .. '.f137.mp4.part'
            FileName = FileName .. ".mp4"
          end
          argument = ' -o "'  .. FileName .. '"'
          FileTemp = FileName:sub(1, -5) .. '.f137.mp4.part'
      end
      
      -- ARGS
      args = " --update-to master -S vcodec:h264,res,acodec:aac " .. url .. ' -P "' .. ProjDir .. '/Videos/"' .. argument
      upArgs = " --update-to master"

      -- TRIGGERS
      Update = Start .. MainPath .. upArgs
      Video = Start .. MainPath .. args
      Destination =  ProjDir ..'/Videos/' .. FileName
      Destination = Destination:gsub('\\','/')
      

--cd ~/Library/"Application Support"/REAPER/Scripts/Tormy\ Van\ Cool\ ReaPack\ Scripts/Various/yt-dlp/ && ./yt-dlp_macos

---------------------------------------------
-- UPDATE AND IMPORT VIDEO
---------------------------------------------

      if url  ~= "" then

          if debug == true then 
            reaper.ShowConsoleMsg("FileName: " .. FileTemp .. "\n")
            reaper.ShowConsoleMsg("Destination: " .. Destination .. "\n")
          end
          
          if OpSys == 2 then
            os.execute(Update)
            os.execute(Video)
          elseif OpSys == 1 or OpSys == 3 then
            os.execute(Start .. MainPath .. upArgs .. args)
          end
          
          -- GET FILE SIZE
          function get_file_size(filename)
              local file = io.open(filename, "rb")
              if not file then return 0 end
              local size = file:seek("end")
              file:close()
              return size
          end
          
          
          ---------------------------------------------
          -- NETWORL DISRUPTION
          ---------------------------------------------
          
          -- GET RESIDUAL FILES
          local ResFiles
          if OpSys == 2 or OpSys == 3 then
              ResFiles = "ls -a " .. ProjDir .."/Videos/*.mp4.part"
              ResDel = 'rm "' .. ProjDir .. '\\Videos\\*.mp4.part"'
          elseif OpSys == 1 then
              ResFiles = 'dir /b "' .. ProjDir .. '\\Videos\\*.mp4.part"'
              ResDel = 'del "' .. ProjDir .. '\\Videos\\*.mp4.part"' 
          end
  
          local handle = io.popen(ResFiles)
          
          if handle == nil then
              return
          end
          local stdout = handle:read("*all")
          success = handle:close()
          
          -- REMOVE RESIDUAL FILES
          if success then
              if debug == true then reaper.ShowConsoleMsg('output is: \n' .. tostring(stdout) .. "\n") end
              local retQuery = reaper.MB("Due a Network Error, the video was not properly downloaded.\nBY CLICKING OK THESE LEFTOVERS WILL BE REMOVED\n\nLeftovers:\n\n" .. tostring(stdout), "NETWORK ERROR", 0)
              if retQuery == 1 then
                handle = io.popen(ResDel)
                success = handle:close()
              end
          else
              if debug == true then reaper.ShowConsoleMsg('error when executing command' .. ResFiles) end
              reaper.InsertMedia(Destination, 1)
          end

          if debug == true then 
            local stable = false
            local last_size = get_file_size(Destination)
            while not stable or io.open(FileTemp, "rb")  do
                
                local new_size = get_file_size(Destination)
                
                if new_size > 0 and new_size == last_size then
                    stable = true
                else
                    last_size = new_size
                end
            end
          end


      end

::done::