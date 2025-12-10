import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

void showVolunteerForm(
  BuildContext context, {
  required Function(Map<String, dynamic>) onConfirm,
}) {
  final nameController = TextEditingController();
  final educationController = TextEditingController();
  final experienceController = TextEditingController();
  final motivationController = TextEditingController();
  final skillsController = TextEditingController();

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
                  children: [

                    Text(
                      "Volunteer Application",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6C63FF),
                      ),
                    ),

                    const SizedBox(height: 20),

                    _field("Full Name", nameController),
                    _field("Education / Qualifications", educationController),
                    _field("Relevant Experience", experienceController, maxLines: 2),
                    _field("Special Skills", skillsController),
                    _field("Motivation", motivationController, maxLines: 3),

                    const SizedBox(height: 10),

                    TextButton.icon(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowedExtensions: ['pdf','jpg','jpeg','png'],
                          type: FileType.custom,
                        );
                        if (result != null && result.files.single.path != null) {
                          selectedFile = File(result.files.single.path!);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("File successfully selected"),
                              backgroundColor: Color(0xFF6C63FF),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.upload_file, color: Color(0xFF6C63FF)),
                      label: Text(
                        selectedFile == null
                          ? "Upload certificate (optional)"
                          : selectedFile!.path.split('/').last,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),

                    SizedBox(height: 25),

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
                                .child("volunteer_docs/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${selectedFile!.path.split('/').last}");

                              await ref.putFile(selectedFile!);
                              uploadedFileUrl = await ref.getDownloadURL();
                            }

                            final volunteerData = {
                              "name": nameController.text.trim(),
                              "education": educationController.text.trim(),
                              "experience": experienceController.text.trim(),
                              "skills": skillsController.text.trim(),
                              "motivation": motivationController.text.trim(),
                              "certificateUrl": uploadedFileUrl,
                              "timestamp": FieldValue.serverTimestamp(),
                              "status": "pending",
                            };

                            await FirebaseFirestore.instance
                              .collection("users")
                              .doc(user.uid)
                              .collection("volunteer_forms")
                              .add(volunteerData);

                            Navigator.pop(context);
                            onConfirm(volunteerData);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            "Submit",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
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

Widget _field(
  String title,
  TextEditingController controller, {
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 6),
        TextField(
          maxLines: maxLines,
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          ),
        ),
      ],
    ),
  );
}
