import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<List<Product>> fetchProducts(http.Client client, int category) async {
  String url =
      'https://raw.githubusercontent.com/batukan99/comp205/main/onsale.json';
  if (category == 0)
    url =
    'https://raw.githubusercontent.com/batukan99/comp205/main/livingroom.json';
  else if (category == 1)
    url =
    'https://raw.githubusercontent.com/batukan99/comp205/main/diningroom.json';
  else if (category == 2)
    url =
    'https://raw.githubusercontent.com/batukan99/comp205/main/bedroom.json';
  else if (category == 3)
    url =
    'https://raw.githubusercontent.com/batukan99/comp205/main/youngrooms.json';
  else if (category == 4)
    url =
    'https://raw.githubusercontent.com/batukan99/comp205/main/tvUnits.json';
  else if (category == -1)
    url =
    'https://raw.githubusercontent.com/batukan99/comp205/main/onsale.json';
  else if (category == -2)
    url =
    'https://raw.githubusercontent.com/batukan99/comp205/main/new.json';
  final response = await client.get(url);
  return compute(parseProducts, response.body);
}

List<Product> parseProducts(String responseBody) {
  final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();

  return parsed.map<Product>((json) => Product.fromJson(json)).toList();
}

class Product {
  String image, title;
  int price, id, sqlId;
  static int increment = 0;
  Product({this.image, this.title, this.price, this.id});
  Product.withsqlId({
    this.image,
    this.title,
    this.price,
    this.id,
    this.sqlId,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product.withsqlId(
      image: json['image'],
      id: json['index'],
      title: json['title'],
      price: json['price'],
      sqlId: json['sqlId'] != null ? json['sqlId'] : increment++,

      //  description: json['description'],
    );
  }
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["image"] = image;
    map["title"] = title;
    map["price"] = price;
    map["id"] = id;
    if (sqlId != null) {
      map["sqlId"] = sqlId;
    }

    return map;
  }

  Product.fromObject(dynamic o) {
    // one of constructer type
    // return from map to product object
    this.id = int.tryParse(o["id"]
        .toString()); // maybe o["id"] could be string thus convert it as int
    this.image = o["image"];
    this.title = o["title"];
    this.price = int.tryParse(o["price"].toString());
    this.sqlId = int.tryParse(o["sqlId"].toString());
  }
}

List listProducts = [];
List<Product> currentProducts = listProducts[0];

String dummyText =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since. When an unknown printer took a galley.";
List<Product> cartProducts = [];
