import 'package:flutter/material.dart';
import 'sticky-list.dart';

/// Represents a row for StickyList.
///
/// Check [HeaderRow] and [RegularRow].
abstract class StickyListRow {
  final Widget child;
  double? _height;
  final GlobalKey _key = GlobalKey();

  StickyListRow({required Widget child, double? height})
      : _height = height,
        child = height == null
            ? WrapStickyWidget(key: GlobalKey(), child: child)
            : child;

  double getHeight() {
    if (_height == null) {
      final context = _key.currentContext;
      if (context != null) {
        _height = context.size?.height ?? 0.0;
      } else {
        throw Exception('Tried to get context height of non-visible row');
      }
    }
    return _height!;
  }

  bool isSticky() => this is HeaderRow;
}

/// Header row for list that sticks to top when scrolled.
class HeaderRow extends StickyListRow {
  HeaderRow({required Widget child, double? height})
      : super(child: child, height: height);
}

/// Regular row for list.
class RegularRow extends StickyListRow {
  RegularRow({required Widget child, double? height})
      : super(child: child, height: height);
}
