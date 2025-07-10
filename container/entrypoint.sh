#!/bin/bash

# Стартувај виртуелен дисплеј
rm -f /tmp/.X0-lock
Xvfb :0 -screen 0 1024x768x16 &
export DISPLAY=:0

# Wine конфигурации
export WINEPREFIX=/wine
export WINEARCH=win32
export WINEDLLOVERRIDES="ole32,oleaut32,windowscodecs=n;winemenubuilder.exe=d"

# Почекај малку за да се инициализира X
sleep 2

# Стартувај ја апликацијата
wine "z:\\dude\\dude.exe" --server
