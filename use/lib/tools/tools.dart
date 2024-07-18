import 'dart:collection';
import 'dart:developer';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';


const double _kScreenEdgeMargin = 10.0;
const double _kTooltipPadding = 5.0;
const double _kInspectButtonMargin = 10.0;
/// Interpret pointer up events within with this margin as indicating the
/// pointer is moving off the device.
const double _kOffScreenMargin = 1.0;

const int _kMaxTooltipLines = 5;
const Color _kTooltipBackgroundColor = Color.fromARGB(230, 60, 60, 60);
const Color _kHighlightedRenderObjectFillColor = Color.fromARGB(128, 128, 128, 255);
const Color _kHighlightedRenderObjectBorderColor = Color.fromARGB(128, 64, 64, 128);

const TextStyle _messageStyle = TextStyle(
  color: Color(0xFFFFFFFF),
  fontSize: 10.0,
  height: 1.2,
);

class WidgetInspectorState extends State<WidgetInspector>
    with WidgetsBindingObserver {

  WidgetInspectorState() : selection = WidgetInspectorService.instance.selection;

  Offset? _lastPointerLocation;

  final InspectorSelection selection;

  /// Whether the inspector is in select mode.
  ///
  /// In select mode, pointer interactions trigger widget selection instead of
  /// normal interactions. Otherwise the previously selected widget is
  /// highlighted but the application can be interacted with normally.
  bool isSelectMode = true;

  final GlobalKey _ignorePointerKey = GlobalKey();

  /// Distance from the edge of the bounding box for an element to consider
  /// as selecting the edge of the bounding box.
  static const double _edgeHitMargin = 2.0;

  InspectorSelectionChangedCallback? _selectionChangedCallback;
  @override
  void initState() {
    super.initState();

    _selectionChangedCallback = () {
      setState(() {
        // The [selection] property which the build method depends on has
        // changed.
      });
    };
    WidgetInspectorService.instance.selectionChangedCallback = _selectionChangedCallback;
  }

  @override
  void dispose() {
    if (WidgetInspectorService.instance.selectionChangedCallback == _selectionChangedCallback) {
      WidgetInspectorService.instance.selectionChangedCallback = null;
    }
    super.dispose();
  }

  bool _hitTestHelper(
      List<RenderObject> hits,
      List<RenderObject> edgeHits,
      Offset position,
      RenderObject object,
      Matrix4 transform,
      ) {
    bool hit = false;
    final Matrix4? inverse = Matrix4.tryInvert(transform);
    if (inverse == null) {
      // We cannot invert the transform. That means the object doesn't appear on
      // screen and cannot be hit.
      return false;
    }
    final Offset localPosition = MatrixUtils.transformPoint(inverse, position);

    final List<DiagnosticsNode> children = object.debugDescribeChildren();
    for (int i = children.length - 1; i >= 0; i -= 1) {
      final DiagnosticsNode diagnostics = children[i];
      if (diagnostics.style == DiagnosticsTreeStyle.offstage ||
          diagnostics.value is! RenderObject) {
        continue;
      }
      final RenderObject child = diagnostics.value! as RenderObject;
      final Rect? paintClip = object.describeApproximatePaintClip(child);
      if (paintClip != null && !paintClip.contains(localPosition)) {
        continue;
      }

      final Matrix4 childTransform = transform.clone();
      object.applyPaintTransform(child, childTransform);
      if (_hitTestHelper(hits, edgeHits, position, child, childTransform)) {
        hit = true;
      }
    }

    final Rect bounds = object.semanticBounds;
    if (bounds.contains(localPosition)) {
      hit = true;
      // Hits that occur on the edge of the bounding box of an object are
      // given priority to provide a way to select objects that would
      // otherwise be hard to select.
      if (!bounds.deflate(_edgeHitMargin).contains(localPosition)) {
        edgeHits.add(object);
      }
    }
    if (hit) {
      hits.add(object);
    }
    return hit;
  }

  /// Returns the list of render objects located at the given position ordered
  /// by priority.
  ///
  /// All render objects that are not offstage that match the location are
  /// included in the list of matches. Priority is given to matches that occur
  /// on the edge of a render object's bounding box and to matches found by
  /// [RenderBox.hitTest].
  List<RenderObject> hitTest(Offset position, RenderObject root) {
    final List<RenderObject> regularHits = <RenderObject>[];
    final List<RenderObject> edgeHits = <RenderObject>[];

    _hitTestHelper(regularHits, edgeHits, position, root, root.getTransformTo(null));
    // Order matches by the size of the hit area.
    double area(RenderObject object) {
      final Size size = object.semanticBounds.size;
      return size.width * size.height;
    }
    regularHits.sort((RenderObject a, RenderObject b) => area(a).compareTo(area(b)));
    final Set<RenderObject> hits = <RenderObject>{
      ...edgeHits,
      ...regularHits,
    };
    return hits.toList();
  }

  void _inspectAt(Offset position) {
    if (!isSelectMode) {
      return;
    }

    final RenderIgnorePointer ignorePointer = _ignorePointerKey.currentContext!.findRenderObject()! as RenderIgnorePointer;
    final RenderObject userRender = ignorePointer.child!;
    final List<RenderObject> selected = hitTest(position, userRender);

    setState(() {
      selection.candidates = selected;
    });
  }

  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
  }

  void _handlePanUpdate(DragUpdateDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    // If the pan ends on the edge of the window assume that it indicates the
    // pointer is being dragged off the edge of the display not a regular touch
    // on the edge of the display. If the pointer is being dragged off the edge
    // of the display we do not want to select anything. A user can still select
    // a widget that is only at the exact screen margin by tapping.
    final ui.FlutterView view = View.of(context);
    final Rect bounds = (Offset.zero & (view.physicalSize / view.devicePixelRatio)).deflate(_kOffScreenMargin);
    if (!bounds.contains(_lastPointerLocation!)) {
      setState(() {
        selection.clear();
      });
    }
  }

  void _handleTap() {
    if (!isSelectMode) {
      return;
    }
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation!);
      WidgetInspectorService.instance._sendInspectEvent(selection.current);
    }
    setState(() {
      // Only exit select mode if there is a button to return to select mode.
      if (widget.selectButtonBuilder != null) {
        isSelectMode = false;
      }
    });
  }

  void _handleEnableSelect() {
    setState(() {
      isSelectMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Be careful changing this build method. The _InspectorOverlayLayer
    // assumes the root RenderObject for the WidgetInspector will be
    // a RenderStack with a _RenderInspectorOverlay as the last child.
    return Stack(children: <Widget>[
      GestureDetector(
        onTap: _handleTap,
        onPanDown: _handlePanDown,
        onPanEnd: _handlePanEnd,
        onPanUpdate: _handlePanUpdate,
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        child: IgnorePointer(
          ignoring: isSelectMode,
          key: _ignorePointerKey,
          child: widget.child,
        ),
      ),
      if (!isSelectMode && widget.selectButtonBuilder != null)
        Positioned(
          left: _kInspectButtonMargin,
          bottom: _kInspectButtonMargin,
          child: widget.selectButtonBuilder!(context, _handleEnableSelect),
        ),
      _InspectorOverlay(selection: selection),
    ]);
  }
}

class _InspectorOverlay extends LeafRenderObjectWidget {
  const _InspectorOverlay({
    required this.selection,
  });

  final InspectorSelection selection;

  @override
  _RenderInspectorOverlay createRenderObject(BuildContext context) {
    return _RenderInspectorOverlay(selection: selection);
  }

  @override
  void updateRenderObject(BuildContext context, _RenderInspectorOverlay renderObject) {
    renderObject.selection = selection;
  }
}

class _RenderInspectorOverlay extends RenderBox {
  /// The arguments must not be null.
  _RenderInspectorOverlay({ required InspectorSelection selection })
      : _selection = selection;

  InspectorSelection get selection => _selection;
  InspectorSelection _selection;
  set selection(InspectorSelection value) {
    if (value != _selection) {
      _selection = value;
    }
    markNeedsPaint();
  }

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return constraints.constrain(Size.infinite);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(needsCompositing);
    context.addLayer(_InspectorOverlayLayer(
      overlayRect: Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      selection: selection,
      rootRenderObject: parent is RenderObject ? parent! : null,
    ));
  }
}

