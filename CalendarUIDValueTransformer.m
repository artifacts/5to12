//
//  CalendarUIDValueTransformer.m
//  Stundentool
//
//  Created by Michael Markowski on 03.04.09.
//  Copyright 2009 Artifacts. All rights reserved.
//

#import "CalendarUIDValueTransformer.h"
#import <CalendarStore/CalendarStore.h>

@implementation CalendarUIDValueTransformer

+ (Class)transformedValueClass
{
	return [CalCalendar class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}
- (id)transformedValue:(id)value
{
	if (!value) return nil;
	NSString *uid = (NSString*)value;
	CalCalendar *calendar = [[CalCalendarStore defaultCalendarStore] calendarWithUID:uid];
	return calendar;
}

- (id)reverseTransformedValue:(id)value
{
	if (!value) return nil;
	CalCalendar *calendar = (CalCalendar*)value;
	return calendar.uid;
}

@end
