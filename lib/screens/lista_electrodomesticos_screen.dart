import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/electrodomestico.dart';
import 'detalle_electrodomestico_screen.dart';

class ListaElectrodomesticosScreen extends StatefulWidget {
  const ListaElectrodomesticosScreen({super.key});

  @override
  State<ListaElectrodomesticosScreen> createState() =>
      _ListaElectrodomesticosScreenState();
}

class _ListaElectrodomesticosScreenState
    extends State<ListaElectrodomesticosScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Electrodomestico> _lista = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final datos = await _dbHelper.obtenerElectrodomesticos();
    setState(() {
      _lista = datos;
      _cargando = false;
    });
  }

  Future<void> _mostrarFormulario({Electrodomestico? existente}) async {
    final nombreCtrl = TextEditingController(text: existente?.nombre ?? '');
    final potenciaCtrl =
        TextEditingController(text: existente?.potenciaWatts.toString() ?? '');
    final horasCtrl =
        TextEditingController(text: existente?.horasUsoDia.toString() ?? '');
    String categoria = existente?.categoria ?? 'Cocina';

    final categorias = [
      'Cocina',
      'Refrigeración',
      'Climatización',
      'Entretenimiento',
      'Iluminación',
      'Otro'
    ];

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      existente == null
                          ? 'Nuevo electrodoméstico'
                          : 'Editar electrodoméstico',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: nombreCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ej: Nevera, Aire acondicionado',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: potenciaCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Potencia (vatios)',
                        hintText: 'Ej: 150',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0) return 'Valor inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: horasCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Horas de uso por día',
                        hintText: 'Ej: 5',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        final n = double.tryParse(v);
                        if (n == null || n <= 0 || n > 24) {
                          return 'Debe estar entre 0 y 24';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: categoria,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        border: OutlineInputBorder(),
                      ),
                      items: categorias
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setModalState(() => categoria = v!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final nuevo = Electrodomestico(
                            id: existente?.id,
                            nombre: nombreCtrl.text.trim(),
                            potenciaWatts: double.parse(potenciaCtrl.text),
                            horasUsoDia: double.parse(horasCtrl.text),
                            categoria: categoria,
                            fechaRegistro: existente?.fechaRegistro ??
                                DateTime.now().toIso8601String(),
                          );

                          if (existente == null) {
                            await _dbHelper.insertarElectrodomestico(nuevo);
                          } else {
                            await _dbHelper.actualizarElectrodomestico(nuevo);
                          }

                          if (ctx.mounted) Navigator.pop(ctx);
                          _cargar();
                        },
                        child: Text(existente == null ? 'Guardar' : 'Actualizar'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmarEliminar(Electrodomestico e) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar electrodoméstico'),
        content: Text('¿Eliminar "${e.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmado == true && e.id != null) {
      await _dbHelper.eliminarElectrodomestico(e.id!);
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis electrodomésticos'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _lista.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No tienes electrodomésticos registrados.\nToca el botón + para agregar el primero.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _lista.length,
                  itemBuilder: (ctx, i) {
                    final e = _lista[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetalleElectrodomesticoScreen(electrodomestico: e),
                            ),
                          );
                          _cargar();
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.bolt, color: Colors.green.shade700),
                        ),
                        title: Text(e.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            '${e.categoria} · ${e.potenciaWatts.toStringAsFixed(0)} W · ${e.horasUsoDia} h/día'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${e.consumoMensualKwh.toStringAsFixed(1)} kWh',
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _mostrarFormulario(existente: e),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red),
                              onPressed: () => _confirmarEliminar(e),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
