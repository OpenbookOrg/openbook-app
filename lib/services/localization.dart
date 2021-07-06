// ignore_for_file: non_constant_identifier_names

import 'dart:async';

import 'package:Okuna/models/user.dart';
import 'package:Okuna/provider.dart';
import 'package:Okuna/translation/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:Okuna/locale/messages_all.dart';

import '../main.dart';

class LocalizationService {
  LocalizationService(this.locale);

  final Locale locale;

  /// See README 7.c for a word on localizedLocales.
  /// These are locales where we have custom crowdin language codes like pt-BR
  /// to support Brazilian Portuguese with a particular country, say Brazil.
  static const localizedLocales = ['pt-BR', 'es-ES', 'sv-SE'];

  Future<LocalizationService> load() {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    String localeName = Intl.canonicalizedLocale(name);

    if (localizedLocales.contains(locale.languageCode)) {
      localeName = locale.languageCode;
    }

    return initializeMessages(localeName).then((bool _) {
      Intl.defaultLocale = localeName;
      return new LocalizationService(locale);
    });
  }

  static LocalizationService of(BuildContext context) {
    late StreamSubscription _onLoggedInUserChangeSubscription;
    var openbookProvider = OpenbookProvider.of(context);
    _onLoggedInUserChangeSubscription =
        openbookProvider.userService.loggedInUserChange.listen((User? newUser) {
      String? _userLanguageCode = newUser != null && newUser.hasLanguage()
          ? newUser.language?.code
          : null;
      Locale _currentLocale = Localizations.localeOf(context);
      if (_userLanguageCode != null &&
          supportedLanguages.contains(_userLanguageCode) &&
          _userLanguageCode != _currentLocale.languageCode) {
        Locale supportedMatchedLocale = supportedLocales.firstWhere(
            (Locale locale) => locale.languageCode == _userLanguageCode);
        print(
            'Overriding locale $_currentLocale with user locale: $supportedMatchedLocale');
        MyApp.setLocale(context, supportedMatchedLocale);
      }
      _onLoggedInUserChangeSubscription.cancel();
    });

    return Localizations.of<LocalizationService>(context, LocalizationService)!;
  }

  String trans(String key) {
    return Intl.message(key, name: key);
  }

  String get auth__headline {
    return Intl.message("Better social.", name: 'auth__headline');
  }

  String get auth__login {
    return Intl.message("Log in", name: 'auth__login');
  }

  String get auth__email_empty_error {
    return Intl.message("Email cannot be empty.",
        name: 'auth__email_empty_error');
  }

  String get auth__email_invalid_error {
    return Intl.message("Please provide a valid email.",
        name: 'auth__email_invalid_error');
  }

  String get auth__username_empty_error {
    return Intl.message("Username cannot be empty.",
        name: 'auth__username_empty_error');
  }

  String get auth__username_characters_error {
    return Intl.message(
        "A username can only contain alphanumeric characters and underscores.",
        name: 'auth__username_characters_error');
  }

  String auth__username_maxlength_error(int maxLength) {
    return Intl.message(
        "A username can't be longer than $maxLength characters.",
        args: [maxLength],
        name: 'auth__username_maxlength_error');
  }

  String get auth__create_account {
    return Intl.message("Sign up", name: 'auth__create_account');
  }

  String get auth__create_acc__lets_get_started {
    return Intl.message("Let's get started",
        name: 'auth__create_acc__lets_get_started');
  }

  String get auth__create_acc__welcome_to_beta {
    return Intl.message("Welcome to the Beta!",
        name: 'auth__create_acc__welcome_to_beta');
  }

  String get auth__create_acc__invalid_token {
    return Intl.message("Invalid token",
        name: 'auth__create_acc__invalid_token');
  }

  String get auth__create_acc__validating_token {
    return Intl.message("Validating token...",
        name: 'auth__create_acc__validating_token');
  }

  String get auth__create_acc__previous {
    return Intl.message("Back", name: 'auth__create_acc__previous');
  }

  String get auth__create_acc__next {
    return Intl.message("Next", name: 'auth__create_acc__next');
  }

  String get auth__create_acc__create_account {
    return Intl.message("Create account",
        name: 'auth__create_acc__create_account');
  }

  String get auth__create_acc__paste_link {
    return Intl.message("Paste your registration link below",
        name: 'auth__create_acc__paste_link');
  }

  String get auth__create_acc__paste_password_reset_link {
    return Intl.message("Paste your password reset link below",
        name: 'auth__create_acc__paste_password_reset_link');
  }

  String get auth__create_acc__paste_link_help_text {
    return Intl.message(
        "Use the link from the Join Openbook button in your invitation email.",
        name: 'auth__create_acc__paste_link_help_text');
  }

  String get auth__create_acc__link_empty_error {
    return Intl.message("Link cannot be empty.",
        name: 'auth__create_acc__link_empty_error');
  }

  String get auth__create_acc__link_invalid_error {
    return Intl.message("This link is invalid.",
        name: 'auth__create_acc__link_invalid_error');
  }

  String get auth__password_empty_error {
    return Intl.message("Password cannot be empty.",
        name: 'auth__password_empty_error');
  }

  String auth__password_range_error(int minLength, int maxLength) {
    return Intl.message(
        "Password must be between $minLength and $maxLength characters.",
        args: [minLength, maxLength],
        name: 'auth__password_range_error');
  }

  String get auth__name_empty_error {
    return Intl.message("Name cannot be empty.",
        name: 'auth__name_empty_error');
  }

  String auth__name_range_error(int minLength, int maxLength) {
    return Intl.message(
        "Name must be between $minLength and $maxLength characters.",
        args: [minLength, maxLength],
        name: 'auth__name_range_error');
  }

  String get auth__description_empty_error {
    return Intl.message("Description cannot be empty.",
        name: 'auth__description_empty_error');
  }

  String auth__description_range_error(int minLength, int maxLength) {
    return Intl.message(
        "Description must be between $minLength and $maxLength characters.",
        args: [minLength, maxLength],
        name: 'auth__description_range_error');
  }

  String get auth__reset_password_success_title {
    return Intl.message("All set!", name: 'auth__reset_password_success_title');
  }

  String get auth__reset_password_success_info {
    return Intl.message("Your password has been updated successfully",
        name: 'auth__reset_password_success_info');
  }

  String get auth__create_acc__request_invite {
    return Intl.message("No invite? Request one here.",
        name: 'auth__create_acc__request_invite');
  }

  String get auth__create_acc__subscribe {
    return Intl.message("Request", name: 'auth__create_acc__subscribe');
  }

  String get auth__create_acc__subscribe_to_waitlist_text {
    return Intl.message("Request an invite!",
        name: 'auth__create_acc__subscribe_to_waitlist_text');
  }

  String get auth__create_acc__congratulations {
    return Intl.message("Congratulations!",
        name: 'auth__create_acc__congratulations');
  }

  String get auth__create_acc__your_subscribed {
    return Intl.message("You're {0} on the waitlist.",
        name: 'auth__create_acc__your_subscribed');
  }

  String get auth__create_acc__almost_there {
    return Intl.message("Almost there...",
        name: 'auth__create_acc__almost_there');
  }

  String get auth__create_acc__what_name {
    return Intl.message("What's your name?",
        name: 'auth__create_acc__what_name');
  }

  String get auth__create_acc__name_placeholder {
    return Intl.message("James Bond",
        name: 'auth__create_acc__name_placeholder');
  }

  String get auth__create_acc__name_empty_error {
    return Intl.message("😱 Your name can't be empty.",
        name: 'auth__create_acc__name_empty_error');
  }

  String get auth__create_acc__name_length_error {
    return Intl.message(
        "😱 Your name can't be longer than 50 characters. (If it is, we're very sorry.)",
        name: 'auth__create_acc__name_length_error');
  }

  String get auth__create_acc__name_characters_error {
    return Intl.message(
        "😅 A name can only contain alphanumeric characters (for now).",
        name: 'auth__create_acc__name_characters_error');
  }

  String get auth__create_acc__what_username {
    return Intl.message("Choose a username",
        name: 'auth__create_acc__what_username');
  }

  String get auth__create_acc__username_placeholder {
    return Intl.message("pablopicasso",
        name: 'auth__create_acc__username_placeholder');
  }

  String get auth__create_acc__username_empty_error {
    return Intl.message("😱 The username can't be empty.",
        name: 'auth__create_acc__username_empty_error');
  }

  String get auth__create_acc__username_length_error {
    return Intl.message("😅 A username can't be longer than 30 characters.",
        name: 'auth__create_acc__username_length_error');
  }

  String get auth__create_acc__username_characters_error {
    return Intl.message(
        "😅 A username can only contain alphanumeric characters and underscores.",
        name: 'auth__create_acc__username_characters_error');
  }

  String get auth__create_acc__username_taken_error {
    return Intl.message("😩 The username @%s is taken.",
        name: 'auth__create_acc__username_taken_error');
  }

  String get auth__create_acc__username_server_error {
    return Intl.message(
        "😭 We're experiencing issues with our servers, please try again in a couple of minutes.",
        name: 'auth__create_acc__username_server_error');
  }

  String get auth__create_acc__what_email {
    return Intl.message("What's your email?",
        name: 'auth__create_acc__what_email');
  }

  String get auth__create_acc__email_placeholder {
    return Intl.message("john_travolta@mail.com",
        name: 'auth__create_acc__email_placeholder');
  }

  String get auth__create_acc__email_empty_error {
    return Intl.message("😱 Your email can't be empty",
        name: 'auth__create_acc__email_empty_error');
  }

  String get auth__create_acc__email_invalid_error {
    return Intl.message("😅 Please provide a valid email address.",
        name: 'auth__create_acc__email_invalid_error');
  }

  String get auth__create_acc__email_taken_error {
    return Intl.message("🤔 An account already exists for that email.",
        name: 'auth__create_acc__email_taken_error');
  }

  String get auth__create_acc__email_server_error {
    return Intl.message(
        "😭 We're experiencing issues with our servers, please try again in a couple of minutes.",
        name: 'auth__create_acc__email_server_error');
  }

  String get auth__create_acc__what_password {
    return Intl.message("Choose a password",
        name: 'auth__create_acc__what_password');
  }

  String auth__create_acc_password_hint_text(int minLength, int maxLength) {
    return Intl.message("($minLength-$maxLength characters)",
        args: [minLength, maxLength],
        name: 'auth__create_acc_password_hint_text');
  }

  String get auth__create_acc__what_password_subtext {
    return Intl.message("(min 10 chars.)",
        name: 'auth__create_acc__what_password_subtext');
  }

  String get auth__create_acc__password_empty_error {
    return Intl.message("😱 Your password can't be empty",
        name: 'auth__create_acc__password_empty_error');
  }

  String get auth__create_acc__password_length_error {
    return Intl.message("😅 A password must be between 8 and 64 characters.",
        name: 'auth__create_acc__password_length_error');
  }

  String get auth__create_acc__what_avatar {
    return Intl.message("Choose a profile picture",
        name: 'auth__create_acc__what_avatar');
  }

  String get auth__create_acc__avatar_tap_to_change {
    return Intl.message("Tap to change",
        name: 'auth__create_acc__avatar_tap_to_change');
  }

  String get auth__create_acc__avatar_choose_camera {
    return Intl.message("Take a photo",
        name: 'auth__create_acc__avatar_choose_camera');
  }

  String get auth__create_acc__avatar_choose_gallery {
    return Intl.message("Use an existing photo",
        name: 'auth__create_acc__avatar_choose_gallery');
  }

  String get auth__create_acc__avatar_remove_photo {
    return Intl.message("Remove photo",
        name: 'auth__create_acc__avatar_remove_photo');
  }

  String get auth__create_acc__done {
    return Intl.message("Create account", name: 'auth__create_acc__done');
  }

  String get auth__create_acc__done_subtext {
    return Intl.message("You can change this in your profile settings.",
        name: 'auth__create_acc__done_subtext');
  }

  String get auth__create_acc__done_created {
    return Intl.message("Your account has been created.",
        name: 'auth__create_acc__done_created');
  }

  String get auth__create_acc__suggested_communities {
    return Intl.message("🥳 Get started by joining the following communities.",
        name: 'auth__create_acc__suggested_communities');
  }

  String get auth__create_acc__submit_loading_title {
    return Intl.message("Hang in there!",
        name: 'auth__create_acc__submit_loading_title');
  }

  String get auth__create_acc__submit_loading_desc {
    return Intl.message("We're creating your account.",
        name: 'auth__create_acc__submit_loading_desc');
  }

  String get auth__create_acc__submit_error_title {
    return Intl.message("Oh no...",
        name: 'auth__create_acc__submit_error_title');
  }

  String get auth__create_acc__submit_error_desc_server {
    return Intl.message(
        "😭 We're experiencing issues with our servers, please try again in a couple of minutes.",
        name: 'auth__create_acc__submit_error_desc_server');
  }

  String get auth__create_acc__submit_error_desc_validation {
    return Intl.message(
        "😅 It looks like some of the information was not right, please check and try again.",
        name: 'auth__create_acc__submit_error_desc_validation');
  }

  String get auth__create_acc__done_title {
    return Intl.message("Hooray!", name: 'auth__create_acc__done_title');
  }

  String get auth__create_acc__done_description {
    return Intl.message("Your account has been created.",
        name: 'auth__create_acc__done_description');
  }

  String get auth__create_acc__your_username_is {
    return Intl.message("Your user name is ",
        name: 'auth__create_acc__your_username_is');
  }

  String get auth__create_acc__can_change_username {
    return Intl.message(
        "If you wish, you can change it anytime via your profile page.",
        name: 'auth__create_acc__can_change_username');
  }

  String get auth__create_acc__done_continue {
    return Intl.message("Login", name: 'auth__create_acc__done_continue');
  }

  String get auth__create_acc__legal_confirmation {
    return Intl.message("Legal confirmation",
        name: 'auth__create_acc__legal_confirmation');
  }

  String get auth__create_acc__legal_confirmation_desc {
    return Intl.message(
        "By registering in Okuna, I certify that I'm older than 16 years old and have read the Community Guidelines, Privacy Policy and Terms of Use and agree to all of the items included",
        name: 'auth__create_acc__legal_confirmation_desc');
  }

  String get auth__create_acc__legal {
    return Intl.message("The important stuff", name: 'auth__create_acc__legal');
  }

  String get auth__create_acc__legal_desc {
    return Intl.message(
        "Please take a moment to read through the following documents",
        name: 'auth__create_acc__legal_desc');
  }

  String get auth__create_acc__legal_desc_extra {
    return Intl.message(
        "They contain important information about your experience in Okuna and you will have to accept to them",
        name: 'auth__create_acc__legal_desc_extra');
  }

  String get auth__create_acc__register {
    return Intl.message("Register", name: 'auth__create_acc__register');
  }

  String get auth__create_acc__are_you_legal_age {
    return Intl.message("Are you older than 16 years?",
        name: 'auth__create_acc__are_you_legal_age');
  }

  String get auth__login__login {
    return Intl.message("Continue", name: 'auth__login__login');
  }

  String get auth__login__previous {
    return Intl.message("Previous", name: 'auth__login__previous');
  }

  String get auth__login__title {
    return Intl.message("Welcome back!", name: 'auth__login__title');
  }

  String get auth__login__subtitle {
    return Intl.message("Enter your credentials to continue.",
        name: 'auth__login__subtitle');
  }

  String get auth__login__forgot_password {
    return Intl.message("Forgot password",
        name: 'auth__login__forgot_password');
  }

  String get auth__login__forgot_password_subtitle {
    return Intl.message("Enter your email",
        name: 'auth__login__forgot_password_subtitle');
  }

  String get auth__login__username_label {
    return Intl.message("Username", name: 'auth__login__username_label');
  }

  String get auth__login__password_label {
    return Intl.message("Password", name: 'auth__login__password_label');
  }

  String get auth__login__email_label {
    return Intl.message("Email", name: 'auth__login__email_label');
  }

  String get auth__login__password_empty_error {
    return Intl.message("Password is required.",
        name: 'auth__login__password_empty_error');
  }

