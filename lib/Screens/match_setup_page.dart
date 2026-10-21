import 'package:flutter/material.dart';
import '../models/match_model.dart';
import 'match_page.dart';

class MatchSetupPage extends StatefulWidget {
  final Team homeTeam;
  final Team guestTeam;

  const MatchSetupPage({super.key, required this.homeTeam, required this.guestTeam});

  @override
  State<MatchSetupPage> createState() => _MatchSetupPageState();
}

class _MatchSetupPageState extends State<MatchSetupPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Armazena a configuração temporária dos dois times
  // Mapas para guardar as escolhas: [0] = P1, [1] = P6, etc... (Padrão visual da quadra)
  final Map<Team, List<Player?>> _startingPlayers = {};
  final Map<Team, Player?> _liberos = {};
  final Map<Team, Player?> _setters = {};
  final Map<Team, List<Player?>> _selectedMiddles = {}; //variavel que guarda onde vai ficar os centrais
  
  // Quem começa sacando?
  Team? _startingServerTeam;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startingServerTeam = widget.homeTeam; // Padrão: Casa começa

    // Inicializa as listas vazias
    _startingPlayers[widget.homeTeam] = List.filled(6, null);
    _startingPlayers[widget.guestTeam] = List.filled(6, null);
    // Inicializa listas de 2 posições (Central 1 e Central 2)
    _selectedMiddles[widget.homeTeam] = [null, null];
    _selectedMiddles[widget.guestTeam] = [null, null];
  }

  // Validação principal
  void _startGame() {
    
    // 1. Verifica se todos os titulares foram escolhidos
    
    if (_hasNulls(widget.homeTeam) || _hasNulls(widget.guestTeam)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha as 6 posições de ambos os times!')));
      return;
    }
    
    // 2. Verifica Levantadores
    
    if (_setters[widget.homeTeam] == null || _setters[widget.guestTeam] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione os levantadores!')));
      return;
    }

    // Nova Validação: Centrais
    if (_selectedMiddles[widget.homeTeam]!.contains(null) || _selectedMiddles[widget.guestTeam]!.contains(null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione os 2 Centrais de cada time!')));
      return;
    }

    // Monta os objetos de configuração
    final homeSetup = MatchSetup(
      team: widget.homeTeam,
      startingSix: _startingPlayers[widget.homeTeam]!.cast<Player>(),
      libero: _liberos[widget.homeTeam],
      setter: _setters[widget.homeTeam]!,
      middles: _selectedMiddles[widget.homeTeam]!.cast<Player>(),
    );

    final guestSetup = MatchSetup(
      team: widget.guestTeam,
      startingSix: _startingPlayers[widget.guestTeam]!.cast<Player>(),
      libero: _liberos[widget.guestTeam],
      setter: _setters[widget.guestTeam]!,
      middles: _selectedMiddles[widget.guestTeam]!.cast<Player>(),
    );

    // Navega para o Jogo
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchPage(
          homeSetup: homeSetup,
          guestSetup: guestSetup,
          startingServerTeam: _startingServerTeam!,
        ),
      ),
    );
  }

  bool _hasNulls(Team team) => _startingPlayers[team]!.contains(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Escalação'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: widget.homeTeam.name), Tab(text: widget.guestTeam.name)],
        ),
      ),
      body: Column(
        children: [
          // Área de seleção de quem saca
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Quem saca primeiro? "),
                DropdownButton<Team>(
                  value: _startingServerTeam,
                  items: [
                    DropdownMenuItem(value: widget.homeTeam, child: Text(widget.homeTeam.name)),
                    DropdownMenuItem(value: widget.guestTeam, child: Text(widget.guestTeam.name)),
                  ],
                  onChanged: (v) => setState(() => _startingServerTeam = v),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeamForm(widget.homeTeam),
                _buildTeamForm(widget.guestTeam),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _startGame,
              icon: const Icon(Icons.sports_volleyball),
              label: const Text('INICIAR PARTIDA', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamForm(Team team) {
    // Restrição 1: Mínimo de 6 jogadores no elenco
    if (team.players.length < 6) {
      return Center(child: Text("O time ${team.name} tem apenas ${team.players.length} jogadores.\nPrecisa de no mínimo 6 para jogar.", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Titulares (Rotação Inicial)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        _buildPositionSelector(team, 0, "P1 (Saque/Defesa)"),
        _buildPositionSelector(team, 5, "P2 (Saída/Rede)"),
        _buildPositionSelector(team, 4, "P3 (Meio/Rede)"),
        _buildPositionSelector(team, 3, "P4 (Ponta/Rede)"),
        _buildPositionSelector(team, 2, "P5 (Defesa Esq)"),
        _buildPositionSelector(team, 1, "P6 (Defesa Centro)"),
        
        const Divider(height: 30),
        const Text("Funções Específicas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        
        // Seletor de Líbero

        DropdownButtonFormField<Player?>(
          decoration: const InputDecoration(labelText: "Líbero (Opcional)"),
          initialValue: _liberos[team],
          items: [
            const DropdownMenuItem<Player?>(
              value: null,
              child: Text("Sem Líbero")),
            ...team.players.map(
              (p) => DropdownMenuItem<Player?>(
                value: p,
                child: Text("${p.number} - ${p.name}")))
          ],
          onChanged: (p) => setState(() => _liberos[team] = p),
        ),

        // Seletor de Levantador (Geralmente é um dos titulares)

        DropdownButtonFormField<Player>(
          decoration: const InputDecoration(labelText: "Levantador Inicial (Obrigatório)"),
          initialValue: _setters[team],
          items: team.players.map((p) => DropdownMenuItem(value: p, child: Text("${p.number} - ${p.name}"))).toList(),
          onChanged: (p) => setState(() => _setters[team] = p),
        ),
        
        // --- NOVO: SELEÇÃO DE CENTRAIS ---
        const SizedBox(height: 10),
        const Text("Definir Centrais (Para troca automática com Líbero)", style: TextStyle(color: Colors.grey)),
        
        DropdownButtonFormField<Player>(
          decoration: const InputDecoration(labelText: "Central 1"),
          initialValue: _selectedMiddles[team]![0],
          items: team.players.map((p) => DropdownMenuItem(value: p, child: Text("${p.number} - ${p.name}"))).toList(),
          onChanged: (p) => setState(() => _selectedMiddles[team]![0] = p),
        ),
        
        DropdownButtonFormField<Player>(
          decoration: const InputDecoration(labelText: "Central 2"),
          initialValue: _selectedMiddles[team]![1],
          items: team.players.map((p) => DropdownMenuItem(value: p, child: Text("${p.number} - ${p.name}"))).toList(),
          onChanged: (p) => setState(() => _selectedMiddles[team]![1] = p),
        ),
      ],
    );
  }

  Widget _buildPositionSelector(Team team, int index, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButtonFormField<Player>(
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        initialValue: _startingPlayers[team]![index],
        items: team.players.map((p) => DropdownMenuItem(value: p, child: Text("${p.number} - ${p.name}"))).toList(),
        onChanged: (p) {
          // Lógica simples: permite repetir por enquanto para facilitar testes, 
          // mas idealmente filtraria quem já foi selecionado.
          setState(() => _startingPlayers[team]![index] = p);
        },
      ),
    );
  }
}