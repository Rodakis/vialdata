import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String _selectedRole = 'operario';

  void _createUser() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete todos los campos')));
      return;
    }

    bool success = await AuthService.createUser(
      _userController.text.trim(),
      _passController.text.trim(),
      _selectedRole
    );

    if (!mounted) return;

    if (success) {
      _userController.clear();
      _passController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario creado!'), backgroundColor: Colors.green));
      setState(() {}); // Refrescar lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El usuario ya existe'), backgroundColor: Colors.red));
    }
  }

  void _deleteUser(String username) async {
    if (username == 'admin') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No puedes borrar al Admin principal')));
      return;
    }
    
    await AuthService.deleteUser(username);
    if (!mounted) return;
    setState(() {}); // Refrescar lista
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario eliminado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: Column(
        children: [
          // --- FORMULARIO DE CREACIÓN ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('NUEVO USUARIO', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _userController, decoration: const InputDecoration(labelText: 'Usuario'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _passController, decoration: const InputDecoration(labelText: 'Contraseña'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedRole,
                            decoration: const InputDecoration(labelText: 'Rol', contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                            items: const [
                              DropdownMenuItem(value: 'operario', child: Text('Operario')),
                              DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                            ],
                            onChanged: (val) => setState(() => _selectedRole = val!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _createUser,
                          child: const Text('CREAR'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          const Divider(thickness: 2),

          // --- LISTA DE USUARIOS EXISTENTES ---
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('USUARIOS ACTIVOS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          
          Expanded(
            child: FutureBuilder<List<UserModel>>(
              future: AuthService.getAllUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: user.role == 'admin' ? Colors.red : Colors.blue,
                        child: Icon(user.role == 'admin' ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                      ),
                      title: Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Rol: ${user.role}  |  Clave: ${user.password}'), 
                      trailing: user.username == 'admin' 
                        ? null 
                        : IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteUser(user.username),
                          ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
