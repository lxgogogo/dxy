import '../../simple_toolbar.dart';
import '../../structs/link_dialog_action.dart';
import '../../theme/quill_dialog_theme.dart';

class QuillToolbarLinkStyleButtonExtraOptions extends QuillToolbarBaseButtonExtraOptions
    implements QuillToolbarBaseButtonExtraOptionsIsToggled {
  const QuillToolbarLinkStyleButtonExtraOptions({
    required super.controller,
    required super.context,
    required super.onPressed,
    required this.isToggled,
  });

  @override
  final bool isToggled;
}

class QuillToolbarLinkStyleButtonOptions
    extends QuillToolbarBaseButtonOptions<QuillToolbarLinkStyleButtonOptions, QuillToolbarLinkStyleButtonExtraOptions> {
  const QuillToolbarLinkStyleButtonOptions({
    this.dialogTheme,
    this.linkRegExp,
    this.linkDialogAction,
    super.iconSize,
    super.iconButtonFactor,
    super.iconData,
    super.afterButtonPressed,
    super.tooltip,
    super.iconTheme,
    super.childBuilder,
  });

  final QuillDialogTheme? dialogTheme;
  final RegExp? linkRegExp;
  final LinkDialogAction? linkDialogAction;
}
