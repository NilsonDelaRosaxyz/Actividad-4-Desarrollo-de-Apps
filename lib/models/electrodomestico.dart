class Electrodomestico {
  final int? id;
  final String nombre;
  final double potenciaWatts;
  final double horasUsoDia;
  final String categoria;
  final String fechaRegistro;

  Electrodomestico({
    this.id,
    required this.nombre,
    required this.potenciaWatts,
    required this.horasUsoDia,
    required this.categoria,
    required this.fechaRegistro,
  });

  // Consumo mensual en kWh: (W * h/dia * 30) / 1000
  double get consumoMensualKwh => (potenciaWatts * horasUsoDia * 30) / 1000;

  // Costo mensual estimado dado un valor de tarifa por kWh
  double costoMensual(double tarifaKwh) => consumoMensualKwh * tarifaKwh;

  // Emisiones de CO2 en kg, usando factor estandar de 0.233 kg CO2/kWh
  double get co2MensualKg => consumoMensualKwh * 0.233;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'potencia_watts': potenciaWatts,
      'horas_uso_dia': horasUsoDia,
      'categoria': categoria,
      'fecha_registro': fechaRegistro,
    };
  }

  factory Electrodomestico.fromMap(Map<String, dynamic> map) {
    return Electrodomestico(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      potenciaWatts: (map['potencia_watts'] as num).toDouble(),
      horasUsoDia: (map['horas_uso_dia'] as num).toDouble(),
      categoria: map['categoria'] as String,
      fechaRegistro: map['fecha_registro'] as String,
    );
  }

  Electrodomestico copyWith({
    int? id,
    String? nombre,
    double? potenciaWatts,
    double? horasUsoDia,
    String? categoria,
    String? fechaRegistro,
  }) {
    return Electrodomestico(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      potenciaWatts: potenciaWatts ?? this.potenciaWatts,
      horasUsoDia: horasUsoDia ?? this.horasUsoDia,
      categoria: categoria ?? this.categoria,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}
