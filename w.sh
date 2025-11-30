#!/bin/bash
# w.sh - VoiceVibing startup script
# Spouští voice assistant a OpenCode s rozděleným oknem

# Spustí voice assistant
va start

# Spustí kitty s OpenCode
~/.local/bin/kitty-with-opencode.sh

# Počká na vytvoření okna
sleep 0.5

# Přepne na splits layout a rozdělí okno horizontálně (horní/dolní)
# V dolním okně spustí ContinuousListener
kitty @ goto-layout splits
kitty @ launch --location=hsplit --cwd=/home/jirka/voice-assistant/continuous-listener dotnet ContinuousListener.dll
