import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/Products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';
class UserProductScreen extends StatelessWidget {
  static const routeName = '/UserProductScreen';


  Future<void> _refreshProduct (BuildContext context) async{
    await Provider.of<Products>(context, listen: false).fetchProducts(true);
  }

  @override
  Widget build(BuildContext context) {
   // final products = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          }, icon: Icon(Icons.add)),
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProduct(context),
        builder:(ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting ? Center(child: CircularProgressIndicator(),) : RefreshIndicator(
          onRefresh: () => _refreshProduct(context),
          child: Consumer<Products> (
            builder: (ctx, products, _) => Padding(
            padding: EdgeInsets.all(8),
            child: ListView.builder(
              itemBuilder: (_, i) {
               return UserProductItem(products.items[i].id.toString() ,products.items[i].imageUrl, products.items[i].title);
              },
              itemCount: products.items.length,
              ),
          )
          )
        ),
      ),
    );
  }
}