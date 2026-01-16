import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DokterPage extends StatefulWidget {
  const DokterPage({super.key});

  @override
  State<DokterPage> createState() => _DokterPageState();
}

class _DokterPageState extends State<DokterPage> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // --- FUNGSI PILIH TANGGAL ---
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyanAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF203A43),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // --- FUNGSI PILIH WAKTU ---
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
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

            // --- FILTER TANGGAL & WAKTU (STICKY BAR) ---
            Padding(
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
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(selectedDate),
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
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
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
            ),

            // --- KONTEN DINAMIS ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. DAFTAR DOKTER (LOGIKA DINAMIS)
                    _buildSectionHeader(
                      "Dokter Praktek",
                      Icons.medical_services,
                    ),
                    _buildGlassList(_getDynamicDoctorList(selectedDate)),

                    const SizedBox(height: 25),

                    // 2. JADWAL KONTROL
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

                    // 3. JADWAL OPERASI
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

                    // 4. APPOINTMENT BPJS
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

                    // 5. PASIEN BATAL
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

  // --- LOGIKA FILTER DOKTER BERDASARKAN TANGGAL ---
  List<Widget> _getDynamicDoctorList(DateTime date) {
    int day = date.day;

    if (day == 17) {
      return [
        _buildDoctorTile(
          "dr. Siska Sp.A",
          "Spesialis Anak",
          "Praktek",
          Colors.pinkAccent,
        ),
        _buildDoctorTile(
          "dr. Afif Sp.K",
          "Spesialis Kulit",
          "Praktek",
          Colors.orangeAccent,
        ),
        _buildDoctorTile(
          "dr. Iqsan Sp.PD",
          "Penyakit Dalam",
          "Praktek",
          Colors.greenAccent,
        ),
      ];
    } else if (day == 18) {
      return [
        _buildDoctorTile(
          "dr. Andre Sp.A",
          "Spesialis Anak",
          "Praktek",
          Colors.blueAccent,
        ),
        _buildDoctorTile(
          "dr. Ryan Sp.A",
          "Spesialis Anak",
          "Praktek",
          Colors.cyanAccent,
        ),
      ];
    } else if (day == 19) {
      return [
        _buildDoctorTile("dr. Rizki", "Dokter Umum", "Tersedia", Colors.white),
        _buildDoctorTile("dr. Very", "Dokter Umum", "Tersedia", Colors.white),
        _buildDoctorTile("dr. Rizal", "Dokter Umum", "Tersedia", Colors.white),
      ];
    } else {
      return [
        const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text(
              "Tidak ada jadwal dokter pada tanggal ini.",
              style: TextStyle(color: Colors.white38),
            ),
          ),
        ),
      ];
    }
  }

  // --- WIDGET HELPERS ---
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
