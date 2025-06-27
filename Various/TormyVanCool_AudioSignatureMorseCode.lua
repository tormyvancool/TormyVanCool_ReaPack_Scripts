retval, InputFields=reaper.GetUserInputs("ASCII MIDIzation",10, "Title,separator=\n,ISRC,Composer,Author,Arranger (if any),Year,Genre,Mixer Engineer,Master Engineer,Duration (seconds)", "")
--retval, InputString_ISRC=reaper.GetUserInputs("Original string", 1, "ISRC", "")
if retval then
  t = {}
  i = 0
  for line in InputFields:gmatch("[^" .. "\n" .. "]*") do
      i = i + 1
      t[i] = line
  end
end

-- DECLARATIONS
InputString=t[1]:upper()
InputString_ISRC=t[2]:upper()
InputString_Composer=t[3]:upper()
InputString_Author=t[4]:upper()
InputString_Arranger=t[5]:upper()
InputString_Year=t[6]:upper()
InputString_Genre=t[7]:upper()
InputString_MixerEngineer=t[8]:upper()
InputString_MasterEngineer=t[9]:upper()
InputString_Duration=t[10]:upper()

function space(a)
  return a:gsub(".", "%1 "):sub(1,-2)
end

title="   - .. - .-..   " --TITL
composer="   -.-. -- .--. ...   " --CMPS
author="   .- ..- - ....   " --AUTH
arranger="   .- .-. -. --.    " --ARNG
isrc="   .. ... .-. -.-.   " --ISRC
year="   -.-- . .- .-.   " --YEAR
genre="   --. . -. .-.   " --GENR
mixer="   -- .. -..- .-.   " --MIXR
master="   -- ... - .-.   " --MSTR
length="   -.. .-. - -.   " --DRTN

--reaper.ShowConsoleMsg("\n"..t[1].." "..t[2].." "..t[3].." "..t[4]..' '.."\n")
--os.exit()
if retval==false then return end

InputString=InputString:upper()


OutputString=""
--[[
i=1
while i<=InputString:len() do
  k=InputString:sub(i,i)
  if k=="C" and InputString:sub(i+1,i+1)=="H" then
    k="CH"
    i=i+1
  end
  if MorseTable[k]~=nil then
    OutputString=OutputString..MorseTable[k].."   "
  end
  i=i+1
end
--]]

-- FUNTCION
local function MORSE(InputData)
  MorseTable={}
  MorseTable["A"]=".-"
  MorseTable["B"]="-..."
  MorseTable["C"]="-.-."
  MorseTable["D"]="-.."
  MorseTable["E"]="."
  MorseTable["F"]="..-."
  MorseTable["G"]="--."
  MorseTable["H"]="...."
  MorseTable["I"]=".."
  MorseTable["J"]=".---"
  MorseTable["K"]="-.-"
  MorseTable["L"]=".-.."
  MorseTable["M"]="--"
  MorseTable["N"]="-."
  MorseTable["O"]="---"
  MorseTable["P"]=".--."
  MorseTable["Q"]="--.-"
  MorseTable["R"]=".-."
  MorseTable["S"]="..."
  MorseTable["T"]="-"
  MorseTable["U"]="..-"
  MorseTable["V"]="...-"
  MorseTable["W"]=".--"
  MorseTable["X"]="-..-"
  MorseTable["Y"]="-.--"
  MorseTable["Z"]="--.."
  
  MorseTable["1"]=".----"
  MorseTable["2"]="..---"
  MorseTable["3"]="...--"
  MorseTable["4"]="....-"
  MorseTable["5"]="....."
  MorseTable["6"]="-...."
  MorseTable["7"]="--..."
  MorseTable["8"]="---.."
  MorseTable["9"]="----."
  MorseTable["0"]="-----"
  
  MorseTable["À"]=".--.-"
  MorseTable["Å"]=".--.-"
  MorseTable["Ä"]=".-.-"
  MorseTable["È"]=".-..-"
  MorseTable["É"]="..-.."
  MorseTable["Ö"]="---."
  MorseTable["Ü"]="..--"
  MorseTable["ß"]="...--.."
  MorseTable["CH"]="----"
  MorseTable["Ñ"]="--.--"
  
  MorseTable["."]=".-.-.-"
  MorseTable[","]="--..--"
  MorseTable[":"]="---..."
  MorseTable[";"]="-.-.-."
  MorseTable["?"]="..--.."
  MorseTable["!"]="-.-.--"
  MorseTable["-"]="-....-"
  MorseTable["_"]="..--.-"
  MorseTable["("]="-.--."
  MorseTable[")"]="-.--.-"
  MorseTable["'"]=".----."
  MorseTable["\""]=".-..-."
  MorseTable["="]="-...-"
  MorseTable["+"]=".-.-."
  MorseTable["/"]="-..-."
  MorseTable["@"]=".--.-."
  
  MorseTable[" "]=" " --word space
  local OutputData=""
  i=1
  while i<=InputData:len() do
    k=InputData:sub(i,i)
    if k=="C" and InputData:sub(i+1,i+1)=="H" then
      k="CH"
      i=i+1
    end
    if MorseTable[k]~=nil then
      OutputData=OutputData..MorseTable[k].."  " --letter space
    end
    i=i+1
  end
  return OutputData