  String get auth__login__password_length_error {
    return Intl.message("Password must be between 8 and 64 characters.",
        name: 'auth__login__password_length_error');
  }

  String get auth__login__username_empty_error {
    return Intl.message("Username is required.",
        name: 'auth__login__username_empty_error');
  }

  String get auth__login__username_length_error {
    return Intl.message("Username can't be longer than 30 characters.",
        name: 'auth__login__username_length_error');
  }

  String get auth__login__username_characters_error {
    return Intl.message(
        "Username can only contain alphanumeric characters and underscores.",
        name: 'auth__login__username_characters_error');
  }

  String get auth__login__credentials_mismatch_error {
    return Intl.message("The provided credentials do not match.",
        name: 'auth__login__credentials_mismatch_error');
  }

  String get auth__login__server_error {
    return Intl.message(
        "Uh oh.. We're experiencing server issues. Please try again in a few minutes.",
        name: 'auth__login__server_error');
  }

  String get auth__login__connection_error {
    return Intl.message(
        "We can't reach our servers. Are you connected to the internet?",
        name: 'auth__login__connection_error');
  }

  String get auth__change_password_title {
    return Intl.message("Change password", name: 'auth__change_password_title');
  }

  String get auth__change_password_current_pwd {
    return Intl.message("Current password",
        name: 'auth__change_password_current_pwd');
  }

  String get auth__change_password_current_pwd_hint {
    return Intl.message("Enter your current password",
        name: 'auth__change_password_current_pwd_hint');
  }

  String get auth__change_password_current_pwd_incorrect {
    return Intl.message("Entered password was incorrect",
        name: 'auth__change_password_current_pwd_incorrect');
  }

  String get auth__change_password_new_pwd {
    return Intl.message("New password", name: 'auth__change_password_new_pwd');
  }

  String get auth__change_password_new_pwd_hint {
    return Intl.message("Enter your new password",
        name: 'auth__change_password_new_pwd_hint');
  }

  String get auth__change_password_new_pwd_error {
    return Intl.message(
        "Please ensure password is between 10 and 100 characters long",
        name: 'auth__change_password_new_pwd_error');
  }

  String get auth__change_password_save_text {
    return Intl.message("Save", name: 'auth__change_password_save_text');
  }

  String get auth__change_password_save_success {
    return Intl.message("All good! Your password has been updated",
        name: 'auth__change_password_save_success');
  }

  String get drawer__menu_title {
    return Intl.message("Menu", name: 'drawer__menu_title');
  }

  String get drawer__main_title {
    return Intl.message("My Okuna", name: 'drawer__main_title');
  }

  String get drawer__my_circles {
    return Intl.message("My circles", name: 'drawer__my_circles');
  }

  String get drawer__my_lists {
    return Intl.message("My lists", name: 'drawer__my_lists');
  }

  String get drawer__my_followers {
    return Intl.message("My followers", name: 'drawer__my_followers');
  }

  String get drawer__my_following {
    return Intl.message("My following", name: 'drawer__my_following');
  }

  String get drawer__my_invites {
    return Intl.message("My invites", name: 'drawer__my_invites');
  }

  String get drawer__my_pending_mod_tasks {
    return Intl.message("My pending moderation tasks",
        name: 'drawer__my_pending_mod_tasks');
  }

  String get drawer__my_mod_penalties {
    return Intl.message("My moderation penalties",
        name: 'drawer__my_mod_penalties');
  }

  String get drawer__app_account_text {
    return Intl.message("App & Account", name: 'drawer__app_account_text');
  }

  String get drawer__themes {
    return Intl.message("Themes", name: 'drawer__themes');
  }

  String get drawer__global_moderation {
    return Intl.message("Global moderation", name: 'drawer__global_moderation');
  }

  String get drawer__profile {
    return Intl.message("Profile", name: 'drawer__profile');
  }

  String get drawer__connections {
    return Intl.message("My connections", name: 'drawer__connections');
  }

  String get drawer__lists {
    return Intl.message("My lists", name: 'drawer__lists');
  }

  String get drawer__settings {
    return Intl.message("Settings", name: 'drawer__settings');
  }

  String get drawer__application_settings {
    return Intl.message("Application Settings",
        name: 'drawer__application_settings');
  }

  String get drawer__account_settings {
    return Intl.message("Account Settings", name: 'drawer__account_settings');
  }

  String get drawer__developer_settings {
    return Intl.message("Developer Settings",
        name: 'drawer__developer_settings');
  }

  String get drawer__account_settings_change_email {
    return Intl.message("Change Email",
        name: 'drawer__account_settings_change_email');
  }

  String get drawer__account_settings_change_password {
    return Intl.message("Change Password",
        name: 'drawer__account_settings_change_password');
  }

  String get drawer__account_settings_notifications {
    return Intl.message("Notifications",
        name: 'drawer__account_settings_notifications');
  }

  String get drawer__account_settings_language_text {
    return Intl.message("Language",
        name: 'drawer__account_settings_language_text');
  }

  String drawer__account_settings_language(String currentUserLanguage) {
    return Intl.message("Language ($currentUserLanguage)",
        args: [currentUserLanguage], name: 'drawer__account_settings_language');
  }

  String get drawer__account_settings_blocked_users {
    return Intl.message("Blocked users",
        name: 'drawer__account_settings_blocked_users');
  }

  String get drawer__account_settings_delete_account {
    return Intl.message("Delete account",
        name: 'drawer__account_settings_delete_account');
  }

  String get drawer__help {
    return Intl.message("Support & Feedback", name: 'drawer__help');
  }

  String get drawer__customize {
    return Intl.message("Customize", name: 'drawer__customize');
  }

  String get drawer__about {
    return Intl.message("About", name: 'drawer__about');
  }

  String drawer__about_platform(String platform) {
    return Intl.message("Running on $platform",
        args: [platform], name: 'drawer__about_platform');
  }

  String get drawer__logout {
    return Intl.message("Log out", name: 'drawer__logout');
  }

  String get drawer__useful_links_title {
    return Intl.message("Useful links", name: 'drawer__useful_links_title');
  }

  String get drawer__useful_links_guidelines {
    return Intl.message("Platform guidelines",
        name: 'drawer__useful_links_guidelines');
  }

  String get drawer__useful_links_guidelines_desc {
    return Intl.message(
        "The guidelines we're all expected to follow for a healthy and friendly co-existence.",
        name: 'drawer__useful_links_guidelines_desc');
  }

  String get drawer__useful_links_privacy_policy {
    return Intl.message("Privacy policy",
        name: 'drawer__useful_links_privacy_policy');
  }

  String get drawer__useful_links_privacy_policy_desc {
    return Intl.message(
        "The legal document explaining how we take care of your data and more.",
        name: 'drawer__useful_links_privacy_policy_desc');
  }

  String get drawer__useful_links_terms_of_use {
    return Intl.message("Terms of use",
        name: 'drawer__useful_links_terms_of_use');
  }

  String get drawer__useful_links_terms_of_use_desc {
    return Intl.message(
        "The legal agreement between you and Okuna you must abide to in order to have access to the platform",
        name: 'drawer__useful_links_terms_of_use_desc');
  }

  String get drawer__useful_links_guidelines_github {
    return Intl.message("Github project board",
        name: 'drawer__useful_links_guidelines_github');
  }

  String get drawer__useful_links_guidelines_github_desc {
    return Intl.message("Take a look at what we're currently working on",
        name: 'drawer__useful_links_guidelines_github_desc');
  }

  String get drawer__useful_links_guidelines_roadmap {
    return Intl.message("The Okuna roadmap",
        name: 'drawer__useful_links_guidelines_roadmap');
  }

  String get drawer__useful_links_guidelines_roadmap_desc {
    return Intl.message(
        "Take a look at what we're planning to do in the future",
        name: 'drawer__useful_links_guidelines_roadmap_desc');
  }

  String get drawer__useful_links_guidelines_feature_requests {
    return Intl.message("Feature requests",
        name: 'drawer__useful_links_guidelines_feature_requests');
  }

  String get drawer__useful_links_guidelines_feature_requests_desc {
    return Intl.message("Request a feature or upvote existing requests",
        name: 'drawer__useful_links_guidelines_feature_requests_desc');
  }

  String get drawer__useful_links_guidelines_bug_tracker {
    return Intl.message("Bug tracker",
        name: 'drawer__useful_links_guidelines_bug_tracker');
  }

  String get drawer__useful_links_guidelines_bug_tracker_desc {
    return Intl.message("Report a bug or upvote existing bugs",
        name: 'drawer__useful_links_guidelines_bug_tracker_desc');
  }

  String get drawer__useful_links_guidelines_handbook {
    return Intl.message("Okuna user guide",
        name: 'drawer__useful_links_guidelines_handbook');
  }

  String get drawer__useful_links_guidelines_handbook_desc {
    return Intl.message(
        "A book with everything there is to know about using the platform",
        name: 'drawer__useful_links_guidelines_handbook_desc');
  }

  String get drawer__useful_links_support {
    return Intl.message("Support Okuna", name: 'drawer__useful_links_support');
  }

  String get drawer__useful_links_support_desc {
    return Intl.message("Find a way you can support us on our journey!",
        name: 'drawer__useful_links_support_desc');
  }

  String get drawer__useful_links_slack_channel {
    return Intl.message("Community Slack channel",
        name: 'drawer__useful_links_slack_channel');
  }

  String get drawer__useful_links_community_guidelines {
    return Intl.message("Community guidelines",
        name: 'drawer__useful_links_community_guidelines');
  }

  String get drawer__useful_links_slack_channel_desc {
    return Intl.message("A place to discuss everything about Okuna",
        name: 'drawer__useful_links_slack_channel_desc');
  }

  String get error__unknown_error {
    return Intl.message("Unknown error", name: 'error__unknown_error');
  }

  String error__receive_share_text_too_long(int limit) {
    return Intl.message("Text is too long (limit: $limit characters)",
        args: [limit], name: 'error__receive_share_text_too_long');
  }

  String get error__receive_share_temp_write_failed {
    return Intl.message('Failed to copy shared file to temporary location',
        name: 'error__receive_share_temp_write_failed');
  }

  String get error__receive_share_temp_write_denied {
    return Intl.message(
        'Denied permission to copy shared file to temporary location',
        name: 'error__receive_share_temp_write_denied');
  }

  String get error__receive_share_invalid_uri_scheme {
    return Intl.message('Failed to receive share',
        name: 'error__receive_share_invalid_uri_scheme');
  }

  String get error__receive_share_file_not_found {
    return Intl.message('Shared file could not be found',
        name: 'error__receive_share_file_not_found');
  }

  String get error__no_internet_connection {
    return Intl.message("No internet connection",
        name: 'error__no_internet_connection');
  }

  String get community__no {
    return Intl.message("No", name: 'community__no');
  }

  String get community__yes {
    return Intl.message("Yes", name: 'community__yes');
  }

  String get community__button_staff {
    return Intl.message("Staff", name: 'community__button_staff');
  }

  String get community__button_rules {
    return Intl.message("Rules", name: 'community__button_rules');
  }

  String get community__community {
    return Intl.message("community", name: 'community__community');
  }

  String get community__communities {
    return Intl.message("communities", name: 'community__communities');
  }

  String get community__excluded_community {
    return Intl.message("hidden community",
        name: 'community__excluded_community');
  }

  String get community__excluded_communities {
    return Intl.message("hidden communities",
        name: 'community__excluded_communities');
  }

  String get community__exclude_joined_communities {
    return Intl.message("Exclude joined communities",
        name: 'community__exclude_joined_communities');
  }

  String get community__exclude_joined_communities_desc {
    return Intl.message("Don't show posts from communities I'm a member of",
        name: 'community__exclude_joined_communities_desc');
  }

  String get community__type_public {
    return Intl.message("Public", name: 'community__type_public');
  }

  String get community__type_private {
    return Intl.message("Private", name: 'community__type_private');
  }

  String get community__member_capitalized {
    return Intl.message("Member", name: 'community__member_capitalized');
  }

  String get community__members_capitalized {
    return Intl.message("Members", name: 'community__members_capitalized');
  }

  String get community__details_favorite {
    return Intl.message("In favorites", name: 'community__details_favorite');
  }

  String get community__admin_desc {
    return Intl.message(
        "This will allow the member to edit the community details, administrators, moderators and banned users.",
        name: 'community__admin_desc');
  }

  String get community__confirmation_title {
    return Intl.message("Confirmation", name: 'community__confirmation_title');
  }

  String get community__retry_loading_posts {
    return Intl.message("Tap to retry", name: 'community__retry_loading_posts');
  }

  String community__admin_add_confirmation(String username) {
    return Intl.message(
        "Are you sure you want to add @$username as a community administrator?",
        args: [username],
        name: 'community__admin_add_confirmation');
  }

  String community__ban_confirmation(String username) {
    return Intl.message("Are you sure you want to ban @$username?",
        args: [username], name: 'community__ban_confirmation');
  }

  String get community__ban_desc {
    return Intl.message(
        "This will remove the user from the community and disallow them from joining again.",
        name: 'community__ban_desc');
  }

  String community__moderator_add_confirmation(String username) {
    return Intl.message(
        "Are you sure you want to add @$username as a community moderator?",
        args: [username],
        name: 'community__moderator_add_confirmation');
  }

  String get community__moderator_desc {
    return Intl.message(
        "This will allow the member to edit the community details, moderators and banned users.",
        name: 'community__moderator_desc');
  }

  String get community__moderators_you {
    return Intl.message("You", name: 'community__moderators_you');
  }

  String get community__moderators_title {
    return Intl.message("Moderators", name: 'community__moderators_title');
  }

  String get community__leave_desc {
    return Intl.message(
        "You won't see its posts in your timeline nor will be able to post to it anymore.",
        name: 'community__leave_desc');
  }

  String get community__leave_confirmation {
    return Intl.message("Are you sure you want to leave the community?",
        name: 'community__leave_confirmation');
  }

  String get community__moderator_resource_name {
    return Intl.message("moderator",
        name: 'community__moderator_resource_name');
  }

  String get community__moderators_resource_name {
    return Intl.message("moderators",
        name: 'community__moderators_resource_name');
  }

  String get community__add_moderator_title {
    return Intl.message("Add moderator",
        name: 'community__add_moderator_title');
  }

  String get community__delete_confirmation {
    return Intl.message("Are you sure you want to delete the community?",
        name: 'community__delete_confirmation');
  }

  String get community__delete_desc {
    return Intl.message(
        "You won't see it's posts in your timeline nor will be able to post to it anymore.",
        name: 'community__delete_desc');
  }

  String get community__actions_manage_text {
    return Intl.message("Manage", name: 'community__actions_manage_text');
  }

  String get community__manage_title {
    return Intl.message("Manage community", name: 'community__manage_title');
  }

  String get community__manage_details_title {
    return Intl.message("Details", name: 'community__manage_details_title');
  }

  String get community__manage_details_desc {
    return Intl.message("Change the title, name, avatar, cover photo and more.",
        name: 'community__manage_details_desc');
  }

  String get community__manage_admins_title {
    return Intl.message("Administrators",
        name: 'community__manage_admins_title');
  }

  String get community__manage_admins_desc {
    return Intl.message("See, add and remove administrators.",
        name: 'community__manage_admins_desc');
  }

  String get community__manage_mods_title {
    return Intl.message("Moderators", name: 'community__manage_mods_title');
  }

  String get community__manage_mods_desc {
    return Intl.message("See, add and remove moderators.",
        name: 'community__manage_mods_desc');
  }

  String get community__manage_banned_title {
    return Intl.message("Banned users", name: 'community__manage_banned_title');
  }

  String get community__manage_banned_desc {
    return Intl.message("See, add and remove banned users.",
        name: 'community__manage_banned_desc');
  }

  String get community__manage_mod_reports_title {
    return Intl.message("Moderation reports",
        name: 'community__manage_mod_reports_title');
  }

  String get community__manage_mod_reports_desc {
    return Intl.message("Review the community moderation reports.",
        name: 'community__manage_mod_reports_desc');
  }

