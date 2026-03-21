import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/api_string.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/core/utils/img_string.dart';
import 'package:closerrr/src/controller/authentication/auth_controller.dart';
import 'package:closerrr/src/controller/authentication/google_maps_controller.dart';
import 'package:closerrr/src/controller/authentication/verify_otp_controller.dart';
import 'package:closerrr/src/controller/custom_controllers/pick_image_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/onboard_profile_controller.dart';
import 'package:closerrr/src/controller/onboarding-controllers/splash_screen_controller.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_background_screen.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/auth_main_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

class ProfileOnboardPage extends StatefulWidget {
  const ProfileOnboardPage({super.key});

  @override
  State<ProfileOnboardPage> createState() => _ProfileOnboardPageState();
}

class _ProfileOnboardPageState extends State<ProfileOnboardPage> {
  final AuthController authController = Get.find();
  final ScalingController scalingController = Get.find();
  final OnboardProfileController onboardProfileController = Get.find();
  final PickImageController pickImageController = Get.find();
  final VerifyOtpController verifyOtpController = Get.find();
  final GoogleMapsController googleMapsController = Get.find();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  RxBool acceptPpAndTAC = false.obs;

  @override
  void initState() {
    super.initState();
    if (!onboardProfileController.isGooglePrefilled.value) {
      clear();
    }
  }

