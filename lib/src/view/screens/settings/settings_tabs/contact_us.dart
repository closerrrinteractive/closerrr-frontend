import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../controller/routing/routing_controller.dart';
import '../../../../controller/user_information/user_info_controller.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  @override
  Widget build(BuildContext context) {
    UserInformationController uiController = Get.find();

    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        leading: Container(),
        leadingWidth: 0,
        toolbarHeight: 8.h,
        surfaceTintColor: transparentColor,
        elevation: 12,
        backgroundColor: whiteColor,
        shadowColor: blueBack.withOpacity(0.1),
        title: Row(
          children: [
            InkWell(
              onTap: () => RouterController.current.pop(),
              overlayColor: const WidgetStatePropertyAll(transparentColor),
              child: Image(
                image: const AssetImage(
                  backIcon,
                ),
                height: 5.5.h,
              ),
            ),
            SizedBox(width: 1.5.w),
            Text(
              'Contact Us',
              style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                color: primaryColor,
                fontSize: (widthScale * kTextFormFactor) * 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Circe',
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: (uiController.userData.value['role_id'] == 2)
              ? fanContactUs()
              : influencerContactUs(),
        ),
      ),
    );
  }

  Widget fanContactUs() {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Need Help?',
          style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
            color: blueBack,
            fontSize: (widthScale * kTextFormFactor) * 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Hellix',
          ),
        ),
        SizedBox(height: 2.5.h),
        RichText(
          text: TextSpan(
            text: 'Before Reaching Out, Please Take A Moment To Check Out Our ',
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '''FAQs''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  color: blueBack,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  height: 1.4,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    print('dsflkhdsj');
                    RouterController.current
                        .pushNamed('contact_us_faqs_and_about');
                  },
              ),
              TextSpan(
                text: '''.''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              TextSpan(
                text:
                    ''' You Might Find The Answers You’re Looking For There.''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.5.h),
        RichText(
          text: TextSpan(
            text:
                'If You Still Have Questions Or Need Further Help, Feel Free To Email Us Anytime At: ',
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: '''hello@closerrr.com''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blueBack,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.5.h),
        RichText(
          text: TextSpan(
            text: 'We Usually Respond Within ',
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text: '''24 Hours''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blueBack,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: ''', So We Appreciate Your Patience!''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.5.h),
        Text(
          'Connect. Get Closerrr.',
          style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
            color: blueBack,
            fontSize: (widthScale * kTextFormFactor) * 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Hellix',
          ),
        ),
        SizedBox(height: 2.5.h),
        RichText(
          text: TextSpan(
            text:
                '''Are You A Creator Looking To Connect More Personally With The Ones Who Care?''',
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '''     Explore More At: ''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '''www.closerrr.com''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blueBack,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget influencerContactUs() {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "We're Here For You!",
          style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
            color: blueBack,
            fontSize: (widthScale * kTextFormFactor) * 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Hellix',
          ),
        ),
        SizedBox(height: 2.5.h),
        RichText(
          text: TextSpan(
            text:
                "Whether It's A Question, Some Feedback, Or Something That Needs Fixing",
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '''.''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              TextSpan(
                text:
                    ''' You Have A Direct Line To Our Team. Just Drop Us An   Email At: ''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              TextSpan(
                text: '''creatorcare@closerrr.com''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blueBack,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.5.h),
        RichText(
          text: TextSpan(
            text:
                "We're currently A Small, Passionate Team Building This Platform Right Alongside You.",
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            children: [
              TextSpan(
                text:
                    '''While That Means We Can't Always Promise An instant Reply, We Can Promise That''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text:
                    '''Your Message Goes Straight To The Top Of Our List. You Are At The Very Heart''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text:
                    '''Of The Closerrr Community, And Supporting You Is Our Most Important Job.''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            text:
                '''Thank You For Your Patience And For Being A Beloved Part Of Closerrr.''',
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.5.h),
        Text(
          'Need Something Faster?',
          style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
            color: blueBack,
            fontSize: (widthScale * kTextFormFactor) * 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Hellix',
          ),
        ),
        SizedBox(height: 2.5.h),
        RichText(
          text: TextSpan(
            text: '''While You Wait For Our Personal Reply, You Might''',
            style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
              fontFamily: 'Hellix',
              color: blackColor,
              fontSize: (widthScale * kTextFormFactor) * 15,
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(
                text: '''Find A Fast Answer In Our Growing Library Of ''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blackColor,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: '''Creator FAQs''',
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  fontFamily: 'Hellix',
                  color: blueBack,
                  fontSize: (widthScale * kTextFormFactor) * 15,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    print('dsflkhdsj');
                    RouterController.current
                        .pushNamed('contact_us_creator_faq');
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
