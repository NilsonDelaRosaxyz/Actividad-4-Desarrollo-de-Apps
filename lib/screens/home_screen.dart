import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/electrodomestico.dart';
import 'lista_electrodomesticos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Electrodomestico> _electrodomesticos = [];
  double _tarifaKwh = 800.0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final lista = await _dbHelper.obtenerElectrodomesticos();
    final tarifa = await _dbHelper.obtenerTarifaKwh();
    setState(() {
      _electrodomesticos = lista;
      _tarifaKwh = tarifa;
      _cargando = false;
    });
  }

  double get _consumoTotalKwh =>
      _electrodomesticos.fold(0.0, (sum, e) => sum + e.consumoMensualKwh);

  double get _costoTotal => _consumoTotalKwh * _tarifaKwh;

  double get _co2Total =>
      _electrodomesticos.fold(0.0, (sum, e) => sum + e.co2MensualKg);

  Electrodomestico? get _mayorConsumo {
    if (_electrodomesticos.isEmpty) return null;
    return _electrodomesticos.reduce(
      (a, b) => a.consumoMensualKwh > b.consumoMensualKwh ? a : b,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EcoWatt'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarDatos,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _tarjetaResumen(),
                  const SizedBox(height: 16),
                  if (_mayorConsumo != null) _tarjetaTip(),
                  const SizedBox(height: 16),
                  Text(
                    'Electrodomésticos registrados: ${_electrodomesticos.length}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ListaElectrodomesticosScreen(),
            ),
          );
          _cargarDatos();
        },
        icon: const Icon(Icons.list),
        label: const Text('Mis electrodomésticos'),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  Widget _tarjetaResumen() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consumo total del hogar (mensual)',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '${_consumoTotalKwh.toStringAsFixed(1)} kWh',
              style: const TextStyle(
                  fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _metricaMini(
                    Icons.attach_money, 'Costo estimado',
                    '\$${_costoTotal.toStringAsFixed(0)} COP'),
                _metricaMini(
                    Icons.cloud_outlined, 'CO₂ generado',
                    '${_co2Total.toStringAsFixed(1)} kg'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricaMini(IconData icon, String label, String valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 4),
        Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _tarjetaTip() {
    final e = _mayorConsumo!;
    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${e.nombre} es tu mayor consumidor (${e.consumoMensualKwh.toStringAsFixed(1)} kWh/mes). '
                'Reducir su uso diario es la forma más rápida de bajar tu consumo total.',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
