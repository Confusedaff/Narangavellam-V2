import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narangavellam/app/user_profile/widgets/avatar_image_picker.dart';
import 'package:narangavellam/auth/sign_up/signup.dart';
import 'package:narangavellam/auth/sign_up/widgets/sign_up_button.dart';
import 'package:notifications_repository/notifications_repository.dart';
import 'package:user_repository/user_repository.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(
        userRepository: context.read<UserRepository>(),
        notificationRepository: context.read<NotificationsRepository>(),
      ),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  File? _avatarFile; 

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xxxlg + AppSpacing.xlg),
            const AppLogo(
              fit: BoxFit.fitHeight,
            ),
            
            Expanded(
                child: Column(
              children: [
                Align(child: AvatarImagePicker(
                  onUpload: (_,avatarFile){
                    setState(() => _avatarFile = avatarFile);
                  },
                ),),
                const SizedBox(height: AppSpacing.md,),
                const SignUpForm(),
                const SizedBox(height: AppSpacing.xlg,),
                SignUpButton(
                  avatarFile: _avatarFile,
                ),
              ],
            ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: SignInIntoAccountButton(),
            ),
          ],
        ),
      ),
    );
  }
}
