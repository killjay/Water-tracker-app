# Figma Design Guide - Water Tracker App

## 🎨 Design System Overview

### Color Palette
- **Primary Blue**: `#2962FF` (vibrant blue)
- **Deep Indigo**: `#1A237E` (replaces black for text)
- **Medium Indigo**: `#3F51B5` (secondary text)
- **Light Indigo**: `#E8EAF6` (backgrounds)
- **Border Indigo**: `#E0E7FF` (borders)
- **Bright Blue**: `#448AFF` (water accent)
- **Cyan**: `#00E5FF` (accent)
- **Success Green**: `#10B981`
- **Error Red**: `#E53935`
- **Background**: `#FFFFFF` (white) / `#EEF2FF` (very light blue tint)

### Typography
- **Headings**: Font weight 700-800, deep indigo color
- **Body**: Font weight 400-600, medium indigo color
- **Letter Spacing**: -0.02 to -0.03 for large headings

### Border Radius
- **Cards**: 24px
- **Buttons**: 999px (fully rounded)
- **Input Fields**: 12px
- **Icons/Containers**: 12-16px

---

## 📱 SCREENS TO DESIGN

### 1. **Login Screen** (`login_screen.dart`)
**Components:**
- App logo/icon (water drop icon, 80px)
- App title "Water Tracker" (32px, bold)
- Email input field with icon
- Password input field with visibility toggle
- Primary login button (gradient blue)
- Divider with "or" text
- Google Sign-In button (using asset image)
- Sign up link text button

**Layout:**
- Centered vertical layout
- 24px padding all around
- Safe area handling

---

### 2. **Sign Up Screen** (`signup_screen.dart`)
**Components:**
- App bar with back button
- Display name field (optional)
- Email input field
- Password input field with visibility toggle
- Confirm password field with visibility toggle
- Primary sign up button
- Login link text button

**Layout:**
- Similar to login screen
- Scrollable form

---

### 3. **Onboarding Flow Screen** (`onboarding_flow_screen.dart`)
**Multi-step wizard with 4 pages:**

#### Page 1: Weight Entry
- Title: "Your weight" (24px, bold)
- Subtitle text
- Weight input field with icon
- Next button

#### Page 2: Activity Level
- Title: "Activity level" (24px, bold)
- Subtitle: "On most days, how active are you?"
- Segmented button group:
  - Low (with self-improvement icon)
  - Normal (with walk icon)
  - High (with fitness center icon)

#### Page 3: Sleep Schedule
- Title: "Sleep schedule" (24px, bold)
- Subtitle text
- Wake time picker (ListTile with sun icon)
- Sleep time picker (ListTile with moon icon)

#### Page 4: Summary
- Title: "Your daily goal" (24px, bold)
- Subtitle text
- Large goal amount display (32px, bold)
- Weight and activity summary text
- Wake/sleep time summary text
- Finish button

**Common Elements:**
- Step indicator dots (4 dots, active state)
- App bar with back button (except first page)
- Bottom navigation bar with Next/Finish button

---

### 4. **Home Screen** (`home_screen.dart`)
**Main Dashboard - Most Complex Screen**

**Top Section:**
- App bar with settings icon
- Date display (uppercase, small, indigo)
- Greeting: "Hello, [Name]" (28px, bold)

**Center Section:**
- Large circular progress indicator (252x252px)
  - Outer ring with shadow
  - Animated water wave inside
  - Center text: current amount / goal amount
  - Pulse and celebration animations

**Status Card:**
- Glass-like card with border
- Icon container (56x56px, rounded, light indigo background)
- "Hydration Status" title
- Status text: "Goal reached! 🎉" / "You're behind pace" / "You're on track!"
- Divider
- Next reminder time with clock icon
- "ACTIVE" badge (gradient blue, rounded pill)

**Today's Intake Section:**
- "TODAY'S INTAKE" label (uppercase, small)
- Total amount / Goal amount display
- Progress bar (12px height, gradient blue/cyan)
  - Background: light blue
  - Fill: gradient from bright blue to cyan
  - Glow effect

**Bottom Navigation:**
- 3 tabs: Home, Logs, Stats
- Custom styling with indigo colors

