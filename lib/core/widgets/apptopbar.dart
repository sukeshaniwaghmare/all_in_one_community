import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final Widget? titleWidget;
  final bool showBackButton;
  final bool showMenuButton;
  final VoidCallback? onMenuPressed;
  final List<PopupMenuEntry<String>>? menuItems;
  final Function(String)? onMenuSelected;

  const AppTopBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.titleWidget,
    this.showBackButton = false,
    this.showMenuButton = false,
    this.onMenuPressed,
    this.menuItems,
    this.onMenuSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ?? Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: foregroundColor ?? AppTheme.primaryColor,
        ),
      ),
      leading: leading ?? _buildLeading(context),
      actions: actions ?? _buildDefaultActions(),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? AppTheme.primaryColor,
      elevation: elevation,
      titleSpacing: 0,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
        onPressed: () => Navigator.pop(context),
      );
    }
    if (showMenuButton) {
      return Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: AppTheme.primaryColor),
          onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
        ),
      );
    }
    return null;
  }

  List<Widget>? _buildDefaultActions() {
    List<Widget> defaultActions = [];
    
    if (menuItems != null && menuItems!.isNotEmpty) {
      defaultActions.add(
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
          onSelected: onMenuSelected,
          itemBuilder: (context) => menuItems!,
        ),
      );
    }
    
    return defaultActions.isEmpty ? null : defaultActions;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class SearchBar extends StatelessWidget {
  final String hintText;
  final Function(String)? onChanged;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const SearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.backgroundColor,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(color: textColor ?? Colors.black),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: backgroundColor ?? Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}