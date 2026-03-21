import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PayoutInfornmations extends StatefulWidget {
  const PayoutInfornmations({super.key});

  @override
  State<PayoutInfornmations> createState() => _PayoutInfornmationsState();
}

class _PayoutInfornmationsState extends State<PayoutInfornmations> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: ChatAppBar(
        isChatSetting: true,
        chatTitle: "Payout Information",
      ),
      body: SfPdfViewer.asset(
        'assets/pdf/payout_infornmations.pdf',
        enableDoubleTapZooming: true,
        canShowPageLoadingIndicator: true,
        pageLayoutMode: PdfPageLayoutMode.continuous,
      ),
    );
  }
}
