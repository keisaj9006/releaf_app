enum DailyInsightCategory {
  movement,
  sleep,
  mind,
  connection,
  nutrition,
  nature,
}

class DailyInsight {
  const DailyInsight({
    required this.id,
    required this.category,
    required this.headline,
    required this.detail,
    required this.evidenceLabel,
    required this.evidenceNote,
    required this.sourcePublisher,
    required this.sourceTitle,
    required this.sourceUrl,
  });

  final String id;
  final DailyInsightCategory category;
  final String headline;
  final String detail;
  final String evidenceLabel;
  final String evidenceNote;
  final String sourcePublisher;
  final String sourceTitle;
  final String sourceUrl;
}

class DailyInsightCatalog {
  const DailyInsightCatalog._();

  static const List<DailyInsight> all = [
    DailyInsight(
      id: 'movement-150-300',
      category: DailyInsightCategory.movement,
      headline:
          'For adults, 150–300 minutes of moderate activity a week is the evidence-based target for substantial health benefits.',
      detail:
          'WHO guidance links regular physical activity with benefits across physical health, mental health, cognitive health and sleep. The target can be accumulated across the week rather than completed in one long session.',
      evidenceLabel: 'WHO guideline',
      evidenceNote:
          'Public-health recommendation based on a broad evidence review. It is a population target, not a personal prescription.',
      sourcePublisher: 'World Health Organization',
      sourceTitle: 'Physical activity',
      sourceUrl:
          'https://www.who.int/news-room/fact-sheets/detail/physical-activity',
    ),
    DailyInsight(
      id: 'movement-some-is-better',
      category: DailyInsightCategory.movement,
      headline:
          'You do not have to reach the full exercise target before movement starts to matter.',
      detail:
          'WHO explicitly states that some physical activity is better than none. For people who are currently inactive, increasing movement gradually can still provide health benefits.',
      evidenceLabel: 'WHO guideline',
      evidenceNote:
          'This is a population-level recommendation. The safest amount and type of activity can vary with health conditions and physical ability.',
      sourcePublisher: 'World Health Organization',
      sourceTitle: 'Physical activity',
      sourceUrl:
          'https://www.who.int/news-room/fact-sheets/detail/physical-activity',
    ),
    DailyInsight(
      id: 'walk-11-minutes',
      category: DailyInsightCategory.movement,
      headline:
          'About 11 minutes of moderate activity a day was associated with a 23% lower risk of early death in a very large analysis.',
      detail:
          'A dose-response meta-analysis of 94 prospective cohorts covering more than 30 million participants found meaningful risk reductions at activity levels below the full weekly guideline. Roughly 75 minutes of moderate activity per week — about 11 minutes a day — was associated with lower all-cause mortality than very low activity.',
      evidenceLabel: 'Dose-response meta-analysis',
      evidenceNote:
          'This is a population-level association, not a guarantee that 11 minutes changes one person’s lifespan by a fixed amount. The study analysed prospective cohorts rather than assigning people to exercise doses.',
      sourcePublisher: 'British Journal of Sports Medicine · PubMed',
      sourceTitle:
          'Non-occupational physical activity and risk of cardiovascular disease, cancer and mortality outcomes: a dose-response meta-analysis of large prospective studies',
      sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/36854652/',
    ),
    DailyInsight(
      id: 'sleep-seven-hours',
      category: DailyInsightCategory.sleep,
      headline:
          'Most adults need at least 7 hours of sleep, but sleep need still varies between people and across age.',
      detail:
          'CDC guidance recommends 7 or more hours for adults aged 18–60, with age-specific ranges for older adults. Healthy sleep also depends on quality and regularity, not duration alone.',
      evidenceLabel: 'Public-health guidance',
      evidenceNote:
          'Seven hours is a general minimum recommendation for most adults, not a universal ideal for every individual.',
      sourcePublisher: 'Centers for Disease Control and Prevention',
      sourceTitle: 'About Sleep',
      sourceUrl: 'https://www.cdc.gov/sleep/about/index.html',
    ),
    DailyInsight(
      id: 'sleep-regularity',
      category: DailyInsightCategory.sleep,
      headline:
          'A consistent sleep and wake time is more evidence-based than chasing one “perfect” bedtime.',
      detail:
          'NIH sleep guidance recommends going to bed and waking at about the same time each day and limiting large weekend shifts. Regular timing supports the body’s sleep–wake rhythm.',
      evidenceLabel: 'NIH sleep guidance',
      evidenceNote:
          'There is no single clock-time window that is best for every adult. Chronotype, work schedule, age and light exposure all matter.',
      sourcePublisher: 'NHLBI · National Institutes of Health',
      sourceTitle: 'Healthy Sleep Habits',
      sourceUrl:
          'https://www.nhlbi.nih.gov/health/sleep-deprivation/healthy-sleep-habits',
    ),
    DailyInsight(
      id: 'light-body-clock',
      category: DailyInsightCategory.sleep,
      headline:
          'Light is one of the strongest environmental signals for setting your sleep–wake rhythm.',
      detail:
          'NIH guidance on circadian rhythms highlights daytime light and reduced artificial light at night as important cues for the body clock. This is one reason morning or daytime outdoor light can support a stable routine.',
      evidenceLabel: 'NIH circadian guidance',
      evidenceNote:
          'Light timing is especially relevant to circadian rhythm. It does not mean bright light alone can fix every sleep problem.',
      sourcePublisher: 'NHLBI · National Institutes of Health',
      sourceTitle: 'Circadian Rhythm Disorders — Treatment',
      sourceUrl:
          'https://www.nhlbi.nih.gov/health/circadian-rhythm-disorders/treatment',
    ),
    DailyInsight(
      id: 'nature-120',
      category: DailyInsightCategory.nature,
      headline:
          'In a large UK study, about 120 minutes in nature per week was associated with better self-reported health and wellbeing.',
      detail:
          'The association appeared whether the time in nature came from one longer visit or several shorter visits across the week. Benefits in this study were strongest around two to five hours weekly.',
      evidenceLabel: 'Observational study',
      evidenceNote:
          'The study found an association, not proof that nature exposure directly caused the better health or wellbeing reports.',
      sourcePublisher: 'Scientific Reports',
      sourceTitle:
          'Spending at least 120 minutes a week in nature is associated with good health and wellbeing',
      sourceUrl: 'https://www.nature.com/articles/s41598-019-44097-3',
    ),
    DailyInsight(
      id: 'social-connection-health',
      category: DailyInsightCategory.connection,
      headline:
          'Social connection is a health factor: WHO links stronger connection with better health and lower risk of early death.',
      detail:
          'The WHO Commission on Social Connection reports that loneliness affects about 1 in 6 people globally and is linked with physical and mental-health harms. The report treats social connection as a public-health issue, not simply a lifestyle preference.',
      evidenceLabel: 'WHO evidence report',
      evidenceNote:
          'These are population-level findings. Loneliness and isolation are influenced by many personal and structural factors, and no single social action guarantees a health outcome.',
      sourcePublisher: 'World Health Organization',
      sourceTitle:
          'From loneliness to social connection: charting a path to healthier societies',
      sourceUrl: 'https://www.who.int/publications/i/item/978240112360',
    ),
    DailyInsight(
      id: 'mindfulness-nuance',
      category: DailyInsightCategory.mind,
      headline:
          'Mindfulness can help some people with anxiety or depression, but the average effect is modest and the evidence is not equally strong for every outcome.',
      detail:
          'Evidence reviews from NCCIH find that mindfulness-based approaches can outperform no treatment for some anxiety and depression outcomes, while comparisons with established treatments and longer-term effects are more mixed.',
      evidenceLabel: 'Evidence review',
      evidenceNote:
          'Mindfulness is a useful tool, not a universal treatment. It should not be presented as a replacement for professional care when that care is needed.',
      sourcePublisher: 'NCCIH · National Institutes of Health',
      sourceTitle: 'Meditation and Mindfulness: Effectiveness and Safety',
      sourceUrl:
          'https://www.nccih.nih.gov/health/meditation-and-mindfulness-effectiveness-and-safety',
    ),
    DailyInsight(
      id: 'vitamin-d-depression',
      category: DailyInsightCategory.nutrition,
      headline:
          'Low vitamin D levels are associated with depression, but trials have not shown that vitamin D supplements prevent or reliably treat depression.',
      detail:
          'NIH reviews distinguish an observational link from treatment evidence: people with low vitamin D are more likely to report depression, yet randomized clinical trials have not demonstrated a consistent antidepressant effect from supplementation.',
      evidenceLabel: 'NIH evidence review',
      evidenceNote:
          'Association does not prove causation. Vitamin D still has established roles in bone, muscle and other body functions; this fact is specifically about depression claims.',
      sourcePublisher: 'NIH Office of Dietary Supplements',
      sourceTitle: 'Vitamin D — Health Professional Fact Sheet',
      sourceUrl:
          'https://ods.od.nih.gov/factsheets/VITAMIND/HealthProfessional/',
    ),
    DailyInsight(
      id: 'gratitude-evidence',
      category: DailyInsightCategory.mind,
      headline:
          'Gratitude exercises show small mental-health and wellbeing benefits in trials, but some of the evidence remains low-certainty.',
      detail:
          'A systematic review and meta-analysis of randomized trials found improvements in several wellbeing outcomes and lower anxiety or depression scores in some analyses. The review also reported low or very low certainty for a number of outcomes and substantial variation between interventions.',
      evidenceLabel: 'Systematic review + meta-analysis',
      evidenceNote:
          'Gratitude can be a low-cost wellbeing practice, but it should not be sold as a treatment or a guarantee of improved mood.',
      sourcePublisher: 'Peer-reviewed research · PubMed/PMC',
      sourceTitle:
          'The effects of gratitude interventions: a systematic review and meta-analysis',
      sourceUrl: 'https://pubmed.ncbi.nlm.nih.gov/37585888/',
    ),
    DailyInsight(
      id: 'alcohol-sleep',
      category: DailyInsightCategory.sleep,
      headline:
          'Alcohol can make falling asleep feel easier while still making the night’s sleep lighter and more fragmented.',
      detail:
          'NIH sleep guidance notes that alcohol close to bedtime may make sleep onset easier but can lead to lighter sleep and more waking during the night.',
      evidenceLabel: 'NIH sleep guidance',
      evidenceNote:
          'This describes a common sleep effect and is not an assessment of anyone’s alcohol use.',
      sourcePublisher: 'NHLBI · National Institutes of Health',
      sourceTitle: 'Insomnia — Treatment',
      sourceUrl: 'https://www.nhlbi.nih.gov/health/insomnia/treatment',
    ),
    DailyInsight(
      id: 'sedentary-time',
      category: DailyInsightCategory.movement,
      headline:
          'Long periods of sedentary time matter even if you think of yourself as “someone who exercises.”',
      detail:
          'WHO guidance recommends both increasing physical activity and limiting sedentary behaviour. Higher sedentary time is associated with worse health outcomes in adults.',
      evidenceLabel: 'WHO guideline',
      evidenceNote:
          'The evidence supports moving more and sitting less overall; it does not define one universally safe maximum sitting interval.',
      sourcePublisher: 'World Health Organization',
      sourceTitle: 'Physical activity',
      sourceUrl:
          'https://www.who.int/news-room/fact-sheets/detail/physical-activity',
    ),
    DailyInsight(
      id: 'activity-immediate-benefits',
      category: DailyInsightCategory.movement,
      headline:
          'One session of moderate-to-vigorous activity can improve sleep quality and reduce short-term feelings of anxiety.',
      detail:
          'CDC guidance separates immediate from long-term exercise benefits. A single session can improve sleep quality and reduce feelings of anxiety, while regular activity adds broader benefits for brain, heart and metabolic health.',
      evidenceLabel: 'CDC public-health guidance',
      evidenceNote:
          'The size of an immediate effect varies between people and activities. This does not mean exercise replaces treatment for an anxiety disorder or sleep disorder.',
      sourcePublisher: 'Centers for Disease Control and Prevention',
      sourceTitle: 'Health Benefits of Physical Activity for Adults',
      sourceUrl:
          'https://www.cdc.gov/physical-activity-basics/health-benefits/adults.html',
    ),
    DailyInsight(
      id: 'movement-strength-two-days',
      category: DailyInsightCategory.movement,
      headline:
          'Cardio is only part of the activity picture: adults are also advised to strengthen major muscle groups on 2 or more days a week.',
      detail:
          'WHO and CDC activity guidance includes muscle-strengthening alongside aerobic activity. Examples can include weights, resistance bands, body-weight exercises and some forms of yoga.',
      evidenceLabel: 'WHO + CDC guideline',
      evidenceNote:
          'This is a population-level recommendation. Appropriate exercises and intensity depend on ability, experience and health conditions.',
      sourcePublisher: 'World Health Organization',
      sourceTitle: 'Physical activity',
      sourceUrl:
          'https://www.who.int/europe/news-room/fact-sheets/item/physical-activity',
    ),
    DailyInsight(
      id: 'nutrition-fruit-veg-400',
      category: DailyInsightCategory.nutrition,
      headline:
          'WHO recommends at least 400 g of fruit and vegetables a day for adults and children over 10 — roughly five portions.',
      detail:
          'The recommendation sits within a broader healthy-diet pattern that also includes legumes, nuts and whole grains. The total can come from a variety of fruits and vegetables rather than one specific food.',
      evidenceLabel: 'WHO nutrition guidance',
      evidenceNote:
          'This is a general population recommendation, not an individualized diet plan. Medical conditions and dietary needs can change what is appropriate.',
      sourcePublisher: 'World Health Organization',
      sourceTitle: 'Healthy diet',
      sourceUrl:
          'https://www.who.int/en/news-room/fact-sheets/detail/healthy-diet',
    ),
    DailyInsight(
      id: 'nutrition-free-sugars',
      category: DailyInsightCategory.nutrition,
      headline:
          'WHO recommends keeping free sugars below 10% of daily energy intake, with further reduction potentially adding health benefits.',
      detail:
          'Free sugars include sugars added to foods and drinks plus sugars naturally present in honey, syrups and fruit juices. They are not the same thing as all naturally occurring sugars in whole foods.',
      evidenceLabel: 'WHO guideline',
      evidenceNote:
          'The percentage is a population-level dietary recommendation. It is not a personalized calorie or carbohydrate target.',
      sourcePublisher: 'World Health Organization',
      sourceTitle: 'Healthy diet',
      sourceUrl:
          'https://www.who.int/en/news-room/fact-sheets/detail/healthy-diet',
    ),
    DailyInsight(
      id: 'nutrition-hydration-guide',
      category: DailyInsightCategory.nutrition,
      headline:
          'The UK Eatwell Guide suggests about 6–8 cups or glasses of fluid a day for most people — but needs rise with heat, illness and long periods of activity.',
      detail:
          'NHS guidance notes that water is a good default, but lower-fat milk and sugar-free drinks, including tea and coffee, can also contribute to fluid intake.',
      evidenceLabel: 'NHS guidance',
      evidenceNote:
          'Six to eight cups is a general guide rather than a fixed requirement. Pregnancy, breastfeeding, environment, activity and illness can all change fluid needs.',
      sourcePublisher: 'NHS',
      sourceTitle: 'Water, drinks and hydration',
      sourceUrl:
          'https://www.nhs.uk/live-well/eat-well/food-guidelines-and-food-labels/water-drinks-nutrition/',
    ),
    DailyInsight(
      id: 'sleep-caffeine-hours',
      category: DailyInsightCategory.sleep,
      headline:
          'Caffeine can keep affecting the body for hours: NHS guidance notes that its effects may last up to around 7 hours.',
      detail:
          'Because caffeine is a stimulant, taking it later in the day can interfere with usual sleep rhythms for some people. Sensitivity varies considerably between individuals.',
      evidenceLabel: 'NHS sleep guidance',
      evidenceNote:
          'This does not mean everyone needs the same caffeine cut-off time. Dose, metabolism, habit and individual sensitivity all matter.',
      sourcePublisher: 'NHS',
      sourceTitle: 'Self-help tips to fight tiredness',
      sourceUrl:
          'https://www.nhs.uk/live-well/sleep-and-tiredness/self-help-tips-to-fight-fatigue/',
    ),
    DailyInsight(
      id: 'nutrition-salt-five-grams',
      category: DailyInsightCategory.nutrition,
      headline:
          'WHO recommends keeping salt intake below 5 g a day for adults — about one teaspoon in total from all foods and added salt.',
      detail:
          'Most dietary salt can come from processed foods and condiments as well as salt added during cooking or at the table. WHO links lower sodium intake with lower blood pressure and cardiovascular risk.',
      evidenceLabel: 'WHO guideline',
      evidenceNote:
          'This is a population recommendation. People with specific medical conditions may receive different individualized advice.',
      sourcePublisher: 'World Health Organization',
      sourceTitle: 'Healthy diet',
      sourceUrl:
          'https://www.who.int/health-topics/healthy-diet',
    ),
  ];

  static DailyInsight forDate(DateTime date) {
    final day = DateTime.utc(date.year, date.month, date.day);
    final anchor = DateTime.utc(2026, 1, 1);
    final index = day.difference(anchor).inDays % all.length;
    return all[index < 0 ? index + all.length : index];
  }
}
