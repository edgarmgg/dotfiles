-- Salta el opening de cualquier vídeo que lo tenga como capítulo: vale cualquier
-- capítulo cuyo título contenga "opening" (One Pace los marca así) o sea exactamente "OP".
-- Tecla S: salta al final del opening si estás dentro de él.
-- Tecla Ctrl+s: activa/desactiva el salto automático al llegar al opening.
local auto = false

local function opening_end()
  local chapters = mp.get_property_native("chapter-list") or {}
  for i, ch in ipairs(chapters) do
    local title = (ch.title or ""):lower()
    if title:find("opening", 1, true) or title == "op" then
      local next_ch = chapters[i + 1]
      local stop = next_ch and next_ch.time or mp.get_property_number("duration")
      return ch.time, stop
    end
  end
end

local function skip(silent)
  local start, stop = opening_end()
  local pos = mp.get_property_number("time-pos")
  if not start or not pos then
    if not silent then mp.osd_message("Este vídeo no tiene capítulo Opening") end
    return
  end
  if pos >= start - 0.5 and pos < stop - 1 then
    mp.set_property_number("time-pos", stop)
    mp.osd_message("Opening saltado")
  elseif not silent then
    mp.osd_message("No estás en el opening")
  end
end

mp.add_key_binding("S", "skip-opening", function() skip(false) end)

mp.add_key_binding("Ctrl+s", "toggle-auto-skip", function()
  auto = not auto
  mp.osd_message("Saltar opening automático: " .. (auto and "sí" or "no"))
end)

-- Con el modo automático, al entrar en el opening lo salta.
mp.observe_property("chapter", "number", function()
  if auto then skip(true) end
end)
