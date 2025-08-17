import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_order_provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPurchaseOrderPage extends StatefulWidget {
  const AddPurchaseOrderPage({super.key});

  @override
  State<AddPurchaseOrderPage> createState() => _AddPurchaseOrderPageState();
}

class _AddPurchaseOrderPageState extends State<AddPurchaseOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _supplierIdController = TextEditingController();
  final TextEditingController _orderDateController = TextEditingController();
  final List<Map<String, TextEditingController>> _itemsControllers = [];
  Map<String, dynamic>? user;
  bool _isLoading = false;
  // final prrovider = Provider.of<PurchaseOrderProvider>(context); // listen: true
  List<String> productOptions = []; // sebelumnya final
  @override
  void initState() {
    super.initState();
    _loadUserFromPrefs();
    _addItem(); // Tambah item default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProducts();
    });
  }

  Future<void> _fetchProducts() async {
    try {
      final provider =
          Provider.of<PurchaseOrderProvider>(context, listen: false);
      final products = await provider.fetchProducts();

      setState(() {
        productOptions =
            products.map<String>((p) => p['name'].toString()).toList();
      });
    } catch (e) {
      debugPrint("Gagal ambil produk: $e");
    }
  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString("user");

    if (userString != null) {
      setState(() {
        user = json.decode(userString);
      });
    }
  }

  void _addItem() {
    _itemsControllers.add({
      "product_name": TextEditingController(),
      "quantity": TextEditingController(),
      "price_buy": TextEditingController(),
      "price_sell": TextEditingController(),
    });
    setState(() {});
  }

  void _removeItem(int index) {
    _itemsControllers.removeAt(index);
    setState(() {});
  }

  Future<void> _savePO() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final DateTime orderDate =
        DateFormat('dd-MM-yyyy').parse(_orderDateController.text);

    final payload = {
      "supplier_id": user!['suplier_id'] ?? 1,
      "order_date": DateFormat('yyyy-MM-dd').format(orderDate),
      "items": _itemsControllers.map((item) {
        return {
          "product_name": item["product_name"]!.text,
          "quantity": int.tryParse(item["quantity"]!.text) ?? 0,
          "price_buy": double.tryParse(item["price_buy"]!.text) ?? 0.0,
          "price_sell": double.tryParse(item["price_sell"]!.text) ?? 0.0,
        };
      }).toList(),
    };

    try {
      final provider =
          Provider.of<PurchaseOrderProvider>(context, listen: false);

      await provider.addOrder(context, payload);
      await provider.fetchOrders(context);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PO berhasil ditambahkan")),
        );
        Navigator.pop(context); // kembali ke halaman PO
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _orderDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }

  Widget _buildItemCard(int index, Map<String, TextEditingController> item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: TextField + Dropdown untuk Nama Item
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item["product_name"],
                    decoration: const InputDecoration(
                      labelText: "Nama Item",
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Nama Item wajib diisi" : null,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    hint: const Text("Pilih"),
                    value: item["product_name"]!.text.isNotEmpty &&
                            productOptions.contains(item["product_name"]!.text)
                        ? item["product_name"]!.text
                        : null,
                    items: productOptions
                        .map((name) => DropdownMenuItem(
                              value: name,
                              child: Text(name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          item["product_name"]!.text = value;
                        });
                      }
                    },
                    underline: const SizedBox(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row Quantity + Hapus
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item["quantity"],
                    decoration: const InputDecoration(
                      labelText: "Jumlah",
                      prefixIcon: Icon(Icons.confirmation_num_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Jumlah wajib diisi" : null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row Harga Beli + Harga Jual
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item["price_buy"],
                    decoration: const InputDecoration(
                      labelText: "Harga Beli",
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Harga Beli wajib diisi" : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: item["price_sell"],
                    decoration: const InputDecoration(
                      labelText: "Harga Jual",
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Harga Jual wajib diisi" : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah PO"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 12),
              TextFormField(
                controller: _orderDateController,
                decoration: const InputDecoration(
                  labelText: "Tanggal Order",
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickDate,
                validator: (value) =>
                    value!.isEmpty ? "Tanggal order wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Items",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              ..._itemsControllers
                  .asMap()
                  .entries
                  .map((entry) => _buildItemCard(entry.key, entry.value)),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Tambah Item"),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePO,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text(
                          "Simpan PO",
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
