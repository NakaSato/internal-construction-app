#!/bin/bash

# Flutter Build Verification Script
# This script performs a complete build verification for the Flutter app

echo "🚀 Starting Flutter Build Verification..."
echo ""

# Step 1: Clean project
echo "🧹 Cleaning project..."
flutter clean
if [ $? -ne 0 ]; then
    echo "❌ Clean failed"
    exit 1
fi

# Step 2: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    echo "❌ Pub get failed"
    exit 1
fi

# Step 3: Run code generation
echo "⚙️  Running code generation..."
dart run build_runner build --delete-conflicting-outputs
if [ $? -ne 0 ]; then
    echo "❌ Code generation failed"
    exit 1
fi

# Step 4: Analyze code
echo "🔍 Analyzing code..."
flutter analyze > analyze_output.txt 2>&1
# Check if there are any errors (not warnings or info)
error_count=$(grep -c "error •" analyze_output.txt || true)
if [ $error_count -gt 0 ]; then
    echo "❌ Analysis found errors:"
    grep "error •" analyze_output.txt
    exit 1
else
    echo "✅ Analysis passed (only warnings/info messages)"
fi

# Step 5: Run tests
echo "🧪 Running tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi

# Step 6: Build web
echo "🌐 Building for web..."
flutter build web --release
if [ $? -ne 0 ]; then
    echo "❌ Web build failed"
    exit 1
fi

# Step 7: Build iOS (if on macOS)
if [ "$(uname)" == "Darwin" ]; then
    echo "📱 Building for iOS..."
    flutter build ios --release --no-codesign
    if [ $? -ne 0 ]; then
        echo "❌ iOS build failed"
        exit 1
    fi
else
    echo "⏭️  Skipping iOS build (not on macOS)"
fi

# Cleanup
rm -f analyze_output.txt

echo ""
echo "🎉 All builds completed successfully!"
echo "✅ Code analysis: PASSED"
echo "✅ Unit tests: PASSED" 
echo "✅ Web build: PASSED"
if [ "$(uname)" == "Darwin" ]; then
    echo "✅ iOS build: PASSED"
fi
echo ""
echo "🚀 Calendar Management feature is production ready!"
