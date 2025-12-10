import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

void showSurvey(
  BuildContext context, {
  required Function(Map<String, dynamic>) onConfirm,
}) {
  final problemController = TextEditingController();
  final durationController = TextEditingController();
  final symptomsController = TextEditingController();
  final treatmentController = TextEditingController();
  final additionalController = TextEditingController();

  File? selectedFile;
  String? uploadedFileUrl;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),

        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450, maxHeight: 750),

          child: Padding(
            padding: const EdgeInsets.all(20),

            child: StatefulBuilder(
              builder: (context, setState) => SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Center(
                      child: Text(
                        "Health Condition Survey",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: Text(
                        "*This survey helps personalize emergency assistance",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _question("1. What health issue are you experiencing?",
                      problemController,
                      hint: "e.g. dizziness, pain, weakness…"
                    ),

                    _question("2. How long have you felt this way?",
                      durationController,
                      hint: "e.g. days, weeks, months"
                    ),

                    _question("3. Symptoms you experience most often:",
                      symptomsController,
                      maxLines: 2,
                      hint: "e.g. headache, nausea…"
                    ),

                    _question("4. Are you taking medication?",
                      treatmentController,
                      hint: "List medication if any"
                    ),

                    _question("5. Additional info / upload file:",
                      additionalController,
                      maxLines: 3,
                      hint: "Extra notes…"
                    ),

                    const SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf','jpg','jpeg','png'],
                        );

                        if (result != null && result.files.single.path != null) {
                          selectedFile = File(result.files.single.path!);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("File selected!"),
                              backgroundColor: Color(0xFF6C63FF),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.upload_file, color: Color(0xFF6C63FF)),
                      label: Text(
                        selectedFile == null
                          ? "Upload file (optional)"
                          : selectedFile!.path.split('/').last,
                        style: GoogleFonts.poppins(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),

                        ElevatedButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            if (selectedFile != null) {
                              final ref = FirebaseStorage.instance
                                .ref()
                                .child("medical_uploads/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split('/').last}");

                              await ref.putFile(selectedFile!);
                              uploadedFileUrl = await ref.getDownloadURL();
                            }

                            final surveyData = {
                              "problem": problemController.text.trim(),
                              "duration": durationController.text.trim(),
                              "symptoms": symptomsController.text.trim(),
                              "treatment": treatmentController.text.trim(),
                              "additional": additionalController.text.trim(),
                              "fileUrl": uploadedFileUrl,
                            };

                            await FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("surveys")
                              .add(surveyData);

                            Navigator.pop(context);
                            onConfirm(surveyData);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: Text("Submit",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _question(
  String title,
  TextEditingController controller, {
  String? hint,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    ),
  );
}
