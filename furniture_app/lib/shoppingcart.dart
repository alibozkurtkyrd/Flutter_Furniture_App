import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';
import 'main.dart';
import 'package:pp_local_notifications/local_notifications.dart';


addToFirebase(Product futureProduct) async {
  final database = FirebaseFirestore.instance;
  await database.collection("cart_products").add({
    "id": futureProduct.id,
    "image": futureProduct.image,
    "title": futureProduct.title,
    "price": futureProduct.price,
  }).then((_) {
    print("Product added to cart_products on Firebase");
  }).catchError((_) {
    print("an error occurred");
  });
}

deleteFromFirebase(QueryDocumentSnapshot futureProduct) async {
  final database = FirebaseFirestore.instance;
  try {
    await database
        .collection("cart_products")
        .where("image", isEqualTo: futureProduct['image'])
        .get()
        .then((snapshot) {
      snapshot.docs.first.reference.delete();
    });
    print("Product deleted from cart_products on Firebase");
  } catch (e) {
    print(e.toString());
  }
}

class Cart extends StatefulWidget {
  @override
  _Cart createState() => _Cart();
}

class _Cart extends State<Cart> {
  final database = FirebaseFirestore.instance;
  Future<QuerySnapshot> cart;
  @override
  void initState() {
    //cart = getCart();
  }
  getCart() async {
    setState(() {
      //cart =  database.collection("cart_products").get();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
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
                "Cart",
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
        body: FutureBuilder<QuerySnapshot>(
          future: database.collection("cart_products").get(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error,
                          color: Colors.blue,
                          size: 45.0,
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        Text('Error: ${snapshot.error}'),
                      ]));
            else {
              return snapshot.hasData
                  ? CartPage(cartProducts: snapshot.data.docs)
                  : Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 25.0,
                        ),
                        Text("Awaiting result..."),
                      ]));
            }
          },
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  List<QueryDocumentSnapshot> cartProducts;
  CartPage({
    Key key,
    this.cartProducts,
  }) : super(key: key);
  @override
  _CartPageState createState() => _CartPageState(cart_products: cartProducts);
}

class _CartPageState extends State<CartPage> {
  List<QueryDocumentSnapshot> cart_products;

  _CartPageState({this.cart_products}) : super();

  static const AndroidNotificationChannel channel =
  const AndroidNotificationChannel(
    id: 'default_notification11',
    name: 'CustomNotificationChannel',
    description: 'Grant this app the ability to show notifications',
    importance: AndroidNotificationChannelImportance.HIGH,
    vibratePattern: AndroidVibratePatterns.DEFAULT,
  );
  showlocalNotification(String url) async {
    await LocalNotifications.createAndroidNotificationChannel(channel: channel);
    await LocalNotifications.createNotification(
        androidSettings: new AndroidSettings(channel: channel),
        id: 0,
        title: 'Checkout',
        content: 'Go to site and checkout these products?',
        imageUrl: url,
        onNotificationClick: new NotificationAction(
            actionText: "some action",
            callback: (s) {
              print(s);
            },
            payload: "some payload",
            launchesApp: false),
        actions: [
          NotificationAction(
              callbackName: "yes",
              actionText: "Yes",
              callback: (payload) {
                print("Yes tapped!");
                LocalNotifications.removeNotification(0);
              },
              payload: "Yes tapped",
              launchesApp: true),
          new NotificationAction(
              actionText: "No",
              callbackName: "no",
              callback: (payload) async {
                print("No tapped!");
                LocalNotifications.removeNotification(0);
              },
              payload: "No Tapped",
              launchesApp: true),
        ]);
  }

  @override
  //int CartTotal = 0;
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: cart_products.length == 0
                ? Center(
              child: Text(
                "There is no Item in your Cart List...",
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
                  itemCount: cart_products.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  child: Image.network(
                                      cart_products[index]["image"]),
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
                                  title: Text(
                                      cart_products[index]["title"],
                                      style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontSize: 16)),
                                  subtitle: Text(
                                    cart_products[index]["price"]
                                        .toString() +
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
                              index: index,
                              p: cart_products[index],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Text("Selected Item ()"), //  add variable later
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text("Subtotal"), Text("TL TOTAL MONEY")],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          if(cart_products.length > 0)
                            showlocalNotification(cart_products[0]["image"]);
                        },
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              border: Border.all(
                                  color: Colors.redAccent, width: 3.0),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0)), //
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 10,
                                    color: Colors.black,
                                    offset: Offset(1, 3))
                              ]),
                          child: Text(
                            "Checkout",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  int index;
  QueryDocumentSnapshot p;

  ActionButton({Key key, this.index, this.p}) : super(key: key);
  @override
  _ActionButtonState createState() => _ActionButtonState(p: p);
}

class _ActionButtonState extends State<ActionButton> {
  QueryDocumentSnapshot p;

  _ActionButtonState({this.p}) : super();
  @override
  int _n = 1;
  Future<int> extractFromList(int index) async {
    //cartProducts.removeAt(index);
    var r = await deleteFromFirebase(p);
    return r;
  }

  void add() {
    setState(() {
      _n++;
    });
  }

  void minus() {
    setState(() {
      (_n > 0) ? (_n--) : _n = 0;
    });
  }

  Widget build(BuildContext context) {
    final _qheight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _qwidth = MediaQuery.of(context).size.width;

    return Row(
      children: <Widget>[
        Container(
          child: Container(
            height: _qheight * 0.05,
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.add_box,
                color: Colors.black,
              ),
              onPressed: add,
            ),
          ),
        ),
        Text(
          '$_n',
          style: TextStyle(fontSize: 20.0),
        ),
        Container(
          height: _qheight * 0.05,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.indeterminate_check_box,
              color: Colors.black,
            ),
            onPressed: minus,
          ),
        ),
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
                  await extractFromList(widget.index);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Cart()),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
