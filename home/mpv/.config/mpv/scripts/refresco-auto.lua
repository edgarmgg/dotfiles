-- Con la tele como única pantalla, pone su refresco en un múltiplo exacto de los
-- fps de cada vídeo (respeta el tope de ~/.config/tele-max-hz) y deja el de antes
-- al cerrar mpv. Los fps salen de ffprobe (avg_frame_rate); si no se parecen a
-- ningún estándar, el vídeo mezcla 24 y 30 y se usa 59.94. Usa hyprctl (Hyprland).
local OUT = "HDMI-A-1"
local standard = { 23.976, 24, 25, 29.97, 30, 50, 59.94, 60 }
local mixed = 59.94
local prev  -- { res = "WxH", hz = Hz, scale = escala } de antes del primer cambio

-- "WxH Hz_actual escala Hz_de_cada_modo..." a la resolución actual, solo si la tele es la única pantalla
local JQ = 'if length == 1 and .[0].name == "' .. OUT .. '" then .[0] as $m | '
  .. '"\\($m.width)x\\($m.height) \\($m.refreshRate) \\($m.scale) " + '
  .. '([$m.availableModes[] | capture("^(?<w>[0-9]+)x(?<h>[0-9]+)@(?<r>[0-9.]+)Hz$") '
  .. '| select((.w | tonumber) == $m.width and (.h | tonumber) == $m.height) | .r] | join(" ")) '
  .. 'else empty end'

local function run(args)
  return mp.command_native({ name = "subprocess", capture_stdout = true, playback_only = false, args = args })
end

local function classify(fps)
  for _, s in ipairs(standard) do
    if math.abs(fps - s) / s < 0.015 then return s end
  end
  return mixed
end

local function set_mode(res, hz, scale)
  run({ "hyprctl", "eval", string.format(
    'hl.monitor({ output = "%s", mode = "%s@%.3f", position = "auto", scale = %s })',
    OUT, res, hz, scale) })
end

mp.register_event("file-loaded", function()
  local path = mp.get_property("path")
  if not path or not path:find("^/") then return end
  mp.command_native_async({
    name = "subprocess", capture_stdout = true, playback_only = false,
    args = { "ffprobe", "-v", "error", "-select_streams", "v:0",
             "-show_entries", "stream=avg_frame_rate", "-of", "csv=p=0", path },
  }, function(ok, res)
    if not ok or res.status ~= 0 then return end
    local num, den = res.stdout:match("(%d+)/(%d+)")
    num, den = tonumber(num), tonumber(den)
    if not num or not den or num == 0 or den == 0 then return end
    local fps = classify(num / den)
    local info = run({ "sh", "-c", "hyprctl monitors -j | jq -r '" .. JQ .. "'" })
    local words = {}
    for w in (info.stdout or ""):gmatch("%S+") do words[#words + 1] = w end
    if #words < 4 then return end  -- la tele no es la única pantalla
    local res_, current, scale = words[1], tonumber(words[2]), words[3]
    local cap = 999
    local f = io.open(os.getenv("HOME") .. "/.config/tele-max-hz")
    if f then cap = tonumber(f:read("*l")) or cap; f:close() end
    -- Refresco múltiplo de fps más exacto (tolerancia 0,2 %); a igual exactitud, el más alto.
    local best, best_err
    local nearest  -- el modo listado más parecido al actual (hyprctl da 60.003 y lista 60.00)
    for i = 4, #words do
      local r = tonumber(words[i])
      if not nearest or math.abs(r - current) < math.abs(nearest - current) then nearest = r end
      local k = math.floor(r / fps + 0.5)
      if r <= cap + 0.01 and k >= 1 then
        local err = math.abs(r - k * fps) / r
        if err < 0.002 and (not best_err or err < best_err - 0.0001 or (err < best_err + 0.0001 and r > best)) then
          best, best_err = r, err
        end
      end
    end
    mp.msg.info(string.format("fps %.3f -> refresco %s", fps, tostring(best)))
    if not best or math.abs(best - nearest) < 0.01 then return end
    prev = prev or { res = res_, hz = nearest, scale = scale }
    -- Pausa mientras la tele cambia de modo (se queda en negro 1-2 s).
    local was_paused = mp.get_property_bool("pause")
    mp.set_property_bool("pause", true)
    set_mode(res_, best, scale)
    mp.add_timeout(2, function()
      if not was_paused then mp.set_property_bool("pause", false) end
    end)
  end)
end)

mp.register_event("shutdown", function()
  if prev then set_mode(prev.res, prev.hz, prev.scale) end
end)
