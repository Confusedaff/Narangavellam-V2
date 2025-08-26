import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narangavellam/app/view/app.dart';
import 'package:narangavellam/auth/sign_up/signup.dart';
import 'package:narangavellam/auth/sign_up/widgets/password_form_field.dart';
import 'package:narangavellam/auth/sign_up/widgets/username_from_field.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignUpCubit, SignupState>(
      listener: (context, state) {
        if(state.submissionStatus.isSuccess){
          openSnackbar(
            const SnackbarMessage.success(
              title: 'Welcome to Naranga Vellam.',
            ),
          );
        }
       if(state.submissionStatus.isError){
           openSnackbar(
              SnackbarMessage.error(
                title: signupSubmissionStatusMessage[state.submissionStatus]!.title,
              description: 
                signupSubmissionStatusMessage[state.submissionStatus]?.description,
                ), 
                clearIfQueue: true,
            );
        }
      },
      listenWhen: (previous, current) => previous.submissionStatus != current.submissionStatus,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailFormField(),
          SizedBox(
            height: AppSpacing.md,
          ),
          FullNameTextField(),
          SizedBox(
            height: AppSpacing.md,
          ),
          UsernameTextField(),
          SizedBox(
            height: AppSpacing.md,
          ),
          PasswordTextField(),
          SizedBox(
            height: AppSpacing.md,
          ),
        ],
      ),
    );
  }
}
