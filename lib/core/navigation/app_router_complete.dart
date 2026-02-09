import 'package:all_in_one_community/features/community/provider/community_provider.dart' as chat_provider;
import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/community/presentation/home screen_selection_screen.dart';
import '../../features/community/presentation/main_navigation_screen.dart';
import '../../features/community/domain/community_type.dart';
import '../../features/chat/presentation/widgets/chat_screen2/chat_screen.dart';
import '../../features/chat/presentation/widgets/chats_creen3/option_screen/create_group_screen.dart';
import '../../features/status/presentation/status_screen.dart';
import '../../features/calls/presentation/calls_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/contacts/presentation/select_contacts_screen.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/broadcast/presentation/broadcast_screen.dart';
import '../../features/qr/presentation/qr_code_screen.dart';
import '../../features/privacy/presentation/privacy_screen.dart';
import '../../features/notifications/presentation/notification_screen.dart';
import '../../features/media/presentation/media_viewer_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/chat/provider/chat_provider.dart' as chat_provider;

class AppRouter {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String communitySelection = '/community-selection';
  static const String mainNavigation = '/main-navigation';
  static const String chat = '/chat';
  static const String createGroup = '/create-group';
  static const String status = '/status';
  static const String calls = '/calls';
  static const String settings = '/settings';
  static const String contacts = '/contacts';
  static const String camera = '/camera';
  static const String search = '/search';
  static const String broadcast = '/broadcast';
  static const String qrCode = '/qr-code';
  static const String privacy = '/privacy';
  static const String notifications = '/notifications';
  static const String mediaViewer = '/media-viewer';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case communitySelection:
        return MaterialPageRoute(builder: (_) => const CommunitySelectionScreen());
      
      case mainNavigation:
        final args = settings.arguments as CommunityType?;
        return MaterialPageRoute(
          builder: (_) => MainNavigationScreen(
            communityType: args ?? CommunityType.society,
          ),
        );
      
      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chat: args?['chat'],
          ),
        );
      
      case createGroup:
        return MaterialPageRoute(builder: (_) => const CreateGroupScreen());
      
      case status:
        return MaterialPageRoute(builder: (_) => const StatusScreen());
      
      case calls:
        return MaterialPageRoute(builder: (_) => const CallsScreen());
      
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case contacts:
        return MaterialPageRoute(builder: (_) => const ContactsScreen());
      
      case camera:
        return MaterialPageRoute(builder: (_) => const CameraScreen());
      
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      
      case broadcast:
        return MaterialPageRoute(builder: (_) => const BroadcastScreen());
      
      case qrCode:
        return MaterialPageRoute(builder: (_) => const QRCodeScreen());
      
      case privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyScreen());
      
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      
      case mediaViewer:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => MediaViewerScreen(
            mediaUrl: args?['mediaUrl'] ?? '',
            mediaType: args?['mediaType'] ?? 'image',
            caption: args?['caption'],
          ),
        );
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}