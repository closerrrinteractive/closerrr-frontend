import 'package:closerrr/core/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/img_string.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../controller/routing/routing_controller.dart';

class TermAndPolicies extends StatefulWidget {
  const TermAndPolicies({super.key, required this.title, required this.path});
  final String title;
  final String path;

  @override
  State<TermAndPolicies> createState() => _TermAndPoliciesState();
}

class _TermAndPoliciesState extends State<TermAndPolicies> {
  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticHelper.trigger(type: HapticFeedbackType.light);
                      RouterController.current.pop();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: blackColor.withOpacity(0.08),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(
                            backSvgIcon,
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontFamily: 'Hellix',
                            color: primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: (widthScale * kTextFormFactor) * 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SfPdfViewer.network(
                widget.path,
                enableDoubleTapZooming: true,
                canShowPageLoadingIndicator: true,
                pageLayoutMode: PdfPageLayoutMode.continuous,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
