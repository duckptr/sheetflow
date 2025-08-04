import 'package:flutter/material.dart';

class ExcelTable extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const ExcelTable({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Text("📭 데이터가 없습니다.");
    }

    final columns = data.first.keys.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 20.0,
          headingRowHeight: 48,
          dataRowHeight: 44,
          headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
          columns: columns
              .map(
                (key) => DataColumn(
                  label: Text(
                    key,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )
              .toList(),
          rows: data.map((row) {
            return DataRow(
              cells: columns.map((key) {
                final value = row[key]?.toString() ?? '';
                return DataCell(
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}