  String get community__manage_closed_posts_title {
    return Intl.message("Closed posts",
        name: 'community__manage_closed_posts_title');
  }

  String get community__manage_closed_posts_desc {
    return Intl.message("See and manage closed posts",
        name: 'community__manage_closed_posts_desc');
  }

  String get community__manage_invite_title {
    return Intl.message("Invite people",
        name: 'community__manage_invite_title');
  }

  String get community__manage_invite_desc {
    return Intl.message(
        "Invite your connections and followers to join the community.",
        name: 'community__manage_invite_desc');
  }

  String get community__manage_delete_title {
    return Intl.message("Delete community",
        name: 'community__manage_delete_title');
  }

  String get community__manage_delete_desc {
    return Intl.message("Delete the community, forever.",
        name: 'community__manage_delete_desc');
  }

  String get community__manage_leave_title {
    return Intl.message("Leave community",
        name: 'community__manage_leave_title');
  }

  String get community__manage_leave_desc {
    return Intl.message("Leave the community.",
        name: 'community__manage_leave_desc');
  }

  String get community__manage_add_favourite {
    return Intl.message("Add the community to your favorites",
        name: 'community__manage_add_favourite');
  }

  String get community__manage_remove_favourite {
    return Intl.message("Remove the community from your favorites",
        name: 'community__manage_remove_favourite');
  }

  String get community__manage_enable_new_post_notifications {
    return Intl.message("Enable new post notifications",
        name: 'community__manage_enable_new_post_notifications');
  }

  String get community__manage_disable_new_post_notifications {
    return Intl.message("Disable new post notifications",
        name: 'community__manage_disable_new_post_notifications');
  }

  String get community__is_private {
    return Intl.message("This community is private.",
        name: 'community__is_private');
  }

  String get community__invited_by_member {
    return Intl.message("You must be invited by a member.",
        name: 'community__invited_by_member');
  }

  String get community__invited_by_moderator {
    return Intl.message("You must be invited by a moderator.",
        name: 'community__invited_by_moderator');
  }

  String get community__refreshing {
    return Intl.message("Refreshing community", name: 'community__refreshing');
  }

  String get community__posts {
    return Intl.message("Posts", name: 'community__posts');
  }

  String get community__about {
    return Intl.message("About", name: 'community__about');
  }

  String get community__category {
    return Intl.message("category.", name: 'community__category');
  }

  String get community__categories {
    return Intl.message("categories.", name: 'community__categories');
  }

  String get community__add_administrators_title {
    return Intl.message("Add administrator",
        name: 'community__add_administrators_title');
  }

  String get community__community_members {
    return Intl.message("Community members",
        name: 'community__community_members');
  }

  String get community__member {
    return Intl.message("member",
        desc:
            'Currently not used in app, reserved for potential use. Could be used as: Showing 1 member',
        name: 'community__member');
  }

  String get community__member_plural {
    return Intl.message("members",
        desc: 'See all members ,Search all members',
        name: 'community__member_plural');
  }

  String get community__administrators_title {
    return Intl.message("Administrators",
        name: 'community__administrators_title');
  }

  String get community__administrator_text {
    return Intl.message("administrator",
        desc:
            'Currently unsused, reserved for potential use. Could be used as Showing 1 administrator',
        name: 'community__administrator_text');
  }

  String get community__administrator_plural {
    return Intl.message("administrators",
        desc:
            'Egs. Search administrators, See list_search_text in user_search.arb ',
        name: 'community__administrator_plural');
  }

  String get community__administrator_you {
    return Intl.message("You", name: 'community__administrator_you');
  }

  String get community__user_you_text {
    return Intl.message("You", name: 'community__user_you_text');
  }

  String get community__tile_delete {
    return Intl.message("Delete", name: 'community__tile_delete');
  }

  String community__pick_upto_max(int max) {
    return Intl.message("Pick up to $max categories",
        args: [max], name: 'community__pick_upto_max');
  }

  String community__pick_atleast_min_category(int min) {
    return Intl.message("You must pick at least $min category.",
        args: [min],
        desc: 'You must pick at least 1 category',
        name: 'community__pick_atleast_min_category');
  }

  String community__pick_atleast_min_categories(int min) {
    return Intl.message("You must pick at least $min categories.",
        args: [min],
        desc:
            'Eg. Variable min will be 3-5. You must pick at least (3-5) categories',
        name: 'community__pick_atleast_min_categories');
  }

  String get community__ban_user_title {
    return Intl.message("Ban user", name: 'community__ban_user_title');
  }

  String get community__banned_users_title {
    return Intl.message("Banned users", name: 'community__banned_users_title');
  }

  String get community__banned_user_text {
    return Intl.message("banned user",
        desc:
            'Currently unsused, reserved for potential use. Could be used as Showing 1 banned user',
        name: 'community__banned_user_text');
  }

  String get community__banned_users_text {
    return Intl.message("banned users",
        desc:
            'Egs. Search banned users, See list_search_text in user_search.arb ',
        name: 'community__banned_users_text');
  }

  String get community__favorites_title {
    return Intl.message("Favorites", name: 'community__favorites_title');
  }

  String get community__favorite_community {
    return Intl.message("favorite community",
        desc:
            'Currently unsused, reserved for potential use. Could be used as Showing 1 favorite community',
        name: 'community__favorite_community');
  }

  String get community__favorite_communities {
    return Intl.message("favorite communities",
        desc:
            'Egs. Search favorite communities, See list_search_text in user_search.arb ',
        name: 'community__favorite_communities');
  }

  String get community__administrated_title {
    return Intl.message("Administrated",
        name: 'community__administrated_title');
  }

  String get community__administrated_community {
    return Intl.message("administrated community",
        desc:
            'Currently unsused, reserved for potential use. Could be used as Showing 1 administrated community',
        name: 'community__administrated_community');
  }

  String get community__administrated_communities {
    return Intl.message("administrated communities",
        desc:
            'Egs. Search administrated communities, See list_search_text in user_search.arb ',
        name: 'community__administrated_communities');
  }

  String get community__moderated_title {
    return Intl.message("Moderated", name: 'community__moderated_title');
  }

  String get community__moderated_community {
    return Intl.message("moderated community",
        desc:
            'Currently unsused, reserved for potential use. Could be used as Showing 1 moderated community',
        name: 'community__moderated_community');
  }

  String get community__moderated_communities {
    return Intl.message("moderated communities",
        desc:
            'Egs. Search moderated communities, See list_search_text in user_search.arb ',
        name: 'community__moderated_communities');
  }

  String get community__joined_title {
    return Intl.message("Joined", name: 'community__joined_title');
  }

  String get community__joined_community {
    return Intl.message("joined community",
        desc:
            'Currently unsused, reserved for potential use. Could be used as Showing 1 joined community',
        name: 'community__joined_community');
  }

  String get community__joined_communities {
    return Intl.message("joined communities",
        desc:
            'Egs. Search joined communities, See list_search_text in user_search.arb ',
        name: 'community__joined_communities');
  }

  String get community__join_communities_desc {
    return Intl.message("Join communities to see this tab come to life!",
        name: 'community__join_communities_desc');
  }

  String get community__refresh_text {
    return Intl.message("Refresh", name: 'community__refresh_text');
  }

  String get community__trending_none_found {
    return Intl.message(
        "No trending communities found. Try again in a few minutes.",
        name: 'community__trending_none_found');
  }

  String get community__trending_refresh {
    return Intl.message("Refresh", name: 'community__trending_refresh');
  }

  String get community__trending_in_all {
    return Intl.message("Trending in all categories",
        name: 'community__trending_in_all');
  }

  String community__trending_in_category(String categoryName) {
    return Intl.message("Trending in $categoryName",
        args: [categoryName], name: 'community__trending_in_category');
  }

  String get community__communities_title {
    return Intl.message("Communities", name: 'community__communities_title');
  }

  String get community__communities_no_category_found {
    return Intl.message(
        "No categories found. Please try again in a few minutes.",
        name: 'community__communities_no_category_found');
  }

  String get community__communities_refresh_text {
    return Intl.message("Refresh", name: 'community__communities_refresh_text');
  }

  String get community__communities_all_text {
    return Intl.message("All", name: 'community__communities_all_text');
  }

  String get community__invite_to_community_title {
    return Intl.message("Invite to community",
        name: 'community__invite_to_community_title');
  }

  String get community__invite_to_community_resource_singular {
    return Intl.message("connection or follower",
        desc:
            'Currently unsused, reserved for potential use. Could be used as Showing 1 connection or follower',
        name: 'community__invite_to_community_resource_singular');
  }

  String get community__invite_to_community_resource_plural {
    return Intl.message("connections and followers",
        desc:
            'Egs. Search connections and followers, See list_search_text in user_search.arb ',
        name: 'community__invite_to_community_resource_plural');
  }

  String get community__favorite_action {
    return Intl.message("Favorite community",
        name: 'community__favorite_action');
  }

  String get community__unfavorite_action {
    return Intl.message("Unfavorite community",
        name: 'community__unfavorite_action');
  }

  String get community__save_community_label_title {
    return Intl.message("Title", name: 'community__save_community_label_title');
  }

  String get community__save_community_label_title_hint_text {
    return Intl.message("e.g. Travel, Photography, Gaming.",
        name: 'community__save_community_label_title_hint_text');
  }

  String get community__save_community_name_title {
    return Intl.message("Name", name: 'community__save_community_name_title');
  }

  String get community__save_community_name_title_hint_text {
    return Intl.message(" e.g. travel, photography, gaming.",
        name: 'community__save_community_name_title_hint_text');
  }

  String community__save_community_name_taken(String takenName) {
    return Intl.message("Community name '$takenName' is taken",
        args: [takenName], name: 'community__save_community_name_taken');
  }

  String get community__save_community_name_label_color {
    return Intl.message("Color",
        name: 'community__save_community_name_label_color');
  }

  String get community__save_community_name_label_color_hint_text {
    return Intl.message("(Tap to change)",
        name: 'community__save_community_name_label_color_hint_text');
  }

  String get community__save_community_name_label_type {
    return Intl.message("Type",
        name: 'community__save_community_name_label_type');
  }

  String get community__save_community_name_label_type_hint_text {
    return Intl.message("(Tap to change)",
        name: 'community__save_community_name_label_type_hint_text');
  }

  String get community__community_type_private_community_hint_text {
    return Intl.message(
        "Note: Private communities cannot be later changed to Public",
        name: 'community__community_type_private_community_hint_text');
  }

  String get community__save_community_name_member_invites {
    return Intl.message("Member invites",
        name: 'community__save_community_name_member_invites');
  }

  String get community__save_community_name_member_invites_subtitle {
    return Intl.message("Members can invite people to the community",
        name: 'community__save_community_name_member_invites_subtitle');
  }

  String get community__save_community_name_category {
    return Intl.message("Category",
        name: 'community__save_community_name_category');
  }

  String get community__save_community_name_label_desc_optional {
    return Intl.message("Description · Optional",
        name: 'community__save_community_name_label_desc_optional');
  }

  String get community__save_community_name_label_desc_optional_hint_text {
    return Intl.message("What is your community about?",
        name: 'community__save_community_name_label_desc_optional_hint_text');
  }

  String get community__save_community_name_label_rules_optional {
    return Intl.message("Rules · Optional",
        name: 'community__save_community_name_label_rules_optional');
  }

  String get community__save_community_name_label_rules_optional_hint_text {
    return Intl.message("Is there something you would like your users to know?",
        name: 'community__save_community_name_label_rules_optional_hint_text');
  }

  String get community__save_community_name_label_member_adjective {
    return Intl.message("Member adjective · Optional",
        name: 'community__save_community_name_label_member_adjective');
  }

  String get community__save_community_name_label_member_adjective_hint_text {
    return Intl.message("e.g. traveler, photographer, gamer.",
        name:
            'community__save_community_name_label_member_adjective_hint_text');
  }

  String get community__save_community_name_label_members_adjective {
    return Intl.message("Members adjective · Optional",
        name: 'community__save_community_name_label_members_adjective');
  }

  String get community__save_community_name_label_members_adjective_hint_text {
    return Intl.message("e.g. travelers, photographers, gamers.",
        name:
            'community__save_community_name_label_members_adjective_hint_text');
  }

  String get community__save_community_edit_community {
    return Intl.message("Edit community",
        name: 'community__save_community_edit_community');
  }

  String get community__save_community_create_community {
    return Intl.message("Create community",
        name: 'community__save_community_create_community');
  }

  String get community__save_community_save_text {
    return Intl.message("Save", name: 'community__save_community_save_text');
  }

  String get community__save_community_create_text {
    return Intl.message("Create",
        name: 'community__save_community_create_text');
  }

  String get community__actions_invite_people_title {
    return Intl.message("Invite people to community",
        name: 'community__actions_invite_people_title');
  }

  String get community__actions_enable_new_post_notifications_title {
    return Intl.message("Enable new post notifications",
        name: 'community__actions_enable_new_post_notifications_title');
  }

  String get community__actions_enable_new_post_notifications_success {
    return Intl.message("New post notifications enabled",
        name: 'community__actions_enable_new_post_notifications_success');
  }

  String get community__actions_disable_new_post_notifications_title {
    return Intl.message("Disable new post notifications",
        name: 'community__actions_disable_new_post_notifications_title');
  }

  String get community__actions_disable_new_post_notifications_success {
    return Intl.message("New post notifications enabled",
        name: 'community__actions_disable_new_post_notifications_success');
  }

  String get community__join_community {
    return Intl.message("Join", name: 'community__join_community');
  }

  String get community__leave_community {
    return Intl.message("Leave", name: 'community__leave_community');
  }

  String get community__community_staff {
    return Intl.message("Community staff", name: 'community__community_staff');
  }

  String get community__post_singular {
    return Intl.message("post", name: 'community__post_singular');
  }

  String get community__post_plural {
    return Intl.message("posts", name: 'community__post_plural');
  }

  String get community__rules_title {
    return Intl.message("Community rules", name: 'community__rules_title');
  }

  String get community__rules_text {
    return Intl.message("Rules", name: 'community__rules_text');
  }

  String get community__name_characters_error {
    return Intl.message(
        "Name can only contain alphanumeric characters and underscores.",
        name: 'community__name_characters_error');
  }

  String community__name_range_error(int maxLength) {
    return Intl.message("Name can't be longer than $maxLength characters.",
        args: [maxLength], name: 'community__name_range_error');
  }

  String get community__name_empty_error {
    return Intl.message("Name cannot be empty.",
        name: 'community__name_empty_error');
  }

  String community__title_range_error(int maxLength) {
    return Intl.message("Title can't be longer than $maxLength characters.",
        args: [maxLength], name: 'community__title_range_error');
  }

  String get community__title_empty_error {
    return Intl.message("Title cannot be empty.",
        name: 'community__title_empty_error');
  }

  String community__rules_range_error(int maxLength) {
    return Intl.message("Rules can't be longer than $maxLength characters.",
        args: [maxLength], name: 'community__rules_range_error');
  }

  String get community__rules_empty_error {
    return Intl.message("Rules cannot be empty.",
        name: 'community__rules_empty_error');
  }

  String community__description_range_error(int maxLength) {
    return Intl.message(
        "Description can't be longer than $maxLength characters.",
        args: [maxLength],
        name: 'community__description_range_error');
  }

  String community__adjectives_range_error(int maxLength) {
    return Intl.message(
        "Adjectives can't be longer than $maxLength characters.",
        args: [maxLength],
        desc:
            'This refers to the customisable adjectives assigned to community members,eg. 1k travellers,5k photographers',
        name: 'community__adjectives_range_error');
  }

  String get community__top_posts_excluded_communities {
    return Intl.message("Hidden communities",
        name: 'community__top_posts_excluded_communities');
  }

  String get community__top_posts_excluded_communities_desc {
    return Intl.message("Manage communities hidden from the explore timeline",
        name: 'community__top_posts_excluded_communities_desc');
  }

  String get community__top_posts_settings {
    return Intl.message("Explore settings",
        name: 'community__top_posts_settings');
  }