**Floating Action Button:**
- Gradient blue button
- "Add Water" text with plus icon
- Shadow effect
- Opens quick add bottom sheet

---

### 5. **History/Logs Screen** (`history_screen.dart`)
**Components:**
- App bar with "History" title
- Date selector card
  - Calendar icon
  - Selected date display
  - Chevron icon
- Summary card
  - Total amount (large number)
  - Total entries count (large number)
- Entries list
  - Empty state: water drop icon, "No entries for this day"
  - Entry cards (swipeable to delete):
    - Water drop icon
    - Amount and unit
    - Cup size label
    - Timestamp
    - Swipe left to reveal delete action

**Interactions:**
- Date picker dialog
- Swipe to delete with confirmation dialog

---

### 6. **Stats Screen** (`stats_screen.dart`)
**Components:**
- App bar with "Stats" title
- Metrics grid (2 columns):
  - Current Streak card
    - Fire icon
    - Streak count (large number)
    - "Current Streak" label
  - Completion Rate card
    - Check circle icon
    - Percentage (large number)
    - "Completion Rate" label
- "Last 7 days" section title
- Weekly bar chart
  - 7 bars (one per day)
  - Day labels (Mon, Tue, etc.)
  - Amount labels above bars
  - Gradient blue for goal achieved
  - Light indigo for not achieved
  - Height proportional to amount

---

### 7. **Settings Screen** (`settings_screen.dart`)
**Sections:**

#### User Profile Card
- Gradient background (light indigo)
- Avatar circle with initials (64x64px, gradient blue)
- Display name (20px, bold)
- Email address (14px, medium indigo)

#### Profile Section
- "PROFILE" section header (uppercase, small)
- Daily Goal tile
  - Flag icon
  - Title and current goal value
  - Chevron icon
- Hydration Profile tile
  - Tune icon
  - Title and subtitle
  - Chevron icon

#### Reminders Section
- "REMINDERS" section header
- Enable Reminders switch tile
  - Notification icon
  - Title and subtitle
  - Toggle switch
- Smart Tuning switch tile
  - Auto awesome icon
  - Title and subtitle
  - Toggle switch
- Reminder Interval tile (shown when smart tuning off)
  - Timer icon
  - Title and interval value
  - Chevron icon

#### Data & Privacy Section
- "DATA & PRIVACY" section header
- Send Feedback tile
  - Feedback icon
  - Title and subtitle
- Clear History tile (red)
  - Delete icon
  - Red text color
  - Title and subtitle

#### Account Section
- "ACCOUNT" section header
- Sign Out tile (red)
  - Logout icon
  - Red text color
  - Title and subtitle

**All tiles:**
- Icon container (40x40px, rounded, colored background)
- Title and subtitle text
- Chevron icon or switch
- Ripple effect on tap

---

### 8. **Goal Setup Screen** (`goal_setup_screen.dart`)
**Components:**
- App bar with "Set Daily Goal" title
- "Daily Water Goal" heading (24px, bold)
- Subtitle text
- Goal amount input field
  - Flag icon
  - Number keyboard
- "Unit" label
- Segmented button group:
  - ml
  - oz
  - cups
- Save Goal button (primary style)

---

## 🧩 REUSABLE COMPONENTS TO DESIGN

### 1. **Primary Button** (`primary_button.dart`)
- Gradient background (blue to indigo)
- Rounded pill shape (999px border radius)
- White text, bold, 16px
- Shadow effect
- Loading state (circular progress indicator)
- Disabled state (lighter colors, reduced opacity)

**States:**
- Default
- Hover/Pressed
- Loading
- Disabled

---

### 2. **Water Progress Indicator** (`progress_indicator.dart`)
**Complex animated component:**
- Circular ring (12px stroke width)
- Outer shadow container
- Animated water wave inside circle
- Center text display:
  - Current amount (large, bold)
  - "of [goal] [unit]" (smaller)
- Progress ring (gradient blue/cyan)
- Celebration animation (glow effect)
- Pulse animation

**Sizes:**
- Default: 200px
- Home screen: 238px (inside 252px container)

---

### 3. **Water Cup Widget** (`water_cup_widget.dart`)
- Card container with border
- Water drop icon (40px)
- Cup label text (bold)
- Amount and unit text
- Selected state:
  - Light indigo background
  - Blue border (2px)
  - Blue icon color
