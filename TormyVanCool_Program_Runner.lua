--[[
@description It creates scripts that are supposed to fire-up an external program, after have selected it
@author: Tormy Van Cool
@version: 1.0.4
@about
# First release made 28 feb 2021
Versioning:
1.0
  + File creation 28.02.2021
1.0.1
  + Declared all variable at the begnining of the file
  + Capitalized the filename into reaper.MB() when the fiel already exists
1.0.2
  + When the action is imported, the Add Menu/Toolbar tool is opened, instead of the action list
1.0.3
  + Chek for the presence of the UltraShall library
1.0.4
 # Correction minor bugs
]]
--local retval, folder = reaper.JS_Dialog_BrowseForFolder( caption, initialFolder )

--------------------------------------------------------------------
-- Script Initialization
--------------------------------------------------------------------
reaper.Undo_BeginBlock() -- creats the UNDO Hook
local LF = "\n"
local extension = ".lua"
local script_File = nil
local custom_Reaction = nil
local sub_Folder = "/scripts/TormyVanCool_Program_Runner_Scripts/"
local UltraschallLua = "/UserPlugins/ultraschall_api.lua"


--------------------------------------------------------------------
-- Functions declaration
--------------------------------------------------------------------
function file_exists(name) -- Checks if mandatory library is installed
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function get_FileNameExt(file)
      return file:match("^.+/(.+)$")
end

--------------------------------------------------------------------
-- Loads the mandatory library
--------------------------------------------------------------------
if file_exists(reaper.GetResourcePath().."/UserPlugins/ultraschall_api.lua") == false then 
  local v = [[
            ULTRASCHALL Library should be installed.
            Copy the follwing link
          
            https://github.com/Ultraschall/ultraschall-lua-api-for-reaper/raw/master/ultraschall_api_index.xml
           
            into:
          
            Extensions > ReaPack > Import repositories...
          
            install it and activate it by runinng:
          
            Actions > Script: ultraschall_Add_Developertools_To_Reaper.lua > Run/Close
            ]]

  reaper.MB(v,'ATTENTION',0)
  return
else
  dofile(reaper.GetResourcePath()..UltraschallLua)
end

--------------------------------------------------------------------
-- Retrieves the program to fire-up and its path
-- replacing the "\" charater with the "/"
--------------------------------------------------------------------
local retval, fileNames = reaper.JS_Dialog_BrowseForOpenFiles( "SELECT THE APP YO WANT TO FIRE-UP", initialFolder, initialFile, extensionList, 0 )
fileNames = fileNames:gsub("\\", "/")

InputString = get_FileNameExt(fileNames)


--------------------------------------------------------------------
-- Check for pre-existent file with tsame name
-- Creates the file
--------------------------------------------------------------------
scripts_Path = reaper.GetResourcePath()
scripts_Path = scripts_Path:gsub("\\", "/") .. sub_Folder
reaper.RecursiveCreateDirectory( scripts_Path, 1 )
scripts_Path =  scripts_Path .. InputString:match("(.+)%..+") .. extension
if file_exists(scripts_Path) == true then
  custom_Reaction = reaper.MB("A file with the name '"..InputString:match("(.+)%..+"):upper()  .. extension:upper() .."' already exists.\nWould you like to overwrite it?", "WARNING",4) -- 6 yes, 7 no
end

if custom_Reaction == nil or custom_Reaction == 6 then
  script_File = io.open(scripts_Path, "w")
elseif custom_Reaction == 7 then
  return
end


--------------------------------------------------------------------
-- Writes the code
--------------------------------------------------------------------
script_File:write('local path = "'..fileNames..'"\n')
script_File:write('reaper.BR_Win32_ShellExecute("open", path, "", "", 1)')


--------------------------------------------------------------------
-- Closes file and returns feedback to user
--------------------------------------------------------------------
script_File:close()
reaper.AddRemoveReaScript(true, 0, scripts_Path, true)
--reaper.PromptForAction( 1, 1, 1 )
--reaper.ShowActionList()
reaper.Main_OnCommand(1528, 0)
reaper.Undo_OnStateChangeEx("PROGRAM RUNNER", -1, -1)
