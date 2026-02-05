// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '弓道ノート';

  @override
  String get freePractice => '自由練習';

  @override
  String get competition => '立 (試合・審査)';

  @override
  String get recentSessions => '最近の履歴';

  @override
  String get noSessionsRecorded => '履歴がありません';

  @override
  String get startMatch => '立を開始';

  @override
  String get newPractice => '練習を開始';

  @override
  String get sessions => '回数';

  @override
  String get total => '総射数';

  @override
  String get hitRate => '的中率';

  @override
  String get noRecordsForMode => 'このモードのデータはありません';

  @override
  String get premiumMemberMessage => 'プレミアム会員です！';

  @override
  String get arrows => '射';

  @override
  String get bow => '弓';

  @override
  String get roundStatus => '進行状況';

  @override
  String get setTargetRounds => '目標射数を設定';

  @override
  String get rounds => '射';

  @override
  String get cancel => 'キャンセル';

  @override
  String get finishSessionTitle => '終了しますか？';

  @override
  String get finishSessionContent => 'まだ全ての回を終了していません。終了して結果を保存しますか？';

  @override
  String get finishAndSave => '終了して保存';

  @override
  String get finishPracticeTitle => '練習を終了しますか？';

  @override
  String get finishPracticeContent => '今日の練習を終了して結果を保存しますか？';

  @override
  String get finish => '終了';

  @override
  String get practice => '練習';

  @override
  String get switchModeTitle => 'モードを変更しますか？';

  @override
  String get switchModeContent => 'モードを変更すると現在の進行状況がリセットされます。続けますか？';

  @override
  String get resetAndSwitch => 'リセットして変更';

  @override
  String get resetSessionTitle => 'リセットしますか？';

  @override
  String get resetSessionContent => '現在の記録を全て消去します。この操作は取り消せません。';

  @override
  String get reset => 'リセット';

  @override
  String get totalScore => '合計点';

  @override
  String get arrowStatus => '進行';

  @override
  String get undo => '戻す';

  @override
  String targetArrowsReached(Object count) {
    return '目標射数($count射)に達しました。次の回へ進んでください。';
  }

  @override
  String get scoreSheet => 'スコア表';

  @override
  String get endIncompleteTitle => '未完了の回';

  @override
  String endIncompleteContent(Object target, Object current) {
    return '目標射数($target射)に達していません(現在: $current射)。\n次の回へ進みますか？';
  }

  @override
  String get proceed => '進む';

  @override
  String get sessionFormat => '行射設定';

  @override
  String get totalRounds => '総回数';

  @override
  String get arrowsPerRound => '1回の射数';

  @override
  String get arr => '射';

  @override
  String get applySettings => '設定を適用';

  @override
  String get resetForNewFormatTitle => '設定を変更しますか？';

  @override
  String get resetForNewFormatContent => '設定を変更すると現在の進行状況がリセットされます。続けますか？';

  @override
  String get resetAndApply => 'リセットして適用';

  @override
  String get selectDistance => '距離を選択';

  @override
  String get chooseDistance => '標準の距離を選択または入力してください';

  @override
  String get custom => 'カスタム';

  @override
  String get customDistance => '距離を入力';

  @override
  String get exampleDistance => '例: 28m, 近的';

  @override
  String get save => '保存';

  @override
  String get bowStrength => '弓の強さ';

  @override
  String get enterBowStrength => '弓の強さを入力してください (例: 15kg)';

  @override
  String get resultAnalysis => '結果分析';

  @override
  String get shotMapping => '的中位置 (全射)';

  @override
  String get scoreBreakdown => 'スコア内訳';

  @override
  String get hit => '的中';

  @override
  String get miss => '外れ';

  @override
  String get closeHistory => '閉じる';

  @override
  String get deleteRecord => 'この記録を削除';

  @override
  String get saveAndFinish => '保存して終了';

  @override
  String get discardData => '破棄する';

  @override
  String get discardSessionTitle => '破棄しますか？';

  @override
  String get discardSessionContent => 'この記録は保存されません。よろしいですか？';

  @override
  String get discard => '破棄';

  @override
  String get deleteRecordTitle => '記録を削除しますか？';

  @override
  String get deleteRecordContent => 'この操作は取り消せません。この記録は完全に削除されます。';

  @override
  String get delete => '削除';

  @override
  String goalEnds(Object count) {
    return '目標: $count立';
  }

  @override
  String get roundMode => '立 (試合・審査)';

  @override
  String sightWithValue(Object value) {
    return '弓: $value';
  }

  @override
  String get shotsCount => '本数';

  @override
  String get noDataAvailable => 'データがありません';

  @override
  String get highUwa => '上';

  @override
  String get lowShita => '下';

  @override
  String get leftMae => '前';

  @override
  String get rightUshiro => '後';

  @override
  String arrowsTending(Object trend) {
    return '矢所が$trendに集まっています。';
  }

  @override
  String trendAnd(Object vertical, Object horizontal) {
    return '$vertical$horizontal';
  }

  @override
  String trendJust(Object vertical, Object horizontal) {
    return '$vertical$horizontal';
  }

  @override
  String get greatTekichu => '素晴らしい！的中です！';

  @override
  String get excellentConsistency => 'よくまとまっています！';

  @override
  String get scatteredHassetsu => 'ばらつきがあります。ハ節を意識しましょう。';

  @override
  String get premiumUnlocked => 'プレミアム機能が解放されました！';

  @override
  String get purchaseFailed => '購入に失敗しました。App Storeの設定を確認してください。';

  @override
  String get ok => 'OK';

  @override
  String get premiumAccess => 'プレミアム機能';

  @override
  String get premiumBenefitsDescription => '開発を支援して、最高の体験を手に入れましょう。';

  @override
  String get benefitRemoveAds => '広告を完全に非表示にします';

  @override
  String get benefitPerformance => '読み込み速度とパフォーマンスが向上します';

  @override
  String get benefitFutureFeatures => '将来の全てのプレミアム機能にアクセス可能';

  @override
  String get benefitSupport => '個人のアプリ開発を直接支援できます';

  @override
  String get unlockNow => '今すぐ購入 (買い切り)';

  @override
  String get restorePurchase => '購入済みの方は復元する';

  @override
  String get legalInfo => '法的情報';

  @override
  String get terms => '利用規約';

  @override
  String get privacy => 'プライバシー';

  @override
  String get backToFree => '閉じる';

  @override
  String get removeAdsAndSupport => '広告を非表示＆開発を支援';
}
