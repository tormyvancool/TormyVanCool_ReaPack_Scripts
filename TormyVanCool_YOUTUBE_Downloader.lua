-- @description: Download videos from YT and see what happens
-- @version: 1.6
-- @author: Tormy Van Cool
-- @Changelog
--[[
  1.0 2024-26-10 - First Release
  1.1 2024-26-10 - +Processes Notifications
                   -/Video/
                   +/Videos/
  1.2 2024-26-10 - ---merge-output-format mp4
                   +-S vcodec:h264,res,acodec:aac
  1.3 2024-26-10 - 10
                 + 2
  1.4 2024-26-10 - 2
                 + 5
  1.5 2024-26-10 - 5
                 + 1
                 # Unified Update
 1.6  2024-26-10 - 1
                 + 2
                 + Version
]]--

reaper.ClearConsole()

---------------------------------------------
-- MAIN VARIABLES
---------------------------------------------
local LF = "\n"
local pipe = "|"
local colon = ":"
local quote = '"' 
local clock = os.clock
local debug = false
local zzz = 2
local ver = 1.6
local version = reaper.GetAppVersion()

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
          MainPath = reaper.GetResourcePath() .. "/Scripts/Tormy Van Cool ReaPack Scripts/Various/yt-dlp/yt-dlp.exe"
        end
        if OS == "OSX32" or OS == "OSX64" or OS == "macOS-arm64" then
          MainPath = reaper.GetResourcePath() .. "/Scripts/Tormy Van Cool ReaPack Scripts/Various/yt-dlp/yt-dlp_macos"   
        end
        if OS == "Other" then
          MainPath = reaper.GetResourcePath() .. "/Scripts/Tormy Van Cool ReaPack Scripts/Various/yt-dlp/yt-dlp"
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

      local minVersion = '7.26'
      if minVersion > version then
        reaper.MB('your Reaper verions is '..version..'\nPlease update REAPER to the last version!', 'ERROR: REAPER '..version..' OUTDATED', 0)
        goto done
      end
---------------------------------------------
-- INTERACTIONS
---------------------------------------------

      -- GET URL
      ProjDir = reaper.GetProjectPathEx(0)
      InputVariable = ""
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
      FileName = GetRid(GetRid(GetRid(FileName, pipe), colon), quote) -- No reserved characters can be written
      if retval_1==false then return end
      if retval_1 then
        t = {}
        i = 0
        for line in FileName:gmatch("[^" .. LF .. "]*") do
            i = i + 1
            t[i] = line
        end
      end
      if t[1]== "" then
        reaper.MB("VIDEO TITLE is MANDATORY","ERROR",0,0)
      end
      until( t[1] ~= "")
      reaper.MB("STARTED THE FOLLOWING PROCESSES v" .. ver .. ":\n\n1. Update YT-DLP\n2. Downlaod the video: " ..url .. "\n3. Naming the video: " .. FileName .. ".mp4 \n4. Saving the video into " .. ProjDir .. "/Videos/\n5. Import the video into the project\n\nHEY it will take a little while. DON'T PANIC!\n\nCLICK ON \"OK\" TO CONTINUE", "PROCESS STARTED. PROCESSES LISTED HERE BELOW",0)

--Pics = "curl -X GET " .. url .. ' --output "' .. Destination ..'"'

---------------------------------------------
-- ARGS & TRIGGERS
---------------------------------------------

      if FileName ~= "" 
        then
          if string.find(FileName, ".mp4") == nil then
            FileName = FileName .. ".mp4"
          end
          argument = ' -o "'  .. FileName .. '"'
      end
      
      -- ARGS
      args = " --update-to master -S vcodec:h264,res,acodec:aac " .. url .. ' -P "' .. ProjDir .. '/Videos/"' .. argument
      
      -- TRIGGERS
      Video = 'start "" "' .. MainPath .. '" ' .. args
      Update = 'start "" "' .. MainPath .. '" --update-to master'
      Destination =  ProjDir ..'/Videos/' .. FileName
      Destination = Destination:gsub('\\','/')


---------------------------------------------
-- UPDATE AND IMPORT VIDEO
---------------------------------------------
      if url  ~= "" then
          os.execute(Video)
          if debug == true then 
            reaper.ShowConsoleMsg("FileName: " .. FileName .. "\n")
            reaper.ShowConsoleMsg("Destination: " .. Destination .. "\n")
          end
          
          -- GET FILE SIZE
          function get_file_size(filename)
              local file = io.open(filename, "rb")
              if not file then return 0 end
              local size = file:seek("end")
              file:close()
              return size
          end
          
          -- WAIT UNTIL THE OUTPUT FILE SIZE IS STABLE (NOT CHANGING)
          local stable = false
          local last_size = get_file_size(Destination)
          while not stable do
              
              sleep(zzz)
              local new_size = get_file_size(Destination)
              
              if new_size > 0 and new_size == last_size then
                  stable = true
              else
                  last_size = new_size
              end
          end
      
          reaper.InsertMedia(Destination, 1)
      end
::done::