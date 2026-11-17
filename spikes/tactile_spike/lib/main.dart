import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import 'tactile.dart';

void main() => runApp(const SpikeApp());

class SpikeApp extends StatefulWidget {
  const SpikeApp({super.key});

  @override
  State<SpikeApp> createState() => _SpikeAppState();
}

class _SpikeAppState extends State<SpikeApp> {
  bool _dark = false;
  bool _blur = false;

  @override
  Widget build(BuildContext context) {
    final b = _dark ? Brightness.dark : Brightness.light;
    return MaterialApp(
      title: 'Tactile spike',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(b),
      home: Builder(builder: (context) {
        final ground = SurfaceData(SurfaceKind.ground, b);
        // Scaffold supplies Material, DefaultTextStyle and the themed window background.
        return Scaffold(
          backgroundColor: ground.fill,
          body: SurfaceScope(
            data: ground,
            child: Stack(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 56,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            AppButton.secondary(
                              label: _dark ? 'Light mode' : 'Dark mode',
                              onPressed: () => setState(() => _dark = !_dark),
                            ),
                            const SizedBox(width: 8),
                            AppButton.secondary(
                              label: 'Blur',
                              onPressed: () => setState(() => _blur = true),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(child: _Page()),
                  ],
                ),
                if (_blur)
                  _Overlay(onClose: () => setState(() => _blur = false)),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Page extends StatefulWidget {
  const _Page();

  @override
  State<_Page> createState() => _PageState();
}

class _PageState extends State<_Page> with SingleTickerProviderStateMixin {
  // A looping bar behind the overlay so blur stutter is visible.
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.surface;
    return Stack(
      children: [
        const Positioned.fill(child: CardDemo()),
        Positioned(
          left: 24,
          right: 24,
          bottom: 24,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Align(
              alignment: Alignment(_c.value * 2 - 1, 0),
              child: Container(
                  width: 48,
                  height: 8,
                  decoration: BoxDecoration(
                      color: s.rootInk(9),
                      borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modal-style overlay: backdrop black 30 % (light) / 90 % (dark) + 2 px blur (04 §7 Dialog).
class _Overlay extends StatelessWidget {
  const _Overlay({required this.onClose});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: ColoredBox(
          color: Colors.black.withValues(alpha: dark ? .9 : .3),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: TactileSurface(
                kind: SurfaceKind.overlay,
                radius: 8,
                padding: const EdgeInsets.all(24),
                child: Builder(builder: (context) {
                  final s = context.surface;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blurred backdrop',
                          style: labelStyle(s.rootInk(12)).copyWith(
                              fontSize: 16,
                              height: 24 / 16,
                              letterSpacing: 0)),
                      const SizedBox(height: 2),
                      Text('The page behind is blurred by 2 px.',
                          style: labelStyle(s.rootInk(11))
                              .copyWith(letterSpacing: 0)),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton.primary(
                            label: 'Close', onPressed: onClose),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
