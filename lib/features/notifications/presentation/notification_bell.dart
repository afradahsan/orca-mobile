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
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  count > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  color: count > 0 ? green : Colors.white,
                  size: iconSize.sp,
                ),
                if (count > 0)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: green.withValues(alpha: 0.6),
                            blurRadius: 4,
                          )
                        ],
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14.sp,
                        minHeight: 14.sp,
                      ),
                      child: Center(
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.w900,
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
