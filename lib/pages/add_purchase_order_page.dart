import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_order_provider.dart';
import 'package:intl/intl.dart';

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
    final DateTime orderDate =
        DateFormat('dd-MM-yyyy').parse(_orderDateController.text);

    final payload = {
      "supplier_id": int.tryParse(_supplierIdController.text) ?? 0,
      "order_date": DateFormat('yyyy-MM-dd').format(orderDate),
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
          children: [
            TextFormField(
              controller: item["product_name"],
              decoration: const InputDecoration(
                labelText: "Product Name",
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
              validator: (value) =>
                  value!.isEmpty ? "Nama produk wajib diisi" : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: item["quantity"],
              decoration: const InputDecoration(
                labelText: "Quantity",
                prefixIcon: Icon(Icons.confirmation_num_outlined),
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? "Jumlah wajib diisi" : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: item["price"],
              decoration: const InputDecoration(
                labelText: "Price",
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty ? "Harga wajib diisi" : null,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Purchase Order"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _supplierIdController,
                decoration: const InputDecoration(
                  labelText: "Supplier ID",
                  prefixIcon: Icon(Icons.business),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Supplier ID wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _orderDateController,
                decoration: const InputDecoration(
                  labelText: "Order Date",
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
