# Checklist de Implementação — Ciclo 1 (Incremento Jogável)

**Objetivo:** Entregar o incremento jogável com o conjunto básico de ações e suporte a dois jogadores.

- **Game Designer / PO:**
  - Definir e validar os valores provisórios (dano, startup) em playtest — dependência: implementador de gameplay — Est.: 2 horas
  - Especificar comandos especiais e regras de input (janela de 0.5s) — dependência: gameplay, UI — Est.: 1 hora
  - Priorizar requisitos e aceitar critérios de aceitação — Est.: 1 hora

- **Gameplay Programmer:**
  - Implementar ações básicas (Light/Heavy, agachar, pular) e frame data configurável — dependência: spec `docs/specs/c1-combat-actions.md` — Est.: 1–2 dias
  - Implementar hitboxes/hurtboxes e aplicação de dano/knockback — Est.: 1 dia
  - Implementar reconhecimento de combo para especiais (sequência LF→HF→Jump, janela 0.5s) e cooldown/meter (provisório) — Est.: 1 dia
  - Suportar leitura de entradas para dois jogadores (input layer, desvincular estados) — Est.: 0.5–1 dia
  - Expor parâmetros (startup/active/dano) em um arquivo de configuração para iteração rápida — Est.: 2–3 horas

- **UI Programmer:**
  - Mostrar feedback visual para hits (hit sparks), bloqueios de special (cooldown ou meter) e prompts de combo reconhecido — Est.: 1 dia
  - Implementar overlay de debug para mostrar frame data e inputs (útil para playtest) — Est.: 0.5–1 dia

- **Artist / Animator:**
  - Fornecer animações base: idle, walk, jump, crouch, light hit, heavy hit, special (placeholder ok) — Est.: 2–3 dias (placeholders 1 dia)
  - Criar efeitos visuais simples para hits e especiais (sparks, screen shake) — Est.: 1 dia

- **Level Designer:**
  - Criar arena simples para testes (posicionamento inicial, limites, colisões) — Est.: 0.5–1 dia

- **Tester / QA:**
  - Executar 3 rodadas de playtest focadas em: responsividade de inputs, balanço Light vs Heavy, reconhecimento de especiais — Est.: 2–3 horas por rodada
  - Registrar evidências e issues em `progress-tracker.md` ou ferramenta do time — Est.: contínuo

**Dependências críticas:**
- Specs: [docs/specs/c1-combat-actions.md](docs/specs/c1-combat-actions.md)
- Contexto do ciclo: [docs/context/cycle.md](docs/context/cycle.md)

**Critério de pronto do incremento:**
- Todas ações mapeadas executam com animação e causam dano conforme parâmetros; reconhecedor de especial funciona dentro da janela; dois jogadores conseguem jogar localmente; playtest 1 validou que decisões táticas ocorrem (adrenalina/tensão observadas ou marcadas como provisórias).

<!-- Atualize estimativas com a equipe; este checklist é sugestão derivada das Specs do Ciclo 1. -->