import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:sizer/sizer.dart';

class DashboardAndAnalytics extends StatefulWidget {
  const DashboardAndAnalytics({super.key});

  @override
  State<DashboardAndAnalytics> createState() => _DashboardAndAnalyticsState();
}

class _DashboardAndAnalyticsState extends State<DashboardAndAnalytics> {
  // Controllers
  late final SettingScreenController _settingController;
  late final UserInformationController _userInfoController;

  final totalPayoutAndroid = 0.obs;
  final totalPayoutIos = 0.obs;
  final totalSubscriberAndroid = 0.obs;
  final totalSubscriberIos = 0.obs;

  // Constants
  static const List<String> _timePeriods = [
    'Last Month',
    'Last Payout Month',
    'Lifetime',
    'Custom'
  ];

  // State variables
  final RxString _selectedPeriod = 'Lifetime'.obs;
  final Rx<DateTime> _fromDate = DateTime.now().obs;
  final Rx<DateTime> _toDate = DateTime.now().obs;
  late final DateTime _userCreatedAt;

  // Cached formatters
  late final DateFormat _dateFormatter;
  late final double _widthScale;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    _settingController = SettingScreenController();
    _userInfoController = Get.find<UserInformationController>();
  }

  void _initializeData() {
    _dateFormatter = DateFormat('MMM dd, yyyy');
    _userCreatedAt =
        DateTime.parse(_userInfoController.userData.value['createdAt']);
    _setStartAndEndDate(_selectedPeriod.value);
    _getAnalytics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _widthScale = MediaQuery.of(context).size.width / kDesignWidth;
  }

  Future<void> _getAnalytics() async {
    await _settingController.getTranscationHistory(
      limit: 5,
      startDate: '',
      endDate: '',
      page: 1,
    );

    final analytics = _settingController.transcations.value?.data.rows;

    analytics?.forEach((element) {
      final androidAmount =
          int.tryParse(element.androidAmount.split('.').first) ?? 0;
      final iosAmount = int.tryParse(element.iosAmount.split('.').first) ?? 0;
      totalPayoutAndroid.value += androidAmount;
      totalPayoutIos.value += iosAmount;
      totalSubscriberAndroid.value += element.androidSubscribers;
      totalSubscriberIos.value += element.iosSubscribers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: ChatAppBar(
        isChatSetting: true,
        chatTitle: "All Payouts",
      ),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimePeriodDropdown(),
          const SizedBox(height: 16),
          _buildDateRangeSelector(),
          SizedBox(height: 4.h),
          Obx(() {
            return _buildAnalyticsSection();
          }),
        ],
      ),
    );
  }

  Widget _buildTimePeriodDropdown() {
    return DropdownButton2<String>(
      value: _selectedPeriod.value,
      isDense: true,
      underline: const SizedBox.shrink(),
      dropdownStyleData: DropdownStyleData(
        width: 55.w,
        scrollPadding: EdgeInsets.zero,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: whiteColor,
        ),
        elevation: 2,
        offset: Offset.zero,
      ),
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_outlined,
          color: primaryColor.withAlpha(100),
        ),
      ),
      buttonStyleData: const ButtonStyleData(
        overlayColor: WidgetStatePropertyAll(transparentColor),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide.none),
        ),
      ),
      alignment: Alignment.centerLeft,
      onChanged: _onPeriodChanged,
      items: _buildDropdownItems(),
      customButton: _buildDropdownButton(),
    );
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return _timePeriods.map((period) {
      final isSelected = period == _selectedPeriod.value;
      return DropdownMenuItem<String>(
        value: period,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            period,
            style: _getDropdownItemTextStyle(isSelected),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildDropdownButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _selectedPeriod.value,
            style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
              color: primaryColor,
              fontSize: (18 * kTextFormFactor) * _widthScale,
              fontWeight: FontWeight.w900,
              fontFamily: 'Circe',
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_outlined,
            color: primaryColor.withAlpha(100),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 2,
          color: const Color(0xFF7A02FA).withAlpha(100),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(
            calenderIcon,
            height: 16,
            colorFilter: ColorFilter.mode(
              primaryColor.withAlpha(140),
              BlendMode.srcIn,
            ),
          ),
          _buildDateLabel('From'),
          _buildDateSelector(
            date: _fromDate,
            isFromDate: true,
          ),
          _buildDateLabel('To'),
          _buildDateSelector(
            date: _toDate,
            isFromDate: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel(String label) {
    return Text(
      label,
      style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
        color: blueBack.withAlpha(140),
        fontSize: (15 * kTextFormFactor) * _widthScale,
      ),
    );
  }

  Widget _buildDateSelector({
    required Rx<DateTime> date,
    required bool isFromDate,
  }) {
    return GestureDetector(
      onTap: () => _showMonthYearPicker(date),
      child: Row(
        children: [
          Obx(() => Text(
                _dateFormatter.format(date.value),
                style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  color: primaryColor,
                  fontSize: (14 * kTextFormFactor) * _widthScale,
                  fontWeight: FontWeight.bold,
                ),
              )),
          SizedBox(width: 1.5.w),
          SvgPicture.asset(
            dropArrowDown,
            colorFilter: const ColorFilter.mode(
              expansionBackgroundColor,
              BlendMode.srcIn,
            ),
            height: 10,
          ),
        ],
      ),
    );
  }

  Future<void> _showMonthYearPicker(Rx<DateTime> dateToUpdate) async {
    final selectedDate = await showMonthYearPicker(
      context: context,
      initialDate: dateToUpdate.value,
      locale: const Locale('en'),
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (selectedDate != null) {
      _selectedPeriod.value = 'Custom';

      // Start date = first day of selected month
      _fromDate.value = DateTime(selectedDate.year, selectedDate.month, 1);

      // End date = last day of selected month
      _toDate.value = DateTime(selectedDate.year, selectedDate.month + 1, 0);

      final startDate = DateFormat('yyyy-MM-dd').format(_fromDate.value);
      final endDate = DateFormat('yyyy-MM-dd').format(_toDate.value);

      await _settingController.getTranscationHistory(
        limit: 10,
        page: 1,
        startDate: startDate,
        endDate: endDate,
      );

      // Recalculate totals after fetching
      _calculateTotals();
    }
  }

  void _calculateTotals() {
    final analytics = _settingController.transcations.value?.data.rows;

    totalPayoutAndroid.value = 0;
    totalPayoutIos.value = 0;
    totalSubscriberAndroid.value = 0;
    totalSubscriberIos.value = 0;

    analytics?.forEach((element) {
      final androidAmount = double.tryParse(element.androidAmount) ?? 0;
      final iosAmount = double.tryParse(element.iosAmount) ?? 0;
      totalPayoutAndroid.value += androidAmount.toInt();
      totalPayoutIos.value += iosAmount.toInt();
      totalSubscriberAndroid.value += element.androidSubscribers;
      totalSubscriberIos.value += element.iosSubscribers;
    });
  }

  void _onPeriodChanged(String? value) async {
    if (value == null) return;

    _selectedPeriod.value = value;
    _setStartAndEndDate(value);

    final startDate = DateFormat('yyyy-MM-dd').format(_fromDate.value);
    final endDate = DateFormat('yyyy-MM-dd').format(_toDate.value);

    // Clear existing totals
    totalPayoutAndroid.value = 0;
    totalPayoutIos.value = 0;
    totalSubscriberAndroid.value = 0;
    totalSubscriberIos.value = 0;

    await _settingController.getTranscationHistory(
      limit: 10,
      page: 1,
      startDate: startDate,
      endDate: endDate,
    );

    _calculateTotals();
  }

  void _setStartAndEndDate(String period) {
    final now = DateTime.now();

    switch (period) {
      case 'Last Month':
        _fromDate.value = DateTime(now.year, now.month - 1, 1);
        _toDate.value = DateTime(now.year, now.month, 0);
        break;
      case 'Last Payout Month':
        if (DateTime.now().day > 25) {
          _fromDate.value = DateTime(now.year, now.month - 2, 1);
          _toDate.value = DateTime(now.year, now.month - 1, 0);
        } else {
          _fromDate.value = DateTime(now.year, now.month - 3, 1);
          _toDate.value = DateTime(now.year, now.month - 2, 0);
        }
        break;
      case 'Lifetime':
        _fromDate.value = _userCreatedAt;
        _toDate.value = now;
        break;
      case 'Custom':
        break;
    }
  }

  Widget _buildAnalyticsSection() {
    if (_settingController.isTransactionLoading.value) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
              child: CircularProgressIndicator(
            color: primaryColor,
          )),
        ],
      );
    }

    if ((_settingController.transcations.value?.data.rows ?? []).isEmpty) {
      return const Center(child: Text('No Transactions Found'));
    }

    return Column(
      children: [
        _AnalyticsSection(
          title: 'Subscribers',
          items: [
            _AnalyticsItem(
              label: 'Android',
              value: totalSubscriberAndroid.value.toString(),
            ),
            _AnalyticsItem(
              label: 'iOS',
              value: totalSubscriberIos.value.toString(),
            ),
            _AnalyticsItem(
              label: 'Total Subscribers',
              value: (totalSubscriberIos.value + totalSubscriberAndroid.value)
                  .toString(),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        _AnalyticsSection(
          title: 'Payouts',
          items: [
            _AnalyticsItem(
              label: 'Android',
              value:
                  "₹${NumberFormat('#,##0', 'hi_IN').format(totalPayoutAndroid.value)}.00",
            ),
            _AnalyticsItem(
              label: 'iOS',
              value:
                  "₹${NumberFormat('#,##0', 'hi_IN').format(totalPayoutIos.value)}.00",
            ),
            _AnalyticsItem(
              label: 'Total Payouts',
              value:
                  "₹${NumberFormat('#,##0', 'hi_IN').format(totalPayoutIos.value + totalPayoutAndroid.value)}.00",
            ),
          ],
        ),
      ],
    );
  }

  TextStyle _getDropdownItemTextStyle(bool isSelected) {
    return CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
      color: isSelected ? whiteColor : blackColor,
      fontSize: (16 * kTextFormFactor) * _widthScale,
      fontWeight: FontWeight.w600,
    );
  }
}

class _AnalyticsSection extends StatelessWidget {
  final String title;
  final List<_AnalyticsItem> items;

  const _AnalyticsSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
            color: blueBack,
            fontSize: (24 * kTextFormFactor) * widthScale,
            fontWeight: FontWeight.w700,
          ),
        ),
        ...items.map((item) => _buildAnalyticsItem(item, widthScale)),
      ],
    );
  }

  Widget _buildAnalyticsItem(_AnalyticsItem item, double widthScale) {
    final isTotal = item.label.contains('Total');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: dividerColor)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.label,
              style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                color: primaryColor,
                fontSize: (18 * kTextFormFactor) * widthScale,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
            Text(
              item.value,
              style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                color: primaryColor,
                fontSize: (18 * kTextFormFactor) * widthScale,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsItem {
  final String label;
  final String value;

  const _AnalyticsItem({
    required this.label,
    required this.value,
  });
}
