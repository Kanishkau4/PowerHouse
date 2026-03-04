import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/screens/challenges/team_detail_screen.dart';
import 'package:powerhouse/models/team_model.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:powerhouse/services/team_service.dart';
import 'package:powerhouse/services/challenge_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:powerhouse/widgets/animated_message.dart';

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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TeamDetailScreen(team: team)),
        ).then((_) => _loadData()); // Reload data when returning
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(24),
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
                      onPressed: _joiningTeamIds.contains(team.teamId)
                          ? null
                          : () => _joinTeam(team.teamId),
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
                      child: _joiningTeamIds.contains(team.teamId)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateTeamSheet(
        teamService: _teamService,
        onCreated: () {
          AnimatedMessage.show(
            context,
            message: 'Team created successfully!',
            backgroundColor: context.primaryColor,
            icon: Icons.check,
          );
          _loadData();
        },
      ),
    );
  }

  final Set<String> _joiningTeamIds = {};

  Future<void> _joinTeam(String teamId) async {
    if (_joiningTeamIds.contains(teamId)) return;

    setState(() {
      _joiningTeamIds.add(teamId);
    });

    try {
      await _teamService.joinTeam(teamId);
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Joined team successfully!',
          backgroundColor: context.primaryColor,
          icon: Icons.check,
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Error joining team: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _joiningTeamIds.remove(teamId);
        });
      }
    }
  }
}

// ============================================================
// 2-step Create Team Bottom Sheet
// ============================================================

class _CreateTeamSheet extends StatefulWidget {
  final TeamService teamService;
  final VoidCallback onCreated;

  const _CreateTeamSheet({required this.teamService, required this.onCreated});

  @override
  State<_CreateTeamSheet> createState() => _CreateTeamSheetState();
}

class _CreateTeamSheetState extends State<_CreateTeamSheet> {
  final _challengeService = ChallengeService();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  int _step = 0; // 0 = team details, 1 = pick challenges
  List<ChallengeModel> _challenges = [];
  final Set<String> _selectedChallengeIds = {};
  bool _isLoadingChallenges = false;
  bool _isCreating = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadChallenges() async {
    setState(() => _isLoadingChallenges = true);
    try {
      final challenges = await _challengeService.getAllChallenges();
      if (mounted) setState(() => _challenges = challenges);
    } catch (_) {
      // If challenges fail to load, show empty list — user can still create team
    } finally {
      if (mounted) setState(() => _isLoadingChallenges = false);
    }
  }

  void _goToStep2() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Please enter a team name');
      return;
    }
    setState(() {
      _nameError = null;
      _step = 1;
    });
    _loadChallenges();
  }

  Future<void> _createTeam() async {
    setState(() => _isCreating = true);
    try {
      final team = await widget.teamService.createTeam(
        teamName: _nameController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
      );

      if (_selectedChallengeIds.isNotEmpty) {
        await widget.teamService.addChallengesToTeam(
          teamId: team.teamId,
          challengeIds: _selectedChallengeIds.toList(),
        );
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onCreated();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating team: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  // ─── challenge type helper ────────────────────────────────
  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'nutrition':
        return Icons.restaurant_outlined;
      case 'mindfulness':
        return Icons.self_improvement_outlined;
      case 'social':
        return Icons.people_outline;
      default:
        return Icons.fitness_center_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'nutrition':
        return const Color(0xFF56ab2f);
      case 'mindfulness':
        return const Color(0xFF4568DC);
      case 'social':
        return const Color(0xFFcc2b5e);
      default:
        return const Color(0xFFFF512F);
    }
  }

  // ─── build ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.surfaceColor;
    final primaryColor = context.primaryColor;
    final primaryText = context.primaryText;
    final secondaryText = context.secondaryText;
    final inputBg = context.inputBackground;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _StepDot(active: _step == 0, done: _step > 0, label: '1'),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _step > 0
                          ? primaryColor
                          : context.borderColor.withOpacity(0.3),
                    ),
                  ),
                  _StepDot(active: _step == 1, done: false, label: '2'),
                ],
              ),
            ),

            // Content
            _step == 0
                ? _buildStep1(primaryText, secondaryText, inputBg, primaryColor)
                : _buildStep2(
                    primaryText,
                    secondaryText,
                    inputBg,
                    primaryColor,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1(
    Color primaryText,
    Color secondaryText,
    Color inputBg,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Team',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: primaryText,
            ),
          ),
          Text(
            'Step 1 of 2 · Team Details',
            style: TextStyle(fontSize: 13, color: secondaryText),
          ),
          const SizedBox(height: 20),

          // Name field
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Team Name *',
              hintText: 'e.g. Power Squad',
              errorText: _nameError,
              prefixIcon: const Icon(Icons.groups_outlined),
            ),
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: 16),

          // Description field
          TextField(
            controller: _descController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'What is your team about?',
              prefixIcon: Icon(Icons.notes_outlined),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // Action row
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _goToStep2,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(
    Color primaryText,
    Color secondaryText,
    Color inputBg,
    Color primaryColor,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick Challenges',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: primaryText,
              ),
            ),
            Text(
              'Step 2 of 2 · Select one or more (optional)',
              style: TextStyle(fontSize: 13, color: secondaryText),
            ),
            const SizedBox(height: 16),

            // Challenge list
            Expanded(
              child: _isLoadingChallenges
                  ? const Center(child: CircularProgressIndicator())
                  : _challenges.isEmpty
                  ? Center(
                      child: Text(
                        'No challenges available',
                        style: TextStyle(color: secondaryText),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _challenges.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final c = _challenges[i];
                        final selected = _selectedChallengeIds.contains(
                          c.challengeId,
                        );
                        final typeColor = _typeColor(c.challengeType);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selected) {
                                _selectedChallengeIds.remove(c.challengeId);
                              } else {
                                _selectedChallengeIds.add(c.challengeId);
                              }
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primaryColor.withOpacity(0.08)
                                  : inputBg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? primaryColor
                                    : context.borderColor.withOpacity(0.3),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Type icon bubble
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: typeColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _typeIcon(c.challengeType),
                                    color: typeColor,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.challengeName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: primaryText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          // XP pill
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.amber.withOpacity(
                                                0.12,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.bolt,
                                                  size: 12,
                                                  color: Colors.amber,
                                                ),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${c.xpReward} XP',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.amber,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          // Duration pill
                                          Text(
                                            '${c.durationDays}d · ${c.targetValue} ${c.unit}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Checkbox
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? primaryColor
                                          : context.borderColor.withOpacity(
                                              0.5,
                                            ),
                                      width: 2,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Selection count hint
            if (_selectedChallengeIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '${_selectedChallengeIds.length} challenge${_selectedChallengeIds.length == 1 ? '' : 's'} selected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Action row
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isCreating
                        ? null
                        : () => setState(() => _step = 0),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isCreating ? null : _createTeam,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _selectedChallengeIds.isEmpty
                                ? 'Create (Skip Challenges)'
                                : 'Create Team',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── tiny helper widget ──────────────────────────────────────────────────────
class _StepDot extends StatelessWidget {
  final bool active;
  final bool done;
  final String label;

  const _StepDot({
    required this.active,
    required this.done,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.primaryColor;
    final filled = active || done;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: filled ? primaryColor : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? primaryColor : context.borderColor.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : context.secondaryText,
                ),
              ),
      ),
    );
  }
}
