#!/bin/bash

# =========================================
#  Closerrr - Wireless iPhone Dev Runner
# =========================================

FLUTTER="/Users/tushar/fvm/versions/3.35.7/bin/flutter"
PROJECT_DIR="/Users/tushar/Closerrr Code/closerrr-frontend"
BACKEND_DIR="/Users/tushar/Closerrr Code/closerrr-backend"
BACKEND_PORT=5253

echo ""
echo "============================================"
echo "  🚀 Closerrr Dev Launcher"
echo "============================================"
echo ""

# ── Step 1: Start backend if not already running ──
echo "🔧 Checking backend server..."
if lsof -i :$BACKEND_PORT > /dev/null 2>&1; then
    echo "   ✅ Backend already running on port $BACKEND_PORT"
else
    echo "   ⚡ Starting backend server..."
    cd "$BACKEND_DIR"
    node index.js > /tmp/closerrr-backend.log 2>&1 &
    BACKEND_PID=$!
    echo "   ⏳ Waiting for backend to start..."
    sleep 4
    if lsof -i :$BACKEND_PORT > /dev/null 2>&1; then
        echo "   ✅ Backend started! (PID: $BACKEND_PID)"
    else
        echo "   ❌ Backend failed to start. Check logs: /tmp/closerrr-backend.log"
        read -p "Press Enter to exit..."
        exit 1
    fi
fi

echo ""

# ── Step 2: Check for iPhone ──
echo "📱 Looking for your iPhone (wired or wireless)..."
DEVICES=$("$FLUTTER" devices 2>&1)

if echo "$DEVICES" | grep -q "iPhone\|iPad"; then
    echo "   ✅ iPhone found!"
    echo ""
    echo "============================================"
    echo "  Pick a mode:"
    echo "  1) 🔥 Debug   — Hot reload (Default, press 'r' for instant changes)"
    echo "  2) 🚀 Release — Standalone (clear from recents, still works)"
    echo "============================================"
    read -p "  Enter 1 or 2 [Default: 1]: " MODE
    echo ""

    if [ -z "$MODE" ]; then
        MODE="1"
    fi

    cd "$PROJECT_DIR"
    if [ "$MODE" = "1" ]; then
        echo "  Starting in DEBUG mode — press 'r' anytime to hot reload!"
        echo "  (Xcode GUI is not required to be open)"
        echo ""
        "$FLUTTER" run
    else
        echo "  Starting in RELEASE mode — app works standalone after install."
        echo ""
        "$FLUTTER" run --release
    fi
else
    echo "   ❌ iPhone NOT found."
    echo ""
    echo "👉 Make sure:"
    echo "   • Your iPhone is connected via cable OR on the same Wi-Fi network"
    echo "   • Developer Mode is ON (Settings → Privacy & Security → Developer Mode)"
    echo "   • The iPhone is unlocked and trusted"
    echo ""
    read -p "Press Enter to exit..."
fi
