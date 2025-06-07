import 'package:flutter/material.dart';


class LoginTile extends StatelessWidget {
 final String text;
 final VoidCallback? onTap;


 const LoginTile({
   super.key,
   required this.text,
   this.onTap,
 });


 @override
 Widget build(BuildContext context) {
   return Padding(
     padding: const EdgeInsets.all(25.0),
     child: Material(
       color: const Color(0xFF094A1C),
       borderRadius: BorderRadius.circular(12),
       child: InkWell(
         borderRadius: BorderRadius.circular(12),
         onTap: onTap,
         child: Container(
           padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
           alignment: Alignment.center,
           child: Text(
             text,
             style: TextStyle(
               color: Colors.white,
               fontSize: 16,
               fontWeight: FontWeight.bold,
             ),
           ),
         ),
       ),
     ),
   );
 }
}
