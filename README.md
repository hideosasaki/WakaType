# WakaType

WakaType is a specialized Japanese typing game designed to help users memorize and practice **Hyakunin Isshu** (traditional Japanese poetry). It features a robust typing engine that supports various romaji-to-kana mappings, historical kana usage, and a dedicated memorization mode.

## Key Features

- **Hyakunin Isshu Practice**: Includes all 100 poems with their respective "Kami-no-ku" (first half) and "Shimo-no-ku" (second half).
- **Advanced Typing Engine**: 
    - Supports multiple romaji variations (e.g., "shi" vs "si", "ji" vs "zi").
    - Handles complex Japanese phonetics including Dakuten, Yoon (contracted sounds), and Sokuon (geminate consonants).
    - Special support for historical kana conventions (e.g., "kefu" -> "kyou").
- **Game Modes**:
    - **Kami-to-Shimo**: Type the second half after seeing the first half.
    - **Shimo-to-Kami**: Type the first half after seeing the second half.
    - **All**: Type the entire poem.
- **Memorization Mode**: If you run out of time (Timeout) or choose to "Give Up", the app reveals the correct answer and requires you to type it correctly to proceed, reinforcing your memory.
- **Visual Feedback**: Displays your last incorrect input in a large font to help you identify and correct typing errors instantly.

## Requirements

- **macOS 14.0+**
- **Xcode 15.0+** (for development/building)

## How to Build & Run

1. Open `WakaType.xcodeproj` in Xcode.
2. Select a scheme (WakaType) and a destination (My Mac).
3. Press `Cmd + R` to build and run.

## Distribution

To distribute the application to another Mac:
1. Set the build destination to **"Any Mac"**.
2. Go to **Product > Archive**.
3. Use the **Distribute App** button in the Organizer to export a standalone `.app` bundle.
4. Compress the `.app` into a `.zip` file for sharing.

*For detailed instructions, refer to [.agent/workflows/distribute.md](.agent/workflows/distribute.md).*

## Tech Stack

- **Swift & SwiftUI**: Core logic and modern user interface.
- **Observation Framework**: Reactive state management.
- **XCTest / Swift Testing**: Comprehensive unit tests for the typing logic and game sessions.

## Author

- **HideosaSasaki** ([GitHub](https://github.com/hideosasaki))

---
*Created with ❤️ for Waka (Japanese Poetry) enthusiasts.*
