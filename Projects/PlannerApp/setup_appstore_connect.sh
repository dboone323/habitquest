#!/bin/bash

# App Store Connect API Key Setup Script
# This script helps configure App Store Connect API keys for automated deployment

set -e

echo "🚀 Setting up App Store Connect API Key for Automated Deployment"
echo "================================================================="

# Check if we're in the right directory
if [[ ! -f "fastlane/Fastfile" ]]; then
    echo "❌ Error: This script must be run from the project root directory (where fastlane/ exists)"
    exit 1
fi

echo ""
echo "📋 Prerequisites:"
echo "1. Create an App Store Connect API Key:"
echo "   - Go to https://appstoreconnect.apple.com/access/api"
echo "   - Create a new API Key with 'Developer' role"
echo "   - Download the .p8 file"
echo ""
echo "2. Note down:"
echo "   - Key ID (starts with something like 'ABC123DEF4')"
echo "   - Issuer ID (UUID format)"
echo ""

read -p "Do you have your App Store Connect API Key ready? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please create your API key first, then run this script again."
    exit 1
fi

# Create fastlane directory if it doesn't exist
mkdir -p fastlane

# Create Appfile for fastlane
read -p "Enter your Apple Developer Team ID (from developer.apple.com): " team_id
read -p "Enter your App Store Connect Issuer ID: " issuer_id
read -p "Enter your App Store Connect Key ID: " key_id
read -p "Enter the path to your .p8 private key file: " key_file

# Validate inputs
if [[ -z "$team_id" || -z "$issuer_id" || -z "$key_id" || -z "$key_file" ]]; then
    echo "❌ Error: All fields are required"
    exit 1
fi

if [[ ! -f "$key_file" ]]; then
    echo "❌ Error: Private key file not found at $key_file"
    exit 1
fi

# Create Appfile
cat > fastlane/Appfile << EOF
app_identifier([
  "com.DanielStevens.PlannerApp",  # Adjust for each project
  "com.DanielStevens.AvoidObstaclesGame",
  "com.DanielStevens.MomentumFinance",
  "com.DanielStevens.HabitQuest"
])
apple_id("your-apple-id@example.com")  # Replace with your Apple ID
team_id("$team_id")
itc_team_id("$team_id")  # Same as team_id for individual developers
EOF

# Create API key configuration
cat > fastlane/api_key.json << EOF
{
  "key_id": "$key_id",
  "issuer_id": "$issuer_id",
  "key": "$(cat "$key_file" | sed 's/-----BEGIN PRIVATE KEY-----//' | sed 's/-----END PRIVATE KEY-----//' | tr -d '\n')",
  "duration": 1200,
  "in_house": false
}
EOF

echo ""
echo "✅ App Store Connect API Key configured successfully!"
echo ""
echo "📁 Files created:"
echo "   - fastlane/Appfile (App identifiers and team configuration)"
echo "   - fastlane/api_key.json (API key for automated deployment)"
echo ""
echo "🔒 Security Note:"
echo "   - The api_key.json file contains sensitive information"
echo "   - Add it to .gitignore if not already present"
echo "   - For CI/CD, store the key content as a GitHub secret"
echo ""
echo "🚀 Next steps:"
echo "   1. Test the configuration: fastlane test"
echo "   2. For CI/CD, set up GitHub Actions workflow"
echo "   3. Store API key securely in CI environment"
