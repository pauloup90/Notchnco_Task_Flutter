# MovieHub - TMDB Flutter App

A production-quality Flutter application showcasing Clean Architecture, BLoC state management, and TMDB API integration.

![MovieHub Logo](assets/demo.png) *(Add a screenshot here)*

## 🚀 Features

- **Popular Movies**: Infinite scrolling list with efficient pagination and caching.
- **Movie Details**: Rich movie information with responsive design and beautiful transitions.
- **Favorites**: Persist favorite movies locally (offline supported) using optimistic UI updates.
- **Dark/Light Mode**: Automatic theme support based on system settings.
- **Error Handling**: Graceful error states, retry mechanisms, and offline support.

## 🛠️ Tech Stack & Architecture

This project follows **Clean Architecture** principles to ensure separation of concerns, testability, and scalability.

### Layers
1. **Presentation Layer**: 
   - **State Management**: `flutter_bloc` (Cubit) for predictable state management.
   - **UI**: Material 3 design, responsive layouts with `sizer`, and smooth animations.
   
2. **Domain Layer** (Pure Dart):
   - **Entities**: Core business objects (`Movie`, `MovieDetails`).
   - **Use Cases**: Encapsulated business logic (`GetPopularMovies`, `ToggleFavorite`).
   - **Repositories (Interfaces)**: Contracts for data operations.

3. **Data Layer**:
   - **Repositories (Implementation)**: Coordinates data retrieval from remote and local sources.
   - **Data Sources**: 
     - **Remote**: `Dio` for API requests with interceptors and error handling.
     - **Local**: `SharedPreferences` for caching favorites and movie data.
   - **Models**: DTOs ensuring type-safe JSON parsing.

### Key Decisions & Rationale

- **State Management (Cubit)**: Chosen for its simplicity and boilerplate reduction compared to full BLoC while maintaining excellent testability and stream-based architecture.
- **Dependency Injection (GetIt)**: Service locator pattern used for decoupling dependencies, making testing and swapping implementations rigorous.
- **Caching Strategy**: 
  - **Favorites**: Persisted indefinitely until removed.
  - **API Responses**: Cached with a 24-hour expiry to support offline browsing while keeping data reasonably fresh.
- **Security**: 
  - API keys are stored in a `.env` file (not identifying in git) using `flutter_dotenv`.
  - HTTPS is enforced for all network traffic.
- **Performance**: 
  - `cached_network_image` for efficient image loading and caching.
  - `ListView.builder` for lazy loading of movie lists.
  - `Equatable` to prevent unnecessary rebuilds.

## 🔧 Setup & Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/moviehub.git
   cd notchnco-task
   ```

2. **Setup Environment Variables**
   Create a `.env` file in the root directory:
   ```env
   TMDB_ACCESS_TOKEN=your_tmdb_read_access_token_here
   ```
   > Note: A default key is provided in the code for demonstration, but you should use your own for production.

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the App**
   ```bash
   flutter run 
   ``` 
 
## 🧪 Testing

Run the test suite:
```bash
flutter test
```

## 📂 Project Structure

```
lib/
├── core/                   # Core functionality (DI, Errors, Utils)
├── data/                   # Data layer (Models, Sources, Repos)
├── domain/                 # Domain layer (Entities, UseCases, Repos Interfaces)
├── presentation/           # UI layer
│   ├── cubit/              # State management
│   ├── screens/            # Screen widgets
│   └── widgets/            # Reusable UI components
├── routes/                 # Navigation
├── theme/                  # App theming
└── main.dart               # Entry point
```

## 🔒 Security Note
The `.env` file containing API keys is included in `.gitignore`. For this submission, a sample key is provided, but in a real scenario, this would be injected via CI/CD secrets.
