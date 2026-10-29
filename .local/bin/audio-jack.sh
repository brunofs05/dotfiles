#!/usr/bin/env bash
# Alterna o perfil da placa SOF entre Speaker e Headphones (o UCM separa os dois).
#   audio-jack.sh watch   -> troca automaticamente ao plugar/tirar o fone P2
#   audio-jack.sh toggle  -> alterna manualmente

CARD="alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic"
HP="HiFi (HDMI1, HDMI2, HDMI3, Headphones, Mic1, Mic2)"
SPK="HiFi (HDMI1, HDMI2, HDMI3, Mic1, Mic2, Speaker)"

current() { pactl list cards | sed -n "/Name: $CARD/,/Active Profile/p" | sed -n 's/.*Active Profile: //p'; }

plugged() { pactl list cards | grep -E '^\s+\[Out\] Headphones:' | grep -qv 'not available'; }

set_profile() {
    [ "$(current)" = "$1" ] && return
    pactl set-card-profile "$CARD" "$1"
    # move os streams abertos para o novo sink padrão
    sleep 0.3
    for s in $(pactl list short sink-inputs | cut -f1); do
        pactl move-sink-input "$s" @DEFAULT_SINK@
    done
}

apply() { if plugged; then set_profile "$HP"; else set_profile "$SPK"; fi; }

case "$1" in
    toggle)
        if [ "$(current)" = "$HP" ]; then set_profile "$SPK"; else set_profile "$HP"; fi ;;
    watch)
        apply
        pactl subscribe | grep --line-buffered "'change' on card" | while read -r _; do apply; done ;;
    *)
        apply ;;
esac
