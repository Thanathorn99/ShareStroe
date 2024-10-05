class Product {
  static const String collectionName = 'products'; // Define the collection name

  String name;
  String description;
  int favorite;
  String? imagePath; // Optional image path for the product
  String? referenceId;
  String? contactnumber;
  String? address;
  String bookingTime; // Add a new field for booking time

  
  
   // Optional reference ID if needed
  // Optional booking date for the cleaning appointment

  Product({
    required this.name,
    required this.description,
    required this.favorite,
    required this.contactnumber,
    required this.address,
    required this.bookingTime,
    this.referenceId,
    // Added bookingDate parameter
  });

  // Factory constructor to create a Product from a JSON map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'] as String,
      description: json['description'] as String,
      favorite: json['favorite'] as int,
      contactnumber: json['contactnumber'] as String,
      address: json['address'] as String,
      bookingTime: json['bookingTime'] as String,
      
      
      
      
      referenceId: json['referenceId'] as String?,
      
    );
  }

  // Method to convert a Product instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'favorite': favorite,
      'contactnumber': contactnumber,
      'address': address,
      'bookingTime': bookingTime,

      
      
      'referenceId': referenceId,
      
      
       // Convert DateTime to String
    };
  }
}
