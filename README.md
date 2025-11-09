# UXpert - UI/UX Design Feedback App

UXpert is an iOS app that provides automatic design critique of UI screenshots using Core ML and FastViT image classification. Get instant feedback on color harmony, layout balance, contrast & accessibility, typography & spacing, and visual hierarchy.

## Features

- **Home Screen**: View past uploads with overall scores and dates
- **Upload Screen**: Pick or drag screenshot images, preview, then tap "Analyse"
- **Result Screen**: Shows overall score badge and 3-5 detailed feedback cards
- **History Detail Screen**: View past uploads with full details and suggestions
- **Dashboard Screen**: SwiftUI Charts showing performance over time and frequent issues

## Architecture

- **MVVM Pattern**: Clean separation of concerns with ViewModels managing business logic
- **Core Data**: Local persistence for upload records and feedback items
- **Core ML Integration**: FastViT model for image classification and analysis
- **SwiftUI**: Modern declarative UI framework with custom components

## Project Structure

```
UXpert/
├── Models/
│   ├── FeedbackItem.swift          # Feedback data model
│   └── UploadRecord.swift          # Upload record data model
├── ViewModels/
│   ├── HomeViewModel.swift         # Home screen business logic
│   ├── UploadViewModel.swift       # Upload and analysis logic
│   └── DashboardViewModel.swift    # Analytics and dashboard logic
├── Views/
│   ├── Components/
│   │   └── FeedbackCard.swift      # Custom feedback card component
│   ├── HomeView.swift              # Home screen UI
│   ├── UploadView.swift            # Upload screen UI
│   ├── ResultView.swift            # Analysis results UI
│   ├── HistoryView.swift           # History list UI
│   ├── HistoryDetailView.swift     # Detailed history view
│   └── DashboardView.swift         # Analytics dashboard UI
├── Helpers/
│   ├── PersistenceManager.swift    # Core Data management
│   └── MLModelManager.swift        # ML model integration
└── Assets/
    └── AccentColor.colorset        # App color scheme
```

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- FastViT.mlmodel (Core ML model)

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd UXpert
   ```

2. **Add FastViT Model**
   - Download the FastViT.mlmodel file
   - Drag and drop it into the Xcode project
   - Ensure it's added to the app target

3. **Install Dependencies**
   - The project uses only system frameworks (no external dependencies)
   - SwiftUI Charts is available in iOS 16+

4. **Build and Run**
   - Open `UXpert.xcodeproj` in Xcode
   - Select your target device (iOS 16+ required)
   - Build and run the project

## Core ML Integration

### Image Preprocessing
The app preprocesses images for FastViT model input:
```swift
// Resize image to 256x256 as required by FastViT
private func preprocessImage(_ image: UIImage) -> UIImage? {
    let targetSize = CGSize(width: 256, height: 256)
    // ... scaling logic
}
```

### Model Invocation
```swift
// Perform ML analysis using FastViT model
private func performMLAnalysis(_ image: UIImage, with model: VNCoreMLModel) async -> [FeedbackItem] {
    // Create Vision request for Core ML model
    let request = VNCoreMLRequest(model: model) { request, error in
        // Process results and map to feedback categories
    }
    // ... analysis logic
}
```

### Mapping Logic
The app maps FastViT classification results to UI/UX feedback categories:
```swift
// Map classification labels to design categories based on visual features
if result.identifier.contains("color") || result.identifier.contains("palette") {
    categoryScores[.colorHarmony] = max(categoryScores[.colorHarmony] ?? 0, confidence)
} else if result.identifier.contains("layout") || result.identifier.contains("grid") {
    categoryScores[.layoutBalance] = max(categoryScores[.layoutBalance] ?? 0, confidence)
}
// ... additional mapping logic
```

## UI/UX Design

### Color Scheme
- **Light Mode**: White background with accent teal (#1EB5E0)
- **Dark Mode**: Dark background (#121212) with accent teal
- **Accessibility**: Contrast ratio >4.5:1 compliance

### Custom Components
- **FeedbackCard**: Expandable cards with category info, scores, and suggestions
- **AnimatedScoreCircle**: Animated circular progress indicator for overall scores
- **ScoreBadge**: Color-coded score indicators

### Animations
- **Score Badge Scaling**: Animated when analysis completes
- **Color Scheme Transitions**: Smooth animations when switching between light/dark mode
- **Card Interactions**: Smooth expand/collapse animations

## Accessibility Features

- **Dynamic Type**: Supports all text size categories
- **VoiceOver**: Comprehensive screen reader support
- **High Contrast**: Ensures 4.5:1 contrast ratio minimum
- **Semantic Labels**: Descriptive accessibility labels for all interactive elements

## Core Data Schema

### Entities

**UploadRecordEntity**
- `id`: UUID (Primary Key)
- `date`: Date
- `imageData`: Binary Data (External storage enabled)
- `overallScore`: Double
- `feedbackItems`: Relationship to FeedbackItemEntity

**FeedbackItemEntity**
- `id`: UUID (Primary Key)
- `category`: String
- `score`: Double
- `suggestion`: String
- `icon`: String
- `uploadRecord`: Relationship to UploadRecordEntity

## Testing

### Unit Tests
Run the test suite to verify functionality:
```bash
# In Xcode
Cmd+U to run all tests
```

**Test Coverage:**
- Core Data saving/fetching operations
- ML model manager initialization and analysis
- Model object validation and computed properties
- Performance testing for database operations

### Test Categories
- **Core Data Tests**: Verify persistence operations
- **ML Model Tests**: Validate analysis pipeline
- **Model Tests**: Test data model integrity
- **Performance Tests**: Measure operation efficiency

## Usage

1. **Upload Design**: Tap the Upload tab and select a UI screenshot
2. **View Analysis**: Review the detailed feedback and overall score
3. **Track Progress**: Use the Dashboard to monitor improvement over time
4. **Review History**: Access past analyses and compare results

## Feedback Categories

- **Color Harmony**: Palette cohesion and color relationships
- **Layout Balance**: Visual weight distribution and grid alignment
- **Contrast & Accessibility**: Text readability and WCAG compliance
- **Typography & Spacing**: Font choices, sizes, and spacing consistency
- **Visual Hierarchy**: Information prioritization and user flow

## Performance Considerations

- **Image Storage**: Binary data with external storage for large images
- **Lazy Loading**: Efficient list rendering with LazyVStack
- **Background Processing**: ML analysis performed asynchronously
- **Memory Management**: Proper cleanup of Core Data contexts

## Future Enhancements

- **Cloud Sync**: iCloud integration for cross-device synchronization
- **Export Options**: PDF reports and detailed analysis exports
- **Team Features**: Shared workspaces and collaborative feedback
- **Advanced Analytics**: More detailed performance metrics and trends
- **Custom Models**: Support for specialized design analysis models

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For questions or issues, please open an issue on the GitHub repository or contact the development team.
