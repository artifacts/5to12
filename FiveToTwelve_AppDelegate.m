//
//  Stundentool_AppDelegate.m
//  Stundentool
//
//  Created by Michael Markowski on 03.04.09.
//  Copyright Artifacts 2009 . All rights reserved.
//

#import "FiveToTwelve_AppDelegate.h"

@implementation FiveToTwelve_AppDelegate

@synthesize textView;
@synthesize fromDate;
@synthesize toDate;
@synthesize availableCalendars;
@synthesize selectedProjects;
@synthesize availableCalendarsController;
@synthesize selectedCalendarsController;
@synthesize projectsController;
@synthesize selectedProjectsController;

- (void)applicationDidFinishLaunching: (NSNotification*)notification
{
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	NSCalendarDate *from = [[NSCalendarDate dateWithYear:[now yearOfCommonEra] 
												   month:[now monthOfYear] day:1 hour:0 minute:0 second:0 timeZone:nil] retain];
	NSCalendarDate *to = [from dateByAddingYears:0 months:1 days:0 hours:0 minutes:0 seconds:0];
	to = [to dateByAddingYears:0 months:0 days:-1 hours:0 minutes:0 seconds:0];
	
	[fromDate setDateValue: from];
	[toDate setDateValue: to];
	self.availableCalendars = [NSMutableArray arrayWithArray: [[CalCalendarStore defaultCalendarStore] calendars]];
	for (CalCalendar *calendar in availableCalendars)
	{
		
	}
	self.selectedProjects =  [[NSMutableArray alloc] init];
}

- (IBAction)addToSelected:(id)sender
{
	for (id item in [projectsController selectedObjects])
	{
		if (![selectedProjects containsObject:item])
		{
			[selectedProjects addObject:item];
//			NSArray *arr = [selectedProjectsController arrangedObjects];
//			NSLog(@"%@",arr);
		}
	}
}

- (IBAction)fetchEvents:(id)sender
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	
	// Create a predicate to fetch all events for this year
	int year = [[[fromDate dateValue] dateWithCalendarFormat:nil timeZone:nil] yearOfCommonEra];
	int month = [[[fromDate dateValue] dateWithCalendarFormat:nil timeZone:nil] monthOfYear];
	int day;
	NSTimeInterval intervalTotal = 0;
	NSTimeInterval intervalForProject = 0;
	NSString *projectSummary = [NSString stringWithFormat:@"Zusammenfassung:\n%@", SEPARATOR_LINE];
	
	for (id project in [projectsController arrangedObjects])
	{
		intervalForProject = 0;
		NSString *projectName = [project valueForKey:@"name"];
		NSString *uid = [project valueForKey:@"calendarUID"];
		[textView insertText: [NSString stringWithFormat:@"%@\n%@", projectName, SEPARATOR_LINE]];		
		NSRange daysRange = [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:[fromDate dateValue]];
		
//		- (NSRange)rangeOfUnit:(NSCalendarUnit)smaller inUnit:(NSCalendarUnit)larger forDate:(NSDate *)date
		

		for (day=daysRange.location; day<=daysRange.length; day++) {
			NSCalendarDate * startDate = [[NSCalendarDate dateWithYear:year 
																 month:month day:day hour:0 minute:0 second:0 timeZone:nil] retain];	
			//for (CalCalendar *calendar in selectedCalendars)
			//{
			CalCalendar *calendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:uid];
				NSArray *events = [self eventsForCalendar:calendar year:year month:month day:day];
				if ([events count]>0)
				{					
					[textView insertText: [dateFormatter stringFromDate:startDate]];
					[textView insertText: @"\n"];
					NSString *time = @"";
					//NSString *name = [NSString stringWithFormat:@"%@", calendar.title];				
					NSTimeInterval interval = 0;
					NSString *description = @"";				
					for (CalEvent *event in events) {
						interval += [[event endDate] timeIntervalSinceDate: [event startDate]];				
						NSString *title = [event.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
						if ([title length] > 0)
						{
							description = [description stringByAppendingString:title];
							if (event != [events lastObject]) 
							{ 
								description = [description stringByAppendingString:@", "];
							}
						}
					}
					NSDate *period;
					if (interval > 0) {			
						time = [time stringByAppendingString:[NSString stringWithFormat:@"%1.2f Stunden", interval/3600]];		
						period = [NSDate dateWithTimeIntervalSinceNow: interval];
						intervalTotal += interval;
						intervalForProject += interval;
					}
					[textView insertText: [NSString stringWithFormat: @"%@\n%@\n", description, time]];
				}
			//}		 
		}		
		if (intervalForProject>0)
		{
			[textView insertText: [NSString stringWithFormat:@"Stunden (Projekt): %1.2f \n\n", intervalForProject/3600]];
			projectSummary = [projectSummary stringByAppendingString:[NSString stringWithFormat:@"%@: %1.2f \n", projectName, intervalForProject/3600]];
		}
	}
	
	[textView insertText: projectSummary];			
	[textView insertText: [NSString stringWithFormat:SEPARATOR_LINE]];			
	[textView insertText: [NSString stringWithFormat:@"Stunden gesamt (alle Projekte): %1.2f \n", intervalTotal/3600]];		
	[textView insertText: [NSString stringWithFormat:@"Tage gesamt: %1.2f \n", intervalTotal/3600/8]];		
	
}

