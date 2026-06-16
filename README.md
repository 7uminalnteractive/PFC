# Bolão+ 🏆

Site de palpites entre amigos com painel admin, envio de palpites e download de imagem.

---

## 📁 Estrutura de arquivos

```
bolao/
├── index.html              ← Login / Criar conta
├── admin/
│   └── index.html          ← Painel admin
├── participant/
│   └── index.html          ← Tela de palpites
└── supabase-setup.sql      ← SQL para configurar o banco
```

---

## 🚀 Passo a passo de configuração

### 1. Supabase

1. Acesse [supabase.com](https://supabase.com) e crie um projeto
2. No menu lateral, vá em **SQL Editor**
3. Cole e execute o conteúdo do arquivo `supabase-setup.sql`
4. Em **Settings → API**, copie:
   - `Project URL`
   - `anon public key`

### 2. Configurar os arquivos HTML

Em **todos os 3 arquivos HTML** (`index.html`, `admin/index.html`, `participant/index.html`), substitua:

```js
const SUPABASE_URL = 'SUPABASE_URL_AQUI';   // ← sua Project URL
const SUPABASE_KEY = 'SUPABASE_ANON_KEY_AQUI'; // ← sua anon key
const ADMIN_EMAIL  = 'admin@bolao.com';      // ← e-mail do admin
```

> ⚠️ O e-mail do admin também aparece nas **policies SQL** (passo 1). Se mudou o e-mail, rode novamente as policies com o e-mail correto.

### 3. GitHub

```bash
git init
git add .
git commit -m "feat: bolão+"
git remote add origin https://github.com/SEU_USUARIO/SEU_REPO.git
git push -u origin main
```

### 4. Vercel

1. Acesse [vercel.com](https://vercel.com) e conecte seu GitHub
2. Importe o repositório
3. Clique em **Deploy** — pronto!

> O Vercel detecta HTML estático automaticamente, sem precisar de nenhuma configuração extra.

---

## 👤 Criar conta admin

1. Acesse o site e clique em **Criar conta**
2. Use o e-mail que você definiu como `ADMIN_EMAIL`
3. Após confirmar o e-mail, entre com esse usuário
4. Você será redirecionado automaticamente para o painel admin

---

## ✨ Funcionalidades

| Funcionalidade | Onde |
|---|---|
| Login / Cadastro | `index.html` |
| Adicionar jogos | Admin → Jogos |
| Abrir/fechar palpites | Admin → Jogos |
| Ver palpites por jogo/participante | Admin → Palpites |
| Fazer palpites | Participante |
| Baixar imagem PNG com palpites | Participante (após enviar) |

---

## 🔒 Segurança (Row Level Security)

- Participantes **só veem os próprios palpites**
- Somente o admin pode **criar, editar e deletar jogos**
- O admin pode **ver todos os palpites**
- Todos os usuários podem ver a **lista de jogos abertos**
