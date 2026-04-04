import 'package:flutter/material.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'Completed', 'In Progress', 'Pending'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.purple.shade700,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple.shade700,
              tabs: const [
                Tab(text: 'Reports'),
                Tab(text: 'Activity Log'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildReportsTab(),
                _buildActivityLogTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search reports...',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple.shade400, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),

        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final selected = _selectedFilter == index;
              return ChoiceChip(
                label: Text(_filters[index]),
                selected: selected,
                onSelected: (_) => setState(() => _selectedFilter = index),
                selectedColor: Colors.purple.shade700,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: Colors.grey.shade100,
              );
            },
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              _buildReportCard(
                category: 'System Error',
                date: '28 Mar 2026',
                description: 'Database connection pool exhausted during peak load. Automatic failover was triggered.',
                status: 'Completed',
                statusColor: Colors.green,
                icon: Icons.error_outline,
                iconColor: Colors.deepOrange,
              ),
              _buildReportCard(
                category: 'Security Incident',
                date: '26 Mar 2026',
                description: 'Multiple failed login attempts detected from unknown IP range. Blocked by firewall.',
                status: 'In Progress',
                statusColor: Colors.orange,
                icon: Icons.shield_outlined,
                iconColor: Colors.blue,
              ),
              _buildReportCard(
                category: 'Performance Issue',
                date: '15 Mar 2026',
                description: 'API response times spiked above 2000ms for the /users endpoint during batch job.',
                status: 'Completed',
                statusColor: Colors.green,
                icon: Icons.speed_outlined,
                iconColor: Colors.deepPurple,
              ),
              _buildEmptyState(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLogTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildLogCard(
          title: 'Deployment successful',
          detail: 'Version 2.4.1 deployed to production.',
          date: 'Today, 06:45',
          icon: Icons.rocket_launch_outlined,
          iconColor: Colors.green,
        ),
        _buildLogCard(
          title: 'Config updated',
          detail: 'Rate limit increased from 100 to 200 req/min.',
          date: 'Today, 07:10',
          icon: Icons.tune_outlined,
          iconColor: Colors.orange,
        ),
        _buildLogCard(
          title: 'User exported data',
          detail: 'CSV export of Q1 report completed (2.3 MB).',
          date: 'Yesterday, 09:20',
          icon: Icons.download_outlined,
          iconColor: Colors.blue,
        ),
        _buildLogCard(
          title: 'Scheduled backup completed',
          detail: 'Full database snapshot stored to cloud.',
          date: 'Yesterday, 03:00',
          icon: Icons.cloud_done_outlined,
          iconColor: Colors.purple,
        ),
        _buildLogCard(
          title: 'Alert dismissed',
          detail: 'Low disk space warning cleared after cleanup.',
          date: '28 Mar 2026',
          icon: Icons.notifications_off_outlined,
          iconColor: Colors.grey,
        ),
        const SizedBox(height: 24),
        _buildEmptyState(),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // ── HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget _buildReportCard({
    required String category,
    required String date,
    required String description,
    required String status,
    required Color statusColor,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.12),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        date,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to detail page
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required String title,
    required String detail,
    required String date,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Nothing here yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items you create or receive will appear here.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: CTA action (e.g., create first item)
            },
            icon: const Icon(Icons.add),
            label: const Text('Create one'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.purple.shade700,
              side: BorderSide(color: Colors.purple.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }
}
