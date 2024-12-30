import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:provider/provider.dart';



class CartItem extends StatelessWidget {
 final String id;
 final String productId;
 final String title;
 final int quantity;
 final double price;

 CartItem({
  required this.id,
  required this.productId,
  required this.price,
  required this.quantity,
  required this.title
 });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Colors.red,
        child: Icon(
          Icons.delete,
          color: Colors.white,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10
        ),
        
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => {
        Provider.of<Cart>(context, listen: false).removeItem(productId)
      },
      confirmDismiss: (direction) {
       return showDialog(context: context, builder: (ctx) => AlertDialog(
        title: Text('Are you sure!'),
        content: Text('Do you want to remove the item from the cart!'),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop(true);
          }, child: Text('Yes')),
          TextButton(onPressed: (){
            Navigator.of(context).pop(false);
          }, child: Text('No'))
        ],
       ));
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ListTile(
            leading: CircleAvatar(child: FittedBox(child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text('\$${price}'),
            )),),
            title: Text(title),
            subtitle: Text('Total: \$${price * quantity}'),
            trailing: Text('${quantity} x'),
            ),
        ),
      ),
    );
  }
}