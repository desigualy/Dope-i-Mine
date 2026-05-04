import 'package:flutter/material.dart';

import '../../domain/avatar/avatar_generation_candidate.dart';

class AvatarCandidateGrid extends StatelessWidget {
  const AvatarCandidateGrid({
    super.key,
    required this.candidates,
    required this.selectedCandidate,
    required this.onSelected,
  });

  final List<AvatarGenerationCandidate> candidates;
  final AvatarGenerationCandidate? selectedCandidate;
  final ValueChanged<AvatarGenerationCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: candidates.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        final selected = selectedCandidate?.id == candidate.id;

        return _CandidateTile(
          candidate: candidate,
          selected: selected,
          onTap: () => onSelected(candidate),
        );
      },
    );
  }
}

class _CandidateTile extends StatelessWidget {
  const _CandidateTile({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  final AvatarGenerationCandidate candidate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: borderColor,
            width: selected ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                candidate.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _FallbackCandidateArt(candidate: candidate),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.62),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '${(candidate.qualityScore * 100).round()}%',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              if (candidate.hasWarnings)
                const Positioned(
                  right: 8,
                  top: 8,
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                  ),
                ),
              if (selected)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(Icons.check, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FallbackCandidateArt extends StatelessWidget {
  const _FallbackCandidateArt({required this.candidate});

  final AvatarGenerationCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final label = candidate.metadata['label'] as String? ?? 'Avatar option';
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: <Color>[Color(0xFF22D3EE), Color(0xFF111827)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.person_rounded, color: Colors.white, size: 44),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
