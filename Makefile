.PHONY: project build clean fetch-xcframework

# Fetch latest xcframework from GitHub Actions
fetch-xcframework:
	bash Scripts/fetch-xcframework.sh

# Generate Xcode project from project.yml (requires xcodegen)
project:
	xcodegen generate

# Build the iOS app (requires Xcode + xcframework)
build:
	xcodebuild -project ProbeTool.xcodeproj -scheme ProbeTool -sdk iphoneos -configuration Release archive -archivePath build/ProbeTool.xcarchive CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO

# Full pipeline: fetch framework, generate project, build
all: fetch-xcframework project build

# Clean build artifacts
clean:
	rm -rf build/
	rm -rf ProbeTool.xcodeproj
