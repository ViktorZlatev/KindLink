import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Call this from admin_home:
/// DisplayHelpRequests(context);
void DisplayHelpRequests(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Help Requests',
    barrierColor: Colors.black.withOpacity(0.45),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) {
      return Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: const HelpRequestsPopup(),
        ),
      );
    },
  );
}

class HelpRequestsPopup extends StatefulWidget {
  const HelpRequestsPopup({super.key});

  @override
  State<HelpRequestsPopup> createState() => _HelpRequestsPopupState();
}

class _HelpRequestsPopupState extends State<HelpRequestsPopup> {
  bool _loading = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('help_requests')
          .where('status', whereIn: ['awaiting_volunteer', 'pending'])
          .get();

      if (!mounted) return;

      setState(() {
        _requests = snapshot.docs;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Failed to load help requests: $e');
      if (!mounted) return;

      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load help requests'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _requestCard(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final location = data['location'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.25),
        ),
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
            'Requester',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            (data['username'] ?? 'Unknown user').toString(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C63FF),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Request ID: ${doc.id}',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),

          const SizedBox(height: 10),

          _info('Status', data['status']),
          _info(
            'Created',
            data['createdAt'] != null
                ? (data['createdAt'] as Timestamp)
                    .toDate()
                    .toLocal()
                    .toString()
                : null,
          ),
          _info('Latitude', location?['lat']?.toString()),
          _info('Longitude', location?['lng']?.toString()),

          if (data['resume'] != null) ...[
            const SizedBox(height: 10),
            Text(
              'Additional Information',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              data['resume'].toString(),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _info(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: value != null && value.toString().isNotEmpty
                  ? value.toString()
                  : '—',
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: 520,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Text(
                      'Pending Help Requests',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Expanded(
                      child: _requests.isEmpty
                          ? Center(
                              child: Text(
                                'No pending help requests',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _requests.length,
                              itemBuilder: (_, i) =>
                                  _requestCard(_requests[i]),
                            ),
                    ),

                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context, rootNavigator: true).pop(),
                      child: Text(
                        'Close',
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
