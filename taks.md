# 📱 Aplicativo de Receitas - Roadmap de Desenvolvimento

## 🎯 Objetivo
Criar um aplicativo de receitas com autenticação, publicação de receitas com fotos, categorias, interação social (comentários, avaliações, favoritos) e compartilhamento.  

---

## ✅ FASE 1: FRONTEND (Telas + Navegação, sem lógica)

### Telas de Autenticação
- [x] Tela de Login  
  - Campos: E-mail, Senha  
  - Botões: "Entrar", "Cadastrar-se", "Esqueci minha senha"  

- [x] Tela de Cadastro  
  - Campos: Nome, E-mail, Senha, Confirmar Senha  
  - Foto de perfil (opcional)  
  - Botão: "Cadastrar"  

- [x] Tela de Recuperar Senha  
  - Campo: E-mail  
  - Botão: "Enviar link de recuperação"  

---

### Telas Principais
- [x] Tela Inicial (Home)  
  - Botões de navegação para receitas, perfil e criar receita  

- [x] Tela de Perfil  
  - Exibir: Nome, Foto, Bio  
  - Botões: "Editar Perfil", "Minhas Receitas"  

- [x] Tela de Editar Perfil (estrutura básica)
  - Campos: Nome, Bio, Foto de Perfil  
  - Botão: "Salvar alterações"  

- [x] Tela de Lista de Receitas (estrutura básica)
  - Listagem de receitas recentes  
  - Campo de busca (nome/ingrediente)  
  - Filtro por categoria  

- [x] Tela de Detalhes da Receita (estrutura básica)
  - Exibir: Título, Foto, Ingredientes, Modo de Preparo, Categoria, Autor  
  - Botões: "Favoritar", "Comentar", "Avaliar", "Compartilhar"  

- [x] Tela de Criar Receita (estrutura básica)
  - Campos: Título, Ingredientes, Modo de Preparo, Categoria  
  - Upload de Foto  
  - Botão: "Publicar"  

- [x] Tela de Editar Receita (estrutura básica)
  - Campos iguais à Tela de Criar Receita (já preenchidos)  
  - Botão: "Salvar alterações"  

- [x] Tela de Minhas Receitas (estrutura básica)
  - Listagem das receitas criadas pelo usuário  

- [x] Tela de Busca (estrutura básica)
  - Campo de busca por nome/ingrediente  
  - Lista de resultados  

- [ ] Tela de Filtro por Categoria  
  - Seleção de categorias para filtrar receitas  

---

### Componentes Visuais
- [ ] Seção de Comentários (UI apenas)  
  - Lista de comentários  
  - Campo de texto: "Escreva um comentário"  

- [ ] Seção de Avaliações (UI apenas)  
  - Botões de 1–5 estrelas  
  - Exibir média da receita  

- [ ] Seção de Favoritos (UI apenas)  
  - Listagem das receitas marcadas como favoritas  

---

### Fluxo de Navegação
- [x] Início do App → Tela de Login  
- [x] Tela de Login → Tela de Cadastro  
- [x] Tela de Login → Tela de Recuperar Senha  
- [x] Login bem-sucedido (mock) → Tela Inicial  
- [x] Tela Inicial → Tela de Lista de Receitas  
- [x] Tela de Lista de Receitas → Tela de Detalhes da Receita  
- [x] Tela de Detalhes da Receita → Comentários / Avaliações  
- [x] Tela de Detalhes da Receita → Perfil do Autor  
- [x] Tela Inicial → Tela de Criar Receita  
- [x] Tela de Perfil → Tela de Editar Perfil  
- [x] Tela de Perfil → Tela de Minhas Receitas → Detalhes da Receita  

---

## ✅ FASE 2: BACKEND + LÓGICA

### Supabase
- [x] Configuração inicial (Auth + Database + Storage)  
- [x] Definição das tabelas  

### Autenticação e Perfil
- [x] Cadastro, login, logout
- [x] Recuperação de senha
- [x] Edição de perfil (nome, bio, foto)  

### Receitas
- [ ] CRUD de receitas  
- [ ] Upload de imagem (câmera/galeria → Supabase Storage)  
- [x] Categorias de receitas  

### Funcionalidades Sociais
- [ ] Favoritar receitas  
- [ ] Sistema de comentários  
- [ ] Avaliações (1–5 estrelas, média)  
- [ ] Compartilhamento nativo  

### Exploração
- [ ] Feed de receitas  
- [ ] Busca por nome/ingredientes  
- [ ] Filtro por categoria  

### Finalização
- [ ] Ajustes de UI/UX  
- [ ] Testes  
- [ ] Publicação (App Store / Play Store)  

---

## 📊 Progresso
- Total de tarefas: **45**
- Concluídas: **27**
- Em andamento: **0**
- Restantes: **18**

---

## 🎉 FASE 1 - PROGRESSO ATUAL

### ✅ Concluído:
- ✅ **Estrutura do projeto Flutter configurada**
- ✅ **Sistema de navegação com GoRouter implementado**
- ✅ **Provider para gerenciamento de estado**
- ✅ **Temas e design system básico**
- ✅ **Todas as telas de autenticação funcionais** (Login, Cadastro, Recuperar Senha)
- ✅ **Tela inicial (Home) com navegação**
- ✅ **Tela de perfil completa**
- ✅ **Estrutura básica de todas as telas principais**
- ✅ **Fluxo de navegação completo**
- ✅ **Componentes reutilizáveis** (CustomTextField, CustomButton)
- ✅ **Autenticação mock funcional**

### 🔄 Próximos passos:
1. Implementar componentes visuais (comentários, avaliações, favoritos)
2. Completar telas com conteúdo real
3. Melhorar design e UX
4. Configurar Supabase (Fase 2)  
