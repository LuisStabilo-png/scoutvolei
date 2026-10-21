# Volley Scout

Aplicativo em Flutter para fazer o **scout de partidas de vôlei** em tempo real: o scouter toca no jogador em quadra e registra cada ação (saque, recepção, ataque, bloqueio, levantamento, defesa, free ball e erros), enquanto o app mantém placar, rotação e saque automaticamente.

## Funcionalidades

- **Cadastro de times e jogadores** (nome e camisa, sem camisas repetidas), com edição.
- **Configuração da partida**: escolha dos 6 titulares nas posições da rotação inicial, líbero (opcional), levantador, centrais e quem saca primeiro.
- **Quadra interativa**: os dois times aparecem na quadra, na rotação atual. Tocar em um jogador abre o menu da ação certa para o momento do rally (saque, recepção ou ações livres).
- **Qualidade de cada ação**: ace/em jogo/erro no saque, passes A, B, C, quebrado e erro na recepção, kill/em jogo/erro no ataque (bloqueado, fora ou rede), entre outras.
- **Placar e rotação automáticos**: cada ponto atualiza o placar, controla side-out e break point e gira o time que recupera o saque.
- **Líbero automático**: entra no lugar do central na posição de saque (P1) quando o time perde o saque e sai quando chega à rede (P4).
- **Erros de equipe**: infrações como rotação, toque na rede, dois toques/condução, invasão e "who's ball", com o jogador responsável quando faz sentido.
- **Modo Debug** na tela inicial: cria dois times de teste e abre uma partida direto, para testar sem cadastrar nada.

## Como rodar

Requer o [Flutter](https://docs.flutter.dev/get-started/install) (Dart ^3.10).

```bash
git clone https://github.com/LuisStabilo-png/scoutvolei.git
cd scoutvolei
flutter pub get
flutter run            # escolha o dispositivo: Windows, Chrome, Android...
```

## Estrutura

```
lib/
├── main.dart                      # ponto de entrada
├── models/match_model.dart        # Player, Team, MatchSetup, MatchAction, enums de ações/qualidade/erros
├── Screens/
│   ├── home_page.dart             # lista de times e atalho para a partida
│   ├── team_creation_page.dart    # criar/editar time
│   ├── match_setup_page.dart      # escalação e saque inicial
│   └── match_page.dart            # partida: placar, rotação, líbero e registro das ações
└── widgets/volleyball_court.dart  # desenho da quadra e posição dos jogadores
```

## Limitações e próximos passos

- Os dados ficam só em memória: ao fechar o app, times e partida são perdidos.
- Ainda não há estatísticas por jogador, controle de sets nem exportação do scout. O histórico de ações já é guardado (`MatchAction`), então esses recursos são o passo natural.
- Substituições durante a partida ainda não foram implementadas.
