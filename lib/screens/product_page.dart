import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProductPage extends StatelessWidget {
  final int productId;

  ProductPage({required this.productId});

  Future<Map<String, dynamic>?> fetchProduct() async {
    final response = await http.get(Uri.parse(
        'http://stocksearch.atwebpages.com/get_product.php?id=${productId.toString()}'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.isNotEmpty ? data : null;
    } else {
      throw Exception('Failed to load product: ${response.statusCode}');
    }
  }

  void _showOrderMoreAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Order Placed',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('More of this item has been ordered.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Product Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchProduct(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Product not found.'));
          } else {
            final product = snapshot.data!;
            // Parse the amount and determine availability
            int amount = 0;
            if (product['amount'] != null) {
              amount = int.tryParse(product['amount'].toString()) ?? 0;
            }
            bool isAvailable = amount > 0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? 'Unnamed Product',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '\$${product['price']?.toString() ?? 'N/A'}',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                  ),
                  SizedBox(height: 20),
                  Text(
                    product['description'] ?? 'No description available.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Availability: ${isAvailable ? 'Available' : 'Not Available'}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                  if (isAvailable)
                    Text(
                      'Amount Available: $amount',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showOrderMoreAlert(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 24,
                        ),
                      ),
                      child: Text(
                        'Order More',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