  clear() {
    pickImageController.imagePath.value = null;
    onboardProfileController.usernameController.clear();
    onboardProfileController.fullnameController.clear();
    onboardProfileController.selectedGender.value = '';
    onboardProfileController.addressController.clear();
    onboardProfileController.birthdayController.clear();
    onboardProfileController.mobileNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    final isInfluencer = Helpers.isInfluencer(
        authController.userInformationController.userData["role_id"]);
    return CustomBackgroundPage(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Obx(
                                () => Transform.scale(
                                  scale: scalingController.scaleFactor
                                      .value, // Bind the scale to the animation value
                                  child: Image.asset(
                                    mainLogo,
                                    scale: 5.5,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 1.h,
                              ),
                              Text(
                                "Closerrr...",
                                style: CustomTextStyle
                                    .styledTextWidget.titleLarge!
                                    .copyWith(
                                        fontSize: 25.sp, color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const CustomSizedBox(),
                      SizedBox(
                        width: 100.w,
                        child: Text(
                          "Personal Details:",
                          style: CustomTextStyle.styledTextWidget.displayLarge
                              ?.copyWith(color: headingColor),
                        ),
                      ),
                      const CustomSizedBox(),
                      const TextFildHeading(
                        head1: "Select Your",
                        head2: "Profile Picture",
                        head3: " (Optional):",
                      ),
                      const CustomSizedBox(),
                      Obx(
                        () => GestureDetector(
                          onTap: () async {
                            await pickImageController.getImagePicker(
                                isCamera: false);
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50.sp),
                                  border: Border.all(
                                      color: headingColor, width: 1.w),
                                ),
                                height: 12.h,
                                width: 12.h,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.sp),
                                  child: pickImageController.imagePath.value !=
                                          null
                                      ? Image.file(
                                          pickImageController.imagePath.value!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return Image.asset(
                                              staticImage,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        )
                                      : Image.asset(
                                          staticImage,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            return Image.asset(
                                              staticImage,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () async {
                                    if (pickImageController.imagePath.value ==
                                        null) {
                                      await pickImageController.getImagePicker(
                                          isCamera: false);
                                    } else {
                                      pickImageController.imagePath.value =
                                          null;
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: headingColor,
                                    ),
                                    child: Icon(
                                      pickImageController.imagePath.value ==
                                              null
                                          ? Icons.add
                                          : Icons.close,
                                      color: whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const CustomSizedBox(),
                      const TextFildHeading(
                          head1: "Enter Your", head2: "Username", head3: ":"),
                      SizedBox(height: 2.h),
                      CustomTextFormField(
                          textLength: 24,
                          prefixIcon: personIcon,
                          hintText: "Your Username",
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your username';
                            } else if (!RegExp(
                                    r'^[a-zA-Z0-9_]+( [a-zA-Z0-9_]+)*$')
                                .hasMatch(value.trim())) {
                              return 'Invalid username format';
                            }
                            return null;
                          },
                          controller:
                              onboardProfileController.usernameController),
                      const CustomSizedBox(),
                      const TextFildHeading(
                          head1: "Enter Your", head2: "Fullname", head3: ":"),
                      SizedBox(height: 2.h),
                      CustomTextFormField(
                          textLength: 24,
                          prefixIcon: personIcon,
                          hintText: "Your Fullname",
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your fullname';
                            }
                            return null;
                          },
                          controller:
                              onboardProfileController.fullnameController),
                      const CustomSizedBox(),
                      const TextFildHeading(
                          head1: "Select Your", head2: "Gender", head3: ":"),
                      const CustomSizedBox(),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GenderToggleButton(gender: 'Male'),
                          GenderToggleButton(gender: 'Female'),
                          GenderToggleButton(gender: 'Non-binary'),
                        ],
                      ),
                      Obx(() => onboardProfileController.isGenderValid.value
                          ? const SizedBox.shrink()
                          : const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Please select a gender',
                                style: TextStyle(color: logOutColor),
                              ),
                            )),
                      const CustomSizedBox(),
                      const TextFildHeading(
                          head1: "Select Your",
                          head2: "City/State/Country",
                          head3: ":"),
                      const CustomSizedBox(),
                      CustomTextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          } else if (!RegExp(r'^[a-zA-Z0-9\s,.\-/#]+$')
                              .hasMatch(value)) {
                            return 'Please enter a valid address';
                          }
                          return null; // Validation passed
                        },
                        prefixIcon: locationIcon,
                        suffixIcon: Icons.keyboard_arrow_down_rounded,
                        hintText: "Your City/State/Country",
                        onChanged: (value) {
                          googleMapsController.fetchPredictions(value);
                        },
                        controller: onboardProfileController.addressController,
                      ),
                      Obx(() {
                        // Reactive listener for predictions
                        if (googleMapsController.predictions.isNotEmpty) {
                          return Material(
                            elevation: 2, // Adds shadow for dropdown effect
                            child: Container(
                              constraints: const BoxConstraints(
                                maxHeight: 200, // Restrict maximum height
                              ),
                              margin: const EdgeInsets.only(
                                  top: 8), // Add spacing from the input field
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: ListView.builder(
                                itemCount:
                                    googleMapsController.predictions.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(
                                        googleMapsController.predictions[index]
                                                ['description'] ??
                                            ""),
                                    onTap: () {
                                      googleMapsController
                                              .selectedAddress.value =
                                          googleMapsController
                                                  .predictions[index]
                                              ['description'];
                                      onboardProfileController
                                              .addressController.text =
                                          googleMapsController
                                              .selectedAddress.value;
                                      googleMapsController.predictions
                                          .clear(); // Clear predictions
                                    },
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return const SizedBox
                            .shrink(); // Empty widget when no predictions
                      }),
                      const CustomSizedBox(),
                      const TextFildHeading(
                        head1: "Select Your",
                        head2: "Birthday",
                        head3: " (DD/MM/YYYY):",
                      ),
                      const CustomSizedBox(),
                      CustomTextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your birthday';
                          } else {
                            try {
                              // Parse the date using the same format as in the controller
                              DateTime birthday =
                                  DateFormat('dd-MM-yyyy').parse(value);
                              if (birthday.isAfter(DateTime.now())) {
                                return 'Birthday cannot be in the future';
                              }
                            } catch (e) {
                              return 'Please enter a valid date';
                            }
                          }
                          return null;
                        },
                        fieldReadOnly: true,
                        hintText: "Your Birthday",
                        controller: onboardProfileController.birthdayController,
                        prefixIcon: cakeIcon,
                        suffixIcon: Icons.keyboard_arrow_down_sharp,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: primaryColor,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            onboardProfileController.birthdayController.text =
                                formattedDate;
                          }
                        },
                      ),
                      const CustomSizedBox(),
                      const TextFildHeading(
                        head1: "Enter Your 10 Digit",
                        head2: "Mobile Number",
                        head3: " (Optional):",
                      ),
                      const CustomSizedBox(),
                      Obx(() => CustomTextFormField(
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (!RegExp(r'^\+?[0-9]{7,15}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid phone number';
                                }
                              }
                              return null;
                            },
                            controller:
                                onboardProfileController.mobileNumberController,
                            prefixIcon: phoneIcon,
                            containerWidget: GestureDetector(
                              onTap: () async {
                                if (onboardProfileController
                                    .isFormFilled.value) {
                                  await onboardProfileController
                                      .verifyMobileNumber();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 5.w,
                                  vertical: 2.sp,
                                ),
                                margin: EdgeInsets.symmetric(
                                  vertical: 2.h,
                                  horizontal: 2.w,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.sp),
                                  color: onboardProfileController
                                          .isFormFilled.value
                                      ? primaryColor
                                      : primaryColor.withOpacity(0.5),
                                ),
                                child: Text(
                                  "Send OTP",
                                  style: CustomTextStyle
                                      .styledTextWidget.bodyMedium!
                                      .copyWith(fontSize: 10.sp),
                                ),
                              ),
                            ),
                            hintText: "Your Mobile Number",
                            keyboardType: TextInputType.number,
                            textLength: null,
                            svg: "assets/svg/phone.svg",
                          )),
                      if (onboardProfileController
                          .showVerifyMessage.value.isNotEmpty)
                        Obx(() => Container(
                              margin: EdgeInsets.only(top: 1.h),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                onboardProfileController
                                    .showVerifyMessage.value,
                                style: CustomTextStyle
                                    .styledTextWidget.bodyMedium!
                                    .copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )),
                      const CustomSizedBox(),
                      const TextFildHeading(
                        head1: "Enter",
                        head2: "One Time Password",
                        head3: ":",
                      ),
                      const CustomSizedBox(),
                      SizedBox(
                          height: 10.h,
                          width: 100.w,
                          child: PinCodeTextField(
                            enableActiveFill: true,
                            showCursor: true,
                            cursorColor: primaryColor,
                            autoDisposeControllers: false,
                            appContext: context,
                            length: 5,
                            controller:
                                verifyOtpController.verificationController,
                            pinTheme: PinTheme(
                              activeFillColor: whiteColor,
                              inactiveFillColor: whiteColor,
                              selectedFillColor: whiteColor,
                              shape: PinCodeFieldShape.box,
                              activeColor: primaryColor.withOpacity(0.8),
                              inactiveColor: primaryColor.withOpacity(0.6),
                              selectedColor: primaryColor.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(10.sp),
                              activeBorderWidth: 1.5,
                              inactiveBorderWidth: 1.5,
                              borderWidth: 1.5,
                              selectedBorderWidth: 1.5,
                              fieldHeight: 60.0,
                              fieldWidth: 60.0,
                            ),
                            textStyle: CustomTextStyle
                                .styledTextWidget.displayMedium
                                ?.copyWith(
                                    color: primaryColor, fontSize: 20.sp),
                            onChanged: (value) {
                              verifyOtpController.emailOtp.value = value;
                            },
                            // onCompleted: (value) {
                            //   if (value.length == 5) {
                            //     verifyOtpController.verifyEmail(
                            //         verifyEvent: "signup", verifyType: "mobile");
                            //   }
                            // },
                            keyboardType: TextInputType.number,
                            autoDismissKeyboard: true,
                            animationType: AnimationType.fade,
                            animationDuration:
                                const Duration(milliseconds: 300),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Did Not Recieve OTP?",
                            style:
                                CustomTextStyle.styledTextWidget.displayMedium,
                          ),
                          SizedBox(
                            width: 1.w,
                          ),
                          GestureDetector(
                            onTap: () async {
                              verifyOtpController.verificationController
                                  .clear();
                              await verifyOtpController.resendVerifyEmail(
                                  verifyEvent: "signup");
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Resend OTP",
                                style: CustomTextStyle
                                    .styledTextWidget.displayMedium
                                    ?.copyWith(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: blueBack,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      blueBack, // Set underline color to white
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const CustomSizedBox(),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => SizedBox(
                                width: 26,
                                height: 26,
                                child: Checkbox(
                                  value: acceptPpAndTAC.value,
                                  onChanged: (value) {
                                    acceptPpAndTAC.value = (value ?? false);
                                  },
                                  activeColor: primaryColor,
                                  side: const BorderSide(
                                      color: primaryColor, width: 2.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              )),
                          const SizedBox(width: 5.0),
                          SizedBox(
                            width: 75.w,
                            child: RichText(
                              text: TextSpan(
                                text: '',
                                style: const TextStyle(
                                  height: 1.4,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'I have read and accept all the',
                                    style: CustomTextStyle
                                        .styledTextWidget.labelLarge!
                                        .copyWith(
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Terms and Conditions',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => isInfluencer
                                          ? Helpers.openLink(
                                              ApiStrings.creatorTermsCondtions)
                                          : Helpers.openLink(
                                              ApiStrings.fanTermsCondtions),
                                    style: CustomTextStyle
                                        .styledTextWidget.labelLarge!
                                        .copyWith(
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                      textBaseline: TextBaseline.alphabetic,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' and',
                                    style: CustomTextStyle
                                        .styledTextWidget.labelLarge!
                                        .copyWith(
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' Privacy Policy',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => isInfluencer
                                          ? Helpers.openLink(
                                              ApiStrings.creatorPrivacyPolicy)
                                          : Helpers.openLink(
                                              ApiStrings.fanPrivacyPolicy),
                                    style: CustomTextStyle
                                        .styledTextWidget.labelLarge!
                                        .copyWith(
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 14,
                                      color: primaryColor,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ', and will adhere to them unconditionally.',
                                    style: CustomTextStyle
                                        .styledTextWidget.labelLarge!
                                        .copyWith(
                                      fontSize:
                                          (widthScale * kTextFormFactor) * 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const CustomSizedBox(),
                      Obx(
                        () => AuthMainButton(
                          buttonColor:
                              onboardProfileController.isFormFilled1.value &&
                                      acceptPpAndTAC.value
                                  ? primaryColor
                                  : primaryColor.withOpacity(0.6),
                          onTap: () async {
                            if (formKey.currentState!.validate() &&
                                onboardProfileController.isFormFilled1.value &&
                                acceptPpAndTAC.value) {
                              await onboardProfileController.onBoardProfile();
                            }
                          },
                          buttonText: "CREATE ACCOUNT",
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 15,
                    child: GestureDetector(
                      onTap: () {
                        authController.logout();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(50.sp)),
                        child: Center(
                          child: SvgPicture.asset(logoutIcon),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomSizedBox extends StatelessWidget {
  const CustomSizedBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 2.h);
  }
}

class TextFildHeading extends StatelessWidget {
  const TextFildHeading({
    super.key,
    required this.head1,
    required this.head2,
    required this.head3,
  });
  final String head1;
  final String head2;
  final String head3;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Wrap(
        children: [
          Text(
            head1,
            style: CustomTextStyle.styledTextWidget.displayMedium,
          ),
          SizedBox(width: 1.w),
          Text(
            head2,
            style: CustomTextStyle.styledTextWidget.displayMedium
                ?.copyWith(color: blueBack, fontWeight: FontWeight.w700),
          ),
          Text(
            head3,
            style: CustomTextStyle.styledTextWidget.displayMedium,
          ),
        ],
      ),
    );
  }
}

class GenderToggleButton extends StatelessWidget {
  final String gender;

  const GenderToggleButton({super.key, required this.gender});

  @override
  Widget build(BuildContext context) {
    final OnboardProfileController genderController = Get.find();

    return Obx(() {
      final bool isSelected = genderController.selectedGender.value == gender;
      return GestureDetector(
        onTap: () {
          genderController.selectGender(gender);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.sp),
            border: Border.all(
              color: headingColor.withOpacity(isSelected ? 1 : 0.5),
              width: isSelected ? 0.7.w : 0.4.w,
            ),
          ),
          child: Text(
            gender,
            style: CustomTextStyle.styledTextWidget.labelLarge!.copyWith(
              color: headingColor.withOpacity(isSelected ? 1 : 0.6),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      );
    });
  }
}
