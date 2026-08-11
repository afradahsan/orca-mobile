import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/auth/domain/auth_provider.dart';
import 'package:orca/features/ecom/data/order_model.dart';
import 'package:orca/features/ecom/domain/order_service.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  State<MyOrders> createState() => _MyOrdersState();
}

enum OrderFilter {
  all,
  confirmed,
  delivered,
  cancelled,
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
    final auth = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    await auth.loadAuthData();

    final String token = auth.token ?? '';
    debugPrint("token: $token");
    if (token.isEmpty) return [];

    return await _orderService.fetchOrders(token);
  }

  OrderFilter selectedFilter = OrderFilter.all;

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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    filterChip("All", OrderFilter.all),
                    filterChip("Confirmed", OrderFilter.confirmed),
                    filterChip("Delivered", OrderFilter.delivered),
                    filterChip("Cancelled", OrderFilter.cancelled),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Order>>(
                  future: _futureOrders,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: green));
                    }
                
                    final orders = snapshot.data;
                
                    if (snapshot.hasError) {
                      debugPrint("ORDER ERROR: ${snapshot.error}");
                      return Text(
                        snapshot.error.toString(),
                        style: const TextStyle(color: Colors.redAccent),
                      );
                    }
                
                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "No orders found",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                
                    final filteredOrders = getFilteredOrders(orders!);
                
                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                
                          if (order.items.isEmpty) {
                            return Center(child: Text("No orders to show", style: TextStyle(color: Colors.white)));
                          }
                
                          return orderCard(order);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget orderCard(Order order) {
    final item = order.items.first;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff171717),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.image.isNotEmpty
                      ? Image.network(
                          item.image,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/images/product_placeholder.png",
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                        )),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (order.items.length > 1)
                      Text(
                        "+${order.items.length - 1} more items",
                        style: const TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      "Order #${order.id.substring(order.id.length - 6)}",
                      style: const TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              statusBadge(order.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹${order.total.toStringAsFixed(0)}",
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white54,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget statusBadge(String status) {
    final color = _statusColor(
      status.toLowerCase(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<Order> getFilteredOrders(List<Order> orders) {
    switch (selectedFilter) {
      case OrderFilter.confirmed:
        return orders
            .where(
              (o) => o.status.toLowerCase() == "confirmed",
            )
            .toList();

      case OrderFilter.delivered:
        return orders
            .where(
              (o) => o.status.toLowerCase() == "delivered",
            )
            .toList();

      case OrderFilter.cancelled:
        return orders
            .where(
              (o) => o.status.toLowerCase() == "cancelled",
            )
            .toList();

      case OrderFilter.all:
      default:
        return orders;
    }
  }

  Widget filterChip(
    String title,
    OrderFilter filter,
  ) {
    final selected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? green : Colors.white.withOpacity(.05),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
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
