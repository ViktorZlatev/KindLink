import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindlink/features/widgets/message.dart';

// map + popups
import 'map/map_style.dart';
import 'map/map_functions.dart';
import 'popups/popup.dart';
import 'popups/volunteer_popup.dart';
import 'popups/location.dart';
import 'popups/help_popup.dart';

// features
import 'survey.dart';
import 'resume.dart';
import 'volunteer.dart';
import 'help.dart';
import 'help_listener.dart';
import 'popups/accept_popup.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomePageState();
}

class _HomePageState extends State<Home> {
  String? username;
  bool _loading = true;
  bool _surveyCompleted = false;
  bool _isVolunteer = false;
  bool _volunteerNotified = false;
  String _volunteerStatus = "";
  bool _locationPopupShown = false;

  Map<String, Marker> _volunteerMarkers = {};

  final MapFunctions mapFunctions = MapFunctions();
  final HelpListenerService _helpListener = HelpListenerService();

  Map<String, dynamic>? _surveyData;

  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();

  static const CameraPosition _sofiaCenter = CameraPosition(
    target: LatLng(42.6977, 23.3219),
    zoom: 13,
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();

    mapFunctions.listenToVolunteerLocations(
      onMarkersUpdated: (markers) {
        if (!mounted) return;
        setState(() {
          _volunteerMarkers = markers;
        });
      },
      onMarkerTap: ({
        required String name,
        required double lat,
        required double lng,
        required dynamic updatedAt,
        required String userId,
      }) {
        showVolunteerPopupCustom(
          context,
          userId: userId,
          lat: lat,
          lng: lng,
        );
      },
    );
  }

  @override
  void dispose() {
    mapFunctions.dispose();
    _helpListener.dispose();
    super.dispose();
  }

