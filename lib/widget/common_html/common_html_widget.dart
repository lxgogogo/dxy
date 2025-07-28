import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:holdem/extensions/string_extensions.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher_string.dart';

import 'html_factory_builder.dart';

class CommonHtmlWidget extends StatelessWidget {
  final String content;

  const CommonHtmlWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      content,
      factoryBuilder: () => HtmlFactoryBuilder(
        context,
        content: content,
      ),
      customStylesBuilder: _customStylesBuilder,
      customWidgetBuilder: (dom.Element element) {
        if (element.localName == 'table') {
          return const SizedBox();
        }
        return null;
      },
      onTapUrl: (String url) async {
        return launchUrlString(url, mode: LaunchMode.externalApplication);
      },
    );
  }

  StylesMap? _customStylesBuilder(dom.Element element) {
    if (element.localName == 'dl' ||
        element.localName == 'dd' ||
        element.localName == 'hr' ||
        element.localName == 'figure') {
      return {
        'margin': '10px 0',
      };
    }

    if (element.localName == 'p' || element.localName == 'li') {
      return {
        'white-space': 'pre-wrap',
        'margin': '5px 0',
      };
    }

    if (element.localName == 'h1') {
      return {
        'font-size': '2em',
        'font-weight': 'bold',
        'margin': '15px 0',
      };
    }

    if (element.localName == 'h2') {
      return {
        'font-size': '1.5em',
        'font-weight': 'bold',
        'margin': '15px 0',
      };
    }

    if (element.localName == 'h3') {
      return {
        'font-size': '1.17em',
        'font-weight': 'bold',
        'margin': '15px 0',
      };
    }
    if (element.localName == 'h4') {
      return {
        'font-size': '1em',
        'font-weight': 'bold',
        'margin': '15px 0',
      };
    }

    if (element.localName == 'h5') {
      return {
        'font-size': '0.8em',
        'font-weight': 'bold',
        'margin': '15px 0',
      };
    }

    if (element.localName == 'h6') {
      return {
        'font-size': '0.6em',
        'font-weight': 'bold',
        'margin': '15px 0',
      };
    }

    if (element.localName == 'a') {
      return {
        'color': 'blue',
        'text-decoration': 'underline',
        'font-size': '14px',
      };
    }

    if (element.localName == 'blockquote') {
      return {
        'border-left': '8px solid #d0e5f2',
        'padding': '10px 10px',
        'margin': '10px 0',
        'background-color': '#f1f1f1',
      };
    }

    if (element.localName == 'code') {
      return {
        'font-family': 'monospace',
        'background-color': '#eee',
        'padding': '3px',
        'border-radius': '3px',
      };
    }
    if (element.localName == 'pre>code') {
      return {
        'display': 'block',
        'padding': '10px',
      };
    }

    if (element.localName == 'table') {
      return {
        'border-collapse': 'collapse',
// 'border-collapse': 'separate',
        'border-spacing': '0',
// 'table-layout':'fixed',
      };
    }

    if (element.localName == 'td') {
      return {
        'border': '1px solid #ccc',
        'min-width': '150px',
        'height': '20px',
      };
    }
    if (element.localName == 'th') {
      return {
        'border': '1px solid #ccc',
        'min-width': '150px',
        'height': '20px',
        'background-color': '#f1f1f1',
      };
    }
    if (element.localName == 'ul') {
      return {
        'padding-left': '20px',
        'list-style-type': 'disc',
      };
    }
    if (element.localName == 'ol') {
      return {
        'padding-left': '20px',
        'list-style-type': 'decimal',
      };
    }
// if (element.localName == '<input type="checkbox"  ></imput>') {
//   return {
//     'margin-right': '5px',
//   };
// }
    return null;
  }
}

class HeightLimiter extends StatefulWidget {
  final Widget child;
  final double maxHeight;

  const HeightLimiter({
    Key? key,
    required this.maxHeight,
    required this.child,
  }) : super(key: key);

  @override
  _HeightLimiterState createState() => _HeightLimiterState();
}

class _HeightLimiterState extends State<HeightLimiter> {
  var _size = Size.zero;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: widget.maxHeight,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MeasureSize(
              onChange: (size) => setState(() => _size = size),
              child: widget.child,
            ),
          ),
          if (_size.height >= widget.maxHeight)
            Positioned(
              bottom: 0,
              left: 0,
              width: _size.width,
              child: _buildOverflowIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildOverflowIndicator() {
    return Container(
      height: widget.maxHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            '#D9D9D9'.hexColor,
            '#737373'.hexColor.withAlpha(0),
          ],
          tileMode: TileMode.clamp,
        ),
      ),
    );
  }
}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }

  @override
  void updateRenderObject(BuildContext context, covariant MeasureSizeRenderObject renderObject) {
    renderObject.onChange = onChange;
  }
}
