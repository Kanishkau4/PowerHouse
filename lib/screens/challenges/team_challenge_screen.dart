import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/team_model.dart';
import 'package:powerhouse/services/team_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TeamChallengeScreen extends StatefulWidget {
  const TeamChallengeScreen({super.key});

  @override
  State<TeamChallengeScreen> createState() => _TeamChallengeScreenState();
}

class _TeamChallengeScreenState extends State<TeamChallengeScreen> {
  final _teamService = TeamService();

  List<TeamModel> _userTeams = [];
  List<TeamModel> _allTeams = [];
  List<Map<String, dynamic>> _teamLeaderboard = [];
  bool _isLoading = true;
  int _selectedTab = 0; // 0 = My Teams, 1 = All Teams, 2 = Leaderboard

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final userTeams = await _teamService.getUserTeams();
      final allTeams = await _teamService.getAllTeams();
      final leaderboard = await _teamService.getTeamLeaderboard();

      setState(() {
        _userTeams = userTeams;
        _allTeams = allTeams;
        _teamLeaderboard = leaderboard;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading team data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        title: Text(
          'Team Challenges',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline, color: context.primaryColor),
            onPressed: _showCreateTeamDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabSelector(),
          const SizedBox(height: 16),
          Expanded(child: _isLoading ? _buildLoadingState() : _buildContent()),
        ],
      ),
    );
  }

  Widget _buildTeamAvatar(String teamName) {
    // 1. Define a list of cool gradients to rotate through
    final gradients = [
      const LinearGradient(
        colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
      ), // Red/Pink
      const LinearGradient(
        colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
      ), // Blue/Cyan
      const LinearGradient(
        colors: [Color(0xFFcc2b5e), Color(0xFF753a88)],
      ), // Purple
      const LinearGradient(
        colors: [Color(0xFF56ab2f), Color(0xFFa8e063)],
      ), // Green
      const LinearGradient(
        colors: [Color(0xFFF7971E), Color(0xFFFFD200)],
      ), // Orange/Gold
      const LinearGradient(
        colors: [Color(0xFF4568DC), Color(0xFFB06AB3)],
      ), // Blue/Purple
    ];

    // 2. Define a list of cool team icons
    final icons = [
      FontAwesomeIcons.rocket,
      FontAwesomeIcons.shieldHalved,
      FontAwesomeIcons.trophy,
      FontAwesomeIcons.fire,
      FontAwesomeIcons.bolt,
      FontAwesomeIcons.crown,
      FontAwesomeIcons.dragon,
      FontAwesomeIcons.gamepad,
    ];

    // 3. Use the team name's hash code to deterministically pick an index
    // This ensures the same team name always gets the same icon/color
    final int hash = teamName.hashCode.abs();
    final gradient = gradients[hash % gradients.length];
    final icon = icons[hash % icons.length];

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: gradient, // Use the generated gradient
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: Icon(icon, color: Colors.white, size: 26)),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: context.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            _buildTab('My Teams', 0),
            _buildTab('All Teams', 1),
            _buildTab('Leaderboard', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? context.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : context.primaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildMyTeamsTab();
      case 1:
        return _buildAllTeamsTab();
      case 2:
        return _buildLeaderboardTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMyTeamsTab() {
    if (_userTeams.isEmpty) {
      return _buildEmptyState(
        'No Teams Yet',
        'Create or join a team to start team challenges!',
        Icons.groups_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _userTeams.length,
      itemBuilder: (context, index) {
        return _buildTeamCard(_userTeams[index], showJoinButton: false);
      },
    );
  }

  Widget _buildAllTeamsTab() {
    if (_allTeams.isEmpty) {
      return _buildEmptyState(
        'No Teams Available',
        'Be the first to create a team!',
        Icons.groups,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _allTeams.length,
      itemBuilder: (context, index) {
        final team = _allTeams[index];
        final isJoined = _userTeams.any((t) => t.teamId == team.teamId);
        return _buildTeamCard(team, showJoinButton: !isJoined);
      },
    );
  }

  Widget _buildLeaderboardTab() {
    if (_teamLeaderboard.isEmpty) {
      return _buildEmptyState(
        'No Teams Yet',
        'Create a team to appear on the leaderboard!',
        Icons.leaderboard,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _teamLeaderboard.length,
      itemBuilder: (context, index) {
        final team = _teamLeaderboard[index];
        return _buildLeaderboardItem(team, index + 1);
      },
    );
  }

  Widget _buildTeamCard(TeamModel team, {required bool showJoinButton}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(24), // Slightly more rounded
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // --- NEW AVATAR IMPLEMENTATION ---
              _buildTeamAvatar(team.teamName),

              // ---------------------------------
              const SizedBox(width: 16),
              // Team Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: context.primaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Members Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.inputBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 14,
                                color: context.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${team.memberCount}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: context.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // XP Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.bolt,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${team.totalXp} XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Join/View Button
              if (showJoinButton)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
                    onPressed: () => _joinTeam(team.teamId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Join',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          if (team.description != null && team.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Divider(color: context.borderColor.withOpacity(0.2), height: 1),
            const SizedBox(height: 12),
            Text(
              team.description!,
              style: TextStyle(
                fontSize: 14,
                color: context.secondaryText,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> team, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rank <= 3
            ? context.primaryColor.withOpacity(0.1)
            : context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3
              ? context.primaryColor
              : context.borderColor.withOpacity(0.3),
          width: rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rank <= 3 ? context.primaryColor : context.inputBackground,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: rank <= 3 ? Colors.white : context.primaryText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Team Name
          Expanded(
            child: Text(
              team['team_name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.primaryText,
              ),
            ),
          ),
          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${team['total_xp']} XP',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.amber,
                ),
              ),
              Text(
                '${team['member_count']} members',
                style: TextStyle(fontSize: 12, color: context.secondaryText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: context.primaryColor.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: context.secondaryText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  void _showCreateTeamDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Team Name',
                hintText: 'Enter team name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter team description',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a team name')),
                );
                return;
              }

              try {
                await _teamService.createTeam(
                  teamName: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Team created successfully!')),
                  );
                  _loadData();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinTeam(String teamId) async {
    try {
      await _teamService.joinTeam(teamId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joined team successfully!')),
      );
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error joining team: $e')));
    }
  }
}
