import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ubantu/data/services/supabase_storage_service.dart';

class PhotoUploadCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? currentPhotoUrl;
  final ValueChanged<String?> onPhotoChanged;
  final Color accentColor;
  final String category;

  const PhotoUploadCard({
    super.key,
    this.title = 'Foto Barang (opsional)',
    this.subtitle = 'Format JPG, PNG (Maksimal 5MB)',
    this.currentPhotoUrl,
    required this.onPhotoChanged,
    this.accentColor = const Color(0xFF86B049),
    this.category = 'order',
  });

  @override
  State<PhotoUploadCard> createState() => _PhotoUploadCardState();
}

class _PhotoUploadCardState extends State<PhotoUploadCard> {
  final ImagePicker _picker = ImagePicker();
  final SupabaseStorageService _storageService = SupabaseStorageService();
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (picked == null) return;

      setState(() {
        _isUploading = true;
      });

      final uploadResult = await _storageService.uploadOrderPhoto(
        File(picked.path),
        widget.category,
      );

      if (mounted) {
        setState(() {
          _isUploading = false;
        });

        if (uploadResult.isSuccess && uploadResult.data != null) {
          widget.onPhotoChanged(uploadResult.data);
        } else {
          widget.onPhotoChanged(picked.path);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Color(0xFF263225),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pilih sumber pengambilan foto',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.accentColor.withAlpha(30),
                    child: Icon(Icons.camera_alt_rounded, color: widget.accentColor),
                  ),
                  title: const Text(
                    'Ambil dari Kamera',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.accentColor.withAlpha(30),
                    child: Icon(Icons.photo_library_rounded, color: widget.accentColor),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const SizedBox(
            height: 150,
            child: Center(child: CircularProgressIndicator()),
          );
        },
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 150,
      width: double.infinity,
      color: const Color(0xFFF0F4ED),
      child: Center(
        child: Icon(Icons.image_outlined, size: 48, color: widget.accentColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.currentPhotoUrl != null && widget.currentPhotoUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasPhoto)
              TextButton.icon(
                onPressed: () => widget.onPhotoChanged(null),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFF44336)),
                label: const Text(
                  'Hapus',
                  style: TextStyle(
                    color: Color(0xFFF44336),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isUploading)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.accentColor.withAlpha(100), width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: widget.accentColor),
                const SizedBox(height: 12),
                Text(
                  'Sedang mengunggah foto...',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else if (hasPhoto)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.accentColor, width: 1.2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildImagePreview(widget.currentPhotoUrl!),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: widget.accentColor, size: 18),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'Foto berhasil dilampirkan',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Plus Jakarta Sans',
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF263225),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _showPickerBottomSheet,
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            'Ganti Foto',
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.bold,
                              color: widget.accentColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          InkWell(
            onTap: _showPickerBottomSheet,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 0.8,
                    color: Color(0xFF263225),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFF0F4ED),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: widget.accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Upload foto',
                    style: TextStyle(
                      color: Color(0xFF263225),
                      fontSize: 13,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF70776D),
                      fontSize: 11,
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
