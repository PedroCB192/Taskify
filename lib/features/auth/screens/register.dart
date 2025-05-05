import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/features/auth/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Controllers
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController =
      TextEditingController(); // Nuevo controller para username
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose(); // No olvidar limpiar este también
    super.dispose();
  }

  // Register function
  // Función de registro mejorada
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user = await _auth.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _usernameController.text.trim(), // Pasamos el username
      );

      if (user != null) {
        // Registro exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.accountCreatedSuccessfully,
            ),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pushReplacementNamed('/tasks');
      }
    } on FirebaseAuthException catch (e) {
      String message = AppLocalizations.of(context)!.errorToRegister;
      switch (e.code) {
        case 'email-already-in-use':
          message = AppLocalizations.of(context)!.theEmailIsAlreadyInUse;
          break;
        case 'invalid-email':
          message = AppLocalizations.of(context)!.formatOfEmailIsInvalid;
          break;
        case 'weak-password':
          // The password
          message =
              AppLocalizations.of(
                context,
              )!.thePasswordMustBeAtLeast6CharactersLong;
          break;
        case 'operation-not-allowed':
          message = AppLocalizations.of(context)!.operationNotAllowed;
          break;
        default:
          message = 'An unexpected error occurred: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  'Taskify',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.roseBonbon,
                  ),
                ),
                const SizedBox(height: 40),
                // Campo de Username (nuevo)
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.username,
                  ),
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      )!.pleaseEnterYourUsername;
                    }
                    if (value.length < 4) {
                      return AppLocalizations.of(
                        context,
                      )!.theUsernameMustBeAtLeast4Characters;
                    }
                    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                      return AppLocalizations.of(
                        context,
                      )!.onlyLettersNumbersAndUnderscoresAreAllowed;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.email,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterYourEmail;
                    }
                    if (!RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(value)) {
                      return AppLocalizations.of(
                        context,
                      )!.pleaseEnterAValidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.password,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(
                        context,
                      )!.pleaseEnterYourPassword;
                    }
                    if (value.length < 6) {
                      return AppLocalizations.of(
                        context,
                      )!.passwordMustBeAtLeast6Characters;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _register,
                        child:
                            _isLoading
                                ? const CircularProgressIndicator()
                                : Text(
                                  AppLocalizations.of(context)!.createAccount,
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
