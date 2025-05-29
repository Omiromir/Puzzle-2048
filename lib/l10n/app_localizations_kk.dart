// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kazakh (`kk`).
class AppLocalizationsKk extends AppLocalizations {
  AppLocalizationsKk([String locale = 'kk']) : super(locale);

  @override
  String get appTitle => '2048 Ойыны';

  @override
  String get homeTitle => 'Басты бет';

  @override
  String get aboutTitle => 'Туралы';

  @override
  String get play => 'Ойнау';

  @override
  String bestScore(Object score) {
    return 'Ең жақсы ұпай: $score';
  }

  @override
  String get language => 'Тіл';

  @override
  String get theme => 'Тақырып';

  @override
  String get logout => 'Шығу';

  @override
  String get login => 'Кіру';

  @override
  String get newGame => 'Жаңа ойын';

  @override
  String get leaderboard => 'Көшбасшылар';

  @override
  String get settings => 'Баптаулар';

  @override
  String get howToPlay => 'Қалай ойнау';

  @override
  String get aboutText => 'Плиткаларды жылжыту үшін сырғытыңыз.\nБірдей сандарды біріктіріңіз.\n2048 жетіңіз — жеңіске жетіңіз!\nСәттілік!';

  @override
  String get credits => 'Жобаны жасағандар: Моисейченко Никита және Абишев Бейбарс.\nЖетекші: Абзал Кызырканов';

  @override
  String get guestModeMessage => 'Сіз қонақ режиміндесіз. Кейбір мүмкіндіктер өшірілген.';

  @override
  String get startGame => 'Ойынды бастау';

  @override
  String get undo => 'Болдырмау';

  @override
  String get restart => 'Қайта бастау';

  @override
  String get gameOver => 'Ойын аяқталды';

  @override
  String get finalScore => 'Қорытынды ұпай';

  @override
  String score(Object score) {
    return 'Ұпай: $score';
  }

  @override
  String get scoreLabel => 'Ұпай';

  @override
  String get name => 'Аты';

  @override
  String get bestLabel => 'Үздік';

  @override
  String get noScoresYet => 'Әзірге ұпай жоқ';
}
