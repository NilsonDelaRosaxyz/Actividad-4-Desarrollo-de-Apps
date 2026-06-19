import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/electrodomestico.dart';

class DetalleElectrodomesticoScreen extends StatefulWidget {
  final Electrodomestico electrodomestico;

  const DetalleElectrodomesticoScreen({super.key, required this.electrodomestico});

  @override
  State<DetalleElectrodomesticoScreen> createState() =>
      _DetalleElectrodomesticoScreenState();
}

class _DetalleElectrodomesticoScreenState
    extends State<DetalleElectrodomesticoScreen> {
  final DBHelper _dbHelper = DBHelper();
  double _tarifaKwh = 800.0;

  @override
  void initState() {
    super.initState();
    _cargarTarifa();
  }

  Future<void> _cargarTarifa() async {
    final tarifa = await _dbHelper.obtenerTarifaKwh();
    setState(() => _tarifaKwh = tarifa);
  }

  String _tipParaCategoria(String categoria) {
    switch (categoria) {
      case 'Climatización':
        return 'Sube el termostato 1-2°C y limpia los filtros regularmente; '
            'puede reducir el consumo hasta un 10%.';
      case 'Refrigeración':
        return 'Evita abrir la puerta innecesariamente y revisa que el sello '
            'de la puerta esté en buen estado.';
      case 'Cocina':
        return 'Usa tapas en las ollas y aprovecha el calor residual apagando '
            'antes de terminar la cocción.';
      case 'Entretenimiento':
        return 'Desconecta o usa regletas con interruptor para evitar el '
            'consumo en modo standby.';
      case 'Iluminación':
        return 'Cambia a bombillos LED si aún no lo has hecho; consumen hasta '
            '80% menos que los incandescentes.';
      default:
        return 'Reduce las horas de uso diario cuando sea posible para bajar '
            'su impacto en tu factura.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.electrodomestico;
    final consumo = e.consumoMensualKwh;
    final costo = e.costoMensual(_tarifaKwh);
    final co2 = e.co2MensualKg;

    return Scaffold(
      appBar: AppBar(
        title: Text(e.nombre),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(e.categoria,
                          style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _filaDato('Potencia', '${e.potenciaWatts.toStringAsFixed(0)} W'),
                  _filaDato('Uso diario', '${e.horasUsoDia} horas/día'),
                  const Divider(height: 28),
                  _filaDato('Consumo mensual', '${consumo.toStringAsFixed(2)} kWh',
                      destacado: true),
                  _filaDato('Costo estimado', '\$${costo.toStringAsFixed(0)} COP',
                      destacado: true),
                  _filaDato('Emisiones CO₂', '${co2.toStringAsFixed(2)} kg',
                      destacado: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco_outlined, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tip de ahorro',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(_tipParaCategoria(e.categoria)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filaDato(String label, String valor, {bool destacado = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            valor,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: destacado ? 16 : 14,
              color: destacado ? Colors.green.shade800 : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
