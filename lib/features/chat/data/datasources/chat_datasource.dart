import '../../../chat/provider/chat_provider.dart';

class ChatDataSource {
  static List<ChatItem> getMockChats() {
    return [
      ChatItem(
        id: '1',
        name: 'Society Management',
        lastMessage: 'Monthly maintenance due tomorrow',
        time: '10:30 AM',
        unreadCount: 3,
        isGroup: true,
        lastMessageSender: 'Admin',
      ),
      ChatItem(
        id: '2',
        name: 'John Doe',
        lastMessage: 'Thanks for the help!',
        time: '9:45 AM',
        unreadCount: 1,
        isOnline: true,
      ),
      ChatItem(
        id: '3',
        name: 'Security Team',
        lastMessage: 'All clear for today',
        time: '8:20 AM',
        isGroup: true,
        lastMessageSender: 'Guard',
      ),
    ];
  }

  static List<Message> getMockMessages(String chatId) {
    return [
      Message(
        id: '1',
        text: 'Hello everyone! 👋',
        isMe: false,
        time: '10:30 AM',
        sender: 'John',
      ),
      Message(
        id: '2',
        text: 'Hi John! How are you doing?',
        isMe: true,
        time: '10:32 AM',
      ),
      Message(
        id: '3',
        text: 'I\'m doing great, thanks for asking!',
        isMe: false,
        time: '10:33 AM',
        sender: 'John',
      ),
    ];
  }

  static Future<List<ChatItem>> fetchChats() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return getMockChats();
  }

  static Future<List<Message>> fetchMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return getMockMessages(chatId);
  }
}