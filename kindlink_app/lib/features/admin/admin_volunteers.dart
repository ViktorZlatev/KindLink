import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Call this from admin_home:  DisplayVolunteers(context);
void DisplayVolunteers(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Volunteer Applications',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) {
      return Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: const VolunteerPopup(),
        ),
      );
    },
  );
}

class VolunteerPopup extends StatefulWidget {
  const VolunteerPopup({super.key});

  @override
  State<VolunteerPopup> createState() => _VolunteerPopupState();
}

class _VolunteerPopupState extends State<VolunteerPopup> {
  bool _loading = true;
  bool _processing = false;
  List<Map<String, dynamic>> volunteers = [];

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
  }

  Future<void> _loadVolunteers() async {
    try {
      List<Map<String, dynamic>> list = [];

      final users = await FirebaseFirestore.instance.collection("users").get();

      for (var user in users.docs) {
        final sub = await user.reference
            .collection("volunteer_forms")
            .where("status", isEqualTo: "pending")
            .get();

        for (var doc in sub.docs) {
          final data = doc.data();

          list.add({
            "userId": user.id,   // 🔐 stable IDs, no name collision
            "formId": doc.id,
            "data": data,
          });
        }
      }

      if (!mounted) return;
      setState(() {
        volunteers = list;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading volunteers: $e');
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load volunteers: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  /// 🔥 Accept or reject a volunteer request
  Future<void> _handleDecision(Map<String, dynamic> v, bool accept) async {
    if (_processing) return;
    setState(() => _processing = true);

    try {
      final String? userId = v["userId"] as String?;
      final String? formId = v["formId"] as String?;

      if (userId == null || formId == null) {
        debugPrint('Missing userId or formId in volunteer map: $v');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Internal error: missing IDs.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        setState(() => _processing = false);
        return;
      }

      // 🔄 Update volunteer form status
      await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("volunteer_forms")
          .doc(formId)
          .update({"status": accept ? "accepted" : "rejected"});

      // ✅ If accepted → mark user as volunteer
      if (accept) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .update({"isVolunteer": true});
      }

      if (!mounted) return;

      // 🧽 Remove from local list
      setState(() {
        volunteers.removeWhere((item) =>
            item["userId"] == userId && item["formId"] == formId);
        _processing = false;
      });

      // 🧨 Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              accept ? 'Volunteer approved successfully.' : 'Volunteer rejected.'),
          backgroundColor: accept ? const Color(0xFF6C63FF) : Colors.redAccent,
        ),
      );

      // If no more -> close popup
      if (volunteers.isEmpty) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      debugPrint('Error updating volunteer status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() => _processing = false);
    }
  }

  Widget _volunteerCard(Map<String, dynamic> v) {
    final data = v["data"] as Map<String, dynamic>? ?? {};

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (data["name"] ?? "Unknown") as String,
            style: GoogleFonts.poppins(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 6),

          _info("Education", data["education"] as String?),
          _info("Experience", data["experience"] as String?),
          _info("Skills", data["skills"] as String?),
          _info("Motivation", data["motivation"] as String?),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ❌ Reject
              ElevatedButton(
                onPressed: _processing ? null : () => _handleDecision(v, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Reject"),
              ),

              // ✅ Accept
              ElevatedButton(
                onPressed: _processing ? null : () => _handleDecision(v, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: Text(
                  "Accept",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: (value != null && value.trim().isNotEmpty)
                  ? value
                  : "Not provided",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      backgroundColor: Colors.white.withOpacity(0.94),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 500,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Volunteer Applications",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: volunteers.isEmpty
                          ? Center(
                              child: Text(
                                "No pending applications",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: volunteers.length,
                              itemBuilder: (_, i) => _volunteerCard(
                                volunteers[i],
                              ),
                            ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      child: Text(
                        "Close",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