- Unselected state:
  - White background
  - Light border (1px)
  - Bright blue icon

---

### 4. **Input Field Component**
**Used in:**
- Login/Signup screens
- Onboarding screens
- Settings dialogs

**Elements:**
- Label text
- Prefix icon
- Text input
- Border (12px radius)
- Focus state (blue border, 2px)
- Error state (red border)
- Helper/error text

**Variants:**
- Standard text input
- Password input (with visibility toggle)
- Number input
- Email input

---

### 5. **Card Component**
**Used throughout app:**
- White background
- 24px border radius
- Light indigo border (1px)
- Subtle shadow
- Padding: 16-20px

**Variants:**
- Standard card
- Section card (with header)
- Metric card (stats)
- Entry card (history)

---

### 6. **List Tile Component**
**Used in:**
- Settings screen
- History screen
- Onboarding screens

**Elements:**
- Icon container (40x40px, rounded)
- Title text (16px, bold)
- Subtitle text (13px, medium indigo)
- Trailing icon/switch
- Ripple effect

---

### 7. **Switch Component**
**Used in:**
- Settings screen

**Style:**
- Active color: vibrant blue
- Track and thumb styling
- Smooth animation

---

### 8. **Segmented Button Group**
**Used in:**
- Onboarding (activity level)
- Goal setup (unit selection)

**Style:**
- Rounded buttons
- Selected: blue background, white text
- Unselected: light background, indigo text
- Icons in buttons (where applicable)

---

### 9. **Bottom Navigation Bar**
**Used in:**
- Home screen

**Elements:**
- White background
- Top border (light indigo)
- Shadow effect
- 3 items: Home, Logs, Stats
- Selected: vibrant blue
- Unselected: light indigo
- Icons and labels

---

### 10. **Floating Action Button**
**Used in:**
- Home screen

**Style:**
- Gradient blue background
- Rounded pill shape
- Plus icon in white circle
- "Add Water" text
- Shadow effect
- Positioned bottom-right

---

## 🗨️ DIALOGS & MODALS TO DESIGN

### 1. **Quick Add Bottom Sheet**
**Components:**
- Rounded top corners (16px)
- "Quick add water" title
- Cup size chips (ActionChip style)
  - Label: "[Cup Name] · [Amount] [Unit]"
- "Custom amount" outlined button with edit icon

**Cup Sizes:**
- Small: 250ml
- Medium: 350ml
- Large: 500ml
- Bottle: 750ml
- Custom cup sizes (user-defined)

---

### 2. **Custom Amount Dialog**
**Components:**
- Dialog container (rounded, 24px)
- "Add Custom Amount" title
- Number input field
  - Water drop icon
  - "Amount (ml)" label
- Cancel button (text)
- Add button (primary)

---

### 3. **Delete Entry Dialog**
**Components:**
- Dialog container
- "Delete Entry" title
- Confirmation message
- Cancel button (text)
- Delete button (red, elevated)

---

### 4. **Reminder Interval Dialog**
**Components:**
- Dialog container (rounded, 24px)
- "Reminder Interval" title
- Number input field
  - "Interval (minutes)" label
- Cancel button (text)
- Save button (primary)

---

### 5. **Clear History Dialog**
**Components:**
- Dialog container (rounded, 24px)
- "Clear History" title
- Warning message text
- Cancel button (text)
- Clear History button (red)

---

### 6. **Sign Out Dialog**
**Components:**
- Dialog container (rounded, 24px)
- "Sign Out" title
- Confirmation message
- Cancel button (text)
- Sign Out button (red)

---

### 7. **Date Picker**
- Standard Material date picker
- Styled to match app theme

---

### 8. **Time Picker**
- Standard Material time picker
- Used for wake/sleep time selection

---

## 🎯 SPECIAL UI ELEMENTS

### 1. **Step Indicator**
**Used in:**
- Onboarding flow

**Style:**
- 4 dots in a row
- Active: vibrant blue (10px circle)
- Inactive: light indigo (10px circle)
- Spacing: 4px horizontal margin

---

