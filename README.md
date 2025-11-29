# Powerhouse

A comprehensive Flutter fitness and nutrition tracking application.

## Features

- 🏋️ Workout tracking and logging
- 🍽️ Nutrition tracking with AI meal scanner
- 📊 Progress tracking and analytics
- 🎯 Goal setting and achievements
- 🏆 Badges and challenges
- 💡 Daily fitness tips and educational content
- 📱 Cross-platform support (iOS, Android, Web)

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- A Supabase account and project
- A Google Gemini API key

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd powerhouse
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Environment Variables

1. Copy the `.env.example` file to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Open `.env` and fill in your actual credentials:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_ANON_KEY`: Your Supabase anonymous key
   - `GEMINI_API_KEY`: Your Google Gemini API key

**Important:** Never commit the `.env` file to version control. It's already included in `.gitignore`.

### 4. Get Your API Keys

#### Supabase
1. Go to [supabase.com](https://supabase.com)
2. Create a new project or use an existing one
3. Go to Settings > API
4. Copy the `URL` and `anon/public` key

#### Google Gemini AI
1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Create a new API key
3. Copy the API key

### 5. Run the Application

```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Core configurations and utilities
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic and API services
└── main.dart       # Application entry point
```

## Database Setup

This project uses Supabase as the backend. You'll need to set up the following tables in your Supabase project:
- `users`
- `foods`
- `food_logs`
- `workouts`
- `workout_logs`
- `weight_history`
- `badges`
- `challenges`
- `tips`

Refer to the `database/` folder for schema details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

- Never commit your `.env` file
- Keep your API keys secure
- Rotate keys if they are accidentally exposed

## License

This project is licensed under the MIT License.

