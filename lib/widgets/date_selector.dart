import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/date_utils.dart';
import '../providers/app_providers.dart';

class DateSelector extends ConsumerStatefulWidget {
  const DateSelector({Key? key}) : super(key: key);

  @override
  ConsumerState<DateSelector> createState() => _DateSelectorState();
}

double? _savedScrollOffset;

class _DateSelectorState extends ConsumerState<DateSelector> {
  late ScrollController _scrollController;
  late double _scrollOffset;
  @override
  void initState() {
    super.initState();
    final selectedDate = ref.read(selectedDateProvider);
    final startDate = DateTime(2026, 6, 11);
    final diff = selectedDate.difference(startDate).inDays;
    final initialOffset = (diff > 0 ? diff : 0) * 80.0; 

    _scrollController = ScrollController(initialScrollOffset: _savedScrollOffset ?? initialOffset);
    _scrollOffset = _savedScrollOffset ?? initialOffset;

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _savedScrollOffset = _scrollController.offset;
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final startDate = DateTime(2026, 6, 11);
    final endDate = DateTime(2026, 7, 19);
    final int totalDays = endDate.difference(startDate).inDays + 1;

    final dates = List.generate(totalDays, (index) {
      return startDate.add(Duration(days: index));
    });

    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final isTodaySelected = AppDateUtils.isToday(selectedDate);
    final int todayIndex = dates.indexWhere((d) => AppDateUtils.isToday(d));

    return SizedBox(
      height: 48,
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isOffLeft = false;
          bool isOffRight = false;

          if (todayIndex != -1) {
            final todayPosStart = todayIndex * 80.0;
            final todayPosEnd = todayPosStart + 80.0;
            if (_scrollOffset >= todayPosEnd) {
              isOffLeft = true;
            }
            if ((_scrollOffset + constraints.maxWidth) <= todayPosStart) {
              isOffRight = true;
            }
          }

          Widget stickyButton({required bool isLeft}) {
            return GestureDetector(
              onTap: () {
                ref.read(selectedDateProvider.notifier).state = todayDate;
                if (todayIndex != -1) {
                  _scrollController.animateTo(
                    todayIndex * 80.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Container(
                width: 56,
                height: double.infinity,
                margin: isLeft ? const EdgeInsets.only(right: 8) : const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isTodaySelected ? AppColors.primary : AppColors.surface,
                  borderRadius: isLeft 
                      ? const BorderRadius.horizontal(right: Radius.circular(24)) 
                      : const BorderRadius.horizontal(left: Radius.circular(24)),
                  border: Border.all(
                    color: isTodaySelected ? AppColors.primary : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: Offset(isLeft ? 2 : -2, 0))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.today,
                      style: TextStyle(
                        color: isTodaySelected ? AppColors.background : AppColors.textSecondary,
                        fontWeight: isTodaySelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${AppDateUtils.formatShortDay(todayDate)} ${AppDateUtils.formatDayNumber(todayDate)}',
                      style: TextStyle(
                        color: isTodaySelected ? AppColors.background : AppColors.textSecondary.withOpacity(0.7),
                        fontWeight: isTodaySelected ? FontWeight.w600 : FontWeight.w400,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = date.year == selectedDate.year &&
                      date.month == selectedDate.month &&
                      date.day == selectedDate.day;
                  
                  final yesterday = now.subtract(const Duration(days: 1));
                  final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;

                  String labelText = '';
                  String subLabelText = '';
                  if (AppDateUtils.isToday(date)) {
                    labelText = AppStrings.today;
                    subLabelText = '${AppDateUtils.formatShortDay(date)} ${AppDateUtils.formatDayNumber(date)}';
                  } else if (isYesterday) {
                    labelText = 'AYER';
                    subLabelText = '${AppDateUtils.formatShortDay(date)} ${AppDateUtils.formatDayNumber(date)}';
                  } else if (AppDateUtils.isTomorrow(date)) {
                    labelText = AppStrings.tomorrow;
                    subLabelText = '${AppDateUtils.formatShortDay(date)} ${AppDateUtils.formatDayNumber(date)}';
                  } else {
                    labelText = '${AppDateUtils.formatShortDay(date)} ${AppDateUtils.formatDayNumber(date)}';
                  }

                  return GestureDetector(
                    onTap: () {
                      ref.read(selectedDateProvider.notifier).state = date;
                    },
                    child: Container(
                      width: 72,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: subLabelText.isEmpty
                          ? Text(
                              labelText,
                              style: TextStyle(
                                color: isSelected ? AppColors.background : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  labelText,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.background : AppColors.textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  subLabelText,
                                  style: TextStyle(
                                    color: isSelected ? AppColors.background : AppColors.textSecondary.withOpacity(0.7),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
              if (isOffLeft)
                Align(
                  alignment: Alignment.centerLeft,
                  child: stickyButton(isLeft: true),
                ),
              if (isOffRight)
                Align(
                  alignment: Alignment.centerRight,
                  child: stickyButton(isLeft: false),
                ),
            ],
          );
        },
      ),
    );
  }
}
