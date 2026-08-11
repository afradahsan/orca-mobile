import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/notifications/domain/notification_model.dart';
import 'package:orca/features/notifications/domain/notification_provider.dart';

class NotificationCenter extends StatefulWidget {
  final Function(String target)? onNotificationNavigate;

  const NotificationCenter({super.key, this.onNotificationNavigate});

  @override
  State<NotificationCenter> createState() => _NotificationCenterState();
}

class _NotificationCenterState extends State<NotificationCenter> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Competition',
    'Fitness',
    'General',
    'Merch',
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Competition':
        return Icons.emoji_events;
      case 'Fitness':
        return Icons.fitness_center;
      case 'Merch':
        return Icons.shopping_bag;
      default:
        return Icons.notifications;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Competition':
        return const Color(0xFFFFD700); // Gold
      case 'Fitness':
        return green;
      case 'Merch':
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  String _formatTimestamp(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount == 0) return const SizedBox();
              return TextButton(
                onPressed: () => provider.markAllAsRead(),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: green,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category Filter Bar
            SizedBox(
              height: 38.sp,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 4.sp),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.sp),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      selectedColor: green,
                      backgroundColor: Colors.grey[900],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 11.sp,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? green : Colors.white12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.sp),

            // Notification List
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, notifProvider, child) {
                  List<NotificationItem> filtered = notifProvider.notifications;
                  if (_selectedCategory != 'All') {
                    filtered = filtered
                        .where((n) => n.category.toLowerCase() == _selectedCategory.toLowerCase())
                        .toList();
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48.sp,
                            color: Colors.white24,
                          ),
                          SizedBox(height: 12.sp),
                          Text(
                            'No notifications here',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.sp),
                          Text(
                            'You are all caught up!',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 11.sp,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 14.sp, vertical: 6.sp),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final catColor = _getCategoryColor(item.category);
                      final catIcon = _getCategoryIcon(item.category);

                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 18.sp),
                          margin: EdgeInsets.only(bottom: 10.sp),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          notifProvider.deleteNotification(item.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Notification removed'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () {
                            notifProvider.markAsRead(item.id);
                            if (item.actionTarget != null && widget.onNotificationNavigate != null) {
                              widget.onNotificationNavigate!(item.actionTarget!);
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10.sp),
                            padding: EdgeInsets.all(12.sp),
                            decoration: BoxDecoration(
                              color: item.isRead
                                  ? Colors.grey[900]?.withOpacity(0.6)
                                  : Colors.grey[900],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: item.isRead ? Colors.transparent : green.withOpacity(0.5),
                                width: item.isRead ? 1 : 1.5,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Icon Badge
                                Container(
                                  padding: EdgeInsets.all(8.sp),
                                  decoration: BoxDecoration(
                                    color: catColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    catIcon,
                                    color: catColor,
                                    size: 18.sp,
                                  ),
                                ),
                                SizedBox(width: 10.sp),

                                // Notification Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.title,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.sp,
                                                fontWeight: item.isRead
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _formatTimestamp(item.createdAt),
                                            style: TextStyle(
                                              color: Colors.white38,
                                              fontSize: 9.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.sp),
                                      Text(
                                        item.message,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11.sp,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: 6.sp),
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.sp,
                                              vertical: 2.sp,
                                            ),
                                            decoration: BoxDecoration(
                                              color: catColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item.category,
                                              style: TextStyle(
                                                color: catColor,
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (item.actionTarget != null) ...[
                                            SizedBox(width: 6.sp),
                                            Icon(
                                              Icons.touch_app,
                                              color: green,
                                              size: 10.sp,
                                            ),
                                            SizedBox(width: 2.sp),
                                            Text(
                                              'Tap to view',
                                              style: TextStyle(
                                                color: green,
                                                fontSize: 9.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Unread Dot
                                if (!item.isRead)
                                  Container(
                                    width: 8.sp,
                                    height: 8.sp,
                                    margin: EdgeInsets.only(left: 6.sp, top: 4.sp),
                                    decoration: BoxDecoration(
                                      color: green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
