//
//  Stundentool_AppDelegate.h
//  Stundentool
//
//  Created by Michael Markowski on 03.04.09.
//  Copyright Artifacts 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CalendarStore/CalendarStore.h>

#define SEPARATOR_LINE @"--------------------------------------------------------------------------------\n"

@interface FiveToTwelve_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
	IBOutlet NSTextView *textView;
	IBOutlet NSDatePicker *fromDate;
	IBOutlet NSDatePicker *toDate;
	NSMutableArray *availableCalendars;
	NSMutableArray *selectedProjects;
	IBOutlet NSArrayController *availableCalendarsController;
	IBOutlet NSArrayController *selectedCalendarsController;
	IBOutlet NSArrayController *projectsController;
    IBOutlet NSArrayController *selectedProjectsController;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
}

@property (nonatomic, retain) NSTextView *textView;
@property (nonatomic, retain) NSDatePicker *fromDate;
@property (nonatomic, retain) NSDatePicker *toDate;
@property (nonatomic, retain) NSMutableArray *availableCalendars;
@property (nonatomic, retain) NSArrayController *availableCalendarsController;
@property (nonatomic, retain) NSArrayController *selectedCalendarsController;
@property (nonatomic, retain) NSArrayController *projectsController;
@property (nonatomic, retain) NSArrayController *selectedProjectsController;
@property (nonatomic, retain) NSMutableArray *selectedProjects;

- (IBAction)fetchEvents:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)addToSelected:(id)sender;
- (NSArray*)eventsForCalendar:(CalCalendar*)calendar year:(int)year month:(int)month day:(int)day;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;
- (IBAction)csvReport:(id)sender;

@end
