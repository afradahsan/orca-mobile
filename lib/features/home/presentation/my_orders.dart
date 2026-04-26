import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/ecom/data/order_model.dart';
import 'package:orca/features/ecom/domain/order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key, this.token});

  final String? token;

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  late Future<List<Order>> _futureOrders;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _futureOrders = _loadOrders();
  }

  Future<List<Order>> _loadOrders() async {
    debugPrint("Loading orders...");
    final prefs = await SharedPreferences.getInstance();
    debugPrint('prefs obtained');
    debugPrint('token is ${widget.token}');
    return await _orderService.fetchOrders(widget.token!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text(
                "My Orders",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.sp),
              FutureBuilder<List<Order>>(
                future: _futureOrders,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(color: green));
                  }
        
                  if (snapshot.hasError) {
                    return Text("Failed to load orders", style: TextStyle(color: Colors.redAccent));
                  }
        
                  final orders = snapshot.data!;
        
                  if (orders.isEmpty) {
                    return Text("No orders yet", style: TextStyle(color: Colors.white54));
                  }
        
                  return Column(
                    children: orders.map((order) {
                      final firstItem = order.items.first;
        
                      return Container(
                        margin: EdgeInsets.only(bottom: 12.sp),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade800),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              firstItem.image,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            firstItem.productName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          subtitle: Text(
                            "₹${order.total.toStringAsFixed(0)} • ${_formatDate(order.createdAt)}",
                            style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                          ),
                          trailing: Text(
                            order.status.toUpperCase(),
                            style: TextStyle(
                              color: _statusColor(order.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _statusColor(String status) {
  switch (status) {
    case "delivered":
      return Colors.greenAccent;
    case "in transit":
      return Colors.orangeAccent;
    case "cancelled":
      return Colors.redAccent;
    default:
      return Colors.white70;
  }
}

String _formatDate(DateTime d) {
  return "${d.day}/${d.month}/${d.year}";
}
