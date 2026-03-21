import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/event_controllers/event_controller.dart';
import 'package:closerrr/src/controller/routing/routing_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/models/events/upcoming_events_response.dart';
import 'package:closerrr/src/models/explore/get_influencer_response.dart';
import 'package:closerrr/src/view/popup/event/delete_popup.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_popup_btn.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/constant_string.dart';

class CreateEvents extends StatefulWidget {
  const CreateEvents({
    super.key,
    required this.profile,
    this.event,
    this.isEdit,
    this.isChat,
  });
  final Profile profile;
  final Events? event;
  final bool? isEdit;
  final bool? isChat;

  @override
  State<CreateEvents> createState() => _CreateEventsState();
}

class _CreateEventsState extends State<CreateEvents> {
  final nameController = TextEditingController();
  final venueController = TextEditingController();
  final eventDetailsController = TextEditingController();
  final poster = XFile('').obs;
  final userInfoController = Get.find<UserInformationController>();
  final eventController = Get.find<EventScreenController>();
  final dateAndTime = DateTime.now().obs;
  final editEvent = false.obs;
  final imageUrl = ''.obs;

  @override
  void initState() {
    super.initState();
    eventController.isCreating.value = false;
    if (widget.isEdit ?? false) {
      // Case: Editing existing event
      nameController.text = widget.event!.name;
      venueController.text = widget.event!.venue;
      eventDetailsController.text = widget.event?.details ?? '';
      dateAndTime.value = widget.event!.time;
      editEvent.value = false; // start in read-only mode
      imageUrl.value = widget.event?.image ?? '';
    } else {
      // Case: Creating new event
      editEvent.value = true; // start editable
      dateAndTime.value = eventController.selectedDate.value;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final widthScale = MediaQuery.of(ctx).size.width / kDesignWidth;
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            color: whiteColor,
          ),
          child: Obx(() => Column(
                children: <Widget>[
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          RouterController.current.goNamed(
                            widget.isChat ?? false
                                ? "chat_create_image_preview_screen"
                                : 'create_image_preview_screen',
                            extra: {
                              'eventPoster': widget.event != null
                                  ? widget.event!.image
                                  : poster.value.path,
                              'friend': widget.profile,
                            },
                          );
                        },
                        child: SizedBox(
                          height: 56.h,
                          width: 100.w,
                          child: Hero(
                            tag: 'eventPoster',
                            child: imageUrl.value.isEmpty ||
                                    imageUrl.value == ''
                                ? Image.file(
                                    File(poster.value.path),
                                    width: double.maxFinite,
                                    height: 38.h,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return SizedBox(
                                        width: 80,
                                        height: 100,
                                        child: Image.asset(
                                          Constants.eventImage,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  )
                                : CachedNetworkImage(
                                    imageUrl: imageUrl.value,
                                    fit: BoxFit.cover,
                                    height: 56.h,
                                    width: double.maxFinite,
                                    errorWidget: (context, url, error) =>
                                        SizedBox(
                                      child: Image.asset(
                                        Constants.eventImage,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2.h,
                        top: 6.h,
                        child: InkWell(
                          onTap: () => ctx.pop(),
                          child: Image(
                            image: const AssetImage(crossIcon),
                            height: 3.h,
                          ),
                        ),
                      ),
                      if (editEvent.value)
                        Positioned(
                          bottom: 2.h,
                          right: 2.h,
                          child: InkWell(
                            onTap: () => showDialog(
                                context: context,
                                builder: (_) =>
                                    _buildImagePicker(widthScale, _)),
                            child: Image.asset(
                              editPngIcon,
                              height: 4.h,
                            ),
                          ),
                        )
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildEventField(
                    label: 'Name',
                    hintText: 'Enter the name of the event here',
                    controller: nameController,
                    readOnly: !editEvent.value,
                  ),
                  _buildEventField(
                    label: 'Date & Time',
                    hintText: 'Enter date & time of the event',
                    controller: TextEditingController(),
                    readOnly: !editEvent.value,
                  ),
                  _buildEventField(
                    label:
                        'Venue', // Change from the backend vanue is not required
                    hintText: 'Event Venue of the event',
                    controller: venueController,
                    readOnly: !editEvent.value,
                  ),
                  _buildEventField(
                    label: 'Event Details (Optional)',
                    hintText: 'Enter Event Details',
                    controller: eventDetailsController,
                    isBold: false,
                    readOnly: !editEvent.value,
                  ),
                  Center(
                    child: Text(
                      "by- ${userInfoController.userData.value['Profile']['fullname'] ?? userInfoController.userData.value['Profile']['username'] ?? ''}",
                      style:
                          CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                        color: primaryColor,
                        fontSize: (widthScale * kTextFormFactor) * 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Hellix',
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  (widget.isEdit ?? false)
                      ? (!editEvent.value
                          ? _buildEditDeleteButtons(widthScale)
                          : _buildSaveButton(widthScale))
                      : _buildSaveButton(widthScale),
                  SizedBox(height: 2.h)
                ],
              )),
        ),
      ),
    );
  }

  AlertDialog _buildImagePicker(double widthScale, BuildContext ctx) {
    return AlertDialog(
      backgroundColor: popColor,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Choose Option",
          style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
            color: primaryColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          InkWell(
            overlayColor: const WidgetStatePropertyAll(transparentColor),
            onTap: () {
              ImagePicker()
                  .pickImage(
                source: ImageSource.gallery,
                imageQuality: 50,
                maxHeight: 1080,
                maxWidth: 1920,
              )
                  .then((value) {
                if (value != null) {
                  poster.value = value;
                  Navigator.pop(ctx);
                }
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  selectImage,
                  height: 7.h,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Gallery',
                  style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                    color: primaryColor,
                    fontSize: (widthScale * kTextFormFactor) * 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            overlayColor: const WidgetStatePropertyAll(transparentColor),
            onTap: () {
              ImagePicker()
                  .pickImage(
                source: ImageSource.camera,
                imageQuality: 50,
                maxHeight: 1080,
                maxWidth: 1920,
              )
                  .then((value) {
                if (value != null) {
                  poster.value = value;
                  Navigator.pop(ctx);
                }
              });
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: headingColor.withOpacity(0.2),
                    ),
                    borderRadius: BorderRadius.circular(26),
                    color: whiteColor,
                  ),
                  child: Icon(
                    Icons.camera,
                    color: primaryColor,
                    size: 4.h,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Camera',
                  style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                    color: primaryColor,
                    fontSize: (widthScale * kTextFormFactor) * 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildEventField({
    required String label,
    required TextEditingController controller,
    bool isBold = false,
    String? hintText,
    bool readOnly = false,
  }) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return Obx(() {
      dateAndTime.value;
      return Container(
        decoration: BoxDecoration(
          color: whiteColor,
          border: Border(
            bottom: BorderSide(width: 1, color: Colors.grey.shade200),
          ),
        ),
        width: double.maxFinite,
        margin: EdgeInsets.only(left: 3.h, right: 3.h, bottom: 1.5.h),
        padding: EdgeInsets.only(bottom: 1.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 3.w),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  fontSize: (widthScale * kTextFormFactor) * 14,
                  color: primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (label.contains('Date & Time')) ...{
              GestureDetector(
                onTap: editEvent.value || (widget.isEdit ?? false) == false
                    ? () async {
                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime:
                              TimeOfDay.fromDateTime(dateAndTime.value),
                        );
                        if (pickedTime != null) {
                          final newDateTime = DateTime(
                            dateAndTime.value.year,
                            dateAndTime.value.month,
                            dateAndTime.value.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          dateAndTime.value = newDateTime;
                        }
                      }
                    : null,
                child: Padding(
                  padding: EdgeInsets.only(left: 3.w, top: 1.5.h, bottom: 1.h),
                  child: Text(
                    DateFormat('dd, MMMM yyyy | hh:mm a')
                        .format(dateAndTime.value),
                    style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                      fontSize: (widthScale * kTextFormFactor) * 17,
                      color: const Color(0xFF120D26),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            } else ...{
              CustomTextFormField(
                controller: controller,
                style: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  fontSize: (widthScale * kTextFormFactor) * 17,
                  fontWeight: hintText!.contains('Event Details')
                      ? FontWeight.w500
                      : FontWeight.bold,
                  color: Colors.black,
                ),
                fieldReadOnly: readOnly,
                borderColor: whiteColor,
                hintText: hintText,
                hintStyle: CustomTextStyle.styledTextWidget.bodyLarge!.copyWith(
                  fontSize: (widthScale * kTextFormFactor) * 17,
                  color: const Color(0xFF120D26).withAlpha(200),
                  fontWeight: hintText.contains('Event Details')
                      ? FontWeight.w500
                      : FontWeight.bold,
                ),
              )
            },
          ],
        ),
      );
    });
  }

  Widget _buildSaveButton(double widthScale) {
    return CustomButton(
      buttonTitle: 'SAVE EVENT',
      backButtonColor: primaryColor,
      titleStyle: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
        color: whiteColor,
        fontSize: (widthScale * kTextFormFactor) * 15,
        letterSpacing: 1,
      ),
      onlyText: true,
      isLoading: eventController.isCreating.value,
      loadingColor: whiteColor,
      onPress: () => _saveOrUpdateEvent(),
      width: 50.w,
      height: 5.h,
    );
  }

  Widget _buildEditDeleteButtons(double widthScale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomButton(
          buttonTitle: 'EDIT EVENT',
          width: 40.w,
          height: 5.h,
          backButtonColor: primaryColor,
          titleStyle: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
            color: whiteColor,
            fontSize: (widthScale * kTextFormFactor) * 12,
            letterSpacing: 1,
          ),
          onlyText: true,
          isLoading: eventController.isCreating.value,
          loadingColor: whiteColor,
          onPress: () => editEvent.value = !editEvent.value,
        ),
        CustomButton(
          buttonTitle: 'DELETE EVENT',
          width: 40.w,
          height: 5.h,
          backButtonColor: logOutColor,
          titleStyle: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
            color: whiteColor,
            fontSize: (widthScale * kTextFormFactor) * 12,
            letterSpacing: 1,
          ),
          onlyText: true,
          isLoading: eventController.isCreating.value,
          loadingColor: whiteColor,
          onPress: () {
            showDialog(
              context: context,
              builder: (context) => DeletePopup(
                delete: _deleteEvent,
              ),
            );
            // _deleteEvent();
          },
        ),
      ],
    );  
  }

  Future<bool> _validateInputs() async {
    if (nameController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter event name');
      return false;
    }
    if (poster.value.path.isEmpty && widget.event?.image == null) {
      Fluttertoast.showToast(msg: 'Please select poster');
      return false;
    }
    if (venueController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter Venue');
      return false;
    }
    if (dateAndTime.value.isAtSameMomentAs(DateTime.now())) {
      Fluttertoast.showToast(msg: 'Please select date and time');
      return false;
    }

    return true;
  }

  Future<void> _deleteEvent() async {
    await eventController
        .deleteEvent(
      id: widget.event!.id.toString(),
    )
        .then((success) {
      Get.back();
      if (success) _showSuccessDialog(msg: 'Event Deleted successfully');
      eventController.isCreating.value = false;
    });
  }

  Future<void> _saveOrUpdateEvent() async {
    if (!await _validateInputs()) return;

    eventController.isCreating.value = true;

    final eventData = {
      "name": nameController.text,
      "time": dateAndTime.value,
      if (venueController.text.isNotEmpty) "venue": venueController.text,
      if (eventDetailsController.text.isNotEmpty)
        "details": eventDetailsController.text,
      if (poster.value.path.isNotEmpty)
        "image": await dio.MultipartFile.fromFile(
          poster.value.path,
          filename: poster.value.path.split('/').last,
        ),
    };

    Map data = userInfoController.userData.value;
    final userId = data['id'].toString();
    // Map profile = data["profile"];

    if (editEvent.value && widget.isEdit != null) {
      await eventController
          .editEvent(
        event: eventData,
        id: userId,
        eventId: widget.event!.id.toString(),
      )
          .then((success) {
        if (success) _showSuccessDialog(msg: 'Event edited successfully');
        eventController.isCreating.value = false;
      });
    } else {
      await eventController
          .addEvent(
        event: eventData,
        id: userId,
      )
          .then((success) {
        if (success) _showSuccessDialog(msg: 'Event Created Successfully');
        eventController.isCreating.value = false;
      });
    }
  }

  void _showSuccessDialog({required String msg}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset('assets/svg/message_sent_icon.svg', height: 64),
            const SizedBox(height: 16),
            PopupCustomBtn(
              isActions: true,
              title: msg, // title: editEvent.value
              //     ? "Event edited successfully"
              //     : 'Event Created Successfully',
              ontap: () {
                Navigator.pop(ctx);
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
