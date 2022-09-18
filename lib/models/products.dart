class Product{
  String name;
  int price;

  Product({required this.name, required this.price});
  factory Product.fromJson(dynamic json){
    return Product(name: json['name'] as String, price: int.parse(json['price']) as int);
  }


}