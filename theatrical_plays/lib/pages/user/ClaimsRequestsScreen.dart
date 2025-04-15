import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:theatrical_plays/models/AccountRequestDto.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:theatrical_plays/using/WebViewScreen.dart';

class ClaimsRequestsScreen extends StatefulWidget {
  @override
  _ClaimsRequestsScreenState createState() => _ClaimsRequestsScreenState();
}

class _ClaimsRequestsScreenState extends State<ClaimsRequestsScreen> {
  late Future<List<AccountRequestDto>> claimsFuture;

  @override
  void initState() {
    super.initState();
    claimsFuture = preloadAndLoadClaims(); // ✅ περιμένουμε preload
  }

  Future<List<AccountRequestDto>> preloadAndLoadClaims() async {
    await UserService.preloadAllActors(); // ✅ φορτώνουμε ονόματα ηθοποιών
    return await UserService.getAllClaims();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        theme.brightness == Brightness.dark ? MyColors.dark : MyColors.light;

    return Scaffold(
      appBar: AppBar(
        title: Text("Αιτήματα Claim", style: TextStyle(color: colors.accent)),
        backgroundColor: colors.background,
        iconTheme: IconThemeData(color: colors.accent),
      ),
      body: FutureBuilder<List<AccountRequestDto>>(
        future: claimsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Κάτι πήγε στραβά..."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Δεν υπάρχουν αιτήματα αυτή τη στιγμή."));
          }

          final claims = snapshot.data!;

          return ListView.builder(
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index];

              final actorName =
                  UserService.getActorNameFromCache(claim.personId) ??
                      "Άγνωστος ηθοποιός";
              final requester = claim.userEmail ?? "Χρήστης #${claim.userId}";

              Color statusColor;
              switch (claim.status?.toLowerCase()) {
                case 'approved':
                  statusColor = Colors.green;
                  break;
                case 'rejected':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              return ListTile(
                title: Text("Αιτών: $requester"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ηθοποιός: $actorName"),
                    Text(
                      "Κατάσταση: ${claim.status}",
                      style: TextStyle(color: statusColor),
                    ),
                  ],
                ),
                trailing: Icon(Icons.description_outlined),
                onTap: () {
                  if (claim.documentUrl != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebViewScreen(
                          url: claim.documentUrl!,
                          onDecision: (String decision) async {
                            bool success = false;

                            if (decision == 'accept') {
                              success =
                                  await UserService.approveClaim(claim.id!);
                              if (success)
                                showAwesomeNotification(
                                    "Το αίτημα εγκρίθηκε ✅");
                            } else if (decision == 'reject') {
                              success =
                                  await UserService.rejectClaim(claim.id!);
                              if (success)
                                showAwesomeNotification(
                                    "Το αίτημα απορρίφθηκε ❌");
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    showAwesomeNotification("Δεν υπάρχει αρχείο",
                        title: "❌ Αποτυχία");
                  }
                },
              );
            },
          );
        },
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
