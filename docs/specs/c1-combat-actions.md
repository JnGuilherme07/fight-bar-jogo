# Spec: Ações de Combate — Ciclo 1

- Identificador da Spec: C1-COMBAT-ACTIONS
- Ciclo: Ciclo 1 — Núcleo Jogável
- Objetivo: Definir as ações básicas necessárias para o primeiro incremento jogável
- Specs selecionadas para o incremento: esta spec

## Resumo
O jogador terá um conjunto básico de ações de ataque e postura: golpe fraco, golpe forte, agachar, pular, ataque baixo fraco, ataque baixo forte, ataque alto fraco, ataque alto forte e (provisoriamente) ataques especiais.

## Requisitos

- REQ-C1-001 — Ações disponíveis
  - Prioridade: Alta
  - Status: DECIDIDO
  - Descrição: O jogador pode executar as ações listadas: golpe fraco, golpe forte, agachar, pular, ataque baixo fraco, ataque baixo forte, ataque alto fraco, ataque alto forte, ataques especiais.
  - Critério de aceitação (Dado/Quando/Então):
    - Dado que a partida está em andamento e o personagem está controlável,
    - Quando o jogador pressionar o comando correspondente à ação,
    - Então a animação da ação inicia, o hitbox correspondente é gerado e o efeito (dano/knockback) é aplicado conforme os parâmetros da ação.
  - Origem: Decisão do aluno — conjunto de ações descrito pelo aluno, justificado como forma de obrigar decisões táticas.

 - REQ-C1-002 — Diferença Fraco vs Forte
  - Prioridade: Alta
  - Status: DECIDIDO
  - Descrição: Golpes fracos são mais rápidos e causam menos dano; golpes fortes são mais lentos e causam mais dano.
  - Valores iniciais (decididos para protótipo):
    - Golpe fraco: startup 0.18s, active 0.08s, dano 6 HP
    - Golpe forte: startup 0.36s, active 0.12s, dano 14 HP
  - Critério de aceitação (Dado/Quando/Então):
    - Dado um contato entre hitbox do atacante e hurtbox do defensor,
    - Quando um golpe fraco acerta,
    - Então aplicar 6 pontos de dano e computar frame data conforme valores iniciais;
    - Dado o mesmo cenário para golpe forte, então aplicar 14 pontos de dano e frame data conforme valores iniciais.
  - Origem: Justificativa do aluno — "fraco é um golpe mais rápido e que dá menos dano e forte é um golpe mais lento que dá mais dano"; o aluno confirmou esses valores para prototipagem.
  - Nota: Apesar de decididos para o protótipo, valores poderão ser ajustados após playtests registrados na spec.
  - Teto de exploração: testar e iterar por até 3 rodadas de playtest antes de alterar drasticamente.

- REQ-C1-003 — Ataques Especiais (Provisório)
  - Prioridade: Média
  - Status: PROVISÓRIO
  - Descrição: Ataques especiais são movimentos executados por combinação de comandos; causam mais dano e têm cooldown.
  - Valores iniciais provisórios:
    - Dano: 25 HP
    - Cooldown: 2.0s entre usos (sem meter neste protótipo)
  - Critério de aceitação (Dado/Quando/Então):
    - Dado que o jogador execute a combinação correta,
    - Quando a combinação for reconhecida,
    - Então executar a animação do especial, aplicar 25 HP de dano e bloquear novo uso por 2.0s.
  - Origem: Decisão do aluno (lista de ações inclui ataques especiais). Justificativa: cria momentos de risco/retorno que aumentam adrenalina.
  - Pergunta de protótipo: O cooldown e dano tornam o especial relevante sem dominar o ritmo da luta?
  - Teto de exploração: ajustar após 2–3 testes.

## Perguntas em aberto
- Valores exatos de dano/frame data para ataques (se deseja outros valores, informe). 
- Mapeamento de inputs (teclado/controle) e se especiais usam "meter" em vez de cooldown.

## Mapeamento de inputs

- Decisão: Suportar teclado e controle (DECIDIDO).
- Execução de ataques baixos/altos: usar direção + botão de ataque (ex.: agachar + `Golpe Fraco` = `Ataque Baixo Fraco`; neutro + botão = ataque em pé; pular + botão = ataque alto) — (DECIDIDO).
- Especiais: executados por combinação de comandos; exemplo confirmado pelo aluno: `Golpe Fraco` + `Golpe Forte` + `Pulo` (sequência rápida) dispara o especial (DECIDIDO).
- Valores de protótipo para mapeamento de botões (PROVISÓRIO, confirmar):
  - Teclado:
    - Golpe Fraco (Light): `J`
    - Golpe Forte (Heavy): `K`
    - Agachar/Down: `S` ou `DownArrow`
    - Pular/Up: `W` ou `UpArrow`
  - Controle (mapear para botões de face, protótipo genérico):
    - Golpe Fraco (Light): `Botão Baixo/Face Inferior`
    - Golpe Forte (Heavy): `Botão Direito/Face Direita`
    - Agachar: `D-pad Down`
    - Pular: `Botão Superior/Face Superior`

## Controles para Dois Jogadores

- Decisão: suportar dois jogadores locais (teclado+teclado, teclado+controle ou controle+controle) (DECIDIDO).
- Mapeamento protótipo — Player 1 (teclado):
  - Golpe Fraco (Light): `J`
  - Golpe Forte (Heavy): `K`
  - Agachar/Down: `S` (ou `DownArrow` alternativa)
  - Pular/Up: `W` (ou `UpArrow` alternativa)
- Mapeamento protótipo — Player 2 (teclado):
  - Golpe Fraco (Light): `L`
  - Golpe Forte (Heavy): `;` (ponto-e-vírgula)
  - Agachar/Down: `DownArrow`
  - Pular/Up: `UpArrow`
- Mapeamento protótipo — Player 1/2 (controle): use botões de face separados por jogador conforme plataforma/driver.
- Critério de aceitação para dois jogadores (Dado/Quando/Então):
  - Dado que dois jogadores estão conectados e atribuídos a Player 1 e Player 2,
  - Quando ambos enviarem inputs simultâneos ou em sequência rápida,
  - Então cada jogador executa suas ações independentemente, sem conflito de leitura de input, e o jogo processa colisões/hitboxes normalmente.
- Origem: Pedido do aluno — "lembre-se de programar controles para dois jogadores".

- Critério de aceitação para especial (Dado/Quando/Então):
  - Dado que o jogador está controlando o personagem,
  - Quando o jogador executar a sequência `Golpe Fraco` → `Golpe Forte` → `Pulo` dentro de 0.5s entre cada input,
  - Então o jogo reconhece o combo e executa o ataque especial associado, aplicando os efeitos definidos em `REQ-C1-003`.

- Origem: Decisão do aluno — mapeamento solicitado e exemplo de combinação de especiais.

## Anotações
- Estas decisões são gravadas com origem do aluno e marcadas provisórias quando parâmetros numéricos foram inicializados para prototipagem.

<!-- Ao fechar cada requisito substitua PROVISÓRIO por DECIDIDO e documente a justificativa ou evidência do playtest. -->