#!/usr/bin/env bash
set -euo pipefail
[[ $(uname -m) == aarch64 ]] || { echo "Native ARM64 required" >&2; exit 1; }
pacman -Syu --noconfirm
pacman -S --needed --noconfirm kitty cava zbar tesseract tesseract-data-eng pavucontrol alsa-utils wl-clipboard fd qt6-multimedia qt6-5compat ripgrep cliphist jq socat inotify-tools pamixer brightnessctl ddcutil acpi iw bluez bluez-utils libnotify networkmanager lm_sensors bc matugen pipewire wireplumber pipewire-pulse pipewire-alsa libpulse python imagemagick wget file git psmisc ffmpeg fastfetch quickshell unzip python-websockets python-jeepney qt6-websockets grim playerctl satty xdg-desktop-portal-gtk slurp wmctrl power-profiles-daemon qt5-wayland qt5-quickcontrols qt5-quickcontrols2 qt5-graphicaleffects qt6-wayland qt5ct qt6ct adwaita-icon-theme gpu-screen-recorder wf-recorder adw-gtk-theme hyprland xdg-desktop-portal-hyprland polkit-gnome firefox upower qt6-virtualkeyboard sddm breeze base-devel rust meson ninja glm cairo pango wayland wayland-protocols libxkbcommon pipewire-jack scdoc libcamera-tools camera-studio nabu-torch noto-fonts noto-fonts-emoji ttf-iosevka-nerd xdg-user-dirs
# The plugin API is version specific. Refuse silently mismatched upgrades.
[[ $(pacman -Q hyprland | cut -d' ' -f2) == 0.57.0-* ]]
useradd -m builduser
chown -R builduser:builduser /var/tmp/nabu-src
runuser -u builduser -- bash -euo pipefail <<'BUILD'
cd /var/tmp/nabu-src/audio
make -j2
make test
cd ../ski
cargo build --release --locked -j2
cd ../wvkbd
make -j2
cd ../hyprgrass
meson setup build --prefix=/usr/local
meson compile -C build -j2
BUILD
cd /var/tmp/nabu-src
make -C audio PREFIX=/usr/local install
(cd ski && sh packaging/stage.sh /)
make -C wvkbd PREFIX=/usr/local install
install -Dm755 hyprgrass/build/src/libhyprgrass.so /usr/local/lib/libhyprgrass.so
install -Dm644 hyprgrass/LICENSE /usr/local/share/licenses/hyprgrass/LICENSE
share=/usr/local/share/serpantinum
mkdir -p "$share"
cp -a serpantinum/{bin,src,config,compositors,version.txt,LICENSE.md} "$share/"
chmod +x "$share"/bin/*
find "$share/src" -type f \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} +
ln -s ../share/serpantinum/bin/serpantinum /usr/local/bin/serpantinum
ln -s ../share/serpantinum/bin/serpantinumd /usr/local/bin/serpantinumd
# Suppress the upstream x86-only installer update path.
printf 'nabu-source-build\n' > "$share/package-managed"
install -Dm644 serpantinum/packaging/desktop/serpantinum-settings.desktop /usr/share/applications/serpantinum-settings.desktop
install -Dm644 serpantinum/packaging/desktop/serpantinum-settings.svg /usr/share/icons/hicolor/scalable/apps/serpantinum-settings.svg
# Add an in-surface keyboard to this exact pinned lockscreen source.
cp /usr/local/share/nabu/TouchKeyboard.qml "$share/src/quickshell/lock/TouchKeyboard.qml"
python - <<'LOCK'
from pathlib import Path
p=Path('/usr/local/share/serpantinum/src/quickshell/lock/LockScreen.qml')
s=p.read_text(); assert s.rstrip().endswith('}')
s=s.rstrip()[:-1]+'''
    TouchKeyboard {
        target: lockScreenRoot.passwordInput
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 24, 1000)
        height: 340
        z: 1000
        visible: !lockScreenRoot.isUnlocking && !lockScreenRoot.isPlayingIntro
    }
}
'''
p.write_text(s)
LOCK
cfg=/home/user/.config
cp -a /etc/skel/.config/. "$cfg/"
for app in kitty cava fastfetch; do
    mkdir -p "$cfg/$app"
    cp -a "$share/config/$app/." "$cfg/$app/"
done
mkdir -p "$cfg/serpantinum" /home/user/Pictures/Wallpapers
jq '.bar.height=56 | .dock.elementSize=56 | .dock.smartAutohide=false | .general.language="ua" | del(.display.monitors) | .lockscreen.fingerprintEnabled=false' "$share/config/serpantinum/settings.json" > "$cfg/serpantinum/settings.json"
# Pin the compositor until its plugin is rebuilt; kernel is pinned by the nabu base overlay.
sed -i '/^IgnorePkg = /s/$/ hyprland/' /etc/pacman.conf
systemctl enable sddm NetworkManager bluetooth
systemctl --global enable pipewire pipewire-pulse wireplumber
systemctl set-default graphical.target
chown -R user:user /home/user
for executable in Hyprland quickshell wvkbd-mobintl ski serpantinum-audio; do
    command -v "$executable"
    file "$(command -v "$executable")" | tee -a /etc/nabu-build-elf.txt
    file "$(command -v "$executable")" | grep -q 'ARM aarch64'
    ! ldd "$(command -v "$executable")" | grep -q 'not found'
done
ldd /usr/local/lib/libhyprgrass.so | tee /etc/nabu-plugin-libs.txt
! grep -q 'not found' /etc/nabu-plugin-libs.txt
pacman -Q > /etc/nabu-packages.txt
rm -rf /var/tmp/nabu-src /home/builduser
userdel builduser
