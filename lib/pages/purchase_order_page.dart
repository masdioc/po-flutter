import 'package:flutter/material.dart';
import 'package:login_profile_app/theme/app_colors.dart';

class PurchaseOrderPage extends StatefulWidget {
  const PurchaseOrderPage({super.key});

  @override
  State<PurchaseOrderPage> createState() => _PurchaseOrderPageState();
}

class _PurchaseOrderPageState extends State<PurchaseOrderPage> {
  List<Map<String, String>> poList = [
    {"id": "1", "name": "PO Pertama"},
    {"id": "2", "name": "PO Kedua"},
  ];

  void _deletePO(String id) {
    setState(() {
      poList.removeWhere((po) => po["id"] == id);
    });
  }

  void _addOrEditPO({Map<String, String>? existingPO}) async {
    // Contoh sederhana untuk simulasi input
    final TextEditingController controller = TextEditingController(
      text: existingPO != null ? existingPO["name"] : "",
    );

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingPO == null
              ? "Tambah Purchase Order"
              : "Edit Purchase Order"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Nama PO",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal")),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(context, {
                    "id": existingPO?["id"] ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    "name": controller.text,
                  });
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        if (existingPO != null) {
          // Update
          final index = poList.indexWhere((po) => po["id"] == existingPO["id"]);
          if (index != -1) {
            poList[index] = result;
          }
        } else {
          // Tambah
          poList.add(result);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Purchase Order"),
        centerTitle: true,
        backgroundColor: AppColors.primary,
      ),
      body: poList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada Purchase Order",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: poList.length,
              itemBuilder: (context, index) {
                final po = poList[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    title: Text(
                      po["name"]!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text("ID: ${po["id"]}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _addOrEditPO(existingPO: po),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePO(po["id"]!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditPO(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
