import 'package:flutter/material.dart';
import 'package:theatrical_plays/models/AccountRequestDto.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/UserService.dart';
import 'package:theatrical_plays/using/WebViewScreen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ClaimsRequestsScreen extends StatefulWidget {
  @override
  _ClaimsRequestsScreenState createState() => _ClaimsRequestsScreenState();
}

class _ClaimsRequestsScreenState extends State<ClaimsRequestsScreen> {
  late Future<List<AccountRequestDto>> claimsFuture;
  Map<String, dynamic>? currentUserData; // 👈 Πρόσθεσε αυτό

  @override
  void initState() {
    super.initState();
    claimsFuture = loadClaimsAndUser();
  }

  Future<List<AccountRequestDto>> loadClaimsAndUser() async {
    currentUserData = await UserService.fetchUserProfile();
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
            print("❌ Σφάλμα ClaimsRequestsScreen: ${snapshot.error}");
            return Center(child: Text("Κάτι πήγε στραβά..."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Δεν υπάρχουν αιτήματα αυτή τη στιγμή."));
          }

          final claims = snapshot.data!;

          return ListView.builder(
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index];

              // 👇 Υπολογισμός πριν το widget
              final isCurrentUser = currentUserData != null &&
                  currentUserData!["userId"] == claim.userId;

              final username =
                  isCurrentUser ? currentUserData!["username"] : null;

              return ListTile(
                title: Text(
                  username != null && username.isNotEmpty
                      ? "Αιτών: @$username"
                      : (claim.userEmail != null
                          ? "Αιτών: ${claim.userEmail}"
                          : "Αιτών: Άγνωστος"),
                ),
                subtitle: Text(
                    "ID ηθοποιού: ${claim.personId} | Κατάσταση: ${claim.status}"),
                trailing: Icon(Icons.description_outlined),
                onTap: () {
                  if (claim.documentUrl != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebViewScreen(
                          url: claim.documentUrl!,
                          onDecision: (String decision) async {
                            if (decision == 'accept') {
                              final success =
                                  await UserService.approveClaim(claim.id!);
                              if (success)
                                showAwesomeNotification(
                                    "Το αίτημα εγκρίθηκε ✅");
                            } else if (decision == 'reject') {
                              final success =
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
