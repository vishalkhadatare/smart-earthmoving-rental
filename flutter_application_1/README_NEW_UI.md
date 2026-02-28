# HeavyEquip Pro - Modern Authentication UI

A modern, clean Flutter authentication UI for an earthmoving equipment management app.

## Features

### 🎨 Design
- Clean, minimal, professional UI
- Light grey background (#F5F5F5)
- Primary color: dark green (#3E6B3F)
- Rounded input fields (radius 16)
- Soft shadow cards
- Mobile responsive layout
- Material 3 design

### 📱 Login Screen
- Construction equipment themed icon
- "Welcome Back" title with subtitle
- Firebase status banner
- Email/Phone toggle switch
- Email and password fields with icons
- Remember me checkbox
- Forgot password link
- Full-width sign-in button
- Social login (Google & Apple)
- Sign up navigation

### 📱 Signup Screen
- Back navigation
- Construction equipment icon
- "Create Account" title with subtitle
- Full name field
- Email field
- Phone number field
- Password field with visibility toggle
- Confirm password field with validation
- Full-width sign-up button
- Sign in navigation link
- Terms & privacy text

### ⚙️ Technical Features
- Reusable CustomTextField widget
- Proper padding (16-24)
- Column + SingleChildScrollView for keyboard overflow
- Separate LoginScreen and SignupScreen classes
- Flutter icons (no external assets needed)
- Form validation placeholders
- Navigation between screens

## File Structure

```
lib/
├── main_new.dart                 # App entry point
├── widgets/
│   └── custom_text_field.dart   # Reusable text field component
└── screens/
    ├── login_screen.dart         # Login screen implementation
    └── signup_screen.dart        # Signup screen implementation
```

## Usage

1. Run the app using the new main file:
   ```bash
   flutter run --target lib/main_new.dart
   ```

2. Or replace your existing main.dart with main_new.dart

3. Navigate between login and signup screens using the provided buttons

## Customization

- **Primary Color**: Change `Color(0xFF3E6B3F)` throughout the code
- **Background Color**: Change `Color(0xFFF5F5F5)` in scaffold backgrounds
- **Border Radius**: Adjust `BorderRadius.circular(16)` in CustomTextField
- **Validation**: Replace placeholder validation with your business logic

## Dependencies

- Flutter SDK (latest)
- No external packages required - uses only Flutter's built-in widgets

## Notes

- Firebase integration placeholders are included
- Social login buttons are ready for implementation
- Form validation is functional but uses placeholder logic
- Responsive design works on all screen sizes
- Follows Material 3 design guidelines
