# Theatrical Analytics

Welcome to **Theatrical Analytics**, a Flutter application designed to provide a user-friendly interface for exploring theatrical data, managing user profiles, and interacting with theater-related content such as actors, movies, and theaters.

## Overview

Theatrical Analytics is a mobile application built with Flutter that allows users to:
- Browse theatrical content (home, actors, movies, theaters) through a bottom navigation bar.
- Manage their user profile, including uploading profile pictures, setting social media links, and viewing credits.
- Purchase credits and log in/out securely.
- View detailed image galleries with the ability to set profile pictures or delete images.

The app integrates with a backend API (running locally at `http://localhost:8080`) to fetch user data, upload images, and update profile information.

## Features

### 1. **Home Screen**
- **Navigation**: A snake-shaped bottom navigation bar (`flutter_snake_navigationbar`) with four tabs:
  - **Home**: Displays a loading screen (`LoadingHomeScreen`) for theatrical content.
  - **Actors**: Shows a list of actors (`LoadingActors`).
  - **Movies**: Displays movie-related content (`LoadingMovies`).
  - **Theaters**: Shows theater-related content (`LoadingTheaters`).
- **User Menu**: A `CircleAvatar` in the AppBar with a popup menu for:
  - Viewing available credits (fetched from `UserService.fetchUserProfile()`).
  - Navigating to the user profile screen.
  - Logging out (clears `globalAccessToken` and redirects to `LoginSignupScreen`).

### 2. **User Profile**
- **Profile Management** (`UserProfileScreen.dart`):
  - Displays user email, role, and credits.
  - Allows editing social media links (Facebook, Instagram, YouTube) via a dialog.
  - Shows a grid of user-uploaded images with a "See More" button if more than 9 images exist.
  - Supports uploading new profile pictures with a preview dialog (`ImageUploadHandler.dart`).
- **Image Viewer** (`ImageViewerScreen.dart`):
  - A full-screen image gallery using `photo_view` for zooming and swiping between images.
  - Options to set an image as profile picture or delete it.
- **Image Upload** (`ImageUploadHandler.dart`):
  - Upload images from the gallery or via URL with a label and option to set as profile picture.

### 3. **API Integration** (`UserService.dart`)
- **Endpoints**:
  - `GET /api/user/info`: Fetches user profile data (email, role, credits, userImages, profilePhoto).
  - `POST /api/User/UploadPhoto`: Uploads a new image (returns success/failure).
  - `PUT /api/User/SetProfilePhoto/{imageId}`: Sets an image as profile picture (currently returns 404, needs backend fix).
  - `DELETE /api/User/Remove/Image/{imageId}`: Deletes an image.
  - Social media updates (`PUT /api/User/@/{platform}`) and phone number management.
- **Authentication**: Uses a `globalAccessToken` stored in `globals.dart` for all API requests.

### 4. **Authentication**
- **Login/Logout**: Managed via `LoginSignupScreen.dart` (not shown) and `AuthorizationStore.dart`.
- Logout clears the token and redirects to the login screen.

### 5. **Credits**
- Users can view and purchase credits (`PurchaseCreditsScreen.dart`) via a Stripe integration (`createCheckoutSession`).
