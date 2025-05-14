import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/Theater.dart';
import 'package:theatrical_plays/using/VenueService.dart';

class EditVenuePage extends StatefulWidget {
  final Theater theater;

  const EditVenuePage({Key? key, required this.theater}) : super(key: key);

  @override
  State<EditVenuePage> createState() => _EditVenuePageState();
}

class _EditVenuePageState extends State<EditVenuePage> {
  late TextEditingController _titleController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.theater.title);
    _addressController = TextEditingController(text: widget.theater.address);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
    });

    final success = await VenueService.updateVenue(
      widget.theater.id,
      _titleController.text.trim(),
      _addressController.text.trim(),
    );

    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Οι αλλαγές αποθηκεύτηκαν επιτυχώς ✅')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Αποτυχία αποθήκευσης αλλαγών ❌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Επεξεργασία Χώρου')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Τίτλος Χώρου'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Διεύθυνση Χώρου'),
            ),
            const SizedBox(height: 32),
            _isSaving
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Αποθήκευση Αλλαγών'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
