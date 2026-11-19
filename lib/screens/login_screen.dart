import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'admin_dashboard_screen.dart';

/// Halaman Login Super Admin untuk aplikasi desktop DOKEMAS
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _apiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AdminDashboardScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showForgotPasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final emailCtrl = TextEditingController(text: _emailController.text.trim());
    final otpCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    int step = 1; // 1 = Kirim OTP, 2 = Input OTP & Password Baru
    bool isSubmitting = false;
    String? modalError;
    String? modalInfo;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreenSoft,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.lock_reset_rounded,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Reset Kata Sandi',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      step == 1
                                          ? 'Langkah 1/2: Kirim kode OTP ke email'
                                          : 'Langkah 2/2: Verifikasi OTP & sandi baru',
                                      style: AppTheme.bodyXS,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppTheme.borderColor),
                        const SizedBox(height: 16),

                        if (modalError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.accentRedLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              modalError!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentRed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        if (modalInfo != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreenSoft,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              modalInfo!,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryGreen,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        const Text('Email Terdaftar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: emailCtrl,
                          enabled: step == 1 && !isSubmitting,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Email wajib diisi';
                            if (!t.contains('@')) return 'Format email tidak valid';
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'admin@dokemas.id',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),

                        if (step == 2) ...[
                          const SizedBox(height: 14),
                          const Text('Kode OTP (dari Email)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: otpCtrl,
                            enabled: !isSubmitting,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Kode OTP wajib diisi' : null,
                            decoration: InputDecoration(
                              hintText: 'Masukkan kode OTP',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('Kata Sandi Baru', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: newPassCtrl,
                            obscureText: true,
                            enabled: !isSubmitting,
                            validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null,
                            decoration: InputDecoration(
                              hintText: 'Minimal 6 karakter',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('Konfirmasi Kata Sandi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: confirmPassCtrl,
                            obscureText: true,
                            enabled: !isSubmitting,
                            validator: (v) => v != newPassCtrl.text ? 'Konfirmasi sandi tidak cocok' : null,
                            decoration: InputDecoration(
                              hintText: 'Ulangi kata sandi baru',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (step == 2)
                              TextButton(
                                onPressed: isSubmitting
                                    ? null
                                    : () => setModalState(() {
                                          step = 1;
                                          modalError = null;
                                          modalInfo = null;
                                        }),
                                child: const Text('Ubah Email'),
                              ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: isSubmitting ? null : () => Navigator.of(dialogCtx).pop(),
                              child: const Text('Batal'),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () async {
                                      if (formKey.currentState?.validate() != true) return;
                                      setModalState(() {
                                        isSubmitting = true;
                                        modalError = null;
                                      });

                                      try {
                                        if (step == 1) {
                                          final msg = await _apiService.forgotPassword(emailCtrl.text.trim());
                                          setModalState(() {
                                            step = 2;
                                            modalInfo = msg;
                                            isSubmitting = false;
                                          });
                                        } else {
                                          final msg = await _apiService.resetPassword(
                                            email: emailCtrl.text.trim(),
                                            otp: otpCtrl.text.trim(),
                                            password: newPassCtrl.text,
                                            passwordConfirmation: confirmPassCtrl.text,
                                          );
                                          if (!dialogCtx.mounted) return;
                                          Navigator.of(dialogCtx).pop();
                                          if (!mounted) return;
                                          _emailController.text = emailCtrl.text.trim();
                                          ScaffoldMessenger.of(this.context).showSnackBar(
                                            SnackBar(
                                              content: Text(msg),
                                              backgroundColor: AppTheme.primaryGreen,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setModalState(() {
                                          modalError = e.toString();
                                          isSubmitting = false;
                                        });
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(step == 1 ? 'Kirim Kode OTP' : 'Simpan Sandi Baru'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgContent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWide = constraints.maxWidth >= 900;

          if (isWide) {
            return Row(
              children: [
                // ── Panel Kiri: Branding DOKEMAS ──
                Expanded(
                  flex: 46,
                  child: _BrandingPanel(),
                ),

                // ── Panel Kanan: Form Login Super Admin ──
                Expanded(
                  flex: 54,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(40),
                      child: _buildLoginCard(),
                    ),
                  ),
                ),
              ],
            );
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildLoginCard(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginCard() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Container(
        padding: const EdgeInsets.all(36),
        decoration: AppTheme.cardDecorationElevated,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Badge Super Admin
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreenSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGreenLight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 14,
                        color: AppTheme.primaryGreen,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Super Admin Portal',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Masuk ke Dashboard',
                style: AppTheme.titleXL,
              ),
              const SizedBox(height: 6),
              const Text(
                'Silakan login menggunakan akun Super Admin untuk mengelola destinasi, user, dan mitra DOKEMAS.',
                style: AppTheme.bodySM,
              ),

              const SizedBox(height: 28),

              // Banner Error
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRedLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.accentRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppTheme.accentRed,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentRed,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Field Email
              const Text(
                'Email Administrator',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                enabled: !_isLoading,
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) {
                    return 'Email wajib diisi';
                  }
                  if (!trimmed.contains('@')) {
                    return 'Format email tidak valid';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'admin@dokemas.id',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppTheme.bgContent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Field Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _showForgotPasswordDialog,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Lupa Kata Sandi?',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _handleLogin(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata sandi wajib diisi';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Masukkan kata sandi',
                  hintStyle: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: AppTheme.bgContent,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // Tombol Submit
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.primaryGreen.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Masuk ke Admin Panel',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 22),
              const Divider(height: 1, color: AppTheme.borderColor),
              const SizedBox(height: 16),

              // Info koneksi backend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Flexible(
                    child: Text(
                      'Terhubung ke Backend API DOKEMAS (Laravel)',
                      style: AppTheme.bodyXS,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F5132),
            Color(0xFF198754),
            Color(0xFF146C43),
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 44),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo DOKEMAS
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.terrain_rounded,
                  color: AppTheme.primaryGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'DOKEMAS',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Dolan Keliling Banyumas',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Hero Copy
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Enterprise Destination Management',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Kendalikan Ekosistem\nPariwisata Banyumas\ndalam Satu Panel.',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Kelola destinasi wisata, akomodasi hotel, akun pengguna, dan mitra pengelola secara terpusat dan real-time.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 28),
              const _FeatureBullet(
                icon: Icons.people_alt_rounded,
                title: 'Manajemen User & Mitra',
                desc: 'Pantau, tambah, ubah role, dan kelola akun secara langsung.',
              ),
              const SizedBox(height: 14),
              const _FeatureBullet(
                icon: Icons.hotel_rounded,
                title: 'Kurasi Wisata & Penginapan',
                desc: 'Sinkronisasi data destinasi dan kategori dengan server produksi.',
              ),
              const SizedBox(height: 14),
              const _FeatureBullet(
                icon: Icons.verified_user_rounded,
                title: 'Keamanan & Kontrol Akses',
                desc: 'Autentikasi token berbasis peran untuk akses Super Admin.',
              ),
            ],
          ),

          // Footer
          const Text(
            '© 2026 DOKEMAS Kabupaten Banyumas • Desktop Admin v2.4',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureBullet({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

