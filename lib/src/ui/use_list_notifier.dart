part of '../../collection_notifiers.dart';

/// Creates a [ListNotifier] tied to the widget lifecycle.
///
/// The notifier is constructed once on first build, disposed on unmount,
/// and listened to so the host widget rebuilds when the list mutates.
///
/// [initial] is consumed **once** on first build. Passing a different
/// iterable on a later rebuild has no effect — the notifier was already
/// constructed. To reset on a dependency change, scope the host widget
/// under a different `key` so the hook re-mounts.
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

class _ListNotifierHook<E> extends Hook<ListNotifier<E>> {
  const _ListNotifierHook(
    this.initial, [
    List<Object?>? keys,
  ]) : super(keys: keys);

  final Iterable<E> initial;

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
