import 'dart:io';

import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/img_string.dart' as Routes;
import 'package:closerrr/src/controller/authentication/verify_otp_controller.dart';
import 'package:closerrr/src/controller/user_information/user_info_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/services/custom_services.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../../core/utils/constant.dart';
import '../../../../../core/utils/img_string.dart';
import '../../../../controller/authentication/auth_controller.dart';
import '../../../../controller/routing/routing_controller.dart';
import 'package:closerrr/core/config/haptic_helper.dart';
import '../../../../controller/settings_controller/settings_controller.dart';
import '../../../popup/setting/delete_account_popup.dart';
import '../../../widgets/custom_widgets/custom_button.dart';
import '../../../widgets/custom_widgets/verify_otp_sheet.dart';

class ManageAccount extends StatefulWidget {
  final Map<String, dynamic> user;
  const ManageAccount({super.key, required this.user});

  @override
  State<ManageAccount> createState() => _ManageAccountState();
}

class _ManageAccountState extends State<ManageAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();
  final UserInformationController uiController = Get.find();
  final VerifyOtpController verifyOtpController = Get.find();
  final SettingScreenController settingScreenController =
      Get.find<SettingScreenController>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController fullnameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  RxString email = ''.obs;
  RxString phoneNo = ''.obs;
  final RxString tempPhoneNo = ''.obs;
  final RxString tempEmail = ''.obs;

  final RxInt genderIndex = 0.obs;

  final RxBool isSomethingChanged = false.obs;

  final Rx<XFile?> profilePic = Rx<XFile?>(null);
  final Map<String, int> gender = {'Male': 0, 'Female': 1, 'Non-binary': 2};

  // Store initial values for comparison
  late String initialUsername;
  late String initialFullname;
  late String initialAddress;
  late String initialDob;
  late int initialGenderIndex;
  late String initialProfilePicPath;

  @override
  void initState() {
    super.initState();
    getDetails();
    fillUserDetails();
    // Set initial values after filling user details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setInitialValues();
    });
  }

  Future<void> getDetails() async {
    // await authController.logout();
    await uiController.getUserData();
  }

  void fillUserDetails() {
    final userProfile = widget.user['Profile'];
    usernameController.text = userProfile?['username'] ?? "";
    fullnameController.text = userProfile?['fullname'] ?? "";
    addressController.text = userProfile?['address'] ?? "";
    dobController.text = userProfile?['birthday'] ?? '';
    settingScreenController.mobileNumberController.text =
        widget.user['mobile'] ?? '';
    settingScreenController.emailController.text = widget.user['email'] ?? "";
    genderIndex.value = gender[userProfile?['gender']] ?? 0;
    profilePic.value =
        XFile(ApiStrings.imageUrl + (userProfile?['profile_pic'] ?? ''));

    tempPhoneNo.value = widget.user['mobile'] ?? '';
    tempEmail.value = widget.user['email'] ?? '';

    email.value = widget.user['email'] ?? '';
    phoneNo.value = widget.user['mobile'] ?? '';
  }

  void setInitialValues() {
    initialUsername = usernameController.text;
    initialFullname = fullnameController.text;
    initialAddress = addressController.text;
    initialDob = dobController.text;
    initialGenderIndex = genderIndex.value;
    initialProfilePicPath = profilePic.value?.path ?? '';
  }

  void checkIfChanged() {
    bool hasChanged = usernameController.text != initialUsername ||
        fullnameController.text != initialFullname ||
        addressController.text != initialAddress ||
        dobController.text != initialDob ||
        genderIndex.value != initialGenderIndex ||
        (profilePic.value?.path ?? '') != initialProfilePicPath;

    isSomethingChanged.value = hasChanged;
  }

  Future<void> _onSave() async {
    CustomLoader.show();

    final isInfluencer = widget.user['role_id'] == 3;
    final newData = {
      'username':
          usernameController.text.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''),
      'fullname': fullnameController.text,
      'gender': gender.keys.elementAt(genderIndex.value),
      'address': addressController.text,
      'birthday': dobController.text,
      if (profilePic.value != null &&
          !profilePic.value!.path.startsWith(ApiStrings.imageUrl))
        'profile_pic': await dio.MultipartFile.fromFile(
          profilePic.value!.path,
          filename: profilePic.value!.path.split('/').last,
          contentType: dio.DioMediaType(
              'image', profilePic.value!.path.split('.').last.toLowerCase()),
        ),
    };

    await settingScreenController.updateProfileData(
      data: newData,
      isInfluencer: isInfluencer,
    );
    CustomLoader.hide();
    // Update initial values after successful save
    setInitialValues();
    checkIfChanged();
  }

  @override
  Widget build(BuildContext context) {
    final double widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return PopScope(
      child: Scaffold(
        backgroundColor: whiteColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: blueBack.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
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
                            'Manage Account',
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
                    const Spacer(),
                    Obx(() => CustomButton(
                          height: 40,
                          borderRadius: 16,
                          padding: const EdgeInsets.all(0),
                          buttonTitle: 'SAVE',
                          titleStyle:
                              CustomTextStyle.styledTextWidget.titleSmall!.copyWith(
                            color: isSomethingChanged.value
                                ? primaryColor
                                : primaryColor.withOpacity(0.5),
                            fontSize: (widthScale * kTextFormFactor) * 14,
                            letterSpacing: 2,
                          ),
                          onPress: isSomethingChanged.value ? _onSave : () {},
                          backButtonColor: whiteColor,
                          isTextStyle: true,
                          bordercolor: BorderSide(
                            width: 1,
                            color: isSomethingChanged.value
                                ? primaryColor
                                : primaryColor.withOpacity(0.2),
                          ),
                          onlyText: true,
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfilePictureSection(widthScale),
                        SizedBox(height: 4.h),
                        _buildTextFieldSection(
                          widthScale,
                          'Username',
                          usernameController,
                          'assets/svg/field_person.svg',
                          false,
                        ),
                        SizedBox(height: 4.h),
                        _buildTextFieldSection(
                          widthScale,
                          'Fullname',
                          fullnameController,
                          'assets/svg/field_person.svg',
                          true,
                        ),
                        SizedBox(height: 4.h),
                        _buildGenderSection(widthScale),
                        SizedBox(height: 4.h),
                        _buildTextFieldSection(
                          widthScale,
                          'City/State/Country',
                          addressController,
                          'assets/svg/location.svg',
                          false,
                        ),
                        SizedBox(height: 4.h),
                        _buildBirthdaySection(widthScale),
                        SizedBox(height: 4.h),
                        _buildPhoneNumberSection(widthScale),
                        SizedBox(height: 4.h),
                        _buildEmailSection(widthScale),
                        SizedBox(height: 4.h),
                        if (!uiController.isInfluencer.value)
                          _buildDeleteAccountButton(widthScale)
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Note: For Delete Account ",
                                      style: CustomTextStyle
                                          .styledTextWidget.bodyMedium!
                                          .copyWith(
                                        color: failed,
                                        fontSize: (widthScale * kTextFormFactor) * 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    TextSpan(
                                      text: "Contact Us",
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          RouterController.current.pushNamed(
                                            Routes.contactUs,
                                          );
                                        },
                                      style: CustomTextStyle
                                          .styledTextWidget.bodyMedium!
                                          .copyWith(
                                        color: blueBack,
                                        fontSize: (widthScale * kTextFormFactor) * 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProfilePictureSection(double widthScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRichText(widthScale, 'Your ', 'Profile Picture'),
        Align(
          alignment: Alignment.center,
          child: InkWell(
            onTap: () async {
              CustomLoader.show();
              final imagePicker = ImagePicker();
              profilePic.value = await imagePicker
                  .pickImage(source: ImageSource.gallery)
                  .then((value) {
                if (value != null) {
                  return XFile(value.path);
                } else {
                  return profilePic.value;
                }
              });
              CustomLoader.hide();
              checkIfChanged(); // Check if profile picture changed
            },
            overlayColor: const WidgetStatePropertyAll(transparentColor),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(width: 4, color: headingColor),
                  ),
                  child: Obx(
                    () {
                      return CircleAvatar(
                        radius: 40,
                        backgroundImage: profilePic.value != null
                            ? profilePic.value!.path
                                    .contains(ApiStrings.imageUrl)
                                ? Image.network((profilePic.value?.path ?? ''))
                                    .image
                                : Image.file(File(profilePic.value!.path)).image
                            : Image.asset(person, color: whiteColor).image,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    height: 25,
                    width: 25,
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: headingColor,
                    ),
                    child: SvgPicture.asset(
                      addIcon,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextFieldSection(
    double widthScale,
    String label,
    TextEditingController controller,
    String svg,
    bool readOnly,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRichText(
          widthScale,
          'Your ',
          label,
        ),
        CustomTextFormField(
          hintText: label,
          controller: controller,
          svg: svg,
          radius: 12,
          isMaxLine: 1,
          prefixIcon: person,
          fieldReadOnly: readOnly,
          // textLength: label == 'Username' ? null : null,
          suffixSvg:
              label == 'Username' || label == 'Fullname' ? null : dropArrowDown,
          suffixSvgHeight: 12,
          textFieldPadding:
              EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 2.w),
          onChanged: (value) {
            if (label == 'Username' && value.contains(' ')) {
              controller.text = value.replaceAll(' ', '');
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
            }

            checkIfChanged();
          },
        ),
      ],
    );
  }

  Widget _buildGenderSection(double widthScale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRichText(widthScale, 'Your ', 'Gender'),
        SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
                3, (index) => _buildGenderContainer(widthScale, index)),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderContainer(double widthScale, int index) {
    return Expanded(
      child: Obx(() => GestureDetector(
            onTap: () {
              genderIndex.value = index;
              checkIfChanged(); // Check if gender changed
            },
            child: Container(
              height: 56,
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                right: index == 0
                    ? 20
                    : index == 1
                        ? 10
                        : 0,
                left: index != 2 ? 0 : 10,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: index == genderIndex.value ? 3 : 1,
                  color: headingColor,
                ),
              ),
              child: Text(
                ['Male', 'Female', 'Non-binary'][index],
                style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                  color: index == genderIndex.value
                      ? headingColor
                      : headingColor.withOpacity(0.6),
                  fontSize: (widthScale * kTextFormFactor) * 12,
                  fontWeight: index == genderIndex.value
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildBirthdaySection(double widthScale) {
    RxString date = dobController.text.obs;

    // Helper function to parse DD-MM-YYYY format safely
    DateTime parseDate(String dateStr) {
      try {
        return DateFormat('dd-MM-yyyy').parseStrict(dateStr);
      } catch (e) {
        // Fallback to current date or initial controller value if parsing fails
        return DateTime.now();
      }
    }

    return Obx(() {
      // Parse the date and reformat it
      DateTime parsedDate = parseDate(date.value);
      date.value = DateFormat('dd-MM-yyyy').format(parsedDate);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRichText(widthScale, 'Your ', 'Birthday (DD/MM/YYYY)'),
          GestureDetector(
            onTap: () {
              showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              ).then((value) {
                if (value != null) {
                  dobController.text = value.toString().split(' ')[0];
                  date.value = DateFormat('dd-MM-yyyy').format(value);
                  uiController.userData.value['Profile']?['birthday'] =
                      dobController.text;
                  checkIfChanged();
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  width: 1,
                  color: headingColor,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/birthday.svg',
                    height: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    date.value.replaceAll('-', '/'),
                    style: CustomTextStyle.styledTextWidget.displayMedium
                        ?.copyWith(
                      color: headingColor,
                      overflow: TextOverflow.ellipsis,
                      height: 2,
                    ),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    dropArrowDown,
                    height: 12,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You Can Only Update Your Birthday Once Every 6 Months, So Choose Carefully!',
            style: CustomTextStyle.styledTextWidget.bodySmall?.copyWith(
              color: sendColor,
              fontSize: (widthScale * kTextFormFactor) * 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPhoneNumberSection(double widthScale) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRichText(widthScale, 'Your 10 Digit ', 'Mobile Number'),
            CustomTextFormField(
              hintText: '123456789',
              controller: settingScreenController.mobileNumberController,
              // prefixIcon: '',
              svg: 'assets/svg/phone.svg',
              radius: 12,
              textLength: 10,
              keyboardType: TextInputType.phone,
              textFieldPadding:
                  EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 2.w),
              onChanged: (value) {
                phoneNo.value = value;
              },
              containerWidget: _buildUpdateButton(
                widthScale: widthScale,
                tempValue: tempPhoneNo.value,
                currentValue: phoneNo.value,
                type: 'mobile',
              ),
            ),
          ],
        ));
  }

  Widget _buildEmailSection(double widthScale) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRichText(widthScale, 'Your Registered ', 'Email Address'),
            CustomTextFormField(
              hintText: 'example@gmail.com',
              controller: settingScreenController.emailController,
              // prefixIcon: '',
              svg: 'assets/svg/email.svg',
              textFieldPadding:
                  EdgeInsets.symmetric(vertical: 1.6.h, horizontal: 2.w),
              onChanged: (value) {
                email.value = value;
              },
              containerWidget: _buildUpdateButton(
                widthScale: widthScale,
                tempValue: tempEmail.value,
                currentValue: email.value,
                type: 'email',
              ),
              radius: 12,
            ),
          ],
        ));
  }

  Widget _buildUpdateButton({
    required double widthScale,
    required String tempValue,
    required String currentValue,
    required String type,
  }) {
    return GestureDetector(
      onTap: () async {
        if (tempValue != currentValue) {
          FocusScope.of(context).unfocus();
          CustomLoader.show();
          final success = await settingScreenController.sendOtp(
            type: type,
            value: currentValue,
          );
          if (success) {
            settingScreenController.isFormFilled.value = false;
            settingScreenController.verificationController.clear();
            showModalBottomSheet(
              context: context,
              constraints: BoxConstraints(maxHeight: 40.h),
              enableDrag: true,
              backgroundColor: transparentColor,
              builder: (context) => VerifyOtpSheet(type: type),
            ).then((value) {
              if (value != null && value) {
                if (type == 'mobile') {
                  tempPhoneNo.value = currentValue;
                  uiController.userData.value['mobile'] = currentValue;
                } else {
                  tempEmail.value = currentValue;
                  uiController.userData.value['email'] = currentValue;
                }
              }
            });
            widget.user[type] = currentValue;
            tempValue = currentValue;
          } else {
            widget.user[type] = widget.user[type];
            CustomSnackbar.show(
              title: 'Error',
              message: 'Something went wrong',
              isError: true,
            );
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.sp),
        margin: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.sp),
          color: tempValue == currentValue
              ? primaryColor.withOpacity(0.2)
              : primaryColor,
        ),
        child: Text(
          "UPDATE",
          style: CustomTextStyle.styledTextWidget.bodyMedium!.copyWith(
            fontSize: (widthScale * kTextFormFactor) * 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(double widthScale) {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => DeleteAccount(id: widget.user['id']),
        ),
        child: Text(
          'Delete Account',
          style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
            color: logOutColor,
            fontSize: (widthScale * kTextFormFactor) * 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRichText(double widthScale, String text1, String text2) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text1,
              style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                color: blackColor,
                fontSize: (widthScale * kTextFormFactor) * 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: text2,
              style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                color: blueBack,
                fontSize: (widthScale * kTextFormFactor) * 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: ':',
              style: CustomTextStyle.styledTextWidget.bodyMedium?.copyWith(
                color: blackColor,
                fontSize: (widthScale * kTextFormFactor) * 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
