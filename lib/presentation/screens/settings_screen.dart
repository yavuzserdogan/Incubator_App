import 'package:flutter/material.dart';
import 'package:incubator/core/utils/screen_size.dart';
import 'package:incubator/presentation/themes/text_style.dart';
import '../../core/constants/color_constant.dart';
import '../../core/constants/widget_size_constant.dart';
import '../../core/utils/text_files.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers - TODO: Bu controller'ları kullanarak form işlemlerini yapacaksınız
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // State variables
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // TODO: Kullanıcı bilgilerini yükle
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // TODO: Kullanıcı verilerini yükleme metodu - burayı implement edin
  void _loadUserData() {
    // Örnek: API'den veya local storage'dan kullanıcı bilgilerini çek
    // _nameController.text = user.name;
    // _surnameController.text = user.surname;
    // _emailController.text = user.email;
  }

  // TODO: Profil güncelleme metodu - burayı implement edin
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: API call yaparak profil bilgilerini güncelle
      // await userService.updateProfile(
      //   name: _nameController.text,
      //   surname: _surnameController.text,
      //   email: _emailController.text,
      // );

      // Success message
      _showSnackBar("Profil başarıyla güncellendi", Colors.green);
    } catch (e) {
      _showSnackBar("Bir hata oluştu: $e", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // TODO: Şifre değiştirme metodu - burayı implement edin
  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar("Yeni şifreler eşleşmiyor", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: API call yaparak şifre değiştir
      // await userService.changePassword(
      //   currentPassword: _currentPasswordController.text,
      //   newPassword: _newPasswordController.text,
      // );

      _showSnackBar("Şifre başarıyla değiştirildi", Colors.green);
      _clearPasswordFields();
    } catch (e) {
      _showSnackBar("Şifre değiştirilemedi: $e", Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.height * 0.01),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ScreenSize.height * WidgetSizeConstant.borderCircular,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ScreenSize.height * 0.015),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
                topRight: Radius.circular(
                  ScreenSize.height * WidgetSizeConstant.borderCircular,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ScreenSize.height * 0.01),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(
                      ScreenSize.height * WidgetSizeConstant.borderCircular,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue.shade700,
                    size: ScreenSize.height * 0.02,
                  ),
                ),
                SizedBox(width: ScreenSize.width * 0.03),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(ScreenSize.height * 0.02),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: ScreenSize.height * 0.01),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade600),
          suffixIcon:
              onToggleVisibility != null
                  ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: onToggleVisibility,
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade600,
              width: ScreenSize.width * 0.01,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              ScreenSize.height * WidgetSizeConstant.borderCircular,
            ),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              backgroundColor != null
                  ? [backgroundColor, backgroundColor.withOpacity(0.8)]
                  : [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          ScreenSize.height * WidgetSizeConstant.borderCircular,
        ),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? Colors.blue).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(
            ScreenSize.height * WidgetSizeConstant.borderCircular,
          ),
          child: Center(
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : Text(
                      text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? Colors.white,
                      ),
                    ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return Scaffold(
      backgroundColor: Color(ColorConstant.screenBackground),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ScreenSize.height * 0.01),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildSectionCard(
                title: "Profil Bilgileri",
                icon: Icons.person_outline,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _nameController,
                          label: "Ad",
                          icon: Icons.person,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return "Ad alanı boş bırakılamaz";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: ScreenSize.width * 0.01),
                      Expanded(
                        child: _buildTextField(
                          controller: _surnameController,
                          label: "Soyad",
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return "Soyad alanı boş bırakılamaz";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: TextFiles.settingsEmail,
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "E-posta alanı boş bırakılamaz";
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value!)) {
                        return "Geçerli bir e-posta adresi girin";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    text: "Profili Güncelle",
                    onPressed: _updateProfile,
                  ),
                ],
              ),

              // Şifre Değiştirme Bölümü
              _buildSectionCard(
                title: TextFiles.settingsPassword,
                icon: Icons.lock_outline,
                children: [
                  _buildTextField(
                    controller: _currentPasswordController,
                    label: "Mevcut Şifre",
                    icon: Icons.lock,
                    obscureText: _obscureCurrentPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureCurrentPassword = !_obscureCurrentPassword;
                      });
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "Mevcut şifre boş bırakılamaz";
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _newPasswordController,
                    label: "Yeni Şifre",
                    icon: Icons.lock_outline,
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "Yeni şifre boş bırakılamaz";
                      }
                      if (value!.length < 6) {
                        return "Şifre en az 6 karakter olmalıdır";
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    label: "Yeni Şifre Tekrar",
                    icon: Icons.lock_reset,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return "Şifre tekrarı boş bırakılamaz";
                      }
                      if (value != _newPasswordController.text) {
                        return "Şifreler eşleşmiyor";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    text: "Şifreyi Değiştir",
                    onPressed: _changePassword,
                    backgroundColor: Colors.orange.shade600,
                  ),
                ],
              ),

              // Hesap İşlemleri Bölümü (Opsiyonel)
              _buildSectionCard(
                title: "Hesap İşlemleri",
                icon: Icons.settings_outlined,
                children: [
                  _buildActionButton(
                    text: "Hesabı Sil",
                    onPressed: () {
                      // TODO: Hesap silme onay dialog'u göster
                      _showDeleteAccountDialog();
                    },
                    backgroundColor: Colors.red.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TODO: Hesap silme onay dialog'u - burayı implement edin
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text("Hesabı Sil"),
            content: const Text(
              "Hesabınızı silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("İptal"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // TODO: Hesap silme işlemini yap
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Sil"),
              ),
            ],
          ),
    );
  }
}
