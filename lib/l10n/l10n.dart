import 'package:flutter/widgets.dart';
import 'package:narangavellam/l10n/app_localizations.dart';

export 'package:narangavellam/l10n/app_localizations.dart';
export 'slang/translations.g.dart';


extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
