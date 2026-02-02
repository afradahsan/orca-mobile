import 'package:flutter/material.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/ecom/data/product_model.dart';
import 'package:orca/features/ecom/presentation/product_details.dart';
import 'package:sizer/sizer.dart';

class ProductSearchPage extends StatefulWidget {
  final List<Product> products;

  const ProductSearchPage({super.key, required this.products});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  String query = "";

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products.where((p) {
      return p.name.toLowerCase().contains(query.toLowerCase()) || p.brand.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        backgroundColor: darkgreen,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search products...",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onChanged: (v) => setState(() => query = v),
        ),
      ),
      body: filtered.isEmpty
          ? const Center(
              child: Text("No products found", style: TextStyle(color: Colors.white54)),
            )
          : ListView.separated(
              padding: EdgeInsets.all(14.sp),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => Divider(color: Colors.white12),
              itemBuilder: (context, index) {
                final p = filtered[index];

                return ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductDetailsPage(product: p)),
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      p.images.first,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    p.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    p.brand,
                    style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                  ),
                  trailing: Text(
                    "₹${p.price}",
                    style: TextStyle(
                      color: green,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
