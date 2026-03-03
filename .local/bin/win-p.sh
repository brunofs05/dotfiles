#!/bin/bash

# Captura a escolha do usuário
CHOSEN=$(echo -e "Built-in Screen only\nExternal Screen only\nBoth Screens" | fuzzel -d -l 3)

STATUS=$(wlr-randr)

case "$CHOSEN" in
    "Built-in Screen only")
        wlr-randr --output eDP-1 --on --pos 0,0

        if echo "$STATUS" | grep -q "^DP-6"; then wlr-randr --output DP-6 --off; fi
        if echo "$STATUS" | grep -q "^DP-1"; then wlr-randr --output DP-1 --off; fi
        if echo "$STATUS" | grep -q "^HDMI-A-1"; then wlr-randr --output HDMI-A-1 --off; fi
        ;;

    "External Screen only")
      
        if echo "$STATUS" | grep -q "^DP-6"; then
            wlr-randr --output DP-6 --on --pos 0,0
        elif echo "$STATUS" | grep -q "^DP-1"; then
            wlr-randr --output DP-1 --on --pos 0,0
        elif echo "$STATUS" | grep -q "^HDMI-A-1"; then
            wlr-randr --output HDMI-A-1 --on --pos 0,0
        fi

        wlr-randr --output eDP-1 --off
        ;;

    "Both Screens")
        wlr-randr --output eDP-1 --on --pos 0,0

        if echo "$STATUS" | grep -q "^DP-6"; then
            wlr-randr --output DP-6 --on --pos 0,0
        elif echo "$STATUS" | grep -q "^DP-1"; then
            wlr-randr --output DP-1 --on --pos 0,0
        elif echo "$STATUS" | grep -q "^HDMI-A-1"; then
            wlr-randr --output HDMI-A-1 --on --pos 0,0
        fi
        ;;
esac
