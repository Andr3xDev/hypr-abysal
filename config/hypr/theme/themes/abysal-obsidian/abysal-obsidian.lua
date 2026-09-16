local palette = require("theme.palette")

local color = palette({
    bg = "#151515",
    bg_elevated = "#232323",
    border_muted = "#2A2A2A",
    border = "#323232",
    border_strong = "#494949",
    text_muted = "#72837D",
    text_secondary = "#A7B4B0",
    text_primary = "#E9EDEB",

    turquoise = "#5AE2DD",
    turquoise_dark = "#143937",
    aquamarine = "#67E4B2",
    aquamarine_dark = "#14392A",
    blue = "#A6D5F2",
    blue_dark = "#162A36",

    red = "#EF616D",
    red_dark = "#391417",
    green = "#84EB8D",
    green_dark = "#143917",
    orange = "#F39049",
    orange_dark = "#392314",

    yellow = "#ECEC8D",
    yellow_dark = "#393914",
    purple = "#B590EA",
    purple_dark = "#231439",
    pink = "#EA71AD",
    pink_dark = "#391426",
})

color.border_active = color.border
color.border_inactive = color.border_muted
color.wallpaper = "~/.config/wallpapers/tkg.jpg"
color.lock_background_brightness = 0.8

return color
