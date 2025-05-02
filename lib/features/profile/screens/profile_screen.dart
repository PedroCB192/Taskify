import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/features/profile/provider/user_provider.dart';
import 'package:taskify/features/profile/widgets/users_profile_widget.dart';
import 'package:taskify/features/profile/widgets/tasks_metric_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('No user data available')),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 0,
              maxHeight: double.infinity,
              maxWidth: double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, // Expandir a todo el ancho
                  child: UsersProfileWidget(user: user),
                ),
                const SizedBox(height: 20),
                if (!user.isPremium)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Become Premium'),
                                  content: const Text(
                                    'Unlock premium features by upgrading your account!',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        // Aquí puedes agregar la lógica para redirigir al usuario
                                        // a la página de pago o suscripción
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Upgrade Now'),
                                    ),
                                  ],
                                ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Join Premium',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: const TasksMetricWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
