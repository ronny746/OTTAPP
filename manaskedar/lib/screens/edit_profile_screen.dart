import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../controllers/auth_controller.dart';
import '../utils/app_theme.dart';
import '../utils/api_config.dart';

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
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
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
           Get.snackbar("Success", "Profile picture uploaded", backgroundColor: Colors.green, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
        } else {
           Get.snackbar("Error", "Failed to upload picture", backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
         Get.snackbar("Error", "Network error while uploading", backgroundColor: Colors.red, colorText: Colors.white);
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _isUploadingImage ? null : _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor, width: 3),
                        color: Colors.grey[900],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(65),
                        child: _isUploadingImage 
                          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                          : _selectedImage != null
                            ? Image.file(_selectedImage!, fit: BoxFit.cover)
                            : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                              ? Image.network(_uploadedImageUrl!, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => const Icon(Icons.person, size: 60, color: Colors.white54))
                              : const Icon(Icons.person, size: 80, color: Colors.white54),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            _buildTextField("Full Name", Icons.person_outline, _nameController),
            const SizedBox(height: 25),
            
            // Phone is generally read-only in OTP based systems
            _buildTextField("Mobile Number", Icons.phone_android, _phoneController, readOnly: true, hint: "Cannot edit registered number"),
            const SizedBox(height: 25),

            _buildTextField("City", Icons.location_city_outlined, _cityController),
            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SAVE CHANGES", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {bool readOnly = false, String? hint, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onChanged: onChanged,
          style: TextStyle(color: readOnly ? Colors.white30 : Colors.white, fontSize: 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: readOnly ? Colors.white30 : AppTheme.primaryColor),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
