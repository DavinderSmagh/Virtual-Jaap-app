# Virtual Jaap Implementation Plan

We will build a responsive Flutter Web application that simulates a real-life Jaap Mala (108 beads).

## User Review Required
No breaking changes. This is a brand new project. Please review the UI concept and let me know if any specific colors or images are preferred. By default, I will use a saffron/orange astrology-themed color palette.

## Proposed Changes

### Core Logic
#### [NEW] `lib/main.dart`
- Set up a clean Material App with an astrology theme.
- The main screen will center a large circular "Tap to Chant" button.
- Surrounding this button, 108 small circles (beads) will be drawn using `CustomPaint` or a `Stack`.
- As the user taps, the current bead will light up or change color.
- A central counter will show the current count (0-108).
- A secondary counter will show the total number of Malas completed.
- A Reset button to clear counts.

### Setup
- We will run `flutter create --platforms web .` in the current directory `c:\Users\LENOVO\Desktop\website` to initialize the project.

## Verification Plan
### Automated Tests
- N/A for this simple UI project, but we will ensure the app compiles without errors (`flutter analyze`).
### Manual Verification
- We will run the app using Google Chrome (`flutter run -d chrome`) and manually verify the bead increment logic and the circular mala layout.
