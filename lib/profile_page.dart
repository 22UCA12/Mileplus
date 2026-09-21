import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';
import 'notification_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController licenseController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();


  // =========================================================
  // VARIABLES
  // =========================================================

  DateTime? expiryDate;

  bool isLoading = true;


  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();
    loadProfile();
  }


  // =========================================================
  // LOAD PROFILE
  // =========================================================

  Future<void> loadProfile() async {

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    final String? expiryString =
    prefs.getString('licenseExpiry');

    DateTime? savedExpiry;

    if (expiryString != null &&
        expiryString.isNotEmpty) {

      savedExpiry =
          DateTime.tryParse(expiryString);
    }

    if (!mounted) return;

    setState(() {

      nameController.text =
          prefs.getString('driverName') ?? '';

      emailController.text =
          prefs.getString('driverEmail') ?? '';

      phoneController.text =
          prefs.getString('driverPhone') ?? '';

      licenseController.text =
          prefs.getString('licenseNumber') ?? '';

      addressController.text =
          prefs.getString('driverAddress') ?? '';

      expiryDate = savedExpiry;

      isLoading = false;
    });

    await checkLicenseExpiry();
  }


  // =========================================================
  // CHECK LICENSE EXPIRY
  // =========================================================

  Future<void> checkLicenseExpiry() async {

    if (expiryDate == null) {
      return;
    }

    if (licenseController.text.trim().isEmpty) {
      return;
    }

    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final DateTime expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );

    if (expiry.isBefore(today)) {

      await NotificationService
          .showExpiredNotification(
        licenseController.text.trim(),
      );
    }
  }


  // =========================================================
  // SELECT EXPIRY DATE
  // =========================================================

  Future<void> selectExpiryDate() async {

    final DateTime now = DateTime.now();

    final DateTime? picked =
    await showDatePicker(
      context: context,

      initialDate:
      expiryDate ?? now,

      firstDate:
      DateTime(2020),

      lastDate:
      DateTime(2100),

      builder: (context, child) {

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme:
            const ColorScheme.light(
              primary:
              Color(0xFF08743F),
            ),
          ),

          child: child!,
        );
      },
    );

    if (picked != null) {

      setState(() {
        expiryDate = picked;
      });

      final SharedPreferences prefs =
      await SharedPreferences
          .getInstance();

      await prefs.setString(
        'licenseExpiry',
        picked.toIso8601String(),
      );

      await checkLicenseExpiry();
    }
  }


  // =========================================================
  // SAVE PROFILE DATA
  // =========================================================

  Future<void> saveProfileData() async {

    final SharedPreferences prefs =
    await SharedPreferences.getInstance();

    await prefs.setString(
      'licenseNumber',
      licenseController.text.trim(),
    );

    await prefs.setString(
      'driverAddress',
      addressController.text.trim(),
    );

    if (expiryDate != null) {

      await prefs.setString(
        'licenseExpiry',
        expiryDate!.toIso8601String(),
      );
    }
  }


  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {

    final bool? confirm =
    await showDialog<bool>(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Logout',
            style: TextStyle(
              color: Colors.black,
            ),
          ),

          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black,
            ),
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },

              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              child: const Text(
                'Logout',
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    final SharedPreferences prefs =
    await SharedPreferences
        .getInstance();

    await prefs.clear();

    await NotificationService
        .cancelExpiryNotification();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,

      MaterialPageRoute(
        builder: (context) =>
        const LoginPage(),
      ),

          (route) => false,
    );
  }


  // =========================================================
  // DATE FORMAT
  // =========================================================

  String formatDate(DateTime? date) {

    if (date == null) {
      return 'Select expiry date';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }


  // =========================================================
  // LICENSE EXPIRED
  // =========================================================

  bool get isLicenseExpired {

    if (expiryDate == null) {
      return false;
    }

    final DateTime today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final DateTime expiry = DateTime(
      expiryDate!.year,
      expiryDate!.month,
      expiryDate!.day,
    );

    return expiry.isBefore(today);
  }


  // =========================================================
  // TEXT FIELD
  // =========================================================

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {

    return Padding(

      padding: const EdgeInsets.only(
        bottom: 16,
      ),

      child: TextField(

        controller: controller,

        readOnly: readOnly,

        keyboardType: keyboardType,

        maxLines: maxLines,

        onChanged: (value) {

          if (!readOnly) {
            saveProfileData();
          }
        },

        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
        ),

        decoration: InputDecoration(

          labelText: label,

          labelStyle: const TextStyle(
            color: Colors.black,
          ),

          prefixIcon: Icon(
            icon,
            color: Colors.black,
          ),

          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),

            borderSide:
            const BorderSide(
              color: Colors.grey,
            ),
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(14),

            borderSide:
            const BorderSide(
              color: Color(0xFF08743F),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }


  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    licenseController.dispose();
    addressController.dispose();

    super.dispose();
  }


  // =========================================================
  // UI
  // =========================================================

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
      const Color(0xFFF4F8F6),


      // =====================================================
      // GREEN TOP BAR
      // BACK ARROW + PROFILE
      // =====================================================

      appBar: AppBar(

        backgroundColor:
        const Color(0xFF08743F),

        elevation: 0,

        leading: IconButton(

          onPressed: () {
            Navigator.pop(context);
          },

          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
        ),

        title: const Text(
          'Profile',

          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        centerTitle: false,
      ),


      // =====================================================
      // BODY
      // =====================================================

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // =================================================
            // NAME
            // =================================================

            buildTextField(

              controller:
              nameController,

              label: 'Name',

              icon:
              Icons.person_outline,

              readOnly: true,
            ),


            // =================================================
            // EMAIL
            // =================================================

            buildTextField(

              controller:
              emailController,

              label: 'Email ID',

              icon:
              Icons.email_outlined,

              readOnly: true,

              keyboardType:
              TextInputType.emailAddress,
            ),


            // =================================================
            // PHONE NUMBER
            // =================================================

            buildTextField(

              controller:
              phoneController,

              label: 'Phone Number',

              icon:
              Icons.phone_outlined,

              readOnly: true,

              keyboardType:
              TextInputType.phone,
            ),


            const SizedBox(height: 5),


            // =================================================
            // LICENSE NUMBER
            // =================================================

            buildTextField(

              controller:
              licenseController,

              label: 'License Number',

              icon:
              Icons.badge_outlined,

              keyboardType:
              TextInputType.text,
            ),


            // =================================================
            // LICENSE EXPIRY DATE
            // =================================================

            InkWell(

              onTap:
              selectExpiryDate,

              child:
              InputDecorator(

                decoration:
                InputDecoration(

                  labelText:
                  'License Expiry Date',

                  labelStyle:
                  const TextStyle(
                    color: Colors.black,
                  ),

                  prefixIcon:
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.black,
                  ),

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),

                  enabledBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),

                    borderSide:
                    const BorderSide(
                      color: Colors.grey,
                    ),
                  ),

                  focusedBorder:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(14),

                    borderSide:
                    const BorderSide(
                      color: Color(0xFF08743F),
                      width: 2,
                    ),
                  ),
                ),

                child: Text(

                  formatDate(
                    expiryDate,
                  ),

                  style:
                  const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),


            const SizedBox(height: 16),


            // =================================================
            // ADDRESS
            // =================================================

            buildTextField(

              controller:
              addressController,

              label: 'Address',

              icon:
              Icons.location_on_outlined,

              keyboardType:
              TextInputType.streetAddress,

              maxLines: 2,
            ),


            // =================================================
            // LICENSE EXPIRED WARNING
            // =================================================

            if (isLicenseExpired)

              Container(

                width:
                double.infinity,

                padding:
                const EdgeInsets.all(14),

                decoration:
                BoxDecoration(

                  color:
                  Colors.red.withOpacity(0.08),

                  border:
                  const Border(
                    left: BorderSide(
                      color: Colors.red,
                      width: 5,
                    ),
                  ),

                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: const Text(

                  'LICENSE EXPIRED',

                  style:
                  TextStyle(
                    color: Colors.red,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),


            const SizedBox(height: 20),


            // =================================================
            // LOGOUT
            // =================================================

            SizedBox(

              width:
              double.infinity,

              height: 52,

              child:
              OutlinedButton.icon(

                onPressed:
                logout,

                icon:
                const Icon(
                  Icons.logout,
                  color: Colors.red,
                  size: 23,
                ),

                label:
                const Text(
                  'LOGOUT',

                  style:
                  TextStyle(
                    color: Colors.red,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                style:
                OutlinedButton.styleFrom(

                  side:
                  const BorderSide(
                    color: Colors.red,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            ),


            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}