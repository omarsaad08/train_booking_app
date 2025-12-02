# Error Handling Implementation Guide

## Overview
Enhanced error handling has been added to the Login and Signup screens to provide users with specific, actionable error messages for common authentication issues.

## Login Screen (`lib/presentation/screens/auth/login.dart`)

### Error Handling Features
1. **Specific Error Messages** - Different messages for different error scenarios:
   - **401 Unauthorized**: "البريد الإلكتروني أو كلمة المرور غير صحيحة" (Invalid email or password)
   - **404 Not Found**: "الحساب غير موجود. يرجى التحقق من البريد الإلكتروني" (Account not found)
   - **400 Bad Request**: "بيانات غير صحيحة. يرجى التحقق من المدخلات" (Invalid data)
   - **500 Server Error**: "خطأ في الخادم. يرجى المحاولة لاحقاً" (Server error, try later)

2. **Network Error Handling**:
   - Connection timeouts
   - Receive timeouts
   - Bad responses
   - Unknown connection errors

3. **UI Improvements**:
   - Error message display box with red border and icon
   - Password visibility toggle button
   - Email validation (checks for @)
   - Input trimming for email

### State Variables
- `_errorMessage`: Stores the current error message
- `_showPassword`: Controls password visibility
- `_isLoading`: Shows loading state during authentication

## Signup Screen (`lib/presentation/screens/auth/signup.dart`)

### Enhanced Features
1. **Specific Error Messages**:
   - **409 Conflict**: "البريد الإلكتروني مسجل بالفعل..." (Email already registered)
   - **400 Bad Request**: "بيانات غير صحيحة..." (Invalid data)
   - **422 Unprocessable Entity**: "البيانات المدخلة غير صحيحة" (Invalid input data)
   - **500 Server Error**: "خطأ في الخادم..." (Server error)

2. **Form Validation**:
   - Name: 3+ characters required
   - Email: Must contain @ symbol
   - Password: 6+ characters required
   - Confirm Password: Must match password field
   - Terms & Conditions: Must be checked

3. **Additional Fields**:
   - Confirm Password field with visibility toggle
   - Terms & Conditions checkbox
   - Validation for password matching

4. **Improved UX**:
   - Email/password trimming
   - Separate error validation for all fields
   - Clear error messages for mismatched passwords
   - Visual feedback with error container

### State Variables
- `_errorMessage`: Current error message
- `_showPassword`: Password visibility
- `_showConfirmPassword`: Confirm password visibility
- `_agreedToTerms`: Terms acceptance status
- `_isLoading`: Loading indicator

## Error Message Display

Both screens display errors in a styled container with:
- Red error icon
- Error message text
- Red border and background
- Clear positioning above form fields

```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: AppTheme.errorColor.withOpacity(0.1),
    border: Border.all(color: AppTheme.errorColor),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      Icon(Icons.error_outline, color: AppTheme.errorColor),
      const SizedBox(width: 12),
      Expanded(
        child: Text(_errorMessage!),
      ),
    ],
  ),
)
```

## API Response Handling

### Expected Response Format
The backend should return errors in the following format:

```json
{
  "statusCode": 400,
  "message": "Error description",
  "error": "Error short code"
}
```

### HTTP Status Codes
- **200/201**: Success
- **400**: Bad request/validation error
- **401**: Unauthorized/wrong password
- **404**: Not found/user doesn't exist
- **409**: Conflict/email already exists
- **422**: Unprocessable entity
- **500**: Internal server error

## Testing Error Scenarios

### Login Test Cases
1. Valid credentials → Navigate to home
2. Invalid email format → Form validation error
3. Empty fields → Form validation error
4. Wrong password → "Invalid email or password"
5. Non-existent email → "Account not found"
6. Network timeout → "Connection timeout"
7. Server error → "Server error, try later"

### Signup Test Cases
1. New valid account → Navigate to home
2. Existing email → "Email already registered"
3. Weak password → "Password must be 6+ characters"
4. Mismatched passwords → "Passwords do not match"
5. Terms not agreed → "Must accept terms"
6. Invalid email format → Form validation error
7. Short name → "Name must be 3+ characters"

## Future Enhancements

1. **Rate Limiting**: Add retry counter and cooldown period
2. **Email Verification**: Send verification email after signup
3. **Password Reset**: Implement forgot password flow
4. **Social Login**: Add OAuth2 integration
5. **2FA**: Two-factor authentication option
6. **Account Lock**: Lock after multiple failed attempts
7. **Audit Logging**: Log authentication attempts

## Backend Integration Checklist

- [ ] Implement 409 Conflict response for duplicate emails
- [ ] Return meaningful error messages in response body
- [ ] Validate email format server-side
- [ ] Validate password strength server-side
- [ ] Implement rate limiting (5 attempts per 15 minutes)
- [ ] Hash passwords with bcrypt
- [ ] Return proper HTTP status codes
- [ ] Include error codes in response for i18n support

## Notes

- All error messages are in Arabic (RTL support)
- Errors clear automatically when user interacts with form
- Loading state prevents duplicate submissions
- Form validation runs before API call
- Mounted checks prevent memory leaks
