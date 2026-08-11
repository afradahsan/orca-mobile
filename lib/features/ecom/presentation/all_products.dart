import 'package:flutter/material.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/ecom/domain/product_repository.dart';
import 'package:orca/features/ecom/presentation/product_details.dart';
import 'package:sizer/sizer.dart';
import '../data/product_model.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({
    this.orcaExclusive = false,
    this.categoryName,
    super.key,
  });

  final bool orcaExclusive;
  final String? categoryName;

  @override
  State<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends State<AllProductsPage> {
  final ProductService _service = ProductService();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    _futureProducts = _service.fetchAllProducts();
  }

  @override
  Widget build(BuildContext context) {
    String titleText = 'ALL PRODUCTS';
    if (widget.orcaExclusive) {
      titleText = 'ORCA EXCLUSIVE';
    } else if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      titleText = widget.categoryName!.toUpperCase();
    }

    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/icons/back-chev-dotted.png', color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: darkgreen,
        title: Text(titleText, style: KTextTheme.dottedDark.titleLarge),
        titleSpacing: 2.sp,
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: green));
          }

          List<Product> products = snapshot.data!;

          if (widget.orcaExclusive) {
            products = products.where((p) => p.brand.toLowerCase() == 'orca').toList();
          } else if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
            products = products.where((p) => p.categoryName.toUpperCase() == widget.categoryName!.toUpperCase()).toList();
          }
          return ListView.separated(
            padding: EdgeInsets.all(16.sp),
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(height: 14.sp),
            itemBuilder: (context, index) {
              final p = products[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailsPage(product: p),
                    ),
                  );
                },
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          p.images.isNotEmpty ? p.images.first : 'https://via.placeholder.com/150',
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 140,
                            width: double.infinity,
                            color: Colors.grey[900],
                            child: const Icon(Icons.shopping_bag_outlined, color: Colors.white38, size: 40),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: KTextTheme.dottedDark.bodyLarge),
                            Text(p.price.toString(),
                                style: KTextTheme.dottedDark.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
