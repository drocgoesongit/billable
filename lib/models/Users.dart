class Users {
  String first;
  String last;
  int phone;
  String? email;

  Users({required this.first, required this.last, required this.phone, this.email});

  Map toJson() => {
    'first' : first,
    'last' : last,
    'phone' : phone,
    'email' : email,
  };
}