  String get user_search__search_text {
    return Intl.message("Search...", name: 'user_search__search_text');
  }

  String get user_search__communities {
    return Intl.message("Communities", name: 'user_search__communities');
  }

  String get user_search__hashtags {
    return Intl.message("Hashtags", name: 'user_search__hashtags');
  }

  String get user_search__users {
    return Intl.message("Users", name: 'user_search__users');
  }

  String user_search__list_search_text(String resourcePluralName) {
    return Intl.message("Search $resourcePluralName ...",
        args: [resourcePluralName],
        desc:
            'resourcePluralName can take many forms foreg. Search members... , Search accepted invites, Search communities.. etc.',
        name: 'user_search__list_search_text');
  }

  String user_search__list_no_results_found(String resourcePluralName) {
    return Intl.message("No $resourcePluralName found.",
        args: [resourcePluralName],
        desc:
            'Used in a generic list widget. Can be No users found. No communities found. No pending invites found. Its always a plural. ',
        name: 'user_search__list_no_results_found');
  }

  String get user_search__list_refresh_text {
    return Intl.message("Refresh", name: 'user_search__list_refresh_text');
  }

  String get user_search__list_retry {
    return Intl.message("Tap to retry.", name: 'user_search__list_retry');
  }

  String get user_search__cancel {
    return Intl.message("Cancel", name: 'user_search__cancel');
  }

  String user_search__searching_for(String searchQuery) {
    return Intl.message("Searching for '$searchQuery'",
        args: [searchQuery], name: 'user_search__searching_for');
  }

  String user_search__no_results_for(String searchQuery) {
    return Intl.message("No results for '$searchQuery'.",
        args: [searchQuery], name: 'user_search__no_results_for');
  }

  String user_search__no_communities_for(String searchQuery) {
    return Intl.message("No communities found for '$searchQuery'.",
        args: [searchQuery], name: 'user_search__no_communities_for');
  }

  String user_search__no_hashtags_for(String searchQuery) {
    return Intl.message("No hashtags found for '$searchQuery'.",
        args: [searchQuery], name: 'user_search__no_hashtags_for');
  }

  String user_search__no_users_for(String searchQuery) {
    return Intl.message("No users found for '$searchQuery'.",
        args: [searchQuery], name: 'user_search__no_users_for');
  }

  String get user_search__selection_submit {
    return Intl.message("Submit", name: 'user_search__selection_submit');
  }

  String get post__open_post {
    return Intl.message("Open post", name: 'post__open_post');
  }

  String get user_search__selection_clear_all {
    return Intl.message("Clear all", name: 'user_search__selection_clear_all');
  }

  String get post__close_post {
    return Intl.message("Close post", name: 'post__close_post');
  }

  String get post__post_opened {
    return Intl.message("Post opened", name: 'post__post_opened');
  }

  String get post__post_closed {
    return Intl.message("Post closed ", name: 'post__post_closed');
  }

  String get post__comment_required_error {
    return Intl.message("Comment cannot be empty.",
        name: 'post__comment_required_error');
  }

  String post__comment_maxlength_error(int maxLength) {
    return Intl.message("A comment can't be longer than $maxLength characters.",
        args: [maxLength], name: 'post__comment_maxlength_error');
  }

  String get post__timeline_posts_all_loaded {
    return Intl.message("🎉  All posts loaded",
        name: 'post__timeline_posts_all_loaded');
  }

  String get post__timeline_posts_refreshing_drhoo_title {
    return Intl.message("Hang in there!",
        name: 'post__timeline_posts_refreshing_drhoo_title');
  }

  String get post__timeline_posts_no_more_drhoo_subtitle {
    return Intl.message("Follow users or join a community to get started!",
        name: 'post__timeline_posts_no_more_drhoo_subtitle');
  }

  String get post__timeline_posts_failed_drhoo_title {
    return Intl.message("Could not load your timeline.",
        name: 'post__timeline_posts_failed_drhoo_title');
  }

  String get post__timeline_posts_failed_drhoo_subtitle {
    return Intl.message("Try again in a couple seconds",
        name: 'post__timeline_posts_failed_drhoo_subtitle');
  }

  String get post__timeline_posts_default_drhoo_title {
    return Intl.message("Something's not right.",
        name: 'post__timeline_posts_default_drhoo_title');
  }

  String get post__timeline_posts_default_drhoo_subtitle {
    return Intl.message("Try refreshing the timeline.",
        name: 'post__timeline_posts_default_drhoo_subtitle');
  }

  String get post__timeline_posts_refresh_posts {
    return Intl.message("Refresh posts",
        name: 'post__timeline_posts_refresh_posts');
  }

  String post__no_circles_for(String circlesSearchQuery) {
    return Intl.message("No circles found matching '$circlesSearchQuery'.",
        args: [circlesSearchQuery], name: 'post__no_circles_for');
  }

  String get post__share_to_circles {
    return Intl.message("Share to circles", name: 'post__share_to_circles');
  }

  String get post__profile_counts_post {
    return Intl.message(" Post", name: 'post__profile_counts_post');
  }

  String get post__profile_counts_posts {
    return Intl.message(" Posts", name: 'post__profile_counts_posts');
  }

  String get post__profile_counts_followers {
    return Intl.message(" Followers", name: 'post__profile_counts_followers');
  }

  String get post__profile_counts_following {
    return Intl.message(" Following", name: 'post__profile_counts_following');
  }

  String get post__profile_counts_follower {
    return Intl.message(" Follower", name: 'post__profile_counts_follower');
  }

  String get post__profile_retry_loading_posts {
    return Intl.message("Tap to retry",
        name: 'post__profile_retry_loading_posts');
  }

  String get post__action_comment {
    return Intl.message("Comment", name: 'post__action_comment');
  }

  String get post__action_react {
    return Intl.message("React", name: 'post__action_react');
  }

  String get post__action_reply {
    return Intl.message("Reply", name: 'post__action_reply');
  }

  String get post__share {
    return Intl.message("Share", name: 'post__share');
  }

  String get post__share_to {
    return Intl.message("Share to", name: 'post__share_to');
  }

  String get post__sharing_post_to {
    return Intl.message("Sharing post to", name: 'post__sharing_post_to');
  }

  String get post__you_shared_with {
    return Intl.message("You shared with", name: 'post__you_shared_with');
  }

  String get post__shared_privately_on {
    return Intl.message("Shared privately on",
        desc:
            'Eg. Shared privately on @shantanu\'s circles. See following string, usernames_circles . Will combine this in future, needs refactoring.',
        name: 'post__shared_privately_on');
  }

  String post__usernames_circles(String postCreatorUsername) {
    return Intl.message("@$postCreatorUsername's circles",
        args: [postCreatorUsername], name: 'post__usernames_circles');
  }

  String get post__share_community {
    return Intl.message("Share", name: 'post__share_community');
  }

  String get post__share_to_community {
    return Intl.message("Share to community", name: 'post__share_to_community');
  }

  String get post__share_community_title {
    return Intl.message("A community", name: 'post__share_community_title');
  }

  String get post__share_community_desc {
    return Intl.message("Share the post to a community you're part of.",
        name: 'post__share_community_desc');
  }

  String get post__my_circles {
    return Intl.message("My circles", name: 'post__my_circles');
  }

  String get post__my_circles_desc {
    return Intl.message("Share the post to one or multiple of your circles.",
        name: 'post__my_circles_desc');
  }

  String get post__world_circle_name {
    return Intl.message("World", name: 'post__world_circle_name');
  }

  String get post__search_circles {
    return Intl.message("Search circles...", name: 'post__search_circles');
  }

  String get post__reaction_list_tap_retry {
    return Intl.message("Tap to retry loading reactions.",
        name: 'post__reaction_list_tap_retry');
  }

  String get post__create_new {
    return Intl.message("New post", name: 'post__create_new');
  }

  String get post__create_new_post_label {
    return Intl.message("Create new post", name: 'post__create_new_post_label');
  }

  String get post__create_new_community_post_label {
    return Intl.message("Create new communtiy post",
        name: 'post__create_new_community_post_label');
  }

  String get post__close_create_post_label {
    return Intl.message("Close create new post",
        name: 'post__close_create_post_label');
  }

  String get post__create_next {
    return Intl.message("Next", name: 'post__create_next');
  }

  String get post__create_media {
    return Intl.message("Media", name: 'post__create_media');
  }

  String get post__create_camera {
    return Intl.message("Camera", name: 'post__create_camera');
  }

  String get post__create_photo {
    return Intl.message("Photo", name: 'post__create_photo');
  }

  String get post__create_video {
    return Intl.message("Video", name: 'post__create_video');
  }

  String post__create_hashtags_invalid(int maxHashtags, int maxCharacters) {
    return Intl.message(
        "Please add a maximum of $maxHashtags hashtags and keep them under $maxCharacters characters.",
        args: [maxHashtags, maxCharacters],
        name: 'post__create_hashtags_invalid');
  }

  String get post__commenter_post_text {
    return Intl.message("Post", name: 'post__commenter_post_text');
  }

  String get post__commenter_write_something {
    return Intl.message("Write something...",
        name: 'post__commenter_write_something');
  }

  String get post__edit_title {
    return Intl.message("Edit post", name: 'post__edit_title');
  }

  String get post__edit_save {
    return Intl.message("Save", name: 'post__edit_save');
  }

  String get post__commenter_expanded_save {
    return Intl.message("Save", name: 'post__commenter_expanded_save');
  }

  String get post__commenter_expanded_join_conversation {
    return Intl.message("Join the conversation...",
        name: 'post__commenter_expanded_join_conversation');
  }

  String get post__commenter_expanded_start_conversation {
    return Intl.message("Start the conversation...",
        name: 'post__commenter_expanded_start_conversation');
  }

  String get post__commenter_expanded_edit_comment {
    return Intl.message("Edit comment",
        name: 'post__commenter_expanded_edit_comment');
  }

  String get post__is_closed {
    return Intl.message("Closed post", name: 'post__is_closed');
  }

  String get post__comment_reply_expanded_reply_comment {
    return Intl.message("Reply to comment",
        name: 'post__comment_reply_expanded_reply_comment');
  }

  String get post__comment_reply_expanded_post {
    return Intl.message("Post", name: 'post__comment_reply_expanded_post');
  }

  String get post__comment_reply_expanded_reply_hint_text {
    return Intl.message("Your reply...",
        name: 'post__comment_reply_expanded_reply_hint_text');
  }

  String get post__top_posts_title {
    return Intl.message("Explore", name: 'post__top_posts_title');
  }

  String get post__trending_posts_title {
    return Intl.message("Trending", name: 'post__trending_posts_title');
  }

  String get post__trending_posts_load_more {
    return Intl.message("Load older posts",
        name: 'post__trending_posts_load_more');
  }

  String get post__load_more {
    return Intl.message("Load more posts", name: 'post__load_more');
  }

  String get post__trending_posts_no_trending_posts {
    return Intl.message(
        "There are no trending posts. Try refreshing in a couple seconds.",
        name: 'post__trending_posts_no_trending_posts');
  }

  String get post__trending_posts_refresh {
    return Intl.message("Refresh", name: 'post__trending_posts_refresh');
  }

  String post__comments_view_all_comments(int commentsCount) {
    return Intl.message("View all $commentsCount comments",
        args: [commentsCount], name: 'post__comments_view_all_comments');
  }

  String get post__comments_closed_post {
    return Intl.message("Closed post", name: 'post__comments_closed_post');
  }

  String get post__comments_disabled {
    return Intl.message("Comments disabled", name: 'post__comments_disabled');
  }

  String get post__text_copied {
    return Intl.message("Text copied!", name: 'post__text_copied');
  }

  String get post__post_reactions_title {
    return Intl.message("Post reactions", name: 'post__post_reactions_title');
  }

  String get post__have_not_shared_anything {
    return Intl.message("You have not shared anything yet.",
        name: 'post__have_not_shared_anything');
  }

  String post__user_has_not_shared_anything(String name) {
    return Intl.message("$name has not shared anything yet.",
        args: [name], name: 'post__user_has_not_shared_anything');
  }

  String get post__comments_header_newest_replies {
    return Intl.message("Newest replies",
        name: 'post__comments_header_newest_replies');
  }

  String get post__comments_header_newer {
    return Intl.message("Newer", name: 'post__comments_header_newer');
  }

  String get post__comments_header_view_newest_replies {
    return Intl.message("View newest replies",
        name: 'post__comments_header_view_newest_replies');
  }

  String get post__comments_header_see_newest_replies {
    return Intl.message("See newest replies",
        name: 'post__comments_header_see_newest_replies');
  }

  String get post__comments_header_oldest_replies {
    return Intl.message("Oldest replies",
        name: 'post__comments_header_oldest_replies');
  }

  String get post__comments_header_older {
    return Intl.message("Older", name: 'post__comments_header_older');
  }

  String get post__comments_header_view_oldest_replies {
    return Intl.message("View oldest replies",
        name: 'post__comments_header_view_oldest_replies');
  }

  String get post__comments_header_see_oldest_replies {
    return Intl.message("See oldest replies",
        name: 'post__comments_header_see_oldest_replies');
  }

  String get post__comments_header_be_the_first_replies {
    return Intl.message("Be the first to reply",
        name: 'post__comments_header_be_the_first_replies');
  }

  String get post__comments_header_newest_comments {
    return Intl.message("Newest comments",
        name: 'post__comments_header_newest_comments');
  }

  String get post__comments_header_view_newest_comments {
    return Intl.message("View newest comments",
        name: 'post__comments_header_view_newest_comments');
  }

  String get post__comments_header_see_newest_comments {
    return Intl.message("See newest comments",
        name: 'post__comments_header_see_newest_comments');
  }

  String get post__comments_header_oldest_comments {
    return Intl.message("Oldest comments",
        name: 'post__comments_header_oldest_comments');
  }

  String get post__comments_header_view_oldest_comments {
    return Intl.message("View oldest comments",
        name: 'post__comments_header_view_oldest_comments');
  }

  String get post__comments_header_see_oldest_comments {
    return Intl.message("See oldest comments",
        name: 'post__comments_header_see_oldest_comments');
  }

  String get post__comments_header_be_the_first_comments {
    return Intl.message("Be the first to comment",
        name: 'post__comments_header_be_the_first_comments');
  }

  String get post__comments_page_title {
    return Intl.message("Post comments", name: 'post__comments_page_title');
  }

  String get post__comments_page_no_more_to_load {
    return Intl.message("No more comments to load",
        name: 'post__comments_page_no_more_to_load');
  }

  String get post__comments_page_tap_to_retry {
    return Intl.message("Tap to retry loading comments.",
        name: 'post__comments_page_tap_to_retry');
  }

  String get post__comments_page_tap_to_retry_replies {
    return Intl.message("Tap to retry loading replies.",
        name: 'post__comments_page_tap_to_retry_replies');
  }

  String get post__comments_page_no_more_replies_to_load {
    return Intl.message("No more replies to load",
        name: 'post__comments_page_no_more_replies_to_load');
  }

  String get post__comments_page_replies_title {
    return Intl.message("Post replies",
        name: 'post__comments_page_replies_title');
  }

  String get post__disable_post_comments {
    return Intl.message("Disable post comments",
        name: 'post__disable_post_comments');
  }

  String get post__enable_post_comments {
    return Intl.message("Enable post comments",
        name: 'post__enable_post_comments');
  }

  String get post__exclude_post_community {
    return Intl.message("Don't show posts from this community",
        name: 'post__exclude_post_community');
  }

  String get post__undo_exclude_post_community {
    return Intl.message("Show posts from this community",
        name: 'post__undo_exclude_post_community');
  }

  String get post__exclude_community_from_profile_posts {
    return Intl.message("Hide this community from my profile",
        name: 'post__exclude_community_from_profile_posts');
  }

  String get post__exclude_community_from_profile_posts_success {
    return Intl.message("Community hidden",
        name: 'post__exclude_community_from_profile_posts_success');
  }

