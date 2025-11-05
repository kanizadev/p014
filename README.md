# �� Advanced Color Palette Generator

A beautiful and modern Flutter app for generating color palettes with multiple color scheme types. Features a stunning glassmorphism design with a sage green theme.

## ✨ Features

- **Multiple Color Schemes**: Generate palettes using various color harmony schemes:
  - Random
  - Monochromatic
  - Complementary
  - Triadic
  - Analogous
  - Split Complementary

- **HSL-Based Generation**: Advanced color generation using Hue, Saturation, and Lightness for more natural and harmonious color combinations

- **Interactive Controls**:
  - Pick a base color to generate schemes from
  - Adjust brightness and saturation sliders
  - Quick color scheme selection with filter chips

- **Beautiful UI**:
  - Glassmorphism design with backdrop blur effects
  - Sage green theme throughout
  - Smooth animations and transitions
  - Responsive layout that adapts to different screen sizes

- **Color Information**:
  - Display HEX codes
  - Display RGB values
  - Automatic contrast color calculation for text readability

- **Copy to Clipboard**:
  - One-tap copy for any color code
  - Elegant copy confirmation dialog
  - Visual feedback with animated copy box

- **Save & Manage**:
  - Save your favorite palettes
  - View saved palettes in a dedicated tab
  - Delete saved palettes

- **Export Options**:
  - Export palette as HEX codes
  - Export palette as RGB values

## 📸 Screenshots

_Add screenshots of your app here_

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- An iOS simulator, Android emulator, or physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/p014.git
   cd p014
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 📖 Usage

### Generating a Color Palette

1. **Select a Color Scheme Type**: Choose from the filter chips at the top (Random, Monochromatic, Complementary, etc.)

2. **Pick a Base Color** (optional): Tap "Pick Base Color" to select a starting color for your palette

3. **Adjust Settings** (optional):
   - Use the brightness slider to adjust lightness
   - Use the saturation slider to adjust color intensity

4. **Generate**: Tap "Generate New Palette" to create a new color combination

### Working with Colors

- **Copy a Color**: Tap any color card to copy its HEX code to the clipboard
- **View Details**: Each color card displays:
  - Color number
  - HEX code
  - RGB values

### Saving Palettes

1. Generate or modify a palette
2. Tap "Save Palette" button
3. View saved palettes in the "Saved" tab
4. Delete saved palettes by tapping the delete icon

### Exporting Palettes

- Tap "Export as HEX" to copy all HEX codes
- Tap "Export as RGB" to copy all RGB values

## 🛠️ Technologies Used

- **Flutter** - UI framework
- **Dart** - Programming language
- **Material Design 3** - Design system
- **HSL Color Model** - For advanced color generation

## 📁 Project Structure

```
lib/
  └── main.dart          # Main application file with all UI and logic
```

## 🎨 Color Scheme

The app uses a sage green theme with the following colors:
- Primary: `#87A96B` (Sage Green)
- Light: `#E8F5E9`, `#C8E6C9`, `#A5D6A7`
- Dark: `#6B8E4F`, `#4A5F3A`

## 🔧 Development

### Running Tests

```bash
flutter test
```

### Building for Release

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

## �� Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/yourusername/p014/issues).

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 👤 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Material Design for the design system
- Color theory principles for palette generation algorithms

---

⭐ If you found this project helpful, please give it a star!
