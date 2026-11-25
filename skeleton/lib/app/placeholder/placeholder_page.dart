import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeleton/app/placeholder/connection_check_cubit.dart';
import 'package:skeleton/app/placeholder/connection_check_state.dart';
import 'package:skeleton/core/error/failure.dart';
import 'package:skeleton/core/l10n/app_localizations.dart';
import 'package:skeleton/core/settings/app_settings.dart';
import 'package:skeleton/core/settings/app_settings_cubit.dart';
import 'package:skeleton/core/theme/tactile/pressable.dart';
import 'package:skeleton/core/theme/tactile/surface.dart';
import 'package:skeleton/core/theme/tactile/typography.dart';
import 'package:skeleton/core/theme/theme_x.dart';
import 'package:skeleton/core/theme/tokens.g.dart';

const double _buttonPressedScale = 0.97;

/// Temporary root page: theme and language controls plus a connection check.
///
/// Expects an [AppSettingsCubit] and a [ConnectionCheckCubit] above it.
class PlaceholderPage extends StatelessWidget {
  /// Creates the page.
  const PlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = context.watch<AppSettingsCubit>();
    final current = settings.state;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpace.s24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label(l10n.placeholderTitle, style: context.text.display),
          const SizedBox(height: AppSpace.s24),
          _Label(l10n.themeTitle, style: context.text.section),
          const SizedBox(height: AppSpace.s8),
          // SEAM(core-widgets-and-templates): replace with ThemeModeSwitch
          _Group(
            children: [
              for (final (mode, label) in [
                (AppThemeMode.system, l10n.themeSystem),
                (AppThemeMode.light, l10n.themeLight),
                (AppThemeMode.dark, l10n.themeDark),
              ])
                _ChoiceButton(
                  label: label,
                  selected: current.themeMode == mode,
                  onPressed: () => settings.setThemeMode(mode),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.s24),
          _Label(l10n.localeTitle, style: context.text.section),
          const SizedBox(height: AppSpace.s8),
          // SEAM(core-widgets-and-templates): replace with ThemeModeSwitch
          _Group(
            children: [
              for (final (locale, label) in [
                (AppLocale.system, l10n.localeSystem),
                (AppLocale.en, l10n.localeEnglish),
                (AppLocale.id, l10n.localeIndonesian),
              ])
                _ChoiceButton(
                  label: label,
                  selected: current.locale == locale,
                  onPressed: () => settings.setLocale(locale),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.s32),
          const _ConnectionCheck(),
        ],
      ),
    );
  }
}

class _ConnectionCheck extends StatelessWidget {
  const _ConnectionCheck();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ConnectionCheckCubit>();
    return BlocBuilder<ConnectionCheckCubit, ConnectionCheckState>(
      builder: (context, state) {
        final loading = state is ConnectionCheckLoading;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChoiceButton(
              label: loading
                  ? l10n.checkConnectionLoading
                  : l10n.checkConnection,
              selected: false,
              onPressed: loading ? null : cubit.check,
            ),
            const SizedBox(height: AppSpace.s12),
            switch (state) {
              ConnectionCheckSuccess() => _Label(l10n.checkConnectionSuccess),
              ConnectionCheckFailure(:final failure) => _FailureMessage(
                failure,
              ),
              _ => const SizedBox.shrink(),
            },
          ],
        );
      },
    );
  }
}

class _FailureMessage extends StatelessWidget {
  const _FailureMessage(this.failure);

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (title, body) = switch (failure) {
      NetworkFailure() => (l10n.failureNetworkTitle, l10n.failureNetworkBody),
      UnauthorizedFailure() => (
        l10n.failureUnauthorizedTitle,
        l10n.failureUnauthorizedBody,
      ),
      NotFoundFailure() => (
        l10n.failureNotFoundTitle,
        l10n.failureNotFoundBody,
      ),
      ValidationFailure() => (
        l10n.failureValidationTitle,
        l10n.failureValidationBody,
      ),
      ServerFailure() => (l10n.failureServerTitle, l10n.failureServerBody),
      CacheFailure() => (l10n.failureCacheTitle, l10n.failureCacheBody),
      UnexpectedFailure() => (
        l10n.failureUnexpectedTitle,
        l10n.failureUnexpectedBody,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(title, style: context.text.title),
        _Label(body, ink: AppTypographyInk.meta),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) =>
      Wrap(spacing: AppSpace.s8, runSpacing: AppSpace.s8, children: children);
}

/// Text in the type role [style] (body by default) and ink step [ink].
class _Label extends StatelessWidget {
  const _Label(this.text, {this.style, this.ink = AppTypographyInk.strong});

  final String text;
  final TextStyle? style;
  final int ink;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: (style ?? context.text.body).copyWith(
      color: context.surface.ink(ink),
    ),
  );
}

/// A raised surface the user can press; [selected] paints `selectedFill`.
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Pressable(
    onPressed: onPressed,
    pressedScale: _buttonPressedScale,
    semanticLabel: label,
    child: TactileSurface(
      kind: SurfaceKind.raised,
      radius: AppRadius.controlAll,
      child: Builder(
        builder: (context) => DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? context.surface.selectedFill : null,
            borderRadius: AppRadius.controlAll,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: context.sizes.control),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s16,
                vertical: AppSpace.s8,
              ),
              child: Center(
                widthFactor: 1,
                child: _Label(label, style: context.text.label),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
