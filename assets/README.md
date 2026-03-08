# Assets Setup

## App Icon
Place your app icon image at: `assets/icon/app_icon.png`
- Recommended size: 1024x1024 px
- Format: PNG with transparency
- Should be a simple, recognizable icon for contacts app (e.g., phone book, contact card)

## Splash Screen
Place your splash screen image at: `assets/splash/splash_icon.png`
- Recommended size: 1024x1024 px
- Format: PNG with transparency
- Should be centered icon/logo

## Generate Icons & Splash

After adding your images, run:

```bash
# Install dependencies
flutter pub get

# Generate app icons
flutter pub run flutter_launcher_icons

# Generate splash screens
flutter pub run flutter_native_splash:create
```

## Icon Design Suggestions
For a contacts app, consider:
- Phone book icon
- Contact card icon
- Person with phone icon
- Address book icon

Use tools like:
- Canva (free templates)
- Figma (design from scratch)
- Icon generators online
