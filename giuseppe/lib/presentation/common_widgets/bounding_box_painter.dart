import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class BoundingBoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> results;
  final double imageWidth;
  final double imageHeight;
  final double screenWidth;
  final double screenHeight;

  BoundingBoxPainter(this.results, this.imageWidth, this.imageHeight, this.screenWidth, this.screenHeight);


  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      color: Colors.blueAccent,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    );

    // Calcula la escala entre las dimensiones de la imagen y la pantalla
    final double scaleX = screenWidth / imageHeight;
    final double scaleY = screenHeight / imageWidth;

    dev.log(" -- Tamaño pantalla:    w:$screenWidth    h:$screenHeight");
    dev.log(" -- Tamaño imagen:    w:$imageWidth    h:$imageHeight ");

    for (var result in results) {
      // Extrae las coordenadas de la caja
      final left = result['box'][0].toDouble() * scaleX;
      final top = result['box'][1].toDouble() * scaleY;
      final right = (result['box'][2].toDouble()) * scaleX;
      final bottom = (result['box'][3].toDouble()) * scaleY;

      // Dibuja el rectángulo (bounding box) escalado
      canvas.drawRect(
        Rect.fromLTRB(left, top, right, bottom),
        paint,
      );

      // Dibuja la etiqueta
      final textSpan = TextSpan(text: result['tag'], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(left, top - 14)); // Posiciona el texto
    }

  }



  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repite la pintura cuando cambian los resultados
  }
}
