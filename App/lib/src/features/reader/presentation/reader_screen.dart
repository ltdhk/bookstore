import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;

  const ReaderScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  double _fontSize = 18.0;
  Color _backgroundColor = Colors.white;
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _showSettings = !_showSettings;
                });
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  '''
Chapter 1: The Beginning

It was a dark and stormy night. The wind howled through the trees, and the rain beat against the windows.

Alice sat by the fire, reading a book. She was so engrossed in the story that she didn't hear the knock at the door.

Suddenly, the door flew open, and a tall, dark figure stood in the doorway.

"Who are you?" Alice asked, her voice trembling.

"I am the ghost of Christmas Past," the figure replied.

Alice gasped. "But it's not Christmas!"

"I know," the ghost said. "I'm early."

... (More text here) ...
                  ''' * 20,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: _backgroundColor == Colors.black ? Colors.white : Colors.black,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            if (_showSettings)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Font Size'),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (_fontSize > 12) _fontSize -= 2;
                                  });
                                },
                              ),
                              Text('${_fontSize.toInt()}'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    if (_fontSize < 30) _fontSize += 2;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildColorButton(Colors.white, 'White'),
                          _buildColorButton(const Color(0xFFF5F5DC), 'Beige'),
                          _buildColorButton(const Color(0xFFC8E6C9), 'Green'),
                          _buildColorButton(Colors.black, 'Dark'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            if (_showSettings)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: const BackButton(color: Colors.black),
                  title: const Text('Chapter 1', style: TextStyle(color: Colors.black)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorButton(Color color, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _backgroundColor = color;
        });
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey),
          shape: BoxShape.circle,
        ),
        child: _backgroundColor == color
            ? Icon(Icons.check, color: color == Colors.black ? Colors.white : Colors.black)
            : null,
      ),
    );
  }
}