-(IBAction)csvReport:(id)sender
{	
	/*
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init]  autorelease];
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	
	NSCalendar *cal = [NSCalendar currentCalendar];
	unsigned int unitFlags = NSDayCalendarUnit;

	NSDateComponents *components = [cal components:unitFlags fromDate:[fromDate dateValue] toDate:[toDate dateValue] options:0];
	// Anzal der Tage zwischen den beiden Daten
	int days = [components day];
	
	NSTimeInterval intervalTotal = 0;
	NSTimeInterval intervalForProject = 0;
	NSString *projectSummary = [NSString stringWithFormat:@"Zusammenfassung:\n%@", SEPARATOR_LINE];
	
	for (id project in [projectsController arrangedObjects])
	{
		intervalForProject = 0;
		NSString *projectName = [project valueForKey:@"name"];
		NSString *uid = [project valueForKey:@"calendarUID"];
		[textView insertText: [NSString stringWithFormat:@"%@\n%@", projectName, SEPARATOR_LINE]];		
		
		NSDate *currentDate = [fromDate dateValue];
		for (int day=1; day<=days; day++)
		{
			unsigned int unitFlags = NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
			NSDateComponents *currentComponents = [cal components:unitFlags fromDate:currentDate];
			
			CalCalendar *calendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:uid];
			int y = [currentComponents year];
			int m = [currentComponents month];
			int d = [currentComponents day];
			
			NSArray *events = [self eventsForCalendar:calendar year:y month:m day:d];
			if ([events count]>0)
			{					
				[textView insertText: [dateFormatter stringFromDate:currentDate]];
				[textView insertText: @"\n"];
				NSString *time = @"";
				//NSString *name = [NSString stringWithFormat:@"%@", calendar.title];				
				NSTimeInterval interval = 0;
				NSString *description = @"";				
				for (CalEvent *event in events) {
					interval += [[event endDate] timeIntervalSinceDate: [event startDate]];				
					NSString *title = [event.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
					if ([title length] > 0)
					{
						description = [description stringByAppendingString:title];
						if (event != [events lastObject]) 
						{ 
							description = [description stringByAppendingString:@", "];
						}
					}
				}
				NSDate *period;
				if (interval > 0) {			
					time = [time stringByAppendingString:[NSString stringWithFormat:@"%1.2f Stunden", interval/3600]];		
					period = [NSDate dateWithTimeIntervalSinceNow: interval];
					intervalTotal += interval;
					intervalForProject += interval;
				}
				[textView insertText: [NSString stringWithFormat: @"%@\n%@\n", description, time]];
			}
			NSDateComponents *comps = [[NSDateComponents alloc] init];
			[comps setDay:day];
			currentDate = [cal dateByAddingComponents:comps toDate:[fromDate dateValue] options:0];
			[comps release];			
		}
		if (intervalForProject>0)
		{
			[textView insertText: [NSString stringWithFormat:@"Stunden (Projekt): %1.2f \n\n", intervalForProject/3600]];
			projectSummary = [projectSummary stringByAppendingString:[NSString stringWithFormat:@"%@: %1.2f \n", projectName, intervalForProject/3600]];
		}			
	}
	[textView insertText: projectSummary];			
	[textView insertText: [NSString stringWithFormat:SEPARATOR_LINE]];			
	[textView insertText: [NSString stringWithFormat:@"Stunden gesamt (alle Projekte): %1.2f \n", intervalTotal/3600]];		
	[textView insertText: [NSString stringWithFormat:@"Tage gesamt: %1.2f \n", intervalTotal/3600/8]];			
	*/
}

