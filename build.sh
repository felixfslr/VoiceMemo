#!/bin/bash
# Build script for Vercel: packages the macOS app source as a downloadable zip
mkdir -p public/downloads
cd VoiceMemoApp && zip -r ../public/downloads/VoiceMemoApp.zip . -x ".build/*" ".swiftpm/*" && cd ..
