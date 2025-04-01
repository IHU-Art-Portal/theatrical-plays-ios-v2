import 'package:flutter/material.dart';
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
    claimsFuture = UserService.getAllClaims(); // <-- Διορθώθηκε
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
              return ListTile(
                title: Text("Αιτών: ${claim.userEmail ?? 'Άγνωστος'}"),
                subtitle: Text(
                    "Άτομο ID: ${claim.personId} | Κατάσταση: ${claim.status}"),
                trailing: Icon(Icons.description_outlined),
                onTap: () {
                  if (claim.documentUrl != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebViewScreen(url: claim.documentUrl!),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Δεν υπάρχει αρχείο")),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
