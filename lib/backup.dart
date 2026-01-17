import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'dart:convert';

import 'dart:async';

import 'package:http/http.dart' as http;

import 'package:flutter_tts/flutter_tts.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:permission_handler/permission_handler.dart';

class DokterPage extends StatefulWidget {
  const DokterPage({super.key});

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  DateTime selectedDate = DateTime.now();

  TimeOfDay selectedTime = TimeOfDay.now();

  List<dynamic> apiSchedules = [];

  bool isLoading = false;

  final FlutterTts flutterTts = FlutterTts();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();

    _initializeAll();
  }

  Future<void> _initializeAll() async {
    await _requestPermissions();

    await _setupNotifications();

    await _setupTts();

    fetchSchedulesFromBackend(selectedDate);

    // Refresh otomatis setiap 15 detik

    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) fetchSchedulesFromBackend(selectedDate, isSilent: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();

    flutterTts.stop();

    super.dispose();
  }

  // --- 1. MINTA IZIN ---

  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  // --- 2. SETUP NOTIFIKASI ---

  Future<void> _setupNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'jadwal_selesai_channel',
      'Pengumuman Jadwal',
      description: 'Notifikasi saat jadwal praktek dokter berakhir',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // --- 3. SETUP SUARA (TTS) ---

  Future<void> _setupTts() async {
    await flutterTts.setLanguage("id-ID");

    await flutterTts.setPitch(1.0);

    await flutterTts.setSpeechRate(0.5);

    await flutterTts.setVolume(1.0);

    await flutterTts.awaitSpeakCompletion(
      true,
    ); // Menunggu suara selesai baru lanjut
  }

  // --- TRIGGER POPUP & SUARA ---

  Future<void> _triggerAlert(String doctorName) async {
    // 1. Notifikasi Visual Popup

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'jadwal_selesai_channel',
      'Pengumuman Jadwal',
      channelDescription: 'Notifikasi jadwal berakhir',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      showWhen: true,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      'Praktek Selesai',
      'Jadwal praktek dokter $doctorName telah berakhir.',
      const NotificationDetails(android: androidDetails),
    );

    // 2. Suara Manusia (TTS)

    debugPrint("Memulai suara untuk: $doctorName");

    try {
      await flutterTts
          .stop(); // Berhentikan suara sebelumnya jika ada yang tabrakan

      await flutterTts.speak(
        "Perhatian. Dokter $doctorName telah menyelesaikan jadwal praktek. Terima kasih.",
      );
    } catch (e) {
      debugPrint("Gagal menjalankan TTS: $e");
    }
  }

  // --- LOGIKA FETCH & FILTER (DIPERBAIKI) ---

  Future<void> fetchSchedulesFromBackend(
    DateTime date, {
    bool isSilent = false,
  }) async {
    if (!isSilent) setState(() => isLoading = true);

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final url = Uri.parse(
      'http://192.168.1.31:3000/api/schedules?date=$formattedDate',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(response.body);

        DateTime now = DateTime.now();

        List<dynamic> filteredData = [];

        for (var item in rawData) {
          String endTimeStr = item['end_time'] ?? "23:59";

          List<String> parts = endTimeStr.split(':');

          // Konstruksi waktu selesai

          DateTime endDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );

          bool isExpired = now.isAfter(endDateTime);

          bool isToday = DateFormat('yyyy-MM-dd').format(date) ==
              DateFormat('yyyy-MM-dd').format(now);

          if (isExpired && isToday) {
            // Cek apakah dokter ini ada di list SEBELUMNYA (berarti dia baru saja selesai)

            bool wasInList = apiSchedules.any((old) => old['id'] == item['id']);

            if (wasInList) {
              _triggerAlert(item['Doctor']['name']);
            }

            // Jangan masukkan ke filteredData (otomatis hilang dari UI)
          } else if (!isExpired) {
            // Jika belum expired, tampilkan di list

            filteredData.add(item);
          }
        }

        if (mounted) {
          setState(() {
            apiSchedules = filteredData;

            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!isSilent && mounted) setState(() => isLoading = false);

      debugPrint("Error: $e");
    }
  }

  // --- UI METHODS ---

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.cyanAccent,
            onPrimary: Colors.black,
            surface: Color(0xFF203A43),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != selectedDate) {
      setState(() => selectedDate = picked);

      fetchSchedulesFromBackend(picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null && picked != selectedTime) {
      setState(() => selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Jadwal Dokter & Pasien',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 110),
            _buildFilterBar(),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.cyanAccent,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader(
                            "Dokter Praktek",
                            Icons.medical_services,
                          ),
                          _buildGlassList(
                            apiSchedules.isEmpty
                                ? [
                                    const Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Center(
                                        child: Text(
                                          "Tidak ada jadwal aktif",
                                          style: TextStyle(
                                            color: Colors.white38,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]
                                : apiSchedules.map((item) {
                                    final doctor = item['Doctor'];

                                    return _buildDoctorTile(
                                      doctor['name'],
                                      doctor['specialization'],
                                      "${item['start_time']} - ${item['end_time']}",
                                      Color(
                                        int.parse(
                                          doctor['accent_color'].replaceAll(
                                            '#',
                                            '0xFF',
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                          ),
                          const SizedBox(height: 25),
                          _buildSectionHeader(
                            "Jadwal Pasien Kontrol",
                            Icons.edit_calendar,
                          ),
                          _buildGlassList([
                            _buildPatientTile(
                              "Bpk. Joko",
                              "Pasca Operasi",
                              "10:30 WIB",
                              Icons.loop,
                            ),
                            _buildPatientTile(
                              "Ibu Maria",
                              "Diabetes",
                              "11:00 WIB",
                              Icons.loop,
                            ),
                          ]),
                          const SizedBox(height: 25),
                          _buildSectionHeader(
                            "Jadwal Pasien Operasi",
                            Icons.emergency,
                          ),
                          _buildGlassList([
                            _buildPatientTile(
                              "An. Rian",
                              "Appendectomy",
                              "14:00 - OK 1",
                              Icons.bolt,
                              color: Colors.redAccent,
                            ),
                          ]),
                          const SizedBox(height: 25),
                          _buildSectionHeader(
                            "Appointment BPJS",
                            Icons.assignment_turned_in,
                          ),
                          _buildGlassList([
                            _buildPatientTile(
                              "Bpk. Slamet",
                              "Rujukan FKTP",
                              "Antrian A-12",
                              Icons.credit_card,
                              color: Colors.tealAccent,
                            ),
                          ]),
                          const SizedBox(height: 25),
                          _buildSectionHeader("Pasien Batal", Icons.cancel),
                          _buildGlassList([
                            _buildPatientTile(
                              "Sdr. Kevin",
                              "Batal oleh Sistem",
                              "10:00 WIB",
                              Icons.block,
                              color: Colors.grey,
                            ),
                          ]),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI WIDGETS ---

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pilih Tanggal",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.cyanAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd MMM yyyy').format(selectedDate),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 40, color: Colors.white24),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Pilih Waktu",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.orangeAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          selectedTime.format(context),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassList(List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDoctorTile(
    String name,
    String spec,
    String status,
    Color accent,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: accent.withOpacity(0.2),
        child: Icon(Icons.person, color: accent),
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        spec,
        style: const TextStyle(color: Colors.white60, fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withOpacity(0.3)),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: accent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPatientTile(
    String name,
    String desc,
    String time,
    IconData icon, {
    Color color = Colors.blueAccent,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        name,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      subtitle: Text(
        desc,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: Text(
        time,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }
}
