import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_order_provider.dart';

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addItem(); // Tambah item default
  }

  void _addItem() {
    _itemsControllers.add({
      "product_name": TextEditingController(),
      "quantity": TextEditingController(),
      "price": TextEditingController(),
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

    final payload = {
      "supplier_id": int.tryParse(_supplierIdController.text) ?? 0,
      "order_date": _orderDateController.text,
      "items": _itemsControllers.map((item) {
        return {
          "product_name": item["product_name"]!.text,
          "quantity": int.tryParse(item["quantity"]!.text) ?? 0,
          "price": double.tryParse(item["price"]!.text) ?? 0.0,
        };
      }).toList(),
    };

    try {
      final provider =
          Provider.of<PurchaseOrderProvider>(context, listen: false);

      // Tambah PO via API
      await provider.addOrder(context, payload);

      // Refresh PO list
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
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Purchase Order"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _supplierIdController,
                decoration: const InputDecoration(labelText: "Supplier ID"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Supplier ID wajib diisi" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _orderDateController,
                decoration: const InputDecoration(labelText: "Order Date"),
                validator: (value) =>
                    value!.isEmpty ? "Tanggal order wajib diisi" : null,
              ),
              const SizedBox(height: 20),
              const Text(
                "Items",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ..._itemsControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: item["product_name"],
                          decoration:
                              const InputDecoration(labelText: "Product Name"),
                          validator: (value) =>
                              value!.isEmpty ? "Nama produk wajib diisi" : null,
                        ),
                        TextFormField(
                          controller: item["quantity"],
                          decoration: const InputDecoration(labelText: "Qty"),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? "Jumlah wajib diisi" : null,
                        ),
                        TextFormField(
                          controller: item["price"],
                          decoration: const InputDecoration(labelText: "Price"),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              value!.isEmpty ? "Harga wajib diisi" : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text("Tambah Item"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePO,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text("Simpan PO"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
