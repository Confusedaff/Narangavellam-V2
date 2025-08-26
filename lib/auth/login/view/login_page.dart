import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narangavellam/auth/login/cubit/login_cubit.dart';
import 'package:narangavellam/auth/login/widgets/sign_up_new_account.dart';
import 'package:narangavellam/auth/login/widgets/widgets.dart';
import 'package:user_repository/user_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child:const LoginView(),
      );
  }
}

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return  AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body:AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
            children: [
          
              const SizedBox(height:AppSpacing.xxxlg*3,),
          
              const AppLogo(
                fit: BoxFit.fitHeight,
                width: double.infinity,
                ),
          
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  const LoginForm(),
        
                  const SizedBox(height: AppSpacing.md),
        
                  const PasswordFromField(),
        
                  const Padding(
                    padding: EdgeInsets.only
                    (top:AppSpacing.sm,bottom: AppSpacing.sm),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: ForgotPasswordButton(),
                    ),
                  ),
        
                  const Align(
                    child: SignInButton(),
                  ),
        
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    child: AppDivider(
                      color: AppColors.lightDark,
                    ),
                  ),
        
                  Align(
                    child: AuthProviderSignInButton(
                      provider: AuthProvider.google, 
                      onPressed: () =>
                          context.read<LoginCubit>().loginWithGoogle(),
                      ),
                  ),
        
                  
                  Align(
                    child: AuthProviderSignInButton(
                      provider: AuthProvider.github, 
                      onPressed: () =>
                          context.read<LoginCubit>().loginWithGithub(),
                      ),
                  ),
                ],)
                ,),
                const Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.xxlg),
                  child: SignUpNewAccountButton(),
                ),

                ElevatedButton(
                      onPressed: () => context.read<UserRepository>().logOut(),
                      child: const Text('Log out'),
                      ),

            ],
          ),
      ),
      );
  }
  
}
