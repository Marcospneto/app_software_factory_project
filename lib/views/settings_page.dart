import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:meu_tempo/config/app_routes.dart';
import 'package:meu_tempo/config/main_color.dart';
import 'package:meu_tempo/locator/locator.dart';
import 'package:meu_tempo/store/profile_image_store.dart';
import 'package:meu_tempo/store/user_store.dart';
import 'package:meu_tempo/views/intro_page.dart';
import 'package:meu_tempo/widgets/custom_appbar.dart';
import 'package:meu_tempo/widgets/custom_button.dart';
import 'package:meu_tempo/widgets/custom_photo_profile.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserStore userStore = getIt<UserStore>();
  final ProfileImageStore profileImageStore = getIt<ProfileImageStore>();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await userStore.loadCurrentUser();
    if (mounted && userStore.currentUser != null) {
      await profileImageStore.loadImage(email: userStore.currentUser!.email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Configurações',
        fontWeight: FontWeight.w900,
        backgroundColor: MainColor.secondaryColor,
        titleColor: Colors.white,
        titleAlignment: Alignment.center,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.home),
        ),
      ),
      body: Observer(
        builder: (_) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  MainColor.primaryColor,
                  MainColor.secondaryColor,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                CustomPhotoProfile(
                  imageFile: profileImageStore.image,
                ),
                const SizedBox(height: 12),
                Text(
                  userStore.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontFamily: 'Comfortaa',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                CustomButton(
                  text: 'EDITAR PERFIL',
                  width: 350,
                  fontSize: 14,
                  iconSize: 26,
                  icon: Icons.edit,
                  
                  iconColor: MainColor.primaryColor,
                  textColor: MainColor.primaryColor,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.editProfile);
                  },
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'ALTERAR SENHA',
                  width: 350,
                  fontSize: 14,
                  iconSize: 26,
                  icon: Icons.edit,
                  iconColor: MainColor.primaryColor,
                  textColor: MainColor.primaryColor,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.alterPassword),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'CENTRO DE TEMPO',
                  width: 350,
                  fontSize: 14,
                  iconSize: 26,
                  icon: Icons.diamond_outlined,
                  iconColor: MainColor.primaryColor,
                  textColor: MainColor.primaryColor,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.timerCenter);
                  },
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'SOBRE',
                  width: 350,
                  fontSize: 14,
                  iconSize: 26,
                  icon: Icons.info_outline,
                  iconColor: MainColor.primaryColor,
                  textColor: MainColor.primaryColor,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.about);
                  },
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'SAIR',
                  width: 350,
                  fontSize: 14,
                  iconSize: 26,
                  icon: Icons.logout,
                  iconColor: MainColor.primaryColor,
                  textColor: MainColor.primaryColor,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  onPressed: () async {
                    await userStore.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const IntroPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
