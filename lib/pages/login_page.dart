import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beatsleuth2/pages/wrapper_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Asegúrate de limpiar los controladores cuando se deshaga el Widget
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const Center(
                child: Text(
                  'Inicia sesión',
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
              const Text(
                'Correo electrónico',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    hintText: 'Introduce tu correo electrónico',
                    hintStyle: TextStyle(color: Colors.grey[300])),
              ),
              const SizedBox(height: 20),
              const Text('Contraseña',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 10),
              TextField(
                obscureText: true,
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.blueGrey[700],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    hintText: 'Introduce tu contraseña',
                    hintStyle: TextStyle(color: Colors.grey[300])),
              ),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                  onPressed: () {},
                  //style: TextButton.styleFrom(backgroundColor: Colors.grey),
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: Colors.grey[300]
                    ),
                  )
                )
              ]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loginUser(),
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
                        'INICIAR SESIÓN', 
                        style: TextStyle(
                          color: Colors.grey[300]
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.grey[300]
                      )
                    ]),
              )
            ],
          ),
        ),
      ),
    );
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

  void _loginUser() async {
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        showCustomErrorSnackBar(context, 'Correo electrónico y contraseña no pueden estar vacíos');
        return;
      }

      // Usa FirebaseAuth para iniciar sesión con el correo electrónico y contraseña proporcionados
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si el inicio de sesión es exitoso, muestra un SnackBar y redirige al usuario
      showCustomSuccessSnackBar(context, 'Has iniciado sesión correctamente');
      

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => SafeArea(child: WrapperPage())),
        (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // Aquí puedes personalizar el mensaje basado en el código de error de FirebaseAuth
      String errorMessage = 'Error desconocido';
      if (e.code == 'user-not-found') {
        errorMessage = 'No se encontró el usuario';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Contraseña incorrecta';
      }
      // Usa el método personalizado para mostrar el SnackBar
      showCustomErrorSnackBar(context, errorMessage);
    } catch (e) {
      // Cualquier otro error
      showCustomErrorSnackBar(context, 'Error: ${e.toString()}');
    }
  }
}