- (NSArray*)eventsForCalendar:(CalCalendar*)calendar year:(int)year month:(int)month day:(int)day
{
	//	NSMutableArray *result = [NSMutableArray array];
	NSCalendarDate * startDate = [[NSCalendarDate dateWithYear:year 
														 month:month day:day hour:0 minute:0 second:0 timeZone:nil] retain];			
	NSCalendarDate * endDate = [[NSCalendarDate dateWithYear:year
													   month:month day:day hour:23 minute:59 second:59 timeZone:nil] retain];		
	
	NSPredicate *calendarAndDayPredicate = [CalCalendarStore eventPredicateWithStartDate:startDate endDate:endDate
																			   calendars:[NSArray arrayWithObject:calendar]];
	NSArray *events = [[CalCalendarStore defaultCalendarStore] eventsWithPredicate:calendarAndDayPredicate];
	
	return events;
}

- (IBAction)quit:(id)sender
{
	//	[NSApplication 
}


/**
    Returns the support folder for the application, used to store the Core Data
    store file.  This code uses a folder named "Stundentool" for
    the content, either in the NSApplicationSupportDirectory location or (if the
    former cannot be found), the system's temporary directory.
 */

- (NSString *)applicationSupportFolder {

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"5to12"];
}


/**
    Creates, retains, and returns the managed object model for the application 
    by merging all of the models found in the application bundle.
 */
 
- (NSManagedObjectModel *)managedObjectModel {

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
    Returns the persistent store coordinator for the application.  This 
    implementation will create and return a coordinator, having added the 
    store for the application to it.  (The folder for the store is created, 
    if necessary.)
 */

- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    NSFileManager *fileManager;
    NSString *applicationSupportFolder = nil;
    NSURL *url;
    NSError *error;
    
    fileManager = [NSFileManager defaultManager];
    applicationSupportFolder = [self applicationSupportFolder];
    if ( ![fileManager fileExistsAtPath:applicationSupportFolder isDirectory:NULL] ) {
        [fileManager createDirectoryAtPath:applicationSupportFolder attributes:nil];
    }
    
    url = [NSURL fileURLWithPath: [applicationSupportFolder stringByAppendingPathComponent: @"5to12.xml"]];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]){
        [[NSApplication sharedApplication] presentError:error];
    }    

    return persistentStoreCoordinator;
}


/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
 
- (NSManagedObjectContext *) managedObjectContext {

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return managedObjectContext;
}


/**
    Returns the NSUndoManager for the application.  In this case, the manager
    returned is that of the managed object context for the application.
 */
 
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}


/**
    Performs the save action for the application, which is to send the save:
    message to the application's managed object context.  Any encountered errors
    are presented to the user.
 */
 
- (IBAction) saveAction:(id)sender {

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


/**
    Implementation of the applicationShouldTerminate: method, used here to
    handle the saving of changes in the application managed object context
    before the application terminates.
 */
 
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    NSError *error;
    int reply = NSTerminateNow;
    
    if (managedObjectContext != nil) {
        if ([managedObjectContext commitEditing]) {
            if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
				
                // This error handling simply presents error information in a panel with an 
                // "Ok" button, which does not include any attempt at error recovery (meaning, 
                // attempting to fix the error.)  As a result, this implementation will 
                // present the information to the user and then follow up with a panel asking 
                // if the user wishes to "Quit Anyway", without saving the changes.

                // Typically, this process should be altered to include application-specific 
                // recovery steps.  

                BOOL errorResult = [[NSApplication sharedApplication] presentError:error];
				
                if (errorResult == YES) {
                    reply = NSTerminateCancel;
                } 

                else {
					
                    int alertReturn = NSRunAlertPanel(nil, @"Could not save changes while quitting. Quit anyway?" , @"Quit anyway", @"Cancel", nil);
                    if (alertReturn == NSAlertAlternateReturn) {
                        reply = NSTerminateCancel;	
                    }
                }
            }
        } 
        
        else {
            reply = NSTerminateCancel;
        }
    }
    
    return reply;
}


/**
    Implementation of dealloc, to release the retained variables.
 */
 
- (void) dealloc {

    [managedObjectContext release], managedObjectContext = nil;
    [persistentStoreCoordinator release], persistentStoreCoordinator = nil;
    [managedObjectModel release], managedObjectModel = nil;
    [super dealloc];
}


@end
