# Telegram-Style UI Design Guide
## All-in-One Community Application

---

## 🎨 Color Palette

### Primary Colors
```dart
Primary Blue:     #0088CC  // Main brand color
Primary Dark:     #006BA1  // Pressed states
Primary Light:    #40A7E3  // Hover states
```

### Background Colors
```dart
Background:       #FFFFFF  // Main background
Chat Background:  #E6EBEE  // Chat screen background
Surface:          #FFFFFF  // Cards, tiles
Divider:          #D1D1D6  // Separators
```

### Text Colors
```dart
Primary Text:     #000000  // Titles, main text
Secondary Text:   #707579  // Subtitles, descriptions
Light Text:       #999999  // Timestamps, hints
```

### Status Colors
```dart
Online:           #00C853  // Online indicator
Success:          #00C853  // Success messages
Error:            #E53935  // Error states
Warning:          #FFA726  // Warning states
```

### Message Bubbles
```dart
Outgoing:         #0088CC  // User's messages
Incoming:         #FFFFFF  // Others' messages
```

---

## 📐 Spacing & Sizing

### Standard Spacing
```dart
Extra Small:  4px
Small:        8px
Medium:       12px
Large:        16px
Extra Large:  20px
XXL:          24px
```

### Component Sizes
```dart
Avatar Small:     28px radius
Avatar Medium:    35px radius
Avatar Large:     50px radius

Icon Small:       20px
Icon Medium:      24px
Icon Large:       28px

Button Height:    50px
Input Height:     48px
List Tile:        72px min height
```

### Border Radius
```dart
Small:        8px   // Icons, badges
Medium:       10px  // Buttons, inputs
Large:        12px  // Cards, bubbles
Circle:       50%   // Avatars, FAB
```

---

## 🔤 Typography

### Font Weights
```dart
Light:        FontWeight.w300
Regular:      FontWeight.w400
Medium:       FontWeight.w500
SemiBold:     FontWeight.w600
Bold:         FontWeight.w700
```

### Text Styles
```dart
// Headers
H1: 28px, SemiBold
H2: 22px, SemiBold
H3: 18px, SemiBold

// Body
Body Large:   16px, Regular
Body:         15px, Regular
Body Small:   14px, Regular

// Captions
Caption:      13px, Regular
Caption Small: 12px, Regular
Tiny:         11px, Regular
```

---

## 🧩 Component Structure

### 1. Chat List Tile
```dart
Structure:
├─ InkWell (tap effect)
   ├─ Padding (16h, 12v)
      ├─ Row
         ├─ CircleAvatar (28 radius)
         │  └─ Online indicator (if online)
         ├─ SizedBox (12 width)
         ├─ Expanded Column
         │  ├─ Row (name + time)
         │  │  ├─ Text (name, 16px, w600 if unread)
         │  │  └─ Text (time, 13px, blue if unread)
         │  └─ Row (message + badge)
         │     ├─ Text (last message, 14px)
         │     └─ Badge (unread count)
```

### 2. Message Bubble
```dart
Structure:
├─ Padding (2v, 4h)
   └─ Row (alignment based on sender)
      ├─ Avatar (if group + incoming)
      └─ Container (bubble)
         ├─ Padding (12h, 8v)
         └─ Column
            ├─ Text (sender name if group)
            ├─ Text (message, 15px)
            └─ Row (time + read status)
```

### 3. AppBar (Telegram Style)
```dart
Structure:
├─ AppBar
   ├─ elevation: 0.5
   ├─ backgroundColor: white
   ├─ foregroundColor: black
   ├─ title: Text (20px, w500)
   └─ actions: [Search, More]
```

### 4. Floating Action Button
```dart
Style:
├─ backgroundColor: #0088CC
├─ foregroundColor: white
├─ icon: Icons.edit (compose)
└─ elevation: 4
```

---

## 📱 Screen Layouts

### Home / Chat List Screen
```
┌─────────────────────────┐
│ ☰  Chats         🔍 ⋮  │ AppBar (white, flat)
├─────────────────────────┤
│ 👤 John Doe      12:30  │ Chat tile
│    Hey, how are you?  2 │ (unread badge)
├─────────────────────────┤
│ 👥 Family Group   11:45 │
│    Mom: Dinner ready?   │
├─────────────────────────┤
│ 👤 Sarah         10:20  │
│    See you tomorrow!    │
└─────────────────────────┘
                    [✏️]    FAB (compose)
```

### Chat Screen
```
┌─────────────────────────┐
│ ← 👤 John Doe    📞 ⋮  │ AppBar
│     online              │
├─────────────────────────┤
│                         │
│  ┌──────────────┐       │ Incoming
│  │ Hello there! │       │ (white bubble)
│  │         10:30 │      │
│  └──────────────┘       │
│                         │
│       ┌──────────────┐  │ Outgoing
│       │ Hi! How are  │  │ (blue bubble)
│       │ you?         │  │
│       │    10:31 ✓✓  │  │
│       └──────────────┘  │
│                         │
├─────────────────────────┤
│ 😊 | Type message... 📎 │ Input bar
│                      🎤 │
└─────────────────────────┘
```

### Community Selection
```
┌─────────────────────────┐
│ ☰  Communities    🔍    │ AppBar
├─────────────────────────┤
│ 🏘️ Society Community    │
│    Manage your society  │ 1
├─────────────────────────┤
│ 🏫 College Community    │
│    Connect with peers   │
├─────────────────────────┤
│ 🏢 Office Community     │
│    Workplace updates    │
└─────────────────────────┘
                    [✏️]    FAB (new)
```

