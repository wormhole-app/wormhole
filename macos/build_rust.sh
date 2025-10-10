#!/bin/bash

set -e

# Build Rust library for macOS
cd "$SRCROOT/../native"

# Determine the build profile based on configuration
if [ "$CONFIGURATION" == "Release" ]; then
    echo "Building Rust library in Release mode..."
    cargo build --release
else
    echo "Building Rust library in Debug mode..."
    cargo build
fi

echo "Rust library built successfully"
