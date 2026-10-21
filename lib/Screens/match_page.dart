import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../widgets/volleyball_court.dart';

class MatchPage extends StatefulWidget {
  final MatchSetup homeSetup;
  final MatchSetup guestSetup;
  final Team startingServerTeam;

  const MatchPage({
    super.key,
    required this.homeSetup,
    required this.guestSetup,
    required this.startingServerTeam,
  });

  @override
  State<MatchPage> createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  int _homeScore = 0;
  int _guestScore = 0;
  List<MatchAction> actionLog = [];

  late Team _servingTeam;
  bool _isServingPhase = true; 
  bool _expectingReception = false; 

  late List<Player> _homeLineup;
  late List<Player> _guestLineup;

  // Controle de substituição do Líbero
  Player? _homeMbReplaced;
  Player? _guestMbReplaced;

  @override
  void initState() {
    super.initState();
    _servingTeam = widget.startingServerTeam;
    _homeLineup = List.from(widget.homeSetup.startingSix);
    _guestLineup = List.from(widget.guestSetup.startingSix);
  }

  void _checkLiberoSwaps() {
    // 1. ENTRADA (Perdeu saque -> Líbero entra no lugar do Central na P1)
    if (widget.homeSetup.libero != null) {
      Player p1 = _homeLineup[0];
      bool isHomeServing = _servingTeam.name == widget.homeSetup.team.name;
      if (_isMiddle(p1, widget.homeSetup) && !isHomeServing) {
         _homeMbReplaced = p1;
         _homeLineup[0] = widget.homeSetup.libero!;
         _showToast("Líbero (Casa) entrou!");
      }
    }

    if (widget.guestSetup.libero != null) {
      Player p1 = _guestLineup[0];
      bool isGuestServing = _servingTeam.name == widget.guestSetup.team.name;
      if (_isMiddle(p1, widget.guestSetup) && !isGuestServing) {
         _guestMbReplaced = p1;
         _guestLineup[0] = widget.guestSetup.libero!;
         _showToast("Líbero (Visitante) entrou!");
      }
    }

    // 2. SAÍDA (Rodou para P4 -> Líbero sai, Central volta)
    if (widget.homeSetup.libero != null) {
      if (_homeLineup[3].number == widget.homeSetup.libero!.number && _homeMbReplaced != null) {
          _homeLineup[3] = _homeMbReplaced!;
          _homeMbReplaced = null;
          _showToast("Central (Casa) voltou!");
      }
    }

    if (widget.guestSetup.libero != null) {
      if (_guestLineup[3].number == widget.guestSetup.libero!.number && _guestMbReplaced != null) {
          _guestLineup[3] = _guestMbReplaced!;
          _guestMbReplaced = null;
          _showToast("Central (Visitante) voltou!");
      }
    }
  }

  bool _isMiddle(Player p, MatchSetup setup) {
    return setup.middles.any((m) => m.number == p.number);
  }

  void _rotateTeam(Team team) {
    setState(() {
      List<Player> lineupToRotate = (team.name == widget.homeSetup.team.name) 
          ? _homeLineup 
          : _guestLineup;

      Player playerMovingToServe = lineupToRotate.removeLast();
      lineupToRotate.insert(0, playerMovingToServe);
      
      _checkLiberoSwaps();
    });
  }

  void _handlePlayerTap(Team teamFromTap, Player player) {
    bool isHomeTeam = teamFromTap.name == widget.homeSetup.team.name;
    Team realTeam = isHomeTeam ? widget.homeSetup.team : widget.guestSetup.team;

    if (_isServingPhase) {
      if (realTeam.name != _servingTeam.name) {
        _showToast("Vez do ${_servingTeam.name} sacar!");
        return;
      }
      List<Player> currentLineup = isHomeTeam ? _homeLineup : _guestLineup;
      if (player.number != currentLineup[0].number) {
        _showToast("O sacador é o #${currentLineup[0].number}!");
        return;
      }
      _showServeMenu(realTeam, player);
      return;
    }

    if (_expectingReception) {
      if (realTeam.name == _servingTeam.name) {
        _showToast("O time que sacou não recebe!");
        return;
      }
      _showReceptionMenu(realTeam, player);
      return;
    }

    _showRallyMenu(realTeam, player);
  }

  // --- MENUS DE AÇÃO ---

