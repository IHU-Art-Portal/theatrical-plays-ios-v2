import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';
import 'package:theatrical_plays/using/WebViewScreen.dart';
import 'package:theatrical_plays/using/UserService.dart';

class PurchaseCreditsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        title: Text("Αγορά Credits", style: TextStyle(color: colors.accent)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.accent),
          onPressed: () {
            Navigator.pop(context); // ✅ Επιστροφή στην αρχική
          },
        ),
      ),
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Διαθέσιμα Πακέτα Αγορών",
                style: TextStyle(color: Colors.white, fontSize: 20)),

            SizedBox(height: 20),

            buildCreditPackage(context, 5, 4.99),
            buildCreditPackage(context, 10, 9.99),
            buildCreditPackage(context, 20, 18.99),
            buildCreditPackage(context, 50, 45.99),

            SizedBox(height: 30),

            // 🔙 **Κουμπί επιστροφής στην αρχική**
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.home, color: Colors.white),
              label: Text("Επιστροφή στην Αρχική"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.accent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCreditPackage(BuildContext context, int credits, double price) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final colors = isDarkMode ? MyColors.dark : MyColors.light;

    return Card(
      color: colors.secondaryText,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: ListTile(
        leading: Icon(Icons.monetization_on, color: Colors.yellow, size: 30),
        title: Text("$credits Credits",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        trailing: Text("$price€",
            style: TextStyle(color: Colors.greenAccent, fontSize: 18)),
        onTap: () async {
          print("🛒 Αγορά $credits credits για $price€");

          String? checkoutUrl =
              await UserService.createCheckoutSession(credits, price);

          if (checkoutUrl != null) {
            print("✅ Μετάβαση στο Stripe Checkout...");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WebViewScreen(url: checkoutUrl),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Αποτυχία δημιουργίας πληρωμής!"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
  }
}
