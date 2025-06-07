import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/constants.dart';
import 'package:uniball_frontend_2/Screens/leaderboard.dart';

//hårdkodad och används inte för tillfället, men i framtiden implementera med tanken att du som användare ska se din senaste utmärkelse

class AwardButton extends StatelessWidget {
  const AwardButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LeaderBoard()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.veryLightGreen,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Din senaste utmärkelse", style: TextStyle(fontSize: 16)),
                Text(
                  "MVP",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text("16/4", style: TextStyle(fontSize: 14)),
              ],
            ),
            SizedBox(width: 8),
            Image.asset('assets/goldTrophy.png', height: 75, width: 75),
          ],
        ),
      ),
    );
  }
}
