//
//  AppDelegate.m
//  Asset Manager
//
//  Created by Nikki Durkin on 10/31/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "MainViewController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet MasterViewController *masterViewController;
//@property (strong, nonatomic) IBOutlet MainViewController *mainViewController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    self.masterViewController = [[MasterViewController alloc] initWithNibName:@"MasterViewController" bundle:nil];
    [self.window.contentView addSubview:self.masterViewController.view];
    self.masterViewController.view.frame = ((NSView *)self.window.contentView).bounds;
    
//    self.mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
//    [self.window.contentView addSubview:self.mainViewController.view];
//    self.mainViewController.view.frame = ((NSView *)self.window.contentView).bounds;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
