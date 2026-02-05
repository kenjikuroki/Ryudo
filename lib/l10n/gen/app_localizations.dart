import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Archery Note'**
  String get appTitle;

  /// No description provided for @freePractice.
  ///
  /// In en, this message translates to:
  /// **'Free Practice'**
  String get freePractice;

  /// No description provided for @competition.
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get competition;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent Sessions'**
  String get recentSessions;

  /// No description provided for @noSessionsRecorded.
  ///
  /// In en, this message translates to:
  /// **'No sessions recorded yet.'**
  String get noSessionsRecorded;

  /// No description provided for @startMatch.
  ///
  /// In en, this message translates to:
  /// **'Start Match'**
  String get startMatch;

  /// No description provided for @newPractice.
  ///
  /// In en, this message translates to:
  /// **'New Practice'**
  String get newPractice;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @hitRate.
  ///
  /// In en, this message translates to:
  /// **'Hit Rate'**
  String get hitRate;

  /// No description provided for @noRecordsForMode.
  ///
  /// In en, this message translates to:
  /// **'No records for this mode'**
  String get noRecordsForMode;

  /// No description provided for @premiumMemberMessage.
  ///
  /// In en, this message translates to:
  /// **'You are a Premium Member!'**
  String get premiumMemberMessage;

  /// No description provided for @arrows.
  ///
  /// In en, this message translates to:
  /// **'arrows'**
  String get arrows;

  /// No description provided for @bow.
  ///
  /// In en, this message translates to:
  /// **'Bow'**
  String get bow;

  /// No description provided for @roundStatus.
  ///
  /// In en, this message translates to:
  /// **'Round Status'**
  String get roundStatus;

  /// No description provided for @setTargetRounds.
  ///
  /// In en, this message translates to:
  /// **'Set Target Arrows'**
  String get setTargetRounds;

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get rounds;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @finishSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish Session?'**
  String get finishSessionTitle;

  /// No description provided for @finishSessionContent.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t finished all sets yet. Do you want to end the session now and save your progress?'**
  String get finishSessionContent;

  /// No description provided for @finishAndSave.
  ///
  /// In en, this message translates to:
  /// **'Finish & Save'**
  String get finishAndSave;

  /// No description provided for @finishPracticeTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish Practice?'**
  String get finishPracticeTitle;

  /// No description provided for @finishPracticeContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to finish today\'s practice and save the results?'**
  String get finishPracticeContent;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @switchModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Switch Mode?'**
  String get switchModeTitle;

  /// No description provided for @switchModeContent.
  ///
  /// In en, this message translates to:
  /// **'Switching modes will reset your current progress. Do you want to continue?'**
  String get switchModeContent;

  /// No description provided for @resetAndSwitch.
  ///
  /// In en, this message translates to:
  /// **'Reset & Switch'**
  String get resetAndSwitch;

  /// No description provided for @resetSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Session?'**
  String get resetSessionTitle;

  /// No description provided for @resetSessionContent.
  ///
  /// In en, this message translates to:
  /// **'This will clear all shots from your current session. This action cannot be undone.'**
  String get resetSessionContent;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @totalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// No description provided for @arrowStatus.
  ///
  /// In en, this message translates to:
  /// **'Arrow Status'**
  String get arrowStatus;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @targetArrowsReached.
  ///
  /// In en, this message translates to:
  /// **'Target arrows per round reached ({count}). Please proceed to the next set.'**
  String targetArrowsReached(Object count);

  /// No description provided for @scoreSheet.
  ///
  /// In en, this message translates to:
  /// **'Score Sheet'**
  String get scoreSheet;

  /// No description provided for @endIncompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'End Incomplete'**
  String get endIncompleteTitle;

  /// No description provided for @endIncompleteContent.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t reached the target number of shots ({target}) yet (Current: {current}).\nDo you want to proceed to the next set anyway?'**
  String endIncompleteContent(Object target, Object current);

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @sessionFormat.
  ///
  /// In en, this message translates to:
  /// **'Session Format'**
  String get sessionFormat;

  /// No description provided for @totalRounds.
  ///
  /// In en, this message translates to:
  /// **'TOTAL ROUNDS'**
  String get totalRounds;

  /// No description provided for @arrowsPerRound.
  ///
  /// In en, this message translates to:
  /// **'ARROWS PER ROUND'**
  String get arrowsPerRound;

  /// No description provided for @arr.
  ///
  /// In en, this message translates to:
  /// **'Arr'**
  String get arr;

  /// No description provided for @applySettings.
  ///
  /// In en, this message translates to:
  /// **'Apply Settings'**
  String get applySettings;

  /// No description provided for @resetForNewFormatTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset for New Format?'**
  String get resetForNewFormatTitle;

  /// No description provided for @resetForNewFormatContent.
  ///
  /// In en, this message translates to:
  /// **'Changing the session format will reset your current progress. Do you want to continue?'**
  String get resetForNewFormatContent;

  /// No description provided for @resetAndApply.
  ///
  /// In en, this message translates to:
  /// **'Reset & Apply'**
  String get resetAndApply;

  /// No description provided for @selectDistance.
  ///
  /// In en, this message translates to:
  /// **'Select Distance'**
  String get selectDistance;

  /// No description provided for @chooseDistance.
  ///
  /// In en, this message translates to:
  /// **'Choose a standard distance or enter custom.'**
  String get chooseDistance;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @customDistance.
  ///
  /// In en, this message translates to:
  /// **'Custom Distance'**
  String get customDistance;

  /// No description provided for @exampleDistance.
  ///
  /// In en, this message translates to:
  /// **'ex: 12m, 10m'**
  String get exampleDistance;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @bowStrength.
  ///
  /// In en, this message translates to:
  /// **'Bow Strength'**
  String get bowStrength;

  /// No description provided for @enterBowStrength.
  ///
  /// In en, this message translates to:
  /// **'Enter your bow strength (e.g. 15kg).'**
  String get enterBowStrength;

  /// No description provided for @resultAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Result Analysis'**
  String get resultAnalysis;

  /// No description provided for @shotMapping.
  ///
  /// In en, this message translates to:
  /// **'Shot Mapping (All Shots)'**
  String get shotMapping;

  /// No description provided for @scoreBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get scoreBreakdown;

  /// No description provided for @hit.
  ///
  /// In en, this message translates to:
  /// **'Hit'**
  String get hit;

  /// No description provided for @miss.
  ///
  /// In en, this message translates to:
  /// **'Miss'**
  String get miss;

  /// No description provided for @closeHistory.
  ///
  /// In en, this message translates to:
  /// **'Close History'**
  String get closeHistory;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete this record'**
  String get deleteRecord;

  /// No description provided for @saveAndFinish.
  ///
  /// In en, this message translates to:
  /// **'Save & Finish'**
  String get saveAndFinish;

  /// No description provided for @discardData.
  ///
  /// In en, this message translates to:
  /// **'Discard Data'**
  String get discardData;

  /// No description provided for @discardSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Session?'**
  String get discardSessionTitle;

  /// No description provided for @discardSessionContent.
  ///
  /// In en, this message translates to:
  /// **'This session will not be saved. Are you sure?'**
  String get discardSessionContent;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Record?'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordContent.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. All shots from this session will be permanently deleted.'**
  String get deleteRecordContent;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @goalEnds.
  ///
  /// In en, this message translates to:
  /// **'Goal: {count} Ends'**
  String goalEnds(Object count);

  /// No description provided for @roundMode.
  ///
  /// In en, this message translates to:
  /// **'Round Mode'**
  String get roundMode;

  /// No description provided for @sightWithValue.
  ///
  /// In en, this message translates to:
  /// **'Sight: {value}'**
  String sightWithValue(Object value);

  /// No description provided for @shotsCount.
  ///
  /// In en, this message translates to:
  /// **'Shots'**
  String get shotsCount;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noDataAvailable;

  /// No description provided for @highUwa.
  ///
  /// In en, this message translates to:
  /// **'High (Uwa)'**
  String get highUwa;

  /// No description provided for @lowShita.
  ///
  /// In en, this message translates to:
  /// **'Low (Shita)'**
  String get lowShita;

  /// No description provided for @leftMae.
  ///
  /// In en, this message translates to:
  /// **'Left (Mae)'**
  String get leftMae;

  /// No description provided for @rightUshiro.
  ///
  /// In en, this message translates to:
  /// **'Right (Ushiro)'**
  String get rightUshiro;

  /// No description provided for @arrowsTending.
  ///
  /// In en, this message translates to:
  /// **'Arrows tending {trend}.'**
  String arrowsTending(Object trend);

  /// No description provided for @trendAnd.
  ///
  /// In en, this message translates to:
  /// **'{vertical} and {horizontal}'**
  String trendAnd(Object vertical, Object horizontal);

  /// No description provided for @trendJust.
  ///
  /// In en, this message translates to:
  /// **'{vertical}{horizontal}'**
  String trendJust(Object vertical, Object horizontal);

  /// No description provided for @greatTekichu.
  ///
  /// In en, this message translates to:
  /// **'Great center shots (Tekichu)!'**
  String get greatTekichu;

  /// No description provided for @excellentConsistency.
  ///
  /// In en, this message translates to:
  /// **'Excellent consistency (Tsume-ai)!'**
  String get excellentConsistency;

  /// No description provided for @scatteredHassetsu.
  ///
  /// In en, this message translates to:
  /// **'Placement is scattered. Focus on consistent Hassetsu.'**
  String get scatteredHassetsu;

  /// No description provided for @premiumUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Premium Features Unlocked!'**
  String get premiumUnlocked;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed or store unavailable. Please check your App Store settings.'**
  String get purchaseFailed;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @premiumAccess.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM ACCESS'**
  String get premiumAccess;

  /// No description provided for @premiumBenefitsDescription.
  ///
  /// In en, this message translates to:
  /// **'Support Kyudo Note development and unlock the best experience.'**
  String get premiumBenefitsDescription;

  /// No description provided for @benefitRemoveAds.
  ///
  /// In en, this message translates to:
  /// **'Remove all annoying advertisements forever'**
  String get benefitRemoveAds;

  /// No description provided for @benefitPerformance.
  ///
  /// In en, this message translates to:
  /// **'Instant loading and faster performance'**
  String get benefitPerformance;

  /// No description provided for @benefitFutureFeatures.
  ///
  /// In en, this message translates to:
  /// **'Access to all future premium features'**
  String get benefitFutureFeatures;

  /// No description provided for @benefitSupport.
  ///
  /// In en, this message translates to:
  /// **'Directly support independent app development'**
  String get benefitSupport;

  /// No description provided for @unlockNow.
  ///
  /// In en, this message translates to:
  /// **'Unlock Now - One Time'**
  String get unlockNow;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Already purchased? Restore Previous Purchase'**
  String get restorePurchase;

  /// No description provided for @legalInfo.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalInfo;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @backToFree.
  ///
  /// In en, this message translates to:
  /// **'Back to Free Version'**
  String get backToFree;

  /// No description provided for @removeAdsAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Remove Ads & Support Developer'**
  String get removeAdsAndSupport;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
