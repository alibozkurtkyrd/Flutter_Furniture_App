import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'detailpage.dart';
import 'product.dart';
import 'shoppingcart.dart';
import 'favorite.dart';

var homescreen = true;
String categoryText = "On Sale";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
int _selectedIndex = 0;
int selectedIndex = -1;

//main
class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Furniture App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(http.Client(), selectedIndex),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Body(futureProducts: snapshot.data)
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
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          /*  BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),*/
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: homescreen ? Colors.amber[800] : Colors.grey,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        homescreen = true;
        selectedIndex = -1;
        categoryText = "On Sale";
        // currentProducts = listProducts[0];
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        ).then((value) => setState(() {}));
      }
      if(index == 1) {
        homescreen = false;
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

        }
    });
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF535353)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.shopping_cart, color: Color(0xFF535353)),
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
        SizedBox(width: 10)
      ],
    );
  }
}

//categories
class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<String> categories = [
    "Living Room",
    "Dining Room",
    "Bedroom",
    "Young Rooms",
    "TV Units",
  ];

  @override
  Widget build(BuildContext context) {
    final _qheight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
    final _qwidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: _qheight * 0.05,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) => buildCategory(index),
        ),
      ),
    );
  }

  Widget buildCategory(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          homescreen = false;
          categoryText = categories[index];
          // currentProducts = listProducts[_selectedIndex];
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          ).then((value) => setState(() {}));
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              categories[index],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF535353),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//home-body
class Body extends StatefulWidget {
  List<Product> futureProducts;
  Body({Key key, this.futureProducts}) : super(key: key);

  @override
  _BodyState createState() => _BodyState(futureProducts);
}

class _BodyState extends State<Body> {
  List<Product> futureProducts;
  _BodyState(this.futureProducts) : super();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            categoryText,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Categories(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: GridView.builder(
                itemCount: futureProducts.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) => ItemCard(
                  product: futureProducts[index],
                  press: () => Navigator.of(context).push(PageRouteBuilder(
                    transitionDuration: Duration(seconds: 1),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Details(product: futureProducts[index]),
                    transitionsBuilder: (context, animation,
                        secondaryAnimation, child) =>
                        _transition(
                            context, animation, secondaryAnimation, child),
                  )),
                )),
          ),
        ),
      ],
    );
  }
}

//home-itemcards
class ItemCard extends StatelessWidget {
  final Product product;
  final Function press;
  const ItemCard({
    Key key,
    this.product,
    this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: press,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              padding: EdgeInsets.all(4),
              // height: 555,
              // width: 250,
              decoration: BoxDecoration(
                color: Colors.brown[200],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Hero(
                tag: "${product.id}",
                child: Image.network(product.image),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Text(
              // products is out demo list
              product.title,
              style: TextStyle(color: Colors.brown[300]),
            ),
          ),
          Text(
            "\₺${product.price}",
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
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
