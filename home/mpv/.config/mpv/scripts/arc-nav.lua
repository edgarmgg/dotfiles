-- Siguiente/anterior episodio que salta entre temporadas o arcos de una serie:
--   siguiente en el último episodio -> primer episodio del arco siguiente
--   anterior en el primer episodio  -> último episodio del arco anterior
-- Las carpetas se ordenan por su número ([629-746] ..., Temporada 2 ...).
-- Solo actúa si la carpeta del vídeo tiene 2 o más vídeos: una carpeta con un
-- único vídeo es una peli, y al acabarla no debe abrir la peli de al lado.
-- Además mira ~/.config/biblioteca.conf para no saltar a una carpeta de pelis
-- (One Piece/Movies tras el último arco) ni de una serie sin temporadas a la serie
-- de al lado. Sin ese fichero simplemente no hace esas dos comprobaciones.
local utils = require "mp.utils"

-- Tipo de cada carpeta de la biblioteca: library[ruta] = "raiz", "pelis", "series" o "serie".
-- Se lee una vez al cargar el script.
local function read_library()
  local kinds, root, entries = {}, nil, {}
  local file = io.open(os.getenv("BIBLIOTECA_CONF")
                       or (os.getenv("HOME") .. "/.config/biblioteca.conf"))
  if not file then return kinds end
  for line in file:lines() do
    local kind, path = line:match("^%s*(%a+)%s+(.-)%s*$")  -- los comentarios empiezan por #
    if kind == "raiz" then root = path elseif kind then entries[#entries + 1] = {kind, path} end
  end
  file:close()
  if not root then return kinds end
  kinds[root] = "raiz"
  for _, entry in ipairs(entries) do
    local kind, path = entry[1], entry[2]
    if not path:find("^/") then path = utils.join_path(root, path) end
    kinds[path] = kind
  end
  return kinds
end
local library = read_library()

local function natural_key(name)
  return (name:lower():gsub("%d+", function(n) return string.format("%012d", tonumber(n)) end))
end

local function sorted(list)
  table.sort(list, function(a, b) return natural_key(a) < natural_key(b) end)
  return list
end

local function video_files(dir)
  local files = {}
  for _, name in ipairs(utils.readdir(dir, "files") or {}) do
    if name:match("%.mkv$") or name:match("%.mp4$") then
      files[#files + 1] = utils.join_path(dir, name)
    end
  end
  return sorted(files)
end

local function clean(name)
  return (name:gsub("%b[]", ""):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Devuelve la lista de episodios del arco vecino (offset +1 o -1) y su nombre.
local function neighbour_arc(offset)
  local path = mp.get_property("path")
  if not path or not path:find("^/") then return end
  local arc_dir = utils.split_path(path):gsub("/$", "")
  if #video_files(arc_dir) < 2 then return end
  local root, arc_name = utils.split_path(arc_dir)
  root = root:gsub("/$", "")
  -- Las carpetas de al lado son otras pelis u otras series, no el arco siguiente
  local parent = library[root]
  if library[arc_dir] == "pelis" or (parent and parent ~= "serie") then return end
  local arcs = sorted(utils.readdir(root, "dirs") or {})
  for i, name in ipairs(arcs) do
    if name == arc_name then
      local target = arcs[i + offset]
      if not target then return end
      if library[utils.join_path(root, target)] == "pelis" then return end
      local files = video_files(utils.join_path(root, target))
      if #files > 0 then return files, clean(target) end
      return
    end
  end
end

local function open_arc(files, start, name)
  mp.commandv("loadfile", files[start], "replace")
  for i = 1, start - 1 do mp.commandv("loadfile", files[i], "insert-at", i - 1) end
  for i = start + 1, #files do mp.commandv("loadfile", files[i], "append") end
  mp.osd_message(name)
end

mp.add_key_binding(nil, "next", function()
  local pos, count = mp.get_property_number("playlist-pos"), mp.get_property_number("playlist-count")
  if pos and count and pos < count - 1 then
    mp.commandv("playlist-next")
    return
  end
  local files, name = neighbour_arc(1)
  if files then open_arc(files, 1, name) else mp.osd_message("Último episodio") end
end)

mp.add_key_binding(nil, "prev", function()
  local pos = mp.get_property_number("playlist-pos")
  if pos and pos > 0 then
    mp.commandv("playlist-prev")
    return
  end
  local files, name = neighbour_arc(-1)
  if files then open_arc(files, #files, name) else mp.osd_message("Primer episodio") end
end)

-- Al acabar el último episodio de un arco, pasa solo al primero del siguiente.
-- Requiere keep-open=yes: mpv se queda en el último fotograma en vez de cerrarse.
-- Si no hay arco siguiente (o es una peli), cierra como haría con keep-open=no.
mp.observe_property("eof-reached", "bool", function(_, reached)
  if not reached then return end
  local files, name = neighbour_arc(1)
  if files then
    open_arc(files, 1, name)
  else
    mp.commandv("quit")
  end
end)
