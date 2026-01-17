// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAccountSetting => 'Account Setting';

  @override
  String get settingsProfile => 'Profile';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsChangeLanguage => 'Change language';

  @override
  String get settingsPlantConfiguration => 'Plant Configuration';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsTerms => 'Terms and Condition';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsLogout => 'Logout';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSelectTitle => 'Select Theme';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageIndonesia => 'Bahasa Indonesia';

  @override
  String get languageSelectTitle => 'Select Language';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonView => 'View';

  @override
  String get commonFeatureComingSoon => 'Feature coming soon';

  @override
  String get commonLinkNotSet => 'Link not available yet';

  @override
  String get commonActive => 'ACTIVE';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonLast => 'Last';

  @override
  String get commonToday => 'Today';

  @override
  String get commonYesterday => 'Yesterday';

  @override
  String get commonNew => 'New';

  @override
  String get commonOld => 'Old';

  @override
  String get commonAll => 'All';

  @override
  String get commonOk => 'OK';

  @override
  String get commonSaving => 'Saving...';

  @override
  String get commonSuccess => 'Success 🎉';

  @override
  String get commonFailed => 'Failed 😣';

  @override
  String get commonEmail => 'Email';

  @override
  String get logoutConfirmTitle => 'Confirm Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get homeYourLocation => 'Your location';

  @override
  String get homeAllFeatures => 'All Features';

  @override
  String get homeMonitoring => 'Monitoring';

  @override
  String get homeMonitoringDesc => 'Check your plant\'s health';

  @override
  String get homeNotification => 'Notification';

  @override
  String get homeNotificationDesc => 'View history';

  @override
  String get homeAddKit => 'Add Kit';

  @override
  String get homeAddKitDesc => 'Connect new devices';

  @override
  String get homeSetting => 'Setting';

  @override
  String get homeSettingDesc => 'Manage your account';

  @override
  String get weatherClear => 'Clear';

  @override
  String get weatherPartlyCloudy => 'Partly cloudy';

  @override
  String get weatherFoggy => 'Foggy';

  @override
  String get weatherDrizzle => 'Drizzle';

  @override
  String get weatherRain => 'Rain';

  @override
  String get weatherSnow => 'Snow';

  @override
  String get weatherRainShowers => 'Rain showers';

  @override
  String get weatherHeavyRain => 'Heavy rain';

  @override
  String get weatherThunderstorm => 'Thunderstorm';

  @override
  String get weatherUnknown => 'Unknown';

  @override
  String get daySun => 'Sun';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get monthJan => 'January';

  @override
  String get monthFeb => 'February';

  @override
  String get monthMar => 'March';

  @override
  String get monthApr => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJun => 'June';

  @override
  String get monthJul => 'July';

  @override
  String get monthAug => 'August';

  @override
  String get monthSep => 'September';

  @override
  String get monthOct => 'October';

  @override
  String get monthNov => 'November';

  @override
  String get monthDec => 'December';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileUserId => 'User ID';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileKitName => 'Kit Name';

  @override
  String get profileKitId => 'Kit ID';

  @override
  String get profileEditProfile => 'Edit Profile';

  @override
  String get profileDefaultKitName => 'Your Kit Name';

  @override
  String get profileDefaultKitId => 'SUF-XXXX-XXXX';

  @override
  String get authLoginTitle => 'Hello Again!';

  @override
  String get authLoginSubtitle => 'Welcome Back You\'ve Been Missed!';

  @override
  String get authEmailLabel => 'Email Address';

  @override
  String get authEmailHint => 'example@email.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => 'Enter your password';

  @override
  String get authRecoveryPassword => 'Recovery Password';

  @override
  String get authSignIn => 'Sign In';

  @override
  String get authSignInGoogle => 'Sign in with Google';

  @override
  String get authNoAccount => 'Don\'t Have An Account? ';

  @override
  String get authSignUpFree => 'Sign Up For Free';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authRegisterSubtitle => 'Let\'s Create Account Together';

  @override
  String get authNameLabel => 'Your Name';

  @override
  String get authNameHint => 'Full name';

  @override
  String get authLocationLabel => 'Location';

  @override
  String get authLocationHint => 'Your city';

  @override
  String get authLocationError =>
      'Unable to get location. Please enter manually.';

  @override
  String get authSignUp => 'Sign Up';

  @override
  String get authVerifyTitle => 'Welcome to Fountaine';

  @override
  String authVerifyDesc(String email) {
    return 'Thank you for registering.\nPlease verify your email address:\n$email';
  }

  @override
  String get authVerifyBanner => 'Email Verification';

  @override
  String get authCopyEmail => 'Copy Email';

  @override
  String get authOpenEmail => 'Open Email';

  @override
  String get authResendEmail => 'Resend Verification Email';

  @override
  String get authRefreshStatus => 'Refresh Status';

  @override
  String get authNeedHelp => 'Need help?';

  @override
  String get authHelpTips =>
      '• Check Spam/Promotions folder.\n• Wait 1-2 minutes then press \"Refresh Status\".\n• Make sure email is correct.\n• Try \"Resend Verification Email\".';

  @override
  String get authBackToLogin => 'Back to Login';

  @override
  String get authLogout => 'Logout';

  @override
  String get authMustBeLoggedIn => 'You must be logged in to add a kit';

  @override
  String get authForgotPasswordTitle => 'Forgot Password';

  @override
  String get authForgotPasswordHeader => 'Forgot Password?';

  @override
  String get authForgotPasswordDesc =>
      'Enter your registered email. We will send you a link to reset your password.';

  @override
  String get authForgotPasswordHint => 'example: you@domain.com';

  @override
  String get authForgotPasswordInfo =>
      'We will send password reset instructions to this email. Link valid for 24 hours.';

  @override
  String get authForgotPasswordSend => 'Send Reset Link';

  @override
  String get authForgotPasswordSuccess => 'Success';

  @override
  String authForgotPasswordSuccessMsg(String email) {
    return 'Password reset link has been sent to $email.\nCheck your inbox or spam folder.';
  }

  @override
  String authForgotPasswordFailed(String error) {
    return 'Failed to send reset: $error';
  }

  @override
  String get authForgotPasswordTip =>
      'Tip: If you don\'t receive the email, check your Spam folder or try again in a few minutes.';

  @override
  String get validationEmailEmpty => 'Email cannot be empty';

  @override
  String get validationEmailInvalid => 'Invalid email format';

  @override
  String get validationNameEmpty => 'Name cannot be empty';

  @override
  String get validationLocationEmpty => 'Location cannot be empty';

  @override
  String get monitorYourKit => 'Your Kit';

  @override
  String get monitorSelectKit => 'Select Kit';

  @override
  String get monitorLongPressDelete => 'Long press to delete';

  @override
  String get monitorDeleteKit => 'Delete Kit';

  @override
  String monitorDeleteKitConfirm(String kitId) {
    return 'Are you sure you want to remove \"$kitId\" from your kit list?';
  }

  @override
  String monitorKitRemoved(String kitId) {
    return 'Kit \"$kitId\" removed from your list';
  }

  @override
  String get monitorMode => 'Mode';

  @override
  String get monitorAuto => 'AUTO';

  @override
  String get monitorManual => 'MANUAL';

  @override
  String get monitorAutoControlActive => 'Auto Control Active';

  @override
  String get monitorAllParametersSafe => 'All Parameters Safe';

  @override
  String get monitorLatestAdjustment => 'Latest adjustment';

  @override
  String get monitorNoAdjustmentNeeded => 'No adjustment needed';

  @override
  String get sensorPh => 'pH';

  @override
  String get sensorTds => 'TDS';

  @override
  String get sensorHumidity => 'Humidity';

  @override
  String get sensorAirTemp => 'Air Temp';

  @override
  String get sensorWaterTemp => 'Water Temp';

  @override
  String get sensorWaterLevel => 'Water Level';

  @override
  String get sensorTemp => 'Temp';

  @override
  String get actionPhUp => 'PH UP';

  @override
  String get actionPhDown => 'PH DOWN';

  @override
  String get actionNutrient => 'NUTRIENT';

  @override
  String get actionRefill => 'REFILL';

  @override
  String get actionPhUpSent => 'pH Up command sent';

  @override
  String get actionPhDownSent => 'pH Down command sent';

  @override
  String get actionNutrientSent => 'Nutrient command sent';

  @override
  String get actionRefillSent => 'Refill command sent';

  @override
  String get historyTitle => 'History';

  @override
  String get historyNoKitSelected => 'No kit selected';

  @override
  String get historySelectKitFirst => 'Select a kit from Monitor first';

  @override
  String get historyNoData => 'No data';

  @override
  String get historyNoReadings => 'No readings for this period';

  @override
  String historyScrollMore(int count) {
    return 'Scroll to see more ($count more)';
  }

  @override
  String get notificationTitle => 'Notification';

  @override
  String get notificationMarkAllRead => 'Mark all read';

  @override
  String get notificationDeleteAll => 'Delete all';

  @override
  String get notificationFilterInfo => 'Info';

  @override
  String get notificationFilterWarning => 'Warning';

  @override
  String get notificationFilterUrgent => 'Urgent';

  @override
  String get notificationEmptyTitle => 'No notifications (for this filter)';

  @override
  String get notificationEmptyDesc =>
      'Your system is operating normally. No issues detected.';

  @override
  String get notificationShowAll => 'Show All';

  @override
  String get notificationScrollMore => 'Scroll to see more';

  @override
  String get notificationJustNow => 'just now';

  @override
  String notificationMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String notificationHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String notificationDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get notificationNew => 'NEW';

  @override
  String get addKitTitle => 'Add Kit';

  @override
  String get addKitSubtitle => 'Add your hydroponic kit to start monitoring.';

  @override
  String get addKitNameLabel => 'Kit Name';

  @override
  String get addKitNameHint => 'e.g. Hydroponic Monitoring System';

  @override
  String get addKitIdLabel => 'Kit ID';

  @override
  String get addKitIdHint => 'e.g. SUF-UINJKT-HM-F2000';

  @override
  String get addKitSaveButton => 'Save Kit';

  @override
  String get addKitSuccess => 'Kit added successfully';

  @override
  String get addKitNameRequired => 'Kit name is required';

  @override
  String get addKitIdRequired => 'Kit ID is required';

  @override
  String get addKitIdTooShort => 'Kit ID is too short';

  @override
  String get bottomSheetActivePlant => 'Active Plant';

  @override
  String get bottomSheetIdealParams => 'Ideal Parameters';

  @override
  String get bottomSheetPhIdeal => 'pH Ideal';

  @override
  String get bottomSheetNutrientIdeal => 'Nutrient (PPM)';

  @override
  String get bottomSheetWaterTempIdeal => 'Water Temp';

  @override
  String get bottomSheetWaterLevelIdeal => 'Water Level';

  @override
  String get bottomSheetViewDetails => 'View Details';

  @override
  String get bottomSheetNoActivePlant => 'No active plant';

  @override
  String get bottomSheetAddKitFirst => 'Add a kit to start monitoring';

  @override
  String get plantNameLettuce => 'Lettuce';

  @override
  String get bottomSheetWaterLevelInfo => 'Low – High';
}
