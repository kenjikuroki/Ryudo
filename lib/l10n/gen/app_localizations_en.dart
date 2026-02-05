// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Archery Note';

  @override
  String get freePractice => 'Free Practice';

  @override
  String get competition => 'Competition';

  @override
  String get recentSessions => 'Recent Sessions';

  @override
  String get noSessionsRecorded => 'No sessions recorded yet.';

  @override
  String get startMatch => 'Start Match';

  @override
  String get newPractice => 'New Practice';

  @override
  String get sessions => 'Sessions';

  @override
  String get total => 'Total';

  @override
  String get hitRate => 'Hit Rate';

  @override
  String get noRecordsForMode => 'No records for this mode';

  @override
  String get premiumMemberMessage => 'You are a Premium Member!';

  @override
  String get arrows => 'arrows';

  @override
  String get bow => 'Bow';

  @override
  String get roundStatus => 'Round Status';

  @override
  String get setTargetRounds => 'Set Target Arrows';

  @override
  String get rounds => 'Rounds';

  @override
  String get cancel => 'Cancel';

  @override
  String get finishSessionTitle => 'Finish Session?';

  @override
  String get finishSessionContent =>
      'You haven\'t finished all sets yet. Do you want to end the session now and save your progress?';

  @override
  String get finishAndSave => 'Finish & Save';

  @override
  String get finishPracticeTitle => 'Finish Practice?';

  @override
  String get finishPracticeContent =>
      'Are you sure you want to finish today\'s practice and save the results?';

  @override
  String get finish => 'Finish';

  @override
  String get practice => 'Practice';

  @override
  String get switchModeTitle => 'Switch Mode?';

  @override
  String get switchModeContent =>
      'Switching modes will reset your current progress. Do you want to continue?';

  @override
  String get resetAndSwitch => 'Reset & Switch';

  @override
  String get resetSessionTitle => 'Reset Session?';

  @override
  String get resetSessionContent =>
      'This will clear all shots from your current session. This action cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String get totalScore => 'Total Score';

  @override
  String get arrowStatus => 'Arrow Status';

  @override
  String get undo => 'Undo';

  @override
  String targetArrowsReached(Object count) {
    return 'Target arrows per round reached ($count). Please proceed to the next set.';
  }

  @override
  String get scoreSheet => 'Score Sheet';

  @override
  String get endIncompleteTitle => 'End Incomplete';

  @override
  String endIncompleteContent(Object target, Object current) {
    return 'You haven\'t reached the target number of shots ($target) yet (Current: $current).\nDo you want to proceed to the next set anyway?';
  }

  @override
  String get proceed => 'Proceed';

  @override
  String get sessionFormat => 'Session Format';

  @override
  String get totalRounds => 'TOTAL ROUNDS';

  @override
  String get arrowsPerRound => 'ARROWS PER ROUND';

  @override
  String get arr => 'Arr';

  @override
  String get applySettings => 'Apply Settings';

  @override
  String get resetForNewFormatTitle => 'Reset for New Format?';

  @override
  String get resetForNewFormatContent =>
      'Changing the session format will reset your current progress. Do you want to continue?';

  @override
  String get resetAndApply => 'Reset & Apply';

  @override
  String get selectDistance => 'Select Distance';

  @override
  String get chooseDistance => 'Choose a standard distance or enter custom.';

  @override
  String get custom => 'Custom';

  @override
  String get customDistance => 'Custom Distance';

  @override
  String get exampleDistance => 'ex: 12m, 10m';

  @override
  String get save => 'Save';

  @override
  String get bowStrength => 'Bow Strength';

  @override
  String get enterBowStrength => 'Enter your bow strength (e.g. 15kg).';

  @override
  String get resultAnalysis => 'Result Analysis';

  @override
  String get shotMapping => 'Shot Mapping (All Shots)';

  @override
  String get scoreBreakdown => 'Score Breakdown';

  @override
  String get hit => 'Hit';

  @override
  String get miss => 'Miss';

  @override
  String get closeHistory => 'Close History';

  @override
  String get deleteRecord => 'Delete this record';

  @override
  String get saveAndFinish => 'Save & Finish';

  @override
  String get discardData => 'Discard Data';

  @override
  String get discardSessionTitle => 'Discard Session?';

  @override
  String get discardSessionContent =>
      'This session will not be saved. Are you sure?';

  @override
  String get discard => 'Discard';

  @override
  String get deleteRecordTitle => 'Delete Record?';

  @override
  String get deleteRecordContent =>
      'This action cannot be undone. All shots from this session will be permanently deleted.';

  @override
  String get delete => 'Delete';

  @override
  String goalEnds(Object count) {
    return 'Goal: $count Ends';
  }

  @override
  String get roundMode => 'Round Mode';

  @override
  String sightWithValue(Object value) {
    return 'Sight: $value';
  }

  @override
  String get shotsCount => 'Shots';

  @override
  String get noDataAvailable => 'No data available.';

  @override
  String get highUwa => 'High (Uwa)';

  @override
  String get lowShita => 'Low (Shita)';

  @override
  String get leftMae => 'Left (Mae)';

  @override
  String get rightUshiro => 'Right (Ushiro)';

  @override
  String arrowsTending(Object trend) {
    return 'Arrows tending $trend.';
  }

  @override
  String trendAnd(Object vertical, Object horizontal) {
    return '$vertical and $horizontal';
  }

  @override
  String trendJust(Object vertical, Object horizontal) {
    return '$vertical$horizontal';
  }

  @override
  String get greatTekichu => 'Great center shots (Tekichu)!';

  @override
  String get excellentConsistency => 'Excellent consistency (Tsume-ai)!';

  @override
  String get scatteredHassetsu =>
      'Placement is scattered. Focus on consistent Hassetsu.';

  @override
  String get premiumUnlocked => 'Premium Features Unlocked!';

  @override
  String get purchaseFailed =>
      'Purchase failed or store unavailable. Please check your App Store settings.';

  @override
  String get ok => 'OK';

  @override
  String get premiumAccess => 'PREMIUM ACCESS';

  @override
  String get premiumBenefitsDescription =>
      'Support Kyudo Note development and unlock the best experience.';

  @override
  String get benefitRemoveAds => 'Remove all annoying advertisements forever';

  @override
  String get benefitPerformance => 'Instant loading and faster performance';

  @override
  String get benefitFutureFeatures => 'Access to all future premium features';

  @override
  String get benefitSupport => 'Directly support independent app development';

  @override
  String get unlockNow => 'Unlock Now - One Time';

  @override
  String get restorePurchase => 'Already purchased? Restore Previous Purchase';

  @override
  String get legalInfo => 'Legal Information';

  @override
  String get terms => 'Terms';

  @override
  String get privacy => 'Privacy';

  @override
  String get backToFree => 'Back to Free Version';

  @override
  String get removeAdsAndSupport => 'Remove Ads & Support Developer';
}
