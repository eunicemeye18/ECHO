import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  const Contact({super.key, required this.userMail, required this.userUid});

  final String userMail;
  final String userUid;


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Icon(Icons.person, color: Colors.white,),
      ),
      title: Text(userMail), 
      subtitle: Text(userUid));
  }
}
