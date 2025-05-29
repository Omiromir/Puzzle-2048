// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '2048 Puzzle';

  @override
  String get homeTitle => 'Home';

  @override
  String get aboutTitle => 'About';

  @override
  String get play => 'Play';

  @override
  String bestScore(Object score) {
    return 'Best Score: $score';
  }

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get logout => 'Log out';

  @override
  String get login => 'Login';

  @override
  String get newGame => 'New Game';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get settings => 'Settings';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get aboutText => 'Swipe to move tiles.\nCombine same numbers.\nReach 2048 to win!\nGood luck!';

  @override
  String get credits => 'Developed by Moiseychenko Nikita and Abishev Beibarys.\nMentor: Abzal Kyzyrkanov';

  @override
  String get guestModeMessage => 'You are in Guest Mode. Some features are disabled.';

  @override
  String get startGame => 'Start Game';

  @override
  String get undo => 'Undo';

  @override
  String get restart => 'Restart';

  @override
  String get gameOver => 'Game Over';

  @override
  String get finalScore => 'Final Score';

  @override
  String score(Object score) {
    return 'Score: $score';
  }

  @override
  String get scoreLabel => 'Score';

  @override
  String get name => 'Name';

  @override
  String get bestLabel => 'Record';

  @override
  String get noScoresYet => 'No scores yet';
}
