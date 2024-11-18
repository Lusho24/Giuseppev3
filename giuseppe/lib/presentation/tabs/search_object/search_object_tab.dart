import 'package:flutter/material.dart';

class SearchObjectTab extends StatefulWidget {
  const SearchObjectTab({super.key});

  @override
  State<SearchObjectTab> createState() => _SearchObjectTabState();
}

class _SearchObjectTabState extends State<SearchObjectTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(50.0),
          child: Text(" PAGINA DE BUSCAR OBJETO"),
        ),
      ),
    );
  }
}
