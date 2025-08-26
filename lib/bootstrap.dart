import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:app_ui/app_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:firebase_remote_config_repository/firebase_remote_config_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:narangavellam/app/app.dart';
import 'package:narangavellam/l10n/l10n.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_storage/persistent_storage.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:shared/shared.dart';

typedef AppBuilder = FutureOr<Widget> Function(
  PowerSyncRepository,
  SharedPreferences,
  FirebaseRemoteConfigRepository,
  FirebaseMessaging,
);

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logD('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logD('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  AppBuilder builder,{
  required FirebaseOptions options,
  required AppFlavor appFlavor,
  }) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

 await runZonedGuarded(
  () async {
    WidgetsFlutterBinding.ensureInitialized();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
  if (Platform.isAndroid) {
    await ScreenProtector.preventScreenshotOn();
    }
  });
    


    setupDi(appFlavor: appFlavor);

    if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(
    name: 'narangavellam-prod-c4f15',
    options: options,
    );

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
              ? HydratedStorage.webStorageDirectory
              : await getTemporaryDirectory(),
      );
}
    final powerSyncRepository = PowerSyncRepository(env: appFlavor.getEnv);
      await powerSyncRepository.initialize();

    final sharedPreferences = await SharedPreferences.getInstance();

    final firebaseRemoteConfig = FirebaseRemoteConfig.instance;
    final firebaseRemoteConfigRepository = FirebaseRemoteConfigRepository(firebaseRemoteConfig: firebaseRemoteConfig);
    final firebaseMessaging = FirebaseMessaging.instance;

    SystemUiOverlayTheme.setPortraitOrientation();

    runApp(TranslationProvider(child: await builder(powerSyncRepository,sharedPreferences,firebaseRemoteConfigRepository,firebaseMessaging)));
  },
  (error, stack) {
    logE(error.toString(), stackTrace: stack);
  },
 );
}
