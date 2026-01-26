import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('id'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSetting.
  ///
  /// In en, this message translates to:
  /// **'Account Setting'**
  String get settingsAccountSetting;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get settingsChangeLanguage;

  /// No description provided for @settingsPlantConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Plant Configuration'**
  String get settingsPlantConfiguration;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Condition'**
  String get settingsTerms;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// App version display
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get themeSelectTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageIndonesia.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get languageIndonesia;

  /// No description provided for @languageSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelectTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;

  /// No description provided for @commonView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get commonView;

  /// No description provided for @commonFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon'**
  String get commonFeatureComingSoon;

  /// No description provided for @commonLinkNotSet.
  ///
  /// In en, this message translates to:
  /// **'Link not available yet'**
  String get commonLinkNotSet;

  /// No description provided for @commonActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get commonActive;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonLast.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get commonLast;

  /// No description provided for @commonToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get commonToday;

  /// No description provided for @commonYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get commonYesterday;

  /// No description provided for @commonNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get commonNew;

  /// No description provided for @commonOld.
  ///
  /// In en, this message translates to:
  /// **'Old'**
  String get commonOld;

  /// No description provided for @commonAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get commonSaving;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success 🎉'**
  String get commonSuccess;

  /// No description provided for @commonFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed 😣'**
  String get commonFailed;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @homeYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your location'**
  String get homeYourLocation;

  /// No description provided for @homeAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'All Features'**
  String get homeAllFeatures;

  /// No description provided for @homeMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get homeMonitoring;

  /// No description provided for @homeMonitoringDesc.
  ///
  /// In en, this message translates to:
  /// **'Check your plant\'s health'**
  String get homeMonitoringDesc;

  /// No description provided for @homeNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get homeNotification;

  /// No description provided for @homeNotificationDesc.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get homeNotificationDesc;

  /// No description provided for @homeAddKit.
  ///
  /// In en, this message translates to:
  /// **'Add Kit'**
  String get homeAddKit;

  /// No description provided for @homeAddKitDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect new devices'**
  String get homeAddKitDesc;

  /// No description provided for @homeSetting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get homeSetting;

  /// No description provided for @homeSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage your account'**
  String get homeSettingDesc;

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get weatherClear;

  /// No description provided for @weatherPartlyCloudy.
  ///
  /// In en, this message translates to:
  /// **'Partly cloudy'**
  String get weatherPartlyCloudy;

  /// No description provided for @weatherFoggy.
  ///
  /// In en, this message translates to:
  /// **'Foggy'**
  String get weatherFoggy;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'Drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'Snow'**
  String get weatherSnow;

  /// No description provided for @weatherRainShowers.
  ///
  /// In en, this message translates to:
  /// **'Rain showers'**
  String get weatherRainShowers;

  /// No description provided for @weatherHeavyRain.
  ///
  /// In en, this message translates to:
  /// **'Heavy rain'**
  String get weatherHeavyRain;

  /// No description provided for @weatherThunderstorm.
  ///
  /// In en, this message translates to:
  /// **'Thunderstorm'**
  String get weatherThunderstorm;

  /// No description provided for @weatherUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get weatherUnknown;

  /// No description provided for @daySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySun;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @monthJan.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJan;

  /// No description provided for @monthFeb.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFeb;

  /// No description provided for @monthMar.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMar;

  /// No description provided for @monthApr.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApr;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJun.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJun;

  /// No description provided for @monthJul.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJul;

  /// No description provided for @monthAug.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAug;

  /// No description provided for @monthSep.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSep;

  /// No description provided for @monthOct.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOct;

  /// No description provided for @monthNov.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNov;

  /// No description provided for @monthDec.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDec;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileUserId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get profileUserId;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileKitName.
  ///
  /// In en, this message translates to:
  /// **'Kit Name'**
  String get profileKitName;

  /// No description provided for @profileKitId.
  ///
  /// In en, this message translates to:
  /// **'Kit ID'**
  String get profileKitId;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profileEditProfile;

  /// No description provided for @profileDefaultKitName.
  ///
  /// In en, this message translates to:
  /// **'Your Kit Name'**
  String get profileDefaultKitName;

  /// No description provided for @profileDefaultKitId.
  ///
  /// In en, this message translates to:
  /// **'SUF-XXXX-XXXX'**
  String get profileDefaultKitId;

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello Again!'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back You\'ve Been Missed!'**
  String get authLoginSubtitle;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'example@email.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authPasswordHint;

  /// No description provided for @authRecoveryPassword.
  ///
  /// In en, this message translates to:
  /// **'Recovery Password'**
  String get authRecoveryPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get authSignIn;

  /// No description provided for @authSignInGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get authSignInGoogle;

  /// No description provided for @authNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Have An Account? '**
  String get authNoAccount;

  /// No description provided for @authSignUpFree.
  ///
  /// In en, this message translates to:
  /// **'Sign Up For Free'**
  String get authSignUpFree;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Create Account Together'**
  String get authRegisterSubtitle;

  /// No description provided for @authNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get authNameLabel;

  /// No description provided for @authNameHint.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authNameHint;

  /// No description provided for @authLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get authLocationLabel;

  /// No description provided for @authLocationHint.
  ///
  /// In en, this message translates to:
  /// **'Your city'**
  String get authLocationHint;

  /// No description provided for @authLocationError.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location. Please enter manually.'**
  String get authLocationError;

  /// No description provided for @authSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get authSignUp;

  /// No description provided for @authVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Fountaine'**
  String get authVerifyTitle;

  /// Verification email message
  ///
  /// In en, this message translates to:
  /// **'Thank you for registering.\nPlease verify your email address:\n{email}'**
  String authVerifyDesc(String email);

  /// No description provided for @authVerifyBanner.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get authVerifyBanner;

  /// No description provided for @authCopyEmail.
  ///
  /// In en, this message translates to:
  /// **'Copy Email'**
  String get authCopyEmail;

  /// No description provided for @authOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Open Email'**
  String get authOpenEmail;

  /// No description provided for @authResendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get authResendEmail;

  /// No description provided for @authRefreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get authRefreshStatus;

  /// No description provided for @authNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help?'**
  String get authNeedHelp;

  /// No description provided for @authHelpTips.
  ///
  /// In en, this message translates to:
  /// **'• Check Spam/Promotions folder.\n• Wait 1-2 minutes then press \"Refresh Status\".\n• Make sure email is correct.\n• Try \"Resend Verification Email\".'**
  String get authHelpTips;

  /// No description provided for @authBackToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get authBackToLogin;

  /// No description provided for @authLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get authLogout;

  /// No description provided for @authMustBeLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to add a kit'**
  String get authMustBeLoggedIn;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordHeader.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPasswordHeader;

  /// No description provided for @authForgotPasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email. We will send you a link to reset your password.'**
  String get authForgotPasswordDesc;

  /// No description provided for @authForgotPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'example: you@domain.com'**
  String get authForgotPasswordHint;

  /// No description provided for @authForgotPasswordInfo.
  ///
  /// In en, this message translates to:
  /// **'We will send password reset instructions to this email. Link valid for 24 hours.'**
  String get authForgotPasswordInfo;

  /// No description provided for @authForgotPasswordSend.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get authForgotPasswordSend;

  /// No description provided for @authForgotPasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get authForgotPasswordSuccess;

  /// Success message after sending reset email
  ///
  /// In en, this message translates to:
  /// **'Password reset link has been sent to {email}.\nCheck your inbox or spam folder.'**
  String authForgotPasswordSuccessMsg(String email);

  /// Error message when reset fails
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset: {error}'**
  String authForgotPasswordFailed(String error);

  /// No description provided for @authForgotPasswordTip.
  ///
  /// In en, this message translates to:
  /// **'Tip: If you don\'t receive the email, check your Spam folder or try again in a few minutes.'**
  String get authForgotPasswordTip;

  /// No description provided for @validationEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be empty'**
  String get validationEmailEmpty;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get validationEmailInvalid;

  /// No description provided for @validationNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get validationNameEmpty;

  /// No description provided for @validationLocationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Location cannot be empty'**
  String get validationLocationEmpty;

  /// No description provided for @monitorYourKit.
  ///
  /// In en, this message translates to:
  /// **'Your Kit'**
  String get monitorYourKit;

  /// No description provided for @monitorSelectKit.
  ///
  /// In en, this message translates to:
  /// **'Select Kit'**
  String get monitorSelectKit;

  /// No description provided for @monitorLongPressDelete.
  ///
  /// In en, this message translates to:
  /// **'Long press to delete'**
  String get monitorLongPressDelete;

  /// No description provided for @monitorDeleteKit.
  ///
  /// In en, this message translates to:
  /// **'Delete Kit'**
  String get monitorDeleteKit;

  /// Confirmation before deleting kit
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove \"{kitId}\" from your kit list?'**
  String monitorDeleteKitConfirm(String kitId);

  /// Success message after kit deleted
  ///
  /// In en, this message translates to:
  /// **'Kit \"{kitId}\" removed from your list'**
  String monitorKitRemoved(String kitId);

  /// No description provided for @monitorMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get monitorMode;

  /// No description provided for @monitorAuto.
  ///
  /// In en, this message translates to:
  /// **'AUTO'**
  String get monitorAuto;

  /// No description provided for @monitorManual.
  ///
  /// In en, this message translates to:
  /// **'MANUAL'**
  String get monitorManual;

  /// No description provided for @monitorAutoControlActive.
  ///
  /// In en, this message translates to:
  /// **'Auto Control Active'**
  String get monitorAutoControlActive;

  /// No description provided for @monitorAllParametersSafe.
  ///
  /// In en, this message translates to:
  /// **'All Parameters Safe'**
  String get monitorAllParametersSafe;

  /// No description provided for @monitorLatestAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Latest adjustment'**
  String get monitorLatestAdjustment;

  /// No description provided for @monitorNoAdjustmentNeeded.
  ///
  /// In en, this message translates to:
  /// **'No adjustment needed'**
  String get monitorNoAdjustmentNeeded;

  /// No description provided for @monitorStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get monitorStatusOnline;

  /// No description provided for @monitorStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get monitorStatusOffline;

  /// No description provided for @monitorLiveTime.
  ///
  /// In en, this message translates to:
  /// **'Live Time'**
  String get monitorLiveTime;

  /// No description provided for @sensorPh.
  ///
  /// In en, this message translates to:
  /// **'pH'**
  String get sensorPh;

  /// No description provided for @sensorTds.
  ///
  /// In en, this message translates to:
  /// **'TDS'**
  String get sensorTds;

  /// No description provided for @sensorHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get sensorHumidity;

  /// No description provided for @sensorAirTemp.
  ///
  /// In en, this message translates to:
  /// **'Air Temp'**
  String get sensorAirTemp;

  /// No description provided for @sensorWaterTemp.
  ///
  /// In en, this message translates to:
  /// **'Water Temp'**
  String get sensorWaterTemp;

  /// No description provided for @sensorWaterLevel.
  ///
  /// In en, this message translates to:
  /// **'Water Level'**
  String get sensorWaterLevel;

  /// No description provided for @sensorTemp.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get sensorTemp;

  /// No description provided for @actionPhUp.
  ///
  /// In en, this message translates to:
  /// **'PH UP'**
  String get actionPhUp;

  /// No description provided for @actionPhDown.
  ///
  /// In en, this message translates to:
  /// **'PH DOWN'**
  String get actionPhDown;

  /// No description provided for @actionNutrient.
  ///
  /// In en, this message translates to:
  /// **'NUTRIENT'**
  String get actionNutrient;

  /// No description provided for @actionRefill.
  ///
  /// In en, this message translates to:
  /// **'REFILL'**
  String get actionRefill;

  /// No description provided for @actionPhUpSent.
  ///
  /// In en, this message translates to:
  /// **'pH Up command sent'**
  String get actionPhUpSent;

  /// No description provided for @actionPhDownSent.
  ///
  /// In en, this message translates to:
  /// **'pH Down command sent'**
  String get actionPhDownSent;

  /// No description provided for @actionNutrientSent.
  ///
  /// In en, this message translates to:
  /// **'Nutrient command sent'**
  String get actionNutrientSent;

  /// No description provided for @actionRefillSent.
  ///
  /// In en, this message translates to:
  /// **'Refill command sent'**
  String get actionRefillSent;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyNoKitSelected.
  ///
  /// In en, this message translates to:
  /// **'No kit selected'**
  String get historyNoKitSelected;

  /// No description provided for @historySelectKitFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a kit from Monitor first'**
  String get historySelectKitFirst;

  /// No description provided for @historyNoData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get historyNoData;

  /// No description provided for @historyNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No readings for this period'**
  String get historyNoReadings;

  /// Pagination hint showing remaining items
  ///
  /// In en, this message translates to:
  /// **'Scroll to see more ({count} more)'**
  String historyScrollMore(int count);

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationTitle;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get notificationDeleteAll;

  /// No description provided for @notificationFilterInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get notificationFilterInfo;

  /// No description provided for @notificationFilterWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get notificationFilterWarning;

  /// No description provided for @notificationFilterUrgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get notificationFilterUrgent;

  /// No description provided for @notificationEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications (for this filter)'**
  String get notificationEmptyTitle;

  /// No description provided for @notificationEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'Your system is operating normally. No issues detected.'**
  String get notificationEmptyDesc;

  /// No description provided for @notificationShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get notificationShowAll;

  /// No description provided for @notificationScrollMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll to see more'**
  String get notificationScrollMore;

  /// No description provided for @notificationJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get notificationJustNow;

  /// Time ago in minutes
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String notificationMinutesAgo(int minutes);

  /// Time ago in hours
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String notificationHoursAgo(int hours);

  /// Time ago in days
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String notificationDaysAgo(int days);

  /// No description provided for @notificationNew.
  ///
  /// In en, this message translates to:
  /// **'NEW'**
  String get notificationNew;

  /// No description provided for @addKitTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Kit'**
  String get addKitTitle;

  /// No description provided for @addKitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your hydroponic kit to start monitoring.'**
  String get addKitSubtitle;

  /// No description provided for @addKitNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Kit Name'**
  String get addKitNameLabel;

  /// No description provided for @addKitNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hydroponic Monitoring System'**
  String get addKitNameHint;

  /// No description provided for @addKitIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Kit ID'**
  String get addKitIdLabel;

  /// No description provided for @addKitIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SUF-UINJKT-HM-F2000'**
  String get addKitIdHint;

  /// No description provided for @addKitSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Kit'**
  String get addKitSaveButton;

  /// No description provided for @addKitSuccess.
  ///
  /// In en, this message translates to:
  /// **'Kit added successfully'**
  String get addKitSuccess;

  /// No description provided for @addKitNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Kit name is required'**
  String get addKitNameRequired;

  /// No description provided for @addKitIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Kit ID is required'**
  String get addKitIdRequired;

  /// No description provided for @addKitIdTooShort.
  ///
  /// In en, this message translates to:
  /// **'Kit ID is too short'**
  String get addKitIdTooShort;

  /// No description provided for @bottomSheetActivePlant.
  ///
  /// In en, this message translates to:
  /// **'Active Plant'**
  String get bottomSheetActivePlant;

  /// No description provided for @bottomSheetIdealParams.
  ///
  /// In en, this message translates to:
  /// **'Ideal Parameters'**
  String get bottomSheetIdealParams;

  /// No description provided for @bottomSheetPhIdeal.
  ///
  /// In en, this message translates to:
  /// **'pH Ideal'**
  String get bottomSheetPhIdeal;

  /// No description provided for @bottomSheetNutrientIdeal.
  ///
  /// In en, this message translates to:
  /// **'Nutrient (PPM)'**
  String get bottomSheetNutrientIdeal;

  /// No description provided for @bottomSheetWaterTempIdeal.
  ///
  /// In en, this message translates to:
  /// **'Water Temp'**
  String get bottomSheetWaterTempIdeal;

  /// No description provided for @bottomSheetWaterLevelIdeal.
  ///
  /// In en, this message translates to:
  /// **'Water Level'**
  String get bottomSheetWaterLevelIdeal;

  /// No description provided for @bottomSheetViewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get bottomSheetViewDetails;

  /// No description provided for @bottomSheetNoActivePlant.
  ///
  /// In en, this message translates to:
  /// **'No active plant'**
  String get bottomSheetNoActivePlant;

  /// No description provided for @bottomSheetAddKitFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a kit to start monitoring'**
  String get bottomSheetAddKitFirst;

  /// No description provided for @plantNameLettuce.
  ///
  /// In en, this message translates to:
  /// **'Lettuce'**
  String get plantNameLettuce;

  /// No description provided for @bottomSheetWaterLevelInfo.
  ///
  /// In en, this message translates to:
  /// **'Low – High'**
  String get bottomSheetWaterLevelInfo;
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
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
