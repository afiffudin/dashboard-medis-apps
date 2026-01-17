import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class DokterPage extends StatefulWidget {
  const DokterPage({super.key});

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  // --- STATE VARIABLES ---
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  List<dynamic> apiSchedules = []; // Data asli dari API (setelah filter jam)
  List<dynamic> filteredSchedules =
      []; // Data untuk ditampilkan (setelah filter nama & poli)
  bool isLoading = false;

  // Controller & Dropdown State
  final TextEditingController _searchDoctorController = TextEditingController();
  String selectedSpecialization = "Semua Poli";
  List<String> specializationOptions = ["Semua Poli"];

  final FlutterTts flutterTts = FlutterTts();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    // Mencegah HP masuk mode tidur agar koneksi socket/http tetap stabil saat kabel dicabut
    WakelockPlus.enable();
    _initializeAll();
  }

  Future<void> _initializeAll() async {
    await _requestPermissions();
    await _setupNotifications();
    await _setupTts();
    fetchSchedulesFromBackend(selectedDate);

    // Auto refresh data setiap 15 detik
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) fetchSchedulesFromBackend(selectedDate, isSilent: true);
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchDoctorController.dispose();
    flutterTts.stop();
    WakelockPlus.disable();
    super.dispose();
  }

  // --- LOGIC: PERMISSIONS & SETUP ---
  Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> _setupNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: androidInit),
    );

    const channel = AndroidNotificationChannel(
      'jadwal_selesai_channel',
      'Pengumuman Jadwal',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage("id-ID");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  // --- LOGIC: TRIGGER SUARA & NOTIFIKASI ---
  Future<void> _triggerAlert(String doctorName) async {
    const androidDetails = AndroidNotificationDetails(
      'jadwal_selesai_channel',
      'Pengumuman Jadwal',
      importance: Importance.max,
      priority: Priority.high,
    );
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      'Praktek Selesai',
      'Dokter $doctorName telah selesai praktek.',
      const NotificationDetails(android: androidDetails),
    );
    await flutterTts.speak(
      "Perhatian. Dokter $doctorName telah menyelesaikan jadwal praktek. Terima kasih.",
    );
  }

  // --- LOGIC: FETCH & FILTER ---
  Future<void> fetchSchedulesFromBackend(DateTime date,
      {bool isSilent = false}) async {
    if (!isSilent) setState(() => isLoading = true);

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    // Ganti IP di bawah sesuai dengan IP Laptop Anda
    final url =
        Uri.parse('http://192.168.1.31:3000/api/schedules?date=$formattedDate');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        List<dynamic> rawData = json.decode(response.body);

        // 1. Filter berdasarkan Jam yang dipilih di Layar (Simulasi)
        DateTime comparisonTime = DateTime(
          date.year,
          date.month,
          date.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        List<dynamic> activeNow = [];
        Set<String> uniquePolis = {"Semua Poli"};

        for (var item in rawData) {
          String endTimeStr = item['end_time'] ?? "23:59";
          List<String> parts = endTimeStr.split(':');
          DateTime endDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );

          if (comparisonTime.isAfter(endDateTime)) {
            // Jika dokter baru saja hilang dari daftar, bunyikan suara
            bool wasInList = apiSchedules.any((old) => old['id'] == item['id']);
            if (wasInList) {
              _triggerAlert(item['Doctor']['name']);
            }
          } else {
            activeNow.add(item);
            uniquePolis.add(item['Doctor']['specialization']);
          }
        }

        if (mounted) {
          setState(() {
            apiSchedules = activeNow;
            specializationOptions = uniquePolis.toList()..sort();

            // Validasi agar pilihan dropdown tidak error jika data hilang
            if (!specializationOptions.contains(selectedSpecialization)) {
              selectedSpecialization = "Semua Poli";
            }

            _applyLocalFilters();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!isSilent && mounted) setState(() => isLoading = false);
      debugPrint("Error: $e");
    }
  }

  void _applyLocalFilters() {
    setState(() {
      filteredSchedules = apiSchedules.where((item) {
        final doctorName = item['Doctor']['name'].toString().toLowerCase();
        final specName = item['Doctor']['specialization'].toString();
        final searchQuery = _searchDoctorController.text.toLowerCase();

        bool matchName = doctorName.contains(searchQuery);
        bool matchSpec = (selectedSpecialization == "Semua Poli") ||
            (specName == selectedSpecialization);

        return matchName && matchSpec;
      }).toList();
    });
  }

  // --- UI BUILDING ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard RS Digital',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            _buildMainFilterCard(),
            _buildSearchRow(),
            Expanded(
              child: isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: Colors.cyanAccent))
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      children: [
                        _buildSectionHeader(
                            "Dokter Praktek Aktif", Icons.medical_services),
                        _buildGlassList(
                          filteredSchedules.isEmpty
                              ? [
                                  const Center(
                                      child: Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Text(
                                              "Tidak ada dokter ditemukan",
                                              style: TextStyle(
                                                  color: Colors.white38))))
                                ]
                              : filteredSchedules.map((item) {
                                  final doc = item['Doctor'];
                                  return _buildDoctorTile(
                                    doc['name'],
                                    doc['specialization'],
                                    "${item['start_time']} - ${item['end_time']}",
                                    Color(int.parse(doc['accent_color']
                                        .replaceAll('#', '0xFF'))),
                                  );
                                }).toList(),
                        ),
                        const SizedBox(height: 25),
                        _buildSectionHeader(
                            "Jadwal Pasien Kontrol", Icons.edit_calendar),
                        _buildGlassList([
                          _buildPatientTile("Bpk. Joko", "Pasca Operasi",
                              "10:30 WIB", Icons.loop),
                          _buildPatientTile(
                              "Ibu Maria", "Diabetes", "11:00 WIB", Icons.loop),
                        ]),
                        const SizedBox(height: 25),
                        _buildSectionHeader(
                            "Jadwal Pasien Operasi", Icons.emergency),
                        _buildGlassList([
                          _buildPatientTile("An. Rian", "Appendectomy",
                              "14:00 - OK 1", Icons.bolt,
                              color: Colors.redAccent),
                        ]),
                        const SizedBox(height: 25),
                        _buildSectionHeader(
                            "Appointment BPJS", Icons.assignment_turned_in),
                        _buildGlassList([
                          _buildPatientTile("Bpk. Slamet", "Rujukan FKTP",
                              "Antrian A-12", Icons.credit_card,
                              color: Colors.tealAccent),
                        ]),
                        const SizedBox(height: 25),
                        _buildSectionHeader("Pasien Batal", Icons.cancel),
                        _buildGlassList([
                          _buildPatientTile("Sdr. Kevin", "Batal oleh Sistem",
                              "10:00 WIB", Icons.block,
                              color: Colors.grey),
                        ]),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildMainFilterCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDate(),
              child: Column(
                children: [
                  const Text("Tanggal",
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd MMM yyyy').format(selectedDate),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 30, color: Colors.white24),
          Expanded(
            child: InkWell(
              onTap: () => _selectTime(),
              child: Column(
                children: [
                  const Text("Jam Simulasi",
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(selectedTime.format(context),
                      style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _searchDoctorController,
                onChanged: (_) => _applyLocalFilters(),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: "Cari dokter...",
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.cyanAccent, size: 18),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedSpecialization,
                  dropdownColor: const Color(0xFF203A43),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  icon: const Icon(Icons.filter_list,
                      color: Colors.cyanAccent, size: 18),
                  items: specializationOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedSpecialization = val;
                        _applyLocalFilters();
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Icon(icon, color: Colors.cyanAccent, size: 20),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildGlassList(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDoctorTile(
      String name, String spec, String status, Color accent) {
    return ListTile(
      leading: CircleAvatar(
          backgroundColor: accent.withOpacity(0.2),
          child: Icon(Icons.person, color: accent)),
      title: Text(name,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      subtitle: Text(spec,
          style: const TextStyle(color: Colors.white60, fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Text(status,
            style: TextStyle(
                color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPatientTile(String name, String desc, String time, IconData icon,
      {Color color = Colors.blueAccent}) {
    return ListTile(
      leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 18)),
      title:
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: Text(desc,
          style: const TextStyle(color: Colors.white54, fontSize: 12)),
      trailing: Text(time,
          style: const TextStyle(color: Colors.white70, fontSize: 11)),
    );
  }

  // --- PICKERS ---
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
      fetchSchedulesFromBackend(picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null) {
      setState(() => selectedTime = picked);
      fetchSchedulesFromBackend(selectedDate);
    }
  }
}
