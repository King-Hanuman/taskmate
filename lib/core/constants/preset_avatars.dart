/// Curated preset avatars for TaskMate.
class PresetAvatar {
  final String id;
  final String name;
  final String url;

  const PresetAvatar({
    required this.id,
    required this.name,
    required this.url,
  });
}

class PresetAvatars {
  PresetAvatars._();

  static const List<PresetAvatar> list = [
    PresetAvatar(
      id: 'student_boy',
      name: 'Pelajar Pintar',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Felix&backgroundColor=b6e3f4',
    ),
    PresetAvatar(
      id: 'student_girl',
      name: 'Pelajar Rajin',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Aneka&backgroundColor=ffdfbf',
    ),
    PresetAvatar(
      id: 'anime_scholar',
      name: 'Kutu Buku',
      url: 'https://api.dicebear.com/7.x/lorelei/png?seed=Luna&backgroundColor=ffd5dc',
    ),
    PresetAvatar(
      id: 'coder_dev',
      name: 'Programmer',
      url: 'https://api.dicebear.com/7.x/bottts/png?seed=Sparky&backgroundColor=d1d4f9',
    ),
    PresetAvatar(
      id: 'gamer_cat',
      name: 'Gamer Pro',
      url: 'https://api.dicebear.com/7.x/bottts/png?seed=Milo&backgroundColor=b6e3f4',
    ),
    PresetAvatar(
      id: 'adventurer_hero',
      name: 'Petualang',
      url: 'https://api.dicebear.com/7.x/adventurer/png?seed=Alex&backgroundColor=c0aede',
    ),
    PresetAvatar(
      id: 'creative_artist',
      name: 'Desainer Grafis',
      url: 'https://api.dicebear.com/7.x/lorelei/png?seed=Kira&backgroundColor=ffd5dc',
    ),
    PresetAvatar(
      id: 'thinker_student',
      name: 'Filsuf Kampus',
      url: 'https://api.dicebear.com/7.x/notionists/png?seed=Sora&backgroundColor=ffdfbf',
    ),
    PresetAvatar(
      id: 'cyber_ninja',
      name: 'Ninja Digital',
      url: 'https://api.dicebear.com/7.x/adventurer/png?seed=Zane&backgroundColor=b6e3f4',
    ),
    PresetAvatar(
      id: 'cool_musician',
      name: 'Musisi Santai',
      url: 'https://api.dicebear.com/7.x/adventurer/png?seed=Leo&backgroundColor=c0aede',
    ),
    PresetAvatar(
      id: 'tech_bot',
      name: 'Asisten AI',
      url: 'https://api.dicebear.com/7.x/bottts/png?seed=Nico&backgroundColor=d1d4f9',
    ),
    PresetAvatar(
      id: 'science_star',
      name: 'Peneliti Muda',
      url: 'https://api.dicebear.com/7.x/avataaars/png?seed=Maya&backgroundColor=ffdfbf',
    ),
  ];
}
