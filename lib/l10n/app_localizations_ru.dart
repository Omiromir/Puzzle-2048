// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Пазл 2048';

  @override
  String get homeTitle => 'Главная';

  @override
  String get aboutTitle => 'О нас';

  @override
  String get play => 'Играть';

  @override
  String bestScore(Object score) {
    return 'Лучший счет: $score';
  }

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get logout => 'Выйти';

  @override
  String get login => 'Войти';

  @override
  String get newGame => 'Новая игра';

  @override
  String get leaderboard => 'Таблица лидеров';

  @override
  String get settings => 'Настройки';

  @override
  String get howToPlay => 'Как играть';

  @override
  String get aboutText => 'Проведите, чтобы переместить плитки.\nОбъединяйте одинаковые.\nДостигните 2048, чтобы победить!\nУдачи!';

  @override
  String get credits => 'Разработали: Моисейченко Никита и Абишев Бейбарс.\nНаставник: Абзал Кызырканов';

  @override
  String get guestModeMessage => 'Вы находитесь в гостевом режиме. Некоторые функции отключены.';

  @override
  String get startGame => 'Начать игру';

  @override
  String get undo => 'Отменить';

  @override
  String get restart => 'Перезапуск';

  @override
  String get gameOver => 'Игра окончена';

  @override
  String get finalScore => 'Итоговый счёт';

  @override
  String score(Object score) {
    return 'Счёт: $score';
  }

  @override
  String get scoreLabel => 'Очки';

  @override
  String get name => 'Имя';

  @override
  String get bestLabel => 'Рекорд';

  @override
  String get noScoresYet => 'Рекордов еще нет';
}
