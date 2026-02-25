import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/remito_model.dart';
import '../models/informe_diario_model.dart';
import 'package:intl/intl.dart';

class PdfService {
  static const logoPath = 'assets/logo.jpg';

  // --- GENERAR PDF PARA REMITO ---
  static Future<void> generateAndShareRemito(RemitoModel remito) async {
    final pdf = pw.Document();
    final netImage = await imageFromAssetBundle(logoPath);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('REMITO DE TRANSPORTE',
                      style: pw.TextStyle(
                          fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Image(netImage, width: 80),
                ],
              ),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Nro Remito: ${remito.nroRemito}'),
              pw.Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy').format(remito.fecha)}'),
              pw.Text('Obra: ${remito.nombreObra}'),
              pw.SizedBox(height: 20),
              pw.Text('DETALLES DEL TRANSPORTE',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Chofer: ${remito.chofer}'),
              pw.Text('Camión: ${remito.patenteCamion}'),
              pw.Text('Acoplado: ${remito.patenteAcoplado}'),
              pw.SizedBox(height: 20),
              pw.Text('MATERIAL: ${remito.material}'),
              pw.Text('CANTIDAD: ${remito.cantidad}'),
              pw.SizedBox(height: 30),
              pw.Text(
                  'Observaciones: ${remito.observaciones.isEmpty ? '-' : remito.observaciones}'),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(), filename: 'remito_${remito.nroRemito}.pdf');
  }

  // --- GENERAR PDF PARA INFORME DIARIO ---
  static Future<void> generateAndShareInforme(
      InformeDiarioModel informe) async {
    final pdf = pw.Document();
    final netImage = await imageFromAssetBundle(logoPath);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('INFORME DIARIO DE OBRA',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Nro: ${informe.numeroInforme}',
                        style: const pw.TextStyle(fontSize: 14)),
                    pw.Text(
                        'Fecha: ${DateFormat('dd/MM/yyyy').format(informe.fecha)}'),
                  ],
                ),
                pw.Image(netImage, width: 70),
              ],
            ),
            pw.Divider(),
            pw.SizedBox(height: 10),
            pw.Text('Obra: ${informe.nombreObra}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Contratante: ${informe.senorOEmpresaContratante}'),
            pw.SizedBox(height: 15),

            // MÁQUINAS
            if (informe.maquinas.isNotEmpty) ...[
              pw.Text('MÁQUINAS:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Máquina', 'Chofer', 'Inicio', 'Fin'],
                  ...informe.maquinas.map(
                      (m) => [m.maquina, m.chofer, m.horaInicio, m.horaFinal]),
                ],
              ),
              pw.SizedBox(height: 10),
            ],

            // MATERIALES
            if (informe.materiales.isNotEmpty) ...[
              pw.Text('MATERIALES:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Material', 'Cantidad', 'Unidad'],
                  ...informe.materiales.map(
                      (m) => [m.material, m.cantidad.toString(), m.unidad]),
                ],
              ),
              pw.SizedBox(height: 10),
            ],

            // OTROS EQUIPOS
            if (informe.otrosEquipos.isNotEmpty) ...[
              pw.Text('OTROS EQUIPOS:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Equipo', 'Inicio', 'Fin'],
                  ...informe.otrosEquipos
                      .map((e) => [e.equipo, e.horaInicio, e.horaFinal]),
                ],
              ),
              pw.SizedBox(height: 10),
            ],

            // CAMIONES
            if (informe.camionesVolcadoras.isNotEmpty) ...[
              pw.Text('CAMIONES VOLCADORAS:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'Cap.',
                    'Marca',
                    'Matrícula',
                    'Chofer',
                    'Viajes',
                    'Hs'
                  ],
                  ...informe.camionesVolcadoras.map((c) => [
                        c.capacidad,
                        c.marca,
                        c.matricula,
                        c.chofer,
                        c.viajes.toString(),
                        c.horas.toString()
                      ]),
                ],
              ),
              pw.SizedBox(height: 10),
            ],

            // PEONES
            if (informe.peonesAyudantes.isNotEmpty) ...[
              pw.Text('PERSONAL (AUXILIARES):',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Nombre', 'Horas'],
                  ...informe.peonesAyudantes
                      .map((p) => [p.nombre, p.horas.toString()]),
                ],
              ),
              pw.SizedBox(height: 10),
            ],

            pw.SizedBox(height: 20),
            pw.Text('OBSERVACIONES:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(informe.observaciones.isEmpty
                ? 'Sin observaciones.'
                : informe.observaciones),
          ];
        },
      ),
    );

    await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'informe_${informe.numeroInforme}.pdf');
  }
}