### 2. **Progress Bar**
**Used in:**
- Home screen (Today's Intake)

**Style:**
- 12px height
- Rounded ends (999px)
- Background: light blue
- Fill: gradient (bright blue to cyan)
- Glow effect on fill
- Smooth animation

---

### 3. **Metric Card**
**Used in:**
- Stats screen

**Style:**
- Card container
- Icon (colored, primary theme)
- Large number (18px, bold, deep indigo)
- Label text (12px, medium indigo)
- Padding: 16px

---

### 4. **Weekly Bar Chart**
**Used in:**
- Stats screen

**Style:**
- 7 bars (one per day)
- Day labels below (Mon, Tue, etc.)
- Amount labels above bars
- Gradient blue for goal achieved
- Light indigo for not achieved
- 6px border radius on bars
- Height proportional to amount

---

### 5. **Empty State**
**Used in:**
- History screen (no entries)

**Style:**
- Large icon (64px, light opacity)
- Message text (16px, medium indigo)
- Centered vertically

---

### 6. **Loading State**
**Used throughout:**
- Circular progress indicator
- White spinner on colored backgrounds
- Colored spinner on white backgrounds

---

### 7. **Snackbar/Toast**
**Used for:**
- Success messages (green)
- Error messages (red)
- Info messages (blue)

**Style:**
- Rounded corners
- Colored background
- White text
- Optional action button

---

## 📐 LAYOUT SPECIFICATIONS

### Spacing System
- **Extra Small**: 4px
- **Small**: 8px
- **Medium**: 16px
- **Large**: 24px
- **Extra Large**: 32px, 48px

### Screen Padding
- **Standard**: 16-24px
- **Cards**: 16-20px internal padding
- **Sections**: 24px vertical spacing

### Icon Sizes
- **Small**: 18-20px
- **Medium**: 24-28px
- **Large**: 40px
- **Extra Large**: 64-80px

---

## 🎨 DESIGN NOTES

1. **Glass-like Effects**: Cards use subtle shadows and borders for depth
2. **Gradients**: Used for buttons, progress indicators, and status badges
3. **Animations**: Progress indicator has wave animation, pulse, and celebration effects
4. **Indigo Theme**: Deep indigo replaces black for softer, more modern look
5. **Rounded Corners**: Consistent use of 12px, 16px, 24px, and 999px (pill)
6. **Typography Hierarchy**: Clear distinction between headings, body, and labels
7. **Color Coding**: Blue for primary actions, red for destructive actions, green for success

---

## ✅ CHECKLIST FOR FIGMA DESIGN

### Screens (8 total)
- [ ] Login Screen
- [ ] Sign Up Screen
- [ ] Onboarding Flow (4 pages)
- [ ] Home Screen
- [ ] History/Logs Screen
- [ ] Stats Screen
- [ ] Settings Screen
- [ ] Goal Setup Screen

### Components (10 total)
- [ ] Primary Button (all states)
- [ ] Water Progress Indicator
- [ ] Water Cup Widget
- [ ] Input Field (all variants)
- [ ] Card Component
- [ ] List Tile
- [ ] Switch
- [ ] Segmented Button Group
- [ ] Bottom Navigation Bar
- [ ] Floating Action Button

### Dialogs (8 total)
- [ ] Quick Add Bottom Sheet
- [ ] Custom Amount Dialog
- [ ] Delete Entry Dialog
- [ ] Reminder Interval Dialog
- [ ] Clear History Dialog
- [ ] Sign Out Dialog
- [ ] Date Picker
- [ ] Time Picker

### Special Elements (7 total)
- [ ] Step Indicator
- [ ] Progress Bar
- [ ] Metric Card
- [ ] Weekly Bar Chart
- [ ] Empty State
- [ ] Loading State
- [ ] Snackbar/Toast

### Design System
- [ ] Color Palette
- [ ] Typography Scale
- [ ] Spacing System
- [ ] Icon Library
- [ ] Shadow Styles
- [ ] Border Radius Values

---

## 📱 RESPONSIVE CONSIDERATIONS

- Design for mobile-first (iOS/Android)
- Consider tablet layouts if needed
- Ensure touch targets are at least 44x44px
- Test with different screen sizes (small to large phones)

---

**Total Design Assets: 33+ screens, components, and dialogs**