  String get post__exclude_community_from_profile_posts_confirmation {
    return Intl.message(
        "This will hide all posts from this community from your profile.",
        name: 'post__exclude_community_from_profile_posts_confirmation');
  }

  String get post__comments_enabled_message {
    return Intl.message("Comments enabled for post",
        name: 'post__comments_enabled_message');
  }

  String get post__comments_disabled_message {
    return Intl.message("Comments disabled for post",
        name: 'post__comments_disabled_message');
  }

  String get post__actions_delete {
    return Intl.message("Delete post", name: 'post__actions_delete');
  }

  String get post__actions_delete_description {
    return Intl.message(
        "The post, as well as its comments and reactions will be permanently deleted.",
        name: 'post__actions_delete_description');
  }

  String get post__actions_deleted {
    return Intl.message("Post deleted", name: 'post__actions_deleted');
  }

  String get post__actions_delete_comment {
    return Intl.message("Delete comment", name: 'post__actions_delete_comment');
  }

  String get post__actions_delete_comment_description {
    return Intl.message(
        "The comment, as well as its replies and reactions will be permanently deleted.",
        name: 'post__actions_delete_comment_description');
  }

  String get post__actions_edit_comment {
    return Intl.message("Edit comment", name: 'post__actions_edit_comment');
  }

  String get post__actions_comment_deleted {
    return Intl.message("Comment deleted",
        name: 'post__actions_comment_deleted');
  }

  String get post__actions_report_text {
    return Intl.message("Report", name: 'post__actions_report_text');
  }

  String get post__actions_reported_text {
    return Intl.message("Reported", name: 'post__actions_reported_text');
  }

  String get post__actions_show_more_text {
    return Intl.message("Show more",
        desc: 'Shown for posts with long text to expand the entire text.',
        name: 'post__actions_show_more_text');
  }

  String get post__time_short_years {
    return Intl.message("y",
        desc:
            'Shown in timestamps next to post to indicate how long ago the post/notification was created for.eg 3y. Keep it as short as possible',
        name: 'post__time_short_years');
  }

  String get post__time_short_one_year {
    return Intl.message("1y",
        desc:
            "No space is intentional, should be as few characters as possible. Since there is not much space where we show this",
        name: 'post__time_short_one_year');
  }

  String get post__time_short_weeks {
    return Intl.message("w",
        desc:
            'Shown in timestamps next to post to indicate how long ago the post/notification was created for.eg 5w.Keep it as short as possible ',
        name: 'post__time_short_weeks');
  }

  String get post__time_short_one_week {
    return Intl.message("1w",
        desc:
            "No space is intentional, should be as few characters as possible. Since there is not much space where we show this",
        name: 'post__time_short_one_week');
  }

  String get post__time_short_days {
    return Intl.message("d",
        desc:
            'Shown in timestamps next to post to indicate how long ago the post/notification was created for.eg 3d. Keep it as short as possible ',
        name: 'post__time_short_days');
  }

  String get post__time_short_one_day {
    return Intl.message("1d",
        desc:
            "No space is intentional, should be as few characters as possible. Since there is not much space where we show this",
        name: 'post__time_short_one_day');
  }

  String get post__time_short_hours {
    return Intl.message("h",
        desc:
            'Shown in timestamps next to post to indicate how long ago the post/notification was created for.eg 3h.Keep it as short as possible ',
        name: 'post__time_short_hours');
  }

  String get post__time_short_one_hour {
    return Intl.message("1h",
        desc:
            "No space is intentional, should be as few characters as possible. Since there is not much space where we show this",
        name: 'post__time_short_one_hour');
  }

  String get post__time_short_minutes {
    return Intl.message("m",
        desc:
            'Shown in timestamps next to post to indicate how long ago the post/notification was created for.eg 13m.Keep it as short as possible ',
        name: 'post__time_short_minutes');
  }

  String get post__time_short_seconds {
    return Intl.message("s",
        desc:
            'Shown in timestamps next to post to indicate how long ago the post/notification was created for.eg 13s Keep it as short as possible ',
        name: 'post__time_short_seconds');
  }

  String get post__time_short_one_minute {
    return Intl.message("1m",
        desc:
            "No space is intentional, should be as few characters as possible. Since there is not much space where we show this",
        name: 'post__time_short_one_minute');
  }

  String get post__time_short_now_text {
    return Intl.message("now",
        desc:
            "Shown when a post was immediately posted, as in time posted is 'now'.Should be as few characters as possible.",
        name: 'post__time_short_now_text');
  }

  String get user__follow_requests {
    return Intl.message("Follow requests", name: 'user__follow_requests');
  }

  String get user__follow_request {
    return Intl.message("Follow request", name: 'user__follow_request');
  }

  String get user__thousand_postfix {
    return Intl.message("k",
        desc: 'For eg. communty has 3k members',
        name: 'user__thousand_postfix');
  }

  String get user__million_postfix {
    return Intl.message("m",
        desc: 'For eg. user has 3m followers', name: 'user__million_postfix');
  }

  String get user__billion_postfix {
    return Intl.message("b",
        desc: 'For eg. World circle has 7.5b people',
        name: 'user__billion_postfix');
  }

  String get user__translate_see_translation {
    return Intl.message("See translation",
        name: 'user__translate_see_translation');
  }

  String get user__translate_show_original {
    return Intl.message("Show original", name: 'user__translate_show_original');
  }

  String get user__follows_lists_account {
    return Intl.message("1 Account", name: 'user__follows_lists_account');
  }

  String user__follows_lists_accounts(String prettyUsersCount) {
    return Intl.message("$prettyUsersCount Accounts",
        args: [prettyUsersCount],
        desc:
            'prettyUsersCount will be 3m, 50k etc.. so we endup with final string 3k Accounts',
        name: 'user__follows_lists_accounts');
  }

  String user__edit_profile_user_name_taken(String username) {
    return Intl.message("Username @$username is taken",
        args: [username], name: 'user__edit_profile_user_name_taken');
  }

  String get user__profile_action_deny_connection {
    return Intl.message("Deny connection request",
        name: 'user__profile_action_deny_connection');
  }

  String get user__profile_action_deny_connection_short {
    return Intl.message("Deny",
        name: 'user__profile_action_deny_connection_short');
  }

  String get user__profile_action_confirm_connection_short {
    return Intl.message("Confirm",
        name: 'user__profile_action_confirm_connection_short');
  }

  String user__profile_user_sent_follow_request(String userUsername) {
    return Intl.message('@$userUsername has sent you a follow request.',
        args: [userUsername], name: 'user__profile_user_sent_follow_request');
  }

  String user__profile_user_sent_connection_request(String userUsername) {
    return Intl.message('@$userUsername has sent you a connection request.',
        args: [userUsername],
        name: 'user__profile_user_sent_connection_request');
  }

  String get user__profile_action_user_blocked {
    return Intl.message("User blocked",
        name: 'user__profile_action_user_blocked');
  }

  String get user__profile_action_user_unblocked {
    return Intl.message("User unblocked",
        name: 'user__profile_action_user_unblocked');
  }

  String get user__profile_action_user_post_notifications_enabled {
    return Intl.message("New post notifications enabled",
        name: 'user__profile_action_user_post_notifications_enabled');
  }

  String get user__profile_action_user_post_notifications_disabled {
    return Intl.message("New post notifications disabled",
        name: 'user__profile_action_user_post_notifications_disabled');
  }

  String get user__profile_in_circles {
    return Intl.message("In circles", name: 'user__profile_in_circles');
  }

  String get user__profile_action_cancel_connection {
    return Intl.message("Cancel connection request",
        name: 'user__profile_action_cancel_connection');
  }

  String get user__profile_url_invalid_error {
    return Intl.message("Please provide a valid url.",
        name: 'user__profile_url_invalid_error');
  }

  String user__profile_location_length_error(int maxLength) {
    return Intl.message("Location can't be longer than $maxLength characters.",
        args: [maxLength], name: 'user__profile_location_length_error');
  }

  String user__profile_bio_length_error(int maxLength) {
    return Intl.message("Bio can't be longer than $maxLength characters.",
        args: [maxLength], name: 'user__profile_bio_length_error');
  }

  String user__profile_okuna_age_toast(String age) {
    return Intl.message("On Okuna since $age",
        args: [age], name: 'user__profile_okuna_age_toast');
  }

  String get user__follow_button_follow_text {
    return Intl.message("Follow", name: 'user__follow_button_follow_text');
  }

  String get user__follow_button_requested_to_follow_text {
    return Intl.message("Requested",
        name: 'user__follow_button_requested_to_follow_text');
  }

  String get user__follow_button_follow_back_text {
    return Intl.message("Follow back",
        name: 'user__follow_button_follow_back_text');
  }

  String get user__follow_button_following_text {
    return Intl.message("Following",
        name: 'user__follow_button_following_text');
  }

  String get user__follow_button_unfollow_text {
    return Intl.message("Unfollow", name: 'user__follow_button_unfollow_text');
  }

  String get user__edit_profile_username {
    return Intl.message("Username", name: 'user__edit_profile_username');
  }

  String get user__add_account_update_account_lists {
    return Intl.message("Update account lists",
        name: 'user__add_account_update_account_lists');
  }

  String get user__add_account_to_lists {
    return Intl.message("Add account to list",
        name: 'user__add_account_to_lists');
  }

  String get user__add_account_update_lists {
    return Intl.message("Update lists", name: 'user__add_account_update_lists');
  }

  String get user__add_account_save {
    return Intl.message("Save", name: 'user__add_account_save');
  }

  String get user__add_account_done {
    return Intl.message("Done", name: 'user__add_account_done');
  }

  String get user__add_account_success {
    return Intl.message("Success", name: 'user__add_account_success');
  }

  String get user__emoji_field_none_selected {
    return Intl.message("No emoji selected",
        name: 'user__emoji_field_none_selected');
  }

  String user__emoji_search_none_found(String searchQuery) {
    return Intl.message("No emoji found matching '$searchQuery'.",
        args: [searchQuery], name: 'user__emoji_search_none_found');
  }

  String get user__follow_lists_title {
    return Intl.message("My lists", name: 'user__follow_lists_title');
  }

  String get user__follow_lists_search_for {
    return Intl.message("Search for a list...",
        name: 'user__follow_lists_search_for');
  }

  String get user__follow_lists_no_list_found {
    return Intl.message("No lists found.",
        name: 'user__follow_lists_no_list_found');
  }

  String user__follow_lists_no_list_found_for(String searchQuery) {
    return Intl.message("No list found for '$searchQuery'",
        args: [searchQuery], name: 'user__follow_lists_no_list_found_for');
  }

  String get user__list_name_empty_error {
    return Intl.message("List name cannot be empty.",
        name: 'user__list_name_empty_error');
  }

  String user__list_name_range_error(int maxLength) {
    return Intl.message(
        "List name must be no longer than $maxLength characters.",
        args: [maxLength],
        name: 'user__list_name_range_error');
  }

  String get user__circle_name_empty_error {
    return Intl.message("Circle name cannot be empty.",
        name: 'user__circle_name_empty_error');
  }

  String user__circle_name_range_error(int maxLength) {
    return Intl.message(
        "Circle name must be no longer than $maxLength characters.",
        args: [maxLength],
        name: 'user__circle_name_range_error');
  }

  String get user__save_follows_list_name {
    return Intl.message("Name", name: 'user__save_follows_list_name');
  }

  String get user__save_follows_list_hint_text {
    return Intl.message("e.g. Travel, Photography",
        name: 'user__save_follows_list_hint_text');
  }

  String user__save_follows_list_name_taken(String listName) {
    return Intl.message("List name '$listName' is taken",
        args: [listName], name: 'user__save_follows_list_name_taken');
  }

  String get user__save_follows_list_emoji {
    return Intl.message("Emoji", name: 'user__save_follows_list_emoji');
  }

  String get user__save_follows_list_users {
    return Intl.message("Users", name: 'user__save_follows_list_users');
  }

  String get user__save_follows_list_edit {
    return Intl.message("Edit list", name: 'user__save_follows_list_edit');
  }

  String get user__save_follows_list_create {
    return Intl.message("Create list", name: 'user__save_follows_list_create');
  }

  String get user__save_follows_list_save {
    return Intl.message("Save", name: 'user__save_follows_list_save');
  }

  String get user__save_follows_list_emoji_required_error {
    return Intl.message("Emoji is required",
        name: 'user__save_follows_list_emoji_required_error');
  }

  String get user__follows_list_edit {
    return Intl.message("Edit", name: 'user__follows_list_edit');
  }

  String get user__follows_list_header_title {
    return Intl.message("Users", name: 'user__follows_list_header_title');
  }

  String get user__edit_profile_name {
    return Intl.message("Name", name: 'user__edit_profile_name');
  }

  String get user__edit_profile_url {
    return Intl.message("Url", name: 'user__edit_profile_url');
  }

  String get user__edit_profile_location {
    return Intl.message("Location", name: 'user__edit_profile_location');
  }

  String get user__edit_profile_bio {
    return Intl.message("Bio", name: 'user__edit_profile_bio');
  }

  String get user__manage_profile_followers_count_toggle {
    return Intl.message("Followers count",
        name: 'user__manage_profile_followers_count_toggle');
  }

  String get user__manage_profile_followers_count_toggle__descr {
    return Intl.message(
        "Display the number of people that follow you, on your profile.",
        name: 'user__manage_profile_followers_count_toggle__descr');
  }

  String get user__manage_profile_community_posts_toggle {
    return Intl.message("Community posts",
        name: 'user__manage_profile_community_posts_toggle');
  }

  String get user__manage_profile_community_posts_toggle__descr {
    return Intl.message(
        "Display posts you share with public communities, on your profile.",
        name: 'user__manage_profile_community_posts_toggle__descr');
  }

  String get user__edit_profile_community_posts {
    return Intl.message("Communities",
        name: 'user__edit_profile_community_posts');
  }

  String get user__edit_profile_community_posts_descr {
    return Intl.message("Display in profile",
        name: 'user__edit_profile_community_posts_descr');
  }

  String get user__manage {
    return Intl.message("Manage", name: 'user__manage');
  }

  String get user__manage_profile_title {
    return Intl.message("Manage profile", name: 'user__manage_profile_title');
  }

  String get user__manage_profile_details_title {
    return Intl.message("Details", name: 'user__manage_profile_details_title');
  }

  String get user__manage_profile_follow_requests_desc {
    return Intl.message("See all your received follow requests.",
        name: 'user__manage_profile_follow_requests_desc');
  }

  String get user__manage_profile_details_title_desc {
    return Intl.message(
        "Change your username, name, url, location, avatar or cover photo.",
        name: 'user__manage_profile_details_title_desc');
  }

  String get user__manage_profile_visibility_title {
    return Intl.message("Visibility",
        name: 'user__manage_profile_visibility_title');
  }

  String get user__manage_profile_visibility_title_desc {
    return Intl.message(
        "Change whether your profile content is public, private or restricted to Okuna members.",
        name: 'user__manage_profile_visibility_title_desc');
  }

  String get user__profile_posts_excluded_communities {
    return Intl.message("Hidden communities",
        name: 'user__profile_posts_excluded_communities');
  }

  String get user__profile_posts_exclude_communities {
    return Intl.message("Exclude communities",
        name: 'user__profile_posts_exclude_communities');
  }

  String get user__profile_posts_excluded_communities_desc {
    return Intl.message(
        "See, add and remove hidden communities from your profile.",
        name: 'user__profile_posts_excluded_communities_desc');
  }

  String get user__protected_account_title {
    return Intl.message("This accounts posts are protected.",
        name: 'user__protected_account_title');
  }

  String user__protected_account_desc(String username) {
    return Intl.message(
        "Only confirmed followers have access to @$username's posts.",
        args: [username],
        name: 'user__protected_account_desc');
  }

  String user__protected_account_instructions(String followButtonText) {
    return Intl.message(
        'Click the "$followButtonText" button to send a follow request.',
        args: [followButtonText],
        name: 'user__protected_account_instructions');
  }

  String get user__protected_account_instructions_complete {
    return Intl.message('You have already sent a follow request.',
        name: 'user__protected_account_instructions_complete');
  }

