import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'admin_volunteers.dart';
import 'admin_requests.dart';

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
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      totalUsers = usersSnapshot.docs.length;

      int pendingCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        final volunteerSnap = await userDoc.reference
            .collection('volunteer_forms') 
            .where('status', isEqualTo: 'pending')
            .get();

        pendingCount += volunteerSnap.docs.length;
      }

      pendingVolunteers = pendingCount;

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

  void _showManageUsers(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => _ManageUsersDialog(
        onUserDeleted: _loadAdminData,
      ),
    );
  }

  Widget _buildStatCard(String title, int number, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF13131A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
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
              color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
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
                  color: const Color(0xFF8B83FF),
                ),
              ),
              Text(
                number.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
      backgroundColor: const Color(0xFF0D0D12),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13131A),
                      border: Border(
                        bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
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
                          () => DisplayHelpRequests(context),
                        ),
                        const SizedBox(height: 16),
                        _buildActionButton(
                          "Manage Users",
                          Icons.manage_accounts,
                          () => _showManageUsers(context),
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

class _ManageUsersDialog extends StatefulWidget {
  final VoidCallback onUserDeleted;

  const _ManageUsersDialog({
    required this.onUserDeleted,
  });

  @override
  State<_ManageUsersDialog> createState() => _ManageUsersDialogState();
}

class _ManageUsersDialogState extends State<_ManageUsersDialog> {
  bool _loading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final snap = await FirebaseFirestore.instance.collection("users").get();
    if (!mounted) return;
    setState(() {
      _users = snap.docs
          .map((d) => {"id": d.id, ...d.data()})
          .where((u) => u["role"] != "admin")
          .toList();
      _loading = false;
    });
  }

  Future<void> _deleteUser(String userId, String displayName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        title: Text("Delete user",
            style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          "Delete \"$displayName\"?\nThis removes them from both Authentication and Firestore so the email can be reused.",
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Cancel",
                style: GoogleFonts.poppins(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("Delete",
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFunctions.instance
          .httpsCallable("deleteUserAccount")
          .call({"userId": userId});

      if (!mounted) return;
      setState(() => _users.removeWhere((u) => u["id"] == userId));

      widget.onUserDeleted();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User deleted successfully."),
          backgroundColor: Color(0xFF6C63FF),
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.message}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      backgroundColor: const Color(0xFF13131A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 500,
          child: _loading
              ? const SizedBox(
                  height: 120,
                  child: Center(child: CircularProgressIndicator()))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Manage Users",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 420),
                      child: _users.isEmpty
                          ? Center(
                              child: Text(
                                "No users found",
                                style: GoogleFonts.poppins(
                                    color: Colors.white54),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: _users.length,
                              separatorBuilder: (_, __) => Divider(
                                  color: Colors.white.withValues(alpha: 0.07)),
                              itemBuilder: (_, i) {
                                final u = _users[i];
                                final name = u["username"] ?? u["email"] ?? "—";
                                final email = u["email"] ?? "";
                                final isVolunteer = u["isVolunteer"] == true;
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        const Color(0xFF6C63FF).withValues(alpha: 0.15),
                                    backgroundImage: u["profilePhotoUrl"] != null
                                        ? NetworkImage(u["profilePhotoUrl"])
                                        : null,
                                    child: u["profilePhotoUrl"] == null
                                        ? Icon(
                                            isVolunteer
                                                ? Icons.volunteer_activism
                                                : Icons.person,
                                            color: const Color(0xFF6C63FF),
                                            size: 20,
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    name,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "$email${isVolunteer ? "  •  Volunteer" : ""}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.redAccent),
                                    tooltip: "Delete user",
                                    onPressed: () =>
                                        _deleteUser(u["id"], name),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      child: Text(
                        "Close",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white54,
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
