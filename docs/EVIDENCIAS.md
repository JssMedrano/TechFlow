# Evidências de funcionalidades — TechFlow

Checklist para demonstração ao professor:

## Persistência
1. Faça login e navegue pelo painel (dados seed já carregados).
2. Cadastre um novo cliente.
3. Feche completamente o aplicativo.
4. Abra novamente e confirme que o cliente permanece salvo (SQLite).

## Login e perfis
- `admin` / `admin123` — acesso completo
- `atendente` / `atend123` — cadastros e OS
- `tecnico` / `tec123` — visualização e atualização de OS

## Ordens de serviço
- Abrir nova OS vinculada a cliente + equipamento
- Alterar status respeitando o fluxo (ex.: Aberta → Atribuída)
- Tentar transição inválida (ex.: Aberta → Concluída) e observar bloqueio
- Concluir apenas após preencher diagnóstico ou solução
- Adicionar peças e verificar total automático
- Anexar imagem pela galeria
- Filtrar por status/prioridade e buscar por código/cliente

## Painel
- Conferir os 8 indicadores: total, abertas, em atendimento, aguardando peça, concluídas, urgentes, atrasadas e valor total
- Tocar em um card para ir à lista filtrada

## Integridade
- Tentar excluir cliente com equipamento/OS vinculados (deve ser impedido)
- Confirmar exclusões destrutivas via diálogo

## Interface
- Desktop (Windows, macOS e Linux): sidebar colapsável/expansível
- Mobile: hamburger alinhado ao título + drawer
