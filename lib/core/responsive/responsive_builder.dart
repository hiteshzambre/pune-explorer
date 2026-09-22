import 'package:flutter/material.dart';
import 'breakpoints.dart';

typedef ResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  BoxConstraints constraints,
  ScreenType screenType,
);

enum ScreenType { smallPhone, mobile, foldable, tablet, desktop }

/// ResponsiveBuilder dynamically builds widgets based on BoxConstraints or MediaQuery
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType screenType)? builder;
  final Widget? smallPhone;
  final Widget? mobile;
  final Widget? foldable;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    this.builder,
    this.smallPhone,
    this.mobile,
    this.foldable,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        ScreenType screenType;
        if (width < Breakpoints.smallPhoneMax) {
          screenType = ScreenType.smallPhone;
        } else if (width < Breakpoints.mobileMax) {
          screenType = ScreenType.mobile;
        } else if (width < Breakpoints.foldableMax) {
          screenType = ScreenType.foldable;
        } else if (width < Breakpoints.tabletMax) {
          screenType = ScreenType.tablet;
        } else {
          screenType = ScreenType.desktop;
        }

        if (builder != null) {
          return builder!(context, screenType);
        }

        switch (screenType) {
          case ScreenType.desktop:
            return desktop ?? tablet ?? foldable ?? mobile ?? const SizedBox.shrink();
          case ScreenType.tablet:
            return tablet ?? foldable ?? mobile ?? const SizedBox.shrink();
          case ScreenType.foldable:
            return foldable ?? tablet ?? mobile ?? const SizedBox.shrink();
          case ScreenType.mobile:
            return mobile ?? const SizedBox.shrink();
          case ScreenType.smallPhone:
            return smallPhone ?? mobile ?? const SizedBox.shrink();
        }
      },
    );
  }
}

/// MaxWidthWrapper enforces maximum readable width for large screens while keeping content centered.
class MaxWidthWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const MaxWidthWrapper({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPadding = EdgeInsets.symmetric(
      horizontal: Breakpoints.getHorizontalPadding(context),
    );

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth > 0 ? maxWidth : Breakpoints.getMaxContentWidth(context),
        ),
        child: Padding(
          padding: padding ?? defaultPadding,
          child: child,
        ),
      ),
    );
  }
}

/// AdaptivePageWrapper provides complete safe-area handling, keyboard avoidance,
/// adaptive horizontal padding, and centered content clamping for any screen size.
class AdaptivePageWrapper extends StatelessWidget {
  final Widget child;
  final bool applySafeArea;
  final bool isScrollable;
  final ScrollPhysics? physics;
  final double? maxContentWidth;
  final EdgeInsetsGeometry? customPadding;

  const AdaptivePageWrapper({
    super.key,
    required this.child,
    this.applySafeArea = true,
    this.isScrollable = true,
    this.physics = const BouncingScrollPhysics(),
    this.maxContentWidth,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = customPadding ??
        EdgeInsets.symmetric(
          horizontal: Breakpoints.getHorizontalPadding(context),
          vertical: Breakpoints.getSectionGap(context),
        );

    Widget content = MaxWidthWrapper(
      maxWidth: maxContentWidth ?? Breakpoints.getMaxContentWidth(context),
      padding: effectivePadding,
      child: child,
    );

    if (isScrollable) {
      content = SingleChildScrollView(
        physics: physics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: content,
      );
    }

    if (applySafeArea) {
      content = SafeArea(
        top: true,
        bottom: true,
        left: true,
        right: true,
        child: content,
      );
    }

    return content;
  }
}

/// FoldableSplitView creates an adaptive master-detail dual-pane view on tablets and foldables,
/// falling back to a single column on phones.
class FoldableSplitView extends StatelessWidget {
  final Widget master;
  final Widget detail;
  final double masterFlex;
  final double detailFlex;
  final double gap;

  const FoldableSplitView({
    super.key,
    required this.master,
    required this.detail,
    this.masterFlex = 2,
    this.detailFlex = 3,
    this.gap = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.isMobile(context) && !Breakpoints.isLandscape(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          master,
          SizedBox(height: gap),
          detail,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: masterFlex.toInt(),
          child: master,
        ),
        SizedBox(width: gap),
        Expanded(
          flex: detailFlex.toInt(),
          child: detail,
        ),
      ],
    );
  }
}
