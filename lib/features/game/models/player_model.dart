enum PlayerRole { civilian, imposter }

class PlayerModel {
  const PlayerModel({
    required this.id,
    required this.name,
    this.role = PlayerRole.civilian,
    this.secretWord = '',
    this.hint = '',
    this.isEliminated = false,
  });

  final String id;
  final String name;
  final PlayerRole role;
  final String secretWord;
  final String hint;
  final bool isEliminated;

  bool get isImposter => role == PlayerRole.imposter;

  PlayerModel copyWith({
    String? id,
    String? name,
    PlayerRole? role,
    String? secretWord,
    String? hint,
    bool? isEliminated,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      secretWord: secretWord ?? this.secretWord,
      hint: hint ?? this.hint,
      isEliminated: isEliminated ?? this.isEliminated,
    );
  }
}
