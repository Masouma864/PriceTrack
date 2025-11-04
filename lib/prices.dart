import 'package:flutter/material.dart';
import './helper/db_helper.dart';

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
  final editQtyController = TextEditingController();
  final editUnitPriceController = TextEditingController();
  final editDiscountController = TextEditingController();

  bool _isChecked = false;
  double _grandTotal = 0.0;
  List<Map<String, dynamic>> _savedPrices = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPrices();
    qtyController.addListener(_calculateTotal);
    unitPriceController.addListener(_calculateTotal);
    discountController.addListener(_calculateTotal);
  }

  @override
  void dispose() {
    qtyController.dispose();
    unitPriceController.dispose();
    discountController.dispose();
    editQtyController.dispose();
    editUnitPriceController.dispose();
    editDiscountController.dispose();
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data saved successfully")),
    );
  }

  Future<void> _loadSavedPrices() async {
    List<Map<String, dynamic>> prices = await DbHelper.getAllPrices();
    setState(() {
      _savedPrices = prices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      appBar: AppBar(
        title: const Text("Price & Discount Calculator"),
        centerTitle: true,
        backgroundColor: Colors.blue.shade600,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.asset("assets/images/calculator.jpg"),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        
                        Card(

                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Your own calculator",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: const Color.fromARGB(
                                          255, 39, 37, 177),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Enter Price Details",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueGrey.shade200,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: unitPriceController,
                                    decoration: InputDecoration(
                                      labelText: "Unit Price",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter unit price';
                                      }
                                      final number = double.tryParse(value);
                                      if (number == null || number < 0) {
                                        return 'Please enter valid unit price';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: qtyController,
                                    decoration: InputDecoration(
                                      labelText: "Qty",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 20),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter quantity';
                                      }
                                      final number = double.tryParse(value);
                                      if (number == null || number < 0) {
                                        return 'Please enter valid qty';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
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
                                      const Text("Apply Discount"),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Visibility(
                                    visible: _isChecked,
                                    child: TextFormField(
                                      controller: discountController,
                                      decoration: const InputDecoration(
                                        labelText: 'Discount %',
                                      ),
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
                                  const SizedBox(height: 10),
                                  Center(
                                    child: Container(
                                      width: 400,
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        "Grand Total: $_grandTotal",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade900,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: SizedBox(
                                      width: 200,
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.blue.shade400,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            _calculateTotal();
                                            await DbHelper.addPrice(
                                              qty: double.parse(
                                                  qtyController.text),
                                              unitPrice: double.parse(
                                                  unitPriceController.text),
                                              discount: _isChecked
                                                  ? double.parse(
                                                      discountController.text)
                                                  : 0,
                                              total: _grandTotal,
                                              hasDiscount: _isChecked,
                                            );

                                            _saveToDatabase();
                                            qtyController.clear();
                                            unitPriceController.clear();
                                            discountController.clear();
                                            setState(() {
                                              _isChecked = false;
                                              _grandTotal = 0.0;
                                            });
                                            _loadSavedPrices();
                                          }
                                        },
                                        child: const Text(
                                          "Save",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
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
                        const SizedBox(height: 20),
                        const Divider(color: Colors.grey, thickness: 3),
                        const Text(
                          "Price List",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        const Divider(color: Colors.grey, thickness: 3),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _savedPrices.length,
                          itemBuilder: (_, index) {
                            final price = _savedPrices[index];
                            return Card(
                              child: ListTile(
                                title: Text(
                                    "QTY: ${price['qty']}, Unit price: ${price['unit_price']}"),
                                subtitle: Text(
                                    "Discount: ${price['discount']}, Total: ${price['total']}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    showEditBox(
                                      price["id"],
                                      price['qty'],
                                      price['unit_price'],
                                      price['discount'],
                                    );
                                  },
                                ),
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text("Delete"),
                                        content: const Text(
                                            "Are you sure you want to delete this item?"),
                                        actions: [
                                          OutlinedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("No"),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await DbHelper.deletePrice(
                                                  price['id']);
                                              Navigator.pop(context);
                                              _loadSavedPrices();
                                            },
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showEditBox(int id, double qty, double unitPrice, double discount) {
    editQtyController.text = qty.toString();
    editUnitPriceController.text = unitPrice.toString();
    editDiscountController.text = discount.toString();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Price"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: editQtyController,
                decoration: const InputDecoration(labelText: "Qty"),
              ),
              TextFormField(
                controller: editUnitPriceController,
                decoration: const InputDecoration(labelText: "Unit Price"),
              ),
              TextFormField(
                controller: editDiscountController,
                decoration: const InputDecoration(labelText: "Discount %"),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            OutlinedButton(
              onPressed: () async {
                double newQty = double.tryParse(editQtyController.text) ?? 0;
                double newUnitPrice =
                    double.tryParse(editUnitPriceController.text) ?? 0;
                double newDiscount =
                    double.tryParse(editDiscountController.text) ?? 0;
                double newTotal = newQty * newUnitPrice;
                if (newDiscount > 0) {
                  newTotal -= (newTotal * newDiscount / 100);
                }

                await DbHelper.updatePrice(
                  id: id,
                  qty: newQty,
                  unitPrice: newUnitPrice,
                  discount: newDiscount,
                  total: newTotal,
                  hasDiscount: newDiscount > 0,
                );
                Navigator.pop(context);
                _loadSavedPrices();
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
