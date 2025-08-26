import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:narangavellam/app/bloc/app_bloc.dart';
import 'package:narangavellam/app/routes/routes.dart';
import 'package:narangavellam/app/view/app.dart';
import 'package:narangavellam/app/view/app_init_utilities.dart';
import 'package:narangavellam/l10n/app_localizations.dart';
import 'package:narangavellam/selector/locale/bloc/locale_bloc.dart';
import 'package:narangavellam/selector/theme/view/bloc/theme_mode_bloc.dart';
import 'package:shared/shared.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final routerConfig = router(context.read<AppBloc>());

    return BlocBuilder<LocaleBloc, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeModeBloc, ThemeMode>(
          builder: (context, themeMode) {
            return AnimatedSwitcher(
              duration: 350.ms,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
                child: MaterialApp.router(
                  debugShowCheckedModeBanner: false,
                  themeMode: themeMode,
                  theme: const AppTheme().theme,
                  darkTheme: const AppDarkTheme().theme,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: locale,
                  routerConfig: routerConfig,
                  builder: (context, child) {
                    initUtilities(context, locale); 
                    return Stack(
                      children: [
                        child!,
                        AppSnackbar(key: snackbarKey),
                        AppLoadingIndeterminate(key: loadingIndeterminateKey),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