  String get user__edit_profile_save_text {
    return Intl.message("Save", name: 'user__edit_profile_save_text');
  }

  String get user__edit_profile_pick_image {
    return Intl.message("Pick image", name: 'user__edit_profile_pick_image');
  }

  String get user__edit_profile_delete {
    return Intl.message("Delete", name: 'user__edit_profile_delete');
  }

  String user__edit_profile_pick_image_error_too_large(int limit) {
    return Intl.message("Image too large (limit: $limit MB)",
        args: [limit], name: 'user__edit_profile_pick_image_error_too_large');
  }

  String get user__tile_following {
    return Intl.message(" · Following", name: 'user__tile_following');
  }

  String get user__following_text {
    return Intl.message("Following", name: 'user__following_text');
  }

  String get user__following_resource_name {
    return Intl.message("followed users",
        desc: 'Eg: Search followed users.., No followed users found. etc ',
        name: 'user__following_resource_name');
  }

  String get user__tile_delete {
    return Intl.message("Delete", name: 'user__tile_delete');
  }

  String get user__invite {
    return Intl.message("Invite", name: 'user__invite');
  }

  String get user__uninvite {
    return Intl.message("Uninvite", name: 'user__uninvite');
  }

  String get user__invite_member {
    return Intl.message("Member", name: 'user__invite_member');
  }

  String user__invite_someone_message(String iosLink, String testFlightLink,
      String androidLink, String inviteLink) {
    return Intl.message(
        "Hey, I'd like to invite you to Okuna.\n\n"
        "For Apple, first, download the TestFlight app on iTunes ($testFlightLink) and then download the Okuna app ($iosLink)\n\n"
        "For Android, download it from the Play store ($androidLink).\n\n"
        "Second, paste this personalised invite link in the 'Sign up' form in the Okuna App: $inviteLink",
        args: [iosLink, testFlightLink, androidLink, inviteLink],
        name: 'user__invite_someone_message');
  }

  String get user__connections_header_circle_desc {
    return Intl.message("The circle all of your connections get added to.",
        name: 'user__connections_header_circle_desc');
  }

  String get user__connections_header_users {
    return Intl.message("Users", name: 'user__connections_header_users');
  }

  String get user__connection_pending {
    return Intl.message("Pending", name: 'user__connection_pending');
  }

  String get user__connection_circle_edit {
    return Intl.message("Edit", name: 'user__connection_circle_edit');
  }

  String get user__connections_circle_delete {
    return Intl.message("Delete", name: 'user__connections_circle_delete');
  }

  String get user__save_connection_circle_name {
    return Intl.message("Name", name: 'user__save_connection_circle_name');
  }

  String get user__save_connection_circle_hint {
    return Intl.message("e.g. Friends, Family, Work.",
        name: 'user__save_connection_circle_hint');
  }

  String get user__save_connection_circle_color_name {
    return Intl.message("Color",
        name: 'user__save_connection_circle_color_name');
  }

  String get user__save_connection_circle_color_hint {
    return Intl.message("(Tap to change)",
        name: 'user__save_connection_circle_color_hint');
  }

  String get user__save_connection_circle_users {
    return Intl.message("Users", name: 'user__save_connection_circle_users');
  }

  String get user__save_connection_circle_edit {
    return Intl.message("Edit circle",
        name: 'user__save_connection_circle_edit');
  }

  String get user__save_connection_circle_create {
    return Intl.message("Create circle",
        name: 'user__save_connection_circle_create');
  }

  String get user__save_connection_circle_save {
    return Intl.message("Save", name: 'user__save_connection_circle_save');
  }

  String get user__update_connection_circle_save {
    return Intl.message("Save", name: 'user__update_connection_circle_save');
  }

  String get user__update_connection_circle_updated {
    return Intl.message("Connection updated",
        name: 'user__update_connection_circle_updated');
  }

  String get user__update_connection_circles_title {
    return Intl.message("Update connection circles",
        name: 'user__update_connection_circles_title');
  }

  String user__confirm_connection_with(String userName) {
    return Intl.message("Confirm connection with $userName",
        args: [userName], name: 'user__confirm_connection_with');
  }

  String get user__confirm_connection_add_connection {
    return Intl.message("Add connection to circle",
        name: 'user__confirm_connection_add_connection');
  }

  String get user__confirm_connection_connection_confirmed {
    return Intl.message("Connection confirmed",
        name: 'user__confirm_connection_connection_confirmed');
  }

  String get user__confirm_connection_confirm_text {
    return Intl.message("Confirm",
        name: 'user__confirm_connection_confirm_text');
  }

  String user__connect_to_user_connect_with_username(String userName) {
    return Intl.message("Connect with $userName",
        args: [userName], name: 'user__connect_to_user_connect_with_username');
  }

  String get user__connect_to_user_add_connection {
    return Intl.message("Add connection to circle",
        name: 'user__connect_to_user_add_connection');
  }

  String get user__connect_to_user_done {
    return Intl.message("Done", name: 'user__connect_to_user_done');
  }

  String get user__connect_to_user_request_sent {
    return Intl.message("Connection request sent",
        name: 'user__connect_to_user_request_sent');
  }

  String get user__remove_account_from_list {
    return Intl.message("Remove account from lists",
        name: 'user__remove_account_from_list');
  }

  String get user__remove_account_from_list_success {
    return Intl.message("Success",
        name: 'user__remove_account_from_list_success');
  }

  String get user__confirm_block_user_title {
    return Intl.message("Confirmation", name: 'user__confirm_block_user_title');
  }

  String get user__confirm_block_user_info {
    return Intl.message(
        "You won't see each other posts nor be able to interact in any way.",
        name: 'user__confirm_block_user_info');
  }

  String get user__confirm_block_user_yes {
    return Intl.message("Yes", name: 'user__confirm_block_user_yes');
  }

  String get user__confirm_block_user_no {
    return Intl.message("No", name: 'user__confirm_block_user_no');
  }

  String get user__confirm_block_user_blocked {
    return Intl.message("User blocked.",
        name: 'user__confirm_block_user_blocked');
  }

  String user__confirm_block_user_question(String username) {
    return Intl.message("Are you sure you want to block @$username?",
        args: [username], name: 'user__confirm_block_user_question');
  }

  String user__save_connection_circle_name_taken(
      String takenConnectionsCircleName) {
    return Intl.message("Circle name '$takenConnectionsCircleName' is taken",
        args: [takenConnectionsCircleName],
        name: 'user__save_connection_circle_name_taken');
  }

  String get user__timeline_filters_title {
    return Intl.message("Timeline filters",
        name: 'user__timeline_filters_title');
  }

  String get user__timeline_filters_search_desc {
    return Intl.message("Search for circles and lists...",
        name: 'user__timeline_filters_search_desc');
  }

  String get user__timeline_filters_clear_all {
    return Intl.message("Clear all", name: 'user__timeline_filters_clear_all');
  }

  String get user__timeline_filters_apply_all {
    return Intl.message("Apply filters",
        name: 'user__timeline_filters_apply_all');
  }

  String get user__timeline_filters_circles {
    return Intl.message("Circles", name: 'user__timeline_filters_circles');
  }

  String get user__timeline_filters_lists {
    return Intl.message("Lists", name: 'user__timeline_filters_lists');
  }

  String get user__followers_title {
    return Intl.message("Followers", name: 'user__followers_title');
  }

  String get user__follower_singular {
    return Intl.message("follower", name: 'user__follower_singular');
  }

  String get user__follower_plural {
    return Intl.message("followers", name: 'user__follower_plural');
  }

  String get user__delete_account_title {
    return Intl.message("Delete account", name: 'user__delete_account_title');
  }

  String get user__delete_account_current_pwd {
    return Intl.message("Current Password",
        name: 'user__delete_account_current_pwd');
  }

  String get user__delete_account_current_pwd_hint {
    return Intl.message("Enter your current password",
        name: 'user__delete_account_current_pwd_hint');
  }

  String get user__delete_account_next {
    return Intl.message("Next", name: 'user__delete_account_next');
  }

  String get user__delete_account_confirmation_title {
    return Intl.message("Confirmation",
        name: 'user__delete_account_confirmation_title');
  }

  String get user__delete_account_confirmation_desc {
    return Intl.message("Are you sure you want to delete your account?",
        name: 'user__delete_account_confirmation_desc');
  }

  String get user__delete_account_confirmation_desc_info {
    return Intl.message("This is a permanent action and can't be undone.",
        name: 'user__delete_account_confirmation_desc_info');
  }

  String get user__delete_account_confirmation_no {
    return Intl.message("No", name: 'user__delete_account_confirmation_no');
  }

  String get user__delete_account_confirmation_yes {
    return Intl.message("Yes", name: 'user__delete_account_confirmation_yes');
  }

  String get user__delete_account_confirmation_goodbye {
    return Intl.message("Goodbye 😢",
        name: 'user__delete_account_confirmation_goodbye');
  }

  String get user__invites_create_create_title {
    return Intl.message("Create invite",
        name: 'user__invites_create_create_title');
  }

  String get user__invites_create_edit_title {
    return Intl.message("Edit invite", name: 'user__invites_create_edit_title');
  }

  String get user__invites_create_save {
    return Intl.message("Save", name: 'user__invites_create_save');
  }

  String get user__invites_create_create {
    return Intl.message("Create", name: 'user__invites_create_create');
  }

  String get user__invites_create_name_title {
    return Intl.message("Nickname", name: 'user__invites_create_name_title');
  }

  String get user__invites_create_name_hint {
    return Intl.message("e.g. Jane Doe",
        name: 'user__invites_create_name_hint');
  }

  String get user__invites_pending {
    return Intl.message("Pending", name: 'user__invites_pending');
  }

  String get user__invites_delete {
    return Intl.message("Delete", name: 'user__invites_delete');
  }

  String get user__invites_invite_text {
    return Intl.message("Invite", name: 'user__invites_invite_text');
  }

  String get user__invites_share_yourself {
    return Intl.message("Share invite yourself",
        name: 'user__invites_share_yourself');
  }

  String get user__invites_share_yourself_desc {
    return Intl.message("Choose from messaging apps, etc.",
        name: 'user__invites_share_yourself_desc');
  }

  String get user__invites_share_email {
    return Intl.message("Share invite by email",
        name: 'user__invites_share_email');
  }

  String get user__invites_email_text {
    return Intl.message("Email", name: 'user__invites_email_text');
  }

  String get user__invites_email_hint {
    return Intl.message("e.g. janedoe@email.com",
        name: 'user__invites_email_hint');
  }

  String get user__invites_email_invite_text {
    return Intl.message("Email invite",
        name: 'user__invites_email_invite_text');
  }

  String get user__invites_email_send_text {
    return Intl.message("Send", name: 'user__invites_email_send_text');
  }

  String get user__invites_email_sent_text {
    return Intl.message("Invite email sent",
        name: 'user__invites_email_sent_text');
  }

  String get user__invites_share_email_desc {
    return Intl.message(
        "We will send an invitation email with instructions on your behalf",
        name: 'user__invites_share_email_desc');
  }

  String get user__invites_edit_text {
    return Intl.message("Edit", name: 'user__invites_edit_text');
  }

  String get user__invites_title {
    return Intl.message("My invites", name: 'user__invites_title');
  }

  String get user__invites_accepted_title {
    return Intl.message("Accepted", name: 'user__invites_accepted_title');
  }

  String get user__invites_accepted_group_name {
    return Intl.message("accepted invites",
        desc:
            'Egs where this will end up: Accepted invites (capitalised title), Search accepted invites, See all accepted invites ',
        name: 'user__invites_accepted_group_name');
  }

  String get user__invites_accepted_group_item_name {
    return Intl.message("accepted invite",
        name: 'user__invites_accepted_group_item_name');
  }

  String get user__invites_pending_group_name {
    return Intl.message("pending invites",
        name: 'user__invites_pending_group_name');
  }

  String get user__invites_pending_group_item_name {
    return Intl.message("pending invite",
        name: 'user__invites_pending_group_item_name');
  }

  String get user__invites_none_used {
    return Intl.message("Looks like you haven't used any invite.",
        name: 'user__invites_none_used');
  }

  String get user__invites_none_left {
    return Intl.message("You have no invites available.",
        name: 'user__invites_none_left');
  }

  String get user__invites_invite_a_friend {
    return Intl.message("Invite a friend",
        name: 'user__invites_invite_a_friend');
  }

  String get user__invites_refresh {
    return Intl.message("Refresh", name: 'user__invites_refresh');
  }

  String get user__language_settings_title {
    return Intl.message("Language settings",
        name: 'user__language_settings_title');
  }

  String get user__language_settings_save {
    return Intl.message("Save", name: 'user__language_settings_save');
  }

  String get user__language_settings_saved_success {
    return Intl.message("Language changed successfully",
        name: 'user__language_settings_saved_success');
  }

  String user__groups_see_all(String groupName) {
    return Intl.message("See all $groupName",
        args: [groupName],
        desc:
            'Can be, See all joined communities, See all pending invites, See all moderated communities etc. ',
        name: 'user__groups_see_all');
  }

  String user__invites_joined_with(String username) {
    return Intl.message("Joined with username @$username",
        args: [username], name: 'user__invites_joined_with');
  }

  String user__invites_pending_email(String email) {
    return Intl.message("Pending, invite email sent to $email",
        args: [email], name: 'user__invites_pending_email');
  }

  String user__timeline_filters_no_match(String searchQuery) {
    return Intl.message("No match for '$searchQuery'.",
        args: [searchQuery], name: 'user__timeline_filters_no_match');
  }

  String get user__clear_application_cache_text {
    return Intl.message("Clear cache",
        name: 'user__clear_application_cache_text');
  }

  String get user__clear_application_cache_desc {
    return Intl.message("Clear cached posts, accounts, images & more.",
        name: 'user__clear_application_cache_desc');
  }

  String get user__clear_application_cache_success {
    return Intl.message("Cleared cache successfully",
        name: 'user__clear_application_cache_success');
  }

  String get user__clear_application_cache_failure {
    return Intl.message("Could not clear cache",
        name: 'user__clear_application_cache_failure');
  }

  String get user__confirm_guidelines_reject_title {
    return Intl.message("Guidelines Rejection",
        name: 'user__confirm_guidelines_reject_title');
  }

  String get user__confirm_guidelines_reject_info {
    return Intl.message("You can't use Okuna until you accept the guidelines.",
        name: 'user__confirm_guidelines_reject_info');
  }

  String get user__confirm_guidelines_reject_chat_with_team {
    return Intl.message("Chat with the team.",
        name: 'user__confirm_guidelines_reject_chat_with_team');
  }

  String get user__confirm_guidelines_reject_chat_immediately {
    return Intl.message("Start a chat immediately.",
        name: 'user__confirm_guidelines_reject_chat_immediately');
  }

  String get user__confirm_guidelines_reject_chat_community {
    return Intl.message("Chat with the community.",
        name: 'user__confirm_guidelines_reject_chat_community');
  }

  String get user__confirm_guidelines_reject_join_slack {
    return Intl.message("Join the Slack channel.",
        name: 'user__confirm_guidelines_reject_join_slack');
  }

  String get user__confirm_guidelines_reject_go_back {
    return Intl.message("Go back",
        name: 'user__confirm_guidelines_reject_go_back');
  }

  String get user__confirm_guidelines_reject_delete_account {
    return Intl.message("Delete account",
        name: 'user__confirm_guidelines_reject_delete_account');
  }

  String get user__guidelines_desc {
    return Intl.message(
        "Please take a moment to read and accept our guidelines.",
        name: 'user__guidelines_desc');
  }

  String get user__guidelines_accept {
    return Intl.message("Accept", name: 'user__guidelines_accept');
  }

  String get user__guidelines_reject {
    return Intl.message("Reject", name: 'user__guidelines_reject');
  }

  String get user__change_email_title {
    return Intl.message("Change Email", name: 'user__change_email_title');
  }

  String get user__change_email_email_text {
    return Intl.message("Email", name: 'user__change_email_email_text');
  }

