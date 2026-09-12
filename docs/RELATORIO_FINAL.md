# Relatório Final — Análise Crítica (TechFlow)

## Funcionalidades implementadas

Foram implementados login local com perfis, CRUDs de clientes/técnicos/equipamentos, gestão completa de ordens de serviço (status, prioridade, prazo, peças, mão de obra, total automático, imagens e histórico), busca/filtros, painel operacional com os indicadores exigidos e persistência SQLite multiplataforma (Web, Windows e Android), com dados de demonstração.

## Dificuldades encontradas

- Compatibilidade do SQLite entre Web e desktop/mobile exigiu factories distintas (`ffi` / `ffi_web`)
- Anexos de imagem na Web precisaram de armazenamento alternativo (Base64)
- Regras de transição de status e exclusões com relacionamentos demandaram validações para evitar inconsistências
- Layout responsivo (sidebar colapsável, títulos e cards) exigiu ajustes finos em Windows e mobile

## Decisões técnicas

- Flutter + Material 3 com identidade visual TechFlow (tema escuro)
- Provider para estado reativo adequado ao escopo acadêmico
- Repository + Singleton de banco para separar UI e persistência
- Seed automático para facilitar apresentação ao professor
- Idioma da interface e documentação em português

## Persistência

SQLite local com foreign keys e histórico de alterações por ordem.

## Gerenciamento de estado

`ChangeNotifier` + `Provider` (`AuthProvider`, `ClientProvider`, `TechnicianProvider`, `EquipmentProvider`, `ServiceOrderProvider`).

## Limitações da versão entregue

- Autenticação local (sem backend/Firebase)
- Sem sincronização em nuvem entre dispositivos
- Sem geração de PDF, assinatura ou geolocalização
- Sem controle de estoque de peças
- Histórico registra eventos principais, não diff campo a campo

## Melhorias futuras

- Sincronização offline/online
- Relatórios PDF e gráficos por técnico/período
- Notificações de prazo
- Tema claro/escuro
- Assinatura do cliente e mapa do atendimento
- Exportação de dados (CSV/Excel)
- Publicação do repositório no GitHub com histórico de commits

## Conclusão

O aplicativo TechFlow atende aos requisitos obrigatórios do enunciado, demonstra POO, navegação, validação, regras de negócio e persistência relacional, e está preparado para execução e demonstração nas plataformas Web, Windows e Android.
