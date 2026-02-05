import 'package:flutter/material.dart';
import 'route_names.dart';
import '../../features/community/presentation/home screen_selection_screen.dart';
import '../../features/community/presentation/main_navigation_screen.dart';
import '../../features/chat/presentation/widgets/chat_screen1/chat_list_screen.dart';
import '../../features/announcements/presentation/announcements_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/community/domain/community_type.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.home:
        return MaterialPageRoute(
          builder: (_) => const CommunitySelectionScreen(),
          settings: settings,
        );
      case RouteNames.community:
        final args = settings.arguments as CommunityType?;
        return MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            communityType: args ?? CommunityType.society,
          ),
          settings: settings,
        );
      case RouteNames.chat:
        final args = settings.arguments as CommunityType?;
        return MaterialPageRoute(
          builder: (_) => ChatListScreen(
            communityType: args ?? CommunityType.society,
          ),
          settings: settings,
        );
      case RouteNames.announcements:
        final args = settings.arguments as CommunityType?;
        return MaterialPageRoute(
          builder: (_) => AnnouncementsScreen(
            communityType: args ?? CommunityType.society,
          ),
          settings: settings,
        );
      case RouteNames.profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const CommunitySelectionScreen(),
          settings: settings,
        );
    }
  }
}