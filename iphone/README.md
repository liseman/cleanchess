# Clean Chess for iPhone

Minimal black-and-white iPhone version of Clean Chess.

## Files

- `CleanChess.xcodeproj/` — open this in Xcode
- `CleanChessApp.swift` — app entrypoint
- `ContentView.swift` — UI + chess logic
- `Info.plist` — app metadata
- `Assets.xcassets/` — asset catalog + app icon slots

## Run

1. Open `CleanChess.xcodeproj` in Xcode on macOS
2. Select the `CleanChess` target
3. In **Signing & Capabilities**, choose your Apple team/account
4. Optionally change the bundle identifier from `com.liseman.cleanchess`
5. Build and run on an iPhone simulator or device

## App Store prep

- Add real app icons to `Assets.xcassets/AppIcon.appiconset`
- Set your own Apple signing team in Xcode
- Update version/build number before release
- Archive from Xcode and upload to App Store Connect

## Notes

- Minimal monochrome UI
- Two-player local chess
- Castling supported
- Pawn promotion to queen
- Undo supported
- Current piece set uses the same silhouette for both colors, with serif glyph styling