  String get user__change_email_current_email_text {
    return Intl.message("Current email",
        name: 'user__change_email_current_email_text');
  }

  String get user__change_email_hint_text {
    return Intl.message("Enter your new email",
        name: 'user__change_email_hint_text');
  }

  String get user__change_email_error {
    return Intl.message("Email is already registered",
        name: 'user__change_email_error');
  }

  String get user__change_email_save {
    return Intl.message("Save", name: 'user__change_email_save');
  }

  String get user__change_email_success_info {
    return Intl.message(
        "We've sent a confirmation link to your new email address, click it to verify your new email",
        name: 'user__change_email_success_info');
  }

  String get user__clear_app_preferences_title {
    return Intl.message("Clear preferences",
        name: 'user__clear_app_preferences_title');
  }

  String get user__clear_app_preferences_desc {
    return Intl.message(
        "Clear the application preferences. Currently this is only the preferred order of comments.",
        name: 'user__clear_app_preferences_desc');
  }

  String get user__clear_app_preferences_cleared_successfully {
    return Intl.message("Cleared preferences successfully",
        name: 'user__clear_app_preferences_cleared_successfully');
  }

  String get user__email_verification_successful {
    return Intl.message("Awesome! Your email is now verified",
        name: 'user__email_verification_successful');
  }

  String get user__email_verification_error {
    return Intl.message(
        "Oops! Your token was not valid or expired, please try again",
        name: 'user__email_verification_error');
  }

  String get user__clear_app_preferences_error {
    return Intl.message("Could not clear preferences",
        name: 'user__clear_app_preferences_error');
  }

  String get user__disconnect_from_user_success {
    return Intl.message("Disconnected successfully",
        name: 'user__disconnect_from_user_success');
  }

  String get user__block_user {
    return Intl.message("Block user", name: 'user__block_user');
  }

  String get user__block_description {
    return Intl.message(
        "You will both dissapear from each other\'s social network experience, with the exception of communities which the person is a staff member of.",
        name: 'user__block_description');
  }

  String get user__unblock_description {
    return Intl.message(
        "You will both be able to follow, connect or explore each other's content again.",
        name: 'user__unblock_description');
  }

  String get user__unblock_user {
    return Intl.message("Unblock user", name: 'user__unblock_user');
  }

  String get user__enable_new_post_notifications {
    return Intl.message("Enable new post notifications",
        name: 'user__enable_new_post_notifications');
  }

  String get user__disable_new_post_notifications {
    return Intl.message("Disable new post notifications",
        name: 'user__disable_new_post_notifications');
  }

  String get user__visibility {
    return Intl.message("Visibility", name: 'user__visibility');
  }

  String get user__visibility_public {
    return Intl.message("Public", name: 'user__visibility_public');
  }

  String get user__visibility_public_desc {
    return Intl.message("Everyone on the internet can see your profile.",
        name: 'user__visibility_public_desc');
  }

  String get user__visibility_private {
    return Intl.message("Private", name: 'user__visibility_private');
  }

  String get user__visibility_private_desc {
    return Intl.message("Only people you approve can see your profile.",
        name: 'user__visibility_private_desc');
  }

  String get user__visibility_okuna {
    return Intl.message("Okuna", name: 'user__visibility_okuna');
  }

  String get user__visibility_okuna_desc {
    return Intl.message("Only members of Okuna can see your profile.",
        name: 'user__visibility_okuna_desc');
  }

  String user__disconnect_from_user(String userName) {
    return Intl.message("Disconnect from $userName",
        args: [userName], name: 'user__disconnect_from_user');
  }

  String user__circle_peoples_count(String prettyUsersCount) {
    return Intl.message("$prettyUsersCount people",
        args: [prettyUsersCount], name: 'user__circle_peoples_count');
  }

  String user__follows_list_accounts_count(String prettyUsersCount) {
    return Intl.message("$prettyUsersCount accounts",
        args: [prettyUsersCount], name: 'user__follows_list_accounts_count');
  }

  String notifications__tab_general() {
    return Intl.message("General", name: 'notifications__tab_general');
  }

  String notifications__tab_requests() {
    return Intl.message("Requests", name: 'notifications__tab_requests');
  }

  String get notifications__settings_title {
    return Intl.message("Notifications settings",
        name: 'notifications__settings_title');
  }

  String get notifications__general_title {
    return Intl.message("Notifications", name: 'notifications__general_title');
  }

  String get notifications__general_desc {
    return Intl.message("Be notified when something happens",
        name: 'notifications__general_desc');
  }

  String get notifications__follow_title {
    return Intl.message("Follow", name: 'notifications__follow_title');
  }

  String get notifications__follow_desc {
    return Intl.message("Be notified when someone starts following you",
        name: 'notifications__follow_desc');
  }

  String get notifications__follow_request_title {
    return Intl.message("Follow request",
        name: 'notifications__follow_request_title');
  }

  String get notifications__follow_request_desc {
    return Intl.message("Be notified when someone wants to follow you.",
        name: 'notifications__follow_request_desc');
  }

  String get notifications__follow_request_approved_title {
    return Intl.message("Follow request approved",
        name: 'notifications__follow_request_approved_title');
  }

  String get notifications__follow_request_approved_title_desc {
    return Intl.message(
        "Be notified when someone approves your follow request.",
        name: 'notifications__follow_request_approved_title_desc');
  }

  String get notifications__connection_title {
    return Intl.message("Connection request",
        name: 'notifications__connection_title');
  }

  String get notifications__connection_desc {
    return Intl.message("Be notified when someone wants to connect with you",
        name: 'notifications__connection_desc');
  }

  String get notifications__comment_title {
    return Intl.message("Post comment", name: 'notifications__comment_title');
  }

  String get notifications__comment_desc {
    return Intl.message(
        "Be notified when someone comments on one of your posts or one you also commented",
        name: 'notifications__comment_desc');
  }

  String get notifications__comment_reply_title {
    return Intl.message("Post comment reply",
        name: 'notifications__comment_reply_title');
  }

  String get notifications__comment_reply_desc {
    return Intl.message(
        "Be notified when someone replies to one of your comments or one you also replied to",
        name: 'notifications__comment_reply_desc');
  }

  String get notifications__comment_user_mention_title {
    return Intl.message("Post comment mention",
        name: 'notifications__comment_user_mention_title');
  }

  String get notifications__comment_user_mention_desc {
    return Intl.message(
        "Be notified when someone mentions you on one of their comments",
        name: 'notifications__comment_user_mention_desc');
  }

  String get notifications__post_user_mention_title {
    return Intl.message("Post mention",
        name: 'notifications__post_user_mention_title');
  }

  String get notifications__post_user_mention_desc {
    return Intl.message(
        "Be notified when someone mentions you on one of their posts",
        name: 'notifications__post_user_mention_desc');
  }

  String get notifications__comment_reaction_title {
    return Intl.message("Post comment reaction",
        name: 'notifications__comment_reaction_title');
  }

  String get notifications__comment_reaction_desc {
    return Intl.message(
        "Be notified when someone reacts to one of your post commments",
        name: 'notifications__comment_reaction_desc');
  }

  String get notifications__post_reaction_title {
    return Intl.message("Post reaction",
        name: 'notifications__post_reaction_title');
  }

  String get notifications__post_reaction_desc {
    return Intl.message("Be notified when someone reacts to one of your posts",
        name: 'notifications__post_reaction_desc');
  }

  String get notifications__community_invite_title {
    return Intl.message("Community invite",
        name: 'notifications__community_invite_title');
  }

  String get notifications__community_invite_desc {
    return Intl.message(
        "Be notified when someone invites you to join a community",
        name: 'notifications__community_invite_desc');
  }

  String get notifications__community_new_post_title {
    return Intl.message("Community new post",
        name: 'notifications__community_new_post_title');
  }

  String get notifications__community_new_post_desc {
    return Intl.message(
        "Be notified when there is a new post in a community you enabled post notifications on",
        name: 'notifications__community_new_post_desc');
  }

  String get notifications__user_new_post_title {
    return Intl.message("User new post",
        name: 'notifications__user_new_post_title');
  }

  String get notifications__user_new_post_desc {
    return Intl.message(
        "Be notified when there is a new post by a user you enabled notifications on",
        name: 'notifications__user_new_post_desc');
  }

  String get notifications__mute_post_turn_on_post_notifications {
    return Intl.message("Turn on post notifications",
        name: 'notifications__mute_post_turn_on_post_notifications');
  }

  String get notifications__mute_post_turn_off_post_notifications {
    return Intl.message("Turn off post notifications",
        name: 'notifications__mute_post_turn_off_post_notifications');
  }

  String get notifications__mute_post_turn_on_post_comment_notifications {
    return Intl.message("Turn on post comment notifications",
        name: 'notifications__mute_post_turn_on_post_comment_notifications');
  }

  String get notifications__mute_post_turn_off_post_comment_notifications {
    return Intl.message("Turn off post comment notifications",
        name: 'notifications__mute_post_turn_off_post_comment_notifications');
  }

  String get notifications__connection_request_tile {
    return Intl.message("[name] [username] wants to connect with you.",
        desc: "Eg.: James @jamest wants to connect with you.",
        name: 'notifications__connection_request_tile');
  }

  String get notifications__accepted_connection_request_tile {
    return Intl.message("[name] [username] accepted your connection request.",
        desc: "Eg.: James @jamest accepted your connection request.",
        name: 'notifications__accepted_connection_request_tile');
  }

  String get notifications__follow_request_tile {
    return Intl.message("[name] [username] wants to follow you.",
        desc: "Eg.: James @jamest wants to follow you.",
        name: 'notifications__follow_request_tile');
  }

  String get notifications__approved_follow_request_tile {
    return Intl.message("[name] [username] approved your follow request.",
        desc: "Eg.: James @jamest approved your follow request.",
        name: 'notifications__approved_follow_request_tile');
  }

  String get notifications__reacted_to_post_tile {
    return Intl.message("[name] [username] reacted to your post.",
        desc: "Eg.: James @jamest reacted to your post.",
        name: 'notifications__reacted_to_post_tile');
  }

  String get notifications__reacted_to_post_comment_tile {
    return Intl.message("[name] [username] reacted to your post comment.",
        desc: "Eg.: James @jamest reacted to your post comment.",
        name: 'notifications__reacted_to_post_comment_tile');
  }

  String get notifications__following_you_tile {
    return Intl.message("[name] [username] is now following you.",
        desc: "Eg.: James @jamest is now following you.",
        name: 'notifications__following_you_tile');
  }

  String notifications__user_community_invite_tile(String communityName) {
    return Intl.message(
        "[name] [username] has invited you to join community c/$communityName.",
        args: [communityName],
        desc: "Eg.: James @jamest has invited you to join community c/okuna.",
        name: 'notifications__user_community_invite_tile');
  }

  String notifications__community_new_post_tile(String communityName) {
    return Intl.message("There was a new post in c/$communityName.",
        args: [communityName],
        desc: "Eg.: There was a new post in c/okuna.",
        name: 'notifications__community_new_post_tile');
  }

  String notifications__comment_reply_notification_tile_user_replied(
      String postCommentText) {
    return Intl.message("[name] [username] replied: $postCommentText",
        desc: 'For.eg. James @jamest replied.',
        args: [postCommentText],
        name: 'notifications__comment_reply_notification_tile_user_replied');
  }

  String notifications__comment_reply_notification_tile_user_also_replied(
      String postCommentText) {
    return Intl.message("[name] [username] also replied: $postCommentText",
        args: [postCommentText],
        name:
            'notifications__comment_reply_notification_tile_user_also_replied');
  }

  String notifications__comment_comment_notification_tile_user_commented(
      String postCommentText) {
    return Intl.message(
        "[name] [username] commented on your post: $postCommentText",
        args: [postCommentText],
        name:
            'notifications__comment_comment_notification_tile_user_commented');
  }

  String notifications__comment_comment_notification_tile_user_also_commented(
      String postCommentText) {
    return Intl.message("[name] [username] also commented: $postCommentText",
        args: [postCommentText],
        name:
            'notifications__comment_comment_notification_tile_user_also_commented');
  }

  String get moderation__filters_title {
    return Intl.message("Moderation Filters",
        name: 'moderation__filters_title');
  }

  String get moderation__filters_reset {
    return Intl.message("Reset", name: 'moderation__filters_reset');
  }

  String get moderation__filters_verified {
    return Intl.message("Verified", name: 'moderation__filters_verified');
  }

  String get moderation__filters_apply {
    return Intl.message("Apply filters", name: 'moderation__filters_apply');
  }

  String get moderation__filters_type {
    return Intl.message("Type", name: 'moderation__filters_type');
  }

  String get moderation__filters_status {
    return Intl.message("Status", name: 'moderation__filters_status');
  }

  String get moderation__filters_other {
    return Intl.message("Other", name: 'moderation__filters_other');
  }

  String get moderation__actions_review {
    return Intl.message("Review", name: 'moderation__actions_review');
  }

  String get moderation__actions_chat_with_team {
    return Intl.message("Chat with the team",
        name: 'moderation__actions_chat_with_team');
  }

  String get moderation__update_category_title {
    return Intl.message("Update category",
        name: 'moderation__update_category_title');
  }

  String get moderation__update_category_save {
    return Intl.message("Save", name: 'moderation__update_category_save');
  }

  String get moderation__update_description_save {
    return Intl.message("Save", name: 'moderation__update_description_save');
  }

  String get moderation__update_description_title {
    return Intl.message("Edit description",
        name: 'moderation__update_description_title');
  }

  String get moderation__update_description_report_desc {
    return Intl.message("Report description",
        name: 'moderation__update_description_report_desc');
  }

  String get moderation__update_description_report_hint_text {
    return Intl.message("e.g. The report item was found to...",
        name: 'moderation__update_description_report_hint_text');
  }

  String get moderation__update_status_save {
    return Intl.message("Save", name: 'moderation__update_status_save');
  }

  String get moderation__update_status_title {
    return Intl.message("Update status",
        name: 'moderation__update_status_title');
  }

  String get moderation__community_review_title {
    return Intl.message("Review moderated object",
        name: 'moderation__community_review_title');
  }

  String get moderation__moderated_object_title {
    return Intl.message("Object", name: 'moderation__moderated_object_title');
  }

  String get moderation__moderated_object_status {
    return Intl.message("Status", name: 'moderation__moderated_object_status');
  }

  String get moderation__moderated_object_reports_count {
    return Intl.message("Reports count",
        name: 'moderation__moderated_object_reports_count');
  }

  String get moderation__moderated_object_verified_by_staff {
    return Intl.message("Verified by Okuna staff",
        name: 'moderation__moderated_object_verified_by_staff');
  }

  String get moderation__moderated_object_verified {
    return Intl.message("Verified",
        name: 'moderation__moderated_object_verified');
  }

  String get moderation__moderated_object_true_text {
    return Intl.message("True",
        desc: 'Eg. Moderated object verified by staff? true / false',
        name: 'moderation__moderated_object_true_text');
  }

  String get moderation__moderated_object_false_text {
    return Intl.message("False",
        desc: 'Eg. Moderated object verified by staff? true / false',
        name: 'moderation__moderated_object_false_text');
  }

  String get moderation__community_review_object {
    return Intl.message("Object", name: 'moderation__community_review_object');
  }

  String get moderation__community_review_approve {
    return Intl.message("Approve",
        name: 'moderation__community_review_approve');
  }

  String get moderation__community_review_reject {
    return Intl.message("reject", name: 'moderation__community_review_reject');
  }

  String get moderation__community_review_item_verified {
    return Intl.message("This item has been verified",
        name: 'moderation__community_review_item_verified');
  }

  String get moderation__global_review_title {
    return Intl.message("Review moderated object",
        name: 'moderation__global_review_title');
  }

  String get moderation__global_review_object_text {
    return Intl.message("Object",
        name: 'moderation__global_review_object_text');
  }

  String get moderation__global_review_verify_text {
    return Intl.message("Verify",
        name: 'moderation__global_review_verify_text');
  }

