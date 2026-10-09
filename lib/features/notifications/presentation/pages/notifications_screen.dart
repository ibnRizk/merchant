import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/locale/locale_cubit.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/realtime/realtime_event.dart';
import '../../../../core/utils/values/app_colors.dart';
import '../../../../core/utils/values/strings.dart';
import '../../../../core/widgets/back_title_bar.dart';
import '../../../../core/widgets/brand_snack_bar.dart';
import '../../../../core/widgets/load_more_footer.dart';
import '../../../../core/widgets/realtime_listener.dart';
import '../../../../core/widgets/status_views.dart';
import '../../domain/entities/app_notification.dart';
import '../cubit/notifications/notifications_cubit.dart';
import '../utils/notification_display.dart';
import '../widgets/notification_tile.dart';
import '../widgets/notifications_list_states.dart';

/// The notification inbox, grouped by day, newest first. Reached from the
/// home bell or a push tap; [NotificationsCubit] is provided by the route.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  /// How close to the end of the list the next page starts loading.
  static const double _loadMoreThreshold = 400;

  static const EdgeInsets _gutter = EdgeInsets.symmetric(horizontal: 20);

  final ScrollController _scrollController = ScrollController();

  NotificationsCubit get _cubit => context.read<NotificationsCubit>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < _loadMoreThreshold) {
      _cubit.loadMore();
    }
  }

  void _open(AppNotification notification) {
    _cubit.markAsRead(notification);
    final int? orderId = notification.orderId;
    if (orderId != null) {
      context.pushNamed(
        AppRoutes.orderDetailsName,
        pathParameters: <String, String>{'id': '$orderId'},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Labels come from the global `Strings.*.tr`, so a language switch has
    // to rebuild this screen for them to refresh.
    context.watch<LocaleCubit>();

    return Scaffold(
      backgroundColor: context.colors.background,
      body: BlocListener<NotificationsCubit, NotificationsState>(
        listenWhen: (NotificationsState previous, NotificationsState current) =>
            current is NotificationsLoaded &&
            current.notice != null &&
            !identical(
              previous is NotificationsLoaded ? previous.notice : null,
              current.notice,
            ),
        listener: (BuildContext context, NotificationsState state) =>
            showBrandSnackBar(
              context,
              (state as NotificationsLoaded).notice!.message,
              isError: true,
            ),
        child: RealtimeListener(
          when: (RealtimeEvent event) => event.affectsNotifications,
          onEvent: _cubit.poll,
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: _cubit.refresh,
              color: context.colors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    sliver: SliverToBoxAdapter(
                      child: BackTitleBar(
                        title: Strings.notificationsTitle,
                        trailing: const _MarkAllReadButton(),
                      ),
                    ),
                  ),
                  BlocBuilder<NotificationsCubit, NotificationsState>(
                    builder: _buildList,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, NotificationsState state) {
    return switch (state) {
      NotificationsLoading() => const SliverPadding(
        padding: _gutter,
        sliver: SliverToBoxAdapter(child: NotificationsLoadingView()),
      ),
      NotificationsLoadFailure(:final message) => SliverPadding(
        padding: _gutter,
        sliver: SliverToBoxAdapter(
          child: RetryErrorView(message: message, onRetry: _cubit.load),
        ),
      ),
      NotificationsLoaded(:final items) when items.isEmpty =>
        const SliverToBoxAdapter(child: NotificationsEmptyView()),
      NotificationsLoaded() => _buildEntries(state),
    };
  }

  Widget _buildEntries(NotificationsLoaded state) {
    final List<_Entry> entries = _Entry.group(state.items, DateTime.now());
    return SliverPadding(
      padding: _gutter.copyWith(bottom: 24),
      sliver: SliverList.builder(
        // One extra slot for the pagination footer.
        itemCount: entries.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == entries.length) {
            return LoadMoreFooter(
              hasMore: state.hasMore,
              isLoadingMore: state.isLoadingMore,
              loadMoreFailed: state.loadMoreFailed,
              onLoadMore: () => _cubit.loadMore(retry: true),
            );
          }
          return switch (entries[index]) {
            _HeaderEntry(:final NotificationSection section) =>
              NotificationsSectionHeader(label: section.label),
            _TileEntry(
              :final AppNotification notification,
              :final NotificationSection section,
            ) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NotificationTile(
                  key: ValueKey<String>(notification.id),
                  notification: notification,
                  section: section,
                  onTap: () => _open(notification),
                ),
              ),
          };
        },
      ),
    );
  }
}

/// A flat row of the grouped list: a day header or a notification.
sealed class _Entry {
  const _Entry();

  /// The list is newest first, so each section starts where the previous
  /// one ends.
  static List<_Entry> group(List<AppNotification> items, DateTime now) {
    final List<_Entry> entries = <_Entry>[];
    NotificationSection? current;
    for (final AppNotification notification in items) {
      final NotificationSection section = NotificationSection.of(
        notification.createdAt,
        now,
      );
      if (section != current) {
        entries.add(_HeaderEntry(section));
        current = section;
      }
      entries.add(_TileEntry(notification, section));
    }
    return entries;
  }
}

final class _HeaderEntry extends _Entry {
  final NotificationSection section;

  const _HeaderEntry(this.section);
}

final class _TileEntry extends _Entry {
  final AppNotification notification;
  final NotificationSection section;

  const _TileEntry(this.notification, this.section);
}

class _MarkAllReadButton extends StatelessWidget {
  const _MarkAllReadButton();

  @override
  Widget build(BuildContext context) {
    final AppColors colors = context.colors;
    return BlocSelector<
      NotificationsCubit,
      NotificationsState,
      ({bool enabled, bool busy})
    >(
      selector: (NotificationsState state) => state is NotificationsLoaded
          ? (
              enabled: state.hasUnread && !state.isMarkingAllRead,
              busy: state.isMarkingAllRead,
            )
          : (enabled: false, busy: false),
      // Capped so a long translation or a large text scale ellipsizes the
      // label instead of squeezing the title out.
      builder: (BuildContext context, ({bool enabled, bool busy}) view) =>
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: TextButton.icon(
              onPressed: view.enabled
                  ? context.read<NotificationsCubit>().markAllAsRead
                  : null,
              icon: view.busy
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.primary,
                      ),
                    )
                  : const Icon(Icons.done_all_rounded, size: 18),
              label: Text(
                Strings.markAllRead,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: colors.primary,
                disabledForegroundColor: colors.textSecondary.withValues(
                  alpha: 0.5,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
    );
  }
}
