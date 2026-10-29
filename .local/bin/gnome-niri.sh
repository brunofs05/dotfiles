#!/usr/bin/env bash
# Replica (no que dá) a config do niri no GNOME. Idempotente.
set -u
gs() { gsettings set "$@"; }
WM=org.gnome.desktop.wm.keybindings
SH=org.gnome.shell.keybindings
MK=org.gnome.settings-daemon.plugins.media-keys

# --- Input ---
gs org.gnome.desktop.input-sources sources "[('xkb', 'us+intl')]"
gs org.gnome.desktop.input-sources xkb-options "['caps:swapescape']"
gs org.gnome.desktop.peripherals.mouse accel-profile 'flat'
gs org.gnome.desktop.peripherals.mouse speed 0.1
gs org.gnome.desktop.peripherals.touchpad tap-to-click true
gs org.gnome.desktop.peripherals.touchpad disable-while-typing true
gs org.gnome.desktop.peripherals.touchpad natural-scroll true
gs org.gnome.desktop.wm.preferences focus-mode 'sloppy'   # focus-follows-mouse

# --- Wallpaper ---
WP="file:///home/brunofs/Pictures/seagull-realesrgan.jpg"
gs org.gnome.desktop.background picture-uri "$WP"
gs org.gnome.desktop.background picture-uri-dark "$WP"
gs org.gnome.desktop.background picture-options 'zoom'

# --- Workspaces: 4 fixos ---
gs org.gnome.mutter dynamic-workspaces false
gs org.gnome.desktop.wm.preferences num-workspaces 4

# Libera atalhos padrão que conflitam
gs $WM activate-window-menu "[]"                       # Alt+Space
gs $SH toggle-quick-settings "[]"                      # Super+S
gs $MK screensaver "['<Super>l']"
gs org.gnome.mutter.keybindings switch-monitor "['XF86Display']"   # Super+P
gs $WM switch-to-application-1 "[]" 2>/dev/null
for i in 1 2 3 4 5 6 7 8 9; do gs org.gnome.shell.keybindings switch-to-application-$i "[]"; done
gs $SH show-screenshot-ui "[]"                         # Print -> script

gs org.gnome.desktop.default-applications.terminal exec 'alacritty'
for i in 5 6 7 8 9; do gs $WM switch-to-workspace-$i "[]"; gs $WM move-to-workspace-$i "[]"; done

# --- Workspaces (Alt+setas e Alt+H/L, Alt+1..9) ---
gs $WM switch-to-workspace-left  "['<Alt>Left','<Alt>h']"
gs $WM switch-to-workspace-right "['<Alt>Right','<Alt>l']"
gs $WM move-to-workspace-left    "['<Alt><Shift>Left','<Alt><Shift>h']"
gs $WM move-to-workspace-right   "['<Alt><Shift>Right','<Alt><Shift>l']"
for i in 1 2 3 4; do
  gs $WM switch-to-workspace-$i  "['<Alt>$i']"
  gs $WM move-to-workspace-$i    "['<Alt><Shift>$i']"
done

# --- Janelas ---
gs $WM close "['<Alt><Shift>q','<Alt>F4']"
gs $WM cycle-windows          "['<Alt>j','<Super>2','<Alt>Escape']"
gs $WM cycle-windows-backward "['<Alt>k','<Super>1','<Alt><Shift>Escape']"
gs $WM toggle-maximized  "['<Alt>p']"
gs $WM toggle-fullscreen "['<Alt><Shift>f','<Alt>y']"
gs $SH toggle-overview   "['<Alt>d','<Alt>space']"

# --- Atalhos customizados ---
B=/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
declare -a NAMES=() 
add() { # nome comando atalho
  local id="niri$((${#NAMES[@]}))"; NAMES+=("$id")
  local k="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$B/$id/"
  gs "$k" name "$1"; gs "$k" command "$2"; gs "$k" binding "$3"
}
KC=/home/brunofs/.config/kitty/kitty-wlctl.conf
add "alacritty"   "alacritty"                               "<Alt>Return"
add "firefox"     "firefox"                                 "<Super>f"
add "thunar"      "thunar"                                  "<Super>e"
add "win-p"       "bash -c ~/.local/bin/win-p.sh"           "<Super>p"
add "wifi"        "kitty -c $KC -T wifi wlctl"              "<Super>s"
add "bluetooth"   "kitty -c $KC -T blue bluetui"            "<Super>b"
add "brilho-min"  "brightnessctl set 1%"                    "<Alt><Shift>m"
add "screenshot"  "/home/brunofs/.local/bin/screenshot.sh"  "Print"
add "screenshot2" "/home/brunofs/.local/bin/screenshot.sh"  "<Alt><Shift>s"
add "screenshot-edit" "/home/brunofs/.local/bin/screenshot_edit.sh" "<Super>Print"
add "logout"      "gnome-session-quit --logout"             "<Alt><Shift>e"

LIST=$(printf "'$B/%s/'," "${NAMES[@]}"); gs $MK custom-keybindings "[${LIST%,}]"
echo ok
