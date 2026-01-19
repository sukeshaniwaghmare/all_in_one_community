import 'package:flutter/material.dart';
import 'app_router_complete.dart';

class NavigationHelper {
  static void goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(context, AppRouter.login, (route) => false);
  }

  static void goToSignup(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.signup);
  }

  static void goToCommunitySelection(BuildContext context) {
    Navigator.pushReplacementNamed(context, AppRouter.communitySelection);
  }

  static void goToMainNavigation(BuildContext context, {dynamic communityType}) {
    Navigator.pushReplacementNamed(context, AppRouter.mainNavigation, arguments: communityType);
  }

  static void goToChat(BuildContext context, {required dynamic chat}) {
    Navigator.pushNamed(context, AppRouter.chat, arguments: {'chat': chat});
  }

  static void goToCreateGroup(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.createGroup);
  }

  static void goToContacts(BuildContext context, {bool isGroupCreation = false}) {
    Navigator.pushNamed(context, AppRouter.contacts, arguments: {'isGroupCreation': isGroupCreation});
  }

  static void goToCamera(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.camera);
  }

  static void goToSearch(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.search);
  }

  static void goToBroadcast(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.broadcast);
  }

  static void goToQRCode(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.qrCode);
  }

  static void goToPrivacy(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.privacy);
  }

  static void goToNotifications(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.notifications);
  }

  static void goToMediaViewer(BuildContext context, {
    required String mediaUrl,
    required String mediaType,
    String? caption,
  }) {
    Navigator.pushNamed(context, AppRouter.mediaViewer, arguments: {
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
    });
  }

  static void goToProfile(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.profile);
  }

  static void goToEditProfile(BuildContext context) {
    Navigator.pushNamed(context, AppRouter.editProfile);
  }
}