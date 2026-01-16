import 'package:flutter/material.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan ExtendBodyBehindAppBar agar gradient terlihat sampai atas
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Data Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6FB7D3), // Biru Muda
              Color(0xFF4A90E2), // Biru Gelap
              Color(0xFF8E44AD), // Ungu
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAnimatedMetricSection(),
              const SizedBox(height: 30),
              _buildGlassContainer(
                title: "Monthly Revenue",
                child: _buildSimpleLineChart(),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildGlassContainer(
                      title: "Growth",
                      child: const Icon(
                        Icons.bar_chart,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildGlassContainer(
                      title: "Ratio",
                      child: const Icon(
                        Icons.pie_chart,
                        size: 80,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                "Recent Transactions",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _buildModernTable(context),
            ],
          ),
        ),
      ),
    );
  }

  // Widget 1: Kartu Metrik dengan Efek Kaca
  Widget _buildAnimatedMetricSection() {
    return Row(
      children: [
        _buildMetricCard("Users", "1,240", Icons.person, Colors.blueAccent),
        const SizedBox(width: 15),
        _buildMetricCard(
          "Profit",
          "\$4,500",
          Icons.account_balance_wallet,
          Colors.greenAccent,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    IconData icon,
    Color iconCol,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(icon, color: iconCol),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget 2: Container Efek Glassmorphism
  Widget _buildGlassContainer({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Center(child: child),
        ],
      ),
    );
  }

  // Widget 3: Simulasi Grafik Garis Modern
  Widget _buildSimpleLineChart() {
    return Container(
      height: 150,
      width: double.infinity,
      child: CustomPaint(painter: ChartPainter()),
    );
  }

  // Widget 4: Tabel Modern Transparan
  Widget _buildModernTable(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            Colors.white.withOpacity(0.2),
          ),
          columns: const [
            DataColumn(
              label: Text('ID', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Status', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Total', style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: [
            _tableRow("#001", "Paid", "\$250"),
            _tableRow("#002", "Pending", "\$120"),
            _tableRow("#003", "Paid", "\$840"),
          ],
        ),
      ),
    );
  }

  DataRow _tableRow(String id, String status, String total) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(color: Colors.white70))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: status == "Paid"
                  ? Colors.greenAccent.withOpacity(0.2)
                  : Colors.orangeAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == "Paid"
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
                fontSize: 12,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            total,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter untuk menggambar garis grafik agar estetik
class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    var path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.4,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.9,
      size.width * 0.8,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
