import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/services/util_service.dart';
import 'package:meu_tempo/store/profile_image_store.dart';
import 'package:meu_tempo/store/user_store.dart';
import 'package:meu_tempo/views/edit/profile_modal.dart';
import 'package:meu_tempo/views/settings_page.dart';
import 'package:meu_tempo/widgets/custom_alert.dart';
import 'package:meu_tempo/widgets/custom_appBar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_input.dart';
import 'package:meu_tempo/widgets/custom_input_phone.dart';
import 'package:meu_tempo/widgets/custom_photo_profile.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserStore userStore = getIt<UserStore>();
  final ProfileImageStore profileImageStore = getIt<ProfileImageStore>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();

  bool _isLoading = true;

  static const _defaultPadding = EdgeInsets.only(top: 20, right: 20, left: 20);
  static const _buttonPadding = EdgeInsets.only(top: 45, right: 80, left: 80);
  static const _photoPadding = EdgeInsets.only(top: 30);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      await userStore.loadCurrentUser();

      if (userStore.currentUser != null) {
        final user = userStore.currentUser!;
        _nameController.text = user.name;
        final formattedTelephone = UtilService.formatMask(user.telephone);
        _telephoneController.text = formattedTelephone;

        await profileImageStore.loadImage(email: user.email);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handlePhotoEdit() async {
    final imagePath = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          ProfileModal(onDelete: () => profileImageStore.clearImage()),
    );

    if (imagePath != null && imagePath.isNotEmpty) {
      final imageFile = File(imagePath);
      await profileImageStore.uploadProfileImage(
          imageFile: imageFile, email: userStore.currentUser!.email);
    }
  }

  Future<void> _editProfile() async {
    final user = userStore.currentUser;
    if (user == null) return;

    final String unmaskedTelephone =
        _telephoneController.text.replaceAll(RegExp(r'[^0-9]'), '');

    await userStore.updateUser(
        name: _nameController.text, telephone: unmaskedTelephone);

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlert(
            title: 'Sucesso',
            message: 'Usuário editado com sucesso!',
            type: AlertType.success,
            onOkPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
              (route) => false,
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Editar Perfil',
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Observer(
            builder: (_) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: _photoPadding,
                      child: CustomPhotoProfile(
                        onPhotoEdit: _handlePhotoEdit,
                        imageFile: profileImageStore.image,
                      ),
                    ),
                    Padding(
                      padding: _defaultPadding,
                      child: CustomInput(
                        label: 'Nome',
                        controller: _nameController,
                        fieldName: 'name',
                        colorText: MainColor.primaryColor,
                        colorLabel: MainColor.primaryColor,
                        colorBorder: MainColor.primaryColor,
                      ),
                    ),
                    Padding(
                      padding: _defaultPadding,
                      child: CustomInputPhone(
                        label: 'Telefone',
                        controller: _telephoneController,
                        fieldName: 'telephone',
                        keyboardType: TextInputType.phone,
                        colorText: MainColor.primaryColor,
                        colorLabel: MainColor.primaryColor,
                        colorBorder: MainColor.primaryColor,
                      ),
                    ),
                    Padding(
                      padding: _buttonPadding,
                      child: CustomButton(
                        onPressed: _editProfile,
                        text: 'Editar',
                        color: MainColor.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
