import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_manager/const/colors.dart';
import 'package:gym_manager/screens/homeScreen.dart';
import 'package:gym_manager/view_models/login_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isCheckingLogin = false;

  @override
  void initState() {
    super.initState();

    // Check if user is already logged in when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfAlreadyLoggedIn();
    });
  }

  Future<void> _checkIfAlreadyLoggedIn() async {
    setState(() => _isCheckingLogin = true);

    final viewModel = context.read<LoginViewModel>();

    // If initial check not done yet, do it now
    if (!viewModel.initialCheckDone) {
      await viewModel.checkLoggedInUser();
    }

    // If user is already logged in, redirect to home
    if (viewModel.isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }

    setState(() => _isCheckingLogin = false);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<LoginViewModel>();
    final success = await viewModel.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success && mounted) {
      // Navigate to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  // Clear error when user starts typing
  void _clearError() {
    final viewModel = context.read<LoginViewModel>();
    if (viewModel.errorMessage != null) {
      viewModel.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColor.mainColor, AppColor.secondcolor],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Consumer<LoginViewModel>(
                builder: (context, viewModel, child) {
                  // Show loading while checking initial login status
                  if (_isCheckingLogin) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 250.h,
                          image: AssetImage('assets/images/icon_app.png'),
                        ),
                        SizedBox(height: 30.h),
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 20.h),
                        Text(
                          'Checking login status...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    );
                  }

                  return Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo or Icon
                        Container(
                          child: Image(
                            height: 250.h,
                            image: AssetImage('assets/images/icon_app.png'),
                          ),
                        ),

                        // Title
                        Text(
                          'Gym Manager',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Login to your account',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: AppColor.whitecolor,
                          ),
                        ),
                        SizedBox(height: 30.h),

                        // Login Card
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Container(
                            width: 500.w,
                            child: Card(
                              elevation: 12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(24.w),
                                child: Column(
                                  children: [
                                    // Username Field
                                    SizedBox(height: 2.h),
                                    TextFormField(
                                      cursorColor: AppColor.secondcolor,
                                      controller: _usernameController,
                                      onChanged: (_) => _clearError(),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondcolor,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        labelStyle: TextStyle(
                                          color: AppColor.mainColor,
                                        ),
                                        labelText: 'Username',
                                        prefixIcon: Icon(Icons.person),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter username';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 20),

                                    // Password Field
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      onChanged: (_) => _clearError(),
                                      decoration: InputDecoration(
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: AppColor.secondcolor,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        labelStyle: TextStyle(
                                          color: AppColor.mainColor,
                                        ),
                                        labelText: 'Password',
                                        prefixIcon: Icon(Icons.lock),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter password';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (_) => _handleLogin(),
                                    ),
                                    const SizedBox(height: 10),

                                    // Error Message
                                    if (viewModel.errorMessage != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                viewModel.errorMessage!,
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 20),

                                    // Login Button
                                    SizedBox(
                                      width: 200.w,
                                      height: 50.h,
                                      child: ElevatedButton(
                                        onPressed: viewModel.isLoading
                                            ? null
                                            : _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            13,
                                            38,
                                            63,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15.r,
                                            ),
                                          ),
                                        ),
                                        child: viewModel.isLoading
                                            ? SizedBox(
                                                width: 24.w,
                                                height: 24.h,
                                                child:
                                                    CircularProgressIndicator(
                                                      color:
                                                          AppColor.whitecolor,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),

                                    // Optional: "Remember me" checkbox
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.grey,
                                          size: 16,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'You will stay logged in until you logout',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
