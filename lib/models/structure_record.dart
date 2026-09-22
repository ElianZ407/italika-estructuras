class StructureRecord {
  final String id;
  final String folio;
  final DateTime fechaHora;
  final String tipoMovimiento; // Entrada Contenedor, Salida, Retorno a CEDIS
  final String economico;
  final String placa;
  final String numeroCarga;
  final String destino;
  final String operador;
  final String anden;

  // 5 Tipos de Estructuras solicitadas
  final int abatibles;
  final int normales;
  final int atvNormal;
  final int atvAbatible;
  final int cartonMadera;

  StructureRecord({
    required this.id,
    required this.folio,
    required this.fechaHora,
    required this.tipoMovimiento,
    required this.economico,
    required this.placa,
    this.numeroCarga = '',
    this.destino = '',
    this.operador = '',
    this.anden = '',
    this.abatibles = 0,
    this.normales = 0,
    this.atvNormal = 0,
    this.atvAbatible = 0,
    this.cartonMadera = 0,
  });

  int get totalEstructuras =>
      abatibles + normales + atvNormal + atvAbatible + cartonMadera;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folio': folio,
      'fechaHora': fechaHora.toIso8601String(),
      'tipoMovimiento': tipoMovimiento,
      'economico': economico,
      'placa': placa,
      'numeroCarga': numeroCarga,
      'destino': destino,
      'operador': operador,
      'anden': anden,
      'abatibles': abatibles,
      'normales': normales,
      'atvNormal': atvNormal,
      'atvAbatible': atvAbatible,
      'cartonMadera': cartonMadera,
      'totalEstructuras': totalEstructuras,
    };
  }

  factory StructureRecord.fromJson(Map<String, dynamic> json) {
    return StructureRecord(
      id: json['id'] as String,
      folio: json['folio'] as String? ?? 'S/F',
      fechaHora: DateTime.parse(json['fechaHora'] as String),
      tipoMovimiento: json['tipoMovimiento'] as String? ?? 'Entrada Contenedor',
      economico: json['economico'] as String? ?? '',
      placa: json['placa'] as String? ?? '',
      numeroCarga: json['numeroCarga'] as String? ?? '',
      destino: json['destino'] as String? ?? '',
      operador: json['operador'] as String? ?? '',
      anden: json['anden'] as String? ?? '',
      abatibles: (json['abatibles'] as num?)?.toInt() ?? 0,
      normales: (json['normales'] as num?)?.toInt() ?? 0,
      atvNormal: (json['atvNormal'] as num?)?.toInt() ?? 0,
      atvAbatible: (json['atvAbatible'] as num?)?.toInt() ?? 0,
      cartonMadera: (json['cartonMadera'] as num?)?.toInt() ?? 0,
    );
  }
}
