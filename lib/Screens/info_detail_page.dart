import 'package:flutter/material.dart';
//den här används inte, är kopplad till info_list_page, så finns om vi vill utveckla så att den används i framtiden

class InfoDetailPage extends StatelessWidget {
  final String date;

  InfoDetailPage({required this.date});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFB4D8C1),
        elevation: 0,
        automaticallyImplyLeading: true, // visar tillbaka-pil
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text(
              'Information',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFFE8F3ED),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inställd träning',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Träningen onsdag $date är inställd. Tyvärr måste vi ställa in dagens träning på grund av vädret.\n\n'
                    'Vi ses som vanligt på nästa träningstillfälle.\n\n/ Ledarna',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
