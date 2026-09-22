import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/structure_record.dart';
import '../services/storage_service.dart';
import 'capture_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<StructureRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    final records = await _storageService.getRecords();
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  Future<void> _openCaptureScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CaptureScreen()),
    );
    if (result == true) {
      _loadRecords();
    }
  }

  Color _getBadgeColor(String tipo) {
    switch (tipo) {
      case 'Entrada Contenedor':
        return Colors.green.shade700;
      case 'Salida':
        return Colors.blue.shade700;
      case 'Retorno a CEDIS':
        return Colors.orange.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalEstructurasHoy = _records.fold<int>(
      0,
      (sum, item) => sum + item.totalEstructuras,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.inventory, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'ITALIKA • Estructuras',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF003893), // Azul Italika
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _loadRecords,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Banner métricas rápidas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF003893),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MetricItem(
                    label: 'Registros',
                    value: '${_records.length}',
                    icon: Icons.receipt_long,
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  _MetricItem(
                    label: 'Total Estructuras',
                    value: '$totalEstructurasHoy',
                    icon: Icons.all_inbox,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Lista de Vales / Registros
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.assignment_turned_in_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No hay registros guardados aún',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Presiona el botón de abajo para iniciar',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            final record = _records[index];
                            final badgeColor = _getBadgeColor(record.tipoMovimiento);
                            final formattedDate = DateFormat('dd/MM/yyyy HH:mm')
                                .format(record.fechaHora);

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Fila 1: Folio, Fecha y Badge Tipo
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          record.folio,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Color(0xFF1F2937),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeColor.withOpacity(0.12),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            record.tipoMovimiento,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: badgeColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formattedDate,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const Divider(height: 18),

                                    // Fila 2: Económico y Placa
                                    Row(
                                      children: [
                                        _InfoChip(
                                          icon: Icons.local_shipping,
                                          label: 'Económico',
                                          value: record.economico.isEmpty
                                              ? 'S/N'
                                              : record.economico,
                                        ),
                                        const SizedBox(width: 12),
                                        _InfoChip(
                                          icon: Icons.credit_card,
                                          label: 'Placa',
                                          value: record.placa.isEmpty
                                              ? 'S/N'
                                              : record.placa,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Fila 3: Desglose de las 5 estructuras
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: [
                                        _StructureTag(
                                            name: 'Abatibles',
                                            count: record.abatibles),
                                        _StructureTag(
                                            name: 'Normales',
                                            count: record.normales),
                                        _StructureTag(
                                            name: 'ATV N.',
                                            count: record.atvNormal),
                                        _StructureTag(
                                            name: 'ATV Abat.',
                                            count: record.atvAbatible),
                                        _StructureTag(
                                            name: 'Cart/Mad',
                                            count: record.cartonMadera),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Fila 4: Total resaltado
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (record.destino.isNotEmpty)
                                          Text(
                                            'Destino: ${record.destino}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        else
                                          const SizedBox(),
                                        Text(
                                          'TOTAL: ${record.totalEstructuras}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF003893),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFE50914), // Rojo Italika para acción principal
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'NUEVO REGISTRO',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        onPressed: _openCaptureScreen,
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF003893)),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}

class _StructureTag extends StatelessWidget {
  final String name;
  final int count;

  const _StructureTag({required this.name, required this.count});

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF003893).withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF003893).withOpacity(0.2)),
      ),
      child: Text(
        '$name: $count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF003893),
        ),
      ),
    );
  }
}
