-- @description: Download videos from YT and see what happens
-- @version: 1.0
-- @author: Tormy Van Cool

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
local zzz = 10


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
      until( t[1] ~= "")
      
      
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
      args = " --merge-output-format mp4 " .. url .. ' -P "' .. ProjDir .. '/Video/"' .. argument
      
      -- TRIGGERS
      Video = 'start "" "' .. MainPath .. '" ' .. args
      Update = 'start "" "' .. MainPath .. '" --update-to master'
      Destination =  ProjDir ..'/Video/' .. FileName
      Destination = Destination:gsub('\\','/')


---------------------------------------------
-- UPDATE AND IMPORT VIDEO
---------------------------------------------
      if url  ~= "" then
          os.execute(Update)
          sleep(zzz)
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
