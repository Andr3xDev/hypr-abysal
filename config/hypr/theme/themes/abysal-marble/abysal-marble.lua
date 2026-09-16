-- ---------------------------------------------------------------------------
-- Abysal Marble
-- Color palette and UI tokens for the Abysal Marble theme
-- ---------------------------------------------------------------------------

return {
	-- Base colors
	base    = "rgb(f0f3f4)", -- main_background
	surface = "rgb(d8e0e3)", -- secondary_background
	text    = "rgb(0d1518)", -- main_text

	-- Palette
	color1 = "rgb(0d9488)", -- turquoise
	color2 = "rgb(8a5a1d)", -- orange
	color3 = "rgb(8a7818)", -- sand
	color4 = "rgb(c13034)", -- soft_red
	color5 = "rgb(2f4ea8)", -- steel_blue
	color6 = "rgb(6b3d7b)", -- lavender_purple
	color7 = "rgb(33424a)", -- dark_gray_secondary
	color8 = "rgb(54646a)", -- medium_gray_comments
	color9 = "rgb(8f9da2)", -- light_gray_borders

	-- Highlight colors
	highlight1 = "rgb(d8e0e3)", -- faint_selection
	highlight2 = "rgb(66777d)", -- medium_selection
	highlight3 = "rgb(425258)", -- strong_selection

	-- Wallpaper
	wallpaper = "~/.config/wallpapers/vogabond.png",

	-- Border configuration
	border_active   = "rgb(8f9da2)", -- Muted gray focus   ($color9)
	border_inactive = "rgb(aeb9bd)", -- Soft light gray    ($color9-subtle)
	border_urgent   = "rgb(c13034)", -- Deep Red            ($color4)

	-- Shadows
	shadow_active   = "rgba(00000050)",
	shadow_inactive = "rgba(00000000)",

	-- Opacity
	opacity = 0.92,

	-- Hyprlock specifics
	lock_background_brightness = 0.9,
	lock_backsurface  = "rgba(240, 243, 244, 0.9)",
	lock_border_color = "rgba(102, 119, 125, 1)",

	lock_text         = "rgb(0d1518)", -- $text
	lock_shadow       = "rgb(f0f3f4)", -- $base

	lock_time_hours   = "rgb(0d1518)", -- $text
	lock_time_date    = "rgb(8a5a1d)", -- $color2

	lock_input_bg     = "rgb(d8e0e3)", -- $surface
	lock_input_border = "rgb(0d9488)", -- $color1
	lock_input_text   = "rgb(0d1518)", -- $text

	lock_actions_border = "rgb(0d9488)", -- $color1
	lock_actions_text   = "rgb(0d1518)", -- $text

	lock_battery_bg     = "rgb(d8e0e3)", -- $surface
	lock_battery_border = "rgb(0d9488)", -- $color1
	lock_battery_text   = "rgb(0d1518)", -- $text
}
