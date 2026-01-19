# 🎨 Telegram Design - Quick Visual Reference

## Color Palette (Copy-Paste Ready)

```dart
// Telegram Blue Theme
Primary:        #0088CC
Primary Dark:   #006BA1
Primary Light:  #40A7E3

// Backgrounds
White:          #FFFFFF
Chat BG:        #E6EBEE
Divider:        #D1D1D6

// Text
Black:          #000000
Gray:           #707579
Light Gray:     #999999

// Status
Online Green:   #00C853
Error Red:      #E53935
Warning Orange: #FFA726
```

---

## Component Sizes

```dart
// Avatars
Small:    28px radius
Medium:   35px radius
Large:    50px radius

// Icons
Small:    20px
Medium:   24px
Large:    28px

// Spacing
XS:  4px
S:   8px
M:   12px
L:   16px
XL:  20px
XXL: 24px

// Borders
Small:  8px
Medium: 10px
Large:  12px
Circle: 50%
```

---

## Typography Scale

```dart
// Headers
H1: 28px, w600
H2: 22px, w600
H3: 18px, w600

// Body
Large:  16px, w400
Normal: 15px, w400
Small:  14px, w400

// Captions
Normal: 13px, w400
Small:  12px, w400
Tiny:   11px, w400
```

---

## Common Patterns

### List Item
```
┌─────────────────────────────┐
│ 👤  John Doe        12:30   │
│     Hey there!            2 │
└─────────────────────────────┘
│ 28px │ 12px │ flex │ badge │
```

### Message Bubble (Outgoing)
```
                  ┌──────────────┐
                  │ Hello!       │ ← Blue #0088CC
                  │    10:30 ✓✓  │
                  └──────────────┘
```

### Message Bubble (Incoming)
```
┌──────────────┐
│ Hi there!    │ ← White #FFFFFF
│       10:31  │
└──────────────┘
```

### Badge
```
┌───┐
│ 2 │ ← Blue #0088CC, 12px radius
└───┘
```

### AppBar
```
┌─────────────────────────────┐
│ Chats              🔍  ⋮   │ ← White BG, Black text
└─────────────────────────────┘
```

---

## Widget Usage Examples

### Avatar with Online Indicator
```dart
TelegramAvatar(
  name: 'John Doe',
  radius: 28,
  showOnline: true,
)
```

### Unread Badge
```dart
TelegramBadge(count: 5)
```

### List Tile
```dart
TelegramListTile(
  title: 'John Doe',
  subtitle: 'Last message',
  time: '12:30',
  unreadCount: 2,
  isOnline: true,
  onTap: () {},
)
```

### AppBar
```dart
TelegramAppBar(
  title: 'Chats',
  actions: [
    IconButton(
      icon: Icon(Icons.search),
      onPressed: () {},
    ),
  ],
)
```

### FAB
```dart
TelegramFAB(
  icon: Icons.edit,
  onPressed: () {},
)
```

---

## Screen Templates

### Chat List Screen
```dart
Scaffold(
  appBar: TelegramAppBar(title: 'Chats'),
  body: ListView.separated(
    separatorBuilder: (_, __) => TelegramDivider(),
    itemBuilder: (_, i) => TelegramListTile(...),
  ),
  floatingActionButton: TelegramFAB(...),
)
```

### Settings Screen
```dart
Scaffold(
  appBar: TelegramAppBar(title: 'Settings'),
  body: ListView(
    children: [
      // Profile Header
      Container(
        color: Colors.white,
        child: Row(
          children: [
            TelegramAvatar(...),
            // Name & Email
          ],
        ),
      ),
      
      // Section
      TelegramSectionHeader(title: 'Account'),
      Container(
        color: Colors.white,
        child: Column(
          children: [
            TelegramSettingsItem(...),
            TelegramDivider(),
            TelegramSettingsItem(...),
          ],
        ),
      ),
    ],
  ),
)
```

---

## Color Usage Guide

| Element | Color | Code |
|---------|-------|------|
| Primary Button | Blue | `AppTheme.primaryColor` |
| AppBar Background | White | `Colors.white` |
| AppBar Text | Black | `Colors.black` |
| Badge | Blue | `AppTheme.primaryColor` |
| FAB | Blue | `AppTheme.primaryColor` |
| Online Dot | Green | `AppTheme.onlineColor` |
| Outgoing Bubble | Blue | `AppTheme.outgoingBubble` |
| Incoming Bubble | White | `AppTheme.incomingBubble` |
| Title Text | Black | `AppTheme.textPrimary` |
| Subtitle Text | Gray | `AppTheme.textSecondary` |
| Divider | Light Gray | `AppTheme.dividerColor` |

---

## Spacing Guide

```dart
// Horizontal Padding
List Items:     16px
Cards:          20px
Buttons:        24px

// Vertical Padding
List Items:     12px
Cards:          16px
Sections:       20px

// Between Elements
Avatar → Text:  12px
Text → Badge:   8px
Title → Sub:    4px
Sections:       20px
```

---

## Elevation Guide

```dart
AppBar:         0.5
Cards:          0
FAB:            4
Dialogs:        8
Bubbles:        0 (shadow only)
```

---

## Border Radius Guide

```dart
Badges:         12px
Buttons:        10px
Cards:          12px
Inputs:         10px
Bubbles:        12px (with 2px tail)
Icons:          8px
Avatars:        Circle (50%)
```

---

## Animation Durations

```dart
Quick:          150ms
Normal:         250ms
Slow:           350ms
Page:           300ms
```

---

## Touch Targets

```dart
Minimum:        48px × 48px
Icon Button:    48px × 48px
List Item:      72px min height
FAB:            56px × 56px
```

---

## Common Mistakes to Avoid

❌ **Don't:**
- Use heavy shadows
- Use gradients on AppBars
- Mix different shades of blue
- Use inconsistent spacing
- Make avatars square
- Use green for badges

✅ **Do:**
- Keep it flat and minimal
- Use white AppBars
- Stick to #0088CC blue
- Use consistent 12px spacing
- Always use circular avatars
- Use blue for badges

---

## Quick Copy-Paste Snippets

### Telegram AppBar
```dart
AppBar(
  elevation: 0.5,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  title: Text(
    'Title',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: Colors.black,
    ),
  ),
)
```

### Telegram Badge
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    '5',
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### Telegram Avatar
```dart
CircleAvatar(
  radius: 28,
  backgroundColor: AppTheme.primaryColor,
  child: Text(
    name[0].toUpperCase(),
    style: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  ),
)
```

### Telegram Divider
```dart
Divider(
  height: 1,
  indent: 72,
  color: AppTheme.dividerColor,
  thickness: 0.5,
)
```

---

## File Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart          ← Theme colors
│   └── widgets/
│       └── telegram_widgets.dart   ← Reusable widgets
├── features/
│   ├── auth/
│   ├── chat/
│   ├── community/
│   ├── profile/
│   └── announcements/
└── main.dart
```

---

## Import Statement

```dart
// Always import these for Telegram styling
import 'package:all_in_one_community/core/theme/app_theme.dart';
import 'package:all_in_one_community/core/widgets/telegram_widgets.dart';
```

---

## Testing Checklist

- [ ] All AppBars are white
- [ ] All badges are blue
- [ ] All FABs are blue
- [ ] Avatars are circular
- [ ] Online dots are green
- [ ] Dividers have 72px indent
- [ ] Spacing is consistent (12px)
- [ ] Typography follows scale
- [ ] No heavy shadows
- [ ] Flat design throughout

---

**Quick Reference Version 1.0**
**Last Updated: 2024**
