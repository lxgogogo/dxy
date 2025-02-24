import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:holdem/extensions/string_extensions.dart';

class AtText extends StatelessWidget {
  final String text;
  final int maxLines;

  const AtText({
    super.key,
    required this.text,
    this.maxLines = 3,
  });

  RegExp get regExp => RegExp(r'\$@([\u4e00-\u9fa5\w]+) \$');

  @override
  Widget build(BuildContext context) {
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (Match match in regExp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(text: match.group(0)?.replaceAll('\$', ''), style: TextStyle(color: '#249CFC'.hexColor)));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return Text.rich(
      TextSpan(children: spans),
      style: TextStyle(
        color: const Color(0xff666666),
        fontSize: 12.sp,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }
}
