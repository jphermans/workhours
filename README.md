# Workhours App 📊⏰

Workhours is a simple iOS application built with SwiftUI to help you track your work hours efficiently. Whether you're working on external client projects or internal tasks, this app provides a straightforward way to log your time, associated details, and calculate relevant metrics based on your settings.

## Features ✨

*   **Work Entry Tab:**
    *   Log work entries with date, customer, and description.
    *   Distinguish between **External** and **Internal** orders using a toggle.
    *   For **External Orders**: Record customer order ID, amount, and SPIRIT order ID. Calculates estimated *bookable hours* based on the net amount (using the Net Percentage from Settings) and your hourly rate.
    *   For **Internal Orders**: Record hours booked and SPIRIT order ID. Calculates potential earnings based on hours and hourly rate.
    *   Data is saved locally using **SQLite**.
*   **Settings Tab:**
    *   Configure your **Net Percentage (%)** (e.g., for VAT or other deductions) used in external order calculations.
    *   Set your default **Hourly Rate (€)** for calculations.
    *   Choose your preferred **Appearance** (System, Light, or Dark mode).
*   **Custom Theming:** Utilizes a distinct color palette for a consistent look and feel across light and dark modes.
*   **Built with SwiftUI:** Modern, declarative UI framework for iOS.

## Color Palette 🎨

The app uses a custom color palette for branding and UI elements:

| Color Name             | Hex       | Preview                                                                                             | Notes                     |
| ---------------------- | --------- | --------------------------------------------------------------------------------------------------- | ------------------------- |
| `atlasTeal`            | `#054E5A` | <img width="60" alt="Atlas Teal" src="https://via.placeholder.com/60/054E5A/054E5A.png?text=+">         | Primary branding color    |
| `atlasGray`            | `#A1A9B4` | <img width="60" alt="Atlas Gray" src="https://via.placeholder.com/60/A1A9B4/A1A9B4.png?text=+">         | Neutral / secondary       |
| `atlasGold`            | `#E1B77E` | <img width="60" alt="Atlas Gold" src="https://via.placeholder.com/60/E1B77E/E1B77E.png?text=+">         | Accent / buttons          |
| `atlasGreen`           | `#5D7875` | <img width="60" alt="Atlas Green" src="https://via.placeholder.com/60/5D7875/5D7875.png?text=+">       | Accent (unused variant?)  |
| `atlasLightGreen`      | `#CED9D7` | <img width="60" alt="Atlas Light Green" src="https://via.placeholder.com/60/CED9D7/CED9D7.png?text=+"> | Accent (unused variant?)  |
| `atlasBlue`            | `#123F6D` | <img width="60" alt="Atlas Blue" src="https://via.placeholder.com/60/123F6D/123F6D.png?text=+">         | Accent (unused variant?)  |
| `atlasBackgroundLight` | `#FAF9F4` | <img width="60" alt="Atlas Background Light" src="https://via.placeholder.com/60/FAF9F4/FAF9F4.png?text=+"> | Base for light mode       |
| `atlasBackground`      | Dynamic   | Adapts automatically for Light/Dark Mode (Uses `AtlasBackgroundLight` in light)                     | Main view background      |
| `atlasPanel`           | Dynamic   | Adapts automatically for Light/Dark Mode (Uses `White` or dark gray)                                  | Panel/card backgrounds    |
| `atlasText`            | Dynamic   | Adapts automatically for Light/Dark Mode (Uses `atlasTeal` or `White`)                              | Primary text color        |

## Icons 🖼️

The app utilizes **SF Symbols** for a clean and native iOS appearance. Key icons include:

*   `clock`: Work Entry Tab icon
*   `gear`: Settings Tab icon
*   `percent`: Net Percentage setting label
*   `eurosign`: Hour Rate setting label

## Technology Stack 🛠️

*   **UI Framework:** SwiftUI
*   **Language:** Swift
*   **Database:** SQLite (using the C `sqlite3` library directly)
*   **State Management:** `@State`, `@Binding`, `@AppStorage`, `@Environment`

## Getting Started 🚀

1.  Clone this repository.
2.  Open the `Workhours.xcodeproj` file in Xcode.
3.  Ensure you have a compatible iOS simulator or a physical device selected.
4.  Build and run the application (Cmd+R).
5.  Navigate to the **Settings** tab first to configure your **Hourly Rate** and **Net Percentage**.
6.  Use the **Work** tab to start logging your hours. The database file (`Workhours.sqlite`) will be created automatically in the app's Documents directory on first save.

## Screenshots 📸

*(Please add screenshots of the main Work Entry screen (both external/internal modes) and the Settings screen here to give users a visual overview.)*
