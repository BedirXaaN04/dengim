import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/story_model.dart';
import '../../core/providers/story_provider.dart';
import '../../core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryViewerScreen extends StatefulWidget {
  final UserStories userStories;

  const StoryViewerScreen({super.key, required this.userStories});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this);
    
    _loadStory(index: 0);
  }

  void _loadStory({required int index, bool animateToPage = true}) {
    _animationController.stop();
    _animationController.reset();
    _animationController.duration = const Duration(seconds: 5);
    _animationController.forward().whenComplete(() {
      _onNext();
    });

    if (animateToPage) {
      _pageController.jumpToPage(index);
    }
    
    // Mark as viewed
    context.read<StoryProvider>().viewStory(widget.userStories.stories[index].id);
  }

  void _onNext() {
    if (_currentIndex < widget.userStories.stories.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _loadStory(index: _currentIndex);
    } else {
      Navigator.pop(context);
    }
  }

  void _onPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _loadStory(index: _currentIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.userStories.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 3) {
            _onPrevious();
          } else if (details.globalPosition.dx > 2 * width / 3) {
            _onNext();
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! > 500) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            // Story Image
            CachedNetworkImage(
              imageUrl: story.imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),

            // Top Gradient
            Container(
              height: 160,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),

            // Top Info & Progress
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  children: [
                    // Progress Bars
                    Row(
                      children: List.generate(widget.userStories.stories.length, (index) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                double value = 0.0;
                                if (index < _currentIndex) {
                                  value = 1.0;
                                } else if (index == _currentIndex) {
                                  value = _animationController.value;
                                }
                                return LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.white24,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  minHeight: 2,
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // User Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: CachedNetworkImageProvider(widget.userStories.userAvatar),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.userStories.userName,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
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
    );
  }
}
