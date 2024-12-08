import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:html/dom.dart';

StylesMap? htmlCustomStyles(Element element) {
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
      'min-width': '50px',
      'height': '20px',
    };
  }
  if (element.localName == 'th') {
    return {
      'border': '1px solid #ccc',
      'min-width': '50px',
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
