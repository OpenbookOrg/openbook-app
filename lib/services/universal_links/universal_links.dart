import 'dart:async';
import 'package:Okuna/services/universal_links/handlers/create_account_link.dart';
import 'package:Okuna/services/universal_links/handlers/email_verification_link.dart';
import 'package:Okuna/services/universal_links/handlers/password_reset_link.dart';
import 'package:flutter/cupertino.dart';
import 'package:uni_links/uni_links.dart';

class UniversalLinksService {
  late StreamSubscription _universalLinksLibSubscription;
  List<UniversalLinkHandler> _universalLinksHandlers = [
    CreateAccountLinkHandler(),
    EmailVerificationLinkHandler(),
    PasswordResetLinkHandler()
  ];
  List<String> _universalLinksQueue = [];
  bool _needsBootstrap = true;
  BuildContext? _latestContext;

  /// Should be called at the page widgets
  void digestLinksWithContext(BuildContext context) {
    _ensureIsBootstrapped();
    _universalLinksQueue.forEach(
        (String link) => _digestLinkWithContext(link: link, context: context));
    _universalLinksQueue = [];
    _latestContext = context;
  }

  void dispose() {
    _universalLinksLibSubscription.cancel();
  }

  void _ensureIsBootstrapped() {
    if (_needsBootstrap) {
      _bootstrap();
      _needsBootstrap = false;
    }
  }

  Future<Null> _bootstrap() async {
    _universalLinksLibSubscription =
        getLinksStream().listen(_onLink, onError: _onLinkError);
    try {
      String? initialLink = await getInitialLink();
      _onLink(initialLink);
    } catch (error) {
      _onLinkError(error);
    }
  }

  void _digestLinkWithContext(
      {required String link, required BuildContext context}) {
    print('Digesting universal link $link');
    _universalLinksHandlers
        .forEach((handler) => handler.handle(context: context, link: link));
  }

  void _onLink(String? link) async {
    if (link == null) return;

    if (_latestContext != null) {
      _digestLinkWithContext(link: link, context: _latestContext!);
    } else {
      _universalLinksQueue.add(link);
    }
  }

  void _onLinkError(error) {
    print('UniversalLinksService Error');
    print(error);
  }
}

abstract class UniversalLinkHandler {
  Future<void> handle({required BuildContext context, required String link});
}
