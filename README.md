# WeatherForecast App

A Ruby on Rails application that allows users to retrieve current weather data by entering an address. This demonstrates API integration, service object architecture, caching, and testing best practices.

---

## ✅ Features

- Accepts a user-entered address via a form
- Geocodes the address to latitude/longitude and zip code using Google Geocoding API
- Retrieves current weather forecast using OpenWeatherMap API
- Displays temperature, high, low, and weather description
- Caches forecast results per zip code for 30 minutes
- Indicates if the forecast is served from cache
- Stores geocoding data securely in signed cookies for 30 days
- Production-quality code structure with clear separation of concerns
- Fully tested with RSpec and WebMock

---

## 🚀 How to Run Locally

1️⃣ **Clone the repository**:

```bash
git clone https://github.com/yourusername/weather_forecast_app.git
cd weather_forecast_app
````

2️⃣ **Install dependencies**:

```bash
bundle install
```

3️⃣ **Set up environment variables**:

Create a `.env` file (not checked into version control) or export these:

```
GOOGLE_GEOCODING_API_KEY=your_google_api_key
WEATHER_API_KEY=your_openweather_api_key
```

4️⃣ **Start the Rails server**:

```bash
rails server
```

5️⃣ **Run tests**:

```bash
bundle exec rspec
```

---

## ⚙️ Architecture & Design

### 🧩 Design Patterns

* **Service Object Pattern** — Each service class has a single responsibility
* **Template Method Pattern** — ApiService defines standardized API error handling
* **Caching Strategy** — Rails.cache with time-based expiration
* **Encapsulation** — Controllers coordinate, services handle logic
* **Secure Cookies** — Stores non-sensitive geolocation data signed for integrity

---

## 🧭 Decomposition of the Application

This app is designed using a clear separation of concerns, with a Service Object architecture. Each component has a single, well-defined responsibility.

### ✅ 1️⃣ ForecastsController

- Coordinates the overall user flow
- Handles user input (address)
- Uses GeocodingService to get coordinates and zip
- Stores geolocation in secure signed cookies
- Retrieves or caches forecast data
- Sets @from_cache flag for UI

---

### ✅ 2️⃣ ApplicationService

- Abstract base class
- Standardizes `.call` interface for all services
- Enforces a consistent entry point for service objects

---

### ✅ 3️⃣ ApiService

- Handles HTTP calls using HTTParty
- Centralizes error handling with `safe_get`
- Logs failures in a standard way
- Ensures derived services don't duplicate HTTP logic

---

### ✅ 4️⃣ GeocodingService

- Inherits from ApiService
- Uses Google Geocoding API
- Returns latitude, longitude, and zip code for a given address
- Handles API errors gracefully

---

### ✅ 5️⃣ WeatherService

- Inherits from ApiService
- Calls OpenWeatherMap API with lat/lon
- Parses and returns temperature, high, low, and description
- Handles failures gracefully

---

### ✅ 6️⃣ Views

- `new.html.erb`: Address input form
- `show.html.erb`: Displays forecast details and cache indicator

---

### ✅ 7️⃣ Caching Layer

- Uses Rails.cache
- Stores weather forecasts keyed by zip code for 30 minutes
- Reduces external API calls and improves performance

---

### ✅ 8️⃣ Cookies

- Stores lat, lon, and address in signed cookies
- Expiration: 30 days
- Ensures user data is tamper-resistant

---

## 📦 Component Breakdown

### 🔹 Controllers

* `ForecastsController`

  * `new` — Form to enter address
  * `create` — Geocodes address, stores signed cookie, redirects to show
  * `show` — Reads cookie, uses cached forecast or calls WeatherService

---

### 🔹 Services

* `ApplicationService`

  * Standardizes the `.call` interface for all services

* `ApiService`

  * Shared error-handling, logging, and HTTP request abstraction

* `GeocodingService`

  * Uses Google Geocoding API to get lat/lon/zip

* `WeatherService`

  * Uses OpenWeatherMap API to fetch weather data (temperature, high/low, description)

---

## 🧪 Testing

* Uses **RSpec** for unit and controller tests
* **WebMock** stubs external API calls to ensure isolation
* Tests include:

  * GeocodingService
  * WeatherService
  * ForecastsController (cookies, redirects, caching)

Run all tests with:

```bash
bundle exec rspec
```

---

## 💾 Caching Strategy

* Forecasts cached in Rails.cache with a 30-minute expiry per zip code
* `ForecastsController#show` sets `@from_cache` to true/false for UI display
* Reduces external API calls and improves latency

---

## 🍪 Cookie Strategy

* Uses `cookies.signed` to store:

  * lat
  * lon
  * address
* Expires in 30 days
* Signed to prevent tampering

---

## 🔑 Environment Variables

| Variable Name              | Description                   |
| -------------------------- | ----------------------------- |
| `GOOGLE_GEOCODING_API_KEY` | Your Google Geocoding API key |
| `WEATHER_API_KEY`          | Your OpenWeatherMap API key   |

---

## 🧠 Scalability & Production Readiness

* Service objects decoupled for easy testing and future extension
* Centralized error handling in ApiService
* Caching strategy reduces load on third-party APIs
* Can easily switch to Redis for distributed caching
* Secure signed cookies for storing user input
* Thorough test suite for safe refactoring

---

## 👨‍💻 Author

**Bharat Vattaparambill**  
Senior Software Engineer  
GitHub: [bharatvb6](https://github.com/bharatvb6)  
Email: [bharatv2544@gmail.com](mailto:bharatv2544@gmail.com)
