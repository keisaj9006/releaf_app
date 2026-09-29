class WhatsNewItem {
  const WhatsNewItem({required this.title, required this.description});
  final String title;
  final String description;
}

class WhatsNewContent {
  const WhatsNewContent({
    required this.releaseId,
    required this.heading,
    required this.introduction,
    required this.items,
  });

  final String releaseId;
  final String heading;
  final String introduction;
  final List<WhatsNewItem> items;

  static const current = WhatsNewContent(
    releaseId: 'releaf-1.0',
    heading: 'What’s new in Releaf',
    introduction: 'A calmer way to find the next useful step.',
    items: [
      WhatsNewItem(
        title: 'Find your way through Sleep',
        description:
            'Choose Stories, Nature, Meditations or Sleep Music from a simpler night-time library.',
      ),
      WhatsNewItem(
        title: 'Reset for the moment',
        description:
            'Explore breathing methods and short practices for different situations.',
      ),
      WhatsNewItem(
        title: 'Keep going in Brain',
        description: 'Continue through more levels at a pace that suits you.',
      ),
    ],
  );
}
