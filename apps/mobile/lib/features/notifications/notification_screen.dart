import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/provider/notification_provider.dart';
import '../../models/nav_args.dart';
import '../../l10n/app_localizations.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const NotificationScreen({super.key, this.embedded = false});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  String? _filter = 'info';
  bool _inited = false;

  final ScrollController _scroll = ScrollController();

  int _displayCount = 10;
  static const int _pageSize = 10;

  String _norm(String? s) => (s ?? '').trim().toLowerCase();

  String? _sanitizeFilter(String? raw) {
    final k = _norm(raw);
    if (k.isEmpty || k == 'all') return null;
    if (k == 'info' || k == 'warning' || k == 'urgent') return k;
    return 'info';
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _resetScroll() {
    if (_scroll.hasClients) {
      _scroll.jumpTo(0);
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;

    if (_scroll.position.atEdge && _scroll.position.pixels != 0) {
      if (_displayCount < _currentListLength()) {
        setState(() {
          _displayCount += _pageSize;
        });
      }
    }
  }

  int _currentListLength() {
    final eff = _sanitizeFilter(_filter);
    final list = ref.read(filteredNotificationProvider(eff));
    return list.length;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    final fromArgs = (args is NotificationRouteArgs)
        ? args.initialFilter
        : null;

    _filter = _sanitizeFilter(fromArgs) ?? 'info';
    _inited = true;
  }

  IconData _icon(String? levelRaw) {
    switch (_norm(levelRaw)) {
      case 'urgent':
        return Icons.dangerous_outlined;
      case 'warning':
        return Icons.warning_amber_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  Color _accent(String? levelRaw) {
    switch (_norm(levelRaw)) {
      case 'urgent':
        return const Color(0xFFE53935);
      case 'warning':
        return const Color(0xFFFFB300);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String _ago(DateTime t, AppLocalizations l10n) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l10n.notificationJustNow;
    if (d.inMinutes < 60) return l10n.notificationMinutesAgo(d.inMinutes);
    if (d.inHours < 24) return l10n.notificationHoursAgo(d.inHours);
    return l10n.notificationDaysAgo(d.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final eff = _sanitizeFilter(_filter);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final all = ref.watch(notificationListProvider);
    List<NotificationItem> list = ref.watch(filteredNotificationProvider(eff));

    if (eff != null) {
      final key = _norm(eff);
      list = list.where((n) => _norm(n.level) == key).toList();
    }

    final notifier = ref.read(notificationListProvider.notifier);

    final displayList = list.take(_displayCount).toList();
    final hasMore = list.length > _displayCount;

    int countLevel(String lvl) =>
        all.where((e) => _norm(e.level) == _norm(lvl) && !e.isRead).length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        primary: !widget.embedded,
        title: Text(
          l10n.notificationTitle,
          style: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: .2,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.primary),
            onSelected: (v) async {
              switch (v) {
                case 'read':
                  notifier.markAllRead();
                  _resetScroll();
                  break;
                case 'delete':
                  notifier.clearAll();
                  _resetScroll();
                  break;
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(value: 'read', child: Text(l10n.notificationMarkAllRead)),
              PopupMenuItem(value: 'delete', child: Text(l10n.notificationDeleteAll)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          notifier.markAllRead();
          _resetScroll();
        },
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        child: Scrollbar(
          controller: _scroll,
          thumbVisibility: true,
          interactive: true,
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 20),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _Glass(
                  colorScheme: colorScheme,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: _FilterChips(
                    value: eff,
                    colorScheme: colorScheme,
                    l10n: l10n,
                    onChanged: (newKey) {
                      setState(() {
                        _filter = _sanitizeFilter(newKey);
                        _displayCount = _pageSize;
                      });
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _resetScroll(),
                      );
                    },
                    infoCount: countLevel('info'),
                    warningCount: countLevel('warning'),
                    urgentCount: countLevel('urgent'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (displayList.isEmpty)
                _EmptyState(
                  colorScheme: colorScheme,
                  l10n: l10n,
                  onExploreAll: () => setState(() => _filter = null),
                )
              else ...[
                ...displayList.map(
                  (n) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _NotificationCard(
                      title: n.title,
                      message: n.message,
                      meta:
                          '${n.kitName ?? "Unknown Kit"} • ${_ago(n.timestamp, l10n)}',
                      icon: _icon(n.level),
                      accent: _accent(n.level),
                      isRead: n.isRead,
                      colorScheme: colorScheme,
                      newLabel: l10n.notificationNew,
                      onTap: () {
                        notifier.markRead(n.id);
                        Navigator.pushNamed(
                          context,
                          '/history',
                          arguments: HistoryRouteArgs(
                            targetTime: n.timestamp,
                            kitName: n.kitName,
                            kitId: n.kitName,
                            reason: n.message,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (hasMore)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        l10n.notificationScrollMore,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  const _Glass({this.child, this.padding, this.borderRadius = 14, required this.colorScheme});
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: colorScheme.surface.withValues(alpha: 0.7)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.value,
    required this.onChanged,
    required this.infoCount,
    required this.warningCount,
    required this.urgentCount,
    required this.colorScheme,
    required this.l10n,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final int infoCount;
  final int warningCount;
  final int urgentCount;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  String _cap(int n) => n > 9 ? '9+' : '$n';

  @override
  Widget build(BuildContext context) {
    final items = <({String label, String? key, IconData? icon, int? count})>[
      (label: l10n.commonAll, key: null, icon: null, count: null),
      (
        label: l10n.notificationFilterInfo,
        key: 'info',
        icon: Icons.campaign_rounded,
        count: infoCount,
      ),
      (
        label: l10n.notificationFilterWarning,
        key: 'warning',
        icon: Icons.warning_amber_rounded,
        count: warningCount,
      ),
      (
        label: l10n.notificationFilterUrgent,
        key: 'urgent',
        icon: Icons.dangerous_outlined,
        count: urgentCount,
      ),
    ];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: items.map((it) {
        final selected = value == it.key;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: _ChipBtn(
            label: it.label,
            selected: selected,
            icon: it.icon,
            badge: it.count == null ? null : _cap(it.count!),
            colorScheme: colorScheme,
            onTap: () => onChanged(it.key),
          ),
        );
      }).toList(),
    );
  }
}

class _ChipBtn extends StatelessWidget {
  const _ChipBtn({
    required this.label,
    required this.selected,
    this.icon,
    this.badge,
    required this.onTap,
    required this.colorScheme,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final String? badge;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
      shape: StadiumBorder(
        side: BorderSide(
          color: (selected ? colorScheme.onPrimary : colorScheme.primary).withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    icon,
                    size: 16,
                    color: selected ? colorScheme.onPrimary : colorScheme.primary,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  color: selected ? colorScheme.onPrimary : colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                _CountBadge(value: badge!, selected: selected, colorScheme: colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.value, required this.selected, required this.colorScheme});
  final String value;
  final bool selected;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: selected ? colorScheme.onPrimary.withValues(alpha: 0.2) : colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? colorScheme.onPrimary.withValues(alpha: 0.5)
              : colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: selected ? colorScheme.onPrimary : colorScheme.primary,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onExploreAll, required this.colorScheme, required this.l10n});
  final VoidCallback onExploreAll;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded, size: 72, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              l10n.notificationEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.notificationEmptyDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onExploreAll,
              icon: const Icon(Icons.all_inclusive_rounded),
              label: Text(l10n.notificationShowAll),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.message,
    required this.meta,
    required this.icon,
    required this.accent,
    required this.isRead,
    required this.onTap,
    required this.colorScheme,
    required this.newLabel,
  });

  final String title;
  final String message;
  final String meta;
  final IconData icon;
  final Color accent;
  final bool isRead;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final String newLabel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 16,
              color: Colors.black.withValues(alpha: 0.06),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 96,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 12, 14, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBadge(icon: icon, color: accent),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 120,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: isRead ? 0 : 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(99),
                                  border: Border.all(
                                    color: accent.withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  newLabel,
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(fontSize: 14.5, height: 1.35, color: colorScheme.onSurface),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              meta,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.18), color.withValues(alpha: 0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}
