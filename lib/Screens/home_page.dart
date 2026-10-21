// lib/screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:scoutvolei/Screens/match_page.dart';
import '../models/match_model.dart';
import 'match_setup_page.dart';
import 'team_creation_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Team> myTeams = [];

  void _goToCreateTeam() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TeamCreationPage()),
    );
    
    if (!mounted) return;
    
    if (result != null && result is Team) {
      setState(() {
        myTeams.add(result);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Time ${result.name} cadastrado!')));
    }
  }

  // --- FUNÇÃO DEBUG (FAIL FAST) ---
  void _debugQuickStart() {
    // 1. Criar Jogadores Home (H1 a H7)
    List<Player> homePlayers = List.generate(7, (i) => Player(name: "Home ${i+1}", number: i+1));
    // 2. Criar Jogadores Away (A1 a A7) - Camisas 10, 20...
    List<Player> guestPlayers = List.generate(7, (i) => Player(name: "Away ${i+1}", number: (i+1)*10));

    // 3. Criar Times
    Team homeTeam = Team(name: "HOME", players: homePlayers);
    Team guestTeam = Team(name: "AWAY", players: guestPlayers);

    // 4. Montar Escalação (Os 6 primeiros são titulares, o 7º é Líbero)
    MatchSetup homeSetup = MatchSetup(
      team: homeTeam,
      startingSix: homePlayers.sublist(0, 6),
      libero: homePlayers[6], 
      setter: homePlayers[0], // P1 começa como levantador
      middles: [homePlayers[2], homePlayers[5]],
    );

    MatchSetup guestSetup = MatchSetup(
      team: guestTeam,
      startingSix: guestPlayers.sublist(0, 6),
      libero: guestPlayers[6],
      setter: guestPlayers[0],
      middles: [guestPlayers[2], guestPlayers[5]],
    );

    // 5. Pular direto para a partida
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchPage(
          homeSetup: homeSetup,
          guestSetup: guestSetup,
          startingServerTeam: homeTeam, // Home começa sacando
        ),
      ),
    );
  }

  void _showMatchSetupDialog() {
    if (myTeams.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cadastre 2 times!')));
      return;
    }
    Team? selectedHome = myTeams[0];
    Team? selectedGuest = myTeams[1];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Configurar Partida'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<Team>(
                    value: selectedHome,
                    isExpanded: true,
                    items: myTeams.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                    onChanged: (v) => setStateDialog(() => selectedHome = v),
                  ),
                  const SizedBox(height: 20),
                  DropdownButton<Team>(
                    value: selectedGuest,
                    isExpanded: true,
                    items: myTeams.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
                    onChanged: (v) => setStateDialog(() => selectedGuest = v),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MatchSetupPage(homeTeam: selectedHome!, guestTeam: selectedGuest!),
                    ));
                  },
                  child: const Text('CONFIGURAR & JOGAR!'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scout Vôlei'), backgroundColor: Colors.orange),
      body: myTeams.isEmpty
          ? const Center(child: Text('Nenhum time cadastrado.'))
          : ListView.builder(
              itemCount: myTeams.length,
              itemBuilder: (context, index) {
                final team = myTeams[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.groups),
                    title: Text(team.name),
                    subtitle: Text('${team.players.length} jogadores'),
                    trailing: const Icon(Icons.edit), //icone de lapis
                    onTap: () async {
                      final updatedTeam = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamCreationPage(teamToEdit: team),
                        ),
                      );
                      //se voltou um time editado, atualizamos a lista
                      if(updatedTeam != null && updatedTeam is Team){
                        setState(() {
                          myTeams[index] = updatedTeam;
                        });
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "btnDebug", // Tags precisam ser únicas
            onPressed: _debugQuickStart, 
            label: const Text('Debug Mode'),
            icon: const Icon(Icons.bug_report),
            backgroundColor: Colors.grey[700],
            foregroundColor: Colors.white,
          ),
          FloatingActionButton(heroTag: "btn1", onPressed: _goToCreateTeam, child: const Icon(Icons.add)),
          const SizedBox(height: 10),
          FloatingActionButton.extended(heroTag: "btn2", onPressed: _showMatchSetupDialog, label: const Text('JOGAR'), icon: const Icon(Icons.play_arrow)),
        ],
      ),
    );
  }
}