import 'package:flutter/material.dart';
import 'role_selection_dialog.dart';

class MemberOptionsBottomSheet extends StatelessWidget {
  final String memberName;
  final String? phoneNumber;
  final String? avatarUrl;
  final bool isAdmin;
  final bool isCurrentUser;
  final String? groupId;
  final String? memberId;
  final VoidCallback? onMessage;
  final VoidCallback? onAudioCall;
  final VoidCallback? onVideoCall;
  final VoidCallback? onPay;
  final VoidCallback? onInfo;
  final VoidCallback? onVerifySecurityCode;
  final VoidCallback? onMakeAdmin;
  final VoidCallback? onDismissAdmin;
  final VoidCallback? onAddOtherRole;
  final VoidCallback? onRemoveMember;
  final Function(String role)? onRoleUpdate;

  const MemberOptionsBottomSheet({
    super.key,
    required this.memberName,
    this.phoneNumber,
    this.avatarUrl,
    this.isAdmin = false,
    this.isCurrentUser = false,
    this.groupId,
    this.memberId,
    this.onMessage,
    this.onAudioCall,
    this.onVideoCall,
    this.onPay,
    this.onInfo,
    this.onVerifySecurityCode,
    this.onMakeAdmin,
    this.onDismissAdmin,
    this.onAddOtherRole,
    this.onRemoveMember,
    this.onRoleUpdate,
  });

  static void show(
    BuildContext context, {
    required String memberName,
    String? phoneNumber,
    String? avatarUrl,
    bool isAdmin = false,
    bool isCurrentUser = false,
    String? groupId,
    String? memberId,
    VoidCallback? onMessage,
    VoidCallback? onAudioCall,
    VoidCallback? onVideoCall,
    VoidCallback? onPay,
    VoidCallback? onInfo,
    VoidCallback? onVerifySecurityCode,
    VoidCallback? onMakeAdmin,
    VoidCallback? onDismissAdmin,
    VoidCallback? onAddOtherRole,
    VoidCallback? onRemoveMember,
    Function(String role)? onRoleUpdate,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => MemberOptionsBottomSheet(
        memberName: memberName,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
        isAdmin: isAdmin,
        isCurrentUser: isCurrentUser,
        groupId: groupId,
        memberId: memberId,
        onMessage: onMessage,
        onAudioCall: onAudioCall,
        onVideoCall: onVideoCall,
        onPay: onPay,
        onInfo: onInfo,
        onVerifySecurityCode: onVerifySecurityCode,
        onMakeAdmin: onMakeAdmin,
        onDismissAdmin: onDismissAdmin,
        onAddOtherRole: onAddOtherRole,
        onRemoveMember: onRemoveMember,
        onRoleUpdate: onRoleUpdate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFDADADA),
            backgroundImage: (avatarUrl != null && avatarUrl!.startsWith('http'))
                ? NetworkImage(avatarUrl!)
                : null,
            child: (avatarUrl == null || !avatarUrl!.startsWith('http'))
                ? Text(
                    memberName.isNotEmpty ? memberName[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            memberName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (phoneNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              phoneNumber!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.message,
                  label: 'Message',
                  color: const Color(0xFF128C7E),
                  onTap: () {
                    Navigator.pop(context);
                    onMessage?.call();
                  },
                ),
                _ActionButton(
                  icon: Icons.call,
                  label: 'Audio',
                  color: const Color(0xFF128C7E),
                  onTap: () {
                    Navigator.pop(context);
                    onAudioCall?.call();
                  },
                ),
                _ActionButton(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: const Color(0xFF128C7E),
                  onTap: () {
                    Navigator.pop(context);
                    onVideoCall?.call();
                  },
                ),
                _ActionButton(
                  icon: Icons.currency_rupee,
                  label: 'Pay',
                  color: const Color(0xFF128C7E),
                  onTap: () {
                    Navigator.pop(context);
                    onPay?.call();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          if (onInfo != null)
            _OptionTile(
              icon: Icons.info_outline,
              title: 'Info',
              onTap: () {
                Navigator.pop(context);
                onInfo?.call();
              },
            ),
          if (onVerifySecurityCode != null)
            _OptionTile(
              icon: Icons.lock_outline,
              title: 'Verify security code',
              onTap: () {
                Navigator.pop(context);
                onVerifySecurityCode?.call();
              },
            ),
          if (!isCurrentUser && !isAdmin && onMakeAdmin != null)
            _OptionTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Make group admin',
              onTap: () async {
                Navigator.pop(context);
                if (groupId != null && memberId != null && onRoleUpdate != null) {
                  onRoleUpdate!('admin');
                } else {
                  onMakeAdmin?.call();
                }
              },
            ),
          if (!isCurrentUser && isAdmin && onDismissAdmin != null)
            _OptionTile(
              icon: Icons.remove_moderator_outlined,
              title: 'Dismiss as admin',
              onTap: () async {
                Navigator.pop(context);
                if (groupId != null && memberId != null && onRoleUpdate != null) {
                  onRoleUpdate!('member');
                } else {
                  onDismissAdmin?.call();
                }
              },
            ),
          if (!isCurrentUser && onAddOtherRole != null)
            _OptionTile(
              icon: Icons.person_add_alt_outlined,
              title: 'Assign role',
              onTap: () async {
                Navigator.pop(context);
                if (groupId != null && memberId != null && onRoleUpdate != null) {
                  final selectedRoles = await RoleSelectionDialog.show(
                    context,
                    memberName: memberName,
                    currentRoles: isAdmin ? ['Admin'] : ['Member'],
                  );
                  if (selectedRoles != null && selectedRoles.isNotEmpty) {
                    onRoleUpdate!(selectedRoles.first.toLowerCase());
                  }
                } else {
                  onAddOtherRole?.call();
                }
              },
            ),
          if (!isCurrentUser && onRemoveMember != null)
            _OptionTile(
              icon: Icons.remove_circle_outline,
              title: 'Remove from group',
              iconColor: const Color(0xFFDC3545),
              titleColor: const Color(0xFFDC3545),
              onTap: () {
                Navigator.pop(context);
                onRemoveMember?.call();
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: iconColor ?? Colors.grey[700],
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: titleColor ?? Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
