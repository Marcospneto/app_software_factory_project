import 'package:flutter/material.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/widgets/custom_button_circular.dart';
import 'package:meu_tempo/widgets/custom_camera_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileModal extends StatelessWidget {
  final VoidCallback onDelete;
  const ProfileModal({super.key, required this.onDelete});

  Future<void> _pickImageFromGallery(BuildContext context) async {
    var status = await Permission.photos.request();

    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        Navigator.pop(context, pickedFile.path);
      }
    } else {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F4F4),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, top: 10),
                        child: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: MainColor.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        'Foto do perfil',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: MainColor.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _OptionButton(
                icon: Icons.photo_camera_outlined,
                label: 'Câmera',
                onTap: () async {
                  final imagePath = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CustomCameraScreen()),
                  );

                  if (imagePath != null) {
                    Navigator.pop(context, imagePath);
                  }
                },
              ),
              _OptionButton(
                icon: Icons.photo_library_outlined,
                label: 'Galeria',
                onTap: () async {
                  _pickImageFromGallery(context);
                },
              ),
              _OptionButton(
                icon: Icons.delete_outline,
                label: 'Excluir',
                onTap: () {
                  onDelete();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomButtonCircular(
          width: 45,
          height: 45,
          icon: icon,
          onPressed: onTap,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: MainColor.primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