/// A layer that outlines the selected [RenderObject] and candidate render
/// objects that also match the last pointer location.
///
/// This approach is horrific for performance and is only used here because this
/// is limited to debug mode. Do not duplicate the logic in production code.
class _InspectorOverlayLayer extends Layer {
  /// Creates a layer that displays the inspector overlay.
  _InspectorOverlayLayer({
    required this.overlayRect,
    required this.selection,
    required this.rootRenderObject,
  }) {
    bool inDebugMode = false;
    assert(() {
      inDebugMode = true;
      return true;
    }());
    if (!inDebugMode) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary(
          'The inspector should never be used in production mode due to the '
              'negative performance impact.',
        ),
      ]);
    }
  }

  InspectorSelection selection;

  /// The rectangle in this layer's coordinate system that the overlay should
  /// occupy.
  ///
  /// The scene must be explicitly recomposited after this property is changed
  /// (as described at [Layer]).
  final Rect overlayRect;

  /// Widget inspector root render object. The selection overlay will be painted
  /// with transforms relative to this render object.
  final RenderObject? rootRenderObject;

  _InspectorOverlayRenderState? _lastState;

  /// Picture generated from _lastState.
  late ui.Picture _picture;

  TextPainter? _textPainter;
  double? _textPainterMaxWidth;

  @override
  void dispose() {
    _textPainter?.dispose();
    _textPainter = null;
    super.dispose();
  }

  @override
  void addToScene(ui.SceneBuilder builder) {
    if (!selection.active) {
      return;
    }

    final RenderObject selected = selection.current!;

    if (!_isInInspectorRenderObjectTree(selected)) {
      return;
    }

    final List<_TransformedRect> candidates = <_TransformedRect>[];
    for (final RenderObject candidate in selection.candidates) {
      if (candidate == selected || !candidate.attached
          || !_isInInspectorRenderObjectTree(candidate)) {
        continue;
      }
      candidates.add(_TransformedRect(candidate, rootRenderObject));
    }

    final _InspectorOverlayRenderState state = _InspectorOverlayRenderState(
      overlayRect: overlayRect,
      selected: _TransformedRect(selected, rootRenderObject),
      tooltip: selection.currentElement!.toStringShort(),
      textDirection: TextDirection.ltr,
      candidates: candidates,
    );

    if (state != _lastState) {
      _lastState = state;
      _picture = _buildPicture(state);
    }
    builder.addPicture(Offset.zero, _picture);
  }

  ui.Picture _buildPicture(_InspectorOverlayRenderState state) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, state.overlayRect);
    final Size size = state.overlayRect.size;
    // The overlay rect could have an offset if the widget inspector does
    // not take all the screen.
    canvas.translate(state.overlayRect.left, state.overlayRect.top);

    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _kHighlightedRenderObjectFillColor;

    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = _kHighlightedRenderObjectBorderColor;

    // Highlight the selected renderObject.
    final Rect selectedPaintRect = state.selected.rect.deflate(0.5);
    canvas
      ..save()
      ..transform(state.selected.transform.storage)
      ..drawRect(selectedPaintRect, fillPaint)
      ..drawRect(selectedPaintRect, borderPaint)
      ..restore();

    // Show all other candidate possibly selected elements. This helps selecting
    // render objects by selecting the edge of the bounding box shows all
    // elements the user could toggle the selection between.
    for (final _TransformedRect transformedRect in state.candidates) {
      canvas
        ..save()
        ..transform(transformedRect.transform.storage)
        ..drawRect(transformedRect.rect.deflate(0.5), borderPaint)
        ..restore();
    }

    final Rect targetRect = MatrixUtils.transformRect(
      state.selected.transform, state.selected.rect,
    );
    final Offset target = Offset(targetRect.left, targetRect.center.dy);
    const double offsetFromWidget = 9.0;
    final double verticalOffset = (targetRect.height) / 2 + offsetFromWidget;

    _paintDescription(canvas, state.tooltip, state.textDirection, target, verticalOffset, size, targetRect);

    // TODO(jacobr): provide an option to perform a debug paint of just the
    // selected widget.
    return recorder.endRecording();
  }

  void _paintDescription(
      Canvas canvas,
      String message,
      TextDirection textDirection,
      Offset target,
      double verticalOffset,
      Size size,
      Rect targetRect,
      ) {
    canvas.save();
    final double maxWidth = size.width - 2 * (_kScreenEdgeMargin + _kTooltipPadding);
    final TextSpan? textSpan = _textPainter?.text as TextSpan?;
    if (_textPainter == null || textSpan!.text != message || _textPainterMaxWidth != maxWidth) {
      _textPainterMaxWidth = maxWidth;
      _textPainter?.dispose();
      _textPainter = TextPainter()
        ..maxLines = _kMaxTooltipLines
        ..ellipsis = '...'
        ..text = TextSpan(style: _messageStyle, text: message)
        ..textDirection = textDirection
        ..layout(maxWidth: maxWidth);
    }

    final Size tooltipSize = _textPainter!.size + const Offset(_kTooltipPadding * 2, _kTooltipPadding * 2);
    final Offset tipOffset = positionDependentBox(
      size: size,
      childSize: tooltipSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: false,
    );

    final Paint tooltipBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = _kTooltipBackgroundColor;
    canvas.drawRect(
      Rect.fromPoints(
        tipOffset,
        tipOffset.translate(tooltipSize.width, tooltipSize.height),
      ),
      tooltipBackground,
    );

    double wedgeY = tipOffset.dy;
    final bool tooltipBelow = tipOffset.dy > target.dy;
    if (!tooltipBelow) {
      wedgeY += tooltipSize.height;
    }

    const double wedgeSize = _kTooltipPadding * 2;
    double wedgeX = math.max(tipOffset.dx, target.dx) + wedgeSize * 2;
    wedgeX = math.min(wedgeX, tipOffset.dx + tooltipSize.width - wedgeSize * 2);
    final List<Offset> wedge = <Offset>[
      Offset(wedgeX - wedgeSize, wedgeY),
      Offset(wedgeX + wedgeSize, wedgeY),
      Offset(wedgeX, wedgeY + (tooltipBelow ? -wedgeSize : wedgeSize)),
    ];
    canvas.drawPath(Path()..addPolygon(wedge, true), tooltipBackground);
    _textPainter!.paint(canvas, tipOffset + const Offset(_kTooltipPadding, _kTooltipPadding));
    canvas.restore();
  }

  @override
  @protected
  bool findAnnotations<S extends Object>(
      AnnotationResult<S> result,
      Offset localPosition, {
        bool? onlyFirst,
      }) {
    return false;
  }

  /// Return whether or not a render object belongs to this inspector widget
  /// tree.
  /// The inspector selection is static, so if there are multiple inspector
  /// overlays in the same app (i.e. an storyboard), a selected or candidate
  /// render object may not belong to this tree.
  bool _isInInspectorRenderObjectTree(RenderObject child) {
    RenderObject? current = child.parent;
    while (current != null) {
      // We found the widget inspector render object.
      if (current is RenderStack
          && current.lastChild is _RenderInspectorOverlay) {
        return rootRenderObject == current;
      }
      current = current.parent;
    }
    return false;
  }
}

