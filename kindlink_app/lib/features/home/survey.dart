import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

void showSurvey(BuildContext context,
    {required Function(Map<String, dynamic>) onConfirm}) {
  final TextEditingController problemController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController treatmentController = TextEditingController();
  final TextEditingController additionalController = TextEditingController();

  File? selectedFile;
  String? uploadedFileUrl;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Health Survey',
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
                            'Health Condition Survey',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(      
                         child: Text(
                            '*This survey asks questions that offer personalization',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color.fromARGB(255, 42, 41, 59),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),


                        // Question 1
                        _question(
                          '1. What health issue are you currently experiencing?',
                          problemController,
                          hint:
                              'e.g. Dizziness, high blood pressure, fatigue, etc.',
                        ),
                        _question(
                          '2. How long have you been feeling this way?',
                          durationController,
                          hint: 'e.g. For a few days, weeks, or months',
                        ),
                        _question(
                          '3. What symptoms do you experience most often?',
                          symptomsController,
                          hint:
                              'e.g. Headaches, blurred vision, chest pain...',
                          maxLines: 2,
                        ),
                        _question(
                          '4. Are you currently taking any medication or treatment?',
                          treatmentController,
                          hint: 'List medication, if any',
                        ),
                        _question(
                          '5. Any additional info or attach medical results?',
                          additionalController,
                          hint: 'Add notes or upload medical file...',
                          maxLines: 3,
                        ),

                        const SizedBox(height: 8),

                        // Upload file button
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
                                  content: Text('File selected successfully!'),
                                  backgroundColor: Color(0xFF6C63FF),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.upload_file,
                              color: Color(0xFF6C63FF)),
                          label: Text(
                            selectedFile == null
                                ? 'Upload file (optional)'
                                : 'File selected: ${selectedFile!.path.split('/').last}',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6C63FF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Buttons
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

                                // ⬆️ Upload file to Firebase Storage (if selected)
                                if (selectedFile != null) {
                                  final storageRef = FirebaseStorage.instance
                                      .ref()
                                      .child(
                                          'medical_uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split('/').last}');
                                  await storageRef.putFile(selectedFile!);
                                  uploadedFileUrl =
                                      await storageRef.getDownloadURL();
                                }

                                // Prepare survey data
                                final surveyData = {
                                  'problem': problemController.text.trim(),
                                  'duration': durationController.text.trim(),
                                  'symptoms': symptomsController.text.trim(),
                                  'treatment': treatmentController.text.trim(),
                                  'additional':
                                      additionalController.text.trim(),
                                  'fileUrl': uploadedFileUrl,
                                };

                                // 💾 Save survey data to Firestore
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('surveys')
                                    .add(surveyData);

                                Navigator.pop(context);
                                onConfirm(surveyData); // ✅ return data to caller
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

// 📋 Helper widget for a question section
Widget _question(String title, TextEditingController controller,
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
