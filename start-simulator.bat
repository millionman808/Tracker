@echo off
REM Launch the Nibble iPhone simulator in your browser.
cd /d "%~dp0"
start "" "http://localhost:8000/simulator/"
python -m http.server 8000