/// State describing how the inspector overlay should be rendered.
///
/// The equality operator can be used to determine whether the overlay needs to
/// be rendered again.
@immutable
class _InspectorOverlayRenderState {
  const _InspectorOverlayRenderState({
    required this.overlayRect,
    required this.selected,
    required this.candidates,
    required this.tooltip,
    required this.textDirection,
  });

  final Rect overlayRect;
  final _TransformedRect selected;
  final List<_TransformedRect> candidates;
  final String tooltip;
  final TextDirection textDirection;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _InspectorOverlayRenderState
        && other.overlayRect == overlayRect
        && other.selected == selected
        && listEquals<_TransformedRect>(other.candidates, candidates)
        && other.tooltip == tooltip;
  }

  @override
  int get hashCode => Object.hash(overlayRect, selected, Object.hashAll(candidates), tooltip);
}

@immutable
class _TransformedRect {
  _TransformedRect(RenderObject object, RenderObject? ancestor)
      : rect = object.semanticBounds,
        transform = object.getTransformTo(ancestor);

  final Rect rect;
  final Matrix4 transform;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _TransformedRect
        && other.rect == rect
        && other.transform == transform;
  }

  @override
  int get hashCode => Object.hash(rect, transform);
}

class _WidgetInspectorService = Object with WidgetInspectorService;

