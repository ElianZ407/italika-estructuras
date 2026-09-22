import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/structure_record.dart';
import '../services/storage_service.dart';
import '../widgets/structure_counter_card.dart';
import 'barcode_scanner_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  final StorageService _storageService = StorageService();

  // Movimiento
  String _tipoMovimiento = 'Entrada Contenedor';

  // Controladores de texto para Económico y Placa
  final TextEditingController _economicoController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _cargaController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  final TextEditingController _operadorController = TextEditingController();

  // 5 Contadores de Estructuras
  int _abatibles = 0;
  int _normales = 0;
  int _atvNormal = 0;
  int _atvAbatible = 0;
  int _cartonMadera = 0;

  int get _totalEstructuras =>
      _abatibles + _normales + _atvNormal + _atvAbatible + _cartonMadera;

  bool _isSaving = false;

  @override
  void dispose() {
    _economicoController.dispose();
    _placaController.dispose();
    _cargaController.dispose();
    _destinoController.dispose();
    _operadorController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode({
    required String title,
    required TextEditingController controller,
  }) async {
    final scannedValue = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScannerScreen(
          title: title,
          hint: 'Apunta al código de barras del $title',
        ),
      ),
    );

    if (scannedValue != null && scannedValue.trim().isNotEmpty) {
      final text = scannedValue.trim();

      // Buscar si el código contiene 'Economico: 3114' o 'Placa:A726AF'
      final econMatch = RegExp(r'econ[oó]mico\s*:\s*([^\r\n\s]+)', caseSensitive: false).firstMatch(text);
      final placaMatch = RegExp(r'placa\s*:\s*([^\r\n\s]+)', caseSensitive: false).firstMatch(text);

      setState(() {
        if (econMatch != null || placaMatch != null) {
          if (econMatch != null) {
            _economicoController.text = econMatch.group(1)!;
          }
          if (placaMatch != null) {
            _placaController.text = placaMatch.group(1)!;
          }
        } else {
          // Si no tiene prefijo, comprobar si vienen dos partes separadas (ej. 3114-A726AF o 3114 / A726AF)
          final parts = text.split(RegExp(r'[\/\-_,\s|]+'));
          if (parts.length >= 2 && RegExp(r'^\d{3,6}$').hasMatch(parts[0])) {
            _economicoController.text = parts[0];
            _placaController.text = parts.sublist(1).join('-');
          } else {
            // Si es plano individual, limpiar prefijos
            final cleaned = text
                .replaceAll(RegExp(r'^econ[oó]mico\s*:\s*', caseSensitive: false), '')
                .replaceAll(RegExp(r'^placa\s*:\s*', caseSensitive: false), '');
            controller.text = cleaned;
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código capturado: $text'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF003893),
          ),
        );
      }
    }
  }

  Future<void> _saveRecord() async {
    final economico = _economicoController.text.trim();
    final placa = _placaController.text.trim();

    if (economico.isEmpty && placa.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa o escanea el Económico o la Placa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_totalEstructuras == 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Total en Cero'),
          content: const Text(
            'No has registrado ninguna estructura. ¿Deseas guardar el registro con conteo en 0?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar de todos modos'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final folio = 'VAL-${DateFormat('yyMMdd-HHmm').format(now)}';

    final record = StructureRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      folio: folio,
      fechaHora: now,
      tipoMovimiento: _tipoMovimiento,
      economico: economico,
      placa: placa,
      numeroCarga: _cargaController.text.trim(),
      destino: _destinoController.text.trim(),
      operador: _operadorController.text.trim(),
      abatibles: _abatibles,
      normales: _normales,
      atvNormal: _atvNormal,
      atvAbatible: _atvAbatible,
      cartonMadera: _cartonMadera,
    );

    final success = await _storageService.saveRecord(record);

    setState(() => _isSaving = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro $folio guardado exitosamente'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al guardar el registro'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Validar Estructuras',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF003893),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tipo de Movimiento (Segmented)
                    const Text(
                      'Tipo de Movimiento',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'Entrada Contenedor',
                          label: Text('Entrada Cont.'),
                          icon: Icon(Icons.login, size: 16),
                        ),
                        ButtonSegment(
                          value: 'Salida',
                          label: Text('Salida'),
                          icon: Icon(Icons.logout, size: 16),
                        ),
                        ButtonSegment(
                          value: 'Retorno a CEDIS',
                          label: Text('Retorno'),
                          icon: Icon(Icons.replay, size: 16),
                        ),
                      ],
                      selected: {_tipoMovimiento},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _tipoMovimiento = newSelection.first;
                        });
                      },
                    ),

                    const SizedBox(height: 18),

                    // Tarjeta: Datos de la Unidad (Código de Barras)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.qr_code_scanner, color: Color(0xFF003893)),
                              SizedBox(width: 8),
                              Text(
                                'Identificación de Unidad',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Botón Principal: Escaneo completo de Económico + Placa
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF003893),
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.qr_code_scanner, size: 20),
                            label: const Text(
                              'ESCANEAR CÓDIGO (ECONÓMICO + PLACA)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            onPressed: () => _scanBarcode(
                              title: 'Económico y Placa',
                              controller: _economicoController,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Campo: Número Económico con botón de escaneo
                          TextField(
                            controller: _economicoController,
                            decoration: InputDecoration(
                              labelText: 'Económico de la Unidad',
                              hintText: 'Ej. 5013',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.numbers),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.barcode_reader, size: 28),
                                color: const Color(0xFF003893),
                                tooltip: 'Escanear código de barras Económico',
                                onPressed: () => _scanBarcode(
                                  title: 'Económico',
                                  controller: _economicoController,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Campo: Placa con botón de escaneo
                          TextField(
                            controller: _placaController,
                            decoration: InputDecoration(
                              labelText: 'Placa de la Unidad',
                              hintText: 'Ej. 23-008',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.credit_card),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.barcode_reader, size: 28),
                                color: const Color(0xFF003893),
                                tooltip: 'Escanear código de barras Placa',
                                onPressed: () => _scanBarcode(
                                  title: 'Placa',
                                  controller: _placaController,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Fila adicional: Carga y Destino
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cargaController,
                                  decoration: const InputDecoration(
                                    labelText: '# Carga',
                                    hintText: '0579',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _destinoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Destino',
                                    hintText: 'Tienda/CEDIS',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          TextField(
                            controller: _operadorController,
                            decoration: const InputDecoration(
                              labelText: 'Operador / Transportista',
                              hintText: 'Nombre del chofer',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Sección: 5 Contadores de Estructuras
                    const Text(
                      'Conteo de Estructuras',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 1. Abatibles
                    StructureCounterCard(
                      title: 'Abatibles',
                      subtitle: 'Abatible Estándar',
                      icon: Icons.compress,
                      count: _abatibles,
                      onChanged: (val) => setState(() => _abatibles = val),
                    ),

                    // 2. Normales
                    StructureCounterCard(
                      title: 'Normales',
                      subtitle: 'EMP-1870MM Estándar',
                      icon: Icons.inventory_2,
                      count: _normales,
                      onChanged: (val) => setState(() => _normales = val),
                    ),

                    // 3. ATV Normal
                    StructureCounterCard(
                      title: 'ATV Normal',
                      subtitle: 'Cuatrimotos Normal',
                      icon: Icons.two_wheeler,
                      count: _atvNormal,
                      onChanged: (val) => setState(() => _atvNormal = val),
                    ),

                    // 4. ATV Abatible
                    StructureCounterCard(
                      title: 'ATV Abatible',
                      subtitle: 'Cuatrimotos Abatible',
                      icon: Icons.unfold_less,
                      count: _atvAbatible,
                      onChanged: (val) => setState(() => _atvAbatible = val),
                    ),

                    // 5. Cartón / Madera
                    StructureCounterCard(
                      title: 'Cartón / Madera',
                      subtitle: 'Embalaje complementario',
                      icon: Icons.pallet,
                      count: _cartonMadera,
                      onChanged: (val) => setState(() => _cartonMadera = val),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Barra inferior fija con Total y Guardar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    offset: const Offset(0, -3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Totalizador
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'TOTAL ESTRUCTURAS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '$_totalEstructuras',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF003893),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Botón Guardar
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF003893),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSaving ? null : _saveRecord,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        _isSaving ? 'Guardando...' : 'Guardar Registro',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
