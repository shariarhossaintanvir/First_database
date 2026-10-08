#!/usr/bin/env bash
set -e

# Flutter SDK directory in Vercel build container
FLUTTER_DIR="$HOME/flutter"

if [ ! -d "$FLUTTER_DIR" ]; then
  echo ">>> Cloning Flutter stable SDK..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
else
  echo ">>> Using existing Flutter SDK at $FLUTTER_DIR..."
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

echo ">>> Flutter version:"
flutter --version

echo ">>> Disabling analytics & enabling web..."
flutter config --no-analytics
flutter config --enable-web

echo ">>> Installing dependencies..."
flutter pub get

echo ">>> Compiling Flutter Web release..."
if [ -n "$RECAPTCHA_V3_KEY" ]; then
  echo ">>> Compiling with custom RECAPTCHA_V3_KEY..."
  flutter build web --release --dart-define=RECAPTCHA_V3_KEY="$RECAPTCHA_V3_KEY"
else
  flutter build web --release
fi

echo ">>> Build completed successfully. Output ready at build/web"
