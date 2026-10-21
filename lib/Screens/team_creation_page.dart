import 'package:flutter/material.dart';
import '../models/match_model.dart'; // Verifique se o caminho do import está correto para seu projeto

class TeamCreationPage extends StatefulWidget {
  final Team? teamToEdit; // <--- O CAMPO QUE FALTAVA

  // O construtor agora aceita o parâmetro opcional
  const TeamCreationPage({super.key, this.teamToEdit});

  @override
  State<TeamCreationPage> createState() => _TeamCreationPageState();
}

class _TeamCreationPageState extends State<TeamCreationPage> {
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _teamNameController = TextEditingController();

  List<Player> playersList = [];

  @override
  void initState() {
    super.initState();
    // LÓGICA DE EDIÇÃO:
    // Se recebemos um time (teamToEdit não é null), preenchemos os campos
    if (widget.teamToEdit != null) {
      _teamNameController.text = widget.teamToEdit!.name;
      // Criamos uma cópia da lista para não alterar o original até salvar
      playersList = List.from(widget.teamToEdit!.players);
    }
  }

  void _addPlayer() {
    final name = _nameController.text;
    final numberText = _numberController.text;

    if (name.isEmpty || numberText.isEmpty) {
      _showError('Preencha nome e número!');
      return;
    }

    final number = int.tryParse(numberText);
    if (number == null) {
      _showError('Número inválido!');
      return;
    }

    // Verifica se já existe alguém com esse número na lista temporária
    bool numberExists = playersList.any((p) => p.number == number);
    if (numberExists) {
      _showError('Já existe um jogador com a camisa $number!');
      return;
    }

    setState(() {
      playersList.add(Player(name: name, number: number));
    });

    // Limpa os campos de jogador para adicionar o próximo
    _nameController.clear();
    _numberController.clear();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red)
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.teamToEdit != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Time' : 'Criar Time')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Campo Nome do Time
            TextField(
              controller: _teamNameController,
              decoration: const InputDecoration(labelText: 'Nome do Time'),
            ),
            const SizedBox(height: 20),
            
            // Campos para adicionar jogador (Linha horizontal)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController, 
                    decoration: const InputDecoration(labelText: 'Nome Jogador')
                  )
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 80, 
                  child: TextField(
                    controller: _numberController, 
                    keyboardType: TextInputType.number, 
                    decoration: const InputDecoration(labelText: 'Nº')
                  )
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green), 
                  onPressed: _addPlayer
                ),
              ],
            ),
            const Divider(height: 40),
            
            // Lista de jogadores adicionados
            Expanded(
              child: ListView.builder(
                itemCount: playersList.length,
                itemBuilder: (context, index) {
                  final player = playersList[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${player.number}')),
                    title: Text(player.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => playersList.removeAt(index)),
                    ),
                  );
                },
              ),
            ),
            
            // Botão de Salvar
            ElevatedButton(
              onPressed: () {
                if (_teamNameController.text.isEmpty || playersList.isEmpty) {
                  _showError('Time precisa de nome e jogadores!');
                  return;
                }

                // Cria o objeto Team com os dados novos/atualizados
                final teamData = Team(
                  name: _teamNameController.text,
                  players: List.from(playersList),
                );

                // Retorna o time para a tela anterior
                Navigator.pop(context, teamData);
              },
              child: Text(isEditing ? 'Salvar Alterações' : 'Criar Time'),
            ),
          ],
        ),
      ),
    );
  }
}