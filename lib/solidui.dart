/// A UI library for building Solid applications with Flutter.
///
/// Copyright (C) 2025, Software Innovation Institute, ANU.
///
/// Licensed under the MIT License (the "License").
///
/// License: https://choosealicense.com/licenses/mit/.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
///
/// Authors: Tony Chen

library;

export 'src/constants/about.dart';
export 'src/constants/navigation.dart';
export 'src/constants/solid_config.dart';
export 'src/constants/ui.dart';

export 'src/handlers/solid_auth_handler.dart';

export 'src/widgets/solid_nav_bar.dart';
export 'src/widgets/solid_nav_drawer.dart';
export 'src/widgets/solid_nav_models.dart';

export 'src/widgets/solid_scaffold.dart';
export 'src/widgets/solid_scaffold_controller.dart';
export 'src/widgets/solid_scaffold_helpers.dart' show SolidScaffoldHelpers;
export 'src/widgets/solid_scaffold_models.dart';

export 'src/widgets/solid_status_bar.dart';
export 'src/widgets/solid_status_bar_models.dart';
export 'src/widgets/solid_dynamic_login_status.dart';
export 'src/widgets/solid_dynamic_auth_button.dart';
export 'src/widgets/solid_default_login.dart';

export 'src/widgets/solid_login.dart';
export 'src/widgets/solid_login_helper.dart';
export 'src/widgets/solid_popup_login.dart';
export 'src/widgets/solid_login_webid_input_dialog.dart';
export 'src/widgets/solid_logout_dialog.dart';
export 'src/widgets/solid_loading_screen.dart';
export 'src/widgets/solid_animation_dialog.dart';

export 'src/widgets/solid_theme_models.dart';
export 'src/widgets/solid_theme_notifier.dart';
export 'src/widgets/solid_theme_app.dart';
export 'src/widgets/solid_theme.dart';

export 'src/widgets/solid_preferences_models.dart';
export 'src/widgets/solid_preferences_notifier.dart';
export 'src/widgets/solid_preferences_dialog.dart';

export 'src/widgets/solid_about_models.dart';
export 'src/widgets/solid_about_button.dart';

export 'src/widgets/solid_invite_others_models.dart';
export 'src/widgets/solid_invite_others.dart';

export 'src/widgets/solid_security_key_utils.dart';
export 'src/widgets/solid_security_key_manager.dart';
export 'src/widgets/solid_security_key_view.dart';
export 'src/widgets/solid_security_key_central_manager.dart';
export 'src/services/solid_security_key_service.dart';
export 'src/services/solid_security_key_notifier.dart';

export 'src/services/solid_profile_notifier.dart';
export 'src/services/solid_profile_service.dart';
export 'src/widgets/solid_profile_avatar.dart';
export 'src/widgets/solid_profile_crop_dialog.dart';
export 'src/widgets/solid_profile_editor.dart';

export 'src/widgets/secret_text_field.dart';
export 'src/widgets/security_key_ui.dart';
export 'src/widgets/change_key_dialog.dart';

export 'src/utils/snack_bar.dart';

export 'src/widgets/solid_file.dart';
export 'src/widgets/solid_file_browser.dart';
export 'src/widgets/solid_file_uploader.dart';
export 'src/widgets/solid_file_upload_area.dart';
export 'src/widgets/solid_file_upload_config.dart';
export 'src/widgets/solid_file_upload_buttons.dart';
export 'src/widgets/solid_file_preview_card.dart';

export 'src/models/file_item.dart';
export 'src/models/file_sort_option.dart';
export 'src/models/file_state.dart';
export 'src/models/data_format_config.dart';
export 'src/models/file_type_config.dart';
export 'src/models/snackbar_config.dart';

export 'src/utils/file_operations.dart';
export 'src/utils/is_text_file.dart';
export 'src/utils/solid_file_operations.dart';
export 'src/utils/solid_file_operations_print.dart';
export 'src/utils/is_phone.dart';
export 'src/utils/solid_alert.dart';
export 'src/utils/solid_notifications.dart';
export 'src/utils/solid_pod_helpers.dart'
    show loginIfRequired, getKeyFromUserIfRequired;
export 'src/utils/web_id_parser.dart';

export 'src/widgets/solid_format_info_card.dart';

export 'src/widgets/build_message_container.dart';

export 'src/widgets/app_bar.dart';
export 'src/widgets/file_explorer.dart';
export 'src/widgets/group_webid_input.dart';
export 'src/widgets/ind_webid_input.dart';
export 'src/widgets/ind_webid_input_screen.dart';
export 'src/widgets/permission_checkbox.dart';
export 'src/widgets/shared_resources_table.dart';

export 'src/widgets/grant_permission_ui.dart';
export 'src/widgets/shared_resources_ui.dart';
export 'src/widgets/permission_table.dart';
export 'src/widgets/grant_permission_form.dart';
export 'src/widgets/select_recipients.dart';
export 'src/widgets/show_selected_recipients.dart';
export 'src/widgets/revoke_permission_button.dart';
export 'src/widgets/share_resource_button.dart';

export 'src/widgets/permission_history.dart';
export 'src/widgets/grant_permission_helpers_ui.dart';

export 'src/constants/initial_setup.dart';
export 'src/screens/initial_setup_screen.dart';
export 'src/screens/initial_setup_screen_body.dart';
export 'src/screens/initial_setup_widgets/enc_key_input_form.dart';
export 'src/screens/initial_setup_widgets/initial_setup_welcome.dart';
export 'src/screens/initial_setup_widgets/res_create_form_submission.dart';
