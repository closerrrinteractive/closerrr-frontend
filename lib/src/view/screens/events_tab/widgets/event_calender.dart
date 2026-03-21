import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/models/events/upcoming_events_response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../../core/utils/constant.dart';

class CalendarWidget extends StatefulWidget {
  final int friendId;
  const CalendarWidget({super.key, required this.friendId});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  final selectedMonth = 0.obs;
  final selectedYear = 0.obs;

  final _selectedDate = DateTime.now().obs;
  final _focusedDay = DateTime.now().obs;

  final EventScreenController eventController = Get.find();

  final DateTime firstDay = DateTime.utc(2010, 10, 16);
  final DateTime lastDay = DateTime.utc(2030, 3, 14);

  final List<String> year = List.generate(16, (index) {
    return (DateTime.now().year - 5 + index).toString();
  });

  @override
  initState() {
    super.initState();
    final mon = DateFormat('MMMM').format(DateTime.now());
    selectedMonth.value = month.indexOf(mon);
    selectedYear.value = 5;
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
}
