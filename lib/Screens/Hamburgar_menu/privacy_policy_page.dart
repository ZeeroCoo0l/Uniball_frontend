import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
              Text("Integritetspolicy", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),

              Text("Senast uppdaterad: 21 maj 2025"),
              SizedBox(height: 16),

              Text("1. Vilka uppgifter vi samlar in", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Vi samlar in följande uppgifter när du använder appen:\n"
                "- Namn\n"
                "- E-postadress\n"
                "- Profilbild (frivillig)\n"
                "- Närvarodata kopplat till träningar och matcher\n"
                "- Roller (t.ex. spelare, admin)",
              ),
              SizedBox(height: 12),

              Text("2. Hur vi använder dina uppgifter", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Vi använder informationen för att:\n"
                "- Hantera ditt konto\n"
                "- Visa statistik och MVP-röstning\n"
                "- Skicka notiser (om du godkänner detta)\n"
                "- Förbättra din användarupplevelse",
              ),
              SizedBox(height: 12),

              Text("3. Tredjepartsleverantörer", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Vi använder Supabase för datalagring och autentisering. "
                "Dina uppgifter lagras säkert via deras plattform.",
              ),
              SizedBox(height: 12),

              Text("4. Hur vi skyddar dina uppgifter", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Vi använder tekniska och organisatoriska åtgärder för att skydda dina uppgifter mot obehörig åtkomst, förändring eller radering.",
              ),
              SizedBox(height: 12),

              Text("5. Dina rättigheter", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Som användare har du rätt att:\n"
                "- Begära tillgång till de uppgifter vi har om dig\n"
                "- Få felaktiga uppgifter rättade\n"
                "- Bli raderad (“rätten att bli glömd”)\n"
                "- Dra tillbaka samtycke",
              ),
              SizedBox(height: 12),

              Text("6. Lagringstid", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Vi sparar dina uppgifter så länge du är aktiv användare. "
                "Du kan när som helst be om att få ditt konto och all data raderad.",
              ),
              SizedBox(height: 12),

              Text("7. Ändringar i denna policy", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "Vi förbehåller oss rätten att uppdatera denna policy. "
                "Större förändringar kommuniceras via appen.",
              ),
              SizedBox(height: 12),

              Text("8. Kontakt", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Vid frågor, kontakta oss på: sporten@disk.su.se"),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
