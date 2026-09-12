# Documentação do Projeto — TechFlow

## 1. Descrição

O **TechFlow** é um aplicativo multiplataforma desenvolvido em Flutter para empresas que prestam serviços de manutenção em equipamentos, computadores, máquinas e aparelhos de climatização. A solução centraliza o ciclo de atendimento desde a abertura da solicitação até a conclusão do serviço.

## 2. Objetivos

### Geral
Desenvolver um aplicativo mobile/desktop/web em Flutter para gerenciamento de ordens de serviço, com cadastro, consulta, edição, exclusão, fluxo de status, persistência local e indicadores operacionais.

### Específicos
- Cadastrar e listar clientes, técnicos e equipamentos
- Abrir, editar e consultar ordens de serviço
- Atribuir prioridade, técnico, prazo e status
- Registrar diagnóstico, solução, peças e mão de obra
- Calcular automaticamente o valor total
- Anexar imagens de evidência
- Buscar e filtrar ordens
- Apresentar painel com indicadores
- Persistir dados após fechar o aplicativo

## 3. Funcionalidades implementadas

| Módulo | Recursos |
|--------|----------|
| Autenticação | Login local com perfis Administrador, Atendente e Técnico |
| Clientes | CRUD com validações de e-mail, telefone e CPF/CNPJ |
| Técnicos | CRUD com especialidade e situação (ativo/inativo) |
| Equipamentos | CRUD vinculados a clientes |
| Ordens de Serviço | Abertura, edição, status, prioridade, prazo, financeiro, imagens, histórico |
| Painel | Total, abertas, em atendimento, aguardando peça, concluídas, urgentes, atrasadas e valor total |
| Persistência | SQLite com relacionamentos e seed de demonstração |

## 4. Fluxo de status

```
Aberta → Atribuída → Em atendimento ⇄ Aguardando peça → Concluída
                 ↘ Cancelada (em vários pontos)
```

Regras:
- Transições inválidas são bloqueadas
- Conclusão exige diagnóstico ou solução
- Status Atribuída/Em atendimento exige técnico
- OS em aberto com prazo vencido é marcada como atrasada

## 5. Arquitetura e padrões

- **Repository**: acesso aos dados SQLite
- **Singleton**: `DatabaseService`
- **Provider**: gerenciamento de estado da UI
- **State (transições)**: `StatusTransitions` controla o ciclo da OS
- Separação em `models`, `screens`, `widgets`, `services`, `repositories`, `providers`, `core`

## 6. Persistência

SQLite local:
- Android: `sqflite`
- Windows, macOS e Linux: `sqflite_common_ffi` com SQLite nativo (`sqlite3_flutter_libs`)
- Web: `sqflite_common_ffi_web`

Imagens:
- Android/Windows/macOS/Linux: arquivos no diretório da aplicação
- Web: Base64 em `SharedPreferences`

## 7. Dados de exemplo

Na primeira execução são criados:
- 3 usuários
- 5 clientes
- 4 técnicos
- 8 equipamentos
- 12 ordens de serviço em status e prioridades distintos

## 8. Interface TechFlow

Tema escuro com acento lima/dourado, sidebar colapsável no desktop e drawer no mobile, tipografia Outfit + JetBrains Mono.
