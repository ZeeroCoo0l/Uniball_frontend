import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/Screens/Login&SignUp/launch_page.dart';
import 'package:uniball_frontend_2/services/login_services/email_login_service.dart';

void signOut(BuildContext context) {
  EmailLoginService().signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LaunchPage()),
    (Route<dynamic> route) => false,
  );
}

class UniballDrawer extends StatelessWidget {
  const UniballDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Text(
              'Meny',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('Om'),
            onTap: () {
              Navigator.pushNamed(context, '/aboutpage');
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Användarvillkor'),
            onTap: () {
              Navigator.pushNamed(context, '/termspage');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shield),
            title: const Text('Integritetspolicysida'),
            onTap: () {
              Navigator.pushNamed(context, '/privacypolicypage');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logga ut'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Loggat ut!")));
              signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
