import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';
import 'package:closerrr/src/controller/settings_controller/settings_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class MyPayouts extends StatefulWidget {
  const MyPayouts({super.key});

  @override
  State<MyPayouts> createState() => _MyPayoutsState();
}

class _MyPayoutsState extends State<MyPayouts> {
  final settingController = Get.find<SettingScreenController>();

  @override
  void initState() {
    super.initState();

    settingController.getPayoutUpcommingDetails();
    settingController.getBeneficiaryDetail();
    settingController.getTranscationHistory(
      limit: 5,
      startDate: '',
      endDate: '',
      page: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: ChatAppBar(
        isChatSetting: true,
        chatTitle: "My Payouts",
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAwaitPayouts(context),
          SizedBox(height: 2.h),
          _buildPayoutInformations(),
          SizedBox(height: 2.h),
          _buildBankAccount(),
          SizedBox(height: 2.h),
          _buildPayoutHistory(),
        ],
      ),
    );
  }

  _buildPayoutHistory() {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Obx(() {
      final transactions = settingController.transcations.value?.data.rows;
      return Container(
        width: 100.w,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payout History',
              style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                color: primaryColor,
                fontSize: widthScale * kTextFormFactor * 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 1.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => const Divider(),
              itemCount: transactions?.length ?? 1,
              itemBuilder: (context, index) {
                final history = transactions?[index];

                Color statusColor = success;
                String statusIcon = checkIcon;
                bool showDate = true;
                switch ((history?.status ?? 'SUCCESS').toUpperCase()) {
                  case 'SUCCESS':
                    statusColor = success;
                    statusIcon = checkIcon;
                    break;
                  case 'FAILED':
                    statusColor = failed;
                    statusIcon = failedIcon;
                    showDate = false;
                  case 'ERROR':
                    statusColor = failed;
                    statusIcon = failedIcon;
                    showDate = false;
                    break;
                  case 'PENDING':
                    statusColor = processing;
                    statusIcon = processingIcon;
                    showDate = false;
                    break;
                  case 'REVERSED':
                    statusColor = failed;
                    statusIcon = failedIcon;
                    showDate = false;
                    break;
                  default:
                    statusColor = processing;
                    statusIcon = processingIcon;
                    showDate = false;
                }

                return Column(
                  children: [
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        SvgPicture.asset(
                          statusIcon,
                          height: 28,
                          width: 28,
                        ),
                        SizedBox(width: 2.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "₹${NumberFormat('#,##0', 'hi_IN').format(double.parse(history?.transferAmount ?? '0').toInt())}",
                              style: CustomTextStyle.styledTextWidget.bodySmall
                                  ?.copyWith(
                                color: blueBack,
                                fontSize: widthScale * kTextFormFactor * 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              DateFormat('MMMM yyyy')
                                  .format(history?.payoutFor ?? DateTime.now()),
                              style: CustomTextStyle.styledTextWidget.bodySmall
                                  ?.copyWith(
                                color: Colors.black,
                                fontSize: widthScale * kTextFormFactor * 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  history?.status ?? 'SUCCESS',
                                  style: CustomTextStyle
                                      .styledTextWidget.bodySmall
                                      ?.copyWith(
                                    color: statusColor,
                                    fontSize: widthScale * kTextFormFactor * 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            if (showDate)
                              Text(
                                DateFormat('dd MMM yyyy').format(
                                    history?.payoutDate ?? DateTime.now()),
                                style: CustomTextStyle
                                    .styledTextWidget.bodySmall
                                    ?.copyWith(
                                  color: Colors.black,
                                  fontSize: widthScale * kTextFormFactor * 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: .5.h),
                  ],
                );
              },
            ),
            const Divider(),
            SizedBox(height: 2.h),
            Container(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  RouterController.current.goNamed("dashboard_and_analytics");
                },
                child: Text(
                  "View All Payouts →",
                  style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                    color: primaryColor,
                    fontSize: widthScale * kTextFormFactor * 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
          ],
        ),
      );
    });
  }

  _buildBankAccount() {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Obx(() {
      final beneficiaryDetails = settingController.beneficiaryDetail.value;
      return Container(
        width: 100.w,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bank Account',
              style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                color: primaryColor,
                fontSize: widthScale * kTextFormFactor * 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              width: 100.w,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: payoutBack,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficiaryDetails?.data.beneficiaryName ?? "--",
                        style: CustomTextStyle.styledTextWidget.bodySmall
                            ?.copyWith(
                          color: blueBack,
                          fontSize: widthScale * kTextFormFactor * 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: .5.h),
                      Text(
                        beneficiaryDetails?.data.bankAccountNumber ?? "--",
                        style: CustomTextStyle.styledTextWidget.bodySmall
                            ?.copyWith(
                          color: primaryColor,
                          fontSize: widthScale * kTextFormFactor * 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: .5.h),
                      Text(
                        beneficiaryDetails?.data.bankIfsc ?? "--",
                        style: CustomTextStyle.styledTextWidget.bodySmall
                            ?.copyWith(
                          color: primaryColor,
                          fontSize: widthScale * kTextFormFactor * 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3F3),
                          border: Border.all(
                            // color: failed,
                            color: success,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              color: success,
                              size: 3.w,
                            ),
                            // SvgPicture.asset(
                            //   // errorIcon,
                            //   checkIcon,
                            //   width: 3.w,
                            //   height: 3.w,
                            // ),
                            SizedBox(width: 1.w),
                            Text(
                              // "Verification Failed",
                              "Verified",
                              style: CustomTextStyle.styledTextWidget.bodySmall
                                  ?.copyWith(
                                // color: failed,
                                color: success,
                                fontSize: widthScale * kTextFormFactor * 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SvgPicture.asset(
                      trashIcons,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 2.h),
            CustomButton(
              height: 6.h,
              buttonTitle: 'ADD NEW ACCOUNT',
              backButtonColor: primaryColor,
              isTextStyle: true,
              onlyText: false,
              textColor: whiteColor,
              preffixIcon: Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: SvgPicture.asset(
                  addBankAccount,
                  color: whiteColor,
                ),
              ),
              onPress: () {
                context.goNamed("add_bank_account");
              },
            ),
            SizedBox(height: 2.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: blueBack,
                  size: 24,
                ),
                SizedBox(width: 2.w),
                SizedBox(
                  width: 70.w,
                  child: Text(
                    "To receive your payouts smoothly and on schedule, please add your bank account.",
                    style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                      color: blueBack,
                      fontSize: widthScale * kTextFormFactor * 14,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    });
  }

  Container _buildPayoutInformations() {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Container(
      width: 100.w,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 2),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payout Information',
            style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
              color: primaryColor,
              fontSize: widthScale * kTextFormFactor * 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Explore how your payouts are calculated, when they\'re released, how payout tiers work, and what banking policies apply.',
            style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
              color: Colors.black,
              fontSize: widthScale * kTextFormFactor * 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          CustomButton(
            height: 6.h,
            buttonTitle: 'LEARN MORE',
            backButtonColor: primaryColor,
            isTextStyle: true,
            onlyText: false,
            textColor: whiteColor,
            onPress: () {
              context.goNamed("payout_informations");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAwaitPayouts(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;

    return Obx(() {
      final data = settingController.payoutUpcomming.value?.data;
      final payoutDate =
          DateFormat('MMM yy').format(data?.payoutDate ?? DateTime.now());
      final payoutFor =
          DateFormat('MMM yyyy').format(data?.payoutDate ?? DateTime.now());
      return Container(
        width: 100.w,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              offset: const Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data != null
                  ? 'Payout For: $payoutFor'
                  : 'Awaiting Your First Payout...',
              style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
                color: primaryColor,
                fontSize: widthScale * kTextFormFactor * 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              '₹${data?.totalAmount ?? '--'}',
              style: CustomTextStyle.styledTextWidget.titleLarge?.copyWith(
                color: blueBack,
                fontSize: widthScale * kTextFormFactor * 40,
              ),
            ),
            Text(
              "From ${data?.activeSubscribers} active subscribers",
              style: CustomTextStyle.styledTextWidget.labelSmall?.copyWith(
                color: Colors.black,
                fontSize: widthScale * kTextFormFactor * 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.5.h),
            Container(
              width: 100.w,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: payoutBack,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem(
                    label: 'Growth Rate',
                    value: data?.growthRate != null
                        ? "+${(data?.growthRate ?? '--').split('.').first}%"
                        : '--',
                    widthScale: widthScale,
                  ),
                  _statItem(
                    label: 'Tier',
                    value: (data?.tier ?? '--').toString(),
                    widthScale: widthScale,
                  ),
                  _statItem(
                    label: 'Payout Date',
                    value: (payoutDate).toString(),
                    widthScale: widthScale,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _statItem({
    required String label,
    required String value,
    required double widthScale,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: CustomTextStyle.styledTextWidget.titleLarge?.copyWith(
            color: blueBack,
            fontFamily: 'Hellix',
            fontSize: widthScale * kTextFormFactor * 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: CustomTextStyle.styledTextWidget.titleMedium?.copyWith(
            color: primaryColor,
            fontFamily: 'Hellix',
            fontSize: widthScale * kTextFormFactor * 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
