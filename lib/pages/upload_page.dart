// upload_page.dart
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

  Future<void> _pickExcelFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _statusMessage = null;
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() => _statusMessage = '업로드 중...');

    final success = await FileService.uploadExcelFile(_selectedFile!);

    setState(() {
      _statusMessage = success ? '✅ 업로드 성공!' : '❌ 업로드 실패';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _pickExcelFile,
            icon: const Icon(Icons.folder_open),
            label: const Text('엑셀 파일 선택'),
          ),
          const SizedBox(height: 16),
          if (_selectedFile != null)
            Text('선택된 파일: ${_selectedFile!.path.split("/").last}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _selectedFile != null ? _uploadFile : null,
            child: const Text('FastAPI로 업로드'),
          ),
          const SizedBox(height: 16),
          if (_statusMessage != null)
            Text(_statusMessage!, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
