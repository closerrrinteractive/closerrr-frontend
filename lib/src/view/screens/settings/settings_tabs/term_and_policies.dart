import 'package:closerrr/core/themes/text_style.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/img_string.dart';
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
            SizedBox(width: 1.w),
            Text(
              widget.title,
              style: CustomTextStyle.styledTextWidget.bodyLarge?.copyWith(
                color: primaryColor,
                fontSize: (widthScale * kTextFormFactor) * 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Circe',
              ),
            ),
            SizedBox(width: 1.w),
          ],
        ),
      ),
      body: SfPdfViewer.network(
        widget.path,
        enableDoubleTapZooming: true,
        canShowPageLoadingIndicator: true,
        pageLayoutMode: PdfPageLayoutMode.continuous,
      ),
    );
  }
}
