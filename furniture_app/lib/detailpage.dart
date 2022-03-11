import 'package:flutter/material.dart';

import 'shoppingcart.dart';

import 'dbHelper.dart';
import 'favorite.dart';
import 'product.dart';

class _MyAppState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Details());
  }
}

class Details extends StatelessWidget {
  final Product product;
  var dbHelper = DbHelper();
  Details({this.product});
  void addProduct(Product product) {
    cartProducts.add(product);
    addToFirebase(product);
  }
  void addFavoriteProduct(Product product) async {
    //cartProducts.add(product);
    var result = await dbHelper.insertFavorite(product);
  }
  @override
  Widget build(BuildContext context) {
    int numofitems = 1;

    final _qheight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _qwidth = MediaQuery.of(context).size.width;

    void incrementcounter() {
      numofitems++;
    }

    void decrementcounter() {
      numofitems--;
    }

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(PageRouteBuilder(
                transitionDuration: Duration(seconds: 1),
                pageBuilder: (context, animation, secondaryAnimation) => Cart(),
                transitionsBuilder: (context, animation, secondaryAnimation,
                    child) =>
                    _transition(context, animation, secondaryAnimation, child),
              ));
            },
          ),
          SizedBox(
            width: 15, // you should change this one
          )
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _qheight * 0.015,
            ),
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  image: DecorationImage(
                    image: NetworkImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                color: Colors.white,
                child: ListTile(
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${product.title}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '\$${product.price}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            height: _qheight * 0.06,
                            width: _qwidth * 0.24,
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: IconButton(
                                    onPressed: () {
                                      addFavoriteProduct(product);
                                      return showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: Text(
                                                  "Selected Item successfully added your Favorite"),
                                            );
                                          });
                                    },
                                    icon: Icon(Icons.favorite,
                                      color: Colors.white70,),
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'About Product',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: _qheight * 0.01,
                      ),
                      Text(
                        'The Obsidian chair is the true pioneer of the AKRacing Office chair series. With executive looks and top-quality materials, it is the right choice for your office – be that a corporate setting or a home office.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Center(
                        child: Container(
                          height: _qheight * 0.1,
                          width: _qwidth * 0.55,
                          child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              color: Colors.blueAccent,
                              onPressed: () {
                                addProduct(product);

                                return showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Text(
                                            "Selected Item successfully added your Cart"),
                                      );
                                    });
                              },
                              child: Text('Add to Cart')),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: _qheight * 0.1,
                          width: _qwidth * 0.55,
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            color: Colors.redAccent,
                            onPressed: () {
                              Navigator.of(context).push(PageRouteBuilder(
                                transitionDuration: Duration(seconds: 1),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                    Favorite(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) =>
                                    _transition(context, animation,
                                        secondaryAnimation, child),
                              ));
                            },
                            child: Text(
                              'Go to the My Favorites',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

SlideTransition _transition(context, animation, secondaryAnimation, child) {
  var begin = Offset(0.0, 1.0);
  var end = Offset.zero;
  var curve = Curves.ease;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}
