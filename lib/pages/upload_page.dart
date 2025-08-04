import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../services/file_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

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
      } else {
        _statusMessage = '❌ 업로드 실패';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('엑셀 업로드 및 중복 분석')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
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
              Text("선택한 파일: ${_selectedFile!.path.split(Platform.pathSeparator).last}"),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _uploadFile,
              icon: const Icon(Icons.upload),
              label: const Text('업로드 및 분석하기'),
            ),
            const SizedBox(height: 12),
            if (_statusMessage != null)
              Text(_statusMessage!, style: const TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),
            if (_analysisResult != null) ...[
              Text("📊 전체 행 수: ${_analysisResult!['total_rows']}"),
              Text("⚠️ 중복 행 수: ${_analysisResult!['duplicated_rows']}"),
              const Divider(),
              const Text("🧾 중복 미리보기:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _analysisResult!['preview'].length,
                  itemBuilder: (context, index) {
                    final row = _analysisResult!['preview'][index];
                    return ListTile(
                      title: Text(row.toString()),
                      dense: true,
                      tileColor: index % 2 == 0 ? Colors.grey[100] : null,
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
