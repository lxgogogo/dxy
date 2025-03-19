import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TransparentPointer extends SingleChildRenderObjectWidget {
  const TransparentPointer({
    required super.child,
    this.transparent = true,
    super.key,
  });

  final bool transparent;

  @override
  RenderTransparentPointer createRenderObject(BuildContext context) {
    return RenderTransparentPointer(
      transparent: transparent,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTransparentPointer renderObject) {
    renderObject.transparent = transparent;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('transparent', transparent));
  }
}

class RenderTransparentPointer extends RenderProxyBox {
  RenderTransparentPointer({
    RenderBox? child,
    bool transparent = true,
  })  : _transparent = transparent,
        super(child);

  bool get transparent => _transparent;
  bool _transparent;

  set transparent(bool value) {
    if (value == _transparent) return;
    _transparent = value;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final hit = super.hitTest(result, position: position);
    return !transparent && hit;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>('transparent', transparent));
  }
}
