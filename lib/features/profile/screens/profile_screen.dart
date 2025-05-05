import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/features/auth/services/auth_service.dart';
import 'package:taskify/features/profile/provider/user_provider.dart';
import 'package:taskify/features/profile/widgets/users_profile_widget.dart';
import 'package:taskify/features/profile/widgets/tasks_metric_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              Text(AppLocalizations.of(context)!.noUserDataAvailable),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final authService = AuthService();
                  await authService.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                UsersProfileWidget(user: user),
                const SizedBox(height: 20),
                if (!user.isPremium)
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!.becomePremium,
                              ),
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.unlockPremiumFeaturesByUpgradingYourAccount,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Aquí puedes agregar la lógica para redirigir al usuario
                                    // a la página de pago o suscripción
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!.upgradeNow,
                                  ),
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
                const SizedBox(height: 20),
                const TasksMetricWidget(),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final authService = AuthService();
                    await authService.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
