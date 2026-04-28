# 🚀 Explorador Espacial

> Explore o universo através da Foto Astronômica do Dia da NASA ( desenvolvido com Flutter & Firebase )

---

## 📸 Prints

**Página inicial**

<img width="1366" height="768" alt="Tela inicial" src="https://github.com/user-attachments/assets/c9e0651f-8584-4073-a065-0e5f649f2dfe" />

---

**Galeria de Imagens**

<img width="1366" height="768" alt="Galeria" src="https://github.com/user-attachments/assets/c6f2e3bf-e998-445d-84b2-99f9fcf778d2" />

---

**Página de Detalhes**

<img width="1366" height="768" alt="Detalhes" src="https://github.com/user-attachments/assets/42cd7875-ca96-4d09-815b-95e632e48779" />

---

**Página de Favoritos**

<img width="1366" height="768" alt="Favoritos" src="https://github.com/user-attachments/assets/914361ef-585f-459a-afda-b17fedf62eaf" />

---

## 🔗 Acesso Online

**https://flutlab.io/editor/d4385550-47a5-4856-9b27-823bc67466fc**

---

## 📱 Download / Testar

- **Versão Web**: [Clique aqui para testar online](https://flutlab.io/editor/d4385550-47a5-4856-9b27-823bc67466fc)
- **APK Android**: [Baixar APK](https://github.com/kaique2308/space-explorer/releases/download/v1.0.0/space_explorer.apk)

### 📷 QR Code para baixar o APK

![QR Code](qrcode.png)

---

## 🧱 Arquitetura da Aplicação

```
lib/
├── main.dart                      # Entrada do app, init Firebase, Provider
├── firebase_options.dart          # Configurações do Firebase
├── theme.dart                     # Tema, cores e tipografia do app
│
├── models/
│   ├── apod_model.dart            # Modelo de dados da API da NASA
│   └── favorite_model.dart        # Modelo do documento no Firestore
│
├── services/
│   ├── nasa_api_service.dart      # Chamadas à API REST da NASA
│   ├── firebase_service.dart      # CRUD no Firestore + Analytics
│   └── translation_service.dart   # Tradução automática (MyMemory API)
│
├── providers/
│   └── apod_provider.dart         # ChangeNotifier (estado global do app)
│
├── screens/
│   ├── main_shell.dart            # Shell de navegação inferior (IndexedStack)
│   ├── home_screen.dart           # Foto do dia + carrossel recente
│   ├── gallery_screen.dart        # Galeria em grade + filtro por data
│   ├── detail_screen.dart         # Imagem em tela cheia + info + favorito
│   └── favorites_screen.dart      # Lista de favoritos via stream Firestore
│
└── widgets/
    └── common_widgets.dart        # Componentes reutilizáveis de UI
```

### Fluxo de dados

```
NASA APOD API (REST) + MyMemory Translation API
        │
        ▼
  services/  ←── funções isoladas por responsabilidade
        │
        ▼
  providers/ (ChangeNotifier — estado global)
        │
        ▼
  Screens (home, gallery, detail, favorites)
        │
        ▼
  Widgets reutilizáveis
        │
        ▼
  Usuário (App Mobile / Web)
```

### Telas da aplicação

| Tela | Tipo | Descrição |
|------|------|-----------|
| `HomeScreen` | Estática | Foto do dia + carrossel recente |
| `GalleryScreen` | Estática (filtro por data) | Grade com os últimos 20 dias |
| `DetailScreen` | **Dinâmica** | Imagem em tela cheia + info + favorito |
| `FavoritesScreen` | Stream Firestore | Lista de favoritos salvos |

---

## 🛠 Tecnologias Utilizadas

| Tecnologia | Versão | Uso |
|-----------|--------|-----|
| Flutter | 3.x | UI e componentização mobile/web |
| Dart | 3.x | Linguagem principal |
| Provider | — | Gerenciamento de estado global |
| NASA APOD API | v1 | Dados de fotos astronômicas |
| Firebase Firestore | — | Persistência de favoritos |
| Firebase Analytics | — | Registro de visualizações e interações |
| MyMemory Translation API | — | Tradução automática para português |
| cached_network_image | — | Cache de imagens na rede |
| Google Fonts | — | Tipografia (Space Grotesk) |

---

## ⚙️ Como rodar localmente

### Pré-requisitos

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Um projeto no [Firebase](https://console.firebase.google.com/)
- (Opcional) Uma [chave da API da NASA](https://api.nasa.gov/) — a chave `DEMO_KEY` funciona para testes

### 1. Clone o repositório

```bash
git clone https://github.com/SEU_USUARIO/space-explorer.git
cd space-explorer
```

### 2. Instale as dependências

```bash
flutter pub get
```

### 3. Configure o Firebase

1. Acesse [console.firebase.google.com](https://console.firebase.google.com)
2. Crie um projeto (ex: `space-explorer`)
3. Adicione um app Web (para FlutLab/web) ou Android/iOS
4. Ative o **Cloud Firestore** (modo de teste)
5. Ative o **Google Analytics**
6. Copie as credenciais para `lib/firebase_options.dart`

### 4. (Opcional) Configure a chave da NASA

Em `lib/services/nasa_api_service.dart`, substitua:

```dart
static const String _apiKey = 'DEMO_KEY';
```

Pela sua chave obtida em [api.nasa.gov](https://api.nasa.gov).

### 5. Inicie o app

```bash
# Web
flutter run -d chrome

# Emulador Android
flutter run -d android

# Simulador iOS (apenas macOS)
flutter run -d ios
```

---

## 🚀 Deploy

### FlutLab (recomendado para web)

1. Acesse [flutlab.io](https://flutlab.io) e faça login
2. Clique em **"Import Project"** e faça upload do ZIP do projeto
3. Atualize `lib/firebase_options.dart` com suas credenciais Firebase
4. Clique em **Run** (preview web)

> **Atenção:** o FlutLab roda no navegador, então use a configuração Firebase para **web**. As regras do Firestore devem permitir leitura/escrita (modo de teste).

### APK Android

[Baixar APK v1.0.0](https://github.com/kaique2308/space-explorer/releases/download/v1.0.0/space_explorer.apk)

---

## ☁️ Regras do Firestore (Desenvolvimento)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // ⚠️ Apenas para testes
    }
  }
}
```

> Para produção, restrinja as escritas a usuários autenticados.

---

## 📡 APIs Utilizadas

**NASA APOD** — [https://api.nasa.gov/](https://api.nasa.gov/)

- ✅ Gratuita (com chave)
- ✅ Chave `DEMO_KEY` disponível para testes
- ✅ Dados disponíveis desde junho de 1995

**MyMemory Translation** — [https://mymemory.translated.net/](https://mymemory.translated.net/)

- ✅ Gratuita
- ✅ Sem necessidade de cadastro para uso básico

Endpoints usados:

```
GET https://api.nasa.gov/planetary/apod?api_key={key}              → Foto do dia
GET https://api.nasa.gov/planetary/apod?api_key={key}&count=20     → Últimas 20 fotos
GET https://api.nasa.gov/planetary/apod?api_key={key}&date={date}  → Foto por data
GET https://api.mymemory.translated.net/get?q={text}&langpair=en|pt → Tradução automática
```

---

## ✅ Checklist de requisitos

- [x] Aplicação em Flutter (Dart)
- [x] Consome API externa (NASA APOD)
- [x] Exibe dados da API na interface
- [x] Integração com Firebase Firestore (favoritos)
- [x] Firebase Analytics integrado
- [x] Tradução automática das descrições
- [x] Navegação entre múltiplas telas
- [x] Aplicação hospedada online (FlutLab)
- [x] README com orientações de uso
- [x] Tecnologias documentadas
- [x] Arquitetura desenhada no README
- [x] Código versionado no GitHub

---

## 📁 Estrutura de arquivos

```
space-explorer/
├── lib/
│   ├── models/
│   ├── services/
│   ├── providers/
│   ├── screens/
│   ├── widgets/
│   ├── theme.dart
│   ├── firebase_options.dart
│   └── main.dart
├── docs/
│   └── architecture.svg
├── pubspec.yaml
└── README.md
```

---

## 👤 Autor

Feito por **Kaique Campos de Oliveira** para a disciplina de Desenvolvimento Mobile.