mixin WidgetInspectorService {
  /// The current [WidgetInspectorService].
  static WidgetInspectorService get instance => _instance;
  static WidgetInspectorService _instance = _WidgetInspectorService();

  bool? _widgetCreationTracked;
  final Map<String, InspectorReferenceData> _idToReferenceData = <String, InspectorReferenceData>{};

  /// Callback typically registered by the [WidgetInspector] to receive
  /// notifications when [selection] changes.
  ///
  /// The Flutter IntelliJ Plugin does not need to listen for this event as it
  /// instead listens for `dart:developer` `inspect` events which also trigger
  /// when the inspection target changes on device.
  InspectorSelectionChangedCallback? selectionChangedCallback;

  void _sendInspectEvent(Object? object){
    inspect(object);

    final _Location? location = _getSelectedSummaryWidgetLocation(null);
    if (location != null) {
      postEvent(
        'navigate',
        <String, Object>{
          'fileUri': location.file, // URI file path of the location.
          'line': location.line, // 1-based line number.
          'column': location.column, // 1-based column number.
          'source': 'flutter.inspector',
        },
        stream: 'ToolEvent',
      );
    }
  }

  _Location? _getSelectedSummaryWidgetLocation(String? previousSelectionId) {
    return _getCreationLocation(_getSelectedSummaryDiagnosticsNode(previousSelectionId)?.value);
  }

  DiagnosticsNode? _getSelectedSummaryDiagnosticsNode(String? previousSelectionId) {
    if (!isWidgetCreationTracked()) {
      return _getSelectedWidgetDiagnosticsNode(previousSelectionId);
    }
    final DiagnosticsNode? previousSelection = toObject(previousSelectionId) as DiagnosticsNode?;
    Element? current = selection.currentElement;
    if (current != null && !_isValueCreatedByLocalProject(current)) {
      Element? firstLocal;
      for (final Element candidate in current.debugGetDiagnosticChain()) {
        if (_isValueCreatedByLocalProject(candidate)) {
          firstLocal = candidate;
          break;
        }
      }
      current = firstLocal;
    }
    return current == previousSelection?.value ? previousSelection : current?.toDiagnosticsNode();
  }

  bool _isValueCreatedByLocalProject(Object? value) {
    final _Location? creationLocation = _getCreationLocation(value);
    if (creationLocation == null) {
      return false;
    }
    return _isLocalCreationLocation(creationLocation.file);
  }

  /// Memoized version of [_isLocalCreationLocationImpl].
  bool _isLocalCreationLocation(String locationUri) {
    final bool? cachedValue = _isLocalCreationCache[locationUri];
    if (cachedValue != null) {
      return cachedValue;
    }
    final bool result = _isLocalCreationLocationImpl(locationUri);
    _isLocalCreationCache[locationUri] = result;
    return result;
  }

  bool _isLocalCreationLocationImpl(String locationUri) {
    final String file = Uri.parse(locationUri).path;

    // By default check whether the creation location was within package:flutter.
    if (_pubRootDirectories == null) {
      // TODO(chunhtai): Make it more robust once
      // https://github.com/flutter/flutter/issues/32660 is fixed.
      return !file.contains('packages/flutter/');
    }
    for (final String directory in _pubRootDirectories!) {
      if (file.startsWith(directory)) {
        return true;
      }
    }
    return false;
  }

  List<String>? _pubRootDirectories;
  /// Memoization for [_isLocalCreationLocation].
  final HashMap<String, bool> _isLocalCreationCache = HashMap<String, bool>();

  /// Returns whether [Widget] creation locations are available.
  ///
  /// {@macro flutter.widgets.WidgetInspectorService.getChildrenSummaryTree}
  bool isWidgetCreationTracked() {
    _widgetCreationTracked ??= const _WidgetForTypeTests() is _HasCreationLocation;
    return _widgetCreationTracked!;
  }

  DiagnosticsNode? _getSelectedWidgetDiagnosticsNode(String? previousSelectionId) {
    final DiagnosticsNode? previousSelection = toObject(previousSelectionId) as DiagnosticsNode?;
    final Element? current = selection.currentElement;
    return current == previousSelection?.value ? previousSelection : current?.toDiagnosticsNode();
  }

  /// Ground truth tracking what object(s) are currently selected used by both
  /// GUI tools such as the Flutter IntelliJ Plugin and the [WidgetInspector]
  /// displayed on the device.
  final InspectorSelection selection = InspectorSelection();

  /// Returns the Dart object associated with a reference id.
  ///
  /// The `groupName` parameter is not required by is added to regularize the
  /// API surface of the methods in this class called from the Flutter IntelliJ
  /// Plugin.
  @protected
  Object? toObject(String? id, [ String? groupName ]) {
    if (id == null) {
      return null;
    }

    final InspectorReferenceData? data = _idToReferenceData[id];
    if (data == null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[ErrorSummary('Id does not exist.')]);
    }
    return data.value;
  }
}

