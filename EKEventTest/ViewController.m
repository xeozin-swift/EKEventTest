//
//  ViewController.m
//  EKEventTest
//
//  Created by 홍서진 on 16/01/2019.
//  Copyright © 2019 홍서진. All rights reserved.
//

#import "ViewController.h"
#import <EventKit/EventKit.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSString *savedEventId;
}

@property (nonatomic, strong) NSArray *allEvents;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadEvents];
}

- (void)loadEvents {
    EKEventStore *store = [[EKEventStore alloc] init];
    
    // Get the appropriate calendar
//    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components
//    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
//    oneDayAgoComponents.day = -1;
//    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
//                                                  toDate:[NSDate date]
//                                                 options:0];
//
    // Create the end date components
//    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
//    oneYearFromNowComponents.year = 1;
//    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
//                                                       toDate:[NSDate date]
//                                                      options:0];
    
    // 이번달 1일
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *arbitraryDate = [NSDate date];
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:arbitraryDate];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [gregorian dateFromComponents:comp];
    
    // 달의 마지막 날 구하기
    NSDate *curDate = [NSDate date];
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSRange daysRange = [currentCalendar rangeOfUnit:NSCalendarUnitDay
                                              inUnit:NSCalendarUnitMonth
                                             forDate:curDate];
    
    // 달의 마지막 날 NSDate
    NSDateComponents *comp2 = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:arbitraryDate];
    [comp2 setDay:daysRange.length];
    NSDate *lastDayOfMonthDate = [gregorian dateFromComponents:comp2];
    // daysRange.length will contain the number of the last day
    // of the month containing curDate
    
    // Create the predicate from the event store's instance method
    NSPredicate *predicate = [store predicateForEventsWithStartDate:firstDayOfMonthDate
                                                            endDate:lastDayOfMonthDate
                                                          calendars:nil];
    
    // Fetch all events that match the predicate
    self.allEvents = [store eventsMatchingPredicate:predicate];
    
}

- (void)createEvent {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) return;
        EKEvent *event = [EKEvent eventWithEventStore:store];
        event.title = @"Event Title";
        event.startDate = [NSDate date]; // today
        event.endDate = [event.startDate dateByAddingTimeInterval:60*60];  // Duration 1 hr
        [event setCalendar:[store defaultCalendarForNewEvents]];
        NSError *err = nil;
        [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        self->savedEventId = event.eventIdentifier;  // Store this so you can access this event later
    }];
}

- (void)editEvent {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) return;
        EKEvent *event = [store eventWithIdentifier:self->savedEventId];
        // Uncomment below if you want to create a new event if savedEventId no longer exists
        // if (event == nil)
        //   event = [EKEvent eventWithEventStore:store];
        if (event) {
            NSError *err = nil;
            event.title = @"New event title";
            [store saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
        }
    }];
}

- (void)deleteEvent {
    EKEventStore *store = [[EKEventStore alloc] init];
    [store requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (!granted) return;
        EKEvent* eventToRemove = [store eventWithIdentifier:self->savedEventId];
        if (eventToRemove) {
            NSError* err = nil;
            [store removeEvent:eventToRemove span:EKSpanThisEvent commit:YES error:&err];
        }
    }];
}

- (IBAction)create:(id)sender {
    [self createEvent];
}

- (IBAction)edit:(id)sender {
    [self editEvent];
}

- (IBAction)delete:(id)sender {
    [self deleteEvent];
}

- (IBAction)load:(id)sender {
    [self loadEvents];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalCell"];
    EKEvent *event = [self.allEvents objectAtIndex:indexPath.row];
    cell.textLabel.text = event.title;
    return cell;
}

@end
