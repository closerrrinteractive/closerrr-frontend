import 'dart:developer';

import 'package:closerrr/core/config/helpers.dart';
import 'package:closerrr/core/themes/colors.dart';
import 'package:closerrr/core/themes/text_style.dart';
import 'package:closerrr/core/utils/constant.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_button.dart';
import 'package:closerrr/src/view/widgets/custom_widgets/custom_text_formfield.dart';
import 'package:closerrr/src/view/widgets/specific_widgets/chat/chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import '../../../../../controller/settings_controller/settings_controller.dart';

class AddBankAccounts extends StatefulWidget {
  const AddBankAccounts({super.key});

  @override
  State<AddBankAccounts> createState() => _AddBankAccountsState();
}

class _AddBankAccountsState extends State<AddBankAccounts> {
  // 🧾 Controllers
  final _accountNumberController = TextEditingController();
  final _reAccountNumberController = TextEditingController();
  final _beneficiaryNameController = TextEditingController();
  final _ifscController = TextEditingController();
  final _vpaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  final _scrollController = ScrollController(); // 👈 Added for auto-scroll
  final _formKey = GlobalKey<FormState>();
  final settingController = Get.find<SettingScreenController>();

  final _isLoading = false.obs;

  @override
  void dispose() {
    _scrollController.dispose();
    _accountNumberController.dispose();
    _reAccountNumberController.dispose();
    _beneficiaryNameController.dispose();
    _ifscController.dispose();
    _vpaController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  // 🚀 Function to hit add bank account API
  Future<void> addBankAccount() async {
    // Validate all fields
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      // Wait for error messages to render
      await Future.delayed(const Duration(milliseconds: 100));

      // Find the first field that has error and scroll to it
      final firstErrorBox = _findFirstErrorRenderObject(context);
      if (firstErrorBox != null) {
        _scrollController.animateTo(
          firstErrorBox.localToGlobal(Offset.zero).dy +
              _scrollController.offset -
              100,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    if (_accountNumberController.text.trim() !=
        _reAccountNumberController.text.trim()) {
      Get.snackbar(
        "Account Mismatch",
        "Bank account numbers do not match!",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    final Map<String, String> bankData = {
      "bank_account_number": _accountNumberController.text.trim(),
      "beneficiary_name": _beneficiaryNameController.text.trim(),
      "bank_ifsc": _ifscController.text.trim(),
      "vpa": _vpaController.text.trim(),
      "beneficiary_email": _emailController.text.trim(),
      "beneficiary_phone": _phoneController.text.trim(),
      "beneficiary_address": _addressController.text.trim(),
      "beneficiary_city": _cityController.text.trim(),
      "beneficiary_state": _stateController.text.trim(),
      "beneficiary_postal_code": _postalCodeController.text.trim(),
    };

    _isLoading.value = true;

    try {
      final result =
          await settingController.addBeneficiaryAccount(data: bankData);

      if (result == true) {
        context.pop();
        Helpers.toast("Bank account added successfully!");
      } else {
        Helpers.toast("Failed to add bank account!");
      }
    } catch (e) {
      log("Error: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  // 🧩 Finds first field with validation error
  RenderBox? _findFirstErrorRenderObject(BuildContext context) {
    final formContext = _formKey.currentContext;
    if (formContext == null) return null;

    final errorFields = <RenderBox>[];
    formContext.visitChildElements((element) {
      if (element.widget is TextFormField) {
        final state = element as StatefulElement;
        final textFormFieldState = state.state as FormFieldState?;
        if (textFormFieldState != null && textFormFieldState.hasError) {
          final box = element.renderObject as RenderBox?;
          if (box != null) errorFields.add(box);
        }
      }
    });

    if (errorFields.isEmpty) return null;

    // Sort by position (top-most field first)
    errorFields.sort(
      (a, b) => a
          .localToGlobal(Offset.zero)
          .dy
          .compareTo(b.localToGlobal(Offset.zero).dy),
    );

    return errorFields.first;
  }

  Widget _buildField({
    required String head1,
    required String head2,
    required String head3,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    keyboardType = TextInputType.text,
    bool obscure = false,
    int textLength = 50,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFildHeading(head1: head1, head2: head2, head3: head3),
        SizedBox(height: 1.h),
        CustomTextFormField(
          textLength: textLength,
          hintText: hint,
          keyboardType: keyboardType,
          obscureText: obscure,
          controller: controller,
          validator: validator,
        ),
        SizedBox(height: 3.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: ChatAppBar(
        isChatSetting: true,
        chatTitle: "Add Bank Account",
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController, // 👈 attach scroll controller
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildField(
                head1: "Your",
                head2: "Bank Account Number",
                head3: ":",
                hint: "Enter your bank account number",
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your bank account number';
                  } else if (value.length < 9 || value.length > 18) {
                    return 'Account number must be 9–18 characters';
                  }
                  if (value != _reAccountNumberController.text) {
                    return 'Account Numbers Don’t Match. Please Try Again.';
                  }
                  return null;
                },
              ),
              _buildField(
                head1: "Re-enter",
                head2: "Bank Account Number",
                head3: ":",
                hint: "Re-enter your bank account number",
                controller: _reAccountNumberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please re-enter your account number';
                  }
                  if (value != _accountNumberController.text) {
                    return 'Account Numbers Don’t Match. Please Try Again.';
                  }
                  return null;
                },
              ),
              _buildField(
                head1: "Your",
                head2: "Beneficiary Name",
                head3: ":",
                hint: "Enter beneficiary name",
                controller: _beneficiaryNameController,
                keyboardType: TextInputType.name,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter beneficiary name'
                    : null,
              ),
              _buildField(
                head1: "Your Bank’s",
                head2: "IFSC Code",
                head3: ":",
                hint: "Enter IFSC code",
                controller: _ifscController,
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter IFSC code';
                  } else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                      .hasMatch(value)) {
                    return 'Please enter valid IFSC code';
                  }
                  return null;
                },
              ),
              _buildField(
                head1: "Your",
                head2: "VPA / UPI ID",
                head3: ":",
                hint: "Enter your UPI ID (optional)",
                keyboardType: TextInputType.text,
                controller: _vpaController,
                validator: (_) => null,
              ),
              _buildField(
                head1: "Your",
                head2: "Email",
                head3: ":",
                hint: "Enter beneficiary email",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email';
                  } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),
              _buildField(
                head1: "Your",
                head2: "Phone Number",
                head3: ":",
                hint: "Enter beneficiary phone",
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                    return 'Please enter valid 10-digit phone number';
                  }
                  return null;
                },
              ),
              _buildField(
                head1: "Your",
                head2: "Address",
                head3: ":",
                hint: "Enter beneficiary address",
                keyboardType: TextInputType.streetAddress,
                controller: _addressController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter address'
                    : null,
              ),
              _buildField(
                head1: "Your",
                head2: "City",
                head3: ":",
                hint: "Enter city",
                controller: _cityController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter city'
                    : null,
              ),
              _buildField(
                head1: "Your",
                head2: "State",
                head3: ":",
                hint: "Enter state",
                controller: _stateController,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter state'
                    : null,
              ),
              _buildField(
                head1: "Your",
                head2: "Postal Code",
                head3: ":",
                hint: "Enter postal code",
                controller: _postalCodeController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter postal code';
                  } else if (!RegExp(r'^[0-9]{5,6}$').hasMatch(value)) {
                    return 'Please enter valid postal code';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              Obx(
                () => _isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        height: 6.h,
                        buttonTitle: 'ADD BANK ACCOUNT',
                        backButtonColor: primaryColor,
                        isTextStyle: true,
                        onlyText: false,
                        textColor: whiteColor,
                        onPress: () => addBankAccount(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
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
    final widthScale = MediaQuery.of(context).size.width / kDesignWidth;
    return SizedBox(
      width: 100.w,
      child: Wrap(
        children: [
          Text(head1, style: CustomTextStyle.styledTextWidget.displayMedium),
          SizedBox(width: 1.w),
          Text(
            head2,
            style: CustomTextStyle.styledTextWidget.displayMedium?.copyWith(
              color: blueBack,
              fontWeight: FontWeight.w700,
              fontSize: (widthScale * kTextFormFactor) * 16,
            ),
          ),
          Text(head3, style: CustomTextStyle.styledTextWidget.displayMedium),
        ],
      ),
    );
  }
}
