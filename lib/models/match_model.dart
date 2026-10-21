// lib/models/match_model.dart

enum MatchType { treino, oficial }
enum ScoutSkill { serveAce, reception, set, attack, block, dig, freeball, opponentError, fault }

enum SkillQuality {
  error,    // Erro direto
  poor,     // Ruim
  neutral,  // Neutro
  good,     // Bom
  perfect   // Perfeito
}

enum ErrorDetail {
  none,     // Nenhum
  blocked,  // Bloqueado
  out,      // Fora
  net       // Rede (Ataque/Saque na rede)
}

// NOVO: Tipos de Faltas/Infrações Genéricas
enum FaultType {
  none,
  whosBall,     // Bola de quem? (Caiu sem ninguém ir)
  rotation,     // Erro de Rotação
  netFault,     // Toque na rede (Infração)
  ballHandling, // Dois toques / Condução
  invasion,     // Invasão por cima ou por baixo
  other         // Outros
}

class Player {
  String name;
  int number;
  Player({required this.name, required this.number});
}

class Team {
  String name;
  List<Player> players;
  Team({required this.name, required this.players});
}

class MatchSetup {
  final Team team;
  final List<Player> startingSix;
  final Player? libero;
  final Player setter;
  final List<Player> middles;

  MatchSetup({
    required this.team,
    required this.startingSix,
    this.libero,
    required this.setter,
    required this.middles,
  });
}

class MatchAction {
  final Team team;
  final Player? player; // Pode ser null em erro de time (ex: Rotação)
  final ScoutSkill skill;
  final SkillQuality quality;
  final ErrorDetail errorDetail;
  final FaultType faultType; // <--- NOVO CAMPO
  final int homeScoreNow;
  final int guestScoreNow;

  MatchAction({
    required this.team,
    this.player,
    required this.skill,
    this.quality = SkillQuality.perfect,
    this.errorDetail = ErrorDetail.none,
    this.faultType = FaultType.none, // <--- Padrão
    required this.homeScoreNow,
    required this.guestScoreNow,
  });

  String get description {
    if (skill == ScoutSkill.fault) {
      String faultName = "";
      switch (faultType) {
        case FaultType.whosBall: faultName = "WHO'S BALL"; break;
        case FaultType.rotation: faultName = "ERRO DE ROTAÇÃO"; break;
        case FaultType.netFault: faultName = "TOQUE NA REDE"; break;
        case FaultType.ballHandling: faultName = "2 TOQUES/CONDUÇÃO"; break;
        case FaultType.invasion: faultName = "INVASÃO"; break;
        case FaultType.other: faultName = "OUTRO ERRO"; break;
        default: faultName = "ERRO";
      }
      // MUDANÇA AQUI: Se tiver jogador, usa o nome dele. Se não, usa o nome do time.
      String subject = player?.name ?? team.name;
      return "$subject - $faultName";
    }

    if (skill == ScoutSkill.opponentError) return "Erro do adversário";
    
    String skillName = skill.name.toUpperCase();
    String qualityText = quality.toString().split('.').last.toUpperCase();
    
    if (errorDetail != ErrorDetail.none) {
      String detailText = errorDetail.toString().split('.').last.toUpperCase();
      return "${player?.name} - $skillName [ERRO - $detailText]";
    }

    return "${player?.name} - $skillName [$qualityText]";
  }
}

class VolleyMatch {
  Team homeTeam;
  Team guestTeam;
  DateTime date;
  List<MatchAction> history = []; 

  VolleyMatch({
    required this.homeTeam,
    required this.guestTeam,
  }) : date = DateTime.now();
}