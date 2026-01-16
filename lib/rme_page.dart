import 'package:flutter/material.dart';

class RmePage extends StatelessWidget {
  const RmePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Rekam Medis Elektronik',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. DEMOGRAFI & RIWAYAT RINGKAS ---
              _buildGlassCard(
                title: "Demografi & Riwayat Pasien",
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.person,
                      "Nama",
                      "Tn. Budi Santoso (45th)",
                    ),
                    _buildInfoRow(
                      Icons.warning_amber,
                      "Alergi",
                      "Antibiotik Penicilin",
                      color: Colors.redAccent,
                    ),
                    _buildInfoRow(
                      Icons.vaccines,
                      "Imunisasi",
                      "BCG, Polio, COVID-19 Booster",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 2. CATATAN SOAP (Subjective, Objective, Assessment, Plan) ---
              _buildSectionTitle("Catatan SOAP"),
              const SizedBox(height: 10),
              _buildGlassCard(
                title: "",
                child: Column(
                  children: [
                    _buildSoapField(
                      "S (Subjective)",
                      "Pasien mengeluh pusing dan mual sejak kemarin malam.",
                    ),
                    _buildSoapField(
                      "O (Objective)",
                      "TD: 140/90 mmHg, Suhu: 37.5°C, Nadi: 88x/menit.",
                    ),
                    _buildSoapField(
                      "A (Assessment)",
                      "Hypertension Stage 1, Mild Dehydration.",
                    ),
                    _buildSoapField(
                      "P (Plan)",
                      "Pemberian Amlodipine 5mg, edukasi istirahat cukup.",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // --- 3. PEMERIKSAAN FISIK & KONDISI UMUM ---
              _buildSectionTitle("Pemeriksaan Fisik"),
              const SizedBox(height: 10),
              _buildGlassCard(
                title: "Kondisi Umum",
                child: const Text(
                  "Kesadaran: Compos Mentis, GCS: E4V5M6. Pemeriksaan thorax normal, abdomen supel.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 20),

              // --- 4. DIAGNOSIS (ICD-10) & TINDAKAN ---
              Row(
                children: [
                  Expanded(
                    child: _buildGlassCard(
                      title: "Diagnosis ICD-10",
                      child: const Text(
                        "I10 - Essential Hypertension",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildGlassCard(
                      title: "Tindakan Medis",
                      child: const Text(
                        "Konsultasi & Observasi TTV",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    side: const BorderSide(color: Colors.white30),
                  ),
                  child: const Text(
                    "SIMPAN REKAM MEDIS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGlassCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white10),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.white70,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoapField(String label, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
