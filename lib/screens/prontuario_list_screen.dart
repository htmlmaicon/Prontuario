import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prontuario.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import 'formulario_prontuario_screen.dart';

class ProntuarioListScreen extends StatefulWidget {
  @override
  _ProntuarioListScreenState createState() => _ProntuarioListScreenState();
}

class _ProntuarioListScreenState extends State<ProntuarioListScreen> {
  final FirestoreService firestoreService = FirestoreService();
  final AuthService authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _logout(BuildContext context) async {
    try {
      await authService.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarProntuario(BuildContext context, Prontuario prontuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioProntuarioScreen(prontuario: prontuario),
      ),
    );
  }

  List<Prontuario> _filterProntuarios(List<Prontuario> prontuarios) {
    if (_searchQuery.isEmpty) {
      return prontuarios;
    }
    
    return prontuarios.where((prontuario) {
      return prontuario.paciente.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final User? user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Prontuários'),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Olá, ${user?.email?.split('@')[0] ?? 'Usuário'}',
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Pesquisar paciente',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Prontuario>>(
              stream: firestoreService.getProntuarios(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Erro ao carregar prontuários',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum prontuário cadastrado',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Clique no botão + para adicionar um prontuário',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final allProntuarios = snapshot.data!;
                final filteredProntuarios = _filterProntuarios(allProntuarios);

                // Mostrar mensagem se não encontrar resultados
                if (_searchQuery.isNotEmpty && filteredProntuarios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum paciente encontrado',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tente buscar por outro nome',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _clearSearch,
                          child: Text('Limpar pesquisa'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProntuarios.length,
                  itemBuilder: (context, index) {
                    final p = filteredProntuarios[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(
                          p.paciente,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(p.descricao),
                            SizedBox(height: 4),
                            Text(
                              'Data: ${p.data.day}/${p.data.month}/${p.data.year} ${p.data.hour}:${p.data.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editarProntuario(context, p),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteDialog(context, p),
                              tooltip: 'Excluir',
                            ),
                          ],
                        ),
                        onTap: () => _editarProntuario(context, p),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FormularioProntuarioScreen(),
          ),
        ),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Prontuario prontuario) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Prontuário'),
        content: Text('Tem certeza que deseja excluir o prontuário de ${prontuario.paciente}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              firestoreService.deletarProntuario(prontuario.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Prontuário excluído com sucesso'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}