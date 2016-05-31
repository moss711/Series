//
//  TableViewModif.h
//  Series
//
//  Created by Alexandre Blanco Gómez on 31/05/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TableViewModif : NSTableView

- (void)scrollRowToVisible:(NSInteger)rowIndex animate:(BOOL)animate;
@end
