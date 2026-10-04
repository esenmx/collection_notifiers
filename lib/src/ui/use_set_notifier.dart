part of '../../collection_notifiers.dart';

/// Creates a [SetNotifier] tied to the widget lifecycle.
///
/// The notifier is constructed once on first build, disposed on unmount,
/// and listened to so the host widget rebuilds when the set mutates.
///
/// [initial] is consumed **once** on first build. Pass [keys] to
/// dispose the notifier and create a fresh one from the current
/// [initial] whenever a key changes (compared like `useMemoized` keys),
/// or re-key the host widget.
///
/// See also: [SetNotifier], the underlying reactive set.
///
/// ```dart
/// class FilterChips extends HookWidget {
///   const FilterChips({super.key, required this.tags});
///
///   final List<String> tags;
///
///   @override
///   Widget build(BuildContext context) {
///     final selected = useSetNotifier<String>();
///     return Wrap(
///       children: [
///         for (final tag in tags)
///           FilterChip(
///             label: Text(tag),
///             selected: selected.contains(tag),
///             onSelected: (_) => selected.invert(tag),
///           ),
///       ],
///     );
///   }
/// }
/// ```
SetNotifier<E> useSetNotifier<E>([
  Iterable<E> initial = const [],
  List<Object?>? keys,
]) {
  return use(_SetNotifierHook<E>(initial, keys));
}

class const _SetNotifierHook<E>(
  final Iterable<E> initial, [
  List<Object?>? keys,
]) extends Hook<SetNotifier<E>> {
  this : super(keys: keys);

  @override
  _SetNotifierHookState<E> createState() => _SetNotifierHookState<E>();
}

class _SetNotifierHookState<E>
    extends HookState<SetNotifier<E>, _SetNotifierHook<E>> {
  late final SetNotifier<E> _notifier = SetNotifier<E>(hook.initial);

  void _listener() {
    setState(() {});
  }

  @override
  void initHook() {
    super.initHook();
    _notifier.addListener(_listener);
  }

  @override
  SetNotifier<E> build(BuildContext context) => _notifier;

  @override
  void dispose() {
    _notifier
      ..removeListener(_listener)
      ..dispose();
  }

  @override
  String get debugLabel => 'useSetNotifier<$E>';
}
