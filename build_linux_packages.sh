#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# 1. Detect the host OS and distribution details
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
  OS_LIKE=$ID_LIKE
  OS_NAME=$NAME
else
  OS_ID="unknown"
  OS_LIKE="unknown"
  OS_NAME="Unknown Linux"
fi

# 2. Extract version from pubspec.yaml
VERSION=$(grep '^version: ' pubspec.yaml | cut -d' ' -f2)
if [ -z "$VERSION" ]; then
  echo "Error: Could not extract version from pubspec.yaml"
  exit 1
fi

echo "=================================================="
echo " Packaging Al-Hadith Version: $VERSION"
echo " Detected OS: $OS_NAME ($OS_ID)"
echo "=================================================="

# 3. Build Debian (.deb) and AppImage packages using Fastforge
echo "--> Building Debian and AppImage packages..."
~/.pub-cache/bin/fastforge package --platform linux --targets deb,appimage

# 4. Build RPM package based on the detected OS distribution
echo "--> Packaging RPM..."
if [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* || "$OS_ID" == "rhel" || "$OS_LIKE" == *"rhel"* ]]; then
  # On native RedHat/Fedora systems, Fastforge's built-in RPM packaging works flawlessly out of the box.
  echo "--> Running native Fastforge RPM builder..."
  ~/.pub-cache/bin/fastforge package --platform linux --targets rpm
else
  # On Arch Linux, CachyOS, Debian, Ubuntu, etc.
  # Run the builder to generate the spec and workspace structure first
  echo "--> Running RPM workspace builder (workaround mode)..."
  ~/.pub-cache/bin/fastforge package --platform linux --targets rpm || true

  RPM_BUILD_DIR="dist/$VERSION/al_hadith-$VERSION-linux_rpm/rpmbuild"
  SPEC_FILE="$RPM_BUILD_DIR/SPECS/al_hadith.spec"

  if [ -f "$SPEC_FILE" ]; then
    # Double-check if the package was already successfully compiled (in case a native backend is configured)
    GENERATED_RPM=$(find "$RPM_BUILD_DIR/RPMS" -name "*.rpm" 2>/dev/null | head -n 1 || true)
    if [ -n "$GENERATED_RPM" ]; then
      echo "--> RPM package already compiled successfully."
      cp "$GENERATED_RPM" "dist/$VERSION/al_hadith-$VERSION-linux.rpm"
    else
      echo "--> Applying directory layout patch to spec file..."
      # Adjust paths in the spec file to pull assets from the parent BUILD folder
      sed -i 's|cp -r %{name}/\* |cp -r ../%{name}/* |g' "$SPEC_FILE"
      sed -i 's|cp -r %{name}\.desktop |cp -r ../%{name}.desktop |g' "$SPEC_FILE"
      sed -i 's|cp -r %{name}\.png |cp -r ../%{name}.png |g' "$SPEC_FILE"
      sed -i 's|cp -r %{name}\*\.xml |cp -r ../%{name}*.xml |g' "$SPEC_FILE"

      # Compile the RPM manually using the local topdir macro
      echo "--> Compiling RPM package manually via rpmbuild..."
      rpmbuild --define "_topdir $(pwd)/$RPM_BUILD_DIR" -bb "$SPEC_FILE"

      GENERATED_RPM=$(find "$RPM_BUILD_DIR/RPMS" -name "*.rpm" 2>/dev/null | head -n 1 || true)
      if [ -n "$GENERATED_RPM" ]; then
        cp "$GENERATED_RPM" "dist/$VERSION/al_hadith-$VERSION-linux.rpm"
        echo "--> Successfully copied RPM package to dist/$VERSION/"
      else
        echo "Error: Compiled RPM package could not be found"
        exit 1
      fi
    fi
  else
    echo "Error: RPM spec file was not generated"
    exit 1
  fi
fi

# 5. Build Flatpak
echo "=================================================="
echo "--> Packaging Flatpak..."
if command -v flatpak-builder >/dev/null 2>&1; then
  # Ensure the build bundle exists
  if [ ! -d "build/linux/x64/release/bundle" ]; then
    echo "--> Building Flutter Linux release bundle..."
    flutter build linux --release
  fi

  if [ -d "build/linux/x64/release/bundle" ]; then
    echo "--> Creating local bundle workspace for Flatpak..."
    rm -rf linux/packaging/flatpak/bundle
    cp -r build/linux/x64/release/bundle linux/packaging/flatpak/bundle
    cp linux/packaging/flatpak/com.ismail.al_hadith.desktop linux/packaging/flatpak/bundle/
    cp linux/packaging/flatpak/com.ismail.al_hadith.metainfo.xml linux/packaging/flatpak/bundle/
    convert assets/img/logo.png -resize 256x256 linux/packaging/flatpak/bundle/com.ismail.al_hadith.png
    
    echo "--> Running flatpak-builder..."
    rm -rf .flatpak-builder build-dir repo
    flatpak-builder --force-clean build-dir linux/packaging/flatpak/com.ismail.al_hadith.yaml --repo=repo
    
    echo "--> Generating flatpak bundle file..."
    flatpak build-bundle repo "dist/$VERSION/al_hadith-$VERSION-linux.flatpak" com.ismail.al_hadith
    
    # Clean up workspace
    rm -rf linux/packaging/flatpak/bundle build-dir repo .flatpak-builder
    echo "--> Flatpak package built successfully."
  else
    echo "Error: build/linux/x64/release/bundle could not be created."
  fi
else
  echo "--> flatpak-builder is not installed. Skipping local Flatpak package generation."
  echo "    To build manually: install 'flatpak-builder' and run flatpak-builder commands."
fi

# 6. Build Snap
echo "=================================================="
echo "--> Packaging Snap..."
if command -v snapcraft >/dev/null 2>&1; then
  echo "--> Running snapcraft..."
  sudo snapcraft clean
  sudo snapcraft --destructive-mode
  
  GENERATED_SNAP=$(find . -maxdepth 1 -name "*.snap" 2>/dev/null | head -n 1 || true)
  if [ -n "$GENERATED_SNAP" ]; then
    sudo chown $(id -u):$(id -g) "$GENERATED_SNAP" || true
    mv "$GENERATED_SNAP" "dist/$VERSION/"
    echo "--> Snap package built successfully: dist/$VERSION/$(basename "$GENERATED_SNAP")"
  else
    echo "Error: Snap package could not be found after build."
  fi
else
  echo "--> snapcraft is not installed. Skipping Snap package generation."
  echo "    To build manually: install 'snapcraft' and run 'snapcraft' in the root directory."
fi

echo "=================================================="
echo " Packaging Completed! Check 'dist/$VERSION/' for output packages:"
find "dist/$VERSION/" -maxdepth 1 -type f \( -name "*.AppImage" -o -name "*.deb" -o -name "*.rpm" -o -name "*.flatpak" -o -name "*.snap" \) -printf "  - %p\n" 2>/dev/null || ls -la "dist/$VERSION/"
echo "=================================================="