  // --------------------------------------------------------
  // 🔥 LOAD USER + START LISTENERS
  // --------------------------------------------------------
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!snapshot.exists) {
        if (!mounted) return;
        setState(() {
          username = user.email;
          _loading = false;
        });
        return;
      }

      final data = snapshot.data()!;

      if (!mounted) return;
      setState(() {
        username = data['username'] ?? user.email;
        _surveyCompleted = data.containsKey('survey');
        _surveyData = data['survey'];
        _isVolunteer = data['isVolunteer'] == true;
        _volunteerStatus = data['VolunteerStatus'] ?? '';
        _locationPopupShown = data["location"]?["isNotified"] == true;
        _loading = false;
      });

      // ----------------------------------------------------
      // ✅ ALWAYS start location updates for volunteers
      // ----------------------------------------------------
      if (_isVolunteer) {
        await mapFunctions.startVolunteerLocationUpdates(
          onError: (msg) => showTopMessage(context, msg),
        );
      }

      // ----------------------------------------------------
      // 👇 START HELP LISTENER SYSTEM
      // ----------------------------------------------------
      _helpListener.startListening(
        isVolunteer: _isVolunteer,
        isUser: true,
        onNewRequest: (id, reqData) {
          showVolunteerHelpPopup(
            context,
            requestId: id,
            data: reqData,
          );
        },
        onVolunteerAccepted: (id, reqData) {
          showAcceptedPopupUser(
            context,
            requestId: id,
            data: reqData,
          );
        },
      );

      // ----------------------------------------------------
      // 📍 LOCATION INFO POPUP (ONLY ONCE)
      // ----------------------------------------------------
      if (_isVolunteer && !_volunteerNotified && !_locationPopupShown) {
        Future.delayed(const Duration(milliseconds: 600), () async {
          if (!mounted) return;

          showVolunteerLocationPermissionDialog(
            context,
            onAllow: () {
              showTopMessage(context, "Location sharing enabled!");
            },
            onDeny: () {
              if (!mounted) return;
              showTopMessage(context, "Your location is now shared");
            },
          );

          _locationPopupShown = true;

          try {
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId != null) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .update({
                "location.isNotified": true,
              });
            }
          } catch (e) {
            print("⚠️ Failed to update isNotified in Firestore: $e");
          }
        });
      }

      // ----------------------------------------------------
      // ❌ REJECTED VOLUNTEER MESSAGE
      // ----------------------------------------------------
      if (_volunteerStatus == "rejected" && !_volunteerNotified) {
        if (!mounted) return;
        showTopMessage(context, "Sorry, you were not approved!");
      }

      _volunteerNotified = true;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        username = user.email;
        _loading = false;
      });
    }
  }

  // --------------------------------------------------------
  // 🚨 IMMEDIATE HELP
  // --------------------------------------------------------
  void _immediateHelp() {
    showEmergencyDialog(
      context,
      surveyCompleted: _surveyCompleted,
      onConfirm: () async {
        Navigator.pop(context); // close emergency popup

        await HelpRequestService.sendImmediateHelpRequest(
          onError: (msg) {
            if (!mounted) return;
            showTopMessage(context, msg);
          },
        );

        if (!mounted) return;
        showTopMessage(context, "Emergency signal sent!");
      },
    );
  }

  // --------------------------------------------------------
  // 🧑 SURVEY
  // --------------------------------------------------------
  void _fillSurvey() {
    showSurvey(
      context,
      onConfirm: (Map<String, dynamic> surveyData) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'survey': surveyData}, SetOptions(merge: true));

        if (!mounted) return;
        setState(() {
          _surveyCompleted = true;
          _surveyData = surveyData;
        });

        showTopMessage(context, 'Survey saved successfully!');
      },
    );
  }

  // --------------------------------------------------------
  // ✏️ UPDATE HELP REQUEST FORM
  // --------------------------------------------------------
  void _requestHelp() {
    if (_surveyData == null) {
      showTopMessage(context, "No survey data found.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    showHelpRequestDialog(
      context,
      surveyData: _surveyData!,
      onSave: (updated) async {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"survey": updated});

        if (!mounted) return;
        setState(() => _surveyData = updated);

        showTopMessage(context, "Changes Saved!");
      },
    );
  }

  // --------------------------------------------------------
  // VOLUNTEER APPLICATION
  // --------------------------------------------------------
  void _becomeVolunteer() {
    if (_isVolunteer) {
      showTopMessage(context, "You are already an approved volunteer.");
      return;
    }

    showVolunteerForm(
      context,
      onConfirm: (data) {
        showTopMessage(context, 'Volunteer application submitted!');
      },
    );
  }

  // --------------------------------------------------------
  // LOGOUT
  // --------------------------------------------------------
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  // --------------------------------------------------------
  // UI + MAP
  // --------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5EF),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // MAP
                GoogleMap(
                  initialCameraPosition: _sofiaCenter,
                  markers: Set<Marker>.of(_volunteerMarkers.values),
                  onMapCreated: (controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                  },
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  style: mapStyle,
                ),

                // --------------------
                // TOP BAR
                // --------------------
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 40,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
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
                          'Hello, ${username ?? 'User'}!',
                          style: GoogleFonts.poppins(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                        Row(
                          children: [
                            _isVolunteer
                                ? Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE6D8FF),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.volunteer_activism,
                                            color: Color(0xFF6C63FF)),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Volunteer",
                                          style: GoogleFonts.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF6C63FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: _becomeVolunteer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF6C63FF),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 18),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        side: const BorderSide(
                                            color: Color(0xFF6C63FF), width: 1.2),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'Volunteer',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                            const SizedBox(width: 13),
                            IconButton(
                              icon: const Icon(Icons.logout,
                                  color: Color(0xFF6C63FF)),
                              tooltip: 'Logout',
                              onPressed: _logout,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // --------------------
                // BOTTOM BUTTONS
                // --------------------
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed:
                              _surveyCompleted ? _requestHelp : _fillSurvey,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF6C63FF),
                            padding: EdgeInsets.symmetric(
                                vertical: _surveyCompleted ? 21 : 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                              side: const BorderSide(
                                color: Color(0xFF6C63FF),
                                width: 1,
                              ),
                            ),
                            elevation: 4,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _surveyCompleted
                                    ? 'Your Resume'
                                    : 'Fill Survey',
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (!_surveyCompleted)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '*for personalization',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF6C63FF),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: ElevatedButton(
                          onPressed: _immediateHelp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: _surveyCompleted ? 12 : 21),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            elevation: 10,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Immediate Help',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_surveyCompleted)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '*personalized',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFFE8DFFF),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
