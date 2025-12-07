import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showHelpRequestDialog(
  BuildContext context, {
  required Map<String, dynamic> surveyData,
  required Function(Map<String, dynamic>) onSave,
}) {
  final editableData = Map<String, dynamic>.from(surveyData);
  bool isEditing = false;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Help Request',
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) => StatefulBuilder(
      builder: (dialogContext, setState) => Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 40,
            ),
            backgroundColor: Colors.white.withOpacity(0.96),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      "Your Health Summary",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Edit toggle
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() => isEditing = !isEditing);
                        },
                        icon: Icon(
                          isEditing ? Icons.check_circle : Icons.edit,
                          color: const Color(0xFF6C63FF),
                        ),
                        label: Text(
                          isEditing ? "" : "Edit Info",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6C63FF),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Survey fields
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
                        children: editableData.entries.map((entry) {
                          final key = entry.key;
                          final value = entry.value ?? "";

                          if (key == "timestamp" || key == "fileUrl") {
                            return const SizedBox.shrink();
                          }

                          IconData icon;
                          switch (key) {
                            case "problem":
                              icon = Icons.healing;
                              break;
                            case "symptoms":
                              icon = Icons.sick;
                              break;
                            case "duration":
                              icon = Icons.timer;
                              break;
                            case "treatment":
                              icon = Icons.medical_services;
                              break;
                            case "additional":
                              icon = Icons.notes;
                              break;
                            default:
                              icon = Icons.info_outline;
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: const Color(0xFF6C63FF).withOpacity(0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(icon,
                                    color: const Color(0xFF6C63FF), size: 26),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: isEditing
                                      ? TextFormField(
                                          initialValue: value.toString(),
                                          onChanged: (v) =>
                                              editableData[key] = v.trim(),
                                          style: GoogleFonts.poppins(
                                              fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText:
                                                key[0].toUpperCase() + key.substring(1),
                                            border: InputBorder.none,
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
                                                color:
                                                    const Color(0xFF6C63FF),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              value.toString().isNotEmpty
                                                  ? value.toString()
                                                  : "No information provided",
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.black87,
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

                    const SizedBox(height: 25),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            onSave(editableData); // return updated data
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            isEditing ? "Save" : "Done",
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
}
