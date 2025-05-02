import 'package:flutter/material.dart';
import 'package:taskify/features/profile/models/user.dart';

class UsersProfileWidget extends StatelessWidget {
  final User user;

  const UsersProfileWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/images/user_profile.png'),
          ),
          const SizedBox(height: 20),
          Text(
            user.name, // Show the user's name
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            user.isPremium
                ? 'Premium User'
                : 'Free User', // Show if the user is premium or free
            style: TextStyle(
              fontSize: 16,
              color: user.isPremium ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