end

-- TITLE
if InputString:len()==0 then
  title=""
else
  title=title..MORSE(InputString)
end

-- ISRC
if InputString_ISRC:len()==0 then
  isrc=""
else
  isrc=isrc..MORSE(InputString_ISRC)
end

-- COMPOSER
if InputString_Composer:len()==0 then
  composer=""
else
  composer=composer..MORSE(InputString_Composer)
end

-- AUTHOR
if InputString_Author:len()==0 then
  author=""
else
  author=author..MORSE(InputString_Author)
end

-- ARRANGER
if InputString_Arranger:len()==0 then
  arranger=""
else
  arranger=arranger..MORSE(InputString_Arranger)
end

-- YEAR
if InputString_Year:len()==0 then
  year=""
else
  year=year..MORSE(InputString_Year)
end

-- GENRE
if InputString_Genre:len()==0 then
  genre=""
else
  genre=genre..MORSE(InputString_Genre)
end


-- MIXER ENGINEER
if InputString_MixerEngineer:len()==0 then
  mixer=""
else
  mixer=mixer..MORSE(InputString_MixerEngineer)
end

-- MASTER ENGINEER
if InputString_MasterEngineer:len()==0 then
  master=""
else
  master=master..MORSE(InputString_MasterEngineer)
end

-- DURATION
if InputString_Duration:len()==0 then
  length=""
else
  length=length..MORSE(InputString_Duration)
end

InputString=MORSE(InputString)

-- END FUNCTION

OutputString=space(isrc)
  ..space(composer)
  ..space(author)
  ..space(arranger)
  ..space(genre)
  ..space(year)
  ..space(mixer)
  ..space(master)
  ..space(length)
  ..space(title).."  " --..InputString:sub(1,-1)

--reaper.ShowConsoleMsg("\n"..OutputString.."\n")
--os.exit()
-- Insert MIDI item at edit cursor position with Morse message

local cur_pos = reaper.GetCursorPosition()
local track = reaper.GetSelectedTrack(0, 0) or reaper.GetLastTouchedTrack()
if not track then return end
local item = reaper.CreateNewMIDIItemInProj( track, cur_pos, cur_pos + 5, false )
local take = reaper.GetActiveTake( item )
local pos = reaper.MIDI_GetPPQPosFromProjTime( take, cur_pos )
local dur = 480
local len = #OutputString
local i = 1
while true do
  local l = OutputString:sub( i, i )
  local duration
  if l == "-" then
    duration = pos + dur*3
    reaper.MIDI_InsertNote( take, false, false, pos, duration, 1, 71, 100, true )
  elseif l == "." then
    duration = pos + dur
    reaper.MIDI_InsertNote( take, false, false, pos, duration, 1, 71, 100, true )
  else -- l == " " then
    duration = pos + dur
  end
  pos = duration
  if i == len then break else i = i + 1 end
end
reaper.MIDI_Sort( take )
local last_note_end = ({reaper.MIDI_GetNote( take, ({reaper.MIDI_CountEvts( take )})[2]-1 )})[5]
reaper.SetMediaItemInfo_Value( item, "D_LENGTH", reaper.MIDI_GetProjTimeFromPPQPos( take, last_note_end ) -  cur_pos )
reaper.Undo_OnStateChange( "Create Morse Code Item" )