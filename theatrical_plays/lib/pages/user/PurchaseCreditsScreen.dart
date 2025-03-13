import 'package:flutter/material.dart';
import 'package:theatrical_plays/using/MyColors.dart';

class PurchaseCreditsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors().black,
        title: Text("Αγορά Credits", style: TextStyle(color: MyColors().cyan)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors().cyan),
          onPressed: () {
            Navigator.pop(context); // ✅ Επιστροφή στην αρχική
          },
        ),
      ),
      backgroundColor: MyColors().black,
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
                backgroundColor: MyColors().cyan,
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
    return Card(
      color: MyColors().gray,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: ListTile(
        leading: Icon(Icons.monetization_on, color: Colors.yellow, size: 30),
        title: Text("$credits Credits",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        trailing: Text("$price€",
            style: TextStyle(color: Colors.greenAccent, fontSize: 18)),
        onTap: () {
          // TODO: Προσθήκη πληρωμής
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Δεν έχει υλοποιηθεί η αγορά!"),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }
}
