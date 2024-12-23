import 'package:holdem/utils/log_util.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';

class HtmlParseUtil {
  static final HtmlParseUtil of = HtmlParseUtil._();

  HtmlParseUtil._();

  String pureText(String? htmlText) {
    if (parse(htmlText).body != null) {
      return parseText(parse(htmlText).body!);
    }
    return '';
  }

  String pureCommentText(String? comment) {
    if (comment?.isNotEmpty != true) return '';
    final regExp = RegExp(r"(<span.*?>)(@([\u4e00-\u9fa5\w]+))(.*?</span>)");
    try {
      final formatComment = comment!.replaceAllMapped(regExp, (match) {
        String prefix = match[1] ?? '';
        String user = match[2] ?? '';
        String suffix = match[4] ?? '';
        return '$prefix\$$user \$$suffix';
      });
      if (parse(formatComment).body != null) {
        return parseText(parse(formatComment).body!);
      }
    } catch (e) {
      Log.e(e.toString());
    }
    return '';
  }

  String parseText(Node node) {
    if (node.nodeType == Node.TEXT_NODE) {
      return node.text!;
    } else if (node.nodeType == Node.ELEMENT_NODE) {
      Element element = node as Element;
      StringBuffer buffer = StringBuffer();
      if (!element.localName!.contains('script')) {
        for (var child in element.nodes) {
          buffer.write(parseText(child));
        }
      }
      return buffer.toString();
    }

    return '';
  }

  List<String> imageList(String htmlText) {
    final document = parse(htmlText);
    final List<Element> imageTags = document.getElementsByTagName('img');
    List<String> images = [];
    for (Element imgTag in imageTags) {
      String? src = imgTag.attributes['src'];
      if (src?.isNotEmpty == true) {
        images.add(src!);
      }
    }
    return images;
  }
}
