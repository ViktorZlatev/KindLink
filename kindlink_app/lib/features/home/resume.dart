// FULL FIXED VERSION — CLEAN DIALOG, NO FLICKER
// (Shortened explanation: identical UI, stable behavior)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showHelpRequestDialog(
  BuildContext context, {
  required Map<String, dynamic> surveyData,
  required Function(Map<String, dynamic>) onSave,
}) {
  final editableData = Map<String, dynamic>.from(surveyData);
  bool isEditing = false;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        backgroundColor: Colors.white.withOpacity(0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),

        child: StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    "Your Health Summary",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 50,
                    height: 3,
                    color: Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 22),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => isEditing = !isEditing),
                      icon: Icon(isEditing ? Icons.check_circle : Icons.edit,
                          color: Color(0xFF6C63FF)),
                      label: Text(
                        isEditing ? "" : "Edit Info",
                        style: GoogleFonts.poppins(
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255,243,241,244),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Column(
                      children: editableData.entries.map((entry) {
                        final key = entry.key;
                        if (key == "timestamp" || key == "fileUrl") {
                          return SizedBox.shrink();
                        }

                        final value = entry.value ?? "";

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Color(0xFF6C63FF).withOpacity(0.15),
                            ),
                          ),
                          child: isEditing
                            ? TextFormField(
                                initialValue: value.toString(),
                                onChanged: (v) => editableData[key] = v.trim(),
                                decoration: InputDecoration(
                                  labelText: key[0].toUpperCase() + key.substring(1),
                                  border: InputBorder.none,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    key[0].toUpperCase() + key.substring(1),
                                    style: GoogleFonts.poppins(
                                      color: Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    value.toString().isNotEmpty
                                      ? value.toString()
                                      : "No information",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel",
                          style: GoogleFonts.poppins(color: Colors.black54),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onSave(editableData);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(isEditing ? "Save" : "Done"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
