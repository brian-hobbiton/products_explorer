# 🛍️ Product Explorer App

A modern Flutter app that fetches and displays products from the [Fake Store API](https://fakestoreapi.com/) with clean
architecture, animations, and Provider for state management. Built as part of a front-end Flutter developer assessment.

---

## 🚀 Features

### ✅ Core Features

- 📦 Fetches product list from a public API
- 🖼️ Product cards with image, name, price, and rating
- 📱 Product detail page with Hero animation
- 🔄 Pull-to-refresh
- ⚠️ Error and empty state handling
- 📲 Smooth navigation and UI transitions

### ⭐ Bonus Features

- 🌑 Dark mode with persistent toggle (SharedPreferences)
- 📥 Offline caching (SharedPreferences)
- 🔄 Infinite scroll (lazy loading)
- 🧰 Filter products by category (choice chip)
- 📩 Share product (title,description & price)
- ❤️ Heart products (save for later)
- 🛒 Add product to shoping cart

---

## 🧱 Architecture & State Management

This app uses **Provider** for state management with `ChangeNotifier`. State is separated by concerns:

- `ProductProvider`: Manages product fetching, pagination, filtering, and caching
- `ThemeProvider`: Manages light/dark theme toggle

---

## 📦 Dependencies

| Package              | Purpose                     |
|----------------------|-----------------------------|
| provider             | State management            |
| http                 | API requests                |
| shared_preferences   | Caching & theme persistence |
| cached_network_image | Optimized image loading     |
| google_fonts         | Custom fonts(inter)         |
| device_preview       | Responsive design preview   |
| flutter_rating_bar   | Product rating display      |
| share_plus           | Share product details       |

---

## 📁 Folder Structure

lib/

- models/ # Data models
- providers/ # Theme & Product providers
- services/ # API service layer
- pages/ # pages
- widgets/ #widgets
- themes/ # App theming
- main.dart # Entry point

---

## 🛠️ Setup Instructions

1. Clone this repo:

```bash
   git clone https://github.com/brian-hobbiton/products_explorer
   cd products-explorer
```

2. Get dependeces:

```bash
  flutter pub get
```

3. Run the app

```bash
  flutter run
```

