import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.loginWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = _getFirebaseAuthErrorMessage(error.code);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login fehlgeschlagen: $error';
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

  Future<void> _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithGoogle();
    } on UsernameTakenException {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Für dieses Google-Konto konnte kein eindeutiger Benutzername erstellt werden.';
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = _getGoogleAuthErrorMessage(error.code);
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Google-Login fehlgeschlagen: $error';
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
      case 'invalid-email':
        return 'Die E-Mail-Adresse ist ungültig.';
      case 'user-disabled':
        return 'Dieses Nutzerkonto wurde deaktiviert.';
      case 'user-not-found':
        return 'Es wurde kein Konto mit dieser E-Mail-Adresse gefunden.';
      case 'wrong-password':
        return 'Das Passwort ist falsch.';
      case 'invalid-credential':
        return 'E-Mail oder Passwort ist falsch.';
      case 'network-request-failed':
        return 'Netzwerkfehler. Die Internetverbindung sollte geprüft werden.';
      default:
        return 'Firebase-Fehler: $code';
    }
  }

  String _getGoogleAuthErrorMessage(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Für diese E-Mail-Adresse existiert bereits ein Konto mit einer anderen Anmeldemethode.';
      case 'invalid-credential':
        return 'Die Google-Anmeldedaten sind ungültig.';
      case 'operation-not-allowed':
        return 'Google-Login ist in Firebase noch nicht aktiviert.';
      case 'popup-closed-by-user':
        return 'Das Google-Login-Fenster wurde geschlossen.';
      case 'cancelled-popup-request':
        return 'Der Google-Login wurde abgebrochen.';
      case 'network-request-failed':
        return 'Netzwerkfehler. Die Internetverbindung sollte geprüft werden.';
      default:
        return 'Google-Login fehlgeschlagen: $code';
    }
  }

  void _openRegisterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'StyleLeague',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Einloggen und Outfits bewerten',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 32),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
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
                  enabled: !_isLoading,
                  onSubmitted: (_) {
                    if (!_isLoading) {
                      _loginWithEmail();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Passwort',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _loginWithEmail,
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Einloggen'),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'oder',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: const Icon(Icons.login),
                    label: const Text('Mit Google anmelden'),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: _isLoading ? null : _openRegisterScreen,
                  child: const Text('Noch kein Konto? Jetzt registrieren'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}