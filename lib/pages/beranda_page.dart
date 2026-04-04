import 'package:flutter/material.dart';

class BerandaPage extends StatefulWidget {
  final ColorScheme colorScheme;

  const BerandaPage({super.key, required this.colorScheme});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedChip = 0;
  bool _showNotice = true;

  final List<String> _filterChips = ['All', 'Recent', 'Active', 'Completed', 'Archived'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
            Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.deepPurple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildBannerRow(Icons.task_alt, 'Active Tasks: 8'),
                      const SizedBox(height: 4),
                      _buildBannerRow(Icons.notifications_active_outlined, 'Unread Alerts: 3'),
                      const SizedBox(height: 4),
                      _buildBannerRow(Icons.sync_outlined, 'Last Synced: 2 min ago'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.insert_chart_outlined, color: Colors.white, size: 32),
                      SizedBox(height: 4),
                      Text(
                        '94%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Uptime',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_showNotice) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'New features are available. Tap to learn more.',
                      style: TextStyle(fontSize: 13, color: Colors.amber.shade900),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showNotice = false),
                    child: Icon(Icons.close, size: 18, color: Colors.amber.shade700),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filterChips.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = _selectedChip == index;
                return ChoiceChip(
                  label: Text(_filterChips[index]),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedChip = index),
                  selectedColor: Colors.purple.shade700,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey.shade100,
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _buildQuickAction(Icons.add_circle_outline, 'New'),
              _buildQuickAction(Icons.search, 'Search'),
              _buildQuickAction(Icons.bar_chart_outlined, 'Reports'),
              _buildQuickAction(Icons.calendar_today_outlined, 'Calendar'),
              _buildQuickAction(Icons.settings_outlined, 'Settings'),
              _buildQuickAction(Icons.chat_bubble_outline, 'Messages'),
              _buildQuickAction(Icons.upload_outlined, 'Export'),
              _buildQuickAction(Icons.more_horiz, 'More'),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            icon: Icons.auto_awesome_outlined,
            iconColor: Colors.teal,
            title: 'AI Assistant',
            description:
                'Get intelligent suggestions and automated insights powered by on-device machine learning. Works fully offline.',
            badge: 'OFFLINE',
            badgeColor: Colors.green,
            onTap: () {
              // TODO: Navigate to AI feature
            },
          ),
          const SizedBox(height: 10),
          _buildFeatureCard(
            icon: Icons.analytics_outlined,
            iconColor: Colors.orange,
            title: 'Analytics Dashboard',
            description:
                'View detailed charts, trends, and summaries of your data. AI classifies patterns and highlights anomalies.',
            badge: 'BETA',
            badgeColor: Colors.blue,
            onTap: () {
              // TODO: Navigate to analytics
            },
          ),
          const SizedBox(height: 10),
          _buildFeatureCard(
            icon: Icons.workspace_premium_outlined,
            iconColor: Colors.amber,
            title: 'Premium Tools',
            description:
                'Unlock advanced export, collaboration, and automation features. Available on the Pro plan.',
            badge: 'PRO',
            badgeColor: Colors.purple,
            onTap: () {
              // TODO: Navigate to premium upgrade
            },
          ),

          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Summary",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(context, '24', 'Completed', Icons.check_circle_outline, Colors.purple),
                      const SizedBox(width: 12),
                      _buildStatItem(context, '3', 'Flagged', Icons.flag_outlined, Colors.red),
                      const SizedBox(width: 12),
                      _buildStatItem(context, '5', 'Pending', Icons.pending_outlined, Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Progress',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
          ),
          const SizedBox(height: 12),
          _buildProgressCard('Project Alpha', 0.72, Colors.purple),
          const SizedBox(height: 8),
          _buildProgressCard('Project Beta', 0.45, Colors.teal),
          const SizedBox(height: 8),
          _buildProgressCard('Data Migration', 0.91, Colors.green),

          const SizedBox(height: 24),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade700,
                ),
          ),
          const SizedBox(height: 12),
          _buildActivityTile(
            icon: Icons.warning_amber_outlined,
            iconColor: Colors.red,
            title: 'Critical alert triggered on Module A',
            subtitle: 'Today, 06:45 • Automated Monitor',
          ),
          _buildActivityTile(
            icon: Icons.straighten,
            iconColor: Colors.orange,
            title: 'Threshold exceeded: Value 98 > limit 80',
            subtitle: 'Today, 07:10 • Sensor Reading',
          ),
          _buildActivityTile(
            icon: Icons.send_outlined,
            iconColor: Colors.blue,
            title: 'Report submitted: Q1 Summary',
            subtitle: 'Yesterday, 15:30 • Classified: Finance',
          ),
          _buildActivityTile(
            icon: Icons.check_circle_outline,
            iconColor: Colors.green,
            title: 'Task completed: Data export for April',
            subtitle: 'Yesterday, 09:20 • Automated',
          ),
          _buildActivityTile(
            icon: Icons.sync_problem_outlined,
            iconColor: Colors.deepOrange,
            title: 'Sync failed: Remote connection timeout',
            subtitle: '28 Mar 2026 • System',
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // ── HELPER WIDGETS
  // ═══════════════════════════════════════════

  Widget _buildBannerRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to feature
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.purple.shade700, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.purple.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String count,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              count,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String label, double value, Color color) {
    final percent = (value * 100).toInt();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(
                  '$percent%',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.12),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
      ),
    );
  }
}
