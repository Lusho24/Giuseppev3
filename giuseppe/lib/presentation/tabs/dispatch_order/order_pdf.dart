import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giuseppe/utils/theme/app_colors.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:developer' as dev;



class OrderPdf extends StatefulWidget {
  final String name;
  final String date;
  final String link;

  const OrderPdf({
    required this.name,
    required this.date,
    required this.link,
    super.key
  });

  @override
  State<OrderPdf> createState() => _OrderPdfState();
}

class _OrderPdfState extends State<OrderPdf> {
  final pdf = pw.Document();

  Future<void> _createPdf() async{
    try{
      final arial = await loadFont('assets/fonts/arial.ttf');
      final imageBytes = await loadImage('assets/images/logo.png');
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // - Encabezado
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Center(
                          child: pw.Image(image, height: 100),
                        ),
                        pw.Table(
                          border: pw.TableBorder.all(width: 1),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Text('Proforma', style: pw.TextStyle(font: arial)),
                                pw.Text('00', style: pw.TextStyle(font: arial)),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Text('Fecha', style: pw.TextStyle(font: arial)),
                                pw.Text('HOY', style: pw.TextStyle(font: arial)),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Text('Cliente', style: pw.TextStyle(font: arial)),
                                pw.Text('Fila 3', style: pw.TextStyle(font: arial)),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Text(' GUÍA DE DESPACHO BODEGA', style: pw.TextStyle(font: arial)),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Text(' GUÍA DE DESPACHO BODEGA', style: pw.TextStyle(font: arial)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // - Detalles
                pw.Table(
                  border: pw.TableBorder.all(width: 1),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          color: PdfColors.grey300,
                          child: pw.Text('Checklist', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          color: PdfColors.grey300,
                            child: pw.Text('Cantidad', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          color: PdfColors.grey300,
                            child: pw.Text('Detalle', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Container(
                            alignment: pw.Alignment.center,
                            color: PdfColors.grey300,
                            child: pw.Text('Observaciones - Para uso interno', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                        )
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Text(''),
                        pw.Align(
                          alignment: pw.Alignment.center,
                          child: pw.Text('54')
                        ),
                        pw.Text('Sillas espaldar ratán modelo LuisXV'),
                        pw.Text('Con cojines limpios'),
                      ],
                    ),
                  ],
                ),
                // - Datos

                // - Firmas

              ],
            );
          }
      ));
      dev.log(" * Pdf generado");
    } catch (e){
      dev.log(" ** Error al generar el pdf: $e");
    }
  }

  Future<pw.Font> loadFont(String path) async {
    final ttf = await rootBundle.load(path);
    return pw.Font.ttf(ttf);
  }

  Future<Uint8List> loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  @override
  void initState() {
    _createPdf();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PdfPreview(
        build: (format) => pdf.save(),
        allowSharing: true,
        canChangePageFormat: false,
      )
    );
  }
}
