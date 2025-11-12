import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço para gerenciar uploads e downloads de arquivos no Supabase Storage
class StorageService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const String _bucketName = 'transaction-attachments';

  /// Extrai a extensão do arquivo de um caminho
  static String _getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1) return '.jpg'; // extensão padrão
    return filePath.substring(lastDot);
  }

  /// Seleciona e faz upload de uma imagem
  static Future<String?> uploadImage({
    required String userId,
    required String transactionId,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      // Selecionar imagem
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Gerar nome único para o arquivo
      final extension = _getFileExtension(image.path);
      final String fileName =
          '$userId/$transactionId/${DateTime.now().millisecondsSinceEpoch}$extension';

      // Ler bytes do arquivo
      final bytes = await image.readAsBytes();

      // Upload para Supabase Storage
      await _supabase.storage.from(_bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(image.path),
              upsert: false,
            ),
          );

      // Retornar URL pública
      final String publicUrl =
          _supabase.storage.from(_bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      print('❌ [StorageService] Erro ao fazer upload: $e');
      return null;
    }
  }

  /// Remove um arquivo do storage
  static Future<bool> deleteFile(String fileUrl) async {
    try {
      // Extrair path do arquivo da URL
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;

      // O path está após /storage/v1/object/public/{bucket}/
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex == -1) return false;

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      // Deletar arquivo
      await _supabase.storage.from(_bucketName).remove([filePath]);

      return true;
    } catch (e) {
      print('❌ [StorageService] Erro ao deletar arquivo: $e');
      return false;
    }
  }

  /// Remove todos os anexos de uma transação
  static Future<bool> deleteTransactionAttachments(
    String userId,
    String transactionId,
  ) async {
    try {
      final List<FileObject> files = await _supabase.storage
          .from(_bucketName)
          .list(path: '$userId/$transactionId');

      if (files.isEmpty) return true;

      final filePaths = files
          .map((file) => '$userId/$transactionId/${file.name}')
          .toList();

      await _supabase.storage.from(_bucketName).remove(filePaths);

      return true;
    } catch (e) {
      print('❌ [StorageService] Erro ao deletar anexos da transação: $e');
      return false;
    }
  }

  /// Obtém o content type baseado na extensão do arquivo
  static String _getContentType(String filePath) {
    final extension = _getFileExtension(filePath).toLowerCase();

    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
