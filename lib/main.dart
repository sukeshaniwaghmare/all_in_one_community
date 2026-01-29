import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'features/community/provider/community_provider.dart';
import 'features/chat/provider/chat_provider.dart';
import 'features/announcements/provider/announcements_provider.dart';
import 'features/profile/provider/profile_provider.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/cart/provider/cart_provider.dart';
import 'features/calls/provider/call_provider.dart';
import 'features/contacts/provider/contact_provider.dart';
import 'core/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const CommunityApp());
}

class CommunityApp extends StatelessWidget {
  const CommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CommunityProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => CallProvider()),
        ChangeNotifierProvider(create: (context) => AnnouncementsProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ContactProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'All-in-One Community',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}