/// A tuple with file, line, and column number, for displaying human-readable
/// file locations.
class _Location {
  const _Location({
    required this.file,
    required this.line,
    required this.column,
    // ignore: unused_element, unused_element_parameter
    this.name,
  });

  /// File path of the location.
  final String file;

  /// 1-based line number.
  final int line;

  /// 1-based column number.
  final int column;

  /// Optional name of the parameter or function at this location.
  final String? name;

  Map<String, Object?> toJsonMap() {
    final Map<String, Object?> json = <String, Object?>{
      'file': file,
      'line': line,
      'column': column,
    };
    if (name != null) {
      json['name'] = name;
    }
    return json;
  }

  @override
  String toString() {
    final List<String> parts = <String>[];
    if (name != null) {
      parts.add(name!);
    }
    parts.add(file);
    parts..add('$line')..add('$column');
    return parts.join(':');
  }
}

/// Returns the creation location of an object if one is available.
///
/// {@macro flutter.widgets.WidgetInspectorService.getChildrenSummaryTree}
///
/// Currently creation locations are only available for [Widget] and [Element].
_Location? _getCreationLocation(Object? object) {
  final Object? candidate = object is Element && !object.debugIsDefunct ? object.widget : object;
  return candidate == null ? null : _getObjectCreationLocation(candidate);
}

_Location? _getObjectCreationLocation(Object object) {
  return object is _HasCreationLocation ? object._location : null;
}

/// Interface for classes that track the source code location the their
/// constructor was called from.
///
/// {@macro flutter.widgets.WidgetInspectorService.getChildrenSummaryTree}
// ignore: unused_element
abstract class _HasCreationLocation {
  _Location? get _location;
}

class _WidgetForTypeTests extends Widget {
  const _WidgetForTypeTests();

  @override
  Element createElement() => throw UnimplementedError();
}