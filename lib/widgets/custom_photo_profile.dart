import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meu_tempo/widgets/custom_button_circular.dart';

class CustomPhotoProfile extends StatefulWidget {
  final VoidCallback? onPhotoEdit;
  final File? imageFile;
  final bool isLoading;

  const CustomPhotoProfile({
    super.key,
    this.onPhotoEdit,
    this.imageFile,
    this.isLoading = false,
  });

  @override
  State<CustomPhotoProfile> createState() => _CustomPhotoProfileState();
}

class _CustomPhotoProfileState extends State<CustomPhotoProfile> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 70,
                backgroundImage: !widget.isLoading && widget.imageFile != null
                    ? FileImage(widget.imageFile!)
                    : const AssetImage('assets/images/user-default.png')
                        as ImageProvider,
              ),
              if (widget.isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.onPhotoEdit != null) // Só exibe o botão se onPhotoEdit não for null
          Positioned(
            bottom: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: widget.isLoading,
              child: Opacity(
                opacity: widget.isLoading ? 0.6 : 1.0,
                child: CustomButtonCircular(
                  width: 45,
                  height: 45,
                  onPressed: widget.onPhotoEdit!,
                  icon: Icons.photo_camera_outlined,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
