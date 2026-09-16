----------------------------------------------------------------------------------
--
--    ,--.              ,--.         ,---.         ,---.              ,--. 
--    |  | ,---.  ,---. |  |,-.     |  o ,-.      /  .-' ,---.  ,---. |  | 
--    |  || .-. || .-. ||     /     .'     /_     |  `-,| .-. :| .-. :|  | 
--    |  |' '-' '' '-' '|  \  \     |  o  .__)    |  .-'\   --.\   --.|  | 
--    `--' `---'  `---' `--'`--'     `---'        `--'   `----' `----'`--' 
--                                                                         
--             _______
--　　　　　 /  ＞　　フ     
--　　　　　| 　_　 _ l      RESUME: Visual config & animations to make
--　 　　　／` ミ＿xノ               beautiful components
--　　 　 /　　　 　 |
--　　　 /　 ヽ　　 ﾉ
--　 　 │　　|　|　|         AUTHOR:  Andr3xDev
--　／￣|　　 |　|　|        URL: https://github.com/Andr3xDev/hypr-abysal
--　| (￣ヽ＿_ヽ_)__)
--　＼二つ
----------------------------------------------------------------------------------


----- Import Colors -----
local theme = require("theme")


----------------------------------------------------------------------------------
--- Gaps, borders, layouts & configs
----------------------------------------------------------------------------------
hl.config({
    general = {
        layout           = "master",
        gaps_in          = 4,
        gaps_out         = 8,
        border_size      = 2,
        allow_tearing    = true,
        resize_on_border = false,

        col = {
            active_border   = theme.border_active,
            inactive_border = theme.border_inactive,
        },
    },

    master = {
        mfact      = 0.6,
        orientation = "left",
        new_status = "slave",
    },
})


----------------------------------------------------------------------------------
--- Decoration
----------------------------------------------------------------------------------

hl.config({
    decoration = {
        rounding         = 6,
        dim_special      = 0.5,
        active_opacity   = 1,
        inactive_opacity = 0.92,

        shadow = {
            range          = 20,
            color          = theme.shadow_active,
            enabled        = true,
            render_power   = 2,
            color_inactive = theme.shadow_inactive,
        },

        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            popups            = true,
            special           = false,
            ignore_opacity    = false,
            new_optimizations = true,
        },
    },
})


----------------------------------------------------------------------------------
--- Animations
----------------------------------------------------------------------------------

-- Curves
hl.curve("springOpen",   { type = "spring", mass = 1, stiffness = 220, dampening = 26 })
hl.curve("easeOut",      { type = "bezier", points = { {0.16, 1}, {0.3, 1}  } })
hl.curve("easeIn",       { type = "bezier", points = { {0.7, 0},  {0.84, 0} } })
hl.curve("wsTransition", { type = "bezier", points = { {0.45, 1}, {0.45, 1} } })

-- Windows
hl.animation({ leaf = "windows",             enabled = true,  speed = 4.5, bezier = "easeOut",      style = "popin 85%" })
hl.animation({ leaf = "windowsIn",           enabled = true,  speed = 5,   spring = "springOpen",   style = "popin 85%" })
hl.animation({ leaf = "windowsOut",          enabled = true,  speed = 3.5, bezier = "easeOut",      style = "popin 85%" })
hl.animation({ leaf = "windowsMove",         enabled = true,  speed = 5,   spring = "springOpen",   style = "slide" })

-- Layers
hl.animation({ leaf = "layers",              enabled = true,  speed = 3.5, bezier = "easeOut",      style = "fade" })
hl.animation({ leaf = "layersIn",            enabled = true,  speed = 3.5, bezier = "easeOut",      style = "fade" })
hl.animation({ leaf = "layersOut",           enabled = true,  speed = 2.5, bezier = "easeIn",       style = "fade" })

-- Fade
hl.animation({ leaf = "fade",                enabled = true,  speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeIn",              enabled = true,  speed = 5,   bezier = "easeOut" })
hl.animation({ leaf = "fadeOut",             enabled = true,  speed = 3,   bezier = "easeOut" })
hl.animation({ leaf = "fadeSwitch",          enabled = true,  speed = 5,   bezier = "easeOut" })
hl.animation({ leaf = "fadeShadow",          enabled = true,  speed = 3,   bezier = "easeOut" })
hl.animation({ leaf = "fadeDim",             enabled = true,  speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeLayers",          enabled = true,  speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeLayersIn",        enabled = true,  speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "fadeLayersOut",       enabled = true,  speed = 2.5, bezier = "easeIn" })
hl.animation({ leaf = "fadePopups",          enabled = true,  speed = 3.5, bezier = "easeOut" })
hl.animation({ leaf = "fadePopupsIn",        enabled = true,  speed = 3.5, spring = "springOpen" })
hl.animation({ leaf = "fadePopupsOut",       enabled = true,  speed = 2.5, bezier = "easeIn" })
hl.animation({ leaf = "fadeDpms",            enabled = true,  speed = 4.5, bezier = "easeOut" })

-- Border
hl.animation({ leaf = "border",              enabled = true,  speed = 2.5, bezier = "easeOut" })
hl.animation({ leaf = "borderangle",         enabled = false })

-- Workspaces
hl.animation({ leaf = "workspaces",          enabled = true,  speed = 4.5, bezier = "wsTransition", style = "slide" })
hl.animation({ leaf = "workspacesIn",        enabled = true,  speed = 4.5, bezier = "wsTransition", style = "slide" })
hl.animation({ leaf = "workspacesOut",       enabled = true,  speed = 4.5, bezier = "wsTransition", style = "slide" })
hl.animation({ leaf = "specialWorkspace",    enabled = true,  speed = 4.5, spring = "springOpen",   style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true,  speed = 5,   spring = "springOpen",   style = "slidevert" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true,  speed = 3.5, bezier = "easeIn",       style = "slidevert" })

-- Misc
hl.animation({ leaf = "zoomFactor",          enabled = true,  speed = 4.5, spring = "springOpen" })
hl.animation({ leaf = "monitorAdded",        enabled = true,  speed = 4.5, bezier = "easeOut" })
