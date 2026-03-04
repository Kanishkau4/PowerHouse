import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/team_model.dart';
import 'package:powerhouse/services/team_service.dart';
import 'package:powerhouse/services/challenge_service.dart';
import 'package:powerhouse/core/config/supabase_config.dart';
import 'package:powerhouse/widgets/animated_message.dart';
import 'package:powerhouse/screens/challenges/challenge_detail_screen.dart';
import 'package:powerhouse/models/challenge_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TeamDetailScreen extends StatefulWidget {
  final TeamModel team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen> {
  final TeamService _teamService = TeamService();
  final ChallengeService _challengeService = ChallengeService();

  late TeamModel _team;
  List<TeamChallengeModel> _challenges = [];
  List<TeamMemberModel> _members = [];
  bool _isLoading = true;
  bool _isCurrentUserCreator = false;

  @override
  void initState() {
    super.initState();
    _team = widget.team;
    _isCurrentUserCreator = _team.createdBy == SupabaseConfig.currentUserId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _teamService.getTeamWithChallenges(_team.teamId);
      setState(() {
        _team = data['team'] as TeamModel;
        _challenges = data['challenges'] as List<TeamChallengeModel>;
        _members = data['members'] as List<TeamMemberModel>;
      });
    } catch (e) {
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Failed to load team details: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinChallenge(String challengeId) async {
    try {
      // Create user challenge
      await _challengeService.joinChallenge(challengeId);

      // Navigate to challenge detail screen
      final userChallenge = await _challengeService.getUserChallenge(
        challengeId,
      );
      if (userChallenge != null && mounted) {
        AnimatedMessage.show(
          context,
          message: 'Successfully joined challenge!',
          backgroundColor: const Color(0xFF1DAB87),
          icon: Icons.check_circle,
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ChallengeDetailScreen(userChallenge: userChallenge),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Failed to join challenge: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditTeamSheet(
        team: _team,
        activeChallenges: _challenges,
        teamService: _teamService,
        onTeamUpdated: _loadData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1DAB87)),
            )
          : CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTeamInfo(),
                        const SizedBox(height: 32),
                        _buildChallengesSection(),
                        const SizedBox(height: 32),
                        _buildMembersSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: context.surfaceColor,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (_isCurrentUserCreator)
          IconButton(
            icon: Icon(Icons.edit, color: context.primaryText),
            onPressed: _showEditSheet,
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_team.imageUrl != null)
              Image.network(
                _team.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: const Color(0xFF1DAB87)),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1DAB87),
                      const Color(0xFF1DAB87).withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, context.surfaceColor],
                  stops: const [0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _team.teamName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        if (_team.description != null && _team.description!.isNotEmpty) ...[
          Text(
            _team.description!,
            style: TextStyle(
              fontSize: 16,
              color: context.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            _buildStatPill(
              icon: Icons.people_outline,
              value: '${_members.length} Members',
              color: context.secondaryText,
              bgColor: context.inputBackground,
            ),
            const SizedBox(width: 12),
            _buildStatPill(
              icon: Icons.bolt,
              value: '${_team.totalXp} XP',
              color: Colors.amber,
              bgColor: Colors.amber.withOpacity(0.1),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatPill({
    required IconData icon,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Challenges',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        if (_challenges.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.inputBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'No active challenges.',
                style: TextStyle(color: context.secondaryText),
              ),
            ),
          )
        else
          ..._challenges.map((c) => _buildChallengeCard(c)),
      ],
    );
  }

  Widget _buildChallengeCard(TeamChallengeModel teamChallenge) {
    final challenge = teamChallenge.challenge;
    if (challenge == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1DAB87).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.stars_rounded,
              color: Color(0xFF1DAB87),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.challengeName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${challenge.xpReward} XP • ${challenge.durationDays} Days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _joinChallenge(challenge.challengeId),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1DAB87),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Join',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Members',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: context.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        ..._members.map((member) {
          final isCreator = member.userId == _team.createdBy;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: context.inputBackground,
                  backgroundImage: member.profilePictureUrl != null
                      ? NetworkImage(member.profilePictureUrl!)
                      : null,
                  child: member.profilePictureUrl == null
                      ? Icon(Icons.person, color: context.secondaryText)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    member.username ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.primaryText,
                    ),
                  ),
                ),
                if (isCreator)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1DAB87).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CREATOR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1DAB87),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Team Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _EditTeamSheet extends StatefulWidget {
  final TeamModel team;
  final List<TeamChallengeModel> activeChallenges;
  final TeamService teamService;
  final VoidCallback onTeamUpdated;

  const _EditTeamSheet({
    required this.team,
    required this.activeChallenges,
    required this.teamService,
    required this.onTeamUpdated,
  });

  @override
  State<_EditTeamSheet> createState() => _EditTeamSheetState();
}

