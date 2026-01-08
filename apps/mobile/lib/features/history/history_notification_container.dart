import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'history_screen.dart';
import '../notifications/notification_screen.dart';

// Match color scheme from other screens
const Color _kPrimary = Color(0xFF0E5A2A);
const Color _kBg = Color(0xFFF3F9F4);

/// Container that wraps History and Notification screens in a PageView
/// with swipe navigation and dot indicators.
class HistoryNotificationContainer extends ConsumerStatefulWidget {
  final String? kitId;
  final DateTime? targetTime;
  final int initialPage;

  const HistoryNotificationContainer({
    super.key,
    this.kitId,
    this.targetTime,
    this.initialPage = 0, // 0 = History, 1 = Notification
  });

  @override
  ConsumerState<HistoryNotificationContainer> createState() =>
      _HistoryNotificationContainerState();
}

class _HistoryNotificationContainerState
    extends ConsumerState<HistoryNotificationContainer> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Dot indicator at top (compact, only 8px padding)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_buildDot(0), const SizedBox(width: 8), _buildDot(1)],
              ),
            ),
            // PageView with History and Notification content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  // Page 0: History Screen (embedded - no SafeArea)
                  HistoryScreen(
                    kitId: widget.kitId,
                    targetTime: widget.targetTime,
                    embedded: true,
                  ),
                  // Page 1: Notification Screen (embedded - no SafeArea)
                  const NotificationScreen(
                    embedded: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = _currentPage == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isActive ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? _kPrimary : _kPrimary.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
