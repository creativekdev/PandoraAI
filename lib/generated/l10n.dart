// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// ` avatars`
  String get avatars {
    return Intl.message(
      ' avatars',
      name: 'avatars',
      desc: '',
      args: [],
    );
  }

  /// `author`
  String get author {
    return Intl.message(
      'author',
      name: 'author',
      desc: '',
      args: [],
    );
  }

  /// `Pandora User`
  String get accountCancelled {
    return Intl.message(
      'Pandora User',
      name: 'accountCancelled',
      desc: '',
      args: [],
    );
  }

  /// `By registering you agree to`
  String get agree_text1 {
    return Intl.message(
      'By registering you agree to',
      name: 'agree_text1',
      desc: '',
      args: [],
    );
  }

  /// ` of the Cartoonizer.`
  String get agree_text2 {
    return Intl.message(
      ' of the Cartoonizer.',
      name: 'agree_text2',
      desc: '',
      args: [],
    );
  }

  /// `All Plans`
  String get all_plans {
    return Intl.message(
      'All Plans',
      name: 'all_plans',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get already_account {
    return Intl.message(
      'Already have an account? ',
      name: 'already_account',
      desc: '',
      args: [],
    );
  }

  /// `and`
  String get and {
    return Intl.message(
      'and',
      name: 'and',
      desc: '',
      args: [],
    );
  }

  /// `Pandora AI`
  String get app_name {
    return Intl.message(
      'Pandora AI',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Apple`
  String get apple {
    return Intl.message(
      'Continue with Apple',
      name: 'apple',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to delete this post?`
  String get are_you_sure_to_delete_this_post {
    return Intl.message(
      'Are you sure to delete this post?',
      name: 'are_you_sure_to_delete_this_post',
      desc: '',
      args: [],
    );
  }

  /// `Group shots, only photos looking INTO the camera, covered faces/sunglasses, monotonous pics, nudes, kids(ONLY 12+ ADULTS)`
  String get bad_photo_description {
    return Intl.message(
      'Group shots, only photos looking INTO the camera, covered faces/sunglasses, monotonous pics, nudes, kids(ONLY 12+ ADULTS)',
      name: 'bad_photo_description',
      desc: '',
      args: [],
    );
  }

  /// `Please don't upload photos of more than one pet; don't cover your pet's face; don't use photos where your pet curls up into a ball.`
  String get bad_photo_pet_description {
    return Intl.message(
      'Please don\'t upload photos of more than one pet; don\'t cover your pet\'s face; don\'t use photos where your pet curls up into a ball.',
      name: 'bad_photo_pet_description',
      desc: '',
      args: [],
    );
  }

  /// `Bad photo examples`
  String get bad_photo_examples {
    return Intl.message(
      'Bad photo examples',
      name: 'bad_photo_examples',
      desc: '',
      args: [],
    );
  }

  /// `Faster speed`
  String get buyAttrFasterSpeed {
    return Intl.message(
      'Faster speed',
      name: 'buyAttrFasterSpeed',
      desc: '',
      args: [],
    );
  }

  /// `High resolution images`
  String get buyAttrHDImages {
    return Intl.message(
      'High resolution images',
      name: 'buyAttrHDImages',
      desc: '',
      args: [],
    );
  }

  /// `No advertisements`
  String get buyAttrNoAds {
    return Intl.message(
      'No advertisements',
      name: 'buyAttrNoAds',
      desc: '',
      args: [],
    );
  }

  /// `No watermark`
  String get buyAttrNoWatermark {
    return Intl.message(
      'No watermark',
      name: 'buyAttrNoWatermark',
      desc: '',
      args: [],
    );
  }

  /// `Buy now`
  String get buyNow {
    return Intl.message(
      'Buy now',
      name: 'buyNow',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get c_password {
    return Intl.message(
      'Confirm Password',
      name: 'c_password',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Card Number`
  String get card_number {
    return Intl.message(
      'Card Number',
      name: 'card_number',
      desc: '',
      args: [],
    );
  }

  /// `Cartoonize`
  String get cartoonize {
    return Intl.message(
      'Cartoonize',
      name: 'cartoonize',
      desc: '',
      args: [],
    );
  }

  /// `Keep cartooning`
  String get cartoonizeCancelDismiss {
    return Intl.message(
      'Keep cartooning',
      name: 'cartoonizeCancelDismiss',
      desc: '',
      args: [],
    );
  }

  /// `Cancel now`
  String get cartoonizeCancelExit {
    return Intl.message(
      'Cancel now',
      name: 'cartoonizeCancelExit',
      desc: '',
      args: [],
    );
  }

  /// `Closing the page will stop the transforming process. Are you sure to continue?`
  String get cartoonizeCancelTitle {
    return Intl.message(
      'Closing the page will stop the transforming process. Are you sure to continue?',
      name: 'cartoonizeCancelTitle',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get change_password {
    return Intl.message(
      'Change Password',
      name: 'change_password',
      desc: '',
      args: [],
    );
  }

  /// `Check out`
  String get checkout {
    return Intl.message(
      'Check out',
      name: 'checkout',
      desc: '',
      args: [],
    );
  }

  /// `Choose Photo`
  String get choose_photo {
    return Intl.message(
      'Choose Photo',
      name: 'choose_photo',
      desc: '',
      args: [],
    );
  }

  /// `Your code was emailed to `
  String get code_send_to_email {
    return Intl.message(
      'Your code was emailed to ',
      name: 'code_send_to_email',
      desc: '',
      args: [],
    );
  }

  /// `Oops Failed`
  String get commonFailedToast {
    return Intl.message(
      'Oops Failed',
      name: 'commonFailedToast',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirm_pass {
    return Intl.message(
      'Confirm Password',
      name: 'confirm_pass',
      desc: '',
      args: [],
    );
  }

  /// `Connect with us`
  String get connect_with_us {
    return Intl.message(
      'Connect with us',
      name: 'connect_with_us',
      desc: '',
      args: [],
    );
  }

  /// `Please enter confirm password`
  String get cpass_validation {
    return Intl.message(
      'Please enter confirm password',
      name: 'cpass_validation',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Create\nAccount`
  String get createAccount {
    return Intl.message(
      'Create\nAccount',
      name: 'createAccount',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get current_pass {
    return Intl.message(
      'Current Password',
      name: 'current_pass',
      desc: '',
      args: [],
    );
  }

  /// `You have run out of your daily credits. Please come back tomorrow.`
  String get DAILY_IP_LIMIT_EXCEEDED {
    return Intl.message(
      'You have run out of your daily credits. Please come back tomorrow.',
      name: 'DAILY_IP_LIMIT_EXCEEDED',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `delete succeed`
  String get delete_succeed {
    return Intl.message(
      'delete succeed',
      name: 'delete_succeed',
      desc: '',
      args: [],
    );
  }

  /// `Deny`
  String get deny {
    return Intl.message(
      'Deny',
      name: 'deny',
      desc: '',
      args: [],
    );
  }

  /// `Comment`
  String get discoveryComment {
    return Intl.message(
      'Comment',
      name: 'discoveryComment',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get discoveryComments {
    return Intl.message(
      'Comments',
      name: 'discoveryComments',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get discoveryDetails {
    return Intl.message(
      'Details',
      name: 'discoveryDetails',
      desc: '',
      args: [],
    );
  }

  /// `Try this template`
  String get discoveryDetailsUseSameTemplate {
    return Intl.message(
      'Try this template',
      name: 'discoveryDetailsUseSameTemplate',
      desc: '',
      args: [],
    );
  }

  /// `Like`
  String get discoveryLike {
    return Intl.message(
      'Like',
      name: 'discoveryLike',
      desc: '',
      args: [],
    );
  }

  /// `I created this using %s`
  String get discoveryShareInputHint {
    return Intl.message(
      'I created this using %s',
      name: 'discoveryShareInputHint',
      desc: '',
      args: [],
    );
  }

  /// `Add some text`
  String get discoveryShareInputTitle {
    return Intl.message(
      'Add some text',
      name: 'discoveryShareInputTitle',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get discoveryShareSubmit {
    return Intl.message(
      'Submit',
      name: 'discoveryShareSubmit',
      desc: '',
      args: [],
    );
  }

  /// `Unlike`
  String get discoveryUnlike {
    return Intl.message(
      'Unlike',
      name: 'discoveryUnlike',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get download {
    return Intl.message(
      'Download',
      name: 'download',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `No record of your usage found\nPlease make your first profile pic to view your history here`
  String get effectRecentEmptyHint {
    return Intl.message(
      'No record of your usage found\nPlease make your first profile pic to view your history here',
      name: 'effectRecentEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter email`
  String get email_validation {
    return Intl.message(
      'Please enter email',
      name: 'email_validation',
      desc: '',
      args: [],
    );
  }

  /// `Please enter valid email`
  String get email_validation1 {
    return Intl.message(
      'Please enter valid email',
      name: 'email_validation1',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get emailAddress {
    return Intl.message(
      'Email Address',
      name: 'emailAddress',
      desc: '',
      args: [],
    );
  }

  /// `No Data Found.`
  String get empty_msg {
    return Intl.message(
      'No Data Found.',
      name: 'empty_msg',
      desc: '',
      args: [],
    );
  }

  /// `Enter 6-digit code`
  String get enter_email_code {
    return Intl.message(
      'Enter 6-digit code',
      name: 'enter_email_code',
      desc: '',
      args: [],
    );
  }

  /// `Examples`
  String get examples {
    return Intl.message(
      'Examples',
      name: 'examples',
      desc: '',
      args: [],
    );
  }

  /// `EXIT EDITING`
  String get exit_editing {
    return Intl.message(
      'EXIT EDITING',
      name: 'exit_editing',
      desc: '',
      args: [],
    );
  }

  /// `Exit editing?`
  String get exit_msg {
    return Intl.message(
      'Exit editing?',
      name: 'exit_msg',
      desc: '',
      args: [],
    );
  }

  /// `You will lose all your progress.`
  String get exit_msg1 {
    return Intl.message(
      'You will lose all your progress.',
      name: 'exit_msg1',
      desc: '',
      args: [],
    );
  }

  /// `The AI that Pandora Avatar uses can generate unpredictable results which may include artistic nudes, defects or shocking images. This is not within our countrol. Please acknowledge and accept full responsibility and risk before continue.`
  String get expect_details {
    return Intl.message(
      'The AI that Pandora Avatar uses can generate unpredictable results which may include artistic nudes, defects or shocking images. This is not within our countrol. Please acknowledge and accept full responsibility and risk before continue.',
      name: 'expect_details',
      desc: '',
      args: [],
    );
  }

  /// `Expired Date`
  String get expired_date {
    return Intl.message(
      'Expired Date',
      name: 'expired_date',
      desc: '',
      args: [],
    );
  }

  /// `Continue with IG Business(via FB)`
  String get facebook {
    return Intl.message(
      'Continue with IG Business(via FB)',
      name: 'facebook',
      desc: '',
      args: [],
    );
  }

  /// `Faster Speed`
  String get faster_speed {
    return Intl.message(
      'Faster Speed',
      name: 'faster_speed',
      desc: '',
      args: [],
    );
  }

  /// `Feedback`
  String get feedback {
    return Intl.message(
      'Feedback',
      name: 'feedback',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get forgot_password {
    return Intl.message(
      'Forgot Password?',
      name: 'forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter your registered email below to receive password reset instruction`
  String get forgot_password_text {
    return Intl.message(
      'Enter your registered email below to receive password reset instruction',
      name: 'forgot_password_text',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Your Password?`
  String get forgot_your_password {
    return Intl.message(
      'Forgot Your Password?',
      name: 'forgot_your_password',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get full_name {
    return Intl.message(
      'Full Name',
      name: 'full_name',
      desc: '',
      args: [],
    );
  }

  /// `Go Premium`
  String get go_premium {
    return Intl.message(
      'Go Premium',
      name: 'go_premium',
      desc: '',
      args: [],
    );
  }

  /// `Show your shoulders, close-up selfies, same person in the photos, variety of location/backgrounds/angels, different facial expressions.`
  String get good_photo_description {
    return Intl.message(
      'Show your shoulders, close-up selfies, same person in the photos, variety of location/backgrounds/angels, different facial expressions.',
      name: 'good_photo_description',
      desc: '',
      args: [],
    );
  }

  /// `Closeup portraits or full body shots of your pet; always upload photos of the same one; various angles, lighting and settings are welcomed.`
  String get good_photo_pet_description {
    return Intl.message(
      'Closeup portraits or full body shots of your pet; always upload photos of the same one; various angles, lighting and settings are welcomed.',
      name: 'good_photo_pet_description',
      desc: '',
      args: [],
    );
  }

  /// `Good photo examples`
  String get good_photo_examples {
    return Intl.message(
      'Good photo examples',
      name: 'good_photo_examples',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Google`
  String get google {
    return Intl.message(
      'Continue with Google',
      name: 'google',
      desc: '',
      args: [],
    );
  }

  /// `The better you follow these guidelines, the better chances for great result!`
  String get guidelines {
    return Intl.message(
      'The better you follow these guidelines, the better chances for great result!',
      name: 'guidelines',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get help {
    return Intl.message(
      'Help',
      name: 'help',
      desc: '',
      args: [],
    );
  }

  /// `High resolution images`
  String get high_resolution {
    return Intl.message(
      'High resolution images',
      name: 'high_resolution',
      desc: '',
      args: [],
    );
  }

  /// `Pandora AI`
  String get home {
    return Intl.message(
      'Pandora AI',
      name: 'home',
      desc: '',
      args: [],
    );
  }

  /// `Include original`
  String get in_original {
    return Intl.message(
      'Include original',
      name: 'in_original',
      desc: '',
      args: [],
    );
  }

  /// `Input name`
  String get input_name {
    return Intl.message(
      'Input name',
      name: 'input_name',
      desc: '',
      args: [],
    );
  }

  /// `Instagram`
  String get insta_login {
    return Intl.message(
      'Instagram',
      name: 'insta_login',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Instagram`
  String get instagram {
    return Intl.message(
      'Continue with Instagram',
      name: 'instagram',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get login {
    return Intl.message(
      'Sign In',
      name: 'login',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `MOST POPULAR`
  String get most_popular {
    return Intl.message(
      'MOST POPULAR',
      name: 'most_popular',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get msgTitle {
    return Intl.message(
      'Messages',
      name: 'msgTitle',
      desc: '',
      args: [],
    );
  }

  /// `Full Name`
  String get name {
    return Intl.message(
      'Full Name',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `Enter name`
  String get name_hint {
    return Intl.message(
      'Enter name',
      name: 'name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please enter name`
  String get name_validation {
    return Intl.message(
      'Please enter name',
      name: 'name_validation',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get new_pass {
    return Intl.message(
      'New Password',
      name: 'new_pass',
      desc: '',
      args: [],
    );
  }

  /// `A required update is available, the App will not be working until this update is applied.`
  String get new_update_dialog_content {
    return Intl.message(
      'A required update is available, the App will not be working until this update is applied.',
      name: 'new_update_dialog_content',
      desc: '',
      args: [],
    );
  }

  /// `A required update is available, update to explore new features!`
  String get new_update_dialog_content_cancellable {
    return Intl.message(
      'A required update is available, update to explore new features!',
      name: 'new_update_dialog_content_cancellable',
      desc: '',
      args: [],
    );
  }

  /// `New Update Required`
  String get new_update_dialog_title {
    return Intl.message(
      'New Update Required',
      name: 'new_update_dialog_title',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have an account? `
  String get no_account {
    return Intl.message(
      'Don’t have an account? ',
      name: 'no_account',
      desc: '',
      args: [],
    );
  }

  /// `No Ads`
  String get no_ads {
    return Intl.message(
      'No Ads',
      name: 'no_ads',
      desc: '',
      args: [],
    );
  }

  /// `Oops! Please check your network connection.`
  String get no_internet_msg {
    return Intl.message(
      'Oops! Please check your network connection.',
      name: 'no_internet_msg',
      desc: '',
      args: [],
    );
  }

  /// `(No watermark, High-res image)`
  String get no_watermark {
    return Intl.message(
      '(No watermark, High-res image)',
      name: 'no_watermark',
      desc: '',
      args: [],
    );
  }

  /// `No watermark`
  String get no_watermark1 {
    return Intl.message(
      'No watermark',
      name: 'no_watermark1',
      desc: '',
      args: [],
    );
  }

  /// `Not enough photos`
  String get not_enough_photos {
    return Intl.message(
      'Not enough photos',
      name: 'not_enough_photos',
      desc: '',
      args: [],
    );
  }

  /// `Ok`
  String get ok {
    return Intl.message(
      'Ok',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok1 {
    return Intl.message(
      'OK',
      name: 'ok1',
      desc: '',
      args: [],
    );
  }

  /// `Or`
  String get or {
    return Intl.message(
      'Or',
      name: 'or',
      desc: '',
      args: [],
    );
  }

  /// `other %d replies >`
  String get other_replies {
    return Intl.message(
      'other %d replies >',
      name: 'other_replies',
      desc: '',
      args: [],
    );
  }

  /// `Packages purchased`
  String get packages_purchased {
    return Intl.message(
      'Packages purchased',
      name: 'packages_purchased',
      desc: '',
      args: [],
    );
  }

  /// `Your photos will be generated in about %d minutes`
  String get pandora_create_spend {
    return Intl.message(
      'Your photos will be generated in about %d minutes',
      name: 'pandora_create_spend',
      desc: '',
      args: [],
    );
  }

  /// `Pandora Avatars use state of the art AI technology to create magnificent avatars for you! Despite requiring a high amount of resources (GPU), we’ve made it as affordable as possible!`
  String get pandora_pay_description {
    return Intl.message(
      'Pandora Avatars use state of the art AI technology to create magnificent avatars for you! Despite requiring a high amount of resources (GPU), we’ve made it as affordable as possible!',
      name: 'pandora_pay_description',
      desc: '',
      args: [],
    );
  }

  /// `Purchase for `
  String get pandora_purchase {
    return Intl.message(
      'Purchase for ',
      name: 'pandora_purchase',
      desc: '',
      args: [],
    );
  }

  /// `We only use your photos to train the AI model. Photos will be deleted from our servers within 24 hours`
  String get pandora_transfer_tips {
    return Intl.message(
      'We only use your photos to train the AI model. Photos will be deleted from our servers within 24 hours',
      name: 'pandora_transfer_tips',
      desc: '',
      args: [],
    );
  }

  /// `Please enter password`
  String get pass_validation {
    return Intl.message(
      'Please enter password',
      name: 'pass_validation',
      desc: '',
      args: [],
    );
  }

  /// `Password not matched`
  String get pass_validation1 {
    return Intl.message(
      'Password not matched',
      name: 'pass_validation1',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Pay`
  String get pay {
    return Intl.message(
      'Pay',
      name: 'pay',
      desc: '',
      args: [],
    );
  }

  /// `Pay with new card`
  String get pay_with_new_card {
    return Intl.message(
      'Pay with new card',
      name: 'pay_with_new_card',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get payment {
    return Intl.message(
      'Payment',
      name: 'payment',
      desc: '',
      args: [],
    );
  }

  /// `Payment successfully`
  String get payment_successfully {
    return Intl.message(
      'Payment successfully',
      name: 'payment_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Place your order`
  String get paymentBtn {
    return Intl.message(
      'Place your order',
      name: 'paymentBtn',
      desc: '',
      args: [],
    );
  }

  /// `MicroPhone Permission`
  String get permissionMicroPhone {
    return Intl.message(
      'MicroPhone Permission',
      name: 'permissionMicroPhone',
      desc: '',
      args: [],
    );
  }

  /// `This app needs microphone access to preview camera`
  String get permissionMicroPhoneContent {
    return Intl.message(
      'This app needs microphone access to preview camera',
      name: 'permissionMicroPhoneContent',
      desc: '',
      args: [],
    );
  }

  /// `Camera Permission`
  String get permissionCamera {
    return Intl.message(
      'Camera Permission',
      name: 'permissionCamera',
      desc: '',
      args: [],
    );
  }

  /// `This app needs camera access to take pictures for upload user profile photo`
  String get permissionCameraContent {
    return Intl.message(
      'This app needs camera access to take pictures for upload user profile photo',
      name: 'permissionCameraContent',
      desc: '',
      args: [],
    );
  }

  /// `PhotoLibrary Permission`
  String get permissionPhotoLibrary {
    return Intl.message(
      'PhotoLibrary Permission',
      name: 'permissionPhotoLibrary',
      desc: '',
      args: [],
    );
  }

  /// `This app needs photo library access. Go to settings?`
  String get permissionPhotoLibraryContent {
    return Intl.message(
      'This app needs photo library access. Go to settings?',
      name: 'permissionPhotoLibraryContent',
      desc: '',
      args: [],
    );
  }

  /// `Go to settings`
  String get permissionPhotoToSettings {
    return Intl.message(
      'Go to settings',
      name: 'permissionPhotoToSettings',
      desc: '',
      args: [],
    );
  }

  /// `Please enter an avatar name`
  String get please_enter_an_avatar_name {
    return Intl.message(
      'Please enter an avatar name',
      name: 'please_enter_an_avatar_name',
      desc: '',
      args: [],
    );
  }

  /// `Please login first`
  String get please_login_first {
    return Intl.message(
      'Please login first',
      name: 'please_login_first',
      desc: '',
      args: [],
    );
  }

  /// `Pandora AI Pro`
  String get ppmPro {
    return Intl.message(
      'Pandora AI Pro',
      name: 'ppmPro',
      desc: '',
      args: [],
    );
  }

  /// `Premium`
  String get premium {
    return Intl.message(
      'Premium',
      name: 'premium',
      desc: '',
      args: [],
    );
  }

  /// ` Privacy Policy`
  String get privacy_policy {
    return Intl.message(
      ' Privacy Policy',
      name: 'privacy_policy',
      desc: '',
      args: [],
    );
  }

  /// `Privacy policy`
  String get privacy_policy1 {
    return Intl.message(
      'Privacy policy',
      name: 'privacy_policy1',
      desc: '',
      args: [],
    );
  }

  /// `Pro`
  String get pro {
    return Intl.message(
      'Pro',
      name: 'pro',
      desc: '',
      args: [],
    );
  }

  /// `Rate us on the app store`
  String get rate_us {
    return Intl.message(
      'Rate us on the app store',
      name: 'rate_us',
      desc: '',
      args: [],
    );
  }

  /// `Rate us on the play store`
  String get rate_us1 {
    return Intl.message(
      'Rate us on the play store',
      name: 'rate_us1',
      desc: '',
      args: [],
    );
  }

  /// `Recently`
  String get recently {
    return Intl.message(
      'Recently',
      name: 'recently',
      desc: '',
      args: [],
    );
  }

  /// `reply`
  String get reply {
    return Intl.message(
      'reply',
      name: 'reply',
      desc: '',
      args: [],
    );
  }

  /// `Resend`
  String get resend {
    return Intl.message(
      'Resend',
      name: 'resend',
      desc: '',
      args: [],
    );
  }

  /// ` to change the email.`
  String get resend_logout {
    return Intl.message(
      ' to change the email.',
      name: 'resend_logout',
      desc: '',
      args: [],
    );
  }

  /// `Note: If for some reason you did not receive the email, please check your spam folder or click the button below to resend.`
  String get resend_tips {
    return Intl.message(
      'Note: If for some reason you did not receive the email, please check your spam folder or click the button below to resend.',
      name: 'resend_tips',
      desc: '',
      args: [],
    );
  }

  /// `RESTORE`
  String get restore {
    return Intl.message(
      'RESTORE',
      name: 'restore',
      desc: '',
      args: [],
    );
  }

  /// `Save Photo`
  String get save_photo {
    return Intl.message(
      'Save Photo',
      name: 'save_photo',
      desc: '',
      args: [],
    );
  }

  /// `Save & Share`
  String get save_share {
    return Intl.message(
      'Save & Share',
      name: 'save_share',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Select a style`
  String get select_a_style {
    return Intl.message(
      'Select a style',
      name: 'select_a_style',
      desc: '',
      args: [],
    );
  }

  /// `Select Style`
  String get select_style {
    return Intl.message(
      'Select Style',
      name: 'select_style',
      desc: '',
      args: [],
    );
  }

  /// `selfies`
  String get selfies {
    return Intl.message(
      'selfies',
      name: 'selfies',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Setup Password`
  String get set_password {
    return Intl.message(
      'Setup Password',
      name: 'set_password',
      desc: '',
      args: [],
    );
  }

  /// `Setting`
  String get setting {
    return Intl.message(
      'Setting',
      name: 'setting',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get setting_my_delete_account {
    return Intl.message(
      'Delete Account',
      name: 'setting_my_delete_account',
      desc: '',
      args: [],
    );
  }

  /// `My Discovery`
  String get setting_my_discovery {
    return Intl.message(
      'My Discovery',
      name: 'setting_my_discovery',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Clear cache`
  String get settingsClearCache {
    return Intl.message(
      'Clear cache',
      name: 'settingsClearCache',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Share App`
  String get share_app {
    return Intl.message(
      'Share App',
      name: 'share_app',
      desc: '',
      args: [],
    );
  }

  /// `Pandora AI`
  String get share_title {
    return Intl.message(
      'Pandora AI',
      name: 'share_title',
      desc: '',
      args: [],
    );
  }

  /// `Share to`
  String get share_to {
    return Intl.message(
      'Share to',
      name: 'share_to',
      desc: '',
      args: [],
    );
  }

  /// `Also share the original image`
  String get shareIncludeOriginal {
    return Intl.message(
      'Also share the original image',
      name: 'shareIncludeOriginal',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get sign_in {
    return Intl.message(
      'Sign In',
      name: 'sign_in',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get sign_up {
    return Intl.message(
      'Sign Up',
      name: 'sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up To Get 1 Image Credit`
  String get signup_text {
    return Intl.message(
      'Sign Up To Get 1 Image Credit',
      name: 'signup_text',
      desc: '',
      args: [],
    );
  }

  /// `Sign up for more uses`
  String get signup_text1 {
    return Intl.message(
      'Sign up for more uses',
      name: 'signup_text1',
      desc: '',
      args: [],
    );
  }

  /// `We're glad you're enjoying our tool! Sign up now or log in, it only takes 2 minutes and you can enjoy more uses!`
  String get signup_text2 {
    return Intl.message(
      'We\'re glad you\'re enjoying our tool! Sign up now or log in, it only takes 2 minutes and you can enjoy more uses!',
      name: 'signup_text2',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get submit {
    return Intl.message(
      'Submit',
      name: 'submit',
      desc: '',
      args: [],
    );
  }

  /// `Successful`
  String get successful {
    return Intl.message(
      'Successful',
      name: 'successful',
      desc: '',
      args: [],
    );
  }

  /// `Discovery`
  String get tabDiscovery {
    return Intl.message(
      'Discovery',
      name: 'tabDiscovery',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get tabHome {
    return Intl.message(
      'Home',
      name: 'tabHome',
      desc: '',
      args: [],
    );
  }

  /// `AI-Lab`
  String get tabAI {
    return Intl.message(
      'AI-Lab',
      name: 'tabAI',
      desc: '',
      args: [],
    );
  }

  /// `My`
  String get tabMine {
    return Intl.message(
      'My',
      name: 'tabMine',
      desc: '',
      args: [],
    );
  }

  /// `Or take a selfie`
  String get take_selfie {
    return Intl.message(
      'Or take a selfie',
      name: 'take_selfie',
      desc: '',
      args: [],
    );
  }

  /// `Terms and conditions`
  String get term_condition {
    return Intl.message(
      'Terms and conditions',
      name: 'term_condition',
      desc: '',
      args: [],
    );
  }

  /// ` Terms & Conditions`
  String get terms_condition {
    return Intl.message(
      ' Terms & Conditions',
      name: 'terms_condition',
      desc: '',
      args: [],
    );
  }

  /// `Continue with TikTok`
  String get tiktok {
    return Intl.message(
      'Continue with TikTok',
      name: 'tiktok',
      desc: '',
      args: [],
    );
  }

  /// `TikTok`
  String get tiktok_login {
    return Intl.message(
      'TikTok',
      name: 'tiktok_login',
      desc: '',
      args: [],
    );
  }

  /// `Image Saved`
  String get toastImageSaved {
    return Intl.message(
      'Image Saved',
      name: 'toastImageSaved',
      desc: '',
      args: [],
    );
  }

  /// `Video Saved`
  String get toastVideoSaved {
    return Intl.message(
      'Video Saved',
      name: 'toastVideoSaved',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get txtContinue {
    return Intl.message(
      'Continue',
      name: 'txtContinue',
      desc: '',
      args: [],
    );
  }

  /// `unique avatars`
  String get unique_avatars {
    return Intl.message(
      'unique avatars',
      name: 'unique_avatars',
      desc: '',
      args: [],
    );
  }

  /// `Update now`
  String get update_now {
    return Intl.message(
      'Update now',
      name: 'update_now',
      desc: '',
      args: [],
    );
  }

  /// `Update Password`
  String get update_pass {
    return Intl.message(
      'Update Password',
      name: 'update_pass',
      desc: '',
      args: [],
    );
  }

  /// `Update Your Profile`
  String get update_profile {
    return Intl.message(
      'Update Your Profile',
      name: 'update_profile',
      desc: '',
      args: [],
    );
  }

  /// `Upload photos`
  String get upload_photos {
    return Intl.message(
      'Upload photos',
      name: 'upload_photos',
      desc: '',
      args: [],
    );
  }

  /// `Uploading photos`
  String get uploading_photos {
    return Intl.message(
      'Uploading photos',
      name: 'uploading_photos',
      desc: '',
      args: [],
    );
  }

  /// `10 variations of 10 styles`
  String get variations_of_styles {
    return Intl.message(
      '10 variations of 10 styles',
      name: 'variations_of_styles',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get view_all {
    return Intl.message(
      'View All',
      name: 'view_all',
      desc: '',
      args: [],
    );
  }

  /// `Watch an ad to remove watermark\n(only this time)`
  String get watchAdHint {
    return Intl.message(
      'Watch an ad to remove watermark\n(only this time)',
      name: 'watchAdHint',
      desc: '',
      args: [],
    );
  }

  /// `Download HD image\nwithout watermark`
  String get watchAdText {
    return Intl.message(
      'Download HD image\nwithout watermark',
      name: 'watchAdText',
      desc: '',
      args: [],
    );
  }

  /// `Share HD image\nwithout watermark`
  String get watchAdToShareText {
    return Intl.message(
      'Share HD image\nwithout watermark',
      name: 'watchAdToShareText',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back!`
  String get welcome {
    return Intl.message(
      'Welcome Back!',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get welcome1 {
    return Intl.message(
      'Welcome',
      name: 'welcome1',
      desc: '',
      args: [],
    );
  }

  /// `Generate magic avatars using AI`
  String get welcome_title1 {
    return Intl.message(
      'Generate magic avatars using AI',
      name: 'welcome_title1',
      desc: '',
      args: [],
    );
  }

  /// `Make your personal AI avatars`
  String get welcome_title2 {
    return Intl.message(
      'Make your personal AI avatars',
      name: 'welcome_title2',
      desc: '',
      args: [],
    );
  }

  /// `One-click selfies to anime`
  String get welcome_title3 {
    return Intl.message(
      'One-click selfies to anime',
      name: 'welcome_title3',
      desc: '',
      args: [],
    );
  }

  /// `Welcome\nBack`
  String get welcomeBack {
    return Intl.message(
      'Welcome\nBack',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `What to Expect`
  String get what_to_expect {
    return Intl.message(
      'What to Expect',
      name: 'what_to_expect',
      desc: '',
      args: [],
    );
  }

  /// `Why it's paid`
  String get why_its_paid {
    return Intl.message(
      'Why it\'s paid',
      name: 'why_its_paid',
      desc: '',
      args: [],
    );
  }

  /// `Continue with You Tube`
  String get youtube {
    return Intl.message(
      'Continue with You Tube',
      name: 'youtube',
      desc: '',
      args: [],
    );
  }

  /// `Zip Code`
  String get zip_code {
    return Intl.message(
      'Zip Code',
      name: 'zip_code',
      desc: '',
      args: [],
    );
  }

  /// `Invalid zip code`
  String get zip_code_validation_message {
    return Intl.message(
      'Invalid zip code',
      name: 'zip_code_validation_message',
      desc: '',
      args: [],
    );
  }

  /// `You've selected %selected photos%badImages of %minSize minimum required.`
  String get choose_photo_not_enough_desc {
    return Intl.message(
      'You\'ve selected %selected photos%badImages of %minSize minimum required.',
      name: 'choose_photo_not_enough_desc',
      desc: '',
      args: [],
    );
  }

  /// ` with %badCount invalid`
  String get choose_photo_bad_images_desc {
    return Intl.message(
      ' with %badCount invalid',
      name: 'choose_photo_bad_images_desc',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least %d more photos.`
  String get choose_photo_more_photos {
    return Intl.message(
      'Please select at least %d more photos.',
      name: 'choose_photo_more_photos',
      desc: '',
      args: [],
    );
  }

  /// `You've selected %selected photos%badImages\n Are you sure to upload these %goodCount photos?`
  String get choose_photo_ok_description {
    return Intl.message(
      'You\'ve selected %selected photos%badImages\n Are you sure to upload these %goodCount photos?',
      name: 'choose_photo_ok_description',
      desc: '',
      args: [],
    );
  }

  /// `Select more photos`
  String get select_more_photos {
    return Intl.message(
      'Select more photos',
      name: 'select_more_photos',
      desc: '',
      args: [],
    );
  }

  /// `Please input name`
  String get pandora_create_input_name_hint {
    return Intl.message(
      'Please input name',
      name: 'pandora_create_input_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please select style`
  String get pandora_create_style_hint {
    return Intl.message(
      'Please select style',
      name: 'pandora_create_style_hint',
      desc: '',
      args: [],
    );
  }

  /// `You've chosen this photo already`
  String get photo_select_already {
    return Intl.message(
      'You\'ve chosen this photo already',
      name: 'photo_select_already',
      desc: '',
      args: [],
    );
  }

  /// `This photo has been deleted already`
  String get photo_delete_already {
    return Intl.message(
      'This photo has been deleted already',
      name: 'photo_delete_already',
      desc: '',
      args: [],
    );
  }

  /// `Play Ground`
  String get play_ground {
    return Intl.message(
      'Play Ground',
      name: 'play_ground',
      desc: '',
      args: [],
    );
  }

  /// `Login / Sign up`
  String get login_or_sign_up {
    return Intl.message(
      'Login / Sign up',
      name: 'login_or_sign_up',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get recent {
    return Intl.message(
      'Recent',
      name: 'recent',
      desc: '',
      args: [],
    );
  }

  /// `Faces`
  String get faces {
    return Intl.message(
      'Faces',
      name: 'faces',
      desc: '',
      args: [],
    );
  }

  /// `Others`
  String get others {
    return Intl.message(
      'Others',
      name: 'others',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Password change successfully.`
  String get change_pwd_successfully {
    return Intl.message(
      'Password change successfully.',
      name: 'change_pwd_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Profile update successfully!`
  String get update_profile_successfully {
    return Intl.message(
      'Profile update successfully!',
      name: 'update_profile_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Select from album`
  String get select_from_album {
    return Intl.message(
      'Select from album',
      name: 'select_from_album',
      desc: '',
      args: [],
    );
  }

  /// `Take a selfie`
  String get take_a_selfie {
    return Intl.message(
      'Take a selfie',
      name: 'take_a_selfie',
      desc: '',
      args: [],
    );
  }

  /// `Resend successfully!`
  String get resend_successfully {
    return Intl.message(
      'Resend successfully!',
      name: 'resend_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Resend failure.`
  String get resend_failed {
    return Intl.message(
      'Resend failure.',
      name: 'resend_failed',
      desc: '',
      args: [],
    );
  }

  /// `Activate successfully!`
  String get activate_successfully {
    return Intl.message(
      'Activate successfully!',
      name: 'activate_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Activate failure.`
  String get activate_failed {
    return Intl.message(
      'Activate failure.',
      name: 'activate_failed',
      desc: '',
      args: [],
    );
  }

  /// `Click logout`
  String get click_logout {
    return Intl.message(
      'Click logout',
      name: 'click_logout',
      desc: '',
      args: [],
    );
  }

  /// `We sent reset password link to registered email`
  String get sent_email_already {
    return Intl.message(
      'We sent reset password link to registered email',
      name: 'sent_email_already',
      desc: '',
      args: [],
    );
  }

  /// `Okay`
  String get okay {
    return Intl.message(
      'Okay',
      name: 'okay',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully shared this post.`
  String get your_post_has_been_submitted_successfully {
    return Intl.message(
      'You have successfully shared this post.',
      name: 'your_post_has_been_submitted_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Check it out`
  String get see_it_now {
    return Intl.message(
      'Check it out',
      name: 'see_it_now',
      desc: '',
      args: [],
    );
  }

  /// `This template is not available now`
  String get template_not_available {
    return Intl.message(
      'This template is not available now',
      name: 'template_not_available',
      desc: '',
      args: [],
    );
  }

  /// `Comment posted`
  String get comment_posted {
    return Intl.message(
      'Comment posted',
      name: 'comment_posted',
      desc: '',
      args: [],
    );
  }

  /// `Newest`
  String get newest {
    return Intl.message(
      'Newest',
      name: 'newest',
      desc: '',
      args: [],
    );
  }

  /// `Popular`
  String get popular {
    return Intl.message(
      'Popular',
      name: 'popular',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure want to logout?`
  String get logout_tips {
    return Intl.message(
      'Are you sure want to logout?',
      name: 'logout_tips',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to delete your account?`
  String get delete_account_tips {
    return Intl.message(
      'Are you sure to delete your account?',
      name: 'delete_account_tips',
      desc: '',
      args: [],
    );
  }

  /// `Your account has been successfully deleted. We always welcome you to use our service again.`
  String get delete_account_successfully_tips {
    return Intl.message(
      'Your account has been successfully deleted. We always welcome you to use our service again.',
      name: 'delete_account_successfully_tips',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to clear all cache?\n total: %d`
  String get clear_cache_tips {
    return Intl.message(
      'Are you sure to clear all cache?\n total: %d',
      name: 'clear_cache_tips',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `Scary content alert!`
  String get scary_content_alert {
    return Intl.message(
      'Scary content alert!',
      name: 'scary_content_alert',
      desc: '',
      args: [],
    );
  }

  /// `Show it`
  String get show_it {
    return Intl.message(
      'Show it',
      name: 'show_it',
      desc: '',
      args: [],
    );
  }

  /// `Scary content alert! Tap to show it`
  String get scary_content_alert_open_it {
    return Intl.message(
      'Scary content alert! Tap to show it',
      name: 'scary_content_alert_open_it',
      desc: '',
      args: [],
    );
  }

  /// `?`
  String get q1 {
    return Intl.message(
      '?',
      name: 'q1',
      desc: '',
      args: [],
    );
  }

  /// `This user has not posted anything`
  String get this_user_has_not_posted_anything {
    return Intl.message(
      'This user has not posted anything',
      name: 'this_user_has_not_posted_anything',
      desc: '',
      args: [],
    );
  }

  /// `You have not posted anything`
  String get you_have_not_posted_anything {
    return Intl.message(
      'You have not posted anything',
      name: 'you_have_not_posted_anything',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `Yearly`
  String get yearly {
    return Intl.message(
      'Yearly',
      name: 'yearly',
      desc: '',
      args: [],
    );
  }

  /// `Create Avatar`
  String get create_avatar {
    return Intl.message(
      'Create Avatar',
      name: 'create_avatar',
      desc: '',
      args: [],
    );
  }

  /// `Waiting`
  String get waiting {
    return Intl.message(
      'Waiting',
      name: 'waiting',
      desc: '',
      args: [],
    );
  }

  /// `Created`
  String get created {
    return Intl.message(
      'Created',
      name: 'created',
      desc: '',
      args: [],
    );
  }

  /// `Creating`
  String get generating {
    return Intl.message(
      'Creating',
      name: 'generating',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: '',
      args: [],
    );
  }

  /// `Bought`
  String get bought {
    return Intl.message(
      'Bought',
      name: 'bought',
      desc: '',
      args: [],
    );
  }

  /// `There are no messages yet`
  String get no_messages_yet {
    return Intl.message(
      'There are no messages yet',
      name: 'no_messages_yet',
      desc: '',
      args: [],
    );
  }

  /// `Failed to upload image`
  String get failed_to_upload_image {
    return Intl.message(
      'Failed to upload image',
      name: 'failed_to_upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Year`
  String get year {
    return Intl.message(
      'Year',
      name: 'year',
      desc: '',
      args: [],
    );
  }

  /// `Month`
  String get month {
    return Intl.message(
      'Month',
      name: 'month',
      desc: '',
      args: [],
    );
  }

  /// `Get Inspired`
  String get get_inspired {
    return Intl.message(
      'Get Inspired',
      name: 'get_inspired',
      desc: '',
      args: [],
    );
  }

  /// `FaceToon`
  String get face_toon {
    return Intl.message(
      'FaceToon',
      name: 'face_toon',
      desc: '',
      args: [],
    );
  }

  /// `Effects`
  String get effects {
    return Intl.message(
      'Effects',
      name: 'effects',
      desc: '',
      args: [],
    );
  }

  /// `January`
  String get january {
    return Intl.message(
      'January',
      name: 'january',
      desc: '',
      args: [],
    );
  }

  /// `February`
  String get february {
    return Intl.message(
      'February',
      name: 'february',
      desc: '',
      args: [],
    );
  }

  /// `March`
  String get march {
    return Intl.message(
      'March',
      name: 'march',
      desc: '',
      args: [],
    );
  }

  /// `April`
  String get april {
    return Intl.message(
      'April',
      name: 'april',
      desc: '',
      args: [],
    );
  }

  /// `May`
  String get may {
    return Intl.message(
      'May',
      name: 'may',
      desc: '',
      args: [],
    );
  }

  /// `June`
  String get june {
    return Intl.message(
      'June',
      name: 'june',
      desc: '',
      args: [],
    );
  }

  /// `July`
  String get july {
    return Intl.message(
      'July',
      name: 'july',
      desc: '',
      args: [],
    );
  }

  /// `August`
  String get august {
    return Intl.message(
      'August',
      name: 'august',
      desc: '',
      args: [],
    );
  }

  /// `September`
  String get september {
    return Intl.message(
      'September',
      name: 'september',
      desc: '',
      args: [],
    );
  }

  /// `October`
  String get october {
    return Intl.message(
      'October',
      name: 'october',
      desc: '',
      args: [],
    );
  }

  /// `November`
  String get november {
    return Intl.message(
      'November',
      name: 'november',
      desc: '',
      args: [],
    );
  }

  /// `December`
  String get december {
    return Intl.message(
      'December',
      name: 'december',
      desc: '',
      args: [],
    );
  }

  /// `Your Pandora Avatars will be generated in about %d minutes. Please explore our other features while waiting!`
  String get pandora_waiting_desc {
    return Intl.message(
      'Your Pandora Avatars will be generated in about %d minutes. Please explore our other features while waiting!',
      name: 'pandora_waiting_desc',
      desc: '',
      args: [],
    );
  }

  /// `You will lose all photos you selected!`
  String get pandora_create_exit_dips {
    return Intl.message(
      'You will lose all photos you selected!',
      name: 'pandora_create_exit_dips',
      desc: '',
      args: [],
    );
  }

  /// `man`
  String get man {
    return Intl.message(
      'man',
      name: 'man',
      desc: '',
      args: [],
    );
  }

  /// `woman`
  String get woman {
    return Intl.message(
      'woman',
      name: 'woman',
      desc: '',
      args: [],
    );
  }

  /// `cat`
  String get cat {
    return Intl.message(
      'cat',
      name: 'cat',
      desc: '',
      args: [],
    );
  }

  /// `dog`
  String get dog {
    return Intl.message(
      'dog',
      name: 'dog',
      desc: '',
      args: [],
    );
  }

  /// `Give Feedback`
  String get give_feedback {
    return Intl.message(
      'Give Feedback',
      name: 'give_feedback',
      desc: '',
      args: [],
    );
  }

  /// `input feedback`
  String get input_feedback {
    return Intl.message(
      'input feedback',
      name: 'input_feedback',
      desc: '',
      args: [],
    );
  }

  /// `No, thanks`
  String get no_thanks {
    return Intl.message(
      'No, thanks',
      name: 'no_thanks',
      desc: '',
      args: [],
    );
  }

  /// `Rate Pandora AI`
  String get rate_pandora_ai {
    return Intl.message(
      'Rate Pandora AI',
      name: 'rate_pandora_ai',
      desc: '',
      args: [],
    );
  }

  /// `If you enjoy using Pandora AI, would you mind taking a moment to rate it?`
  String get rate_description {
    return Intl.message(
      'If you enjoy using Pandora AI, would you mind taking a moment to rate it?',
      name: 'rate_description',
      desc: '',
      args: [],
    );
  }

  /// `Looove it! rate now`
  String get looveit {
    return Intl.message(
      'Looove it! rate now',
      name: 'looveit',
      desc: '',
      args: [],
    );
  }

  /// `More`
  String get more {
    return Intl.message(
      'More',
      name: 'more',
      desc: '',
      args: [],
    );
  }

  /// `Generate again`
  String get generate_again {
    return Intl.message(
      'Generate again',
      name: 'generate_again',
      desc: '',
      args: [],
    );
  }

  /// `Me-taverse`
  String get meTaverse {
    return Intl.message(
      'Me-taverse',
      name: 'meTaverse',
      desc: '',
      args: [],
    );
  }

  /// `Generate Record`
  String get generate_record {
    return Intl.message(
      'Generate Record',
      name: 'generate_record',
      desc: '',
      args: [],
    );
  }

  /// `Pandora Avatar`
  String get pandora_avatar {
    return Intl.message(
      'Pandora Avatar',
      name: 'pandora_avatar',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Select Completed`
  String get select_completed {
    return Intl.message(
      'Select Completed',
      name: 'select_completed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid Password`
  String get invalid_password {
    return Intl.message(
      'Invalid Password',
      name: 'invalid_password',
      desc: '',
      args: [],
    );
  }

  /// `Uploading...`
  String get trans_uploading {
    return Intl.message(
      'Uploading...',
      name: 'trans_uploading',
      desc: '',
      args: [],
    );
  }

  /// `Ai Painting...`
  String get trans_painting {
    return Intl.message(
      'Ai Painting...',
      name: 'trans_painting',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get trans_success {
    return Intl.message(
      'Completed',
      name: 'trans_success',
      desc: '',
      args: [],
    );
  }

  /// `Saving...`
  String get trans_saving {
    return Intl.message(
      'Saving...',
      name: 'trans_saving',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Image File`
  String get wrong_image {
    return Intl.message(
      'Wrong Image File',
      name: 'wrong_image',
      desc: '',
      args: [],
    );
  }

  /// `Save into the album`
  String get save_into_album {
    return Intl.message(
      'Save into the album',
      name: 'save_into_album',
      desc: '',
      args: [],
    );
  }

  /// `Save HD, watermark-free image`
  String get save_hd_image {
    return Intl.message(
      'Save HD, watermark-free image',
      name: 'save_hd_image',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to save %d images`
  String get save_album_tips {
    return Intl.message(
      'Are you sure to save %d images',
      name: 'save_album_tips',
      desc: '',
      args: [],
    );
  }

  /// `App Version`
  String get current_version {
    return Intl.message(
      'App Version',
      name: 'current_version',
      desc: '',
      args: [],
    );
  }

  /// `Please select photos`
  String get please_select_photos {
    return Intl.message(
      'Please select photos',
      name: 'please_select_photos',
      desc: '',
      args: [],
    );
  }

  /// `To add more photos please`
  String get album_to_settings_tips {
    return Intl.message(
      'To add more photos please',
      name: 'album_to_settings_tips',
      desc: '',
      args: [],
    );
  }

  /// `Go to settings`
  String get album_to_settings_button {
    return Intl.message(
      'Go to settings',
      name: 'album_to_settings_button',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message(
      'Preview',
      name: 'preview',
      desc: '',
      args: [],
    );
  }

  /// `Please select at least %d photos`
  String get select_min_photos_hint {
    return Intl.message(
      'Please select at least %d photos',
      name: 'select_min_photos_hint',
      desc: '',
      args: [],
    );
  }

  /// `Save Video`
  String get metaverse_save_video {
    return Intl.message(
      'Save Video',
      name: 'metaverse_save_video',
      desc: '',
      args: [],
    );
  }

  /// `Save Image`
  String get metaverse_save_image {
    return Intl.message(
      'Save Image',
      name: 'metaverse_save_image',
      desc: '',
      args: [],
    );
  }

  /// `Share Video`
  String get metaverse_share_video {
    return Intl.message(
      'Share Video',
      name: 'metaverse_share_video',
      desc: '',
      args: [],
    );
  }

  /// `Share Image`
  String get metaverse_share_image {
    return Intl.message(
      'Share Image',
      name: 'metaverse_share_image',
      desc: '',
      args: [],
    );
  }

  /// `Remind`
  String get remind {
    return Intl.message(
      'Remind',
      name: 'remind',
      desc: '',
      args: [],
    );
  }

  /// `You have selected %s style. Please upload photos that match the style to ensure more accurate results. Are you sure the style is %s?`
  String get avatar_create_ensure_hint {
    return Intl.message(
      'You have selected %s style. Please upload photos that match the style to ensure more accurate results. Are you sure the style is %s?',
      name: 'avatar_create_ensure_hint',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Choose another`
  String get choose_another {
    return Intl.message(
      'Choose another',
      name: 'choose_another',
      desc: '',
      args: [],
    );
  }

  /// `You've reached your %s limit today`
  String get generate_reached_limit_title {
    return Intl.message(
      'You\'ve reached your %s limit today',
      name: 'generate_reached_limit_title',
      desc: '',
      args: [],
    );
  }

  /// `You've reached your $s daily limit! Upgrade your account now for extended access or return tomorrow. Feel free to explore our other exciting features in the meantime.`
  String get generate_reached_limit {
    return Intl.message(
      'You\'ve reached your \$s daily limit! Upgrade your account now for extended access or return tomorrow. Feel free to explore our other exciting features in the meantime.',
      name: 'generate_reached_limit',
      desc: '',
      args: [],
    );
  }

  /// `You've reached your %s daily limit! Sign up now for extended access.`
  String get generate_reached_limit_guest {
    return Intl.message(
      'You\'ve reached your %s daily limit! Sign up now for extended access.',
      name: 'generate_reached_limit_guest',
      desc: '',
      args: [],
    );
  }

  /// `Come back tomorrow or try other functions.`
  String get generate_reached_limit_vip {
    return Intl.message(
      'Come back tomorrow or try other functions.',
      name: 'generate_reached_limit_vip',
      desc: '',
      args: [],
    );
  }

  /// `Enter, share invitation code or upgrade to get additional usage credits!`
  String get reached_limit_content {
    return Intl.message(
      'Enter, share invitation code or upgrade to get additional usage credits!',
      name: 'reached_limit_content',
      desc: '',
      args: [],
    );
  }

  /// `Enter or share invitation code to get additional usage credits!`
  String get reached_limit_content_vip {
    return Intl.message(
      'Enter or share invitation code to get additional usage credits!',
      name: 'reached_limit_content_vip',
      desc: '',
      args: [],
    );
  }

  /// `Sign up and enter invitation code to get additional usage credits!`
  String get reached_limit_content_guest {
    return Intl.message(
      'Sign up and enter invitation code to get additional usage credits!',
      name: 'reached_limit_content_guest',
      desc: '',
      args: [],
    );
  }

  /// `Read All`
  String get read_all {
    return Intl.message(
      'Read All',
      name: 'read_all',
      desc: '',
      args: [],
    );
  }

  /// `Input invitation Code`
  String get input_invited_code {
    return Intl.message(
      'Input invitation Code',
      name: 'input_invited_code',
      desc: '',
      args: [],
    );
  }

  /// `Invitation Code`
  String get invited_code {
    return Intl.message(
      'Invitation Code',
      name: 'invited_code',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the invitation code`
  String get please_input_invited_code {
    return Intl.message(
      'Please enter the invitation code',
      name: 'please_input_invited_code',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations!`
  String get congratulations {
    return Intl.message(
      'Congratulations!',
      name: 'congratulations',
      desc: '',
      args: [],
    );
  }

  /// `Use them now to generate high-resolution cartoonized images without watermarks`
  String get invitation_desc {
    return Intl.message(
      'Use them now to generate high-resolution cartoonized images without watermarks',
      name: 'invitation_desc',
      desc: '',
      args: [],
    );
  }

  /// `Try it now`
  String get try_it_now {
    return Intl.message(
      'Try it now',
      name: 'try_it_now',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get buy {
    return Intl.message(
      'Buy',
      name: 'buy',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade`
  String get upgrade {
    return Intl.message(
      'Upgrade',
      name: 'upgrade',
      desc: '',
      args: [],
    );
  }

  /// `Choose your style (optional)`
  String get choose_your_style {
    return Intl.message(
      'Choose your style (optional)',
      name: 'choose_your_style',
      desc: '',
      args: [],
    );
  }

  /// `Reference image (optional)`
  String get reference_image {
    return Intl.message(
      'Reference image (optional)',
      name: 'reference_image',
      desc: '',
      args: [],
    );
  }

  /// `The image you select will be used as a reference for the final`
  String get reference_image_tips {
    return Intl.message(
      'The image you select will be used as a reference for the final',
      name: 'reference_image_tips',
      desc: '',
      args: [],
    );
  }

  /// `Upload Image`
  String get upload_image {
    return Intl.message(
      'Upload Image',
      name: 'upload_image',
      desc: '',
      args: [],
    );
  }

  /// `Describe the image you want to see`
  String get text_2_image_input_hint {
    return Intl.message(
      'Describe the image you want to see',
      name: 'text_2_image_input_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enter a prompt to inspire the generation process. Below are some suggestions to help you get started.`
  String get text_2_image_input_tips {
    return Intl.message(
      'Enter a prompt to inspire the generation process. Below are some suggestions to help you get started.',
      name: 'text_2_image_input_tips',
      desc: '',
      args: [],
    );
  }

  /// `Enter prompt`
  String get text_2_image_prompt_title {
    return Intl.message(
      'Enter prompt',
      name: 'text_2_image_prompt_title',
      desc: '',
      args: [],
    );
  }

  /// `Generate`
  String get generate {
    return Intl.message(
      'Generate',
      name: 'generate',
      desc: '',
      args: [],
    );
  }

  /// `Please input prompt to generate image`
  String get text2img_prompt_empty_hint {
    return Intl.message(
      'Please input prompt to generate image',
      name: 'text2img_prompt_empty_hint',
      desc: '',
      args: [],
    );
  }

  /// `Display Text`
  String get display_text {
    return Intl.message(
      'Display Text',
      name: 'display_text',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get choose_your_scale {
    return Intl.message(
      'Size',
      name: 'choose_your_scale',
      desc: '',
      args: [],
    );
  }

  /// `%d Conversions of Me-Taverse per day`
  String get buy_attr_metaverse {
    return Intl.message(
      '%d Conversions of Me-Taverse per day',
      name: 'buy_attr_metaverse',
      desc: '',
      args: [],
    );
  }

  /// `%d Conversions of AI Artist per day`
  String get buy_attr_ai_artist {
    return Intl.message(
      '%d Conversions of AI Artist per day',
      name: 'buy_attr_ai_artist',
      desc: '',
      args: [],
    );
  }

  /// `Please input feedback`
  String get feedback_empty {
    return Intl.message(
      'Please input feedback',
      name: 'feedback_empty',
      desc: '',
      args: [],
    );
  }

  /// `You've been submitted, please try again tomorrow`
  String get feedback_out_date {
    return Intl.message(
      'You\'ve been submitted, please try again tomorrow',
      name: 'feedback_out_date',
      desc: '',
      args: [],
    );
  }

  /// `Thanks for your opinions`
  String get feedback_thanks {
    return Intl.message(
      'Thanks for your opinions',
      name: 'feedback_thanks',
      desc: '',
      args: [],
    );
  }

  /// `Selected: `
  String get selected {
    return Intl.message(
      'Selected: ',
      name: 'selected',
      desc: '',
      args: [],
    );
  }

  /// `View all %d comments >`
  String get view_all_comment {
    return Intl.message(
      'View all %d comments >',
      name: 'view_all_comment',
      desc: '',
      args: [],
    );
  }

  /// `%d likes`
  String get all_likes {
    return Intl.message(
      '%d likes',
      name: 'all_likes',
      desc: '',
      args: [],
    );
  }

  /// `Expand`
  String get expand {
    return Intl.message(
      'Expand',
      name: 'expand',
      desc: '',
      args: [],
    );
  }

  /// `Collapse`
  String get collapse {
    return Intl.message(
      'Collapse',
      name: 'collapse',
      desc: '',
      args: [],
    );
  }

  /// `Upgrade Now`
  String get upgrade_now {
    return Intl.message(
      'Upgrade Now',
      name: 'upgrade_now',
      desc: '',
      args: [],
    );
  }

  /// `Explore More`
  String get explore_more {
    return Intl.message(
      'Explore More',
      name: 'explore_more',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up Now`
  String get sign_up_now {
    return Intl.message(
      'Sign Up Now',
      name: 'sign_up_now',
      desc: '',
      args: [],
    );
  }

  /// `Like`
  String get like {
    return Intl.message(
      'Like',
      name: 'like',
      desc: '',
      args: [],
    );
  }

  /// `Comments`
  String get comments {
    return Intl.message(
      'Comments',
      name: 'comments',
      desc: '',
      args: [],
    );
  }

  /// `System`
  String get system {
    return Intl.message(
      'System',
      name: 'system',
      desc: '',
      args: [],
    );
  }

  /// `System Message`
  String get system_msg {
    return Intl.message(
      'System Message',
      name: 'system_msg',
      desc: '',
      args: [],
    );
  }

  /// `No data exist`
  String get not_found {
    return Intl.message(
      'No data exist',
      name: 'not_found',
      desc: '',
      args: [],
    );
  }

  /// `Times a day`
  String get per_day {
    return Intl.message(
      'Times a day',
      name: 'per_day',
      desc: '',
      args: [],
    );
  }

  /// `Code`
  String get ref_code {
    return Intl.message(
      'Code',
      name: 'ref_code',
      desc: '',
      args: [],
    );
  }

  /// `Get invitation code failed, click to retry`
  String get get_ref_code_failed {
    return Intl.message(
      'Get invitation code failed, click to retry',
      name: 'get_ref_code_failed',
      desc: '',
      args: [],
    );
  }

  /// `Your invitation code was copied!`
  String get ref_code_copied {
    return Intl.message(
      'Your invitation code was copied!',
      name: 'ref_code_copied',
      desc: '',
      args: [],
    );
  }

  /// `Explain`
  String get explain {
    return Intl.message(
      'Explain',
      name: 'explain',
      desc: '',
      args: [],
    );
  }

  /// `Share your Invitation Code with your friend and you get %1d Metaverse and %2d AI Artist: Text to Image if the Code is used.`
  String get ref_code_share_desc {
    return Intl.message(
      'Share your Invitation Code with your friend and you get %1d Metaverse and %2d AI Artist: Text to Image if the Code is used.',
      name: 'ref_code_share_desc',
      desc: '',
      args: [],
    );
  }

  /// `Input an Invitation Code and you get %1d Metaverse and %2d AI Artist: Text to Image`
  String get ref_code_get_desc {
    return Intl.message(
      'Input an Invitation Code and you get %1d Metaverse and %2d AI Artist: Text to Image',
      name: 'ref_code_get_desc',
      desc: '',
      args: [],
    );
  }

  /// `Invite your friends, get rewarded.\n\nBoth you and your friends can receive additional Me-taverse and AI Artist quota if your invitation code is used. `
  String get ref_code_desc {
    return Intl.message(
      'Invite your friends, get rewarded.\n\nBoth you and your friends can receive additional Me-taverse and AI Artist quota if your invitation code is used. ',
      name: 'ref_code_desc',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enter_code {
    return Intl.message(
      'Enter Code',
      name: 'enter_code',
      desc: '',
      args: [],
    );
  }

  /// `My Code`
  String get my_code {
    return Intl.message(
      'My Code',
      name: 'my_code',
      desc: '',
      args: [],
    );
  }

  /// `Remaining credits`
  String get remaining_credits {
    return Intl.message(
      'Remaining credits',
      name: 'remaining_credits',
      desc: '',
      args: [],
    );
  }

  /// `Enter now`
  String get submit_now {
    return Intl.message(
      'Enter now',
      name: 'submit_now',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to unsubscribe?`
  String get restore_msg {
    return Intl.message(
      'Are you sure to unsubscribe?',
      name: 'restore_msg',
      desc: '',
      args: [],
    );
  }

  /// `You will lose all of your rights until subscribe again`
  String get restore_content {
    return Intl.message(
      'You will lose all of your rights until subscribe again',
      name: 'restore_content',
      desc: '',
      args: [],
    );
  }

  /// `Unsubscribe`
  String get cancel_subscribe {
    return Intl.message(
      'Unsubscribe',
      name: 'cancel_subscribe',
      desc: '',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancel_subscribe_succeed {
    return Intl.message(
      'Cancelled',
      name: 'cancel_subscribe_succeed',
      desc: '',
      args: [],
    );
  }

  /// `Clear Successfully`
  String get clean_successfully {
    return Intl.message(
      'Clear Successfully',
      name: 'clean_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Copy Successfully`
  String get copy_successfully {
    return Intl.message(
      'Copy Successfully',
      name: 'copy_successfully',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Describe your drawing in a few words`
  String get ai_draw_hint {
    return Intl.message(
      'Describe your drawing in a few words',
      name: 'ai_draw_hint',
      desc: '',
      args: [],
    );
  }

  /// `Please update your app`
  String get oldversion_tips {
    return Intl.message(
      'Please update your app',
      name: 'oldversion_tips',
      desc: '',
      args: [],
    );
  }

  /// `Clear current drawing`
  String get ai_draw_reset_tips {
    return Intl.message(
      'Clear current drawing',
      name: 'ai_draw_reset_tips',
      desc: '',
      args: [],
    );
  }

  /// `By clearing the current drawing, you will lose all of your progress.`
  String get ai_draw_reset_tips_desc {
    return Intl.message(
      'By clearing the current drawing, you will lose all of your progress.',
      name: 'ai_draw_reset_tips_desc',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get ai_draw_clear_btn {
    return Intl.message(
      'Clear',
      name: 'ai_draw_clear_btn',
      desc: '',
      args: [],
    );
  }

  /// `Server Busy`
  String get server_exception {
    return Intl.message(
      'Server Busy',
      name: 'server_exception',
      desc: '',
      args: [],
    );
  }

  /// `The server seems busy right now. Please try again in a few minutes.`
  String get server_exception_desc {
    return Intl.message(
      'The server seems busy right now. Please try again in a few minutes.',
      name: 'server_exception_desc',
      desc: '',
      args: [],
    );
  }

  /// `Network Anomaly`
  String get net_exception {
    return Intl.message(
      'Network Anomaly',
      name: 'net_exception',
      desc: '',
      args: [],
    );
  }

  /// `Please ensure your internet connection is available`
  String get net_exception_desc {
    return Intl.message(
      'Please ensure your internet connection is available',
      name: 'net_exception_desc',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get retry {
    return Intl.message(
      'Retry',
      name: 'retry',
      desc: '',
      args: [],
    );
  }

  /// `Create New Avatars`
  String get create_new_avatars {
    return Intl.message(
      'Create New Avatars',
      name: 'create_new_avatars',
      desc: '',
      args: [],
    );
  }

  /// `View more %d comments`
  String get view_more_comment {
    return Intl.message(
      'View more %d comments',
      name: 'view_more_comment',
      desc: '',
      args: [],
    );
  }

  /// `Log in to the platform account`
  String get loginToThePlatformAccount {
    return Intl.message(
      'Log in to the platform account',
      name: 'loginToThePlatformAccount',
      desc: '',
      args: [],
    );
  }

  /// `Connecting`
  String get platform_connecting {
    return Intl.message(
      'Connecting',
      name: 'platform_connecting',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get disconnect {
    return Intl.message(
      'Disconnect',
      name: 'disconnect',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure to disconnect this account?`
  String get disconnect_social_tips {
    return Intl.message(
      'Are you sure to disconnect this account?',
      name: 'disconnect_social_tips',
      desc: '',
      args: [],
    );
  }

  /// `You have unbound the account`
  String get disconnect_social_completed {
    return Intl.message(
      'You have unbound the account',
      name: 'disconnect_social_completed',
      desc: '',
      args: [],
    );
  }

  /// `Before`
  String get before {
    return Intl.message(
      'Before',
      name: 'before',
      desc: '',
      args: [],
    );
  }

  /// `After`
  String get after {
    return Intl.message(
      'After',
      name: 'after',
      desc: '',
      args: [],
    );
  }

  /// `Select Region`
  String get SELECT_COUNTRY_CALLING_CODE {
    return Intl.message(
      'Select Region',
      name: 'SELECT_COUNTRY_CALLING_CODE',
      desc: '',
      args: [],
    );
  }

  /// `Please select region`
  String get SELECT_COUNTRY_CALLING_CODE_HINT {
    return Intl.message(
      'Please select region',
      name: 'SELECT_COUNTRY_CALLING_CODE_HINT',
      desc: '',
      args: [],
    );
  }

  /// `RegionName, RegionCode or CallingCode`
  String get SELECT_COUNTRY_KEYWORD {
    return Intl.message(
      'RegionName, RegionCode or CallingCode',
      name: 'SELECT_COUNTRY_KEYWORD',
      desc: '',
      args: [],
    );
  }

  /// `Select Region`
  String get SELECT_REGION {
    return Intl.message(
      'Select Region',
      name: 'SELECT_REGION',
      desc: '',
      args: [],
    );
  }

  /// `Select State`
  String get SELECT_STATE {
    return Intl.message(
      'Select State',
      name: 'SELECT_STATE',
      desc: '',
      args: [],
    );
  }

  /// `State`
  String get STATE {
    return Intl.message(
      'State',
      name: 'STATE',
      desc: '',
      args: [],
    );
  }

  /// `StateName or StateCode`
  String get SELECT_STATE_KEYWORD {
    return Intl.message(
      'StateName or StateCode',
      name: 'SELECT_STATE_KEYWORD',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get Subtotal {
    return Intl.message(
      'Subtotal',
      name: 'Subtotal',
      desc: '',
      args: [],
    );
  }

  /// `Shipping details`
  String get shipping_details {
    return Intl.message(
      'Shipping details',
      name: 'shipping_details',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: '',
      args: [],
    );
  }

  /// `Apartment/Suite/Other`
  String get apartment_suite_other {
    return Intl.message(
      'Apartment/Suite/Other',
      name: 'apartment_suite_other',
      desc: '',
      args: [],
    );
  }

  /// `Input address`
  String get search_address {
    return Intl.message(
      'Input address',
      name: 'search_address',
      desc: '',
      args: [],
    );
  }

  /// `City`
  String get city {
    return Intl.message(
      'City',
      name: 'city',
      desc: '',
      args: [],
    );
  }

  /// `Country/Region`
  String get country_region {
    return Intl.message(
      'Country/Region',
      name: 'country_region',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get first_name {
    return Intl.message(
      'First Name',
      name: 'first_name',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get last_name {
    return Intl.message(
      'Last Name',
      name: 'last_name',
      desc: '',
      args: [],
    );
  }

  /// `Contact Number`
  String get contact_number {
    return Intl.message(
      'Contact Number',
      name: 'contact_number',
      desc: '',
      args: [],
    );
  }

  /// `Shipping & Delivery`
  String get shipping_delivery {
    return Intl.message(
      'Shipping & Delivery',
      name: 'shipping_delivery',
      desc: '',
      args: [],
    );
  }

  /// `7-10 business days`
  String get business_days_7_10 {
    return Intl.message(
      '7-10 business days',
      name: 'business_days_7_10',
      desc: '',
      args: [],
    );
  }

  /// `10-20 business days`
  String get business_days_10_20 {
    return Intl.message(
      '10-20 business days',
      name: 'business_days_10_20',
      desc: '',
      args: [],
    );
  }

  /// `Standard`
  String get standard {
    return Intl.message(
      'Standard',
      name: 'standard',
      desc: '',
      args: [],
    );
  }

  /// `Expedited`
  String get expedited {
    return Intl.message(
      'Expedited',
      name: 'expedited',
      desc: '',
      args: [],
    );
  }

  /// `Back home`
  String get back_home {
    return Intl.message(
      'Back home',
      name: 'back_home',
      desc: '',
      args: [],
    );
  }

  /// `View orders`
  String get view_orders {
    return Intl.message(
      'View orders',
      name: 'view_orders',
      desc: '',
      args: [],
    );
  }

  /// `Order ID:`
  String get order_ID {
    return Intl.message(
      'Order ID:',
      name: 'order_ID',
      desc: '',
      args: [],
    );
  }

  /// `Shipping information`
  String get shipping_information {
    return Intl.message(
      'Shipping information',
      name: 'shipping_information',
      desc: '',
      args: [],
    );
  }

  /// `Payment failed`
  String get payment_failed {
    return Intl.message(
      'Payment failed',
      name: 'payment_failed',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get try_again {
    return Intl.message(
      'Try again',
      name: 'try_again',
      desc: '',
      args: [],
    );
  }

  /// `Order details`
  String get order_details {
    return Intl.message(
      'Order details',
      name: 'order_details',
      desc: '',
      args: [],
    );
  }

  /// `Variations`
  String get variations {
    return Intl.message(
      'Variations',
      name: 'variations',
      desc: '',
      args: [],
    );
  }

  /// `Order time`
  String get order_time {
    return Intl.message(
      'Order time',
      name: 'order_time',
      desc: '',
      args: [],
    );
  }

  /// `Number`
  String get number {
    return Intl.message(
      'Number',
      name: 'number',
      desc: '',
      args: [],
    );
  }

  /// `Order Screening`
  String get order_screening {
    return Intl.message(
      'Order Screening',
      name: 'order_screening',
      desc: '',
      args: [],
    );
  }

  /// `1 month`
  String get month_1 {
    return Intl.message(
      '1 month',
      name: 'month_1',
      desc: '',
      args: [],
    );
  }

  /// `3 month`
  String get month_3 {
    return Intl.message(
      '3 month',
      name: 'month_3',
      desc: '',
      args: [],
    );
  }

  /// `6 month`
  String get month_6 {
    return Intl.message(
      '6 month',
      name: 'month_6',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Orders`
  String get orders {
    return Intl.message(
      'Orders',
      name: 'orders',
      desc: '',
      args: [],
    );
  }

  /// `Search order`
  String get search_order {
    return Intl.message(
      'Search order',
      name: 'search_order',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get start_date {
    return Intl.message(
      'Start Date',
      name: 'start_date',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get end_date {
    return Intl.message(
      'End Date',
      name: 'end_date',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: '',
      args: [],
    );
  }

  /// `Paid`
  String get paid {
    return Intl.message(
      'Paid',
      name: 'paid',
      desc: '',
      args: [],
    );
  }

  /// `Unpaid`
  String get unpaid {
    return Intl.message(
      'Unpaid',
      name: 'unpaid',
      desc: '',
      args: [],
    );
  }

  /// `Refunded`
  String get refunded {
    return Intl.message(
      'Refunded',
      name: 'refunded',
      desc: '',
      args: [],
    );
  }

  /// `voided`
  String get voided {
    return Intl.message(
      'voided',
      name: 'voided',
      desc: '',
      args: [],
    );
  }

  /// `Partial delivered`
  String get partial_delivered {
    return Intl.message(
      'Partial delivered',
      name: 'partial_delivered',
      desc: '',
      args: [],
    );
  }

  /// `Fulfilled`
  String get fulfilled {
    return Intl.message(
      'Fulfilled',
      name: 'fulfilled',
      desc: '',
      args: [],
    );
  }

  /// `Restocked`
  String get restocked {
    return Intl.message(
      'Restocked',
      name: 'restocked',
      desc: '',
      args: [],
    );
  }

  /// `Please input %s`
  String get pleaseInput {
    return Intl.message(
      'Please input %s',
      name: 'pleaseInput',
      desc: '',
      args: [],
    );
  }

  /// `Start Now`
  String get start_now {
    return Intl.message(
      'Start Now',
      name: 'start_now',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get monday {
    return Intl.message(
      'Monday',
      name: 'monday',
      desc: '',
      args: [],
    );
  }

  /// `Tuesday`
  String get tuesday {
    return Intl.message(
      'Tuesday',
      name: 'tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Wednesday`
  String get wednesday {
    return Intl.message(
      'Wednesday',
      name: 'wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Thursday`
  String get thursday {
    return Intl.message(
      'Thursday',
      name: 'thursday',
      desc: '',
      args: [],
    );
  }

  /// `Friday`
  String get friday {
    return Intl.message(
      'Friday',
      name: 'friday',
      desc: '',
      args: [],
    );
  }

  /// `Saturday`
  String get saturday {
    return Intl.message(
      'Saturday',
      name: 'saturday',
      desc: '',
      args: [],
    );
  }

  /// `Sunday`
  String get sunday {
    return Intl.message(
      'Sunday',
      name: 'sunday',
      desc: '',
      args: [],
    );
  }

  /// `Size`
  String get size {
    return Intl.message(
      'Size',
      name: 'size',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: '',
      args: [],
    );
  }

  /// `Model`
  String get model {
    return Intl.message(
      'Model',
      name: 'model',
      desc: '',
      args: [],
    );
  }

  /// `Please select a Size`
  String get pleaseSelectSize {
    return Intl.message(
      'Please select a Size',
      name: 'pleaseSelectSize',
      desc: '',
      args: [],
    );
  }

  /// `Please select a Color`
  String get pleaseSelectColor {
    return Intl.message(
      'Please select a Color',
      name: 'pleaseSelectColor',
      desc: '',
      args: [],
    );
  }

  /// `Please select a Model`
  String get pleaseSelectModel {
    return Intl.message(
      'Please select a Model',
      name: 'pleaseSelectModel',
      desc: '',
      args: [],
    );
  }

  /// `Please select the $s`
  String get pleaseSelect {
    return Intl.message(
      'Please select the \$s',
      name: 'pleaseSelect',
      desc: '',
      args: [],
    );
  }

  /// `Use Style`
  String get use_style {
    return Intl.message(
      'Use Style',
      name: 'use_style',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
