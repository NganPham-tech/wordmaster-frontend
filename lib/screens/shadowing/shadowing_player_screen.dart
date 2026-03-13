import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/data/models/shadowing_model.dart';
import '/controllers/shadowing_controller.dart';
import 'shadowing_segment_practice_screen.dart';
import 'widgets/audio_wave.dart';

class ShadowingPlayerScreen extends StatefulWidget {
  final ShadowingContentDetail content;

  const ShadowingPlayerScreen({super.key, required this.content});

  @override
  State<ShadowingPlayerScreen> createState() => _ShadowingPlayerScreenState();
}

class _ShadowingPlayerScreenState extends State<ShadowingPlayerScreen> {
  final ShadowingController controller = Get.find<ShadowingController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.content.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Content header
              _buildContentHeader(),
              
              const SizedBox(height: 24),

              // Practice mode cards
              _buildPracticeModeCard(
                title: 'Segment Practice',
                subtitle: 'Practice one segment at a time',
                icon: Icons.view_list,
                color: const Color(0xFF6366F1),
                onTap: () {
                  Get.to(() => ShadowingSegmentPracticeScreen(
                        content: widget.content,
                      ));
                },
              ),

              const SizedBox(height: 16),

              _buildPracticeModeCard(
                title: 'Full Audio Practice',
                subtitle: 'Record the entire content',
                icon: Icons.mic,
                color: const Color(0xFF10B981),
                onTap: _showFullPractice,
              ),

              const SizedBox(height: 24),

              // Content details
              _buildContentDetails(),

              const SizedBox(height: 24),

              // Segments preview
              _buildSegmentsPreview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white.withOpacity(0.2),
                    image: widget.content.thumbnail != null
                        ? DecorationImage(
                            image: NetworkImage(widget.content.thumbnail!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.content.thumbnail == null
                      ? const Icon(
                          Icons.audiotrack,
                          color: Colors.white,
                          size: 40,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.content.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.content.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.content.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  Icons.access_time,
                  widget.content.duration != null
                      ? '${(widget.content.duration! / 60).toStringAsFixed(0)} min'
                      : 'N/A',
                ),
                _buildStatItem(
                  Icons.format_list_numbered,
                  '${widget.content.segments.length} segments',
                ),
                _buildStatItem(
                  Icons.signal_cellular_alt,
                  widget.content.difficulty,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.9)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContentDetails() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Content Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Difficulty', widget.content.difficulty),
            const SizedBox(height: 12),
            _buildDetailRow('Accent', widget.content.accentType),
            const SizedBox(height: 12),
            _buildDetailRow('Speech Rate', widget.content.speechRate),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Word Count',
              widget.content.wordCount?.toString() ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentsPreview() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Segments Preview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.content.segments.length} total',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.content.segments.take(5).length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final segment = widget.content.segments[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    segment.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${segment.duration.toStringAsFixed(1)}s',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
            if (widget.content.segments.length > 5) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  '+ ${widget.content.segments.length - 5} more segments',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showFullPractice() {
    Get.dialog(
      Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Full Transcript',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const Divider(),
              
              // Audio controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            // TODO: Implement play/pause full audio
                            controller.playFullAudio(widget.content.audioURL!);
                          },
                          icon: const Icon(Icons.play_arrow, size: 32),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Implement stop
                            controller.stopAudio();
                          },
                          icon: const Icon(Icons.stop, size: 32),
                        ),
                      ],
                    ),
                    const Text(
                      'Play full audio to follow along',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Full transcript
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Full Transcript:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Show full transcript or segments
                        if (widget.content.transcript.isNotEmpty)
                          Text(
                            widget.content.transcript,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.black87,
                            ),
                          )
                        else
                          // If no full transcript, show segments combined
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.content.segments.map((segment) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  segment.text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.6,
                                    color: Colors.black87,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Practice button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    // TODO: Start full practice mode with recording
                    _startFullPracticeMode();
                  },
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Practice Recording'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _startFullPracticeMode() {
    // TODO: Implement full practice recording mode
    Get.snackbar(
      'Practice Mode',
      'Full practice recording will be implemented soon',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About This Content'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Title: ${widget.content.title}'),
              const SizedBox(height: 8),
              if (widget.content.description != null)
                Text('Description: ${widget.content.description}'),
              const SizedBox(height: 8),
              Text('Difficulty: ${widget.content.difficulty}'),
              const SizedBox(height: 8),
              Text('Accent: ${widget.content.accentType}'),
              const SizedBox(height: 8),
              Text('Segments: ${widget.content.segments.length}'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Full Transcript:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.content.transcript),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}