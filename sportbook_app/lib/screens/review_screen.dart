import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReviewScreen extends StatefulWidget {
  final String reservationId;

  const ReviewScreen({super.key, required this.reservationId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _success;

  Future<void> _submitReview() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _success = null;
    });

    try {
      final response = await ApiService.post('/Review', {
        'reservationId': widget.reservationId,
        'rating': _rating,
        'comment': _commentController.text.trim(),
      });

      if (response.statusCode == 200) {
        setState(() => _success = 'Review submitted successfully!');
      } else {
        setState(() => _error = response.body.isNotEmpty
            ? response.body
            : 'You have already submitted a review for this reservation.');
      }
    } catch (_) {
      setState(() => _error = 'Error submitting review.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Leave a Review')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Rating',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => setState(() => _rating = index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 48,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      _rating == 1
                          ? 'Poor'
                          : _rating == 2
                              ? 'Fair'
                              : _rating == 3
                                  ? 'Average'
                                  : _rating == 4
                                      ? 'Good'
                                      : 'Excellent!',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 4,
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child:
                    Text(_error!, style: TextStyle(color: Colors.red.shade700)),
              ),
            ],
            if (_success != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
                ),
                child: Text(_success!,
                    style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold)),
              ),
            ],
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18)),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Submit Review',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

// Backward compatibility alias
class RecenzijaScreen extends ReviewScreen {
  const RecenzijaScreen({super.key, required String idRezervacije})
      : super(reservationId: idRezervacije);
}
