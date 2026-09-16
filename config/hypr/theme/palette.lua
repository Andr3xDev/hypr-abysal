local function rgb(hex)
    return "rgb(" .. hex:sub(2):lower() .. ")"
end

return function(tokens)
    local color = {}
    for name, hex in pairs(tokens) do
        color[name] = rgb(hex)
    end

    color.border_active = color.turquoise
    color.border_inactive = color.border
    color.border_urgent = color.red
    color.shadow_active = "rgba(11111b70)"
    color.shadow_inactive = "rgba(00000000)"

    color.lock_backsurface = color.bg
    color.lock_border_color = color.border
    color.lock_time_hours = color.text_primary
    color.lock_time_date = color.text_secondary
    color.lock_shadow = color.bg
    color.lock_input_bg = color.bg_elevated
    color.lock_input_border = color.border_strong
    color.lock_input_text = color.text_primary
    color.lock_actions_text = color.text_secondary
    color.lock_battery_bg = color.bg_elevated
    color.lock_battery_border = color.border
    color.lock_battery_text = color.text_primary

    color.tokens = tokens
    return color
end
