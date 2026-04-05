import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';
import '../utils/api_config.dart';

import '../widgets/spiritual_background.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = _authController.userName.value != 'OTT User' ? _authController.userName.value : '';
    _phoneController.text = _authController.userPhone.value;
    _cityController.text = _authController.userCity.value;
    _uploadedImageUrl = _authController.userImageUrl.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 72);
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isUploadingImage = true;
      });

      try {
        final headers = await ApiConfig.getHeaders();
        var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.user}/upload'));
        request.headers.addAll({
          'Authorization': headers['Authorization']!
        });
        request.files.add(await http.MultipartFile.fromPath('file', _selectedImage!.path));
        
        var response = await request.send();
        var resData = await response.stream.bytesToString();
        
        if (response.statusCode == 200) {
           final decoded = json.decode(resData);
           setState(() {
             _uploadedImageUrl = decoded['url'];
           });
           Get.snackbar("SUCCESS".tr, "PROFILE_IMAGE_UPLOADED".tr, backgroundColor: Colors.white, colorText: Colors.black, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20), borderRadius: 15);
        } else {
           Get.snackbar("ERROR".tr, "IMAGE_UPLOAD_FAILED".tr, backgroundColor: AppTheme.backgroundColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20), borderRadius: 15);
        }
      } catch (e) {
         Get.snackbar("ERROR".tr, "NETWORK_ERROR".tr, backgroundColor: AppTheme.backgroundColor, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(20), borderRadius: 15);
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);
    
    bool req = await _authController.updateProfile(
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
      imageUrl: _uploadedImageUrl ?? '',
    );

    setState(() => _isLoading = false);

    if(req) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "EDIT_PROFILE".tr, 
          style: GoogleFonts.cinzel(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: 2.0)
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SpiritualBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Center(
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: AppTheme.primaryColor.withOpacity(0.05), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(70),
                          child: Container(
                            color: Colors.white.withOpacity(0.03),
                            child: _isUploadingImage 
                              ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                              : _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                                  ? Image.network(_uploadedImageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => const Icon(Icons.person, size: 70, color: Colors.white24))
                                  : const Icon(Icons.person_rounded, size: 90, color: Colors.white12),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.black, size: 18),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),

              _buildTextField("FULL_NAME".tr, Icons.person_outline_rounded, _nameController),
              const SizedBox(height: 30),
              
              _buildTextField("MOBILE_NUMBER".tr, Icons.phone_iphone_rounded, _phoneController, readOnly: true, hint: "CANNOT_EDIT_MOBILE".tr),
              const SizedBox(height: 30),

              _buildTextField("CITY".tr, Icons.location_on_outlined, _cityController),
              const SizedBox(height: 70),

              GestureDetector(
                onTap: _isLoading ? null : _saveProfile,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: Center(
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          "SAVE_CHANGES".tr, 
                          style: GoogleFonts.lato(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2.0)
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool readOnly = false, String? hint, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Text(label, style: GoogleFonts.lato(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: readOnly ? Colors.white.withOpacity(0.05) : AppTheme.primaryColor.withOpacity(0.15), width: 1),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: onChanged,
            style: GoogleFonts.lato(color: readOnly ? Colors.white30 : Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: readOnly ? Colors.white24 : AppTheme.primaryColor, size: 22),
              hintText: hint,
              hintStyle: GoogleFonts.lato(color: Colors.white12, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}
