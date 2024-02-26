import 'package:flutter/material.dart';
import 'package:beatsleuth2/pages/login_page.dart';
import 'package:beatsleuth2/pages/signup_page.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:page_transition/page_transition.dart';

class DefaultPage extends StatefulWidget {
  @override
  _DefaultPageState createState() => _DefaultPageState();
}

class _DefaultPageState extends State<DefaultPage> {
  @override
  void initState() {
    super.initState();
    // Desenfoca cualquier campo de texto activo y cierra el teclado
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FocusScope.of(context).unfocus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 7, 27, 36),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: WaveWidget(
                config: CustomConfig(
                  gradients: [
                    [
                      const Color.fromARGB(255, 09, 39, 058),
                      const Color.fromARGB(255, 05, 20, 15)
                    ],
                    [
                      const Color.fromARGB(255, 29, 59, 078),
                      const Color.fromARGB(255, 10, 30, 30)
                    ],
                    [
                      const Color.fromARGB(255, 49, 79, 098),
                      const Color.fromARGB(255, 15, 40, 45)
                    ],
                    [
                      const Color.fromARGB(255, 69, 99, 118),
                      const Color.fromARGB(255, 20, 50, 60)
                    ]
                  ],
                  durations: [35000, 19440, 10800, 6000],
                  heightPercentages: [0.50, 0.54, 0.57, 0.60],
                  blur: const MaskFilter.blur(BlurStyle.solid, 10),
                  gradientBegin: Alignment.bottomLeft,
                  gradientEnd: Alignment.topRight,
                ),
                waveAmplitude: 0,
                size: const Size(double.infinity, double.infinity)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¡Bienvenido!',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 50),
                Image.asset('assets/images/logoSinFondov1.png',
                    width: 150, height: 150),
                const SizedBox(height: 20),
                Text(
                  'BeatSleuth',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 60),
                Text('Encuentra tus\nCanciones favoritas.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            duration: const Duration(milliseconds: 200),
                            child: SafeArea(child: SignupPage())));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 190, 131, 56),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  child: const Text('REGÍSTRATE GRATIS'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.leftToRight,
                            duration: const Duration(milliseconds: 200),
                            child: SafeArea(child: LoginPage())));
                  },
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.white)),
                      textStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  child: const Text('INICIA SESIÓN'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
