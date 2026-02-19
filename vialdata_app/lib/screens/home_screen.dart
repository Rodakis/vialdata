import 'admin_obras_screen.dart';
import 'package:flutter/material.dart';
import '../models/obra_model.dart';
import '../services/auth_service.dart';
import 'remito_form_screen.dart';
import 'informe_diario_form_screen.dart';
import 'admin_users_screen.dart';
import 'admin_lists_screen.dart';
import 'login_screen.dart';
import 'history_screen.dart';
import '../services/storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ObraModel? selectedObra;
  List<ObraModel> obras = []; // Lista vacía al inicio

@override
void initState() {
  super.initState();
  _cargarObras();  // carga las obras reales al abrir la app
}

// Esta función recarga la lista cada vez que entras a la pantalla
Future<void> _cargarObras() async {
  final lista = await StorageService.getObras();
  setState(() {
    obras = lista;
    // Si la obra seleccionada ya no existe, la reseteamos
    if (selectedObra != null && !obras.any((o) => o.id == selectedObra!.id)) {
      selectedObra = null;
    }
  });
}

  void _logout() {
    AuthService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('VialData - Campo'),
            Text('Usuario: ${AuthService.currentUser?.username}', style: const TextStyle(fontSize: 12)),
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Ver Registros',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView( // Agregado por si la pantalla es chica
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- PANEL ADMINISTRADOR (Solo visible si es admin) ---
              if (AuthService.isAdmin) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('PANEL ADMINISTRADOR', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      const SizedBox(height: 10),
                      
                      // BOTÓN 1: USUARIOS
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red, 
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40)
                        ),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Gestionar Usuarios (Personas)'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminUsersScreen()));
                        },
                      ),

                      const SizedBox(height: 10),

                      // BOTÓN 3: GESTIONAR OBRAS
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade900,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 40)
                            ),
                            icon: const Icon(Icons.business),
                            label: const Text('Gestionar Proyectos / Obras'),
                            onPressed: () async {
                              // Usamos await para que al volver recargue la lista
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminObrasScreen()));
                              _cargarObras(); // <--- Recargar al volver
                            },
                          ),

                      // BOTÓN 2: LISTAS
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 40)
                        ),
                        icon: const Icon(Icons.list),
                        label: const Text('Gestionar Listas (Materiales/Empresas)'),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminListsScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ],

              // --- BOTÓN HISTORIAL (ACCESO RÁPIDO) ---
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  side: BorderSide(color: Colors.blueGrey.shade200),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
                },
                icon: const Icon(Icons.list_alt, color: Colors.blueGrey),
                label: const Text('VER MIS REGISTROS GUARDADOS', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 20),

              const Text(
                '1. Seleccionar Obra', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 10),
              
              DropdownButtonFormField<ObraModel>(
                value: selectedObra,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
                hint: const Text('¿En qué obra estás hoy?'),
                items: obras.map((obra) {
                  return DropdownMenuItem(
                    value: obra,
                    child: Text(obra.nombre, style: const TextStyle(fontWeight: FontWeight.w500)),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedObra = val;
                  });
                },
              ),

              const SizedBox(height: 20),

              if (selectedObra != null) ...[
                const Text(
                  '2. ¿Qué vas a registrar?', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 20),
                
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 70),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RemitoFormScreen(obra: selectedObra!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.local_shipping, size: 30),
                  label: const Text('NUEVO REMITO', style: TextStyle(fontSize: 18)),
                ),
                
                const SizedBox(height: 15),
                
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 70),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformeDiarioFormScreen(obra: selectedObra!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment, size: 30),
                  label: const Text('INFORME DIARIO', style: TextStyle(fontSize: 18)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}