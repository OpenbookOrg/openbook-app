import 'dart:io';

import 'package:Okuna/delegates/localization_delegate.dart';
import 'package:Okuna/pages/auth/create_account/accept_step.dart';
import 'package:Okuna/pages/auth/create_account/create_account.dart';
import 'package:Okuna/pages/auth/create_account/done_step/done_step.dart';
import 'package:Okuna/pages/auth/create_account/email_step.dart';
import 'package:Okuna/pages/auth/create_account/suggested_communities/suggested_communities.dart';
import 'package:Okuna/pages/auth/create_account/username_step.dart';
import 'package:Okuna/pages/auth/reset_password/forgot_password_step.dart';
import 'package:Okuna/pages/auth/create_account/get_started.dart';
import 'package:Okuna/pages/auth/create_account/legal_step.dart';
import 'package:Okuna/pages/auth/create_account/submit_step.dart';
import 'package:Okuna/pages/auth/create_account/password_step.dart';
import 'package:Okuna/pages/auth/reset_password/reset_password_success_step.dart';
import 'package:Okuna/pages/auth/reset_password/set_new_password_step.dart';
import 'package:Okuna/pages/auth/reset_password/verify_reset_password_link_step.dart';
import 'package:Okuna/pages/auth/login.dart';
import 'package:Okuna/pages/auth/splash.dart';
import 'package:Okuna/pages/home/home.dart';
import 'package:Okuna/pages/waitlist/subscribe_done_step.dart';
import 'package:Okuna/pages/waitlist/subscribe_email_step.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/pages/auth/create_account/name_step.dart';
import 'package:Okuna/services/localization.dart';
import 'package:Okuna/services/universal_links/universal_links.dart';
import 'package:Okuna/widgets/toast.dart';
import 'package:Okuna/translation/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:flutter\_localizations/flutter\_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'dart:async';

import 'delegates/es_es_localizations_delegate.dart';
import 'delegates/pt_br_localizations_delegate.dart';
import 'delegates/sv_se_localizations_delegate.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  final openbookProviderKey = new GlobalKey<OpenbookProviderState>();

  @override
  _MyAppState createState() => _MyAppState();

  static void setLocale(BuildContext context, Locale? newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();

    state?.setState(() {
      state.locale = newLocale ?? Locale('en', 'US');
    });
  }
}

class _MyAppState extends State<MyApp> {
  Locale? locale;
  late bool _needsBootstrap;

  static const MAX_NETWORK_IMAGE_CACHE_MB = 200;
  static const MAX_NETWORK_IMAGE_CACHE_ENTRIES = 1000;

  @override
  void initState() {
    super.initState();
    _needsBootstrap = true;
  }

  void bootstrap() {
    DiskCache().maxEntries = MAX_NETWORK_IMAGE_CACHE_ENTRIES;
    //DiskCache().maxSizeBytes = MAX_NETWORK_IMAGE_CACHE_MB * 1000000; // 200mb
  }

