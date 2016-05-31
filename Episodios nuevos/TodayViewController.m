//
//  TodayViewController.m
//  Episodios nuevos
//
//  Created by Alexandre Blanco Gómez on 14/11/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
    // Update your data and prepare for a snapshot. Call completion handler when you are done
    // with NoData if nothing has changed or NewData if there is new data since the last
    // time we called you
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"com.Horseware.TvTime.TodayWidget"];
    NSString *serie = [defaults objectForKey:@"Serie"];
    if(serie!=nil){
        //self.textFieldPrincipal.stringValue=serie;
    }
    completionHandler(NCUpdateResultNewData);
    //completionHandler(NCUpdateResultNoData);
}

@end

