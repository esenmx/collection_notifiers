part of '../../collection_notifiers.dart';

/// Creates a [QueueNotifier] tied to the widget lifecycle.
///
/// The notifier is constructed once on first build, disposed on unmount,
/// and listened to so the host widget rebuilds when the queue mutates.
///
/// [initial] is consumed **once** on first build. Passing a different
/// iterable on a later rebuild has no effect — the notifier was already
/// constructed. To reset on a dependency change, scope the host widget
/// under a different `key` so the hook re-mounts.
///
/// See also: [QueueNotifier], the underlying reactive queue.
///
/// ```dart
/// class JobQueueView extends HookWidget {
///   const JobQueueView({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final jobs = useQueueNotifier<String>();
///     return Column(
///       children: [
///         FilledButton(
///           onPressed: () => jobs.addLast('Job ${jobs.length + 1}'),
///           child: const Text('Enqueue'),
///         ),
///         for (final j in jobs) Text(j),
///       ],
///     );
///   }
/// }
/// ```
QueueNotifier<E> useQueueNotifier<E>([
  Iterable<E> initial = const [],
  List<Object?>? keys,
]) {
  return use(_QueueNotifierHook<E>(initial, keys));
}

class _QueueNotifierHook<E> extends Hook<QueueNotifier<E>> {
  const _QueueNotifierHook(
    this.initial, [
    List<Object?>? keys,
  ]) : super(keys: keys);

  final Iterable<E> initial;

  @override
  _QueueNotifierHookState<E> createState() => _QueueNotifierHookState<E>();
}

class _QueueNotifierHookState<E>
    extends HookState<QueueNotifier<E>, _QueueNotifierHook<E>> {
  late final QueueNotifier<E> _notifier = QueueNotifier<E>(hook.initial);

  void _listener() {
    setState(() {});
  }

  @override
  void initHook() {
    super.initHook();
    _notifier.addListener(_listener);
  }

  @override
  QueueNotifier<E> build(BuildContext context) => _notifier;

  @override
  void dispose() {
    _notifier
      ..removeListener(_listener)
      ..dispose();
  }

  @override
  String get debugLabel => 'useQueueNotifier<$E>';
}
