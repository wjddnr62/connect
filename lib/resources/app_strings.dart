import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:sprintf/sprintf.dart';

class AppStrings {
  final Locale locale;

  AppStrings(this.locale);

  static Map<String, Map<String, String>> _localizedStrings = {};

  String localizeString(key) {
    return _localizedStrings[locale.languageCode][key];
  }

  static String of(StringKey key) {
    switch (key) {
      case StringKey.neofect:
        return 'NEOFECT';
      case StringKey.connect_lower_case:
        return 'connect';
      case StringKey.copyright:
        return 'COPYRIGHTⓒ2020. NEOFECT. ALL RIGHTS RESERVED.';
      case StringKey.connect_home_id_title:
        return 'Connect Rapael\nHome ID';
      case StringKey.connect_home_id_description:
        return 'Please enter your Rapael home ID to access personalized rehabiliation content and support.';
      case StringKey.connect:
        return 'Connect';
      case StringKey.submit:
        return 'Submit';
      case StringKey.hint_email_input:
        return 'abc@abc.com';
      case StringKey.label_email_input:
        return 'Type your email';
      case StringKey.submitting:
        return 'Submitting...';
      case StringKey.check_email_verification:
        return 'We sent you a verification link to your email';
      case StringKey.retype_email:
        return 'Retype your Email';
      case StringKey.description_check_email_part1:
        return 'A verification link has been sent to ';
      case StringKey.description_check_email_part2:
        return '. Please check your email. This link will expire in 24 hours.';
      case StringKey.verifying_email:
        return 'Verifying email...';
      case StringKey.hello:
        return 'Hello,';
      case StringKey.welcome_to_neofect:
        return 'Welcome to Neofect';
      case StringKey.welcome_description:
        return 'You have successfully connected your Rapael Home ID. We will provide you with personalized missions and support designed to help you move forward on your rehab journey.';
      case StringKey.dashboard:
        return 'Dashboard';
      case StringKey.training_summary:
        return 'Training Summary';
      case StringKey.time:
        return 'Time';
      case StringKey.star:
        return 'Star';
      case StringKey.mission:
        return 'Mission';
      case StringKey.start:
        return 'Start';
      case StringKey.mission_activity:
        return 'ACTIVITY';
      case StringKey.mission_game:
        return 'GAME';
      case StringKey.mission_reading:
        return 'READING';
      case StringKey.mission_answer:
        return 'ANSWER';
      case StringKey.mission_video:
        return 'VIDEO';
      case StringKey.basic_information:
        return 'Basic Information';
      case StringKey.question_nickname:
        return 'Please enter your name';
      case StringKey.hint_nickname:
        return 'Nickname';
      case StringKey.next:
        return 'Next';
      case StringKey.previous:
        return 'Previous';
      case StringKey.name_required:
        return 'Name is required';
      case StringKey.question_birthday:
        return 'When is your birthday?';
      case StringKey.hint_date:
        return 'mm dd, yyyy';
      case StringKey.question_onset_day:
        return 'When did your stroke occur?';
      case StringKey.question_gender:
        return 'What is your gender?';
      case StringKey.male:
        return 'Male';
      case StringKey.female:
        return 'Female';
      case StringKey.other:
        return 'Other';
      case StringKey.left:
        return 'Left';
      case StringKey.right:
        return 'Right';
      case StringKey.unknown_error:
        return 'Unknown error : Please try again later.';
      case StringKey.invalid_email:
        return 'Enter a valid email';
      case StringKey.not_registered_email:
        return 'Not registered';
      case StringKey.generating_mission:
        return 'We are generating your rehab mission';
      case StringKey.disconnect:
        return 'Disconnect';
      case StringKey.confirm_disconnect:
        return 'Do you want to disconnect?';
      case StringKey.cancel:
        return 'Cancel';
      case StringKey.confirm:
        return 'Confirm';
      case StringKey.coach_name:
        return 'Siena Conde';
      case StringKey.stroke_coach:
        return 'Stroke Coach';
      case StringKey.description_mission_complete:
        return 'Most of the activities you need in your daily life, such as meals, personal hygiene and dressing, can be performed independently. We will recommend rehabilitation training with difficulty using your hands. Find activities that can actively participate in your community as well as your daily life.';
      case StringKey.word_continue:
        return 'Continue';
      case StringKey.completed:
        return 'Complete';
      case StringKey.i_watched_it:
        return 'Watch';
      case StringKey.i_will_play:
        return 'Will complete';
      case StringKey.undo:
        return 'Undo';
      case StringKey.notification:
        return 'Notification';
      case StringKey.empty:
        return 'Empty';
      case StringKey.loading:
        return 'Loading...';
      case StringKey.error:
        return 'Error :(';
      case StringKey.question_infected_side:
        return 'Which side of your body is affected by the stroke?';
      case StringKey.getting_profile:
        return 'We are getting your Rapael Home Information.';
      case StringKey.getting_questions:
        return 'Loading questions';
      case StringKey.sending_profile:
        return 'Updating your profile';
      case StringKey.rapael_home_id:
        return 'Rapael Home ID : ';
      case StringKey.desc_internet_connection_error:
        return 'Internet connection lost.\nPlease check your network status.';
      case StringKey.desc_unknown_error:
        return 'Please close this app and reopen it later.';
      case StringKey.retry_later:
        return 'Retry later';
      case StringKey.title_notification_permission:
        return 'Notification Permission';
      case StringKey.description_notification_permission:
        return 'Rehabit app will send you push messages via this app. With this push message, you will get alarm for daily new missions and schedule events and more. Please accept this permission.';
      case StringKey.privacy_policy:
        return 'Privacy Policy';
      case StringKey.try_again:
        return 'Try again';
      case StringKey.stroke_evaluation:
        return 'Stroke Evaluation';
      case StringKey.stroke_evaluation_description:
        return "Before we start please answer the following questions as best you can. Your answers will help us provide you with a program designed to evaluate how far you've already come and provide you recommendations to maximize your recovery.";
      case StringKey.stroke_evaluation_renewal:
        return "It's been 100 days since you trained with Rehabit. Please recheck the Stroke evaluation regularly.";
      case StringKey.stroke_evaluation_complete:
        return "Stroke evaluation is complete";
      case StringKey.turn_on:
        return 'Turn On';
      case StringKey.terms:
        return 'Terms of service';
      case StringKey.starting:
        return 'Starting';
      case StringKey.type_password:
        return 'Type your password';
      case StringKey.confirm_password:
        return 'Confirm password';
      case StringKey.password:
        return 'password';
      case StringKey.forgot_password:
        return 'Forgot Password';
      case StringKey.agree:
        return 'Agree';
      case StringKey.i_am_a_patient:
        return 'I\'m a patient';
      case StringKey.i_am_a_caregiver:
        return 'I\'m a caregiver';
      case StringKey.password_not_matched:
        return 'Password doesn\'t match';
      case StringKey.name:
        return 'Name';
      case StringKey.reset_password:
        return 'Reset Password';
      case StringKey.reset_password_desc:
        return 'To reset your password, please type your email and click reset password link in your email.';
      case StringKey.request_password_reset:
        return 'Send Reset Link';
      case StringKey.sending:
        return 'Sending';
      case StringKey.back_to_login:
        return 'Back to Login';
      case StringKey.desc_reset_password_part1:
        return 'A reset password link has been sent to ';
      case StringKey.desc_reset_password_part2:
        return '. Please check your email.';
      case StringKey.desc_video_call_join:
        return 'Please set the angle of camera and environment so that stroke coach can see your affected side.';
      case StringKey.joining:
        return 'Joining...';
      case StringKey.permission_title:
        return "App Permissions";
      case StringKey.permission_message:
        return "Please allow microphone and camera access to use Video Call.";
      case StringKey.permission_camera_title:
        return "Camera";
      case StringKey.permission_camera_message:
        return "Allow this app to use camera";
      case StringKey.permission_audio_title:
        return "Audio";
      case StringKey.permission_audio_message:
        return "Allow this app to use microphone";
      case StringKey.introduction:
        return "Introduction";
      case StringKey.available_time:
        return "Available Time";
      case StringKey.sending_failed:
        return "Sending Failed";
      case StringKey.ask_video_call_quit:
        return "Do you want to end the Video Call? You may not be able to rejoin.";
      case StringKey.request_video_call:
        return 'Request Video Call';
      case StringKey.video_archive:
        return 'Video Archive';
      case StringKey.account:
        return 'Account';
      case StringKey.settings:
        return 'Settings';
      case StringKey.assigning_ot:
        return 'Assigning stroke coach';
      case StringKey.unassigned_ot_yet:
        return 'You can request Video Call after being assigned with a stroke coach. We will let you known once stroke coach has been assigned.';
      case StringKey.move_to_home:
        return 'Move to Home';
      case StringKey.voucher:
        return 'Voucher';
      case StringKey.ot:
        return 'Stroke Coach';
      case StringKey.plan:
        return 'Plan';
      case StringKey.video_call_requested:
        return 'Video Call has been requested.';
      case StringKey.empty_schedule:
        return 'There is no schedule for today';
      case StringKey.more:
        return 'More';
      case StringKey.upcoming_events:
        return 'Upcoming Events';
      case StringKey.video_call_cancelable_before_confirm:
        return 'You can cancel this request before it\'s reviewed by the stroke coach';
      case StringKey.video_call_cancelable_after_confirm:
        return 'Event can be cancelled up to 48 hours before the event.';
      case StringKey.cancel_event:
        return 'Cancel Event';
      case StringKey.cancel_request:
        return 'Cancel Request';
      case StringKey.video_call_therapist_dropped:
        return 'Connection lost due to the unstable internet environment. Please wait until reconnection.';
      case StringKey.video_call_therapist_disconnected:
        return 'Video Call with %s ended. Directing you to the Home screen.';
      case StringKey.video_call_failed:
        return 'Internet connection is unstable. Please try again.';
      case StringKey.email:
        return 'Email';
      case StringKey.phone_number:
        return 'Phone number';
      case StringKey.data_of_birth:
        return 'Date of birth';
      case StringKey.gender:
        return 'Gender';
      case StringKey.name_of_disease:
        return 'Diagnosis';
      case StringKey.date_of_occurrence:
        return 'Date of occurrence';
      case StringKey.affected_side:
        return 'Affected side';
      case StringKey.stroke:
        return 'Stroke';
      case StringKey.profile:
        return 'Profile';
      case StringKey.my_ot:
        return 'My Stroke Coach';
      case StringKey.logout:
        return 'Logout';
      case StringKey.ask_logout:
        return 'Would you like to logout?';
      case StringKey.invalid_password_format:
        return 'Password should be 10-20 characters with letters and numbers';
      case StringKey.incorrect_password:
        return 'incorrect password';
      case StringKey.create_password:
        return 'Choose a password';
      case StringKey.notifications:
        return 'Notifications';
      case StringKey.error_question_input:
        return 'You need to select one of the answers';
      case StringKey.current_status:
        return 'My Report';
      case StringKey.neofect_home:
        return 'Neofect Home';
      case StringKey.advice:
        return 'Advice';
      case StringKey.n_days_ago:
        return '%d days ago';
      case StringKey.personal_best:
        return 'Personal best';
      case StringKey.hr:
        return 'hr';
      case StringKey.min:
        return 'min';
      case StringKey.where_do_you_live:
        return 'Where do you live?';
      case StringKey.diagnostic_name:
        return 'Diagnostic name';
      case StringKey.what_is_diagnostic_name:
        return 'What is the diagnostic name?';
      case StringKey.few_seconds_ago:
        return 'a few seconds ago';
      case StringKey.minutes_ago:
        return 'minutes ago';
      case StringKey.minute_ago:
        return 'minute ago';
      case StringKey.please_update:
        return 'Please update to continue using Rehabit service.';
      case StringKey.update:
        return 'Update';
      case StringKey.video_call:
        return 'Video Call';
      case StringKey.question_dominant_side:
        return 'What was your dominant hand prior to stroke?';
      case StringKey.video:
        return 'VIDEO';
      case StringKey.exercise_basics:
        return 'EXERCISE BASICS';
      case StringKey.clinic:
        return 'Clinic';
      case StringKey.card_reading:
        return 'READING';
      case StringKey.edit:
        return 'Edit';
      case StringKey.choose_clinic_desc:
        return ' Choose your clinic from the list below. If your clinic is not in the list, choose \'N/A\'.';
      case StringKey.save:
        return 'Save';
      case StringKey.verifying:
        return 'Verifying';
      case StringKey.connecting:
        return 'Connecting';
      case StringKey.no_mission:
        return 'No Mission';
      case StringKey.no_notifications:
        return 'No Notifications yet';
      case StringKey.join:
        return 'Join';
      case StringKey.stroke_coach_live:
        return 'Stroke Coach Live';
      case StringKey.subject:
        return 'Subject';
      case StringKey.all:
        return 'All';
      case StringKey.home_training:
        return 'Home Training';
      case StringKey.bookmark:
        return 'Bookmark';
      case StringKey.most_popular:
        return 'Most Popular';
      case StringKey.newest:
        return 'Newest';
      case StringKey.oldest:
        return 'Oldest';
      case StringKey.wait_your_coach:
        return 'Wait for your Rehabit specialist to be assigned.';
      case StringKey.have_you_been_through_a_lot:
        return 'Have you been through a lot?';
      case StringKey.the_stroke_journey_is_hard:
        return 'The stroke journey is hard!';
      case StringKey.today_you_can_start_something_new:
        return 'Today, you can start something new';
      case StringKey.take_a_deep_breath:
        return 'Take a deep breath';
      case StringKey.you_re_not_alone:
        return "You're not alone";
      case StringKey.together:
        return 'Together';
      case StringKey.together_we_not_alone:
        return 'Together, We got this!';
      case StringKey.subscribe:
        return 'Subscribe';
      case StringKey.subscribed_basic_product:
        return "You are subscribed to the \'%s\' product";
      case StringKey.neofect_connect:
        return "Rehabit";
      case StringKey.subscription_completed:
        return 'Your subscription is complete.';
      case StringKey.subscription_not_completed:
        return 'Your subscription is not complete.';
      case StringKey.payment_not_available:
        return 'Payment is not available.';
      case StringKey.make_neofect_rehabilitation_partner_today:
        return 'Make Neofect your rehabilitation partner today.';
      case StringKey.are_you_sure_you_want_to_exit:
        return 'Are you sure you want to exit?';
      case StringKey.congratulations:
        return 'Congratulations!';
      case StringKey.congratulation_description:
        return "You’ve done perfectly today!\nLet’s keep it on tomorrow.";
      case StringKey.continue_text:
        return "Continue";
      case StringKey.coupon_registered:
        return 'The coupon has been registered.';
      case StringKey.terms_of_use:
        return 'Terms of Use';
      case StringKey.contributors:
        return 'Contributors';
      case StringKey.invalid_password_length_violation:
        return 'The password should be 10-20 characters.';
      case StringKey.consecutive_password_violation:
        return 'The password should be non-continuous characters or numbers.';
      case StringKey.least_two_types_password_violation:
        return 'The password should contain at least two types of : Capital letters, Lower case letters, Numbers, and Special characters.';
      case StringKey.we_make_connect_with_rehab_experts:
        return 'We make Connect with\nrehab experts.';
      case StringKey.we_offer_everyday_missions_only_for_you:
        return 'We offer everyday\nmissions only for you';
      case StringKey.you_can_find_yourself_improved_in_few_months_with_connect:
        return 'You can find yourself\nimproved in few\nmonths with Connect';
      case StringKey.now_lets_get_started:
        return 'Now, let`s get started!';
      case StringKey.make_a_neofect_account:
        return 'Make a Neofect account';
      case StringKey.continue_with_facebook:
        return 'Continue with Facebook';
      case StringKey.continue_with_apple:
        return 'Continue with Apple';
      case StringKey.sign_in_with_facebook:
        return 'Continue with Facebook';
      case StringKey.sign_in_with_apple:
        return 'Continue with Apple';
      case StringKey.have_a_neofect_account:
        return 'Have a Neofect account?';
      case StringKey.sign_up:
        return 'Sign up';
      case StringKey.type_your_email:
        return 'Type your email';
      case StringKey.type_your_password:
        return 'Type your password';
      case StringKey.please_enter_your_name:
        return 'Please enter your name';
      case StringKey.date_of_birth:
        return 'dd / mm / yyyy';
      case StringKey.incorrect_email:
        return 'Incorrect email';
      case StringKey.this_email_is_already_signed_up:
        return 'This email is already signed up';
      case StringKey.Password:
        return 'Password';
      case StringKey.password_length_check_text:
        return '10-20 characters';
      case StringKey.non_continuous_characters_or_numbers:
        return 'Non-continuous characters or numbers';
      case StringKey.contain_at_least_two_types_of:
        return 'Contain at least two types of: Capital letters, Lower case letters, numbers and special characters';
      case StringKey.wrong_email_of_password:
        return 'Wrong email of password';
      case StringKey.login:
        return 'Log in';
      case StringKey.or:
        return 'OR';
      case StringKey.dont_have_an_account:
        return "Don’t have an account?";
      case StringKey.welcome_neofecter:
        return "Welcome, Neofecter!";
      case StringKey.three_month_free_trial:
        return '3-month free trial';
      case StringKey.general_contents_for_rehab:
        return 'General contents for rehab';
      case StringKey.daily_missions:
        return "Daily missions";
      case StringKey.for_vip_user:
        return 'For VIP member';
      case StringKey.customized_contents:
        return 'Customized contents';
      case StringKey.advice_from_experts:
        return 'Advice from experts';
      case StringKey.comprehensive_evaluation:
        return 'Comprehensive evaluation';
      case StringKey.check_improvement_trend_at_a_glance:
        return 'Check improvement trend at a glance';
      case StringKey.you_can_use_all_functions:
        return 'You can use all functions of Rehabit for free for 3 months (VIP benefits will be terminated automatically after 3 months)';
      case StringKey.start_three_month_free_trial:
        return 'Start 3-month free trial';
      case StringKey.you_can_use_all_functions_of_connect:
        return 'You can use all functions of Rehabit only with \$19.99.';
      case StringKey.i_want_to_be_a_vip:
        return 'I want to be a VIP';
      case StringKey.start_as_free_user:
        return 'Start as free user';
      case StringKey.welcome_to_connect:
        return 'Welcome to Rehabit';
      case StringKey.welcome_warriors:
        return 'Welcome, Warriors!';
      case StringKey.rehab_coach_assigned_only_for_you:
        return 'Rehab coach assigned only for you';
      case StringKey.unique_and_high_quality_rehab_contents:
        return 'Unique & high-quality rehab contents';
      case StringKey.customized_daily_missions:
        return 'Customized daily missions';
      case StringKey.checking_improvement_through_regular_evaluation:
        return 'Checking improvement through regular evaluation';
      case StringKey.profile_character:
        return 'Profile character';
      case StringKey.sympathy:
        return 'Empathy';
      case StringKey.love:
        return 'Love';
      case StringKey.happiness:
        return 'Happiness';
      case StringKey.hope:
        return "Hope";
      case StringKey.autonomy:
        return 'Autonomy';
      case StringKey.my_photo:
        return 'My photo';
      case StringKey.status_message:
        return 'Status message';
      case StringKey.please_set_the_status_message:
        return 'Please set the status message.';
      case StringKey.what_brings_you_to_neofect_connect:
        return 'What brings you to Rehabit?';
      case StringKey.you_can_select_multiple:
        return 'You can select multiple';
      case StringKey.to_get_professional_information_rehabilitation:
        return 'To get professional\ninformation rehabilitation';
      case StringKey.to_do_self_rehabilitation:
        return 'To do self-rehabilitation';
      case StringKey.for_mental_health_care:
        return 'For mental health care';
      case StringKey.for_better_daily_life:
        return 'For better daily life';
      case StringKey.to_get_tips_and_advice_from_experts:
        return 'To get tips and advice from\nexperts';
      case StringKey.today_mission:
        return 'Today’s Mission';
      case StringKey.how_was_your_day_today_write_a_diary:
        return 'How was your day today? Write a diary';
      case StringKey.time_to_sleep:
        return 'Bedtime';
      case StringKey.wake_up_time:
        return 'Wake up';
      case StringKey.choose_the_weather:
        return 'Choose the weather';
      case StringKey.choose_your_feeling:
        return 'Choose your feeling';
      case StringKey.tell_me_what_happened_today:
        return 'Tell me what happened today.';
      case StringKey.optional:
        return 'Optional';
      case StringKey.please_write_a_diary:
        return 'Please write a diary';
      case StringKey.upload_photos:
        return 'Upload photos';
      case StringKey.this_diary_is_private:
        return 'This diary is private.';
      case StringKey.get_evaluation:
        return 'Get Evaluation';
      case StringKey.for_customized_contents:
        return 'for customized contents!';
      case StringKey.share:
        return 'Share';
      case StringKey.you_become_vip_at_connect:
        return 'You have unlocked VIP membership!\nEnjoy the following exclusive benefits.';
      case StringKey.start_evaluation:
        return 'Start Evaluation';
      case StringKey.what_is_your_gender:
        return 'What is your gender?';
      case StringKey.about_you:
        return 'About you';
      case StringKey.please_write_the_things_you_want_to_say_to_your_coach:
        return 'Please write the things you want to say to your coach.';
      case StringKey.place_your_text:
        return 'Place your text';
      case StringKey.quiz:
        return 'Quiz';
      case StringKey.why_dont_we_think_about_it_again:
        return "Why don’t we think about it again?";
      case StringKey.youre_a_genius:
        return 'You’re a genius';
      case StringKey.please_enter_your_answer:
        return 'Please enter your answer.';
      case StringKey.verify_email:
        return 'Verify Email';
      case StringKey.resend:
        return 'Resend';
      case StringKey.verification_message:
        return 'Verification mail has send to the email address you entered. Please check the email, verify your email account and continue signing up.';
      case StringKey.verified:
        return 'Verified';
      case StringKey.includes_a_personal_connect_coach:
        return 'Includes a personal Rehabit Specialist';
      case StringKey.regular_evaluations_and_progress_reports:
        return 'Regular evaluations & progress reports';
      case StringKey.unlimited_premium_content:
        return 'Unlimited premium content (Articles, exercises, and videos)';
      case StringKey.learn_more:
        return 'Learn more';
      case StringKey.free_member:
        return 'Free member';
      case StringKey.vip_member:
        return 'VIP member';
      case StringKey.basic_rehab_content:
        return 'Basic rehab content (Limited)';
      case StringKey.king:
        return 'King';
      case StringKey.platinum:
        return 'Platinum';
      case StringKey.diamond:
        return 'Diamond';
      case StringKey.gold:
        return 'Gold';
      case StringKey.silver:
        return 'Silver';
      case StringKey.bronze:
        return 'Bronze';
      case StringKey.orange:
        return 'Orange';
      case StringKey.stone:
        return 'Stone';
      case StringKey.ranking:
        return 'Ranking';
      case StringKey.total:
        return 'Total';
      case StringKey.tap_here_to_search_for_your_name:
        return 'Tap here to search for your name';
      case StringKey
          .holistic_wellness_program_developed_by_stroke_rehab_experts:
        return 'Holistic wellness program for people recovering from a stroke';
      case StringKey
          .stay_on_track_with_daily_missions_and_over_500_custom_contents:
        return 'Stay on track with daily missions and over 500 custom contents';
      case StringKey
          .neofect_connect_will_give_you_the_tools_to_change_your_life:
        return 'Rehabit will give you the tools to change your life';
      case StringKey.look_forward_to_a_happier_healthier_you:
        return 'Look forward to a happier, healthier you!';
      case StringKey.you_can_get_points_when_you_are_active:
        return 'You can get points when you are active.';
      case StringKey.daily_access:
        return 'Daily access';
      case StringKey.mission_complete:
        return 'Mission complete';
      case StringKey.all_mission_complete:
        return 'All missions complete';
      case StringKey.quiz_mission_complete:
        return 'Quiz mission Complete';
      case StringKey.write_a_diary:
        return 'Write a diary';
      case StringKey.train_by_watching_exercise_video_for_a_long_time:
        return 'Train by watching Exercise Video for a long time';
      case StringKey.ranking_is_reset_every_month:
        return '* Ranking is reset every month.';
      case StringKey.one_personal_neofect_specialist:
        return 'One personal Neofect Specialist';
      case StringKey.social_login_fail:
        return 'Login failed. Please try again later. If the same problem occurs, please sign up in a different way.';
      case StringKey.you_will_get_customized_contents_according_to_your_goal:
        return 'You will get customized contents according to your goal';
      case StringKey.my_report:
        return 'My Report';
      case StringKey.chatting:
        return 'chatting';
      case StringKey.Access_interrupted_due_to_a_temporary_problem:
        return 'Access interrupted due to a temporary problem.';
      case StringKey.feedback:
        return 'Feedback';
      case StringKey.give_us_feedback:
        return 'Give us feedback';
      case StringKey.rate_the_app:
        return 'Rate the app';
      case StringKey.upgrade:
        return 'Upgrade';
      case StringKey.cheer_up_level:
        return 'Cheer up and get to the next level!';
      case StringKey.connect_rank:
        return 'Rehabit Rank';
      case StringKey.summary:
        return 'SUMMARY';
      case StringKey.activity:
        return 'ACTIVITY';
      case StringKey.diary:
        return 'DIARY';
      case StringKey.last_30_days:
        return 'Last 30 days';
      case StringKey.practice_time:
        return 'PRACTICE\nTIME';
      case StringKey.mission_achievement:
        return 'MISSION\nACHIEVEMENT';
      case StringKey.activity_achievement:
        return 'ACTIVITY\nACHIEVEMENT(AVG)';
      case StringKey.your_dedicated_specialist:
        return 'Your dedicated specialist';
      case StringKey.send_message:
        return 'Send Message';
      case StringKey.evaluation_trend:
        return 'Evaluation Trend';
      case StringKey.evaluation_trend_vip_member:
        return 'This data is a preview. Please switch to a VIP member to see the evaluation trend.\nDo you want to switch to a VIP member?';
      case StringKey.be_vip_member:
        return 'Be VIP member';
      case StringKey.function:
        return 'Function';
      case StringKey.general_healthcare:
        return 'General Healthcare';
      case StringKey.life_style:
        return 'Life Style';
      case StringKey.social_activity:
        return 'Social Activity';
      case StringKey.the_last_three_months:
        return 'The last 3 months';
      case StringKey.the_last_four_months:
        return 'The last 4 months';
      case StringKey.delete:
        return 'Delete';
      case StringKey.how_was_your_day_today:
        return 'How was your day today?';
      case StringKey.keep_your_body_moving:
        return 'Keep your body moving!';
      case StringKey.activity_tracker:
        return 'Activity Tracker';
      case StringKey.lets_set_your_goal:
        return "Let's set your goal!";
      case StringKey.lets_set_your_new_goal:
        return "Let's set your new goal!";
      case StringKey.what_is_your_health_goal_to_achieve_through_rehabit:
        return 'What is your health goal to achieve through Rehabit?';
      case StringKey.i_want_to_maintain_my_health_status:
        return 'I want to maintain my health status';
      case StringKey.i_want_to_improve_my_movement_control:
        return 'I want to improve my movement control';
      case StringKey.i_want_to_take_better_care_of_myself_every_day:
        return 'I want to take better care of myself every day';
      case StringKey
          .i_want_to_be_able_to_undertake_more_activities_in_daily_living:
        return 'I want to be able to undertake more activities in daily living';
      case StringKey.i_want_to_be_able_to_do_the_things_i_enjoyed_before:
        return 'I want to be able to do the things I enjoyed before';
      case StringKey.your_activity_goal:
        return "Your Activity Goal will be calculated automatically based on your answer. You can check more details on 'My Report' section.";
      case StringKey.lets_set_a_more_specific_goal:
        return "Let's set a more specific goal!";
      case StringKey.dress_independently:
        return 'Dress independently';
      case StringKey.be_able_to_cut_bread_into_slices:
        return 'Be able to cut bread into slices';
      case StringKey.walk_indoors_independently:
        return 'Walk indoors independently';
      case StringKey.maintain_range_of_movement_in_hand_wrist_and_elbow:
        return 'Maintain range of movement in hand, wrist and elbow';
      case StringKey.open_a_bottle_of_water:
        return 'Open a bottle of water';
      case StringKey.remember_a_daily_to_do_list:
        return 'Remember a daily to-do list';
      case StringKey.get_in_and_out_of_a_car_safely:
        return 'Get in and out of a car safely';
      case StringKey.be_able_to_type_a_message_accurately:
        return 'Be able to type a message accurately';
      case StringKey.practice_golf_on_a_driving_range:
        return 'Practice golf on a driving range';
      case StringKey.try_new_recipes:
        return 'Try new recipes';
      case StringKey.enter_your_own_goal:
        return 'Enter your own goal';
      case StringKey.enter_your_details_here:
        return 'Enter your details here';
      case StringKey.lets_set_your_activity_goal_to_improve_your_health:
        return "Let's set your Activity Goal to improve your health!";
      case StringKey.we_suggest_your_daily:
        return "We suggest your daily activity goals as below.\nLet's move! (You can adjust them if you want)";
      case StringKey.steps:
        return 'Steps';
      case StringKey.upper_body:
        return 'Upper Body';
      case StringKey.lower_body:
        return 'Lower Body';
      case StringKey.whole_body:
        return 'Whole Body';
      case StringKey.total_daily_steps:
        return 'Total daily steps';
      case StringKey.total_amount_of_upper_body_exercise:
        return 'Total amount of upper body exercise';
      case StringKey.total_amount_of_lower_body_exercise:
        return 'Total amount of lower body exercise';
      case StringKey.total_amount_of_whole_body_exercise:
        return 'Total amount of whole body exercise';
      case StringKey.total_amount_of_social_activities:
        return 'Total amount of social activities (i.e. Meeting friends, Having conversation online, Exercise in group)';
      case StringKey.done:
        return 'Done';
      case StringKey.record_activity:
        return 'Record Activity';
      case StringKey.keep_your_body_moving_track_your_movement:
        return 'Keep your body moving!\nTrack your movement';
      case StringKey.goal_setting:
        return 'Goal Setting';
      case StringKey.goal:
        return 'Goal';
      case StringKey.ios_health_app_setting:
        return 'You should allow Rehabit to access your health information.\n(Health app > Steps > Data Sources & Access > Allow Rehabit)';
      case StringKey.run_the_app:
        return 'Run the app';
      case StringKey.set_your_activity_goal_and_achieve_it:
        return 'Set your activity goal and achieve it!';
      case StringKey.set_activity_goal:
        return 'Set Activity Goal';
      case StringKey.you_can_get_personalized_advice:
        return "You can get personalized advice from our Neofect Specialist if you upgrade to VIP membership!\nTake your personal health into your own hands. Become a VIP member now!";
      case StringKey.goal_achieved:
        return 'Goal Achieved';
      case StringKey.allow_to_read_data:
        return 'Allow to read data';
      case StringKey.rehabit_is_waiting_for_your_feedback:
        return 'Rehabit is waiting for your feedback!';
      case StringKey.send_feedback:
        return 'Send feedback';
      case StringKey.copy_link:
        return 'Copy link:';
      case StringKey.no_content_yet:
        return 'No content yet';
      case StringKey.email_address_copied:
        return 'Email address copied';
      case StringKey.that_s_right:
        return "That's right!";
      case StringKey.you_did_it:
        return "You did it!";
      case StringKey.well_done:
        return "Well done!";
      case StringKey.yes_good_job:
        return "Yes! Good job!";
      case StringKey.great_good_job:
        return "Great! Good job!";
      case StringKey.congrats_you_did_it:
        return "Congrats! You did it!";
      case StringKey.yes_that_s_right:
        return "Yes! That's right!";
      case StringKey.you_did_a_great_job:
        return 'You did a great job!';
      case StringKey.your_answer_is_correct:
        return 'Your answer is correct!';
      case StringKey.bookmark_list:
        return 'Bookmark List';
      case StringKey.continue_with_google:
        return 'Continue with Google';
      case StringKey.other_login_options:
        return 'Other login options';
    }
    return '';
  }
}

