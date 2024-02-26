import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> registerUser(String name, String email, String password) async {
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (newUser != null) {
        // El registro fue exitoso
        // Guardar el nombre del usuario en Firestore
        await _firestore.collection('users').doc(newUser.user?.uid).set({
          'name': name,
        });
      }
    } catch (e) {
      // Ocurrió un error al registrar al usuario
      // Aquí puedes agregar código para manejar el error y mostrar un mensaje al usuario
      rethrow;
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user != null) {
        // El inicio de sesión fue exitoso
        // Aquí puedes agregar código para navegar a otra página o realizar otras acciones
      }
    } catch (e) {
      // Ocurrió un error al iniciar sesión
      // Aquí puedes agregar código para manejar el error y mostrar un mensaje al usuario
      rethrow;
    }
  }

  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
      // El cierre de sesión fue exitoso
      // Aquí puedes agregar código para navegar a otra página o realizar otras acciones
    } catch (e) {
      // Ocurrió un error al cerrar sesión
      // Aquí puedes agregar código para manejar el error y mostrar un mensaje al usuario
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      // Se envió el correo electrónico para restablecer la contraseña
      // Aquí puedes agregar código para mostrar un mensaje al usuario o realizar otras acciones
    } catch (e) {
      // Ocurrió un error al enviar el correo electrónico para restablecer la contraseña
      // Aquí puedes agregar código para manejar el error y mostrar un mensaje al usuario
      rethrow;
    }
  }
}
