import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/file_service.dart';
import '../widgets/summary_card.dart';

class UploadPage extends StatefulWidget {
  final void Function(List<Map<String, dynamic>>)? onRefinedData; // ✅ 콜백 추가

  const UploadPage({super.key, this.onRefinedData});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? _selectedFile;
  String? _statusMessage;
  Map<String, dynamic>? _analysisResult;

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
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _statusMessage = '업로드 중...';
      _analysisResult = null;
    });

    final result = await FileService.uploadExcelFile(_selectedFile!);

    setState(() {
      if (result != null) {
        _statusMessage = '✅ 업로드 및 분석 완료';
        _analysisResult = result;

        // ✅ 콜백으로 preview 데이터를 전달
        final previewList = result['preview'];
        if (previewList is List && widget.onRefinedData != null) {
          widget.onRefinedData!(List<Map<String, dynamic>>.from(previewList));
        }
      } else {
        _statusMessage = '❌ 업로드 실패';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final previewList = _analysisResult?['preview'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ⬆ Summary Cards
          Row(
            children: [
              Expanded(
                child: SummaryCard(
                  title: '전체 행 수',
                  value: _analysisResult?['total_rows']?.toString() ?? '-',
                  icon: Icons.table_rows,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SummaryCard(
                  title: '중복 행 수',
                  value: _analysisResult?['duplicated_rows']?.toString() ?? '-',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
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

          /// 📁 Upload Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickExcelFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('엑셀 파일 선택'),
                ),
                const SizedBox(height: 12),
                if (_selectedFile != null)
                  Text(
                    "선택한 파일: ${_selectedFile!.path.split(Platform.pathSeparator).last}",
                    style: const TextStyle(fontSize: 14),
                  ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _uploadFile,
                  icon: const Icon(Icons.upload),
                  label: const Text('업로드 및 분석하기'),
                ),
                const SizedBox(height: 12),
                if (_statusMessage != null)
                  Text(
                    _statusMessage!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _statusMessage!.startsWith('✅')
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          /// 🧾 중복 데이터 미리보기
          if (_analysisResult != null) ...[
            const Text(
              "🧾 중복 미리보기",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (previewList != null &&
                previewList is List &&
                previewList.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
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
                      tileColor: index % 2 == 0
                          ? Colors.grey.shade50
                          : Colors.transparent,
                    );
                  },
                ),
              ),
            ] else ...[
              const Text("⚠️ 미리볼 중복 항목이 없습니다.")
            ],
          ]
        ],
      ),
    );
  }
}
