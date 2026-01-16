import 'package:flutter/material.dart';
import 'rme_page.dart';

class TenagaMedisPage extends StatelessWidget {
  const TenagaMedisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Portal Tenaga Medis',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Tombol back jadi putih
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298), Color(0xFF2193b0)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. RINGKASAN DASHBOARD PASIEN ---
              _buildSectionTitle("Dashboard Pasien & Janji Temu"),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildMetricGlass("Pasien Hari Ini", "24", Icons.people_alt),
                  const SizedBox(width: 10),
                  _buildMetricGlass("Janji Temu", "8", Icons.calendar_today),
                ],
              ),

              const SizedBox(height: 25),

              // --- 2. GRID MENU MODUL UTAMA DENGAN EFEK KLIK PUTIH ---
              _buildSectionTitle("Modul Pelayanan Medis"),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.3,
                children: [
                  _buildMenuGlass(
                    "Rekam Medis (RME)",
                    Icons.history_edu,
                    Colors.orangeAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RmePage()),
                    ),
                  ),
                  _buildMenuGlass(
                    "Resep & Obat (KFA)",
                    Icons.medication,
                    Colors.greenAccent,
                  ),
                  _buildMenuGlass(
                    "Lab & Radiologi",
                    Icons.biotech,
                    Colors.blueAccent,
                  ),
                  _buildMenuGlass(
                    "Penerbitan Dokumen",
                    Icons.print,
                    Colors.white,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // --- 3. INTEGRASI DATA (SATUSEHAT/BPJS) ---
              _buildGlassContainer(
                title: "Status Integrasi Data Nasional",
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIntegrationStatus("SATUSEHAT", true),
                    _buildIntegrationStatus("BPJS (Pcare)", true),
                    _buildIntegrationStatus("SITB", false),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // --- 4. KOMUNIKASI & TELEMEDISIN ---
              _buildSectionTitle("Komunikasi & Telemedisin"),
              const SizedBox(height: 10),
              _buildGlassContainer(
                title: "Konsultasi Video 24 Jam",
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(Icons.videocam, color: Colors.white),
                  ),
                  title: const Text(
                    "3 Pasien Menunggu",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Klik untuk memulai sesi",
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                    ),
                    child: const Text("Buka Chat"),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- 5. ANALISIS & LAPORAN ---
              _buildSectionTitle("Pelaporan & 10 Besar Diagnosis"),
              const SizedBox(height: 10),
              _buildGlassContainer(
                title: "Statistik Diagnosis (ICD-10)",
                child: Column(
                  children: [
                    _buildReportRow("1. Nasopharyngitis (J00)", "45%"),
                    _buildReportRow("2. Hypertension (I10)", "30%"),
                    _buildReportRow("3. Myalgia (M79.1)", "15%"),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMetricGlass(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // MODIFIKASI: Menambahkan Material & InkWell agar card bisa diklik dengan warna highlight putih
  Widget _buildMenuGlass(
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {}, // Gunakan parameter onTap di sini
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withOpacity(0.3), // Warna splash saat diklik
        highlightColor: Colors.white.withOpacity(
          0.1,
        ), // Warna background putih tipis saat ditekan
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 35),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassContainer({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
    );
  }

  Widget _buildIntegrationStatus(String platform, bool isSynced) {
    return Column(
      children: [
        Icon(
          isSynced ? Icons.check_circle : Icons.sync_problem,
          color: isSynced ? Colors.greenAccent : Colors.orangeAccent,
        ),
        const SizedBox(height: 5),
        Text(
          platform,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildReportRow(String name, String percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white70)),
          Text(
            percentage,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
