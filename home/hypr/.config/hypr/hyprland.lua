-- Hyprland (Lua). Traducción de ~/.config/niri/config.kdl.
-- Original generado por DMS guardado en hyprland.lua.dms-original.
-- Wiki: https://wiki.hypr.land/configuring/

local terminal = "kitty"
local mainMod  = "SUPER"
-- El PATH de Hyprland no incluye ~/.local/bin: los scripts propios van con ruta completa.
local bin      = os.getenv("HOME") .. "/.local/bin/"

-- Monitores: autodetección (el portátil y la tele los gestiona tele-hdmi2).
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Autostart (dms arranca solo como servicio de usuario con uwsm).
hl.on("hyprland.start", function()
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    hl.exec_cmd(bin .. "fondos --arranque eDP-1")   -- Wallpaper Engine: último fondo elegido con `fondos` (por defecto ASCII Lain)
end)

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in     = 8,
        gaps_out    = 24,
        border_size = 0,
        resize_on_border = true,
        allow_tearing    = false,
        layout = "dwindle",
    },

    decoration = {
        rounding = 16,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = { enabled = false },
        blur   = { enabled = false },
    },

    animations = { enabled = true },

    -- Gesto horizontal de escritorios. distance: recorrido de dedos por escritorio (300 por defecto; más = más lento).
    -- cancel_ratio: fracción mínima del recorrido para confirmar al soltar (0.5 por defecto).
    -- min_speed_to_force: velocidad a partir de la cual un golpe rápido confirma aunque sea corto (30 por defecto).
    gestures = {
        workspace_swipe_distance           = 250,
        workspace_swipe_cancel_ratio       = 0.2,
        workspace_swipe_min_speed_to_force = 15,
    },

    input = {
        kb_layout    = "es",
        numlock_by_default = true,
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
        },
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },

    dwindle = { preserve_split = true },
})

-- Colores del tema de DMS (los reescribe matugen).
require("dms.colors")

-- Gesto de 3 dedos horizontal: sigue los dedos (escritorio anterior/siguiente).
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 0.8, bezier = "default", style = "slide" })

--------------------------------
---- ATAJOS (como en niri) -----
--------------------------------

-- Programas
hl.bind(mainMod .. " + T",          hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T",           hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE",      hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
-- Super solo (al soltarla) abre spotlight; si pulsas otra tecla con Super no salta.
hl.bind(mainMod .. " + Super_L",    hl.dsp.exec_cmd("dms ipc call spotlight toggle"), { release = true })
hl.bind(mainMod .. " + ALT + L",   hl.dsp.exec_cmd("dms ipc call lock lock"))
hl.bind(mainMod .. " + V",          hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind(mainMod .. " + B",          hl.dsp.exec_cmd(bin .. "fondos"))   -- selector de fondos de Wallpaper Engine
hl.bind(mainMod .. " + SHIFT + B",  hl.dsp.exec_cmd(bin .. "workshop"))   -- web para buscar y bajar fondos del Workshop

-- Ventanas
hl.bind(mainMod .. " + Q",          hl.dsp.window.close())
hl.bind("CTRL + SHIFT + W",         hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + V",  hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + S",          hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + SHIFT + F",  hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mainMod .. " + W",          hl.dsp.layout("togglesplit"))   -- dwindle: cambia split vertical/horizontal
hl.bind(mainMod .. " + P",          hl.dsp.window.pseudo())

-- Foco: flechas y hjkl
local dirs = { left = "left", right = "right", up = "up", down = "down" }
local vim  = { H = "left", L = "right", K = "up", J = "down" }
for key, d in pairs(dirs) do
    hl.bind(mainMod .. " + " .. key,            hl.dsp.focus({ direction = d }))
    hl.bind(mainMod .. " + CTRL + " .. key,     hl.dsp.window.move({ direction = d }))
end
for key, d in pairs(vim) do
    hl.bind(mainMod .. " + " .. key,            hl.dsp.focus({ direction = d }))
    hl.bind(mainMod .. " + CTRL + " .. key,     hl.dsp.window.move({ direction = d }))
end

-- Redimensionar (en niri: Mod+- / Mod+=)
hl.bind(mainMod .. " + minus", hl.dsp.window.resize({ x = -60, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + equal", hl.dsp.window.resize({ x =  60, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -60, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y =  60, relative = true }), { repeating = true })

-- Monitores
for key, d in pairs(vim) do
    hl.bind(mainMod .. " + SHIFT + " .. key,          hl.dsp.focus({ monitor = d }))
    hl.bind(mainMod .. " + SHIFT + CTRL + " .. key,   hl.dsp.window.move({ monitor = d }))
end

-- Workspaces 1-9 (aquí no hay "oculto" que desplace los números)
for i = 1, 9 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })  -- existen siempre, aunque estén vacíos
    hl.bind(mainMod .. " + " .. i,            hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + CTRL + " .. i,     hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + U",         hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + I",         hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + Page_Down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + Page_Up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + CTRL + U",  hl.dsp.window.move({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + I",  hl.dsp.window.move({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- "Minimizar": especial "oculto" (N lo guarda, Shift+N lo muestra/oculta)
hl.bind(mainMod .. " + N",         hl.dsp.window.move({ workspace = "special:oculto" }))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.workspace.toggle_special("oculto"))

-- Ratón: mover y redimensionar arrastrando
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Capturas
hl.bind("Print",           hl.dsp.exec_cmd(bin .. "recortar-pantalla --todo"))  -- Fn+F9 del ThinkPad parece mandar Print
hl.bind("XF86SelectiveScreenshot", hl.dsp.exec_cmd(bin .. "recortar-pantalla --editar"))  -- Fn+F10 del ThinkPad
hl.bind(mainMod .. " + F9",         hl.dsp.exec_cmd(bin .. "recortar-pantalla --todo"))

-- Cheatsheet de atajos (script ~/.local/bin/atajos)
hl.bind(mainMod .. " + F1",         hl.dsp.exec_cmd(bin .. "atajos"))
hl.bind(mainMod .. " + A",          hl.dsp.exec_cmd(bin .. "atajos"))

-- Salir
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("uwsm stop"))
hl.bind("CTRL + ALT + Delete",     hl.dsp.exec_cmd("uwsm stop"))

-- Teclas multimedia
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),     { locked = true })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl --class=backlight set +10%"),         { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl --class=backlight set 10%-"),         { locked = true, repeating = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioStop",  hl.dsp.exec_cmd("playerctl stop"),       { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

--------------------------------
---- REGLAS DE VENTANA ---------
--------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Picture-in-Picture de Firefox flotante
hl.window_rule({
    name  = "firefox-pip",
    match = { class = "firefox$", title = "^Picture-in-Picture$" },
    float = true,
})
