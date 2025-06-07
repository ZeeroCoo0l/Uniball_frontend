import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';

//anvönds för att hjälpa till att navigera vid utveckling

class KnappSida extends StatelessWidget {
  const KnappSida({super.key});
  

  @override
  Widget build(BuildContext context) {

    return MainScaffold(
      selectedIndex: -1,
      onTabChange: (index) => handleTabChange(context, index),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Center(
            child: Text(
              "Knappsida",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profilepageshort');
              },
              child: const Text("Go to profile page"),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/votingpopup');
              },
              child: const Text("Go to voting popup"),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/homepage_admin');
              },
              child: const Text("Go to homepage admin"),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create_or_join_team');
              },
              child: const Text("Go to create/join team"),
            ),
          ),
        ],
      ),
    );
  }
}
