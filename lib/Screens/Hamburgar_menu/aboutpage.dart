import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/components/MainScaffold/mainscaffold.dart';


class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

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
              Text("Om Uniball", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text(
                "Uniball är en app utvecklad för att förenkla och organisera studentfotboll vid universitetet. "
                "Appen samlar funktioner för närvarohantering, lagindelning, MVP-röstning och träningsplanering.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text("Version: 1.0.0", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Utvecklad av: Team Group 9 – DSV, Stockholms universitet", style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Text("Kontakt: sporten@disk.su.se", style: TextStyle(fontSize: 16)),
              SizedBox(height: 40),
            ],
          ),
        )
      ),
     );
    }
  }