class _EditTeamSheetState extends State<_EditTeamSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  File? _newImage;
  bool _isLoading = false;

  final ChallengeService _challengeService = ChallengeService();
  List<ChallengeModel> _allChallenges = [];
  bool _isLoadingChallenges = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.team.teamName);
    _descController = TextEditingController(text: widget.team.description);
    _loadAllChallenges();
  }

  Future<void> _loadAllChallenges() async {
    try {
      final challenges = await _challengeService.getAllChallenges();
      setState(() {
        _allChallenges = challenges;
        _isLoadingChallenges = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingChallenges = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _newImage = File(pickedFile.path));
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? imageUrl = widget.team.imageUrl;

      if (_newImage != null) {
        imageUrl = await widget.teamService.uploadTeamImage(
          widget.team.teamId,
          _newImage!,
        );
      }

      await widget.teamService.updateTeam(
        teamId: widget.team.teamId,
        teamName: _nameController.text.trim(),
        description: _descController.text.trim(),
        imageUrl: imageUrl,
      );

      if (mounted) {
        widget.onTeamUpdated();
        Navigator.pop(context);
        AnimatedMessage.show(
          context,
          message: 'Team updated successfully',
          backgroundColor: const Color(0xFF1DAB87),
          icon: Icons.check_circle,
        );
      }
    } catch (e) {
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Error updating team: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addChallenge(String challengeId) async {
    try {
      await widget.teamService.startTeamChallenge(
        teamId: widget.team.teamId,
        challengeId: challengeId,
      );
      widget.onTeamUpdated();
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Challenge added',
          backgroundColor: const Color(0xFF1DAB87),
          icon: Icons.add_task,
        );
      }
    } catch (e) {
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Error adding challenge: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }

  Future<void> _removeChallenge(String teamChallengeId) async {
    try {
      await widget.teamService.removeTeamChallenge(teamChallengeId);
      widget.onTeamUpdated();
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Challenge removed',
          backgroundColor: const Color(0xFF1DAB87),
          icon: Icons.remove_circle,
        );
      }
    } catch (e) {
      if (mounted) {
        AnimatedMessage.show(
          context,
          message: 'Error removing challenge: $e',
          backgroundColor: Colors.red,
          icon: Icons.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: context.borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Edit Team',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 24),

                // Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: context.inputBackground,
                        shape: BoxShape.circle,
                        image: _newImage != null
                            ? DecorationImage(
                                image: FileImage(_newImage!),
                                fit: BoxFit.cover,
                              )
                            : (widget.team.imageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                        widget.team.imageUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                  : null),
                      ),
                      child: _newImage == null && widget.team.imageUrl == null
                          ? Icon(
                              Icons.add_a_photo,
                              color: context.secondaryText,
                              size: 32,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: context.primaryText),
                  decoration: InputDecoration(
                    labelText: 'Team Name',
                    fillColor: context.inputBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  style: TextStyle(color: context.primaryText),
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    fillColor: context.inputBackground,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Info Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DAB87),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Details',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                Divider(color: context.borderColor),
                const SizedBox(height: 16),

                // Manage Challenges
                Text(
                  'Manage Challenges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: context.primaryText,
                  ),
                ),
                const SizedBox(height: 16),

                if (_isLoadingChallenges)
                  const Center(child: CircularProgressIndicator())
                else
                  ..._allChallenges.map((challenge) {
                    final existingTeamChallenge = widget.activeChallenges
                        .where((tc) => tc.challengeId == challenge.challengeId)
                        .firstOrNull;
                    final isAdded = existingTeamChallenge != null;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.star,
                        color: isAdded
                            ? const Color(0xFF1DAB87)
                            : context.secondaryText,
                      ),
                      title: Text(
                        challenge.challengeName,
                        style: TextStyle(
                          color: context.primaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '+${challenge.xpReward} XP',
                        style: TextStyle(color: context.secondaryText),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isAdded ? Icons.remove_circle : Icons.add_circle,
                          color: isAdded ? Colors.red : const Color(0xFF1DAB87),
                        ),
                        onPressed: () {
                          if (isAdded) {
                            _removeChallenge(
                              existingTeamChallenge.teamChallengeId,
                            );
                          } else {
                            _addChallenge(challenge.challengeId);
                          }
                        },
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