  String get moderation__global_review_unverify_text {
    return Intl.message("Unverify",
        name: 'moderation__global_review_unverify_text');
  }

  String get moderation__confirm_report_title {
    return Intl.message("Submit report",
        name: 'moderation__confirm_report_title');
  }

  String get moderation__confirm_report_provide_details {
    return Intl.message(
        "Can you provide extra details that might be relevant to the report?",
        name: 'moderation__confirm_report_provide_details');
  }

  String get moderation__confirm_report_provide_optional_info {
    return Intl.message("(Optional)",
        name: 'moderation__confirm_report_provide_optional_info');
  }

  String get moderation__confirm_report_provide_optional_hint_text {
    return Intl.message("Type here...",
        name: 'moderation__confirm_report_provide_optional_hint_text');
  }

  String get moderation__confirm_report_provide_happen_next {
    return Intl.message("Here's what will happen next:",
        name: 'moderation__confirm_report_provide_happen_next');
  }

  String get moderation__confirm_report_provide_happen_next_desc {
    return Intl.message(
        "- Your report will be submitted anonymously. \n"
        "- If you are reporting a post or comment, the report will be sent to the Okuna staff and the community moderators if applicable and the post will be hidden from your feed. \n"
        "- If you are reporting an account or community, it will be sent to the Okuna staff. \n"
        "- We'll review it, if approved, content will be deleted and penalties delivered to the people involved ranging from a temporary suspension to deletion of the account depending on the severity of the transgression. \n"
        "- If the report is found to be made in an attempt to damage the reputation of another member or community in the platform with no infringement of the stated reason, penalties will be applied to you. \n",
        name: 'moderation__confirm_report_provide_happen_next_desc');
  }

  String get moderation__confirm_report_submit {
    return Intl.message("I understand, submit.",
        name: 'moderation__confirm_report_submit');
  }

  String get moderation__confirm_report_user_reported {
    return Intl.message("User reported",
        name: 'moderation__confirm_report_user_reported');
  }

  String get moderation__confirm_report_community_reported {
    return Intl.message("Community reported",
        name: 'moderation__confirm_report_community_reported');
  }

  String get moderation__confirm_report_post_reported {
    return Intl.message("Post reported",
        name: 'moderation__confirm_report_post_reported');
  }

  String get moderation__confirm_report_post_comment_reported {
    return Intl.message("Post comment reported",
        name: 'moderation__confirm_report_post_comment_reported');
  }

  String get moderation__confirm_report_item_reported {
    return Intl.message("Item reported",
        name: 'moderation__confirm_report_item_reported');
  }

  String get moderation__community_moderated_objects {
    return Intl.message("Community moderated objects",
        name: 'moderation__community_moderated_objects');
  }

  String get moderation__globally_moderated_objects {
    return Intl.message("Globally moderated objects",
        name: 'moderation__globally_moderated_objects');
  }

  String get moderation__tap_to_retry {
    return Intl.message("Tap to retry loading items",
        name: 'moderation__tap_to_retry');
  }

  String get moderation__report_post_text {
    return Intl.message("Report post", name: 'moderation__report_post_text');
  }

  String get moderation__you_have_reported_post_text {
    return Intl.message("You have reported this post",
        name: 'moderation__you_have_reported_post_text');
  }

  String get moderation__report_account_text {
    return Intl.message("Report account",
        name: 'moderation__report_account_text');
  }

  String get moderation__you_have_reported_account_text {
    return Intl.message("You have reported this account",
        name: 'moderation__you_have_reported_account_text');
  }

  String get moderation__report_hashtag_text {
    return Intl.message("Report hashtag",
        name: 'moderation__report_hashtag_text');
  }

  String get moderation__you_have_reported_hashtag_text {
    return Intl.message("You have reported this hashtag",
        name: 'moderation__you_have_reported_hashtag_text');
  }

  String get moderation__report_community_text {
    return Intl.message("Report community",
        name: 'moderation__report_community_text');
  }

  String get moderation__you_have_reported_community_text {
    return Intl.message("You have reported this community",
        name: 'moderation__you_have_reported_community_text');
  }

  String get moderation__report_comment_text {
    return Intl.message("Report comment",
        name: 'moderation__report_comment_text');
  }

  String get moderation__you_have_reported_comment_text {
    return Intl.message("You have reported this comment",
        name: 'moderation__you_have_reported_comment_text');
  }

  String get moderation__description_text {
    return Intl.message("Description", name: 'moderation__description_text');
  }

  String get moderation__no_description_text {
    return Intl.message("No description",
        name: 'moderation__no_description_text');
  }

  String get moderation__category_text {
    return Intl.message("Category", name: 'moderation__category_text');
  }

  String get moderation__reporter_text {
    return Intl.message("Reporter", name: 'moderation__reporter_text');
  }

  String get moderation__reports_preview_title {
    return Intl.message("Reports", name: 'moderation__reports_preview_title');
  }

  String get moderation__reports_preview_resource_reports {
    return Intl.message("reports",
        desc: 'Usage: See all reports..',
        name: 'moderation__reports_preview_resource_reports');
  }

  String moderation__reports_see_all(int resourceCount, String resourceName) {
    return Intl.message("See all $resourceCount $resourceName",
        desc: 'Usage: See all 4 reports.',
        args: [resourceCount, resourceName],
        name: 'moderation__reports_see_all');
  }

  String get moderation__object_status_title {
    return Intl.message("Status", name: 'moderation__object_status_title');
  }

  String get moderation__my_moderation_tasks_title {
    return Intl.message("Pending moderation tasks",
        name: 'moderation__my_moderation_tasks_title');
  }

  String get moderation__pending_moderation_tasks_singular {
    return Intl.message("pending moderation task",
        name: 'moderation__pending_moderation_tasks_singular');
  }

  String get moderation__pending_moderation_tasks_plural {
    return Intl.message("pending moderation tasks",
        desc: 'Eg. No pending moderation tasks found',
        name: 'moderation__pending_moderation_tasks_plural');
  }

  String get moderation__my_moderation_penalties_title {
    return Intl.message("Moderation penalties",
        name: 'moderation__my_moderation_penalties_title');
  }

  String get moderation__my_moderation_penalties_resouce_singular {
    return Intl.message("moderation penalty",
        name: 'moderation__my_moderation_penalties_resouce_singular');
  }

  String get moderation__my_moderation_penalties_resource_plural {
    return Intl.message("moderation penalties",
        desc:
            "See all moderation penalties, No moderation penalties found etc..",
        name: 'moderation__my_moderation_penalties_resource_plural');
  }

  String notifications__mentioned_in_post_comment_tile(String postCommentText) {
    return Intl.message(
        "[name] [username] mentioned you on a comment: $postCommentText",
        args: [postCommentText],
        desc: "Eg.: James @jamest mentioned you on a comment: hello @jamest",
        name: 'notifications__mentioned_in_post_comment_tile');
  }

  String get notifications__mentioned_in_post_tile {
    return Intl.message("[name] [username] mentioned you on a post.",
        desc: "Eg.: James @jamest mentioned you on a post.",
        name: 'notifications__mentioned_in_post_tile');
  }

  String get notifications__user_new_post_tile {
    return Intl.message("[name] [username] posted something.",
        desc: "Eg.: James @jamest posted something.",
        name: 'notifications__user_new_post_tile');
  }

  String get contextual_account_search_box__suggestions {
    return Intl.message("Suggestions",
        desc:
            "The title to display on the suggestions when searching for accounts when trying to mention someone.",
        name: 'contextual_account_search_box__suggestions');
  }

  String get contextual_account_search_box__no_results {
    return Intl.message("No results found",
        name: 'contextual_account_search_box__no_results');
  }

  String get contextual_community_search_box__suggestions {
    return Intl.message("Suggestions",
        desc:
            "The title to display on the suggestions when searching for communitys when trying to mention someone.",
        name: 'contextual_community_search_box__suggestions');
  }

  String get contextual_community_search_box__no_results {
    return Intl.message("No results found",
        name: 'contextual_community_search_box__no_results');
  }

  String contextual_hashtag_search_box__be_the_first(String hashtag) {
    return Intl.message("You\'ll be the first to use #$hashtag",
        args: [hashtag], name: 'contextual_hashtag_search_box__be_the_first');
  }

  String get image_picker__from_gallery {
    return Intl.message("From gallery", name: 'image_picker__from_gallery');
  }

  String get image_picker__from_camera {
    return Intl.message("From camera", name: 'image_picker__from_camera');
  }

  String image_picker__error_too_large(int limit) {
    return Intl.message("File too large (limit: $limit MB)",
        args: [limit], name: 'image_picker__error_too_large');
  }

  String get video_picker__from_gallery {
    return Intl.message("From gallery", name: 'video_picker__from_gallery');
  }

  String get video_picker__from_camera {
    return Intl.message("From camera", name: 'video_picker__from_camera');
  }

  String get post_uploader__generic_upload_failed {
    return Intl.message("Upload failed",
        name: 'post_uploader__generic_upload_failed');
  }

  String get post_uploader__creating_post {
    return Intl.message("Creating post...",
        name: 'post_uploader__creating_post');
  }

  String get post_uploader__compressing_media {
    return Intl.message("Compressing media...",
        name: 'post_uploader__compressing_media');
  }

  String get post_uploader__uploading_media {
    return Intl.message("Uploading media...",
        name: 'post_uploader__uploading_media');
  }

  String get post_uploader__publishing {
    return Intl.message("Publishing post...",
        name: 'post_uploader__publishing');
  }

  String get post_uploader__processing {
    return Intl.message("Processing post...",
        name: 'post_uploader__processing');
  }

  String get post_uploader__success {
    return Intl.message("Success!", name: 'post_uploader__success');
  }

  String get post_uploader__cancelling {
    return Intl.message("Cancelling", name: 'post_uploader__cancelling');
  }

  String get post_uploader__cancelled {
    return Intl.message("Cancelled!", name: 'post_uploader__cancelled');
  }

  String get post_body_media__unsupported {
    return Intl.message("Unsupported media type",
        name: 'post_body_media__unsupported');
  }

  String get post_body_link_preview__empty {
    return Intl.message("This link could not be previewed",
        name: 'post_body_link_preview__empty');
  }

  String post_body_link_preview__invalid(String link) {
    return Intl.message("Invalid link: $link",
        args: [link], name: 'post_body_link_preview__invalid');
  }

  String post_body_link_preview__error_with_description(String description) {
    return Intl.message(
        "Failed to preview link with website error: $description",
        args: [description],
        name: 'post_body_link_preview__error_with_description');
  }

  String get link_preview_failed__title {
    return Intl.message("Preview failed", name: 'link_preview_failed__title');
  }

  String get link_preview_failed__description {
    return Intl.message("We could not preview this link right now",
        name: 'link_preview_failed');
  }

  String get retry {
    return Intl.message("Retry", name: 'retry');
  }

  String get posts_stream__all_loaded {
    return Intl.message("🎉  All posts loaded",
        name: 'posts_stream__all_loaded');
  }

  String get posts_stream__refreshing_drhoo_title {
    return Intl.message("Hang in there!",
        name: 'posts_stream__refreshing_drhoo_title');
  }

  String get posts_stream__refreshing_drhoo_subtitle {
    return Intl.message("Refreshing the stream.",
        name: 'posts_stream__refreshing_drhoo_subtitle');
  }

  String get posts_stream__empty_drhoo_title {
    return Intl.message("This stream is empty.",
        name: 'posts_stream__empty_drhoo_title');
  }

  String get posts_stream__empty_drhoo_subtitle {
    return Intl.message("Try refreshing in a couple of seconds.",
        name: 'posts_stream__empty_drhoo_subtitle');
  }

  String get posts_stream__failed_drhoo_title {
    return Intl.message("Could not load the stream.",
        name: 'posts_stream__failed_drhoo_title');
  }

  String get posts_stream__failed_drhoo_subtitle {
    return Intl.message("Try again in a couple seconds",
        name: 'posts_stream__failed_drhoo_subtitle');
  }

  String get posts_stream__status_tile_empty {
    return Intl.message("No posts found",
        name: 'posts_stream__status_tile_empty');
  }

  String get posts_stream__status_tile_no_more_to_load {
    return Intl.message("🎉  All posts loaded",
        name: 'posts_stream__status_tile_no_more_to_load');
  }

  String get application_settings__videos {
    return Intl.message("Videos", name: 'application_settings__videos');
  }

  String get application_settings__link_previews {
    return Intl.message("Link previews",
        name: 'application_settings__link_previews');
  }

  String get application_settings__hashtags_display {
    return Intl.message("Display",
        name: 'application_settings__hashtags_display');
  }

  String get application_settings__hashtags {
    return Intl.message("Hashtags", name: 'application_settings__hashtags');
  }

  String get application_settings__videos_autoplay {
    return Intl.message("Autoplay",
        name: 'application_settings__videos_autoplay');
  }

  String get application_settings__link_previews_show {
    return Intl.message("Show",
        name: 'application_settings__link_previews_show');
  }

  String get application_settings__videos_autoplay_always {
    return Intl.message("Always",
        name: 'application_settings__videos_autoplay_always');
  }

  String get application_settings__videos_autoplay_wifi_only {
    return Intl.message("Wifi only",
        name: 'application_settings__videos_autoplay_wifi_only');
  }

  String get application_settings__videos_autoplay_never {
    return Intl.message("Never",
        name: 'application_settings__videos_autoplay_never');
  }

  String get application_settings__link_previews_autoplay_always {
    return Intl.message("Always",
        name: 'application_settings__link_previews_autoplay_always');
  }

  String get application_settings__link_previews_autoplay_wifi_only {
    return Intl.message("Wifi only",
        name: 'application_settings__link_previews_autoplay_wifi_only');
  }

  String get application_settings__link_previews_autoplay_never {
    return Intl.message("Never",
        name: 'application_settings__link_previews_autoplay_never');
  }

  String get application_settings__videos_sound {
    return Intl.message("Sound", name: 'application_settings__videos_sound');
  }

  String get application_settings__tap_to_change {
    return Intl.message("(Tap to change)",
        name: 'application_settings__tap_to_change');
  }

  String get application_settings__videos_sound_enabled {
    return Intl.message("Enabled",
        name: 'application_settings__videos_sound_enabled');
  }

  String get application_settings__videos_sound_disabled {
    return Intl.message("Disabled",
        name: 'application_settings__videos_sound_disabled');
  }

  String get application_settings__hashtags_display_traditional {
    return Intl.message("Traditional",
        name: 'application_settings__hashtags_display_traditional');
  }

  String get application_settings__hashtags_display_disco {
    return Intl.message("🕺 Disco",
        name: 'application_settings__hashtags_display_disco');
  }

  String get application_settings__comment_sort_newest_first {
    return Intl.message("Newest first",
        name: 'application_settings__comment_sort_newest_first');
  }

  String get application_settings__comment_sort_oldest_first {
    return Intl.message("Oldest first",
        name: 'application_settings__comment_sort_oldest_first');
  }

  String get media_service__crop_image {
    return Intl.message("Crop image", name: 'media_service__crop_image');
  }

  String get permissions_service__storage_permission_denied {
    return Intl.message(
        "We require the storage permission to allow you to pick media items, please grant it in your settings.",
        name: 'permissions_service__storage_permission_denied');
  }

  String get permissions_service__camera_permission_denied {
    return Intl.message(
        "We require the camera permission to allow you to take photos and record videos, please grant it in your settings.",
        name: 'permissions_service__camera_permission_denied');
  }

  String get bottom_sheets__confirm_action_are_you_sure {
    return Intl.message("Are you sure?",
        name: 'bottom_sheets__confirm_action_are_you_sure');
  }

  String get bottom_sheets__confirm_action_yes {
    return Intl.message("Yes", name: 'bottom_sheets__confirm_action_yes');
  }

  String get bottom_sheets__confirm_action_no {
    return Intl.message("No", name: 'bottom_sheets__confirm_action_no');
  }

  String get bottom_sheets__dismiss {
    return Intl.message("Dismiss", name: 'bottom_sheets__dismiss');
  }

  Locale getLocale() {
    return locale;
  }
}
