import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/ai_rating.dart';
import '../models/quest.dart';
import '../models/photo_history.dart';
import '../services/photo_history_service.dart';

class ResultsScreen extends StatefulWidget {
  final AIRating rating;
  final Quest quest;
  final File? photoFile;
  final Uint8List? webImageBytes;

  const ResultsScreen({
    super.key,
    required this.rating,
    required this.quest,
    this.photoFile,
    this.webImageBytes,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final PhotoHistoryService _historyService = PhotoHistoryService();
  
  @override
  void initState() {
    super.initState();
    _saveToHistory();
  }

  Future<void> _saveToHistory() async {
    final submission = PhotoSubmission(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'local_user', // Will be replaced with actual user ID when login is ready
      questId: widget.quest.id,
      questTitle: widget.quest.title,
      submittedAt: DateTime.now(),
      isApproved: widget.rating.isApproved,
      hasGreenery: widget.rating.hasGreenery,
      isOutdoors: widget.rating.isOutdoors,
      reasoning: widget.rating.reasoning,
      xpEarned: widget.rating.xpEarned,
      localImagePath: widget.photoFile?.path,
    );
    
    await _historyService.saveSubmission(submission);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Results'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Photo Preview
            Container(
              height: 300,
              width: double.infinity,
              child: kIsWeb && widget.webImageBytes != null
                  ? Image.memory(widget.webImageBytes!, fit: BoxFit.cover)
                  : widget.photoFile != null
                      ? Image.file(widget.photoFile!, fit: BoxFit.cover)
                      : const Center(child: Text('No image')),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Approval Status Card
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: widget.rating.isApproved
                              ? [Colors.green.shade600, Colors.green.shade800]
                              : [Colors.red.shade600, Colors.red.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            widget.rating.isApproved ? Icons.check_circle : Icons.cancel,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.rating.statusText,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.rating.resultMessage,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // XP Earned
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.bolt,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '+${widget.rating.xpEarned} XP Earned',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Community Voting Info
                  Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people,
                            color: Colors.blue.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Community Voting',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your photo will appear in the community feed where others can vote!',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.thumb_up, size: 16, color: Colors.green.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Likes = +5 XP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.thumb_down, size: 16, color: Colors.red.shade600),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Dislikes = -3 XP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    icon: const Icon(Icons.home, size: 24),
                    label: const Text(
                      'Return Home',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
