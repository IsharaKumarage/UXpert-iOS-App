//
//  UXpertTests.swift
//  UXpertTests
//
//  Created by STUDENT on 2025-11-09.
//

import XCTest
import CoreData
@testable import UXpert

/// Unit tests for UXpert app functionality
final class UXpertTests: XCTestCase {
    
    var persistenceManager: PersistenceManager!
    var mlModelManager: MLModelManager!
    
    override func setUpWithError() throws {
        // Set up test environment
        persistenceManager = PersistenceManager.shared
        mlModelManager = MLModelManager.shared
    }
    
    override func tearDownWithError() throws {
        // Clean up test environment
        persistenceManager = nil
        mlModelManager = nil
    }
    
    // MARK: - Core Data Tests
    
    /// Test saving and fetching upload records
    func testSaveAndFetchUploadRecord() throws {
        // Create test feedback items
        let feedbackItems = [
            FeedbackItem(
                category: .colorHarmony,
                score: 0.85,
                suggestion: "Test suggestion for color harmony",
                icon: "paintpalette.fill"
            ),
            FeedbackItem(
                category: .layoutBalance,
                score: 0.72,
                suggestion: "Test suggestion for layout balance",
                icon: "rectangle.3.group.fill"
            )
        ]
        
        // Create test upload record
        let uploadRecord = UploadRecord(
            overallScore: 0.785,
            feedbackItems: feedbackItems
        )
        
        // Save the record
        persistenceManager.saveUploadRecord(uploadRecord)
        
        // Fetch all records
        let fetchedRecords = persistenceManager.fetchUploadRecords()
        
        // Verify the record was saved
        XCTAssertFalse(fetchedRecords.isEmpty, "Should have at least one saved record")
        
        let savedRecord = fetchedRecords.first { $0.id == uploadRecord.id }
        XCTAssertNotNil(savedRecord, "Should find the saved record")
        
        if let savedRecord = savedRecord {
            XCTAssertEqual(savedRecord.overallScore, uploadRecord.overallScore, accuracy: 0.001)
            XCTAssertEqual(savedRecord.feedbackItems.count, uploadRecord.feedbackItems.count)
            
            // Verify feedback items
            for originalItem in uploadRecord.feedbackItems {
                let savedItem = savedRecord.feedbackItems.first { $0.category == originalItem.category }
                XCTAssertNotNil(savedItem, "Should find saved feedback item for category \(originalItem.category)")
                
                if let savedItem = savedItem {
                    XCTAssertEqual(savedItem.score, originalItem.score, accuracy: 0.001)
                    XCTAssertEqual(savedItem.suggestion, originalItem.suggestion)
                    XCTAssertEqual(savedItem.icon, originalItem.icon)
                }
            }
        }
    }
    
    /// Test deleting upload records
    func testDeleteUploadRecord() throws {
        // Create and save a test record
        let feedbackItems = [
            FeedbackItem(
                category: .contrastAccessibility,
                score: 0.65,
                suggestion: "Test suggestion",
                icon: "eye.fill"
            )
        ]
        
        let uploadRecord = UploadRecord(
            overallScore: 0.65,
            feedbackItems: feedbackItems
        )
        
        persistenceManager.saveUploadRecord(uploadRecord)
        
        // Verify it was saved
        var fetchedRecords = persistenceManager.fetchUploadRecords()
        let initialCount = fetchedRecords.count
        XCTAssertTrue(fetchedRecords.contains { $0.id == uploadRecord.id })
        
        // Delete the record
        persistenceManager.deleteUploadRecord(uploadRecord)
        
        // Verify it was deleted
        fetchedRecords = persistenceManager.fetchUploadRecords()
        XCTAssertEqual(fetchedRecords.count, initialCount - 1)
        XCTAssertFalse(fetchedRecords.contains { $0.id == uploadRecord.id })
    }
    
    // MARK: - ML Model Tests
    
    /// Test ML model manager initialization
    func testMLModelManagerInitialization() {
        XCTAssertNotNil(mlModelManager, "ML Model Manager should initialize successfully")
    }
    
    /// Test image analysis returns valid feedback
    func testImageAnalysisReturnsValidFeedback() async {
        // Create a test image
        let testImage = createTestUIImage()
        
        // Perform analysis
        let feedbackItems = await mlModelManager.analyzeUIDesign(testImage)
        
        // Verify results
        XCTAssertFalse(feedbackItems.isEmpty, "Should return feedback items")
        XCTAssertEqual(feedbackItems.count, FeedbackCategory.allCases.count, "Should return feedback for all categories")
        
        // Verify each feedback item
        for item in feedbackItems {
            XCTAssertTrue(item.score >= 0.0 && item.score <= 1.0, "Score should be between 0 and 1")
            XCTAssertFalse(item.suggestion.isEmpty, "Should have a suggestion")
            XCTAssertFalse(item.icon.isEmpty, "Should have an icon")
            XCTAssertTrue(FeedbackCategory.allCases.contains(item.category), "Should be a valid category")
        }
    }
    
