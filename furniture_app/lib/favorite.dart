import 'package:flutter/material.dart';

import 'dbHelper.dart';
import 'main.dart';

class Favorite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furniture',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue[200],
            elevation: 5.0,
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Color(0xFF535353)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Favorites",
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                  );
                },
              ),
              SizedBox(
                width: 15, // you should change this one
              )
            ],
          ),
          body: FavoritePage()),
    );
  }
}

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  var dbHelper = DbHelper();
  List<dynamic> products; // List<Product> is better but give  ERRO
  int productCount = 0;

  @override
  void initState() {
    getFavoriteProducts();

    super.initState();
  }

  @override
  //int CartTotal = 0;
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: productCount == 0
                ? Center(
              child: Text(
                "There is no Item in your Favorite List...",
                style: TextStyle(
                  fontFamily: 'DancingScript',
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                : Container(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: productCount,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Image.network(
                                      products[index].image),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F6F9),
                                    borderRadius:
                                    BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(products[index].title,
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontSize: 16)),
                                  subtitle: Text(
                                    products[index].price.toString() +
                                        " TL",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 40,
                            child: ActionButton(
                              sqlId: products[index].sqlId,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }

  void getFavoriteProducts() async {
    var productsFuture = dbHelper.getProductsFavorite();
    productsFuture.then((data) {
      setState(() {
        this.products = data;
        productCount = data.length;
      });
    });
  }
}

class ActionButton extends StatefulWidget {
  int sqlId;

  ActionButton({this.sqlId});
  @override
  _ActionButtonState createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  int _n = 1;
  Future<int> extractFromList() async {
    //_CartPageState().products.removeAt(index);

    //print("test223: ${_CartPageState().products[index].sqlId}");

    var result =
    await _FavoritePageState().dbHelper.deleteFavorite(widget.sqlId);

    return result;
  }

  Widget build(BuildContext context) {
    final _qheight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _qwidth = MediaQuery.of(context).size.width;

    return Row(
      children: <Widget>[
        Expanded(
          flex: 4,
          child: Container(
            height: _qheight * 0.05,
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
                heroTag: null,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.delete,
                  color: Colors.black,
                ),
                onPressed: () async {
                  await extractFromList();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Favorite()),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
