import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/file_service.dart';
import '../widgets/summary_card.dart';

class UploadPage extends StatefulWidget {
  final void Function(List<Map<String, dynamic>>)? onRefinedData;
  const UploadPage({super.key, this.onRefinedData});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedFile;
  String? _statusMessage;
  Map<String, dynamic>? _analysisResult;
  List<dynamic>? _groupedResult;
  List<dynamic>? _sortedPreview;

  Future<void> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _statusMessage = null;
        _analysisResult = null;
        _groupedResult = null;
        _sortedPreview = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _statusMessage = '업로드 중';
      _analysisResult = null;
      _groupedResult = null;
      _sortedPreview = null;
    });

    final result = await FileService.uploadExcelFile(_selectedFile!);
    final grouped = await FileService.groupSerials(_selectedFile!);

    setState(() {
      if (result != null) {
        _statusMessage = '✅ 업로드 및 분석 완료';
        _analysisResult = result;

        final previewList = result['preview'];
        if (previewList is List && widget.onRefinedData != null) {
          widget.onRefinedData!(List<Map<String, dynamic>>.from(previewList));
        }
      } else {
        _statusMessage = '❌ 업로드 실패';
      }
      _groupedResult = grouped;
    });
  }

  Future<void> _sortData() async {
    if (_selectedFile == null) {
      setState(() {
        _statusMessage = '⚠️ 파일을 먼저 선택하세요';
      });
      return;
    }

    setState(() {
      _statusMessage = '정렬 중...';
      _sortedPreview = null;
    });

    final result = await FileService.sortExcelFile(_selectedFile!);

    setState(() {
      if (result != null && result['sorted_preview'] != null) {
        _sortedPreview = result['sorted_preview'];
        _statusMessage = '✅ 정렬 완료';
      } else {
        _statusMessage = '❌ 정렬 실패';
      }
    });
  }

  Future<void> _generateFile() async {
    if (_selectedFile == null) {
      setState(() {
        _statusMessage = '⚠️ 파일을 먼저 선택하세요';
      });
      return;
    }

    setState(() {
      _statusMessage = '파일 생성 중...';
    });

    final fileBytes = await FileService.generateExcelFile(_selectedFile!);
    if (fileBytes != null) {
      final downloadsDir = await getDownloadsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final savePath = '${downloadsDir!.path}/sorted_serials_$timestamp.xlsx';

      final file = File(savePath);
      await file.writeAsBytes(fileBytes);

      setState(() {
        _statusMessage = '✅ 파일 생성 완료';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('파일이 다운로드 폴더에 저장되었습니다.\n$savePath')),
        );
      }
    } else {
      setState(() {
        _statusMessage = '❌ 파일 생성 실패';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewList = _analysisResult?['preview'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 0,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 260,
                child: SummaryCard(
                  title: '전체 행 수',
                  value: _analysisResult?['total_rows']?.toString() ?? '-',
                  icon: Icons.table_rows,
                  color: Colors.indigo,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 260,
                child: SummaryCard(
                  title: '중복 행 수',
                  value: _analysisResult?['duplicated_rows']?.toString() ?? '-',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
              ),
              SizedBox(
                width: 260,
                child: SummaryCard(
                  title: '분석 상태',
                  value: _statusMessage ?? '대기 중',
                  icon: Icons.check_circle,
                  color: _statusMessage?.startsWith('✅') == true
                      ? Colors.green
                      : Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildCard(
                width: 196,
                title: "파일 선택",
                buttonText: "선택",
                tooltip: "엑셀 파일 선택",
                onPressed: _pickExcelFile,
                footer: _selectedFile != null
                    ? _selectedFile!.path.split(Platform.pathSeparator).last
                    : "엑셀 파일을 선택하세요",
              ),
              _buildCard(
                width: 196,
                title: "분석 실행",
                buttonText: "실행",
                tooltip: "파일 업로드 및 분석",
                onPressed: _uploadFile,
                footer: _statusMessage ?? "분석을 시작하세요",
                footerColor: _statusMessage?.startsWith('✅') == true
                    ? Colors.green
                    : (_statusMessage?.startsWith('❌') == true ? Colors.red : null),
              ),
              _buildCard(
                width: 196,
                title: "정렬 실행",
                buttonText: "실행",
                tooltip: "데이터 정렬",
                onPressed: _sortData,
                footer: "데이터 정렬 실행",
              ),
              _buildCard(
                width: 196,
                title: "파일 생성",
                buttonText: "생성",
                tooltip: "정렬된 파일 다운로드",
                onPressed: _generateFile,
                footer: "엑셀 파일 다운로드",
              ),
            ],
          ),

          const SizedBox(height: 32),

          if (_analysisResult != null) ...[
            const Text("🧾 중복 미리보기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (previewList != null && previewList.isNotEmpty)
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: previewList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = previewList[index];
                    return ListTile(
                      title: Text(row.toString()),
                      dense: true,
                      tileColor: index % 2 == 0 ? Colors.grey.shade50 : Colors.transparent,
                    );
                  },
                ),
              )
            else
              const Text("⚠️ 미리볼 중복 항목이 없습니다."),
          ],

          if (_sortedPreview != null) ...[
            const SizedBox(height: 32),
            const Text("📑 정렬 미리보기", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sortedPreview!.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final row = _sortedPreview![index];
                  return ListTile(
                    title: Text(row.toString()),
                    dense: true,
                    tileColor: index % 2 == 0 ? Colors.grey.shade50 : Colors.transparent,
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 32),

          if (_groupedResult != null && _groupedResult!.isNotEmpty) ...[
            const Text("📦 제품코드별 시리얼 추적", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._groupedResult!.map<Widget>((group) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 1.5,
                child: ExpansionTile(
                  title: Text("제품코드: ${group['product_code']}"),
                  children: (group['serial_logs'] as List).map<Widget>((log) {
                    return ListTile(
                      title: Text("testdate: ${log['test_date']} | shipdate: ${log['ship_date']}"),
                      subtitle: Text("시리얼: ${log['serial_start']} ~ ${log['serial_end']}"),
                      dense: true,
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildCard({
    required double width,
    required String title,
    required String buttonText,
    required String tooltip,
    required VoidCallback? onPressed,
    String? footer,
    Color? footerColor,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: Tooltip(
                  message: tooltip,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (footer != null)
                Text(
                  footer,
                  style: TextStyle(
                    fontSize: 12,
                    color: footerColor ?? Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
