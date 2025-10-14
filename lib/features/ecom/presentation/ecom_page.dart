import 'package:flutter/material.dart';
import 'package:orca/core/themes/text_theme.dart';
import 'package:orca/core/utils/colors.dart';
import 'package:orca/core/utils/constants.dart';
import 'package:orca/features/ecom/data/product_model.dart';
import 'package:orca/features/ecom/domain/cart_provider.dart';
import 'package:orca/features/ecom/domain/product_repository.dart';
import 'package:orca/features/ecom/presentation/all_products.dart';
import 'package:orca/features/ecom/presentation/cart_page.dart';
import 'package:orca/features/ecom/presentation/product_details.dart';
import 'package:orca/features/ecom/presentation/widgets/product_card.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EcomPage extends StatefulWidget {
  const EcomPage({super.key});
  @override
  State<EcomPage> createState() => _EcomPageState();
}

class _EcomPageState extends State<EcomPage> {
  final ProductService _service = ProductService();
  late Future<List<Product>> _futureProducts;

  @override
  void initState() {
    super.initState();
    debugPrint('in initstate ecom');
    _futureProducts = _service.fetchAllProducts();
    debugPrint('future products - $_futureProducts');
  }

  searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      child: Container(
        height: 30.sp,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: whitet50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: whitet150),
            SizedBox(width: 8.sp),
            Text(
              "Search here",
              style: TextStyle(color: whitet150, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkgreen,
      body: FutureBuilder<List<Product>>(
        future: ProductService().fetchAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: green,));
          } else if (snapshot.hasError) {
            debugPrint('statement has error - ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('statement no data - ${snapshot.data}');
            return const Center(child: Text('No products found', style: TextStyle(color: green),));
          }

          final products = snapshot.data!;
          print('✅ snapshot data - ${products.length} items');

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SHOP ORCA', style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold, fontFamily: 'Doto')),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Image.asset('assets/icons/search-dotted.png', color: Colors.white, width: 19.sp, height: 19.sp),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CartPage()),
                            );
                          },
                        ),
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                IconButton(
                                    icon: Image.asset(
                                      'assets/icons/cart-dotted.png',
                                      height: 20.sp,
                                    ),
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage()))),
                                if (cart.totalItems > 0)
                                  Positioned(
                                    right: 12.sp,
                                    top: 10.sp,
                                    child: Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${cart.totalItems}',
                                        style: KTextTheme.dottedDark.bodySmall!.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                // const SizedBox(height: 20),
                Row(
                  children: [
                    Text('ORCA EXCLUSIVE', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Doto')),
                    const Spacer(),
                    IconButton(
                        icon: Image.asset(
                          'assets/icons/chevron-dotted.png',
                          width: 22.sp,
                          height: 22.sp,
                        ),
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => AllProductsPage()),
                            )),
                  ],
                ),
                SizedBox(height: 8.sp),
                Row(
                  children: [
                    Expanded(
                      child: ProductCard(
                        product: products[2],
                        onTap: () {},
                        showPrice: false,
                      ),
                    ),
                    SizedBox(width: 50.sp),
                    // Expanded(
                    //     child: ProductCard(
                    //   product: products[1],
                    //   onTap: () {},
                    //   showPrice: false,
                    // )),
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle("SUPPLEMENTS"),
                SizedBox(height: 4.sp),
                ...products.where((e) => e.category == '67d28c34b0a6538d1cd82f2b').map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _smallProductCard(e),
                    )),
                
              ],
            ),
          );
        },
      ),
    );
  }

  //  ----- UI widgets ------

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold, fontFamily: 'Doto')),
        const Spacer(),
        IconButton(
            icon: Image.asset(
              'assets/icons/chevron-dotted.png',
              width: 22.sp,
              height: 22.sp,
            ),
            onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AllProductsPage()),
                )),
      ],
    );
  }

  Widget _smallProductCard(Product p) {
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
        height: 60.sp,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                p.images.isNotEmpty ? p.images.first : 'https://via.placeholder.com/150',
                width: double.infinity,
                height: 130.sp,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: Text(
                p.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Doto',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
