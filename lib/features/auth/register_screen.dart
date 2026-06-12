import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _acceptedTerms = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_acceptedTerms) {
      setState(() {
        _errorMessage =
            'Datenschutz und Nutzungsbedingungen müssen akzeptiert werden.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.registerWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on UsernameTakenException {
      if (mounted) {
        setState(() {
          _errorMessage = 'Dieser Benutzername ist bereits vergeben.';
        });
      }
    } on FormatException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = error.message;
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = _getFirebaseAuthErrorMessage(error.code);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Registrierung fehlgeschlagen: $error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFirebaseAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Diese E-Mail-Adresse wird bereits verwendet.';
      case 'invalid-email':
        return 'Die E-Mail-Adresse ist ungültig.';
      case 'weak-password':
        return 'Das Passwort ist zu schwach. Es muss mindestens 6 Zeichen enthalten.';
      case 'operation-not-allowed':
        return 'E-Mail/Passwort-Login ist in Firebase noch nicht aktiviert.';
      case 'network-request-failed':
        return 'Netzwerkfehler. Die Internetverbindung sollte geprüft werden.';
      case 'user-not-created':
        return 'Der Nutzer konnte nicht erstellt werden.';
      default:
        return 'Firebase-Fehler: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konto erstellen'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Benutzername',
                    helperText: '3–20 Zeichen: a-z, 0-9, Punkt oder Unterstrich',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _register();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                    helperText: 'Mindestens 6 Zeichen',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                  title: const Text(
                    'Datenschutz und Nutzungsbedingungen akzeptieren',
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Registrieren'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}