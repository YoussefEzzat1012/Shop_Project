import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import '../providers/product.dart';
import '../widgets/productsGrid.dart';
import '../widgets/product_item.dart';
import 'package:provider/provider.dart';
import '../widgets/badge.dart'; 
import './cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/Products.dart';

enum FilterOptions{
  Favorites,
  All
}

class ProductOverviewScreen extends StatefulWidget {
  static const String routeName = '/ProductOverviewScreen';
  
  @override
  State<ProductOverviewScreen> createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showFavoritesOnly = false;
  var _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    setState(() {
      _isLoading = true;
      });
    Provider.of<Products>(context, listen: false).fetchProducts(true).then((_) {
      setState(() {
      _isLoading = false;
      });
    });
    super.initState();
  }

  Future<void> _refreshProduct (BuildContext context) async{
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Shop'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            onSelected: (FilterOptions selectedValue) {
              setState(() {
                 if (selectedValue == FilterOptions.Favorites) {
                      _showFavoritesOnly = true;
              } else{
                  _showFavoritesOnly = false;
              }
              });
             
            },
            itemBuilder: (_) => [
              PopupMenuItem(child: Text('Only Favorite'), value: FilterOptions.Favorites,),
              PopupMenuItem(child: Text('Show All'), value: FilterOptions.All,)
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => MyBadge(
              value: cart.itemCount.toString(),
              child: ch ?? Icon(Icons.shopping_cart),
            ),
            child: IconButton(icon: Icon(Icons.shopping_cart), onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading? Center(child: CircularProgressIndicator(),) : RefreshIndicator(
        onRefresh: () => _refreshProduct(context),
        child: ProductsGrid(_showFavoritesOnly)),
    );
  }
}


