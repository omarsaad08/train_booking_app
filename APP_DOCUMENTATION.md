# Train Booking App - Complete Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Tech Stack](#tech-stack)
4. [Features](#features)
5. [User Flows](#user-flows)
6. [Screen Guide](#screen-guide)
7. [API Integration](#api-integration)
8. [Data Management](#data-management)
9. [Error Handling](#error-handling)
10. [Internationalization](#internationalization)
11. [Security](#security)
12. [Development Guide](#development-guide)

---

## Project Overview

**Train Booking** is a Flutter mobile application that allows users to browse, book, and manage train reservations. The app supports full Arabic (RTL) localization and provides a seamless ticket booking experience with image upload capabilities.

### Key Objectives
- Enable users to search and book train tickets
- Manage booking history and confirmation details
- Upload and edit travel-related images
- Provide secure authentication and user management

### Project Structure
```
train_booking/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── appRouter.dart            # Route configuration
│   ├── config/
│   │   └── app_theme.dart        # Theme & styling
│   ├── data/
│   │   ├── auth_service.dart     # Authentication
│   │   ├── booking_service.dart  # Booking operations
│   │   ├── image_service.dart    # Image management
│   │   └── token_storage.dart    # Secure token storage
│   ├── presentation/
│   │   ├── components/
│   │   │   ├── custom_button.dart
│   │   │   └── custom_text_field.dart
│   │   └── screens/
│   │       ├── auth/
│   │       │   ├── login.dart
│   │       │   └── signup.dart
│   │       └── base/
│   │           ├── home.dart
│   │           ├── bookings_list.dart
│   │           ├── profile.dart
│   │           ├── booking_confirmation.dart
│   │           ├── booking_images.dart
│   │           └── image_editing.dart
│   └── logic/                    # Business logic
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code
├── pubspec.yaml                  # Dependencies
└── analysis_options.yaml         # Linting rules
```

---

## Architecture

### MVC-Like Pattern
The app follows a layered architecture:

```
┌─────────────────────────────────────┐
│      Presentation Layer             │
│  (Screens & UI Components)          │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│       Logic Layer                   │
│   (Business Logic & State)          │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│        Data Layer                   │
│  (Services & API Integration)       │
└──────────────────┬──────────────────┘
                   │
┌──────────────────▼──────────────────┐
│     Remote Data Source              │
│    (Backend API & Database)         │
└─────────────────────────────────────┘
```

### Service Architecture
- **AuthService**: Handles login, signup, and token management
- **BookingService**: Manages booking creation and retrieval
- **ImageService**: Handles image upload and retrieval
- **TokenStorage**: Secure local storage using flutter_secure_storage

---

## Tech Stack

### Frontend (Flutter)
| Package | Purpose | Version |
|---------|---------|---------|
| flutter | UI Framework | 3.10.0+ |
| dio | HTTP Client | 5.9.0 |
| flutter_secure_storage | Secure Storage | 9.2.4 |
| image_picker | Image Selection | 1.2.1 |
| image | Image Processing | 4.2.0 |
| intl | Localization | 0.20.0 |
| flutter_localizations | RTL Support | SDK |
| gal | Image Gallery | 2.0.1 |
| screenshot | Screenshot Capture | 3.0.0 |
| path_provider | File Access | 2.1.0 |

### Backend (PHP)
- **PHP 8.1+**: Server-side language
- **MySQL 8.0**: Database
- **PDO**: Database abstraction
- **Nginx**: Web server
- **Docker**: Containerization

### DevOps
- **Docker Compose**: Container orchestration
- **Docker**: Application containerization

---

## Features

### 1. Authentication
- **User Registration**: Create new accounts with email and password
- **User Login**: Secure login with JWT token-based authentication
- **Password Validation**: 6+ characters required
- **Email Validation**: RFC-compliant email format
- **Token Management**: Automatic token storage and refresh

### 2. Booking Management
- **Search Trains**: Filter by departure and arrival cities
- **Time Slots**: 5 predefined departure times (12 AM, 6 AM, 12 PM, 6 PM, 12 AM)
- **Booking Creation**: Reserve seats for selected routes and times
- **Booking List**: View all current and past bookings
- **Booking Details**: View confirmation details with ticket information
- **Booking Confirmation**: Visual confirmation of successful booking

### 3. Image Management
- **Image Upload**: Upload photos for each booking
- **Image Editing**: Apply filters (Grayscale, Sepia, Blue, Warm tones)
- **Gallery View**: Browse uploaded images for a booking
- **Image Deletion**: Remove unwanted images
- **Image Metadata**: Store and retrieve image information

### 4. User Profile
- **Profile View**: Display user information
- **Logout**: Secure session termination
- **User ID Display**: Show unique user identifier

### 5. Localization
- **Arabic Support**: Full RTL (Right-to-Left) interface
- **Arabic Translations**: All UI text in Arabic
- **Date Formatting**: Localized date and time display

### 6. UI/UX
- **Gradient Designs**: Modern gradient buttons and containers
- **Material Design**: Following Material Design 3 principles
- **Dark Error States**: Clear visual feedback for errors
- **Loading States**: Loading indicators during async operations
- **Empty States**: User-friendly empty state messages

---

## User Flows

### 1. Registration Flow
```
Launch App
    ↓
Check if logged in → No → Login Screen
    ↓
User clicks "Sign Up"
    ↓
Sign Up Screen
├── Enter Name
├── Enter Email
├── Enter Password
├── Confirm Password
└── Accept Terms & Conditions
    ↓
Validate Inputs
├── Name: 3+ characters
├── Email: Valid format
├── Password: 6+ characters
├── Passwords: Must match
└── Terms: Must accept
    ↓
Send to Backend
├── Check if email exists
├── Hash password
└── Create user account
    ↓
Success? → Yes → Save Token → Navigate to Home
    ↓
Failure → Show Error Message
```

### 2. Login Flow
```
Login Screen
├── Enter Email
└── Enter Password
    ↓
Validate Inputs
├── Email: Not empty
└── Password: Not empty
    ↓
Send Credentials to Backend
├── Verify email exists
├── Verify password
└── Generate JWT token
    ↓
Success? → Yes → Save Token & User ID → Navigate to Home
    ↓
Failure → Show Specific Error
├── Wrong password: "Invalid email or password"
├── Account not found: "Account does not exist"
└── Server error: "Server error, try later"
```

### 3. Booking Flow
```
Home Screen
├── Select From City
├── Select To City
└── Wait for Time Slots
    ↓
Time Slots Display (if cities selected)
├── 12 AM to 2 AM
├── 6 AM to 8 AM
├── 12 PM to 2 PM
├── 6 PM to 8 PM
└── 12 AM to 2 AM
    ↓
User selects Time Slot
    ↓
"Create Booking" Button Enabled
    ↓
User Clicks Button
    ↓
Validate Selection
├── From city selected: ✓
├── To city selected: ✓
├── Time slot selected: ✓
└── User logged in: ✓
    ↓
Send Booking Request
├── user_id: From storage
├── from_city: Selected city
├── to_city: Selected city
├── departure_time: Selected slot
└── arrival_time: Selected slot
    ↓
Backend Creates Booking
├── Store in database
├── Generate booking ID
└── Return confirmation
    ↓
Success → Navigate to Confirmation Screen
    ↓
Confirmation Screen
├── Display Booking ID
├── Display Route (From → To)
├── Display Times
└── Option to Upload Images
    ↓
User Can:
├── View Uploaded Images
├── Upload New Images
├── Upload Images with Filters
└── Return to Home
```

### 4. Image Upload & Editing Flow
```
Booking Confirmation → Click "Upload Images"
    ↓
Booking Images Screen
├── Display existing images
└── "Pick Image" Button
    ↓
User Clicks Pick Image
    ↓
Image Picker Dialog
├── Camera
└── Gallery
    ↓
User Selects Image
    ↓
Image Editing Screen
├── Preview Image
├── Filter Options:
│   ├── Normal (no filter)
│   ├── Grayscale
│   ├── Sepia
│   ├── Blue tone
│   └── Warm tone
└── Apply Filter (Optional)
    ↓
User Clicks Save
    ↓
Upload to Backend
├── POST image data
├── Include booking_id
└── Include edited image
    ↓
Backend Stores Image
├── Save to file system
├── Update database
└── Return image info
    ↓
Success → Add to Gallery
    ↓
User Can:
├── Upload More Images
├── Delete Images
└── Return to Confirmation
```

### 5. View Bookings Flow
```
Home Screen → Click "View My Bookings"
    ↓
Bookings List Screen
    ↓
Load User Bookings
├── Get user_id from storage
├── Fetch bookings from backend
└── Display in list
    ↓
For Each Booking:
├── Display Route
├── Display Date/Time
├── Display Booking ID
└── Display Status
    ↓
User Can:
├── Click booking → View Details
├── Swipe → Delete (optional)
└── Back → Return to Home
    ↓
Booking Details → Navigate to Confirmation Screen
```

---

## Screen Guide

### Authentication Screens

#### Login Screen (`lib/presentation/screens/auth/login.dart`)
**Purpose**: Authenticate existing users

**UI Components**:
- Logo container with train icon
- Title: "مرحباً بك مجدداً" (Welcome back)
- Email input field
  - Validation: Not empty, contains @
- Password input field
  - Visibility toggle
  - Validation: Not empty
- Error message display (if error occurs)
- Login button (with loading state)
- Sign up link

**State Management**:
- `_emailController`: Email input
- `_passwordController`: Password input
- `_isLoading`: Loading state
- `_errorMessage`: Current error message
- `_showPassword`: Password visibility toggle

**Error Handling**:
| Status Code | Error Message |
|---|---|
| 401 | "البريد الإلكتروني أو كلمة المرور غير صحيحة" |
| 404 | "الحساب غير موجود..." |
| 400 | "بيانات غير صحيحة..." |
| 500 | "خطأ في الخادم..." |
| Timeout | "انتهت مهلة الاتصال..." |

#### Signup Screen (`lib/presentation/screens/auth/signup.dart`)
**Purpose**: Register new user accounts

**UI Components**:
- Logo container with person_add icon
- Title: "إنشاء حساب جديد" (Create new account)
- Name input field
  - Validation: 3+ characters
- Email input field
  - Validation: Not empty, contains @
- Password input field
  - Visibility toggle
  - Validation: 6+ characters
- Confirm password field
  - Visibility toggle
  - Validation: Must match password
- Terms & conditions checkbox
- Error message display
- Sign up button (with loading state)
- Login link

**State Management**:
- `_nameController`: Name input
- `_emailController`: Email input
- `_passwordController`: Password input
- `_confirmPasswordController`: Confirm password input
- `_isLoading`: Loading state
- `_errorMessage`: Current error message
- `_showPassword`: Password visibility
- `_showConfirmPassword`: Confirm password visibility
- `_agreedToTerms`: Terms acceptance status

**Validation Order**:
1. All fields must be filled
2. Name: 3+ characters
3. Email: Must contain @
4. Password: 6+ characters
5. Confirm Password: Must match password
6. Terms: Must be checked
7. Backend validation: Email uniqueness

**Error Handling**:
| Status Code | Error Message |
|---|---|
| 409 | "البريد الإلكتروني مسجل بالفعل..." |
| 400 | "بيانات غير صحيحة..." |
| 422 | "البيانات المدخلة غير صحيحة" |
| 500 | "خطأ في الخادم..." |

---

### Main Application Screens

#### Home Screen (`lib/presentation/screens/base/home.dart`)
**Purpose**: Main booking interface

**UI Components**:
- App bar with profile icon
- "View My Bookings" button
- From City Dropdown
  - 27 Egyptian cities
- To City Dropdown
  - Same city list
- Time Slots Grid (shows when both cities selected)
  - 5 time slots: 12 AM, 6 AM, 12 PM, 6 PM, 12 AM
  - Each shows departure and arrival times
  - Selection highlights selected slot
- "Create Booking" button (enabled only when cities and time selected)

**State Management**:
- `_selectedFromCity`: Selected departure city
- `_selectedToCity`: Selected arrival city
- `_selectedTimeSlotIndex`: Selected time slot
- `_userId`: Current logged-in user ID
- `_isCreatingBooking`: Loading state

**Egyptian Cities Supported**:
القاهرة, الإسكندرية, البحيرة, دمياط, الدقهلية, الغربية, المنوفية, القليوبية, كفر الشيخ, الشرقية, بورسعيد, الإسماعيلية, السويس, شمال سيناء, جنوب سيناء, الفيوم, بني سويف, المنيا, أسيوط, سوهاج, قنا, الأقصر, أسوان, البحر الأحمر, الوادي الجديد

**Time Slots**:
```json
[
  {"label": "12 صباحاً", "departure": "00:00:00", "arrival": "02:00:00"},
  {"label": "6 صباحاً", "departure": "06:00:00", "arrival": "08:00:00"},
  {"label": "12 ظهراً", "departure": "12:00:00", "arrival": "14:00:00"},
  {"label": "6 مساءً", "departure": "18:00:00", "arrival": "20:00:00"},
  {"label": "12 ليلاً", "departure": "00:00:00", "arrival": "02:00:00"}
]
```

#### Booking Confirmation Screen (`lib/presentation/screens/base/booking_confirmation.dart`)
**Purpose**: Display booking confirmation details

**UI Components**:
- Booking ID display
- Route information (From → To)
- Time information (Departure & Arrival)
- Scheduled time display
- "Upload Images" button
- Back button

**Parameters**:
- `bookingId`: Unique booking identifier
- `fromCity`: Departure city
- `toCity`: Arrival city
- `scheduleTime`: Selected time slot label

#### Bookings List Screen (`lib/presentation/screens/base/bookings_list.dart`)
**Purpose**: Display user's booking history

**UI Components**:
- List of user's bookings
- For each booking:
  - Booking ID
  - Route (From → To)
  - Date/Time information
  - Clickable to view details

**Data Loading**:
- Fetches bookings for current user
- Shows loading indicator while fetching
- Handles empty state (no bookings)
- Handles errors gracefully

#### Booking Images Screen (`lib/presentation/screens/base/booking_images.dart`)
**Purpose**: Manage images for a specific booking

**UI Components**:
- App bar with back button and title
- Image gallery (grid view of uploaded images)
- "Pick Image" button (floating action button)
- For each image:
  - Image preview
  - Delete button

**Features**:
- Upload new images
- Delete existing images
- View images in gallery
- Navigate to image editing screen

**Parameters**:
- `bookingId`: Associated booking
- `fromCity`: For reference
- `toCity`: For reference

#### Image Editing Screen (`lib/presentation/screens/base/image_editing.dart`)
**Purpose**: Edit and apply filters to images

**UI Components**:
- Image preview (large)
- Filter selection chips:
  - Normal (no filter)
  - Grayscale
  - Sepia
  - Blue
  - Warm
- Save button
- Cancel button

**Filters**:
1. **Grayscale**: Converts to black and white
2. **Sepia**: Classic sepia tone effect
   - Formula: R = 0.393*R + 0.769*G + 0.189*B
3. **Blue**: Enhances blue tones
   - R: ×0.7, G: ×0.8, B: ×1.2
4. **Warm**: Warm color temperature
   - R: ×1.2, G: ×1.1, B: ×0.8

**State Management**:
- `_selectedFilter`: Currently selected filter
- `_filteredImageBytes`: Processed image data
- `_isProcessing`: Processing state

#### Profile Screen (`lib/presentation/screens/base/profile.dart`)
**Purpose**: User profile and account management

**UI Components**:
- User ID display
- User information section
- Logout button
- Confirmation dialog for logout

**Features**:
- Display user ID
- Logout with confirmation
- Redirect to login after logout

---

## API Integration

### Base Configuration
```dart
BaseOptions(
  baseUrl: 'http://192.168.1.218:8080',
  connectTimeout: Duration(seconds: 5),
  receiveTimeout: Duration(seconds: 3),
)
```

### Authentication Endpoints

#### Signup
```
POST /signup
Content-Type: application/json

Request:
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}

Response (200/201):
{
  "token": "eyJhbGc...",
  "user_id": 1,
  "message": "User created successfully"
}

Response (409):
{
  "error": "Email already exists",
  "message": "The email address is already registered"
}
```

#### Login
```
POST /login
Content-Type: application/json

Request:
{
  "email": "john@example.com",
  "password": "password123"
}

Response (200):
{
  "token": "eyJhbGc...",
  "user_id": 1,
  "message": "Login successful"
}

Response (401):
{
  "error": "Invalid credentials",
  "message": "Email or password is incorrect"
}
```

### Booking Endpoints

#### Create Booking
```
POST /bookings
Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "user_id": 1,
  "from_city": "القاهرة",
  "to_city": "الإسكندرية",
  "departure_time": "06:00:00",
  "arrival_time": "08:00:00",
  "schedule_time": "6 صباحاً"
}

Response (201):
{
  "id": 1,
  "user_id": 1,
  "from_city": "القاهرة",
  "to_city": "الإسكندرية",
  "departure_time": "06:00:00",
  "arrival_time": "08:00:00",
  "created_at": "2024-12-02T10:30:00"
}
```

#### Get User Bookings
```
GET /bookings?user_id={userId}
Authorization: Bearer {token}

Response (200):
{
  "data": [
    {
      "id": 1,
      "user_id": 1,
      "from_city": "القاهرة",
      "to_city": "الإسكندرية",
      "departure_time": "06:00:00",
      "arrival_time": "08:00:00",
      "created_at": "2024-12-02T10:30:00"
    }
  ]
}
```

### Image Endpoints

#### Upload Image
```
POST /images
Authorization: Bearer {token}
Content-Type: multipart/form-data

Request:
{
  "booking_id": 1,
  "image": [binary data]
}

Response (200/201):
{
  "id": 1,
  "booking_id": 1,
  "image_path": "/uploads/img_1.jpg",
  "created_at": "2024-12-02T10:30:00"
}
```

#### Get Booking Images
```
GET /images?booking_id={bookingId}
Authorization: Bearer {token}

Response (200):
{
  "data": [
    {
      "id": 1,
      "booking_id": 1,
      "image_path": "/uploads/img_1.jpg",
      "created_at": "2024-12-02T10:30:00"
    }
  ]
}
```

#### Delete Image
```
DELETE /images/{imageId}
Authorization: Bearer {token}

Response (200):
{
  "message": "Image deleted successfully"
}
```

---

## Data Management

### Local Storage
Uses `flutter_secure_storage` for sensitive data:

```dart
// Stored Data
token: String                // JWT authentication token
user_id: int                // Current user ID
```

### Token Management
- **Storage**: Secure local storage
- **Format**: JWT (JSON Web Token)
- **Lifetime**: Persistent until logout
- **Headers**: Automatically added to all authenticated requests
  ```
  Authorization: Bearer {token}
  ```

### Data Models

#### User
```dart
{
  "id": int,
  "name": String,
  "email": String,
  "created_at": DateTime
}
```

#### Booking
```dart
{
  "id": int,
  "user_id": int,
  "from_city": String,
  "to_city": String,
  "departure_time": String,  // HH:MM:SS
  "arrival_time": String,    // HH:MM:SS
  "schedule_time": String,   // User-friendly label
  "created_at": DateTime
}
```

#### Image
```dart
{
  "id": int,
  "booking_id": int,
  "image_path": String,      // Server path
  "created_at": DateTime
}
```

---

## Error Handling

### Comprehensive Error Handling Strategy

#### Login/Signup Errors

| Error Type | HTTP Code | Message |
|---|---|---|
| Wrong Password | 401 | "البريد الإلكتروني أو كلمة المرور غير صحيحة" |
| Account Not Found | 404 | "الحساب غير موجود. يرجى التحقق من البريد الإلكتروني" |
| Invalid Data | 400 | "بيانات غير صحيحة. يرجى التحقق من المدخلات" |
| Email Already Exists | 409 | "البريد الإلكتروني مسجل بالفعل. استخدم بريد آخر" |
| Server Error | 500 | "خطأ في الخادم. يرجى المحاولة لاحقاً" |
| Connection Timeout | - | "انتهت مهلة الاتصال. تحقق من الإنترنت" |
| Receive Timeout | - | "انتهت مهلة استقبال البيانات. حاول مجددا" |

#### Form Validation Errors

| Field | Validation | Error Message |
|---|---|---|
| Email (Login) | Not empty | "الرجاء إدخال البريد الإلكتروني" |
| Email (Login) | Contains @ | "يرجى إدخال بريد إلكتروني صحيح" |
| Password (Login) | Not empty | "الرجاء إدخال كلمة المرور" |
| Name (Signup) | 3+ characters | "الاسم يجب أن يكون 3 أحرف على الأقل" |
| Email (Signup) | Contains @ | "يرجى إدخال بريد إلكتروني صحيح" |
| Password (Signup) | 6+ characters | "كلمة المرور يجب أن تكون 6 أحرف على الأقل" |
| Confirm Password | Matches password | "كلمات المرور غير متطابقة" |
| Terms & Conditions | Checked | "يجب الموافقة على الشروط والأحكام" |

#### UI Error Display
All errors are displayed in:
- **Error Container**: Red-bordered box with white background
- **Error Icon**: Visual indicator (❌)
- **Error Message**: Clear, actionable text in Arabic
- **Automatic Clearing**: Errors clear when user retries

---

## Internationalization

### RTL (Right-to-Left) Support
- **Language**: Arabic (العربية)
- **Text Direction**: RTL automatically applied
- **Flutter Support**: `flutter_localizations` package

### Localization Configuration
```dart
localizationsDelegates: const [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
supportedLocales: const [
  Locale('ar', 'AE'),
],
```

### Arabic Text Throughout
- All UI labels in Arabic
- All error messages in Arabic
- All button text in Arabic
- All input hints in Arabic

### Date & Time Formatting
```dart
import 'package:intl/intl.dart';

// Format date in Arabic locale
final formatter = DateFormat('dd/MM/yyyy', 'ar_SA');
final formatted = formatter.format(DateTime.now());
```

---

## Security

### Authentication Security
1. **JWT Tokens**: Secure token-based authentication
2. **Secure Storage**: `flutter_secure_storage` for token storage
3. **HTTPS Ready**: Backend supports HTTPS in production
4. **Token Headers**: Automatic token injection in requests

### Data Security
1. **Password Hashing**: Backend uses bcrypt for password hashing
2. **Input Validation**: Client-side and server-side validation
3. **SQL Injection Prevention**: PDO with prepared statements
4. **CORS Support**: Configured for safe cross-origin requests

### API Security
1. **Authentication Middleware**: All protected endpoints require token
2. **Token Validation**: Backend validates token on each request
3. **Status Code Handling**: Proper HTTP status codes for errors
4. **Error Messages**: Safe, non-revealing error messages

### Best Practices
1. **No Hardcoded Secrets**: Configuration externalized
2. **Mounted Checks**: Prevents memory leaks
3. **Error Handling**: Comprehensive try-catch blocks
4. **Input Trimming**: Removes whitespace from inputs
5. **Validation Before Submit**: Form validation before API calls

---

## Development Guide

### Setup Instructions

#### Prerequisites
- Flutter SDK 3.10.0+
- Dart 3.10.0+
- Android SDK (for Android development)
- Xcode (for iOS development)
- Docker (for backend)

#### Installation
```bash
# 1. Clone repository
git clone <repository-url>
cd train_booking

# 2. Install dependencies
flutter pub get

# 3. Generate required files (if using build_runner)
flutter pub run build_runner build

# 4. Run the app
flutter run

# Development build
flutter run --debug

# Release build
flutter run --release
```

### Backend Setup
```bash
# 1. Navigate to backend
cd train_booking_backend

# 2. Start Docker services
docker-compose up -d

# 3. Verify services
docker-compose ps

# 4. Access PhpMyAdmin
# Navigate to: http://localhost:8081
# User: api_user
# Password: api_password

# 5. Logs
docker-compose logs -f php
docker-compose logs -f mysql
docker-compose logs -f nginx
```

### Code Structure Conventions

#### Naming
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables**: `camelCase`
- **Constants**: `kCamelCase`
- **Private members**: `_privateName`

#### File Organization
```
screen_name.dart
├── Imports
├── Widget Class
├── State Class
├── Helper Methods
│   ├── _buildXyz()
│   ├── _loadData()
│   └── _handleError()
└── Build Method
```

#### Widget Structure
```dart
class ScreenName extends StatefulWidget {
  const ScreenName({super.key});

  @override
  State<ScreenName> createState() => _ScreenNameState();
}

class _ScreenNameState extends State<ScreenName> {
  // Properties
  // Lifecycle methods (initState, dispose)
  // Business logic methods
  // Build method
}
```

### Testing Checklist

#### Authentication Flow
- [ ] Sign up with valid credentials
- [ ] Sign up with existing email (409 error)
- [ ] Sign up without accepting terms
- [ ] Sign up with weak password
- [ ] Login with correct credentials
- [ ] Login with wrong password (401 error)
- [ ] Login with non-existent email (404 error)
- [ ] Network error handling

#### Booking Flow
- [ ] Select from city
- [ ] Select to city
- [ ] Time slots appear correctly
- [ ] Create booking successfully
- [ ] View booking confirmation
- [ ] View bookings list

#### Image Flow
- [ ] Upload image from camera
- [ ] Upload image from gallery
- [ ] Apply filters to image
- [ ] Save filtered image
- [ ] View uploaded images
- [ ] Delete image

#### UI/UX
- [ ] RTL layout correct
- [ ] Arabic text displays correctly
- [ ] Loading states show
- [ ] Error messages clear and helpful
- [ ] Buttons disable during loading
- [ ] Proper navigation between screens

### Debugging Tips

#### Network Debugging
```dart
// Enable debug logging in AuthService
void debugLog(String message) {
  print('[AuthService] $message');
}
```

#### State Debugging
```dart
// Print state changes
setState(() {
  print('State updated: variable = $variable');
  variable = newValue;
});
```

#### Widget Rebuilds
```dart
@override
Widget build(BuildContext context) {
  print('Building ScreenName');
  return Scaffold(...);
}
```

### Common Issues & Solutions

#### Issue: "No token found"
**Solution**: Ensure token is saved after login:
```dart
await _tokenStorage.saveToken(response.data['token']);
```

#### Issue: CORS errors
**Solution**: Backend CORS headers are configured in nginx.conf

#### Issue: Images not uploading
**Solution**: Verify multipart form-data format in ImageService

#### Issue: RTL not working
**Solution**: Ensure `supportedLocales` includes Arabic in main.dart

#### Issue: Timeout errors
**Solution**: Check network connectivity and backend is running

---

## Troubleshooting

### Backend Connection Issues
```bash
# Check if services are running
docker ps

# View service logs
docker-compose logs php
docker-compose logs mysql

# Restart services
docker-compose restart

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

### Database Issues
```bash
# Access MySQL directly
docker exec -it train_booking_backend-mysql-1 mysql -u api_user -p api_db

# Check tables
SHOW TABLES;
DESCRIBE users;
DESCRIBE bookings;
DESCRIBE images;
```

### Flutter Issues
```bash
# Clean project
flutter clean

# Rebuild
flutter pub get
flutter pub upgrade

# Clear build cache
flutter clean
rm -rf build/

# Run with verbose output
flutter run -v
```

---

## Future Enhancements

### Phase 2 Features
- [ ] Real payment integration (Stripe, PayPal)
- [ ] Seat selection interface
- [ ] Email notifications for bookings
- [ ] SMS notifications for bookings
- [ ] PDF ticket generation
- [ ] Cancellation and refund system
- [ ] Review and rating system

### Phase 3 Features
- [ ] Multiple user profiles
- [ ] Favorite routes
- [ ] Notification preferences
- [ ] Passenger details storage
- [ ] Invoice generation
- [ ] Trip sharing feature

### Technical Improvements
- [ ] Implement GetX or Riverpod for state management
- [ ] Add unit and integration tests
- [ ] Implement caching strategy
- [ ] Add analytics tracking
- [ ] Implement biometric authentication
- [ ] Add offline mode support
- [ ] Optimize image upload with compression
- [ ] Implement pagination for large lists

---

## Support & Contact

For issues, feature requests, or contributions:
1. Check existing documentation
2. Review error messages and logs
3. Test on real device if possible
4. Report with detailed reproduction steps

---

## License

This project is proprietary. All rights reserved.

---

**Last Updated**: December 2, 2024
**Version**: 1.0.0
**Status**: Production Ready
