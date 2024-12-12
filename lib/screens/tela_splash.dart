import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audi_mag/main.dart';

class TelaSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaInicial()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 150,
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(), // Adiciona um indicador de carregamento
          SizedBox(height: 10),
          Text(
            'Carregando...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
