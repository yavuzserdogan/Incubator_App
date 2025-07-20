import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:incubator/presentation/themes/text_style.dart';
import 'package:incubator/presentation/widgets/button_widget.dart';
import 'package:incubator/presentation/widgets/logo_widget.dart';
import 'package:incubator/presentation/widgets/text_field_widget.dart';
import '../../core/constants/color_constant.dart';
import '../../core/utils/screen_size.dart';
import '../../core/utils/text_files.dart';
import '../components/snackbar_helper.dart';
import '../controllers/login_controller.dart';
import '../widgets/footer_section_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LoginController controller;
  late AnimationController _animationController;
  late AnimationController _fadeController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LoginController>();

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
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _fadeController.dispose();
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
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenSize.width * 0.07,
                vertical: ScreenSize.height * 0.05,
              ),
              child: Column(
                children: [
                  SizedBox(height: ScreenSize.height * 0.08),
                  LogoWidget(
                    animationController: _animationController,
                    scaleAnimation: _scaleAnimation,
                    slideAnimation: _slideAnimation,
                    fadeAnimation: _fadeAnimation,
                    textInfo: TextFiles.welcomeLogin,
                  ),

                  mediumConstBox,
                  Container(
                    padding: EdgeInsets.all(ScreenSize.width * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        ScreenSize.height * 0.02,
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
                          // Email field
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
                              icon: Icons.lock_outline,
                              isPassword: true,
                              obscureText: controller.isPasswordVisible.value,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: ScreenSize.width * 0.06,
                                ),
                                onPressed:
                                    () => controller.passwordVisibility(),
                              ),
                            ),
                          ),
                          mediumConstBox,
                          ButtonWidget(
                            onPressed: () async {
                              // if (_formKey.currentState!.validate()) {
                              //   try {
                              //     final success = await controller.login(
                              //       email: _emailController.text,
                              //       password: _passwordController.text,
                              //     );
                              //
                              //     if (success) {
                              //       Get.toNamed('/default');
                              //     }
                              //   } catch (e) {
                              //     SnackBarHelper.showError(
                              //       message:
                              //           '${TextFiles.loginError}: ${e.toString()}',
                              //     );
                              //   }
                              // }
                            },
                            label: TextFiles.loginButton,
                            isLoading: controller.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FooterSectionWidget(
                    navigationRoute: '/register',
                    textButtonName: TextFiles.registerTextButton,
                  ),

                  TextButton(
                    onPressed: () {
                      Get.toNamed("/default");
                    },
                    child: Text(
                      "Misafir Girişi",
                      style: titleSmall.copyWith(color: Colors.white),
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
