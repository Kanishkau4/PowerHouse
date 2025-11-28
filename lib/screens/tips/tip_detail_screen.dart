import 'package:flutter/material.dart';
import 'package:powerhouse/core/theme/theme_extensions.dart';
import 'package:powerhouse/models/models.dart';
import 'package:powerhouse/services/tips_service.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class TipDetailScreen extends StatefulWidget {
  final TipModel tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  State<TipDetailScreen> createState() => _TipDetailScreenState();
}

class _TipDetailScreenState extends State<TipDetailScreen> {
  final _tipsService = TipsService();

  bool _isBookmarked = false;
  bool _isLiked = false;
  bool _isLoading = true;

  YoutubePlayerController? _youtubeController;
  @override
  void initState() {
    super.initState();
    _loadTipProgress();
    _incrementViewCount();
    _initializeVideoPlayer(); // Add this line
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _initializeVideoPlayer() {
    if (widget.tip.videoUrl != null && widget.tip.videoUrl!.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(widget.tip.videoUrl!);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    }
  }

  Future<void> _loadTipProgress() async {
    setState(() => _isLoading = true);

    try {
      final progress = await _tipsService.getUserTipProgress(widget.tip.tipId);

      if (progress != null) {
        setState(() {
          _isBookmarked = progress.isBookmarked;
          _isLiked = progress.isLiked;
        });
      }

      // Mark as read
      await _tipsService.markTipAsRead(widget.tip.tipId);
    } catch (e) {
      print('Error loading tip progress: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _incrementViewCount() async {
    await _tipsService.incrementViewCount(widget.tip.tipId);
  }

  Future<void> _toggleBookmark() async {
    final newStatus = await _tipsService.toggleTipBookmark(widget.tip.tipId);
    setState(() {
      _isBookmarked = newStatus;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus ? 'Tip bookmarked!' : 'Bookmark removed'),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF1DAB87),
      ),
    );
  }

  Future<void> _toggleLike() async {
    final newStatus = await _tipsService.toggleTipLike(widget.tip.tipId);
    setState(() {
      _isLiked = newStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.surfaceColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image (if available)
                    if (widget.tip.hasImage) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.tip.imageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Category and Reading Time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor().withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _getCategoryColor(),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(),
                                size: 16,
                                color: _getCategoryColor(),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getCategoryDisplayName(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _getCategoryColor(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: context.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.tip.readingTimeText,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title
                    Text(
                      widget.tip.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: context.primaryText,
                        height: 1.2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Content
                    Text(
                      widget.tip.content,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.primaryText,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Video Player (if available, shown after content)
                    if (widget.tip.hasVideo && _youtubeController != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: const Color(0xFF1DAB87),
                          progressColors: const ProgressBarColors(
                            playedColor: Color(0xFF1DAB87),
                            handleColor: Color(0xFF1DAB87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Stats Row
                    _buildStatsRow(),

                    const SizedBox(height: 32),

                    // Action Buttons
                    _buildActionButtons(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back, color: context.primaryText),
            ),
          ),

          const Spacer(),

          // Bookmark Button
          GestureDetector(
            onTap: _toggleBookmark,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _isBookmarked
                    ? const Color(0xFF1DAB87)
                    : context.surfaceColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: _isBookmarked ? Colors.white : context.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(_getCategoryIcon(), size: 80, color: _getCategoryColor()),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.visibility,
            widget.tip.viewCount.toString(),
            'Views',
          ),
          Container(width: 1, height: 30, color: Colors.grey.shade300),
          _buildStatItem(
            Icons.favorite,
            widget.tip.likeCount.toString(),
            'Likes',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1DAB87)),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Like Button
        Expanded(
          child: GestureDetector(
            onTap: _toggleLike,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _isLiked
                    ? const Color(0xFFE11D48).withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isLiked
                      ? const Color(0xFFE11D48)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked
                        ? const Color(0xFFE11D48)
                        : Colors.grey.shade700,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isLiked ? 'Liked' : 'Like',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _isLiked
                          ? const Color(0xFFE11D48)
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor() {
    switch (widget.tip.category) {
      case 'exercise':
        return const Color(0xFF1DAB87);
      case 'nutrition':
        return const Color(0xFFF97316);
      case 'wisdom':
        return const Color(0xFFFFB800);
      case 'myth':
        return const Color(0xFFE11D48);
      case 'recovery':
        return const Color(0xFF8B5CF6);
      case 'lifestyle':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF1DAB87);
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.tip.category) {
      case 'exercise':
        return Icons.fitness_center;
      case 'nutrition':
        return Icons.restaurant;
      case 'wisdom':
        return Icons.lightbulb;
      case 'myth':
        return Icons.fact_check;
      case 'recovery':
        return Icons.spa;
      case 'lifestyle':
        return Icons.self_improvement;
      default:
        return Icons.tips_and_updates;
    }
  }

  String _getCategoryDisplayName() {
    switch (widget.tip.category) {
      case 'exercise':
        return 'Exercise Tips';
      case 'nutrition':
        return 'Nutrition';
      case 'wisdom':
        return 'Daily Wisdom';
      case 'myth':
        return 'Myth Busting';
      case 'recovery':
        return 'Recovery';
      case 'lifestyle':
        return 'Lifestyle';
      default:
        return widget.tip.category;
    }
  }
}
