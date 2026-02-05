import 'package:flutter/material.dart';
import 'features/auth/presentation/login_screen.dart';
import 'services/fcm_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/notifications/services/notification_service.dart' as local_notifications;
import 'package:provider/provider.dart';
import 'features/community/provider/community_provider.dart';
import 'features/chat/provider/chat_provider.dart';
import 'features/chat/data/datasources/chat_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/usecases/get_chats_usecase.dart';
import 'features/chat/domain/usecases/get_messages_usecase.dart';
import 'features/chat/domain/usecases/send_message_usecase.dart';
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
  await local_notifications.NotificationService.initialize();
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
        ChangeNotifierProvider(create: (context) {
          final dataSource = ChatDataSource();
          final repository = ChatRepositoryImpl(dataSource);
          return ChatProvider(
            getChatsUseCase: GetChatsUseCase(repository),
            getMessagesUseCase: GetMessagesUseCase(repository),
            sendMessageUseCase: SendMessageUseCase(repository),
          );
        }),
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