class HistoryRouteArgs {
  final DateTime? targetTime;
  final String? kitName;
  final String? kitId;
  final String? reason;

  const HistoryRouteArgs({
    this.targetTime,
    this.kitName,
    this.kitId,
    this.reason,
  });
}

class NotificationRouteArgs {
  final String? initialFilter;
  const NotificationRouteArgs({this.initialFilter});
}
