import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narangavellam/auth/login/cubit/login_cubit.dart';
import 'package:narangavellam/l10n/l10n.dart';
import 'package:shared/shared.dart';

class PasswordFromField extends StatefulWidget {
  const PasswordFromField({super.key});

  @override
  State<PasswordFromField> createState() => _PasswordFromFieldState();
}

class _PasswordFromFieldState extends State<PasswordFromField> {

    late TextEditingController _controller;
    late FocusNode _focusNode;
    late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_focusNodeListener);
    _debouncer = Debouncer();
  }

    void _focusNodeListener(){
      if(!_focusNode.hasFocus){
        context.read<LoginCubit>().onPasswordUnfocused();
      }
    }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_focusNodeListener)
      ..dispose();
    _debouncer.dispose();
    super.dispose();

  }

  @override
  Widget build(BuildContext context) {

    final passwordFromFieldError = context.select((LoginCubit cubit) => cubit.state.password.errorMessage);
    final showPassword = context.select((LoginCubit cubit) => cubit.state.showPassword);

    return AppTextField(
      filled: true,
      obscureText: !showPassword,
      suffixIcon: Tappable(backgroundColor: AppColors.transparent,
      onTap: context.read<LoginCubit>().changePasswordVisibility,
      child: Icon(
        !showPassword ? Icons.visibility : Icons.visibility_off,
        color: context.customReversedAdaptiveColor(light: AppColors.grey),
      ),
      ),
      errorText: passwordFromFieldError,
      textController: _controller,
      focusNode: _focusNode,
      hintText: context.l10n.passwordText,
      textInputType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onChanged: (value) => _debouncer.run((){
          context.read<LoginCubit>().onPasswordChanged(value);
      }),
    );
  }
}
