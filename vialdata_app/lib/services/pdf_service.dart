import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/remito_model.dart';
import '../models/informe_diario_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateAndShareRemito(RemitoModel remito) async {
    final pdf = pw.Document();
    final logoPath = 'assets/logo.jpg';
    final logoImage = pw.MemoryImage(
      (await rootBundle.load(logoPath)).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('REMITO DE CARGA',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Image(logoImage, height: 60),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Número: ${remito.nroRemito}'),
              pw.Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(remito.fecha)}'),
              pw.Text('Obra: ${remito.nombreObra}'),
              pw.Divider(),
              pw.Text('Guía: ${remito.nroGuia}'),
              pw.Text('Procedencia: ${remito.procedencia}'),
              pw.Text('Destino: ${remito.destino}'),
              pw.Text('Material: ${remito.material}'),
              pw.Text('Cantidad: ${remito.cantidad}'),
              pw.Text('Recibidor: ${remito.recibidor}'),
              pw.SizedBox(height: 10),
              pw.Text('Transporte:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Empresa: ${remito.empresaTransportista}'),
              pw.Text('Patente Camión: ${remito.patenteCamion}'),
              pw.Text('Patente Acoplado: ${remito.patenteAcoplado}'),
              pw.Text('Chofer: ${remito.chofer}'),
              pw.SizedBox(height: 20),
              pw.Text('Observaciones: ${remito.observaciones}'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'remito_${remito.nroRemito}.pdf');
  }

  static Future<void> generateAndShareInforme(
      InformeDiarioModel informe) async {
    final pdf = pw.Document();
    final logoPath = 'assets/logo.jpg';
    final logoImage = pw.MemoryImage(
      (await rootBundle.load(logoPath)).buffer.asUint8List(),
    );

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('INFORME DIARIO',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Image(logoImage, height: 60),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Obra: ${informe.nombreObra}'),
              pw.Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(informe.fecha)}'),
              pw.Divider(),
              pw.Text('Horas Máquina: ${informe.horasMaquina}'),
              pw.Text('Km Recorridos: ${informe.kmRecorridos}'),
              pw.SizedBox(height: 10),
              pw.Text('Actividades:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(informe.actividades),
              pw.SizedBox(height: 10),
              pw.Text('Avance:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(informe.avanceDescripcion),
              pw.SizedBox(height: 10),
              pw.Text('Personal:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(informe.personal),
              pw.SizedBox(height: 10),
              pw.Text('Equipos:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(informe.equipos),
              pw.SizedBox(height: 10),
              pw.Text('Incidencias:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(informe.incidencias ?? '-'),
              pw.SizedBox(height: 10),
              pw.Text('Observaciones:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(informe.comentariosAdicionales ?? '-'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'informe_${DateFormat('ddMMyyyy').format(informe.fecha)}.pdf');
  }
}
