/// 🌈 Custom Google Map Style (soft peach + purple tones)
const String mapStyle = '''
[
  {
    "featureType": "all",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#FFF5EF" }
    ]
  },
  {
    "featureType": "poi.park",
    "stylers": [
      { "color": "#E9E2F9" }
    ]
  },
  {
    "featureType": "road",
    "stylers": [
      { "saturation": -20 },
      { "lightness": 30 }
    ]
  },
  {
    "featureType": "water",
    "stylers": [
      { "color": "#D4C6FA" }
    ]
  }
]
''';
