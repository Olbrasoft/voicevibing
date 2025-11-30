#!/bin/bash
# voice-vibing.sh - VoiceVibing startup script
# Spouští voice assistant a OpenCode s rozděleným oknem

# Unikátní socket pro toto kitty okno
KITTY_SOCKET="/tmp/kitty-voicevibing-$$"

# 1. Spustit kitty s vlastním socketem
kitty --listen-on "unix:$KITTY_SOCKET" --title "VoiceVibing" bash -c '
    echo "=== Spouštím Voice Assistant služby ==="
    
    echo "1. Startuji edge-tts-server..."
    sudo systemctl start edge-tts-server.service
    
    echo "2. Startuji push-to-talk-dictation..."
    sudo systemctl start push-to-talk-dictation.service
    
    echo "3. Startuji transcription-indicator..."
    systemctl --user start transcription-indicator.service
    
    echo ""
    echo "=== Hotovo, spouštím OpenCode ==="
    sleep 0.5
    
    # Spustí OpenCode (nahradí tento shell)
    exec ~/.local/bin/opencode-fixedport
' &

# 2. Počkat na socket - aktivně čekat až bude dostupný
echo "Čekám na kitty socket..."
for i in {1..30}; do
    if [ -S "$KITTY_SOCKET" ]; then
        # Socket existuje, zkusíme se připojit
        if kitty @ --to "unix:$KITTY_SOCKET" ls &>/dev/null; then
            echo "Socket je připraven!"
            break
        fi
    fi
    sleep 0.2
done

# 3. Počkat na OpenCode (až se načte)
echo "Čekám na spuštění OpenCode..."
sleep 3

# 4. Přepnout na splits layout
kitty @ --to "unix:$KITTY_SOCKET" goto-layout splits

# 5. Spustit ContinuousListener v dolním okně (použít .NET 10 z ~/.dotnet)
kitty @ --to "unix:$KITTY_SOCKET" launch --location=hsplit --bias=30 --cwd=/home/jirka/voice-assistant/continuous-listener ~/.dotnet/dotnet ContinuousListener.dll

# 6. Přesunout okno doleva
sleep 0.3
~/.local/bin/move-window-left.sh
