import 'package:flutter/material.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/features/ecom/domain/product_repository.dart';
import 'package:orca/features/ecom/presentation/product_details.dart';
import 'package:sizer/sizer.dart';
import '../data/product_model.dart';

class AllProductsPage extends StatefulWidget {
  const AllProductsPage({super.key});

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
    return Scaffold(
      backgroundColor: darkgreen,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/icons/back-chev-dotted.png', color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        // centerTitle: true,
        backgroundColor: darkgreen,
        title: Text('ALL PRODUCTS', style: KTextTheme.dottedDark.titleLarge),
        titleSpacing: 2.sp,
      ),
      body: FutureBuilder<List<Product>>(
        future: _futureProducts,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
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
                        child: Image.asset(
                          p.imageUrl,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
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
                            Text(p.title,
                                style: KTextTheme.dottedDark.bodyLarge),
                            Text(p.price,
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
