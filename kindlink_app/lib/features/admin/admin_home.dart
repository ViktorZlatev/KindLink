import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_volunteers.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int totalUsers = 0;
  int pendingVolunteers = 0;
  int activeSOS = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      // 🔹 1. Get all users
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      totalUsers = usersSnapshot.docs.length;

      // 🔹 2. For EACH user, look into /users/{uid}/volunteer_forms
      int pendingCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        final volunteerSnap = await userDoc.reference
            .collection('volunteer_forms')        // 👈 subcollection under each user
            .where('status', isEqualTo: 'pending') // only pending
            .get();

        pendingCount += volunteerSnap.docs.length;
      }

      pendingVolunteers = pendingCount;

      // 🔹 3. Count active SOS alerts (if you use this collection)
      final sosSnapshot = await FirebaseFirestore.instance
          .collection('sos_alerts')
          .where('status', isEqualTo: 'active')
          .get();
      activeSOS = sosSnapshot.docs.length;

      if (mounted) {
        setState(() => _loading = false);
      }
    } catch (e) {
      debugPrint('Error loading admin data: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildStatCard(String title, int number, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6C63FF),
                ),
              ),
              Text(
                number.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 17),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // 🔝 Top Bar
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Admin Panel",
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 22 : 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Color(0xFF6C63FF)),
                          tooltip: "Logout",
                          onPressed: _logout,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📊 Stats Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                    ),
                    child: Column(
                      children: [
                        _buildStatCard("Total Users", totalUsers, Icons.people),
                        const SizedBox(height: 16),
                        _buildStatCard("Pending Volunteers",
                            pendingVolunteers, Icons.volunteer_activism),
                        const SizedBox(height: 16),
                        _buildStatCard(
                            "Active SOS Alerts", activeSOS, Icons.warning_amber),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔧 Action Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                    ),
                    child: Column(
                      children: [
                        _buildActionButton(
                          "Review Volunteer Applications",
                          Icons.assignment,
                          () => DisplayVolunteers(context),

                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          "View SOS Alerts",
                          Icons.emergency_share,
                          () => Navigator.pushNamed(context, '/admin_sos'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
