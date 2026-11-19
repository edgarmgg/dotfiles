-- Apunta en ~/.local/state/mpv/watched.txt los vídeos (episodios o pelis) vistos hasta el final
-- (o al menos al 95 %), para que `ver`, `onepace` y el mando (mpv-remote) empiecen
-- en el primero sin terminar y marquen lo visto.
local log_path = os.getenv("HOME") .. "/.local/state/mpv/watched.txt"
local percent = 0
local current_path

mp.observe_property("percent-pos", "number", function(_, value)
  if value then percent = value end
end)

mp.register_event("start-file", function()
  percent = 0
  current_path = mp.get_property("path")
end)

mp.register_event("end-file", function(event)
  local path = current_path
  if not path or not path:find("^/") then return end
  if event.reason == "eof" or percent >= 95 then
    local file = io.open(log_path, "a")
    if file then
      file:write(path, "\n")
      file:close()
    end
  end
end)
