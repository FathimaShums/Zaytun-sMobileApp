// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final Battery _battery = Battery();

  Position? _currentPosition;
  int _batteryLevel = 0;
  List<Contact> _contacts = [];
  bool _isLoadingLocation = false;
  bool _isLoadingContacts = false;

  @override
  void initState() {
    super.initState();
    _initBatteryState();
  }

  Future<void> _initBatteryState() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      if (mounted) {
        setState(() => _batteryLevel = batteryLevel);
      }

      _battery.onBatteryStateChanged.listen((BatteryState state) async {
        final level = await _battery.batteryLevel;
        if (mounted) {
          setState(() => _batteryLevel = level);
        }
      });
    } catch (e) {
      print('Failed to get battery level: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _getContacts() async {
    setState(() => _isLoadingContacts = true);

    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        final contacts = await ContactsService.getContacts(
          withThumbnails: false,
          orderByGivenName: true,
        );
        if (mounted) {
          setState(() {
            _contacts = contacts.toList();
            _isLoadingContacts = false;
          });
        }
      } else {
        throw Exception('Contacts permission denied');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingContacts = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing contacts: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      // Clear stored token
      // Navigate to login screen
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error logging out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hardware Features Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Battery Status
                    ListTile(
                      leading: Icon(
                        Icons.battery_full,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Battery Level'),
                      subtitle: Text('$_batteryLevel%'),
                    ),

                    const Divider(),

                    // Location
                    ListTile(
                      leading: Icon(
                        Icons.location_on,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Current Location'),
                      subtitle: _currentPosition != null
                          ? Text(
                              'Latitude: ${_currentPosition!.latitude.toStringAsFixed(4)}\n'
                              'Longitude: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                            )
                          : const Text('Location not available'),
                      trailing: _isLoadingLocation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _getCurrentLocation,
                            ),
                    ),

                    const Divider(),

                    // Contacts
                    ExpansionTile(
                      leading: Icon(
                        Icons.contacts,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: const Text('Contacts'),
                      subtitle: Text('${_contacts.length} contacts loaded'),
                      trailing: _isLoadingContacts
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _getContacts,
                            ),
                      children: [
                        if (_contacts.isEmpty)
                          const ListTile(
                            title: Text('No contacts loaded'),
                            subtitle: Text('Tap refresh to load contacts'),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _contacts.length
                                .clamp(0, 5), // Show first 5 contacts
                            itemBuilder: (context, index) {
                              final contact = _contacts[index];
                              return ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(contact.displayName ?? 'No Name'),
                                subtitle: Text(
                                  contact.phones?.firstOrNull?.value ??
                                      'No Phone',
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
