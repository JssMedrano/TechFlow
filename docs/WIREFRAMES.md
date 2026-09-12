# Wireframes / Protótipo das telas — TechFlow

Protótipo textual alinhado à interface entregue (tema escuro TechFlow).  
Plataformas: Web, Windows, Android, macOS e Linux.

## 1. Login

### Desktop / Web (layout dividido)
- Fundo escuro com grade técnica
- **Esquerda:** logo TechFlow + painel estilo terminal (status do hub, alertas, versão)
- **Direita:**
  - Título: Bem-vindo de volta
  - Subtítulo: Entre no seu espaço de manutenção
  - Campos: ID/Email e Senha (com mostrar/ocultar)
  - Checkbox: Lembrar este dispositivo por 30 dias
  - Botão dourado: Entrar
  - Link: Solicite acesso ao administrador
  - Dica de credenciais demo

### Mobile
- Logo TechFlow no topo
- Mesmo formulário centralizado em coluna única (sem painel terminal completo)

## 2. Shell de navegação

### Desktop / Web (≥ 900px)
- Sidebar lateral TechFlow (colapsável):
  - Expandida (~250px): Painel, Ordens, Clientes, Técnicos, Equipamentos + perfil + Sair
  - Recolhida (~76px): apenas ícones + botão expandir
- Conteúdo principal à direita

### Mobile (< 900px)
- Menu hamburger alinhado ao título
- Drawer lateral com os mesmos itens de navegação

## 3. Painel Operacional (Dashboard)

### Cabeçalho
- Título: Painel Operacional
- Data/hora atual
- Busca (desktop) + botão Nova OS

### Indicadores (grade responsiva — 4 colunas no desktop, 2 no mobile)
1. Total de OS  
2. Abertas  
3. Em atendimento  
4. Aguardando peça  
5. Concluídas  
6. Urgentes  
7. Atrasadas  
8. Valor total (R$)

Toque no card aplica filtro correspondente na lista de OS.

### Área inferior
- **Esquerda (desktop):** Ordens de Serviço Recentes (código, problema, cliente, status, tempo)
- **Direita (desktop):** Alertas de prazo + Carga por técnico (barra de progresso)
- **Mobile:** mesmos blocos empilhados verticalmente

## 4. Ordens de Serviço (lista)

- Título + busca + filtros (status, prioridade, técnico, atrasadas, urgentes)
- Botão Nova OS
- Lista com código, problema, cliente/equipamento, chips de status/prioridade, total e selo ATRASADA
- Toque abre detalhe/formulário
- Exclusão com confirmação (quando permitido pelo perfil)

## 5. Formulário / Detalhe da OS

### Cabeçalho
- Nova Ordem de Serviço / Ordem de Serviço
- ID da OS
- Ações: Cancelar | Salvar OS

### Seções (cards)
1. **Informações gerais** — cliente, equipamento, problema  
2. **Diagnóstico e solução**  
3. **Materiais e mão de obra** — itens (descrição, qtd, unitário), mão de obra, valor total automático  
4. **Gestão** — status, prioridade, técnico, prazo  
5. **Evidências** — imagem (galeria/câmera)  
6. **Histórico** — timeline de eventos  

### Layout
- Desktop: coluna principal (1–3) + coluna lateral (4–6)
- Mobile: seções empilhadas

## 6. Diretório de Clientes

- Título + busca + Novo Cliente
- Cards resumo: clientes ativos, ativos registrados, última revisão
- Lista/tabela com avatar, nome, documento, contato, quantidade de equipamentos e ações (ver/editar/excluir)

## 7. Técnicos

- Título + busca + Novo técnico
- Lista com nome, especialidade, contato e situação (ativo/inativo)
- Formulário com validações

## 8. Equipamentos

- Título + busca + Novo equipamento
- Lista vinculada ao cliente (marca, modelo, série, patrimônio)
- Formulário com cliente obrigatório

## Componentes reutilizados (Material / custom)

- `Scaffold`, `AppBar`, `Drawer` / sidebar custom
- `TextFormField`, `DropdownButtonFormField`, `DatePicker`
- `FilledButton`, `OutlinedButton`, `AlertDialog`, `SnackBar`
- Cards de métrica, badges de status/prioridade, headers responsivos
