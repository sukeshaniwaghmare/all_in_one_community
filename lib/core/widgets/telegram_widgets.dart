import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Telegram-style list tile for chats, contacts, and communities
class TelegramListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? time;
  final int? unreadCount;
  final bool isOnline;
  final bool isGroup;
  final VoidCallback onTap;
  final String? avatarText;

  const TelegramListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.time,
    this.unreadCount,
    this.isOnline = false,
    this.isGroup = false,
    required this.onTap,
    this.avatarText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            TelegramAvatar(
              name: avatarText ?? title,
              radius: 28,
              showOnline: isOnline && !isGroup,
            ),
            const SizedBox(width: 12),
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
                            fontWeight: (unreadCount ?? 0) > 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          time!,
                          style: TextStyle(
                            fontSize: 13,
                            color: (unreadCount ?? 0) > 0
                                ? AppTheme.primaryColor
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: (unreadCount ?? 0) > 0
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                            fontWeight: (unreadCount ?? 0) > 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                      ),
                      if (unreadCount != null && unreadCount! > 0) ...[
                        const SizedBox(width: 8),
                        TelegramBadge(count: unreadCount!),
                      ],
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

/// Telegram-style circular avatar with optional online indicator
class TelegramAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final bool showOnline;
  final Color? backgroundColor;

  const TelegramAvatar({
    super.key,
    required this.name,
    this.radius = 28,
    this.showOnline = false,
    this.backgroundColor,
  });

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

/// Telegram-style unread count badge
class TelegramBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;

  const TelegramBadge({
    super.key,
    required this.count,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Telegram-style AppBar
class TelegramAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? leading;

  const TelegramAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.5,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: false,
      automaticallyImplyLeading: showBackButton,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Telegram-style FAB
class TelegramFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? heroTag;

  const TelegramFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.edit,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryColor,
      elevation: 4,
      child: Icon(icon, color: Colors.white),
    );
  }
}

/// Telegram-style section header
class TelegramSectionHeader extends StatelessWidget {
  final String title;

  const TelegramSectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Telegram-style settings item
class TelegramSettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? iconColor;

  const TelegramSettingsItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: iconColor ?? AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textSecondary,
                ),
          ],
        ),
      ),
    );
  }
}

/// Telegram-style divider with indent
class TelegramDivider extends StatelessWidget {
  final double indent;

  const TelegramDivider({
    super.key,
    this.indent = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: indent,
      color: AppTheme.dividerColor,
      thickness: 0.5,
    );
  }
}
