import 'package:flutter/rendering.dart';
import 'package:local_hero/src/rendering/local_hero_layer.dart';

/// A [RenderSliverList] that paints each of its LocalHero children even when
/// they move out of the viewport into the cache extent to keep animations to
/// and from outside the viewport possible.
class RenderSliverLocalHeroList extends RenderSliverList {
  /// Creates a [RenderSliverLocalHeroList]
  RenderSliverLocalHeroList({
    required RenderSliverBoxChildManager childManager,
  }) : super(childManager: childManager);

  // paint method copied and adapted from [RenderSliverMultiBoxAdaptor]
  @override
  void paint(PaintingContext context, Offset offset) {
    if (firstChild == null) {
      return;
    }
    // offset is to the top-left corner, regardless of our axis direction.
    // originOffset gives us the delta from the real origin to the origin in the axis direction.
    final Offset mainAxisUnit, crossAxisUnit, originOffset;
    final bool addExtent;
    switch (applyGrowthDirectionToAxisDirection(
        constraints.axisDirection, constraints.growthDirection)) {
      case AxisDirection.up:
        mainAxisUnit = const Offset(0.0, -1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset + Offset(0.0, geometry!.paintExtent);
        addExtent = true;
        break;
      case AxisDirection.right:
        mainAxisUnit = const Offset(1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.down:
        mainAxisUnit = const Offset(0.0, 1.0);
        crossAxisUnit = const Offset(1.0, 0.0);
        originOffset = offset;
        addExtent = false;
        break;
      case AxisDirection.left:
        mainAxisUnit = const Offset(-1.0, 0.0);
        crossAxisUnit = const Offset(0.0, 1.0);
        originOffset = offset + Offset(geometry!.paintExtent, 0.0);
        addExtent = true;
    }
    RenderBox? child = firstChild;
    while (child != null) {
      final double mainAxisDelta = childMainAxisPosition(child);
      final double crossAxisDelta = childCrossAxisPosition(child);
      Offset childOffset = Offset(
        originOffset.dx +
            mainAxisUnit.dx * mainAxisDelta +
            crossAxisUnit.dx * crossAxisDelta,
        originOffset.dy +
            mainAxisUnit.dy * mainAxisDelta +
            crossAxisUnit.dy * crossAxisDelta,
      );
      if (addExtent) {
        childOffset += mainAxisUnit * paintExtentOf(child);
      }

      // When a LocalHero goes off the viewport into the cache extent it is
      // still painted to keep animations from and to off-screen correct.
      // Otherwise if the child's visible interval (mainAxisDelta, mainAxisDelta + paintExtentOf(child))
      // does not intersect the paint extent interval (0, constraints.remainingPaintExtent), it's hidden.
      if (_isLocalHero(child) ||
          mainAxisDelta < constraints.remainingPaintExtent &&
              mainAxisDelta + paintExtentOf(child) > 0) {
        context.paintChild(child, childOffset);
      }

      child = childAfter(child);
    }
  }

  bool _isLocalHero(RenderBox sliverListChild) {
    return (sliverListChild as RenderIndexedSemantics).child
        is RenderLocalHeroLeaderLayer;
  }
}
