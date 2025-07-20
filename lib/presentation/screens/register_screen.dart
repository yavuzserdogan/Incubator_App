import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/core/constants/color_constant.dart';
import 'package:incubator/core/constants/widget_size_constant.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:incubator/core/utils/text_files.dart';
import 'package:incubator/presentation/components/snackbar_helper.dart';
import 'package:incubator/presentation/controllers/register_controller.dart';
import 'package:incubator/presentation/widgets/button_widget.dart';
import 'package:incubator/presentation/widgets/logo_widget.dart';
import '../../core/errors.dart';
import '../widgets/footer_section_widget.dart';
import '../widgets/text_field_widget.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final RegisterController controller;

  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.find<RegisterController>();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    final SizedBox smallConstBox = SizedBox(height: ScreenSize.height * 0.02);
    final SizedBox mediumConstBox = SizedBox(height: ScreenSize.height * 0.04);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: ScreenSize.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(ColorConstant.gradientColorsFirst),
              Color(ColorConstant.gradientColorsSecond),
              Color(ColorConstant.gradientColorsFirst),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.width * 0.06,
              ),
              child: Column(
                children: [
                  mediumConstBox,
                  LogoWidget(
                    animationController: _animationController,
                    scaleAnimation: _scaleAnimation,
                    slideAnimation: _slideAnimation,
                    fadeAnimation: _fadeAnimation,
                    textInfo: TextFiles.welcome,
                  ),
                  mediumConstBox,
                  Container(
                    padding: EdgeInsets.all(ScreenSize.width * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.01),
                      borderRadius: BorderRadius.circular(
                        ScreenSize.height * WidgetSizeConstant.borderRadius,
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: ScreenSize.width * 0.005,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                          spreadRadius: 0,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFieldWidget(
                            controller: _nameController,
                            hintText: TextFiles.name,
                            icon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return TextFiles.nameWarning;
                              }
                              return null;
                            },
                          ),
                          smallConstBox,
                          TextFieldWidget(
                            controller: _surnameController,
                            hintText: TextFiles.surname,
                            icon: Icons.badge_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return TextFiles.surnameWarning;
                              }
                              return null;
                            },
                          ),
                          smallConstBox,
                          TextFieldWidget(
                            controller: _emailController,
                            hintText: TextFiles.email,
                            icon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return TextFiles.emailDefaultWarning;
                              }
                              final emailRegex = RegExp(
                                r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
                                r"[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
                                r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
                              );
                              if (!emailRegex.hasMatch(value)) {
                                return TextFiles.emailWarning;
                              }
                              return null;
                            },
                          ),
                          smallConstBox,
                          Obx(
                            () => TextFieldWidget(
                              controller: _passwordController,
                              hintText: TextFiles.password,
                              icon: Icons.lock_outline_rounded,
                              obscureText: controller.isPasswordVisible.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: ScreenSize.width * 0.055,
                                ),
                                onPressed:
                                    () => controller.passwordVisibility(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return TextFiles.passwordDefaultWarning;
                                }
                                final passwordRegex = RegExp(
                                  r'^(?=.*[A-Z])(?=.*[!@#\$%^&*(),.?":{}|<>]).{6,}$',
                                );
                                if (!passwordRegex.hasMatch(value)) {
                                  return TextFiles.passwordWarning;
                                }
                                return null;
                              },
                            ),
                          ),
                          mediumConstBox,
                          ButtonWidget(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  await controller.register(
                                    name: _nameController.text,
                                    surname: _surnameController.text,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                  Get.toNamed('/default');
                                } catch (e) {
                                  if (e is Failure) {
                                    final userMessage = ErrorHandler.getUserFriendlyMessage(e);
                                    SnackBarHelper.showError(message: userMessage);
                                  }
                                  else {
                                    SnackBarHelper.showError(message: TextFiles.unknownError);
                                  }
                                }
                              }
                            },
                            label: TextFiles.registerButton,
                            isLoading: controller.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FooterSectionWidget(
                    navigationRoute: '/login',
                    textButtonName: TextFiles.loginTextButton,
                  ),
                  mediumConstBox,
                  Text(
                    TextFiles.kvk,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: ScreenSize.width * 0.03,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
