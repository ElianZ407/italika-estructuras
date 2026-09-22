import 'package:flutter/material.dart';

class StructureCounterCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final ValueChanged<int> onChanged;

  const StructureCounterCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = count > 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasValue ? const Color(0xFF003893) : Colors.grey.shade300,
          width: hasValue ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Icono representativo
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: hasValue
                  ? const Color(0xFF003893).withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: hasValue ? const Color(0xFF003893) : Colors.grey.shade600,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Título y subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Botones de ajuste rápido
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botón Menos (-)
              IconButton.filledTonal(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  minimumSize: const Size(40, 40),
                ),
                icon: const Icon(Icons.remove, size: 20),
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
              ),

              // Indicador numérico
              Container(
                constraints: const SizeBox(minWidth: 46),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: hasValue ? const Color(0xFF003893) : Colors.grey.shade700,
                  ),
                ),
              ),

              // Botón Más (+)
              IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF003893),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(40, 40),
                ),
                icon: const Icon(Icons.add, size: 20),
                onPressed: () => onChanged(count + 1),
              ),

              const SizedBox(width: 6),

              // Botón de salto rápido (+5)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: const Size(36, 40),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => onChanged(count + 5),
                child: const Text(
                  '+5',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF003893),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
