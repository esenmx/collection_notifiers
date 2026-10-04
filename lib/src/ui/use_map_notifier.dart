part of '../../collection_notifiers.dart';

/// Creates a [MapNotifier] tied to the widget lifecycle.
///
/// The notifier is constructed once on first build, disposed on unmount,
/// and listened to so the host widget rebuilds when the map mutates.
///
/// [initial] is consumed **once** on first build. Pass [keys] to
/// dispose the notifier and create a fresh one from the current
/// [initial] whenever a key changes (compared like `useMemoized` keys),
/// or re-key the host widget.
///
/// See also: [MapNotifier], the underlying reactive map.
///
/// ```dart
/// class SettingsPage extends HookWidget {
///   const SettingsPage({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final settings = useMapNotifier<String, bool>({'darkMode': false});
///     return SwitchListTile(
///       value: settings['darkMode'] ?? false,
///       onChanged: (v) => settings['darkMode'] = v,
///       title: const Text('Dark mode'),
///     );
///   }
/// }
/// ```
MapNotifier<K, V> useMapNotifier<K, V>([
  Map<K, V> initial = const {},
  List<Object?>? keys,
]) {
  return use(_MapNotifierHook<K, V>(initial, keys));
}

class const _MapNotifierHook<K, V>(
  final Map<K, V> initial, [
  List<Object?>? keys,
]) extends Hook<MapNotifier<K, V>> {
  this : super(keys: keys);

  @override
  _MapNotifierHookState<K, V> createState() => _MapNotifierHookState<K, V>();
}

class _MapNotifierHookState<K, V>
    extends HookState<MapNotifier<K, V>, _MapNotifierHook<K, V>> {
  late final MapNotifier<K, V> _notifier = MapNotifier<K, V>(hook.initial);

  void _listener() {
    setState(() {});
  }

  @override
  void initHook() {
    super.initHook();
    _notifier.addListener(_listener);
  }

  @override
  MapNotifier<K, V> build(BuildContext context) => _notifier;

  @override
  void dispose() {
    _notifier
      ..removeListener(_listener)
      ..dispose();
  }

  @override
  String get debugLabel => 'useMapNotifier<$K, $V>';
}
