import 'package:flutter/material.dart';
import 'package:uniball_frontend_2/entities/practice.dart';

class VotePopup extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onClose;
  final Practice practice;

  const VotePopup({
    super.key,
    required this.onContinue,
    required this.onClose,
    required this.practice,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color.fromARGB(255, 0, 0, 0),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        width: 300,
        height: 400,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: GestureDetector(
                onTap: () {
                  onClose();
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.close),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Rösta på kvällens assist,\nmål och MVP!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Image.asset('assets/goldTrophy.png', width: 80, height: 80),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      onContinue();
                      Navigator.of(context).pop();
                      Navigator.pushNamed(
                        context,
                        '/voting1Best',
                        arguments: practice,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Gå vidare',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
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
