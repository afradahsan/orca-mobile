import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/notifications/domain/notification_provider.dart';
import 'package:orca/features/notifications/presentation/notification_center.dart';

class NotificationBell extends StatelessWidget {
  final Color iconColor;
  final double iconSize;
  final Function(String target)? onNotificationNavigate;

  const NotificationBell({
    super.key,
    this.iconColor = Colors.white,
    this.iconSize = 22.0,
    this.onNotificationNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notifProvider, child) {
        final count = notifProvider.unreadCount;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationCenter(
                  onNotificationNavigate: onNotificationNavigate,
                ),
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(6.sp),
            decoration: BoxDecoration(
              color: Colors.grey[900]?.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  count > 0 ? Icons.notifications_active : Icons.notifications_outlined,
                  color: count > 0 ? green : iconColor,
                  size: iconSize.sp,
                ),
                if (count > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16.sp,
                        minHeight: 16.sp,
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
