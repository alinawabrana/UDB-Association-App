import 'package:flutter/material.dart';
import 'package:udb_association/src/features/surveys/models/survey_simple.dart';

class SurveyQuestionWidget extends StatefulWidget {
  final SurveyQuestion question;
  final int questionNumber;
  final ValueChanged<dynamic> onAnswerChanged;

  const SurveyQuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.onAnswerChanged,
  });

  @override
  State<SurveyQuestionWidget> createState() => _SurveyQuestionWidgetState();
}

class _SurveyQuestionWidgetState extends State<SurveyQuestionWidget> {
  dynamic _currentAnswer;

  @override
  void initState() {
    super.initState();
    // Initialize with default value based on question type
    if (widget.question.type == 'text') {
      _currentAnswer = '';
    } else if (widget.question.type == 'multiple_choice') {
      _currentAnswer = null;
    } else if (widget.question.type == 'rating') {
      _currentAnswer = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and text
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7C32).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.questionNumber.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7C32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.question.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Question input based on type
          _buildQuestionInput(),
        ],
      ),
    );
  }

  Widget _buildQuestionInput() {
    switch (widget.question.type) {
      case 'text':
        return _buildTextInput();
      case 'multiple_choice':
        return _buildMultipleChoiceInput();
      case 'rating':
        return _buildRatingInput();
      default:
        return _buildTextInput();
    }
  }

  Widget _buildTextInput() {
    return TextField(
      onChanged: (value) {
        _currentAnswer = value;
        widget.onAnswerChanged(_currentAnswer);
      },
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Enter your answer here...',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6B7C32)),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildMultipleChoiceInput() {
    // For now, we'll use a simple text input
    // In a real implementation, you might want to parse options from the question
    return TextField(
      onChanged: (value) {
        _currentAnswer = value;
        widget.onAnswerChanged(_currentAnswer);
      },
      decoration: InputDecoration(
        hintText: 'Enter your choice...',
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF6B7C32)),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildRatingInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final rating = index + 1;
            final isSelected = _currentAnswer == rating;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentAnswer = rating;
                });
                widget.onAnswerChanged(_currentAnswer);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  size: 32,
                  color: isSelected
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFFD1D5DB),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _currentAnswer != null ? '$_currentAnswer out of 5' : 'Tap to rate',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