  @override
  Widget build(BuildContext context) {
    if (_needsBootstrap) {
      bootstrap();
      _needsBootstrap = false;
    }

    var textTheme = _defaultTextTheme();
    return OpenbookProvider(
      key: widget.openbookProviderKey,
      child: OBToast(
        child: MaterialApp(
            navigatorObservers: [routeObserver],
            locale: this.locale,
            debugShowCheckedModeBanner: false,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              // if no deviceLocale use english
              if (deviceLocale == null) {
                this.locale = Locale('en', 'US');
                return this.locale;
              }
              // initialise locale from device
              if (deviceLocale != null &&
                  supportedLanguages.contains(deviceLocale.languageCode) &&
                  this.locale == null) {
                Locale supportedMatchedLocale = supportedLocales.firstWhere(
                    (Locale locale) =>
                        locale.languageCode == deviceLocale.languageCode);
                this.locale = supportedMatchedLocale;
              } else if (this.locale == null) {
                print(
                    'Locale ${deviceLocale.languageCode} not supported, defaulting to en');
                this.locale = Locale('en', 'US');
              }
              return this.locale;
            },
            title: 'Okuna',
            supportedLocales: supportedLocales,
            localizationsDelegates: [
              const LocalizationServiceDelegate(),
              GlobalCupertinoLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              const MaterialLocalizationPtBRDelegate(),
              const CupertinoLocalizationPtBRDelegate(),
              const MaterialLocalizationEsESDelegate(),
              const CupertinoLocalizationEsESDelegate(),
              const MaterialLocalizationSvSEDelegate(),
              const CupertinoLocalizationSvSEDelegate(),
            ],
            theme: new ThemeData(
                buttonTheme: ButtonThemeData(
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(2.0))),
                // This is the theme of your application.
                //
                // Try running your application with "flutter run". You'll see the
                // application has a blue toolbar. Then, without quitting the app, try
                // changing the primarySwatch below to Colors.green and then invoke
                // "hot reload" (press "r" in the console where you ran "flutter run",
                // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
                // counter didn't reset back to zero; the application is not restarted.
                primarySwatch: Colors.grey,
                fontFamily: 'NunitoSans',
                textTheme: textTheme,
                primaryTextTheme: textTheme,
                accentTextTheme: textTheme),
            routes: {
              /// The openbookProvider uses services available in the context
              /// Their connection must be bootstrapped but no other way to execute
              /// something before loading any route, therefore this ugliness.
              '/': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBHomePage();
              },
              '/auth': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthSplashPage();
              },
              '/auth/token': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthCreateAccountPage();
              },
              '/auth/get-started': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthGetStartedPage();
              },
              '/auth/legal_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBLegalStepPage();
              },
              '/auth/accept_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAcceptStepPage();
              },
              '/auth/name_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthNameStepPage();
              },
              '/auth/email_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthEmailStepPage();
              },
              '/auth/username_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthUsernameStepPage();
              },
              '/auth/password_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthPasswordStepPage();
              },
              '/auth/submit_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthSubmitPage();
              },
              '/auth/done_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthDonePage();
              },
              '/auth/suggested_communities': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBSuggestedCommunitiesPage();
              },
              '/auth/login': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthLoginPage();
              },
              '/auth/forgot_password_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthForgotPasswordPage();
              },
              '/auth/verify_reset_password_link_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthVerifyPasswordPage();
              },
              '/auth/set_new_password_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthSetNewPasswordPage();
              },
              '/auth/password_reset_success_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBAuthPasswordResetSuccessPage();
              },
              '/waitlist/subscribe_email_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                return OBWaitlistSubscribePage();
              },
              '/waitlist/subscribe_done_step': (BuildContext context) {
                bootstrapOpenbookProviderInContext(context);
                WaitlistSubscribeArguments? args =
                    ModalRoute.of(context)?.settings.arguments as WaitlistSubscribeArguments?;
                return OBWaitlistSubscribeDoneStep(count: args?.count ?? 0);
              }
            }),
      ),
    );
  }

  void bootstrapOpenbookProviderInContext(BuildContext context) {
    var openbookProvider = OpenbookProvider.of(context);
    var localizationService = LocalizationService.of(context);
    if (this.locale?.languageCode !=
        localizationService.getLocale().languageCode) {
      Future.delayed(Duration(milliseconds: 0), () {
        MyApp.setLocale(context, this.locale);
      });
    }
    openbookProvider.setLocalizationService(localizationService);
    UniversalLinksService universalLinksService =
        openbookProvider.universalLinksService;
    universalLinksService.digestLinksWithContext(context);
    openbookProvider.validationService
        .setLocalizationService(localizationService);
    openbookProvider.shareService.setContext(context);
  }
}

Future<Null> main() async {
  MyApp app = MyApp();

// Run the whole app in a zone to capture all uncaught errors.
  runZonedGuarded(() => runApp(app), (Object error, StackTrace stackTrace) {
    if (isInDebugMode) {
      print(error);
      print(stackTrace);
      print('In dev mode. Not sending report to Sentry.io.');
      return;
    }

    SentryClient? sentryClient =
        app.openbookProviderKey.currentState?.sentryClient;

    try {
      sentryClient?.captureException(
        error,
        stackTrace: stackTrace,
      );
      print('Error sent to sentry.io: $error');
    } catch (e) {
      print('Sending report to sentry.io failed: $e');
      print('Original error: $error');
    }
  });
}

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

bool get isOnDesktop {
  return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
}

TextTheme _defaultTextTheme() {
  // This text theme is merged with the default theme in the `TextData`
  // constructor. This makes sure that the emoji font is used as fallback for
  // every text that uses the default theme.
  var style;
  if (isOnDesktop) {
    style = new TextStyle(fontFamilyFallback: ['Emoji']);
  }
  return new TextTheme(
    bodyText2: style,
    bodyText1: style,
    button: style,
    caption: style,
    headline4: style,
    headline3: style,
    headline2: style,
    headline1: style,
    headline5: style,
    overline: style,
    subtitle1: style,
    subtitle2: style,
    headline6: style,
  );
}
