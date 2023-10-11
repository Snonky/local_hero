import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:local_hero/local_hero.dart';
import 'package:local_hero/src/rendering/sliver_local_hero_list.dart';

/// A [SliverList] that can contain [LocalHero]s. The LocalHero children are
/// specially treated to make local hero animations possible inside a lazy list.
/// All other children behave the same as in a normal [SliverList].
///
/// Do not add a repaint boundary or other wrapping widgets to the LocalHeros as
/// that will prevent them from receiving updates about their own location on
/// screen.
///
/// The ancestor [LocalHeroScope] should have its
/// [LocalHeroScope.onlyAnimateRemount] option set to true to prevent the
/// [LocalHero]s from animating because of scroll movement.
///
/// When lazily loaded, the LocalHeros can't animate to and from an area of the
/// viewport that is outside the cache extent as their widgets will be disposed
/// when they leave that extent.
class SliverLocalHeroList extends SliverList {
  /// Creates a [SliverLocalHeroList]
  const SliverLocalHeroList({
    Key? key,
    required SliverChildDelegate delegate,
  }) : super(delegate: delegate, key: key);

  @override
  RenderSliverList createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverLocalHeroList(childManager: element);
  }
}
