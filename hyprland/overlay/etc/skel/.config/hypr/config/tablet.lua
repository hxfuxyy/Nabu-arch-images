-- Hyprland 0.57 + the matching Hyprgrass commit. Touchscreen gestures, not touchpad.
hl.config({
    input = {kb_layout = "ua,ru,us", touchdevice = {enabled = true}},
    gestures = {workspace_swipe_touch = true, workspace_swipe_cancel_ratio = 0.15},
    decoration = {blur = {enabled = false}},
})
if hl.plugin.hyprgrass then
    hl.config({plugin = {hyprgrass = {sensitivity = 4.0, edge_margin = 24,
        long_press_delay = 450, resize_on_border_long_press = true}}})
    local hg = hl.plugin.hyprgrass
    hg.gesture({pattern = {kind="swipe", fingers=3, direction="horizontal"}, action="workspace"})
    hg.bind({pattern = {kind="edge", origin="down", direction="up"},
        action=hl.dsp.exec_cmd("serpantinum msg toggle launcher")})
    hg.bind({pattern = {kind="edge", origin="up", direction="down"},
        action=hl.dsp.exec_cmd("serpantinum msg toggle system")})
    hg.bind({pattern = {kind="tap", fingers=3}, action=hl.dsp.exec_cmd("nabu-keyboard")})
    hg.bind({pattern = {kind="swipe", fingers=3, direction="up"},
        action=hl.dsp.exec_cmd("serpantinum msg toggle launcher")})
    -- Four fingers switch windows without closing an application by accident.
    hg.bind({pattern = {kind="swipe", fingers=4, direction="left"}, action=hl.dsp.window.cycle_next({next=true})})
    hg.bind({pattern = {kind="swipe", fingers=4, direction="right"}, action=hl.dsp.window.cycle_next({next=false})})
    hg.bind({pattern = {kind="swipe", fingers=3, direction="down"}, action=hl.dsp.exec_cmd("serpantinum msg toggle system")})
    hg.bind({pattern = {kind="pinch", fingers=3, direction="pinchin"}, action=hl.dsp.window.float()})
    hg.gesture({pattern = {kind="swipe", fingers=4, direction="down"}, action="fullscreen"})
    local brightness = dofile(os.getenv("HOME") .. "/.config/hypr/plugins/hyprgrass/extras/brightnessctl.lua")
    local volume = dofile(os.getenv("HOME") .. "/.config/hypr/plugins/hyprgrass/extras/wpctl.lua")
    hg.gesture({pattern={kind="edge", origin="left", fingers=2, direction="vertical"},
        action=brightness.brightness_action({direction="vertical",flip=true,min_value=5,throttle_ms=100})})
    hg.gesture({pattern={kind="edge", origin="right", fingers=2, direction="vertical"},
        action=volume.volume_action({direction="vertical",flip=true,throttle_ms=100})})
    hg.gesture({pattern = {kind="swipe", fingers=4, direction="up"}, action="fullscreen"})
    hg.bind({pattern = {kind="longpress", fingers=3}, action=hl.dsp.window.drag(), mouse=true})
    hg.bind({pattern = {kind="tap", fingers=4}, action=hl.dsp.exec_cmd("nabu-rotate")})
end
-- Volume keys stay volume keys; physical power button suspends via logind.
hl.bind("SUPER + K", hl.dsp.exec_cmd("nabu-keyboard"))
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("GTK_THEME=Adwaita:dark squeekboard")
end)

-- nabu-rotate stores the matching display/touch transforms here.
local rotation = io.open(os.getenv("HOME") .. "/.config/hypr/config/rotation.lua", "r")
if rotation then rotation:close(); dofile(os.getenv("HOME") .. "/.config/hypr/config/rotation.lua") end
