import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      selectedIndex: -1,
      onTabChange: (index) => handleTabChange(context, index),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          thumbVisibility: true,
          child: ListView(
            children: const [
              SizedBox(height: 20),
              Text(
                "Användarvillkor",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              Text("Introduktion", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Uniball är en app för att organisera, kommunicera och engagera dig i studentfotboll. "
                "Genom att använda appen godkänner du följande villkor.",
              ),
              SizedBox(height: 12),

              Text(
                "1. Användarkonto",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Du ansvarar för att informationen du anger vid registrering är korrekt. "
                "Ditt konto är personligt och får inte delas med andra utan tillstånd.",
              ),
              SizedBox(height: 12),

              Text(
                "2. Personuppgifter och integritet",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Vi hanterar personuppgifter enligt gällande dataskyddslagstiftning. "
                "Information som namn, e-post och profilbild används för att förbättra användarupplevelsen.",
              ),
              SizedBox(height: 12),

              Text(
                "3. Ansvarsfrihet",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Appen tillhandahålls i befintligt skick. Vi ansvarar inte för eventuella skador eller förluster "
                "som uppstår till följd av användningen.",
              ),
              SizedBox(height: 12),

              Text(
                "4. Tillåten användning",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Det är inte tillåtet att ladda upp stötande innehåll, trakassera andra användare eller missbruka appens funktioner.",
              ),
              SizedBox(height: 12),

              Text(
                "5. Immateriella rättigheter",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Allt innehåll i appen, inklusive logotyper och design, tillhör utvecklarna och får inte användas utan tillstånd.",
              ),
              SizedBox(height: 12),

              Text(
                "6. Ändringar av villkoren",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Vi förbehåller oss rätten att när som helst ändra användarvillkoren. "
                "Du ansvarar för att hålla dig uppdaterad om eventuella ändringar.",
              ),
              SizedBox(height: 12),

              Text("7. Kontakt", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Vid frågor, kontakta oss på: sporten@disk.su.se"),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
