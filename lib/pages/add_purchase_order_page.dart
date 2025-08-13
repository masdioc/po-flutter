import 'package:flutter/material.dart';

class AddPurchaseOrderPage extends StatefulWidget {
  final Map<String, String>? existingPO;

  const AddPurchaseOrderPage({super.key, this.existingPO});

  @override
  State<AddPurchaseOrderPage> createState() => _AddPurchaseOrderPageState();
}

class _AddPurchaseOrderPageState extends State<AddPurchaseOrderPage> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingPO != null) {
      _nameController.text = widget.existingPO!["name"]!;
    }
  }

  void _savePO() {
    if (_nameController.text.isEmpty) return;

    final newPO = {
      "id": widget.existingPO?["id"] ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      "name": _nameController.text,
    };

    Navigator.pop(context, newPO);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingPO != null;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(isEditing ? "Edit Purchase Order" : "Tambah Purchase Order"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Nama PO"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePO,
              child: Text(isEditing ? "Simpan Perubahan" : "Tambah PO"),
            ),
          ],
        ),
      ),
    );
  }
}