  void _showServeMenu(Team team, Player player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        child: Column(
          children: [
            Text("Saque de ${player.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(team, player, ScoutSkill.serveAce, "ACE", Colors.green[700]!, SkillQuality.perfect),
                _actionButton(team, player, ScoutSkill.serveAce, "EM JOGO", Colors.blue, SkillQuality.neutral),
                _actionButton(team, player, ScoutSkill.serveAce, "ERRO", Colors.red, SkillQuality.error),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showReceptionMenu(Team team, Player player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 250,
        child: Column(
          children: [
            Text("Recepção de ${player.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(team, player, ScoutSkill.reception, "(++) Passe A", Colors.green[700]!, SkillQuality.perfect),
                _actionButton(team, player, ScoutSkill.reception, "(+) Passe B", Colors.green, SkillQuality.good),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(team, player, ScoutSkill.reception, "(-) Passe C", Colors.amber, SkillQuality.neutral),
                _actionButton(team, player, ScoutSkill.reception, "(/) Quebrado", Colors.orange, SkillQuality.poor),
                _actionButton(team, player, ScoutSkill.reception, "(=) Erro", Colors.red, SkillQuality.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRallyMenu(Team team, Player player) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 380,
        child: Column(
          children: [
            Text("O que ${player.name} fez?", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white), icon: const Icon(Icons.flash_on), label: const Text("ATAQUE"), onPressed: () { Navigator.pop(context); _showAttackOptions(team, player); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white), icon: const Icon(Icons.front_hand), label: const Text("BLOQUEIO"), onPressed: () { Navigator.pop(context); _showBlockOptions(team, player); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white), icon: const Icon(Icons.pan_tool_alt), label: const Text("LEVANTAMENTO"), onPressed: () { Navigator.pop(context); _showSetOptions(team, player); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white), icon: const Icon(Icons.call_received), label: const Text("FREE BALL"), onPressed: () { Navigator.pop(context); _showFreeBallOptions(team, player); })),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white), icon: const Icon(Icons.sports_volleyball), label: const Text("DEFESA"), onPressed: () { Navigator.pop(context); _showDigOptions(team, player); })),
          ],
        ),
      ),
    );
  }

  // Menu Principal de Erros
  void _showGeneralFaultMenu(Team faultTeam) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 350,
        child: Column(
          children: [
            Text("ERRO: ${faultTeam.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
            const Text("Qual foi a infração?", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                // Agora chamamos uma função intermediária _onFaultOptionSelected
                _faultButton(faultTeam, FaultType.whosBall, "WHO'S BALL"),
                _faultButton(faultTeam, FaultType.rotation, "ROTAÇÃO"),
                _faultButton(faultTeam, FaultType.netFault, "REDE"),
                _faultButton(faultTeam, FaultType.ballHandling, "2 TOQUES / COND"),
                _faultButton(faultTeam, FaultType.invasion, "INVASÃO"),
                _faultButton(faultTeam, FaultType.other, "OUTROS"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _faultButton(Team team, FaultType type, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100], foregroundColor: Colors.red[900]),
      // Chama a nova lógica de decisão
      onPressed: () => _onFaultOptionSelected(team, type), 
      child: Text(label),
    );
  }
  // NOVO MENU: Quem cometeu a falta?
  void _showFaultPlayerSelect(Team team, FaultType type) {
    // Descobre qual é a escalação atual desse time (para mostrar só quem tá em quadra)
    List<Player> activePlayers = (team.name == widget.homeSetup.team.name) 
        ? _homeLineup 
        : _guestLineup;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 400,
        child: Column(
          children: [
            const Text("Quem cometeu o erro?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
            const SizedBox(height: 20),
            
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: activePlayers.length,
                itemBuilder: (context, index) {
                  final player = activePlayers[index];
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, side: const BorderSide(color: Colors.grey)),
                    onPressed: () => _registerFault(team, type, player), // Registra com o jogador!
                    child: Text("#${player.number} ${player.name}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NOVA FUNÇÃO: Decide se precisa pedir o jogador ou não
  void _onFaultOptionSelected(Team team, FaultType type) {
    // Fecha o menu de tipos de erro
    Navigator.pop(context); 

    // LISTA DE EXCEÇÕES: Erros que continuam genéricos (sem jogador)
    if (type == FaultType.whosBall || type == FaultType.other) {
      _registerFault(team, type, null); // Manda null no jogador
    } else {
      // Para Rede, Invasão, 2 Toques, Rotação -> Pedimos QUEM FOI
      _showFaultPlayerSelect(team, type);
    }
  }

  // --- SUB-MENUS ---
  void _showAttackOptions(Team team, Player player) {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        child: Column(
          children: [
            Text("Qualidade do ATAQUE", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(team, player, ScoutSkill.attack, "KILL", Colors.green, SkillQuality.perfect),
                _actionButton(team, player, ScoutSkill.attack, "EM JOGO", Colors.blue, SkillQuality.neutral),
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () { Navigator.pop(context); _showAttackErrorOptions(team, player); }, child: const Text("ERRO")),
              ],
            )
          ],
        ),
      );
    });
  }

  void _showAttackErrorOptions(Team team, Player player) {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        padding: const EdgeInsets.all(20),
        height: 250,
        child: Column(
          children: [
            const Text("Tipo de ERRO no Ataque", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionButton(team, player, ScoutSkill.attack, "BLOQUEADO", Colors.red[900]!, SkillQuality.error, ErrorDetail.blocked),
                _actionButton(team, player, ScoutSkill.attack, "FORA", Colors.red, SkillQuality.error, ErrorDetail.out),
                _actionButton(team, player, ScoutSkill.attack, "REDE", Colors.red[300]!, SkillQuality.error, ErrorDetail.net),
              ],
            )
          ],
        ),
      );
    });
  }

  void _showBlockOptions(Team team, Player player) {
    showModalBottomSheet(context: context, builder: (context) => Container(
      padding: const EdgeInsets.all(20), height: 200,
      child: Column(children: [Text("Qualidade do BLOQUEIO", style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_actionButton(team, player, ScoutSkill.block, "KILL", Colors.blue[800]!, SkillQuality.perfect), _actionButton(team, player, ScoutSkill.block, "AMORTECIDO", Colors.blue[400]!, SkillQuality.neutral), _actionButton(team, player, ScoutSkill.block, "ERRO", Colors.red, SkillQuality.error)])]),
    ));
  }
  void _showDigOptions(Team team, Player player) {
    showModalBottomSheet(context: context, builder: (context) => Container(
      padding: const EdgeInsets.all(20), height: 200,
      child: Column(children: [Text("Qualidade da DEFESA", style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_actionButton(team, player, ScoutSkill.dig, "EM JOGO", Colors.orange, SkillQuality.perfect), _actionButton(team, player, ScoutSkill.dig, "ERRO", Colors.red, SkillQuality.error)])]),
    ));
  }
  void _showSetOptions(Team team, Player player) {
    showModalBottomSheet(context: context, builder: (context) => Container(
      padding: const EdgeInsets.all(20), height: 200,
      child: Column(children: [Text("Qualidade do LEVANTAMENTO", style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_actionButton(team, player, ScoutSkill.set, "BOM (+)", Colors.green, SkillQuality.good), _actionButton(team, player, ScoutSkill.set, "RUIM (-)", Colors.orange, SkillQuality.poor), _actionButton(team, player, ScoutSkill.set, "ERRO (=)", Colors.red, SkillQuality.error)])]),
    ));
  }
  void _showFreeBallOptions(Team team, Player player) {
    showModalBottomSheet(context: context, builder: (context) => Container(
      padding: const EdgeInsets.all(20), height: 250,
      child: Column(children: [Text("Qualidade da FREE BALL", style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_actionButton(team, player, ScoutSkill.freeball, "PASSE A (3)", Colors.teal[800]!, SkillQuality.perfect), _actionButton(team, player, ScoutSkill.freeball, "PASSE B (2)", Colors.teal, SkillQuality.good)]), const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_actionButton(team, player, ScoutSkill.freeball, "QUEBRADO (1)", Colors.orange, SkillQuality.poor), _actionButton(team, player, ScoutSkill.freeball, "ERRO (0)", Colors.red, SkillQuality.error)])]),
    ));
  }

  Widget _actionButton(Team team, Player player, ScoutSkill skill, String label, Color color, SkillQuality quality, [ErrorDetail errorDetail = ErrorDetail.none]) {
    return ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white), onPressed: () => _registerAction(team, player, skill, quality, errorDetail), child: Text(label));
  }

  // --- LÓGICA DE FALTAS GENÉRICAS ---
 // Atualize a assinatura para aceitar [Player? player]
  void _registerFault(Team faultTeam, FaultType type, [Player? player]) {
    // Se o menu de seleção de jogador estiver aberto, fecha ele.
    // Se veio direto do menu anterior, o Navigator.pop já foi chamado lá.
    if (player != null) {
       Navigator.pop(context); 
    }
    
    // Quem cometeu a falta "sofre" o ponto
    Team scoringTeam = (faultTeam.name == widget.homeSetup.team.name) 
        ? widget.guestSetup.team 
        : widget.homeSetup.team;

    setState(() {
      // 1. Placar
      if (scoringTeam.name == widget.homeSetup.team.name) {
        _homeScore++;
      } else {
        _guestScore++;
      }

      // 2. Rotação
      if (scoringTeam.name != _servingTeam.name) {
        _showToast("Side-out! Ponto do ${scoringTeam.name}.");
        _servingTeam = scoringTeam;
        _rotateTeam(scoringTeam);
      } else {
        _showToast("Break Point! Erro do adversário.");
      }

      // 3. Reset
      _isServingPhase = true;
      _expectingReception = false;

      // 4. Log (Agora passamos o PLAYER se ele existir)
      actionLog.insert(0, MatchAction(
        team: faultTeam,
        player: player, // <--- AQUI ESTÁ A MUDANÇA
        skill: ScoutSkill.fault,
        quality: SkillQuality.error,
        faultType: type,
        homeScoreNow: _homeScore,
        guestScoreNow: _guestScore,
      ));

      _checkLiberoSwaps();
    });
  }

  void _registerAction(Team actionTeam, Player player, ScoutSkill skill, SkillQuality quality, [ErrorDetail errorDetail = ErrorDetail.none]) {
    Navigator.pop(context);
    setState(() {
      bool pointScored = false;
      Team? scoringTeam;

      if (quality == SkillQuality.perfect) {
        if (skill == ScoutSkill.attack || skill == ScoutSkill.block || skill == ScoutSkill.serveAce) {
          pointScored = true;
          scoringTeam = actionTeam;
        }
      } else if (quality == SkillQuality.error) {
        pointScored = true;
        scoringTeam = (actionTeam.name == widget.homeSetup.team.name) ? widget.guestSetup.team : widget.homeSetup.team;
      }

      if (pointScored) {
        if (scoringTeam!.name == widget.homeSetup.team.name) {
          _homeScore++;
        } else {
          _guestScore++;
        }
        if (scoringTeam.name != _servingTeam.name) {
          _showToast("Side-out! ${scoringTeam.name} recupera.");
          _servingTeam = scoringTeam;
          _rotateTeam(scoringTeam);
        } else {
           _showToast("Break Point!");
        }
        _isServingPhase = true;
        _expectingReception = false;
      } else {
        if (skill == ScoutSkill.serveAce) { _isServingPhase = false; _expectingReception = true; } 
        else if (skill == ScoutSkill.reception || skill == ScoutSkill.freeball) { _expectingReception = false; }
      }
      actionLog.insert(0, MatchAction(team: actionTeam, player: player, skill: skill, quality: quality, errorDetail: errorDetail, homeScoreNow: _homeScore, guestScoreNow: _guestScore));
      _checkLiberoSwaps();
    });
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    String statusText = "RALLY";
    if (_isServingPhase) {
      statusText = "SAQUE: ${_servingTeam.name}";
    } else if (_expectingReception) {statusText = "AGUARDANDO RECEPÇÃO";}

    return Scaffold(
      appBar: AppBar(
        title: Text(statusText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: _servingTeam.name == widget.homeSetup.team.name ? Colors.blue : Colors.red,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(children: [Text(widget.homeSetup.team.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text("$_homeScore", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.blue))]),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("X", style: TextStyle(fontSize: 20))),
                Column(children: [Text(widget.guestSetup.team.name, style: const TextStyle(fontWeight: FontWeight.bold)), Text("$_guestScore", style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red))]),
              ],
            ),
          ),
          
          Expanded(
            child: Stack(
              children: [
                // 1. A QUADRA (Fundo)
                VolleyballCourt(
                  homeTeam: Team(name: widget.homeSetup.team.name, players: _homeLineup),
                  guestTeam: Team(name: widget.guestSetup.team.name, players: _guestLineup),
                  homeLibero: widget.homeSetup.libero,
                  guestLibero: widget.guestSetup.libero,
                  onPlayerTap: _handlePlayerTap,
                ),

                // 2. BOTÃO DE ERRO - ESQUERDA (CASA)
                Positioned(
                  left: 10,
                  top: 10,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100], 
                      foregroundColor: Colors.red[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _showGeneralFaultMenu(widget.homeSetup.team),
                    child: const Text("ERRO", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),

                // 3. BOTÃO DE ERRO - DIREITA (VISITANTE)
                Positioned(
                  right: 10,
                  top: 10,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[100], 
                      foregroundColor: Colors.red[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => _showGeneralFaultMenu(widget.guestSetup.team),
                    child: const Text("ERRO", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          
          if (actionLog.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Text("Última: ${actionLog.first.description}", style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }
}