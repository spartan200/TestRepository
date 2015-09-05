//
//  PuzzleBuilderTests.m
//  PuzzleBuilderTests
//
//  Created by Collin Thommasen on 2015-08-29.
//  Copyright (c) 2015 Collin Thommasen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "CFTSimplePuzzle.h"

@interface PuzzleBuilderTests : XCTestCase

@end

@implementation PuzzleBuilderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NSBundle *bundle = [NSBundle bundleForClass: [self class]];
    NSString *filePath = [bundle pathForResource: @"PowerShanty"
                                          ofType: @"jpg"];
    CFTSimplePuzzle *simplePuzzle = [[CFTSimplePuzzle alloc] initWithNumberOfPieces: 16
                                                                       forImagePath: filePath];
    XCTAssert([simplePuzzle generatePuzzleWithName: @"Puzzle"], @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
