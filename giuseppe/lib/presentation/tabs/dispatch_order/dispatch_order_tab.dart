import 'package:flutter/material.dart';

class DispatchOrderTab extends StatefulWidget {
  const DispatchOrderTab({super.key});

  @override
  State<DispatchOrderTab> createState() => _DispatchOrderTabState();
}

class _DispatchOrderTabState extends State<DispatchOrderTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(50.0),
          child: Text(" PAGINA DE GENERAR ORDENES"),
        ),
      ),
    );
  }
}
