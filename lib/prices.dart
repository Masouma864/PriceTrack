import 'package:flutter/material.dart';

class PriceFormPage extends StatefulWidget {
  const PriceFormPage({super.key});

  @override
  State<PriceFormPage> createState() => _PriceFormPageState();
}

class _PriceFormPageState extends State<PriceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final qtyController = TextEditingController();
  final unitPriceController = TextEditingController();
  final discountController = TextEditingController();

  bool _isChecked = false;
  double _grandTotal = 0.0;

  @override
  void initState() {
    super.initState();

    qtyController.addListener(_calculateTotal);
    unitPriceController.addListener(_calculateTotal);
    discountController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    qtyController.dispose();
    unitPriceController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    int qty = int.tryParse(qtyController.text) ?? 0;
    double unitPrice = double.tryParse(unitPriceController.text) ?? 0;
    double total = qty * unitPrice;

    if (_isChecked) {
      double discount = double.tryParse(discountController.text) ?? 0;
      total = total - (total * discount / 100);
    }
    setState(() {
      _grandTotal = total;
    });
  }

  void _saveToDatabase() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data saved successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.emoji_emotions_rounded),
        title: const Text('Total Price Form'),
      ),
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.only(top: 60),

            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: unitPriceController,
                    decoration: InputDecoration(
                      label: Text("UnitPrice"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter unit price';
                      }
                      final number = double.tryParse(value);
                      if (number == null || number < 0) {
                        return 'please enter valid unitprice';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: qtyController,
                    decoration: InputDecoration(
                      label: Text("Qty"),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'please enter quantity';
                      }
                      final number = double.tryParse(value);
                      if (number == null || number < 0) {
                        return 'please enter valid qty';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                            _calculateTotal();
                          });
                        },
                      ),
                      Expanded(child: Text("Apply Discount")),
                    ],
                  ),

                  SizedBox(height: 20),
                  Visibility(
                    visible: _isChecked,
                    child: TextFormField(
                      controller: discountController,
                      decoration: InputDecoration(labelText: 'Discount %'),
                      validator: (value) {
                        if (!_isChecked) return null;
                        if (value == null || value.isEmpty) {
                          return "Please enter discount";
                        }
                        final number = double.tryParse(value);
                        if (number == null || number < 0) {
                          return 'Discount must be >= 0';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      child: Text(
                        "Grand Total:$_grandTotal",
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _calculateTotal();
                        _saveToDatabase();
                      }
                    },
                    child: Text("Save"),
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
