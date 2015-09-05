//
//  CFTSimplePuzzle.m
//  PuzzleBuilder
//
//  Created by Collin Thommasen on 2015-08-29.
//  Copyright (c) 2015 Collin Thommasen. All rights reserved.
//

#import "CFTSimplePuzzle.h"

#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface CFTSimplePuzzle()

// Property that contains the number of pieces the puzzle will be divided into
@property int numberOfPieces;

// Property that contains the path to the image that will be used for the puzzle
@property (nonatomic, strong) NSString *imagePath;
@end

@implementation CFTSimplePuzzle

- (void) dealloc
{
    [self.imagePath dealloc];
    
    [super dealloc];
}

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
                 forImagePath: (NSString *) imgPath
{
    self = [super init];
    
    if (self) {
        // Initialize
        self.numberOfPieces = numOfPieces;
        self.imagePath = imgPath;
    }
    
    return self;
}

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
- (BOOL) generatePuzzleWithName: (NSString *) puzzleName
{
    BOOL successful = true;
    
    //Get the image size
    //CGSize imgSize = [CFTSimplePuzzle getImageSizeFromPath: self.imagePath];
    UIImage *img = [CFTSimplePuzzle fixrotation: [UIImage imageNamed: self.imagePath]];
    CGSize imgSize = img.size;
    
    //Calculate the number of pieces
    int piecesInARow = [CFTSimplePuzzle calculateColumnsInARowFromNumberOfPieces: self.numberOfPieces];
    
    //Get the size of each piece, the puzzle will have an equal amount of pieces in a row and column
    CGSize pieceSize = [CFTSimplePuzzle calculatePiecesSizeForNumberOfColumns: piecesInARow
                                                                 numberOfRows: piecesInARow
                                                                   puzzleSize: imgSize];
    
    //Create the directory to save the puzzle pieces in
    NSString *puzzleDir = [NSHomeDirectory() stringByAppendingPathComponent: @"Puzzles"];
    
    //Append the puzzle name to the puzzle directory
    puzzleDir = [puzzleDir stringByAppendingPathComponent: puzzleName];
    
    BOOL isDirectory;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath: puzzleDir isDirectory: &isDirectory] || !isDirectory) {
        //Directory doesn't exist so we need to create it
        NSError *error;
        NSDictionary *attr = [NSDictionary dictionaryWithObject: NSFileProtectionComplete
                                                         forKey: NSFileProtectionKey];
        if (![manager createDirectoryAtPath: puzzleDir
                withIntermediateDirectories: YES
                                 attributes: attr
                                      error: &error]) {
            NSLog(@"There was an error creating the directory for the puzzle: %@", error);
            
            successful = NO;
        }
        
        if (error != NULL)
            [error dealloc];
        
        [attr dealloc];
    } else {
        //Directory already exists so we need to delete anything in it
        NSError *error;
        
        for (NSString *str in [manager contentsOfDirectoryAtPath: puzzleDir
                                                           error: &error]) {
            BOOL success = [manager removeItemAtPath: [puzzleDir stringByAppendingPathComponent: str]
                                               error: &error];
            if (!success) {
                NSLog(@"There was an error removing the file at %@: %@", str, error);
                [error dealloc];
                successful = NO;
            }
        }
    }
    
    //Now we need to go though the image and break it down into smaller images and write them into the folder
    //UIImage *img = [self fixrotation: [UIImage imageNamed: self.imagePath]];
    for (int i = 0; i < piecesInARow; i++) {
        for (int j = 0; j < piecesInARow; j++) {
            CGRect rect = CGRectMake(i * pieceSize.width, j * pieceSize.height,
                                     pieceSize.width, pieceSize.height);
            
            CGImageRef drawImage = CGImageCreateWithImageInRect(img.CGImage, rect);
            NSString *path = [puzzleDir stringByAppendingPathComponent:
                              [NSString stringWithFormat: @"%d-%d.png", i, j]];
            CFURLRef url = (__bridge CFURLRef) [NSURL fileURLWithPath: path];
            if (!url) {
                NSLog(@"Failed to create the destination url.");
                return NO;
            }
            CGImageDestinationRef destination = CGImageDestinationCreateWithURL(url, kUTTypePNG, 1, NULL);
            
            CGImageDestinationAddImage(destination, drawImage, nil);
            
            if (!CGImageDestinationFinalize(destination)) {
                NSLog(@"Failed to write the image to %@", path);
                CFRelease(destination);
                return NO;
            }
            
            CFRelease(destination);
            CFRelease(drawImage);
        }
    }
    
    return successful;
}

/**
 * Function will fix the given UIImage so it is rotated properly.
 * @author Collin Thommasen
 * @date September 5, 2015
 *
 * @param image - the image to be fixed
 * @return returns an UIImage that has been rotated properly according to it's orientation.
 */
+ (UIImage *)fixrotation:(UIImage *)image{
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

/**
 * Gets the size of the image at the given path.
 * @author Collin Thommasen
 * @date August 29, 2015
 *
 * @param path - the path to the image
 * @return the size of the image at the given path, width and height will be -1 if there is an error
 */
+ (CGSize) getImageSizeFromPath: (NSString *) path
{
    CFURLRef url = CFURLCreateFromFileSystemRepresentation (kCFAllocatorDefault, (const UInt8 *)[path UTF8String],
                                                            strlen([path UTF8String]), false);
    
    if (!url) {
        printf ("* * Bad input file path\n");
        return CGSizeMake(-1, -1);
    }
    
    CGImageSourceRef myImageSource;
    
    myImageSource = CGImageSourceCreateWithURL(url, NULL);
    
    CFDictionaryRef imagePropertiesDictionary;
    
    imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSource,0, NULL);
    
    CFNumberRef imageWidth = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyPixelWidth);
    CFNumberRef imageHeight = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyPixelHeight);
    
    int w = 0;
    int h = 0;
    
    CFNumberGetValue(imageWidth, kCFNumberIntType, &w);
    CFNumberGetValue(imageHeight, kCFNumberIntType, &h);
    
    CFRelease(imagePropertiesDictionary);
    CFRelease(myImageSource);
    
    return CGSizeMake(w, h);
}

/**
 * Calculates the number of pieces in a row of the puzzle.  The puzzle will have an equal amount of rows and columns.
 * @author Collin Thommasen
 * @date September 5, 2015
 *
 * @param numPieces - the number of total pieces in a puzzle
 * @return returns the number of pieces in a row (number of columns)
 */
+ (int) calculateColumnsInARowFromNumberOfPieces: (int) numPieces
{
    //For now we will just take the square root of the numPieces
    return (int) sqrtf((float) numPieces);
}

+ (CGSize) calculatePiecesSizeForNumberOfColumns: (int) numColumns
                                    numberOfRows: (int) numRows
                                      puzzleSize: (CGSize) puzzleSize
{
    CGFloat w; //The width
    CGFloat h; //The height
    
    //Calculate the width and height
    w = puzzleSize.width / (float) numColumns;
    h = puzzleSize.height / (float) numRows;
    
    return CGSizeMake(w, h);
}
@end