### Profile / Settings
```
┌─────────────────────────┐
│ ☰  Settings       🔍    │ AppBar
├─────────────────────────┤
│     👤                  │
│   John Doe              │ Profile header
│   john@email.com    QR  │
├─────────────────────────┤
│ ACCOUNT                 │ Section header
│ 👤 Personal Info    →   │
│ 🔒 Privacy          →   │
│ 🔔 Notifications    →   │
├─────────────────────────┤
│ COMMUNITY               │
│ 👥 My Communities   →   │
│ ⚙️  Admin Panel     →   │
└─────────────────────────┘
```

---

## 🎯 Key Design Principles

### 1. Flat Design
- Minimal shadows (elevation: 0-2)
- Clean, crisp edges
- No gradients on surfaces
- Flat color backgrounds

### 2. Circular Avatars
- Always use CircleAvatar
- Show initials or icons
- Consistent sizing
- Online indicator: small green circle (bottom-right)

### 3. List Items
- Left-aligned avatar (28-35px radius)
- 12px spacing between avatar and content
- Title + subtitle layout
- Right-aligned metadata (time, badge)
- Divider with 72px left indent

### 4. Badges (Unread Count)
```dart
Container(
  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  decoration: BoxDecoration(
    color: AppTheme.primaryColor,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    count.toString(),
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

### 5. Message Bubbles
- Outgoing: Blue background, white text, right-aligned
- Incoming: White background, black text, left-aligned
- Rounded corners (12px)
- Tail effect (2px radius on sender side)
- Timestamp + read status inside bubble

### 6. AppBar Style
```dart
AppBar(
  elevation: 0.5,
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  centerTitle: false,
  titleTextStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  ),
)
```

---

## 🔧 Reusable Widgets

### Telegram List Tile
```dart
class TelegramListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? time;
  final int? unreadCount;
  final bool isOnline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(title[0].toUpperCase()),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.onlineColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: unreadCount > 0 
                              ? FontWeight.w600 
                              : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (time != null)
                        Text(
                          time!,
                          style: TextStyle(
                            fontSize: 13,
                            color: unreadCount > 0 
                              ? AppTheme.primaryColor 
                              : AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: unreadCount > 0 
                              ? AppTheme.textPrimary 
                              : AppTheme.textSecondary,
                            fontWeight: unreadCount > 0 
                              ? FontWeight.w500 
                              : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (unreadCount != null && unreadCount! > 0)
                        Container(
                          margin: EdgeInsets.only(left: 8),
                          padding: EdgeInsets.symmetric(
                            horizontal: 7, 
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Telegram Avatar
```dart
class TelegramAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final bool showOnline;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor ?? AppTheme.primaryColor,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontSize: radius * 0.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (showOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.5,
              height: radius * 0.5,
              decoration: BoxDecoration(
                color: AppTheme.onlineColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

### Telegram Badge
```dart
class TelegramBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: count > 99 ? 6 : 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

---

## 📋 Implementation Checklist

### Phase 1: Theme Update ✅
- [x] Update color palette to Telegram blue
- [x] Adjust text colors
- [x] Update status colors

### Phase 2: Component Updates
- [ ] Update all AppBars (white background, black text)
- [ ] Update all avatars (circular, consistent sizing)
- [ ] Update badges (blue background, rounded)
- [ ] Update list tiles (proper spacing, dividers)
- [ ] Update FABs (blue, edit icon)

### Phase 3: Screen Updates
- [ ] Login screen (minimal, clean)
- [ ] Community selection (list style)
- [ ] Chat list (Telegram layout)
- [ ] Chat screen (bubble style)
- [ ] Profile/Settings (grouped sections)

### Phase 4: Polish
- [ ] Remove heavy shadows
- [ ] Ensure flat design
- [ ] Consistent spacing
- [ ] Smooth animations
- [ ] Professional typography

---

## 🎨 Before & After Comparison

### Color Changes
| Element | Before (Purple) | After (Blue) |
|---------|----------------|--------------|
| Primary | #6B4FBB | #0088CC |
| Accent | #8B6FDB | #40A7E3|
| Badge | Purple | Blue |
| Online | #4CD964 | #00C853 |

### Design Changes
| Element | Before | After |
|---------|--------|-------|
| Shadows | Heavy | Minimal (0.5) |
| AppBar | Colored | White/Flat |
| Bubbles | Rounded | Telegram-style |
| Avatars | Mixed | Circular only |
| Typography | Mixed weights | Consistent |

---

## 🚀 Quick Start

1. **Theme is already updated** - The color palette has been changed to Telegram blue
2. **Your existing screens** already follow Telegram-style layout
3. **Minor adjustments needed**:
   - Ensure all AppBars use white background
   - Verify badge colors are blue
   - Check avatar consistency
   - Confirm spacing matches guide

---

## 📚 Resources

### Telegram Design References
- Official Telegram app (Android/iOS)
- Telegram Web (web.telegram.org)
- Material Design 3 guidelines
- Flutter Material components

### Color Tools
- Material Color Tool: material.io/resources/color
- Coolors: coolors.co
- Adobe Color: color.adobe.com

---

## 💡 Tips

1. **Consistency is key** - Use the same spacing, colors, and typography throughout
2. **Test on real devices** - Ensure readability and touch targets
3. **Follow Material Design** - Telegram uses Material Design principles
4. **Keep it simple** - Avoid over-decoration
5. **Performance matters** - Optimize list rendering and animations

---

**Last Updated:** 2024
**Version:** 1.0
**Status:** Theme Updated ✅
