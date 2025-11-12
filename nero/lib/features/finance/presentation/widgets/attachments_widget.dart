import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/services/storage_service.dart';

/// Widget para gerenciar anexos de uma transação
class AttachmentsWidget extends StatefulWidget {
  final List<String> attachments;
  final String userId;
  final String transactionId;
  final Function(List<String>) onAttachmentsChanged;
  final bool isDark;

  const AttachmentsWidget({
    super.key,
    required this.attachments,
    required this.userId,
    required this.transactionId,
    required this.onAttachmentsChanged,
    required this.isDark,
  });

  @override
  State<AttachmentsWidget> createState() => _AttachmentsWidgetState();
}

class _AttachmentsWidgetState extends State<AttachmentsWidget> {
  bool _isUploading = false;

  Color get _labelColor =>
      widget.isDark ? AppColors.darkText : const Color(0xFF1C1C1C);
  Color get _secondaryColor =>
      widget.isDark ? const Color(0xFF9E9E9E) : const Color(0xFF5F5F5F);
  Color get _backgroundColor =>
      widget.isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get _borderColor =>
      widget.isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
  Color get _cardColor =>
      widget.isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file, size: 18, color: _secondaryColor),
            const SizedBox(width: 8),
            Text(
              'Anexos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _labelColor,
              ),
            ),
            const Spacer(),
            // Botão para adicionar anexo
            InkWell(
              onTap: _isUploading ? null : _showAttachmentOptions,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isUploading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      )
                    else
                      const Icon(
                        Icons.add_photo_alternate,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    const SizedBox(width: 6),
                    const Text(
                      'Adicionar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Lista de anexos
        if (widget.attachments.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.image_not_supported, color: _secondaryColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Nenhum anexo adicionado',
                  style: TextStyle(
                    color: _secondaryColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.attachments
                .map((url) => _buildAttachmentThumbnail(url))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildAttachmentThumbnail(String url) {
    return Stack(
      children: [
        // Thumbnail da imagem
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: _borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: _cardColor,
                child: Icon(
                  Icons.broken_image,
                  color: _secondaryColor,
                  size: 32,
                ),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: _cardColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Botão de remover
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeAttachment(url),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Botão de visualizar
        Positioned(
          bottom: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _viewAttachment(url),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.visibility,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.primary),
              title: Text('Tirar Foto', style: TextStyle(color: _labelColor)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: Text('Galeria', style: TextStyle(color: _labelColor)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final url = await StorageService.uploadImage(
        userId: widget.userId,
        transactionId: widget.transactionId,
        source: source,
      );

      if (url != null && mounted) {
        final updatedAttachments = [...widget.attachments, url];
        widget.onAttachmentsChanged(updatedAttachments);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Anexo adicionado com sucesso!'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Text('Erro ao adicionar anexo: $e'),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removeAttachment(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _backgroundColor,
        title: Text('Remover Anexo', style: TextStyle(color: _labelColor)),
        content: Text(
          'Deseja remover este anexo?',
          style: TextStyle(color: _secondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: _secondaryColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final updatedAttachments = widget.attachments
                  .where((attachment) => attachment != url)
                  .toList();
              widget.onAttachmentsChanged(updatedAttachments);

              // Deletar do storage
              StorageService.deleteFile(url);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  void _viewAttachment(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: _cardColor,
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 64),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
