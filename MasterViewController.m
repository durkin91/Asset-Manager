//
//  MasterViewController.m
//  Asset Manager
//
//  Created by Nikki Durkin on 10/31/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import "MasterViewController.h"

#define PAINTCODE_COLORS @"Paintcode Colors"
#define AVACHAT_COLORS @"Avachat Colors"

@interface MasterViewController ()
@property (weak) IBOutlet NSTextField *paintcodeColorTextField1;
@property (weak) IBOutlet NSTextField *avachatColorTextField1;
@property (weak) IBOutlet NSTextField *paintcodeColorTextField2;
@property (weak) IBOutlet NSTextField *avachatColorTextField2;
@property (weak) IBOutlet NSTextField *paintcodeColorTextField3;
@property (weak) IBOutlet NSTextField *avachatColorTextField3;
@property (weak) IBOutlet NSTextField *paintcodePaths;
@property (weak) IBOutlet NSTextField *avachatPaths;

- (IBAction)selectAllPaintcodePathsTextButton:(id)sender;
- (IBAction)selectAllTextButton:(id)sender;
- (IBAction)convertPathsButton:(NSButton *)sender;
@end

@implementation MasterViewController

-(void)loadView
{
    [super loadView];
//    NSArray *paintcodeColors = [[NSUserDefaults standardUserDefaults] objectForKey:PAINTCODE_COLORS];
//    [self.paintcodeColorTextField1 setStringValue:paintcodeColors[0]];
//    [self.paintcodeColorTextField2 setStringValue:paintcodeColors[1]];
//    [self.paintcodeColorTextField3 setStringValue:paintcodeColors[2]];
//    
//    NSArray *avachatColors = [[NSUserDefaults standardUserDefaults] objectForKey:AVACHAT_COLORS];
//    [self.avachatColorTextField1 setStringValue:avachatColors[0]];
//    [self.avachatColorTextField2 setStringValue:avachatColors[1]];
//    [self.avachatColorTextField3 setStringValue:avachatColors[2]];
}

- (IBAction)selectAllPaintcodePathsTextButton:(id)sender
{
        [self.paintcodePaths selectText:sender];
}

- (IBAction)selectAllTextButton:(id)sender
{
    [self.avachatPaths selectText:sender];
    
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString: [self.avachatPaths stringValue] forType:NSStringPboardType];
}

- (IBAction)convertPathsButton:(NSButton *)sender
{
    
    //Put color conversions into a dictionary and remove empty text fields
    NSMutableArray *paintcodeColorsUnstripped = [@[[self.paintcodeColorTextField1 stringValue], [self.paintcodeColorTextField2 stringValue], [self.paintcodeColorTextField3 stringValue]] mutableCopy];
    NSMutableArray *paintcodeColors = [self removeEmptyStringsFromArray:paintcodeColorsUnstripped];
    NSLog(@"Paintcode Colors from textfields: %@", paintcodeColors);
    
    NSMutableArray *avachatColorsUnstripped = [@[[self.avachatColorTextField1 stringValue], [self.avachatColorTextField2 stringValue], [self.avachatColorTextField3 stringValue]] mutableCopy];
    NSMutableArray *avachatColors = [self removeEmptyStringsFromArray:avachatColorsUnstripped];
    NSLog(@"Avachat Colors from textfields: %@", avachatColors);
    
    //Create an array of colors and an array of bezier paths
    NSMutableString *paintcodePaths = [[self.paintcodePaths stringValue] mutableCopy];
    NSMutableArray *paintcodePathsBrokenIntoLines = [[paintcodePaths componentsSeparatedByString:@"\n"] mutableCopy];
    
    NSArray *colors = [self extractPathsOrColorsFromString:paintcodePathsBrokenIntoLines searchCriteriaToMakePredicate:@"*[* setFill];" filteringString:@" setFill];"];
    NSArray *bezierPaths = [self extractPathsOrColorsFromString:paintcodePathsBrokenIntoLines searchCriteriaToMakePredicate:@"*[* fill];" filteringString:@" fill];"];
    
    NSLog(@"Colors: %@ and Paths: %@", colors, bezierPaths);
    
    
    //replace occurances of the paintcode colors with the avachat colors
    NSMutableArray *newColors = [@[] mutableCopy];
    for (NSString *color in colors) {
        NSString *newColor;
        BOOL colorFound = NO;
        for (NSString *paintcodeColor in paintcodeColors) {
            if ([color isEqualToString:paintcodeColor]) {
                NSInteger index = [paintcodeColors indexOfObject:paintcodeColor];
                newColor = [avachatColors objectAtIndex:index];
                [newColors addObject:newColor];
                colorFound = YES;
            }
        }
        if (!colorFound) {
            NSLog(@"The color %@ in the paintcode paths did not match any colors in the text fields. Please check and try again", color);
        }
    }
    NSLog(@"%@", newColors);
    
    //Construct the string that will be used to replace all occurences of setFill and fill
    int pathIndex = 0;
    NSMutableArray *transformedStrings = [@[] mutableCopy];
    for (NSString *line in paintcodePathsBrokenIntoLines) {
        NSString *newLine;
        if ([line rangeOfString:@"setFill];"].location != NSNotFound) {
            newLine = [NSString stringWithFormat:@"[paths addObject:[self addColor:%@ andPath:%@]];", [newColors objectAtIndex:pathIndex], [bezierPaths objectAtIndex:pathIndex]];
            [transformedStrings addObject:newLine];
            pathIndex ++;
        }
        //we don't want to add the 'fill' lines, but we want to add everything else
        else if ([line rangeOfString:@"fill];"].location == NSNotFound) {
            newLine = line;
            [transformedStrings addObject:newLine];
        }
    }
    
    //output the final transformed string
    NSString *finalTransformation = [transformedStrings componentsJoinedByString:@"\n"];
    [self.avachatPaths setStringValue:finalTransformation];
    
    //save colors in text fields to NSUserdefaults
//    [[NSUserDefaults standardUserDefaults] setObject:paintcodeColors forKey:PAINTCODE_COLORS];
//    [[NSUserDefaults standardUserDefaults] setObject:avachatColors forKey:AVACHAT_COLORS];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}




- (NSMutableArray *)extractPathsOrColorsFromString:(NSMutableArray *)paintcodePathsBrokenIntoLines searchCriteriaToMakePredicate:(NSString *)searchCriteria filteringString:(NSString *)filteringString
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@", searchCriteria];
    NSArray *results = [paintcodePathsBrokenIntoLines filteredArrayUsingPredicate:predicate];
    
    NSMutableArray *finalResults = [@[] mutableCopy];
    for (NSString *string in results) {
        NSString *finalResult = [string stringByReplacingOccurrencesOfString:@"[" withString:@""];
        finalResult = [finalResult stringByReplacingOccurrencesOfString:filteringString withString:@""];
        finalResult = [finalResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [finalResults addObject:finalResult];
    }
    return finalResults;
}

- (NSMutableArray *)removeEmptyStringsFromArray:(NSMutableArray *)array
{
    for (NSString *string in array) {
        if ([string isEqualToString:@""]) {
            [array removeObject:string];
        }
    }
    
    return array;
    
}
@end
