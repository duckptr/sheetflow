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

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16.0,
        headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
        columns: columns.map((key) => DataColumn(label: Text(key))).toList(),
        rows: data.map((row) {
          return DataRow(
            cells: columns.map((key) {
              final value = row[key]?.toString() ?? '';
              return DataCell(Text(value));
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
