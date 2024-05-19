import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  bool _isEmailValid = true;
  final _passwordController = TextEditingController();
  bool _isPasswordValid = true;
  final _confirmPasswordController = TextEditingController();
  bool _isConfirmPasswordValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 7, 27, 36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(overscroll: false),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    'Regístrate en\nBeatSleuth',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                const Text('Nombre',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey[700],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      hintText: 'Introduce tu nombre',
                      hintStyle: TextStyle(color: Colors.grey[300])),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Correo electrónico',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  onChanged: (text) {
                    _validateEmail();
                  },
                  style: TextStyle(
                      color: _isEmailValid ? Colors.white : Colors.red),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey[700],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Colors.transparent
                                  : Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isEmailValid
                                  ? Colors.transparent
                                  : Colors.red)),
                      hintText: 'Introduce tu correo electrónico',
                      hintStyle: TextStyle(color: Colors.grey[300])),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Contraseña',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  controller: _passwordController,
                  onChanged: (text) {
                    _validatePassword();
                  },
                  style: TextStyle(
                      color: _isPasswordValid ? Colors.white : Colors.red),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey[700],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isPasswordValid
                                  ? Colors.transparent
                                  : Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isPasswordValid
                                  ? Colors.transparent
                                  : Colors.red)),
                      hintText: 'Introduce tu contraseña',
                      hintStyle: TextStyle(color: Colors.grey[300])),
                ),
                const SizedBox(height: 5),
                Text(
                  'Min 1 mayús, 1 minús, 1 número, 1 carácter especial, 6 caracteres total',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Confirmar contraseña',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  controller: _confirmPasswordController,
                  onChanged: (text) {
                    _validateConfirmPassword();
                  },
                  style: TextStyle(
                      color: _isConfirmPasswordValid ? Colors.white : Colors.red),
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.blueGrey[700],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isConfirmPasswordValid
                                  ? Colors.transparent
                                  : Colors.red)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: _isConfirmPasswordValid
                                  ? Colors.transparent
                                  : Colors.red)),
                      hintText: 'Confirma tu contraseña',
                      hintStyle: TextStyle(color: Colors.grey[300])),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _registerUser(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 190, 131, 56),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'REGISTRARSE',
                          style: TextStyle(
                            color: Colors.grey[300]
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.grey[300]
                        ),
                      ]),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateEmail() {
    final email = _emailController.text;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{1,6}$');
    setState(() {
      if (email.isNotEmpty) {
        _isEmailValid = emailRegex.hasMatch(email);
      } else {
        _isEmailValid = true;
      }
    });
  }

  void _validatePassword() {
    final password = _passwordController.text;
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$');
    setState(() {
      _isPasswordValid = passwordRegex.hasMatch(password);
    });
  }

  void _validateConfirmPassword() {
    final confirmPassword = _confirmPasswordController.text;
    setState(() {
      _isConfirmPasswordValid = confirmPassword == _passwordController.text;
    });
  }

  void showCustomErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white), // Texto blanco para contrastar con el borde
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800], // Un fondo oscuro pero no totalmente negro
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.redAccent, width: 2), // Borde rojo para el mensaje de error
        ),
        margin: const EdgeInsets.only(bottom: 50, left: 15, right: 15),
      ),
    );
  }

  void showCustomSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white), // Texto blanco para contrastar con el borde
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800], // Un fondo oscuro pero no totalmente negro
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.greenAccent, width: 2), // Borde rojo para el mensaje de error
        ),
        margin: const EdgeInsets.only(bottom: 50, left: 15, right: 15),
      ),
    );
  }

  void _registerUser() async {
    if (_isEmailValid && _isPasswordValid && _isConfirmPasswordValid) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        showCustomSuccessSnackBar(context, 'Te has registrado correctamente');

        Navigator.pop(context);

      } on FirebaseAuthException catch (e) {
        String message = 'Ocurrió un error al registrar al usuario';
        if (e.code == 'weak-password') {
          message = 'La contraseña es muy débil';
        } else if (e.code == 'email-already-in-use') {
          message = 'El correo electrónico ya está en uso';
        }
        showCustomErrorSnackBar(context, message);
      } catch (e) {
        // Cualquier otro error
        showCustomErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    } else {
      showCustomErrorSnackBar(context, 'Por favor corrija los errores antes de continuar.');
    }
  }
}
