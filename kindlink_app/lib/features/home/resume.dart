import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showHelpRequestDialog(
  BuildContext context, {
  required Map<String, dynamic> surveyData,
  required String surveyId, // ← passed from Firestore
  required VoidCallback onAlert,
}) {
  final editableData = Map<String, dynamic>.from(surveyData);
  bool isEditing = false;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Request Help',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => StatefulBuilder(
      builder: (context, setState) => Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.white.withOpacity(0.96),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🟣 Title
                    Text(
                      'Your Health Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 50,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Edit toggle
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () async {
                          if (isEditing) {
                            await _saveEditsToFirestore(editableData, surveyId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Information updated successfully!'),
                                backgroundColor: Color(0xFF6C63FF),
                              ),
                            );
                          }
                          setState(() => isEditing = !isEditing);
                        },
                        icon: Icon(
                          isEditing ? null : Icons.edit,
                          color: const Color(0xFF6C63FF),
                        ),
                        label: Text(
                          isEditing ? '' : 'Edit Info',
                          style: GoogleFonts.poppins(
                           fontSize: isEditing ? 0 : 15,
                            color: const Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🩺 Modern info display
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color.fromARGB(255, 243, 241, 244),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: editableData.entries.map((e) {
                          final key = e.key;
                          final value = e.value ?? '';
                          if (key == 'timestamp' || key == 'fileUrl') {
                            return const SizedBox();
                          }

                          IconData icon;
                          switch (key.toLowerCase()) {
                            case 'problem':
                              icon = Icons.healing;
                              break;
                            case 'duration':
                              icon = Icons.timer;
                              break;
                            case 'symptoms':
                              icon = Icons.sick;
                              break;
                            case 'treatment':
                              icon = Icons.medical_services;
                              break;
                            case 'additional':
                              icon = Icons.notes;
                              break;
                            default:
                              icon = Icons.info_outline;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF6C63FF).withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(icon,
                                    color: const Color(0xFF6C63FF), size: 26),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: isEditing
                                      ? TextField(
                                          controller: TextEditingController(
                                              text: value.toString()),
                                          onChanged: (val) =>
                                              editableData[key] = val.trim(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: key[0].toUpperCase() +
                                                key.substring(1),
                                            labelStyle: GoogleFonts.poppins(
                                              color: const Color(0xFF6C63FF),
                                              fontWeight: FontWeight.w600,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              key[0].toUpperCase() +
                                                  key.substring(1),
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    const Color(0xFF6C63FF),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              value.toString().isNotEmpty
                                                  ? value.toString()
                                                  : 'No information provided',
                                              style: GoogleFonts.poppins(
                                                color: Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 📎 Attached file
                    if (surveyData['fileUrl'] != null)
                      InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Opening attached file...'),
                              backgroundColor: Color(0xFF6C63FF),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFFEDEAFF),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_file,
                                  color: Color(0xFF6C63FF)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'View attached medical file',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF6C63FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // 🔘 Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (isEditing) {
                              setState(() => isEditing = false);
                            } else {
                              Navigator.pop(context);
                            }
                          },
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
                            if (!isEditing) {
                              Navigator.pop(context);
                              onAlert();
                            } else {
                              await _saveEditsToFirestore(
                                  editableData, surveyId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Information updated successfully!'),
                                  backgroundColor: Color(0xFF6C63FF),
                                ),
                              );
                              setState(() => isEditing = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 26,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            isEditing ? 'Save Changes' : 'Done',
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

/// 💾 Save edits to Firestore
Future<void> _saveEditsToFirestore(
    Map<String, dynamic> updatedData, String surveyId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('surveys')
        .doc(surveyId)
        .update(updatedData);
  } catch (e) {
    debugPrint('Error updating survey: $e');
  }
}
