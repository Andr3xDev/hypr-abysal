----------------------------------------------------------------------------------
--
--       ,--.   ,--.               ,--.  ,--.
--       |   `.'   | ,---. ,--,--, `--',-'  '-. ,---. ,--.--. ,---.
--       |  |'.'|  || .-. ||      \,--.'-.  .-'| .-. ||  .--'(  .-'
--       |  |   |  |' '-' '|  ||  ||  |  |  |  ' '-' '|  |   .-'  `)
--       `--'   `--' `---' `--''--'`--'  `--'   `---' `--'   `----'
--
--             _______
--　　　　　 /  ＞　　フ
--　　　　　| 　_　 _ l      RESUME: Here are the monitor and screen config
--　 　　　／` ミ＿xノ               for laptops, but they are not universal
--　　 　 /　　　 　 |
--　　　 /　 ヽ　　 ﾉ
--　 　 │　　|　|　|         AUTHOR:  Andr3xDev
--　／￣|　　 |　|　|        URL: https://github.com/Andr3xDev/hypr-abysal
--　| (￣ヽ＿_ヽ_)__)
--　＼二つ
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
--- My Monitors - Change input with yours
----------------------------------------------------------------------------------

hl.monitor({
	output       = "eDP-1",
	mode         = "1920x1080@144",
	position     = "auto-left",
	scale        = 1.25,
	bitdepth     = 8,
	cm           = "srgb",
})

hl.monitor({
	output       = "HDMI-A-1",
	mode         = "1920x1080@75",
	position     = "auto-right",
	scale        = 1.0,
	bitdepth     = 8,
	cm           = "srgb",
})

hl.monitor({
	output       = "DP-1",
	mode         = "1920x1080@100",
	position     = "auto",
	scale        = 1.0,
	bitdepth     = 8,
	cm           = "srgb",
})
