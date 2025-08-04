import 'package:flutter/material.dart';

class PaginatedExcelTable extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const PaginatedExcelTable({super.key, required this.data});

  @override
  State<PaginatedExcelTable> createState() => _PaginatedExcelTableState();
}

class _PaginatedExcelTableState extends State<PaginatedExcelTable> {
  late ExcelDataSource _dataSource;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _dataSource = ExcelDataSource(widget.data);
  }

  void _sort<T>(
    Comparable<T> Function(Map<String, dynamic> d) getField,
    int columnIndex,
    bool ascending,
  ) {
    _dataSource.sort(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Text("📭 데이터가 없습니다.");
    }

    final columns = widget.data.first.keys.toList();

    return SingleChildScrollView(
      child: PaginatedDataTable(
        header: const Text('📊 정제된 데이터'),
        rowsPerPage: _rowsPerPage,
        availableRowsPerPage: const [5, 10, 20],
        onRowsPerPageChanged: (value) {
          if (value != null) {
            setState(() => _rowsPerPage = value);
          }
        },
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: List.generate(columns.length, (index) {
          final columnName = columns[index];
          return DataColumn(
            label: Text(
              columnName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onSort: (colIndex, ascending) {
              _sort<String>((d) => d[columnName]?.toString() ?? '', colIndex, ascending);
            },
          );
        }),
        source: _dataSource,
        columnSpacing: 24,
        showCheckboxColumn: false,
      ),
    );
  }
}

class ExcelDataSource extends DataTableSource {
  List<Map<String, dynamic>> _data;

  ExcelDataSource(this._data);

  void sort<T>(Comparable<T> Function(Map<String, dynamic> d) getField, bool ascending) {
    _data.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final row = _data[index];
    final cells = row.values
        .map((value) => DataCell(Text(value?.toString() ?? '')))
        .toList();

    return DataRow.byIndex(
      index: index,
      cells: cells,
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
