part of '../../collection_notifiers.dart';

/// Creates a [ListNotifier] tied to the widget lifecycle.
///
/// The notifier is constructed once on first build, disposed on unmount,
/// and listened to so the host widget rebuilds when the list mutates.
///
/// [initial] is consumed **once** on first build. Pass [keys] to
/// dispose the notifier and create a fresh one from the current
/// [initial] whenever a key changes (compared like `useMemoized` keys),
/// or re-key the host widget.
///
/// See also: [ListNotifier], the underlying reactive list.
///
/// ```dart
/// class TodoList extends HookWidget {
///   const TodoList({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final todos = useListNotifier<String>(['Buy milk']);
///     return Column(
///       children: [
///         FilledButton(
///           onPressed: () => todos.add('New'),
///           child: const Text('Add'),
///         ),
///         for (final t in todos) Text(t),
///       ],
///     );
///   }
/// }
/// ```
ListNotifier<E> useListNotifier<E>([
  Iterable<E> initial = const [],
  List<Object?>? keys,
]) {
  return use(_ListNotifierHook<E>(initial, keys));
}

class const _ListNotifierHook<E>(
  final Iterable<E> initial, [
  List<Object?>? keys,
]) extends Hook<ListNotifier<E>> {
  this : super(keys: keys);

  @override
  _ListNotifierHookState<E> createState() => _ListNotifierHookState<E>();
}

class _ListNotifierHookState<E>
    extends HookState<ListNotifier<E>, _ListNotifierHook<E>> {
  late final ListNotifier<E> _notifier = ListNotifier<E>(hook.initial);

  void _listener() {
    setState(() {});
  }

  @override
  void initHook() {
    super.initHook();
    _notifier.addListener(_listener);
  }

  @override
  ListNotifier<E> build(BuildContext context) => _notifier;

  @override
  void dispose() {
    _notifier
      ..removeListener(_listener)
      ..dispose();
  }

  @override
  String get debugLabel => 'useListNotifier<$E>';
}
