-- @Description Export Stems
-- @about Insert empty item on all tracks at the position of the edit cursor
-- @Author Tormy Van Cool
-- @Version 1.0
-- @About 
--   Performs the following actions:
--   > Get the cursor position
--   > Selects all tracks
--   > Insert empty item
--   > Glue all items on all tracks
--   > Calls the rendering window
--   > Unslects all tracks
--   > Selects all items for stems
--   > Calls the rendering window
--   Once exported, each track has a duration form the begining of the song
--   to the end of the track itself, not to the very end of the song.
--   This saves HD space, making shorter files

reaper.Undo_BeginBlock()
reaper.Main_OnCommand(40296, 0) -- Selects all tracks
CursorPosition = reaper.GetCursorPositionEx()

local TracksN = reaper.CountSelectedTracks(0)
local trackArray = {}

function insertEmptyItem()
  for i = 0, (TracksN - 1) do
    reaper.SetEditCurPos(CursorPosition, 1, 0)
    local selectedTrack = reaper.GetSelectedTrack(0, 0)
    trackArray[i] = selectedTrack
    reaper.Main_OnCommand(40914,0) -- Track: Set first selected track as last touched track
    reaper.Main_OnCommand(40142,0) -- Insert empty item
    reaper.Main_OnCommand(40421,0) -- Select all items in track
    reaper.Main_OnCommand(41588,0) -- Glue all items
    reaper.SetTrackSelected(track, false)
  end
end
insertEmptyItem()

reaper.Main_OnCommand(40297,0) -- Unselect all tracks
reaper.Main_OnCommand(40182,0) -- Select all items
reaper.Main_OnCommand(40015,0) -- Render
reaper.Undo_EndBlock("Prepare for export", 0)
