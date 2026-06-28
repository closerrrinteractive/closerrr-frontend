#!/bin/bash
# One-time setup: enable "Connect via network" for Closerrr's iPhone in Xcode.
set -e

echo "Enabling wireless iOS debugging for Closerrr's iPhone..."
echo "(Keep the iPhone plugged in via USB until this finishes.)"
echo ""

osascript <<'APPLESCRIPT'
tell application "Xcode"
	activate
end tell
delay 2

tell application "System Events"
	tell process "Xcode"
		click menu item "Devices and Simulators" of menu "Window" of menu bar 1
	end tell
end tell
delay 3

tell application "System Events"
	tell process "Xcode"
		set frontmost to true
		set cbFound to false
		repeat with w in windows
			try
				set cb to checkbox "Connect via network" of w
				if value of cb is 0 then
					click cb
				end if
				set cbFound to true
				exit repeat
			end try
		end repeat
		if not cbFound then
			repeat with w in windows
				repeat with cb in checkboxes of w
					try
						if name of cb contains "network" then
							if value of cb is 0 then click cb
							set cbFound to true
						end if
					end try
				end repeat
			end repeat
		end if
		if cbFound then
			display notification "Connect via network is enabled. Wait for the globe icon, then unplug the cable." with title "Closerrr wireless setup"
		else
			display dialog "Could not find the Connect via network checkbox. In Xcode: Window → Devices and Simulators → select Closerrr's iPhone → check Connect via network." buttons {"OK"} default button "OK"
		end if
	end tell
end tell
APPLESCRIPT

echo ""
echo "Done. Waiting 15 seconds for network pairing..."
sleep 15

echo ""
echo "Checking device transport..."
xcrun devicectl device info details --device 00008101-001D68290A2B001E 2>&1 | grep -E "transportType|tunnelState|name:" || true

echo ""
echo "You can now unplug the iPhone cable."
echo "Verify with: cd \"$(dirname "$0")/..\" && fvm flutter devices"
read -p "Press Enter to close this window..."