    /// Test analysis with nil image
    func testAnalysisWithNilImage() async {
        // Create a 1x1 transparent image to simulate edge case
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let emptyImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let testImage = emptyImage else {
            XCTFail("Could not create test image")
            return
        }
        
        // Perform analysis
        let feedbackItems = await mlModelManager.analyzeUIDesign(testImage)
        
        // Should still return feedback (fallback behavior)
        XCTAssertFalse(feedbackItems.isEmpty, "Should return fallback feedback even for empty image")
    }
    
    // MARK: - Model Tests
    
    /// Test FeedbackItem model
    func testFeedbackItemModel() {
        let item = FeedbackItem(
            category: .typographySpacing,
            score: 0.75,
            suggestion: "Test suggestion",
            icon: "textformat.size"
        )
        
        XCTAssertEqual(item.scorePercentage, 75)
        XCTAssertEqual(item.category, .typographySpacing)
        XCTAssertEqual(item.score, 0.75)
        XCTAssertEqual(item.suggestion, "Test suggestion")
        XCTAssertEqual(item.icon, "textformat.size")
    }
    
    /// Test UploadRecord model
    func testUploadRecordModel() {
        let feedbackItems = [
            FeedbackItem(category: .colorHarmony, score: 0.8, suggestion: "Good", icon: "paintpalette.fill"),
            FeedbackItem(category: .layoutBalance, score: 0.6, suggestion: "Needs work", icon: "rectangle.3.group.fill")
        ]
        
        let record = UploadRecord(
            overallScore: 0.7,
            feedbackItems: feedbackItems
        )
        
        XCTAssertEqual(record.overallScorePercentage, 70)
        XCTAssertEqual(record.feedbackItems.count, 2)
        
        // Test strongest and weakest categories
        XCTAssertEqual(record.strongestCategory?.category, .colorHarmony)
        XCTAssertEqual(record.weakestCategory?.category, .layoutBalance)
    }
    
    /// Test FeedbackCategory enum
    func testFeedbackCategoryEnum() {
        // Test all categories have icons and colors
        for category in FeedbackCategory.allCases {
            XCTAssertFalse(category.iconName.isEmpty, "Category \(category) should have an icon")
            XCTAssertFalse(category.color.isEmpty, "Category \(category) should have a color")
        }
        
        // Test specific category properties
        XCTAssertEqual(FeedbackCategory.colorHarmony.iconName, "paintpalette.fill")
        XCTAssertEqual(FeedbackCategory.layoutBalance.iconName, "rectangle.3.group.fill")
        XCTAssertEqual(FeedbackCategory.contrastAccessibility.iconName, "eye.fill")
        XCTAssertEqual(FeedbackCategory.typographySpacing.iconName, "textformat.size")
        XCTAssertEqual(FeedbackCategory.visualHierarchy.iconName, "list.bullet.indent")
    }
    
    // MARK: - Performance Tests
    
    /// Test Core Data performance with multiple records
    func testCoreDataPerformance() {
        measure {
            // Create multiple test records
            for i in 0..<10 {
                let feedbackItems = FeedbackCategory.allCases.map { category in
                    FeedbackItem(
                        category: category,
                        score: Double.random(in: 0.4...0.9),
                        suggestion: "Test suggestion \(i)",
                        icon: category.iconName
                    )
                }
                
                let record = UploadRecord(
                    overallScore: Double.random(in: 0.5...0.9),
                    feedbackItems: feedbackItems
                )
                
                persistenceManager.saveUploadRecord(record)
            }
            
            // Fetch all records
            let _ = persistenceManager.fetchUploadRecords()
        }
    }
    
    /// Test ML analysis performance
    func testMLAnalysisPerformance() {
        let testImage = createTestUIImage()
        
        measure {
            Task {
                let _ = await mlModelManager.analyzeUIDesign(testImage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Create a test UI image for testing
    private func createTestUIImage() -> UIImage {
        let size = CGSize(width: 256, height: 256)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        // Draw a simple test pattern
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.systemBlue.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height/2))
        
        context?.setFillColor(UIColor.systemGreen.cgColor)
        context?.fill(CGRect(x: 0, y: size.height/2, width: size.width, height: size.height/2))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
}
