# Clean Chess - iOS Xcode Project

Complete Xcode project ready to open and run!

## What's Included

- `CleanChess.zip` - Complete Xcode project
  - CleanChess.xcodeproj - Xcode project file
  - CleanChess/ - Source files
    - CleanChessApp.swift - App entry point
    - ContentView.swift - Complete game implementation
    - Assets.xcassets - Asset catalog

## Quick Start

### Option 1: Open the Project Directly

1. **Download** `CleanChess.zip`
2. **Unzip** the file (double-click it)
3. **Double-click** `CleanChess.xcodeproj` to open in Xcode
4. **Click the Play button** (▶) to run on simulator or device

### Option 2: Manual Steps

1. Download and unzip `CleanChess.zip`
2. Open Terminal and navigate to the unzipped folder
3. Run: `open CleanChess.xcodeproj`
4. In Xcode, select a simulator or your device
5. Press Cmd+R to build and run

## Requirements

- **macOS** (Xcode only runs on Mac)
- **Xcode 13.0 or later**
- **iOS 15.0 or later** (for running the app)

## Features

- ✅ Native iOS app with SwiftUI
- ✅ Clean, minimal interface
- ✅ 2-player local chess game
- ✅ Full chess rules (moves, check, checkmate)
- ✅ Visual move indicators
- ✅ New Game and Undo Move buttons
- ✅ Works on iPhone and iPad

## Running on Your Device

1. Connect your iPhone/iPad to your Mac
2. In Xcode, select your device from the device menu (top bar)
3. You may need to:
   - Trust your Mac on the device
   - Enable Developer Mode (Settings → Privacy & Security → Developer Mode)
   - Sign the app with your Apple ID (Xcode → Signing & Capabilities)
4. Press the Play button (▶)

## Troubleshooting

**"No code signing identities found"**
- Go to Signing & Capabilities tab in Xcode
- Select your Team (use your Apple ID)
- Xcode will automatically create a signing certificate

**"Untrusted Developer"** (when running on device)
- On your iPhone/iPad: Settings → General → VPN & Device Management
- Tap on your developer profile
- Tap "Trust"

**Project won't open**
- Make sure you're opening `CleanChess.xcodeproj`, not the `CleanChess` folder
- Make sure Xcode is installed (download from Mac App Store)

## What's Next?

The app is ready to use! You can:
- Run it on the simulator to test
- Install it on your iPhone/iPad
- Customize colors in `ContentView.swift`
- Publish to the App Store (requires Apple Developer Program, $99/year)

Enjoy your chess game!
