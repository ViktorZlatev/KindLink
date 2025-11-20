import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

void showVolunteerForm(BuildContext context,
    {required Function(Map<String, dynamic>) onConfirm}) {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController motivationController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();

  File? selectedFile;
  String? uploadedFileUrl;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Volunteer Form',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.9),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 450,
                maxHeight: 750,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: StatefulBuilder(
                  builder: (context, setState) => SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            'Volunteer Application',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        _field(
                          '1. Full Name',
                          nameController,
                          hint: 'Enter your full name',
                        ),
                        _field(
                          '2. Education / Qualifications',
                          educationController,
                          hint: 'e.g. Nursing, First Aid, Social Work, etc.',
                        ),
                        _field(
                          '3. Relevant Experience or Certificates',
                          experienceController,
                          hint:
                              'e.g. Previous volunteer work, first aid experience...',
                          maxLines: 2,
                        ),
                        _field(
                          '4. Special Skills',
                          skillsController,
                          hint:
                              'e.g. Driving, language skills, communication, CPR...',
                        ),
                        _field(
                          '5. Motivation – Why do you want to volunteer?',
                          motivationController,
                          hint:
                              'Explain briefly why you want to join and how you can help.',
                          maxLines: 3,
                        ),

                        const SizedBox(height: 8),

                        // Upload certificates or documents
                        TextButton.icon(
                          onPressed: () async {
                            final result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: [
                                'pdf',
                                'jpg',
                                'jpeg',
                                'png'
                              ],
                            );
                            if (result != null &&
                                result.files.single.path != null) {
                              selectedFile = File(result.files.single.path!);
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('File selected successfully!'),
                                  backgroundColor: Color(0xFF6C63FF),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.upload_file,
                              color: Color(0xFF6C63FF)),
                          label: Text(
                            selectedFile == null
                                ? 'Upload certificate (optional)'
                                : 'Selected: ${selectedFile!.path.split('/').last}',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6C63FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final user =
                                    FirebaseAuth.instance.currentUser;
                                if (user == null) return;

                                // Upload certificate file (if selected)
                                if (selectedFile != null) {
                                  final storageRef = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          'volunteer_docs/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split('/').last}');
                                  await storageRef.putFile(selectedFile!);
                                  uploadedFileUrl =
                                      await storageRef.getDownloadURL();
                                }

                                // Prepare volunteer data
                                final volunteerData = {
                                  'name': nameController.text.trim(),
                                  'education': educationController.text.trim(),
                                  'experience':
                                      experienceController.text.trim(),
                                  'skills': skillsController.text.trim(),
                                  'motivation':
                                      motivationController.text.trim(),
                                  'certificateUrl': uploadedFileUrl,
                                  'timestamp': FieldValue.serverTimestamp(),
                                  'status': 'pending'
                                };

                                // Save to Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('volunteer_forms')
                                    .add(volunteerData);

                                Navigator.pop(context);
                                onConfirm(volunteerData);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6C63FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                              ),
                              child: Text(
                                'Submit',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        ),
      );
    },
  );
}

Widget _field(String title, TextEditingController controller,
    {String? hint, int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    ),
  );
}
