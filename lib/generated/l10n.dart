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

  /// `I created this using #Pandora Avatar`
  String get discoveryShareInputHint {
    return Intl.message(
      'I created this using #Pandora Avatar',
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

  /// `Your photos will be generated in about 2 hours`
  String get pandora_create_spend {
    return Intl.message(
      'Your photos will be generated in about 2 hours',
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

  /// `We only use your photos to train the AI model and render your avatars Both the input photos and the AI model will be deleted from our servers within 24 hours. You will have the option to keep the AI model as a premium service`
  String get pandora_transfer_tips {
    return Intl.message(
      'We only use your photos to train the AI model and render your avatars Both the input photos and the AI model will be deleted from our servers within 24 hours. You will have the option to keep the AI model as a premium service',
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

  /// `This app needs photo library access to choose pictures for upload user profile photo`
  String get permissionPhotoLibraryContent {
    return Intl.message(
      'This app needs photo library access to choose pictures for upload user profile photo',
      name: 'permissionPhotoLibraryContent',
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

  /// `Make a cartoon profile picture`
  String get welcome_title1 {
    return Intl.message(
      'Make a cartoon profile picture',
      name: 'welcome_title1',
      desc: '',
      args: [],
    );
  }

  /// `Add artistic touch to your photo`
  String get welcome_title2 {
    return Intl.message(
      'Add artistic touch to your photo',
      name: 'welcome_title2',
      desc: '',
      args: [],
    );
  }

  /// `Create cartoon stickers for yourself`
  String get welcome_title3 {
    return Intl.message(
      'Create cartoon stickers for yourself',
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

  /// `You've selected %selected photos of %minSize minimum required.`
  String get choose_photo_not_enough_desc {
    return Intl.message(
      'You\'ve selected %selected photos of %minSize minimum required.',
      name: 'choose_photo_not_enough_desc',
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

  /// `Your post has been submitted successfully`
  String get your_post_has_been_submitted_successfully {
    return Intl.message(
      'Your post has been submitted successfully',
      name: 'your_post_has_been_submitted_successfully',
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
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
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
