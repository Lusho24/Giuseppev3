import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  List<Map<String, String>> dataList = [
    {
      'cantidad': '54',
      'detalle': 'Sillas espaldar ratán modelo LuisXV',
      'observaciones': 'Con cojines limpios',
    },
    {
      'cantidad': '20',
      'detalle': 'Mesa rectangular de madera natural',
      'observaciones': 'LLegan a bodega',
    },
  ];

  Future<void> _createPdf() async{
    try{
      final arial = await loadFont('assets/fonts/arial.ttf');
      final arialN = await loadFont('assets/fonts/arial_negrita.ttf');
      final imageBytes = await loadImage('assets/images/logo.png');
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              children: [
                // - Encabezado
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FlexColumnWidth(1),
                  },
                  border: pw.TableBorder.all(width: 1),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          height: 100,
                          child: pw.Image(image, height: 70),
                        ),
                        pw.Table(
                          border: pw.TableBorder.all(width: 1),
                          children: [
                            pw.TableRow(
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 65,
                                      height: 12,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(width: 1, color: PdfColors.black),
                                      ),
                                      child: pw.Text("Proforma Nro.", style: pw.TextStyle(font: arial, fontSize: 9)),
                                    ),
                                    pw.Container(
                                      width: 100,
                                      height: 12,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(width: 1, color: PdfColors.black),
                                      ),
                                      child: pw.Text("00 - 260", style: pw.TextStyle(font: arialN, fontSize: 9)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 65,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(width: 1, color: PdfColors.black),
                                      ),
                                      child: pw.Text("Fecha", style: pw.TextStyle(font: arial, fontSize: 9)),
                                    ),
                                    pw.Container(
                                      width: 100,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(width: 1, color: PdfColors.black),
                                      ),
                                      child: pw.Text(widget.date, style: pw.TextStyle(font: arial, fontSize: 9)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Row(
                                  children: [
                                    pw.Container(
                                      width: 65,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(width: 1, color: PdfColors.black),
                                      ),
                                      child: pw.Text("Cliente", style: pw.TextStyle(font: arial, fontSize: 9)),
                                    ),
                                    pw.Container(
                                      width: 100,
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(width: 1, color: PdfColors.black),
                                      ),
                                      child: pw.Text(widget.name, style: pw.TextStyle(font: arial, fontSize: 9)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(5),
                                  alignment: pw.Alignment.center,
                                  child: pw.Text("GUÍA DE DESPACHO BODEGA", style: pw.TextStyle(font: arialN, fontSize: 9)),
                                )
                              ],
                            ),
                            pw.TableRow(
                              children: [
                                pw.Container(
                                  height: 50,
                                  alignment: pw.Alignment.center,
                                  child: pw.Text(
                                          "Matriz: Av. 6 de Diciembre N34-154 e Irlanda\n"
                                          "Edificio Atelier - Local N° 4\n"
                                          "0969051685 - 0985526565\n"
                                          "Quito - Ecuador",
                                      style: pw.TextStyle(font: arial, fontSize: 7),
                                    textAlign: pw.TextAlign.center
                                  ),
                                )

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
                  columnWidths: {
                    3: const pw.FixedColumnWidth(134.0),
                  },
                  border: pw.TableBorder.all(width: 1),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.symmetric(vertical: 1),
                          color: PdfColors.grey300,
                          child: pw.Text("Checklist", style: pw.TextStyle(font: arialN,fontSize: 9)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.symmetric(vertical: 1),
                          color: PdfColors.grey300,
                            child: pw.Text("Cantidad", style: pw.TextStyle(font: arialN,fontSize: 9)),
                        ),
                        pw.Container(
                          alignment: pw.Alignment.center,
                          padding: const pw.EdgeInsets.symmetric(vertical: 1),
                          color: PdfColors.grey300,
                            child: pw.Text("Detalle", style: pw.TextStyle(font: arialN,fontSize: 9)),
                        ),
                        pw.Container(
                            alignment: pw.Alignment.center,
                            padding: const pw.EdgeInsets.symmetric(vertical: 1),
                            color: PdfColors.grey300,
                            child: pw.Text("Observaciones - Para uso interno", style: pw.TextStyle(font: arialN,fontSize: 9))
                        )
                      ],
                    ),
                    // - items
                    ...dataList.map((item) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(1),
                            child: pw.Text("",style: pw.TextStyle(font: arial,fontSize: 9))
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(1),
                            alignment: pw.Alignment.center,
                            child: pw.Text(item['cantidad'] ?? '', style: pw.TextStyle(font: arial,fontSize: 9)),
                          ),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1),
                              child: pw.Text(item['detalle'] ?? '', style: pw.TextStyle(font: arial,fontSize: 9))
                          ),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1),
                              child: pw.Text(item['observaciones'] ?? '', style: pw.TextStyle(font: arial,fontSize: 9))
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                // - Datos
                pw.Spacer(),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FlexColumnWidth(2.5),
                  },
                  border: pw.TableBorder.all(width: 1),
                  children: [
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1.5),
                          child: pw.Text("Fecha de despacho:", style: pw.TextStyle(font: arialN, fontSize: 9)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(1.5),
                          child: pw.Text("Miercoles 16 de marzo 2022", style: pw.TextStyle(font: arial, fontSize: 9))
                        ),
                      ]
                    ),
                    pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Chofer:", style: pw.TextStyle(font: arialN, fontSize: 9))
                          ),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Patricio Quinchuqui", style: pw.TextStyle(font: arial, fontSize: 9))
                          ),
                        ]
                    ),
                    pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Lugar de entrega:", style: pw.TextStyle(font: arialN, fontSize: 9))
                          ),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Quinta el alcazar", style: pw.TextStyle(font: arial, fontSize: 9))
                          ),
                        ]
                    ),
                    pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Hora de entrega:", style: pw.TextStyle(font: arialN, fontSize: 9))
                          ),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("20:30", style: pw.TextStyle(font: arial, fontSize: 9))
                          ),
                        ]
                    ),
                    pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Recibe:", style: pw.TextStyle(font: arialN, fontSize: 9))
                          ),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Sr. Cristian Herrera", style: pw.TextStyle(font: arial, fontSize: 9))
                          ),
                        ]
                    ),
                    pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Responsable despacho:", style: pw.TextStyle(font: arialN, fontSize: 9))
                          ),
                          pw.Padding(
                              padding: const pw.EdgeInsets.all(1.5),
                              child: pw.Text("Luis Espinosa", style: pw.TextStyle(font: arial, fontSize: 9))
                          ),
                        ]
                    ),
                  ]
                ),

                // - Firmas
                pw.Column(
                  children: [
                    pw.SizedBox(height: 50),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          height: 1,
                          width: 110,
                          color: PdfColors.black,
                        ),
                        pw.SizedBox(width: 100),
                        pw.Container(
                          height: 1,
                          width: 110,
                          color: PdfColors.black,
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text("FIRMA EL DESPACHO", style: pw.TextStyle(font: arialN, fontSize: 9)),
                        pw.SizedBox(width: 120),
                        pw.Text("FIRMA EL INGRESO", style: pw.TextStyle(font: arialN, fontSize: 9)),
                      ],
                    ),
                  ],
                )
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
