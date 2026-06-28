import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/models/events/upcoming_events_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../../core/utils/constant.dart';

class CalendarWidget extends StatefulWidget {
  final int friendId;
  const CalendarWidget({super.key, required this.friendId});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  static const bool useNewMonthYearPicker = true;

  final selectedMonth = 0.obs;
  final selectedYear = 0.obs;

  final _selectedDate = DateTime.now().obs;
  final _focusedDay = DateTime.now().obs;

  final EventScreenController eventController = Get.find();

  final DateTime firstDay = DateTime.utc(2020, 1, 1);
  final DateTime lastDay = DateTime.utc(2100, 12, 31);

  final List<String> year = List.generate(81, (index) {
    return (2020 + index).toString();
  });

  @override
  initState() {
    super.initState();
    final mon = DateFormat('MMMM').format(DateTime.now());
    selectedMonth.value = month.indexOf(mon);
    selectedYear.value = year.indexOf(DateTime.now().year.toString());
    if (selectedYear.value == -1) {
      selectedYear.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Obx(() {
      return Container(
        padding: EdgeInsets.all(2.w),
        margin: EdgeInsets.symmetric(horizontal: 2.h),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E5EF), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFFE5E5EF),
              offset: Offset(0, 4),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            if (useNewMonthYearPicker)
              _buildNewMonthYearPicker(context, widthScale)
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                    dropdownColor: whiteColor,
                    underline: Container(),
                    borderRadius: BorderRadius.circular(15),
                    elevation: 2,
                    iconSize: 0,
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: primaryColor.withAlpha(100),
                    ),
                    style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                      color: primaryColor,
                      fontSize: (widthScale * kTextFormFactor) * 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Circe',
                    ),
                    value: selectedMonth.value,
                    alignment: Alignment.bottomCenter,
                    onChanged: (value) {
                      selectedMonth.value = value ?? 0;
                      _updateFocusedDay(month: selectedMonth.value + 1);
                    },
                    menuMaxHeight: 50.h,
                    items: [
                      ...List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index,
                          alignment: Alignment.center,
                          child: Container(
                            width: 80.w,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: index == selectedMonth.value
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              month[index],
                              style: CustomTextStyle.styledTextWidget.bodyLarge!
                                  .copyWith(
                                color: index == selectedMonth.value
                                    ? whiteColor
                                    : blackColor,
                                fontSize: (widthScale * kTextFormFactor) * 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                    selectedItemBuilder: (context) => [
                      ...List.generate(
                        12,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(
                            month[index],
                            style: CustomTextStyle.styledTextWidget.bodyLarge!
                                .copyWith(
                              color: primaryColor,
                              fontSize: (widthScale * kTextFormFactor) * 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: primaryColor.withAlpha(100),
                  ),
                  SizedBox(width: 6.w),
                  DropdownButton(
                    dropdownColor: whiteColor,
                    underline: Container(),
                    borderRadius: BorderRadius.circular(15),
                    elevation: 2,
                    iconSize: 0,
                    icon: Icon(
                      Icons.keyboard_arrow_down_outlined,
                      color: primaryColor.withAlpha(100),
                    ),
                    style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                      color: primaryColor,
                      fontSize: (widthScale * kTextFormFactor) * 18,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Circe',
                    ),
                    value: selectedYear.value,
                    menuMaxHeight: 50.h,
                    menuWidth: 26.w,
                    onChanged: (value) {
                      selectedYear.value = value!;
                      _updateFocusedDay(
                          year: int.parse(year[selectedYear.value]));
                    },
                    isDense: true,
                    padding: EdgeInsets.zero,
                    items: [
                      ...List.generate(
                        year.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Container(
                            width: 80.w,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: index == selectedYear.value
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              year[index],
                              style: CustomTextStyle.styledTextWidget.bodyLarge!
                                  .copyWith(
                                color: index == selectedYear.value
                                    ? whiteColor
                                    : blackColor,
                                fontSize: (widthScale * kTextFormFactor) * 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                    selectedItemBuilder: (context) => [
                      ...List.generate(
                        year.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text(
                            year[index],
                            style: CustomTextStyle.styledTextWidget.bodyLarge!
                                .copyWith(
                              color: primaryColor,
                              fontSize: (widthScale * kTextFormFactor) * 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_outlined,
                    color: primaryColor.withAlpha(100),
                  ),
                ],
              ),
            const Divider(color: dividerColor, thickness: 1),
            TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: _focusedDay.value,
              currentDay: _selectedDate.value,
              rowHeight: 48,
              startingDayOfWeek: StartingDayOfWeek.monday,
              daysOfWeekStyle: DaysOfWeekStyle(
                dowTextFormatter: (date, locale) {
                  return DateFormat.E(locale).format(date).substring(0, 2);
                },
                weekdayStyle:
                    CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  color: const Color(0xFF9291A5),
                  fontSize: (widthScale * kTextFormFactor) * 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Hellix',
                ),
                weekendStyle:
                    CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  color: const Color(0xFF9291A5),
                  fontSize: (widthScale * kTextFormFactor) * 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Hellix',
                ),
              ),
              weekNumbersVisible: false,
              onDaySelected: (selectedDay, focusedDay) {
                HapticHelper.trigger(type: HapticFeedbackType.light);
                _selectedDate.value = selectedDay;
                _focusedDay.value = focusedDay;
                eventController.selectedDate.value = selectedDay;
                eventController.isLoading.value = true;
                eventController.getUpcomingFriendEvents(
                  friendId: widget.friendId,
                  page: 1,
                  limit: 50,
                  date: DateFormat('yyyy-MM-dd').format(focusedDay),
                );
              },
              eventLoader: (day) => _getEventsForDay(day).isEmpty
                  ? <Events>[]
                  : [_getEventsForDay(day).first],
              daysOfWeekHeight: 6.h,
              headerVisible: false,
              onPageChanged: (focusedDay) {
                HapticHelper.trigger(type: HapticFeedbackType.light);
                _focusedDay.value = focusedDay;
                selectedYear.value = year.indexOf(focusedDay.year.toString());
                selectedMonth.value = focusedDay.month - 1;
                eventController.getUpcomingFriendEvents(
                  friendId: widget.friendId,
                  page: 1,
                  limit: 50,
                  date: DateFormat('yyyy-MM-dd').format(focusedDay),
                  isMonth: true,
                );
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: const BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                todayDecoration: BoxDecoration(
                  color: _selectedDate.value.day == DateTime.now().day
                      ? whiteColor
                      : primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selectedDate.value.day == DateTime.now().day
                        ? primaryColor
                        : Colors.transparent,
                  ),
                ),
                todayTextStyle: TextStyle(
                  color: _selectedDate.value.day == DateTime.now().day
                      ? null
                      : whiteColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                markerDecoration: const BoxDecoration(
                  color: blueBack,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _updateFocusedDay({int? year, int? month}) {
    final newYear = year ?? _focusedDay.value.year;
    final newMonth = month ?? _focusedDay.value.month;
    final newDay = _focusedDay.value.day;

    final newFocusedDay = DateTime(newYear, newMonth, newDay);

    if (newFocusedDay.isAfter(firstDay) && newFocusedDay.isBefore(lastDay)) {
      _focusedDay.value = newFocusedDay;
    } else {
      _focusedDay.value = newFocusedDay.isBefore(firstDay) ? firstDay : lastDay;
    }
  }

  List<Events> _getEventsForDay(DateTime day) {
    final events = eventController.friendMonthEvents
        .where((event) =>
            event.time.year == day.year &&
            event.time.month == day.month &&
            event.time.day == day.day)
        .toList();
    return events;
  }

  void _goToPreviousMonth() {
    final currentFocus = _focusedDay.value;
    final int prevYear = currentFocus.month == 1 ? currentFocus.year - 1 : currentFocus.year;
    final int prevMonth = currentFocus.month == 1 ? 12 : currentFocus.month - 1;
    
    if (prevYear > 2020 || (prevYear == 2020 && prevMonth >= 1)) {
      final DateTime targetDate = DateTime(prevYear, prevMonth, 1);
      _focusedDay.value = targetDate;
      selectedMonth.value = prevMonth - 1;
      final yearIndex = year.indexOf(prevYear.toString());
      if (yearIndex != -1) {
        selectedYear.value = yearIndex;
      }
      
      eventController.getUpcomingFriendEvents(
        friendId: widget.friendId,
        page: 1,
        limit: 50,
        date: DateFormat('yyyy-MM-dd').format(targetDate),
        isMonth: true,
      );
    }
  }

  void _goToNextMonth() {
    final currentFocus = _focusedDay.value;
    final int nextYear = currentFocus.month == 12 ? currentFocus.year + 1 : currentFocus.year;
    final int nextMonth = currentFocus.month == 12 ? 1 : currentFocus.month + 1;
    
    if (nextYear < 2100 || (nextYear == 2100 && nextMonth <= 12)) {
      final DateTime targetDate = DateTime(nextYear, nextMonth, 1);
      _focusedDay.value = targetDate;
      selectedMonth.value = nextMonth - 1;
      final yearIndex = year.indexOf(nextYear.toString());
      if (yearIndex != -1) {
        selectedYear.value = yearIndex;
      }
      
      eventController.getUpcomingFriendEvents(
        friendId: widget.friendId,
        page: 1,
        limit: 50,
        date: DateFormat('yyyy-MM-dd').format(targetDate),
        isMonth: true,
      );
    }
  }

  Widget _buildNewMonthYearPicker(BuildContext context, double widthScale) {
    final currentFocus = _focusedDay.value;
    final bool isLeftInactive = currentFocus.year == 2020 && currentFocus.month == 1;
    final bool isRightInactive = currentFocus.year == 2100 && currentFocus.month == 12;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.chevron_left_rounded,
              color: isLeftInactive ? primaryColor.withOpacity(0.3) : primaryColor,
              size: 28,
            ),
            onPressed: isLeftInactive
                ? null
                : () {
                    HapticHelper.trigger(type: HapticFeedbackType.light);
                    _goToPreviousMonth();
                  },
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              HapticHelper.trigger(type: HapticFeedbackType.light);
              _showMonthYearPicker(context, widthScale);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${month[selectedMonth.value]}, ${year[selectedYear.value]}",
                    style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                      color: primaryColor,
                      fontSize: (widthScale * kTextFormFactor) * 16,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Hellix',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: primaryColor.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.chevron_right_rounded,
              color: isRightInactive ? primaryColor.withOpacity(0.3) : primaryColor,
              size: 28,
            ),
            onPressed: isRightInactive
                ? null
                : () {
                    HapticHelper.trigger(type: HapticFeedbackType.light);
                    _goToNextMonth();
                  },
          ),
        ],
      ),
    );
  }

  void _showMonthYearPicker(BuildContext context, double widthScale) {
    int tempMonth = selectedMonth.value;
    int tempYearVal = selectedYear.value;

    showModalBottomSheet(
      context: context,
      backgroundColor: whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 40.h,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: Colors.grey[600],
                            fontSize: (widthScale * kTextFormFactor) * 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Select Month & Year',
                        style: TextStyle(
                          fontFamily: 'Hellix',
                          color: headingColor,
                          fontSize: (widthScale * kTextFormFactor) * 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticHelper.trigger(type: HapticFeedbackType.light);
                          selectedMonth.value = tempMonth;
                          selectedYear.value = tempYearVal;
                          _updateFocusedDay(
                            year: int.parse(year[tempYearVal]),
                            month: tempMonth + 1,
                          );
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Done',
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: primaryColor,
                            fontSize: (widthScale * kTextFormFactor) * 15,
                            fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: dividerColor),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left_rounded,
                        color: tempYearVal > 0
                            ? primaryColor
                            : primaryColor.withOpacity(0.3),
                        size: 28,
                      ),
                      onPressed: tempYearVal > 0
                          ? () {
                              HapticHelper.trigger(type: HapticFeedbackType.light);
                              setState(() {
                                tempYearVal--;
                              });
                            }
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      year[tempYearVal],
                      style: TextStyle(
                        fontFamily: 'Hellix',
                        color: primaryColor,
                        fontSize: (widthScale * kTextFormFactor) * 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        Icons.chevron_right_rounded,
                        color: tempYearVal < year.length - 1
                            ? primaryColor
                            : primaryColor.withOpacity(0.3),
                        size: 28,
                      ),
                      onPressed: tempYearVal < year.length - 1
                          ? () {
                              HapticHelper.trigger(type: HapticFeedbackType.light);
                              setState(() {
                                tempYearVal++;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final isSelected = tempMonth == index;
                      final String shortMonth = month[index].length > 3
                          ? month[index].substring(0, 3)
                          : month[index];
                      return GestureDetector(
                        onTap: () {
                          HapticHelper.trigger(type: HapticFeedbackType.light);
                          setState(() {
                            tempMonth = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : primaryColor.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : primaryColor.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            shortMonth,
                            style: TextStyle(
                              fontFamily: 'Hellix',
                              color: isSelected ? whiteColor : primaryColor,
                              fontSize: (widthScale * kTextFormFactor) * 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
}
