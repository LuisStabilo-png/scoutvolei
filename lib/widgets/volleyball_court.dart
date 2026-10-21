import 'package:flutter/material.dart';
import '../models/match_model.dart';

class VolleyballCourt extends StatelessWidget {
  final Team homeTeam;
  final Team guestTeam;
  final Function(Team, Player) onPlayerTap;
  
  // NOVOS CAMPOS: Precisamos saber quem são os líberos
  final Player? homeLibero;
  final Player? guestLibero;

  const VolleyballCourt({
    super.key,
    required this.homeTeam,
    required this.guestTeam,
    required this.onPlayerTap,
    this.homeLibero,
    this.guestLibero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double w = constraints.maxWidth;
        final double h = constraints.maxHeight;

        return Stack(
          children: [
            // 1. Fundo Verde
            Container(color: const Color(0xFF2E8B57)), 
            
            // 2. Quadra Laranja
            Center(
              child: Container(
                width: w * 0.9,
                height: h * 0.7,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Row(
                  children: [
                    Expanded(child: Container(decoration: const BoxDecoration(border: Border(right: BorderSide(color: Colors.white, width: 2))))),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),

            // --- TIME DA CASA (ESQUERDA) ---
            // Orientação: P1 em Baixo
            _buildPlayerNode(homeTeam, 0, w * 0.10, h * 0.75, Colors.blue, true), // P1
            _buildPlayerNode(homeTeam, 1, w * 0.05, h * 0.50, Colors.blue, true), // P6
            _buildPlayerNode(homeTeam, 2, w * 0.10, h * 0.25, Colors.blue, true), // P5
            _buildPlayerNode(homeTeam, 3, w * 0.35, h * 0.25, Colors.blue, true), // P4
            _buildPlayerNode(homeTeam, 4, w * 0.40, h * 0.50, Colors.blue, true), // P3
            _buildPlayerNode(homeTeam, 5, w * 0.35, h * 0.75, Colors.blue, true), // P2

            // --- TIME VISITANTE (DIREITA) ---
            // Orientação: P1 em Cima (Rotacionado)
            _buildPlayerNode(guestTeam, 0, w * 0.85, h * 0.20, Colors.red, false), // P1
            _buildPlayerNode(guestTeam, 1, w * 0.90, h * 0.50, Colors.red, false), // P6
            _buildPlayerNode(guestTeam, 2, w * 0.85, h * 0.80, Colors.red, false), // P5
            _buildPlayerNode(guestTeam, 3, w * 0.60, h * 0.80, Colors.red, false), // P4
            _buildPlayerNode(guestTeam, 4, w * 0.55, h * 0.50, Colors.red, false), // P3
            _buildPlayerNode(guestTeam, 5, w * 0.60, h * 0.20, Colors.red, false), // P2
          ],
        );
      },
    );
  }

  Widget _buildPlayerNode(Team team, int index, double left, double top, Color defaultColor, bool isHome) {
    if (index >= team.players.length) return const SizedBox();
    
    final player = team.players[index];

    // LÓGICA DO LÍBERO
    // Verifica se esse jogador é o líbero do time correspondente
    bool isThisLibero = false;
    if (isHome && homeLibero != null && player.number == homeLibero!.number) {
      isThisLibero = true;
    } else if (!isHome && guestLibero != null && player.number == guestLibero!.number) {
      isThisLibero = true;
    }

    // Configura as cores
    Color bubbleColor = defaultColor;
    Color textColor = Colors.white;

    if (isThisLibero) {
      if (isHome) {
        bubbleColor = Colors.white; // Líbero Home = Branco
        textColor = Colors.black;   // Texto Preto
      } else {
        bubbleColor = Colors.black; // Líbero Away = Preto
        textColor = Colors.white;   // Texto Branco
      }
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => onPlayerTap(team, player),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white, // Borda
          child: CircleAvatar(
            radius: 21,
            backgroundColor: bubbleColor, // Cor do Fundo (Azul/Vermelho/Branco/Preto)
            child: Text(
              "${player.number}",
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}