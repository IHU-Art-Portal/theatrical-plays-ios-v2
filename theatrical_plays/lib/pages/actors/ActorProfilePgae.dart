import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:theatrical_plays/models/Actor.dart';
import 'package:theatrical_plays/models/Production.dart';
import 'package:theatrical_plays/models/Movie.dart';
import 'package:theatrical_plays/using/AuthorizationStore.dart';
import 'package:theatrical_plays/using/Constants.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/Loading.dart';
import 'package:theatrical_plays/pages/actors/widgets/ActorProfileBody.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:theatrical_plays/using/globals.dart';

class ActorProfilePage extends StatefulWidget {
  final Actor actor;

  const ActorProfilePage({Key? key, required this.actor}) : super(key: key);

  @override
  State<ActorProfilePage> createState() => _ActorProfilePageState();
}

class _ActorProfilePageState extends State<ActorProfilePage> {
  List<Production> productions = [];
  List<Movie> movies = [];
  bool isLoading = true;
  bool isClaimed = false;

  @override
  void initState() {
    super.initState();
    loadProductions();
  }

  Future<void> loadProductions() async {
    try {
      final token =
          await AuthorizationStore.getStoreValue("authorization") ?? '';
      final url = Uri.parse(
          "http://${Constants().hostName}/api/people/${widget.actor.id}/productions");

      final response = await http.get(url, headers: {
        "Authorization": "Bearer $globalAccessToken",
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['data']['results'];

        productions = results.map((item) {
          final p = item['production'];
          final role = item['role'] ?? '';
          return Production.fromJson(p, role: role);
        }).toList();

        movies = results.map((item) {
          final p = item['production'];
          return Movie.fromJson(p);
        }).toList();
      }
    } catch (e) {
      print('Error: $e');
    }

    setState(() {
      isLoading = false;
      isClaimed = widget.actor.isClaimed;
    });
  }

  Future<void> claimActor() async {
    try {
      final fileBytes =
          await rootBundle.load('assets/test_files/test_cv_tp.pdf');
      final base64File = base64Encode(fileBytes.buffer.asUint8List());

      final url = Uri.parse(
          "http://${Constants().hostName}/api/AccountRequests/RequestAccount");
      final headers = {
        "Accept": "application/json",
        "Authorization": "Bearer $globalAccessToken",
        "Content-Type": "application/json",
      };

      final body = jsonEncode({
        "personId": widget.actor.id,
        "identificationDocument": base64File,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        showAwesomeNotification("Το αίτημα διεκδίκησης στάλθηκε",
            title: "✅ Επιτυχία");
      } else {
        showAwesomeNotification("Αποτυχία: ${response.statusCode}",
            title: "❌ Αποτυχία");
      }
    } catch (e) {
      showAwesomeNotification("Σφάλμα κατά την αποστολή αιτήματος",
          title: "❌ Αποτυχία");
    }
  }

  void openGallery(List<String> images) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: _GalleryView(images: images),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clr =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Scaffold(
      backgroundColor: clr.background,
      appBar: AppBar(
        backgroundColor: clr.background,
        elevation: 0,
        iconTheme: IconThemeData(color: clr.accent),
        title: Text(widget.actor.fullName, style: TextStyle(color: clr.accent)),
      ),
      body: isLoading
          ? Center(child: Loading())
          : Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (widget.actor.images.isNotEmpty) {
                      openGallery(widget.actor.images);
                    }
                  },
                  child: ActorProfileBody(
                    actor: widget.actor,
                    productions: productions,
                    movies: movies,
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: isClaimed ? null : claimActor,
                    child: Tooltip(
                      message: isClaimed
                          ? "Ο λογαριασμός είναι ήδη διεκδικημένος"
                          : "Κάνε αίτημα διεκδίκησης",
                      child: Icon(
                        isClaimed ? Icons.verified : Icons.verified_outlined,
                        color: isClaimed ? Colors.green : clr.accent,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void showAwesomeNotification(String body,
      {String title = '🔔 Ειδοποίηση',
      NotificationLayout layout = NotificationLayout.Default}) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: layout,
      ),
    );
  }
}

class _GalleryView extends StatefulWidget {
  final List<String> images;

  const _GalleryView({required this.images});

  @override
  State<_GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<_GalleryView> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.images.length,
          onPageChanged: (i) => setState(() => index = i),
          itemBuilder: (_, i) {
            return InteractiveViewer(
              child: Center(
                child: Image.network(widget.images[i], fit: BoxFit.contain),
              ),
            );
          },
        ),
        Positioned(
          top: 40,
          right: 20,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }
}
