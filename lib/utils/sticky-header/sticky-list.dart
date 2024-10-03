import 'package:flutter/material.dart';
import 'sticky-list-row.dart';

typedef StickyWidgetBuilder = StickyListRow Function(
  BuildContext context,
  int index,
);

/// Widget that operates likes [ListView] with type of header rows that
/// sticks to top when scrolled.
///
/// Data for this list are [StickyListRow] : [HeaderRow] and [RegularRow], which
/// are set in list to constructor, or using builder in similar way to
/// ListView builder.
///
/// You should supply height for rows and headers, otherwise GlobalKeys are
/// used to determine height.
///
class StickyList extends StatefulWidget {
  /// Background color of list
  final Color background;
  final bool reverse;

  /// Delegate that builds children widget similar to [SliverChildBuilderDelegate]
  final _StickyChildBuilderDelegate childrenDelegate;
  final ScrollController controller;

  /// Use this constructor for list of [StickyListRow]
  StickyList({
    super.key,
    Color background = Colors.transparent,
    bool reverse = false,
    required ScrollController controller,
    List<StickyListRow> children = const <StickyListRow>[],
  })  : childrenDelegate = _StickyChildBuilderDelegate(children),
        reverse = reverse,
        background = background,
        controller = controller;

  /// This constructor is appropriate for list views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  StickyList.builder({
    super.key,
    Color background = Colors.transparent,
    bool reverse = false,
    required int itemCount,
    required ScrollController controller,
    required StickyWidgetBuilder builder,
  })  : childrenDelegate =
            _StickyChildBuilderDelegate.builder(builder, itemCount),
        reverse = reverse,
        background = background,
        controller = controller;

  @override
  _StickyListState createState() => _StickyListState(background: background);
}

class _StickyListState extends State<StickyList> {
  final Color _background;

  /// When new sticky is coming, we use transform (translation) to simulate
  /// that the new sticky header is pushing the old one off the screen.
  var _stickyTranslationOffset = 0.0;

  /// Current position at the top of list
  var _currentPosition = -1;

  _StickyListState({required Color background})
      : _background = background,
        _stickyTranslationOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: _background),
          ),
          ListView.builder(
            reverse: widget.reverse,
            itemBuilder: (BuildContext context, int index) {
              return widget.childrenDelegate.build(context, index).child;
            },
            itemCount: widget.childrenDelegate.itemCount,
            controller: _getScrollController(),
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(0.0),
          ),
          Positioned(
            top: widget.reverse ? null : 0.0,
            bottom: widget.reverse ? 0.0 : null,
            left: 0.0,
            right: 0.0,
            child: _getStickyHeaderWidget(context),
          ),
        ],
      ),
    );
  }

  Widget _getStickyHeaderWidget(BuildContext ctx) {
    Widget stickyWidget = Container();
    if (_currentPosition == -1) {
      // Don't display header for iOS bounce
    } else {
      // Use child widget to avoid duplicate widgets with same global key
      Widget header = _getPreviousHeader(context, _currentPosition - 1);
      if (header is WrapStickyWidget) {
        header = (header).child;
      }

      var translationOffset =
          widget.reverse ? _stickyTranslationOffset : -_stickyTranslationOffset;
      stickyWidget = ClipRect(
        child: Container(
          transform: Matrix4.translationValues(0.0, translationOffset, 0.0),
          child: header,
        ),
      );
    }
    return stickyWidget;
  }

  Widget _getPreviousHeader(BuildContext ctx, int position) {
    for (int i = position; i >= 0; i--) {
      if (widget.childrenDelegate.build(ctx, i).isSticky()) {
        return widget.childrenDelegate.build(ctx, i).child;
      }
    }

    return widget.childrenDelegate.build(ctx, 0).child;
  }

  ScrollController _getScrollController() {
    // If a ScrollController is provided use it, otherwise create a new ScrollController
    var controller = widget.controller;
    controller.addListener(() {
      var pixels = controller.offset;
      var newPosition = _getPositionForOffset(context, pixels);

      _calculateStickyOffset(context, newPosition, pixels);
      _calculateNewPosition(pixels, newPosition);
    });
    return controller;
  }

  void _calculateNewPosition(double pixels, int newPosition) {
    if (pixels < 0) {
      setState(() {
        _currentPosition = -1;
      });
    } else if (newPosition != _currentPosition) {
      setState(() {
        _currentPosition = newPosition;
      });
    }
  }

  void _calculateStickyOffset(
    BuildContext ctx,
    int newPosition,
    double pixels,
  ) {
    if ((newPosition > 0) &&
        widget.childrenDelegate.build(ctx, newPosition).isSticky()) {
      final headerHeight =
          widget.childrenDelegate.build(ctx, newPosition).getHeight();
      if (_getOffsetForCurrentRow(context, pixels, newPosition) <
          headerHeight) {
        setState(() {
          _stickyTranslationOffset = headerHeight -
              _getOffsetForCurrentRow(context, pixels, newPosition);
        });
      }
    } else {
      if (_stickyTranslationOffset > 0.0) {
        setState(() {
          _stickyTranslationOffset = 0.0;
        });
      }
    }
  }

  double _getOffsetForCurrentRow(
    BuildContext ctx,
    double offset,
    int position,
  ) {
    double calcOffset = offset;
    for (var i = 0; i < position - 1; i++) {
      calcOffset =
          calcOffset - widget.childrenDelegate.build(ctx, i).getHeight();
    }

    return (widget.childrenDelegate.build(ctx, position - 1).getHeight() -
        calcOffset);
  }

  int _getPositionForOffset(BuildContext ctx, double offset) {
    int counter = 0;
    double calcOffset = offset;

    if (offset < 1) {
      return -1;
    }

    while (calcOffset > 0) {
      calcOffset =
          calcOffset - widget.childrenDelegate.build(ctx, counter).getHeight();
      counter++;
    }

    return counter;
  }
}

/// Simple widget that just wraps the child. When height is not provided,
/// GlobalKeys are used, and this widget is used to access child and avoid
/// duplicate widget for same GlobalKey (when duplicating header).
class WrapStickyWidget extends StatelessWidget {
  final Widget child;

  const WrapStickyWidget({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

///  A delegate that supplies children for sticky list. It is used in list and
///  builder way. Works similar to [SliverChildBuilderDelegate] that is used
///  by [ListView]
class _StickyChildBuilderDelegate {
  StickyWidgetBuilder? stickyBuilder;
  late int itemCount;
  List<StickyListRow> children;

  _StickyChildBuilderDelegate(List<StickyListRow> children)
      : stickyBuilder = null,
        children = children,
        itemCount = children.length;

  _StickyChildBuilderDelegate.builder(
    StickyWidgetBuilder builder,
    int itemCount,
  )   : stickyBuilder = builder,
        itemCount = itemCount,
        children = <StickyListRow>[];

  StickyListRow build(BuildContext context, int index) {
    if (stickyBuilder != null) {
      final w = stickyBuilder!(context, index);
      return w;
    } else {
      return children[index];
    }
  }
}
