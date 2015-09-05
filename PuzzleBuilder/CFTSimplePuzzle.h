//
//  CFTSimplePuzzle.h
//  PuzzleBuilder
//
//  Created by Collin Thommasen on 2015-08-29.
//  Copyright (c) 2015 Collin Thommasen. All rights reserved.
//
// This class will create a simple puzzle that is just made up of rectangles.
#import <Foundation/Foundation.h>

@interface CFTSimplePuzzle : NSObject

#pragma mark -
#pragma mark Constructors
/**
 * Initializes the CFTSimplePuzzle class with the number of pieces to divide the given image into.
 * @author Collin Thommasen
 * @date August 29, 2015
 * 
 * @param numOfPieces - Number of pieces to split the image into
 * @param imagePath - NSString containing the path for the image is located.
 */
- (id) initWithNumberOfPieces: (int) numOfPieces
                 forImagePath: (NSString *) imgPath;

#pragma mark -
#pragma mark Functions

/**
 * Generates the puzzle to a folder with the given name.
 * @author Collin Thommasen
 * @date August 29, 2015
 *
 * @param puzzleName - The name of the puzzle.
 * @return True if there is no errors.  If there are errors it returns False.
 */
- (BOOL) generatePuzzleWithName: (NSString *) puzzleName;
@end
