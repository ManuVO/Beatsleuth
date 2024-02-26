import 'package:flutter/material.dart';
import 'package:beatsleuth2/pages/wrapper_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  void _loginUser() async {
    try {
      /*
    await _firebaseService.loginUser(
      _emailController.text,
      _passwordController.text,
    );
    */
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Has iniciado sesión correctamente'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.only(bottom: 50, left: 15, right: 15),
        ),
      );
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => SafeArea(child: WrapperPage())),
          (Route<dynamic> route) => false);
    } catch (e) {
      // Ocurrió un error al registrar al usuario
      // Aquí puedes agregar código para manejar el error y mostrar un mensaje al usuario
    }
  }
}
