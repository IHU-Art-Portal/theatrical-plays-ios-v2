import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/MoviesService.dart'; // Πρόσθεσε αυτό στην αρχή αν δεν υπάρχει

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

  int? movieEventId;

  @override
  void initState() {
    super.initState();
    loadEventId();
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

  void loadEventId() async {
    final events = await MoviesService.getEventsForProduction(widget.movie.id);
    if (events.isNotEmpty) {
      setState(() {
        movieEventId = events.first.id; // ή ζήτησε από τον χρήστη να επιλέξει
      });
    }
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
  void save() async {
    final productionUpdated = await MoviesService.updateProduction(
      productionId: widget.movie.id,
      title: titleCtrl.text,
      description: descCtrl.text,
      ticketUrl: urlCtrl.text,
      producer: widget.movie.producer,
      mediaUrl: widget.movie.mediaUrl,
      duration: widget.movie.duration,
    );

    final eventId = movieEventId;
    if (eventId == null) {
      notify('Δεν βρέθηκε event για την παραγωγή');
      return;
    }
    final eventUpdated = await MoviesService.updateEvent(
      eventId: eventId,
      priceRange: widget.movie.priceRange,
      eventDate: null,
      productionId: widget.movie.id,
      venueId: widget.movie.organizerId,
    );

    if (productionUpdated && eventUpdated) {
      notify('Οι αλλαγές αποθηκεύτηκαν με επιτυχία ✅');
      Navigator.pop(context);
    } else {
      notify('❌ Κάτι πήγε στραβά. Δοκίμασε ξανά.');
    }
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
