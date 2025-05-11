import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:theatrical_plays/models/Movie.dart';

// Εδώ θα επεξεργαζόμαστε μια παράσταση (τίτλος, περιγραφή, url κλπ)
class EditMoviePage extends StatefulWidget {
  final Movie movie;

  const EditMoviePage({super.key, required this.movie});

  @override
  State<EditMoviePage> createState() => _EditMoviePageState();
}

class _EditMoviePageState extends State<EditMoviePage> {
  // controllers για τα πεδία που θα αλλάζει ο χρήστης
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  late TextEditingController urlCtrl;

  @override
  void initState() {
    super.initState();
    // γεμίζουμε τα πεδία με τα υπάρχοντα δεδομένα
    titleCtrl = TextEditingController(text: widget.movie.title);
    descCtrl = TextEditingController(text: widget.movie.description);
    urlCtrl = TextEditingController(text: widget.movie.ticketUrl ?? '');
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    urlCtrl.dispose();
    super.dispose();
  }

  // helper για ειδοποίηση
  void notify(String msg) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 99999,
        channelKey: 'basic_channel',
        title: 'Ενημέρωση',
        body: msg,
      ),
    );
  }

  // τι κάνουμε όταν πατήσει αποθήκευση
  void save() {
    print('Τίτλος: ${titleCtrl.text}');
    print('Περιγραφή: ${descCtrl.text}');
    print('URL: ${urlCtrl.text}');
    notify('Οι αλλαγές αποθηκεύτηκαν τοπικά (προσωρινά)');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Επεξεργασία'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            field(titleCtrl, 'Τίτλος'),
            const SizedBox(height: 12),
            field(descCtrl, 'Περιγραφή', lines: 3),
            const SizedBox(height: 12),
            field(urlCtrl, 'Link Εισιτηρίων'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: save,
              child: const Text('Αποθήκευση'),
            ),
          ],
        ),
      ),
    );
  }

  // μικρό helper για πεδία
  Widget field(TextEditingController ctrl, String label, {int lines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: lines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white30),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