enum StringKey {
  neofect,
  connect_lower_case,
  copyright,
  connect_home_id_title,
  connect_home_id_description,
  connect,
  submit,
  hint_email_input,
  label_email_input,
  submitting,
  check_email_verification,
  retype_email,
  description_check_email_part1,
  description_check_email_part2,
  verifying_email,
  hello,
  welcome_to_neofect,
  welcome_description,
  dashboard,
  training_summary,
  time,
  star,
  mission,
  start,
  mission_activity,
  mission_game,
  mission_reading,
  mission_answer,
  mission_video,
  basic_information,
  question_nickname,
  hint_nickname,
  next,
  previous,
  error_question_input,
  question_birthday,
  hint_date,
  question_onset_day,
  question_gender,
  male,
  female,
  other,
  left,
  right,
  unknown_error,
  invalid_email,
  not_registered_email,
  generating_mission,
  disconnect,
  confirm_disconnect,
  cancel,
  confirm,
  coach_name,
  stroke_coach,
  description_mission_complete,
  word_continue,
  completed,
  i_watched_it,
  i_will_play,
  undo,
  notification,
  notifications,
  empty,
  loading,
  error,
  question_infected_side,
  getting_profile,
  getting_questions,
  sending_profile,
  rapael_home_id,
  desc_internet_connection_error,
  desc_unknown_error,
  retry_later,
  try_again,
  title_notification_permission,
  description_notification_permission,
  privacy_policy,
  stroke_evaluation,
  turn_on,
  terms,
  starting,
  type_password,
  confirm_password,
  password,
  forgot_password,
  agree,
  i_am_a_patient,
  i_am_a_caregiver,
  password_not_matched,
  name,
  reset_password,
  reset_password_desc,
  request_password_reset,
  sending,
  back_to_login,
  desc_reset_password_part1,
  desc_reset_password_part2,
  desc_video_call_join,
  joining,
  permission_title,
  permission_message,
  permission_camera_title,
  permission_camera_message,
  permission_audio_title,
  permission_audio_message,
  introduction,
  available_time,
  sending_failed,
  ask_video_call_quit,
  request_video_call,
  video_archive,
  account,
  settings,
  assigning_ot,
  unassigned_ot_yet,
  move_to_home,
  voucher,
  ot,
  plan,
  video_call_failed,
  video_call_requested,
  empty_schedule,
  more,
  upcoming_events,
  video_call_cancelable_before_confirm,
  video_call_cancelable_after_confirm,
  cancel_event,
  video_call_therapist_dropped,
  video_call_therapist_disconnected,
  email,
  phone_number,
  data_of_birth,
  gender,
  name_of_disease,
  date_of_occurrence,
  affected_side,
  stroke,
  profile,
  my_ot,
  logout,
  ask_logout,
  invalid_password_format,
  incorrect_password,
  create_password,
  cancel_request,
  name_required,
  current_status,
  neofect_home,
  advice,
  n_days_ago,
  personal_best,
  hr,
  min,
  where_do_you_live,
  diagnostic_name,
  what_is_diagnostic_name,
  few_seconds_ago,
  minutes_ago,
  minute_ago,
  please_update,
  update,
  video_call,
  question_dominant_side,
  video,
  exercise_basics,
  clinic,
  card_reading,
  edit,
  choose_clinic_desc,
  save,
  verifying,
  connecting,
  no_mission,
  no_notifications,
  join,
  stroke_coach_live,
  subject,
  all,
  home_training,
  bookmark,
  most_popular,
  newest,
  oldest,
  wait_your_coach,
  have_you_been_through_a_lot,
  the_stroke_journey_is_hard,
  today_you_can_start_something_new,
  take_a_deep_breath,
  you_re_not_alone,
  together,
  together_we_not_alone,
  subscribe,
  subscribed_basic_product,
  neofect_connect,
  subscription_not_completed,
  subscription_completed,
  payment_not_available,
  make_neofect_rehabilitation_partner_today,
  are_you_sure_you_want_to_exit,
  stroke_evaluation_description,
  stroke_evaluation_renewal,
  stroke_evaluation_complete,
  congratulations,
  congratulation_description,
  continue_text,
  coupon_registered,
  terms_of_use,
  contributors,
  invalid_password_length_violation,
  consecutive_password_violation,
  least_two_types_password_violation,
  we_make_connect_with_rehab_experts,
  we_offer_everyday_missions_only_for_you,
  you_can_find_yourself_improved_in_few_months_with_connect,
  now_lets_get_started,
  make_a_neofect_account,
  continue_with_facebook,
  continue_with_apple,
  sign_in_with_facebook,
  sign_in_with_apple,
  have_a_neofect_account,
  sign_up,
  type_your_email,
  type_your_password,
  please_enter_your_name,
  date_of_birth,
  incorrect_email,
  this_email_is_already_signed_up,
  Password,
  password_length_check_text,
  non_continuous_characters_or_numbers,
  contain_at_least_two_types_of,
  wrong_email_of_password,
  login,
  or,
  dont_have_an_account,
  welcome_neofecter,
  three_month_free_trial,
  general_contents_for_rehab,
  daily_missions,
  customized_contents,
  advice_from_experts,
  comprehensive_evaluation,
  check_improvement_trend_at_a_glance,
  you_can_use_all_functions,
  start_three_month_free_trial,
  for_vip_user,
  welcome_to_connect,
  you_can_use_all_functions_of_connect,
  i_want_to_be_a_vip,
  start_as_free_user,
  welcome_warriors,
  rehab_coach_assigned_only_for_you,
  unique_and_high_quality_rehab_contents,
  customized_daily_missions,
  checking_improvement_through_regular_evaluation,
  profile_character,
  sympathy,
  love,
  happiness,
  hope,
  autonomy,
  my_photo,
  status_message,
  please_set_the_status_message,
  what_brings_you_to_neofect_connect,
  you_can_select_multiple,
  to_get_professional_information_rehabilitation,
  to_do_self_rehabilitation,
  for_mental_health_care,
  for_better_daily_life,
  to_get_tips_and_advice_from_experts,
  today_mission,
  how_was_your_day_today_write_a_diary,
  time_to_sleep,
  wake_up_time,
  choose_the_weather,
  choose_your_feeling,
  tell_me_what_happened_today,
  optional,
  please_write_a_diary,
  upload_photos,
  this_diary_is_private,
  get_evaluation,
  for_customized_contents,
  share,
  you_become_vip_at_connect,
  start_evaluation,
  what_is_your_gender,
  about_you,
  please_write_the_things_you_want_to_say_to_your_coach,
  place_your_text,
  quiz,
  why_dont_we_think_about_it_again,
  youre_a_genius,
  please_enter_your_answer,
  verify_email,
  resend,
  verification_message,
  verified,
  includes_a_personal_connect_coach,
  regular_evaluations_and_progress_reports,
  unlimited_premium_content,
  learn_more,
  free_member,
  vip_member,
  basic_rehab_content,
  king,
  platinum,
  diamond,
  gold,
  silver,
  bronze,
  orange,
  stone,
  ranking,
  total,
  tap_here_to_search_for_your_name,
  holistic_wellness_program_developed_by_stroke_rehab_experts,
  stay_on_track_with_daily_missions_and_over_500_custom_contents,
  neofect_connect_will_give_you_the_tools_to_change_your_life,
  look_forward_to_a_happier_healthier_you,
  you_can_get_points_when_you_are_active,
  daily_access,
  mission_complete,
  all_mission_complete,
  quiz_mission_complete,
  write_a_diary,
  train_by_watching_exercise_video_for_a_long_time,
  ranking_is_reset_every_month,
  one_personal_neofect_specialist,
  social_login_fail,
  you_will_get_customized_contents_according_to_your_goal,
  my_report,
  chatting,
  Access_interrupted_due_to_a_temporary_problem,
  feedback,
  give_us_feedback,
  rate_the_app,
  upgrade,
  cheer_up_level,
  connect_rank,
  summary,
  activity,
  diary,
  last_30_days,
  practice_time,
  mission_achievement,
  activity_achievement,
  your_dedicated_specialist,
  send_message,
  evaluation_trend,
  evaluation_trend_vip_member,
  be_vip_member,
  function,
  general_healthcare,
  life_style,
  social_activity,
  the_last_four_months,
  the_last_three_months,
  delete,
  how_was_your_day_today,
  keep_your_body_moving,
  activity_tracker,
  lets_set_your_goal,
  lets_set_your_new_goal,
  what_is_your_health_goal_to_achieve_through_rehabit,
  i_want_to_maintain_my_health_status,
  i_want_to_improve_my_movement_control,
  i_want_to_take_better_care_of_myself_every_day,
  i_want_to_be_able_to_undertake_more_activities_in_daily_living,
  i_want_to_be_able_to_do_the_things_i_enjoyed_before,
  your_activity_goal,
  lets_set_a_more_specific_goal,
  dress_independently,
  be_able_to_cut_bread_into_slices,
  walk_indoors_independently,
  maintain_range_of_movement_in_hand_wrist_and_elbow,
  open_a_bottle_of_water,
  remember_a_daily_to_do_list,
  get_in_and_out_of_a_car_safely,
  be_able_to_type_a_message_accurately,
  practice_golf_on_a_driving_range,
  try_new_recipes,
  enter_your_own_goal,
  enter_your_details_here,
  lets_set_your_activity_goal_to_improve_your_health,
  we_suggest_your_daily,
  steps,
  upper_body,
  lower_body,
  whole_body,
  total_daily_steps,
  total_amount_of_upper_body_exercise,
  total_amount_of_lower_body_exercise,
  total_amount_of_whole_body_exercise,
  total_amount_of_social_activities,
  done,
  record_activity,
  keep_your_body_moving_track_your_movement,
  goal_setting,
  goal,
  ios_health_app_setting,
  run_the_app,
  set_your_activity_goal_and_achieve_it,
  set_activity_goal,
  you_can_get_personalized_advice,
  goal_achieved,
  allow_to_read_data,
  rehabit_is_waiting_for_your_feedback,
  send_feedback,
  copy_link,
  no_content_yet,
  email_address_copied,
  that_s_right,
  you_did_it,
  well_done,
  yes_good_job,
  great_good_job,
  congrats_you_did_it,
  yes_that_s_right,
  you_did_a_great_job,
  your_answer_is_correct,
  bookmark_list,
  continue_with_google,
  other_login_options
}

extension StringKeyEx on StringKey {
  String getString() {
    return AppStrings.of(this);
  }

  String getFormattedString(var args) {
    return sprintf(this.getString(), args);
  }
}
