//
//  TextFieldConAvisoDeFocus.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 12/4/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "TextFieldConAvisoDeFocus.h"
#import "VentanaAnadir.h"

@implementation TextFieldConAvisoDeFocus

@dynamic delegate;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (BOOL)becomeFirstResponder{
    BOOL didBecomeFirstResponder = [super becomeFirstResponder];
    
    NSNotification *notification=[[NSNotification alloc]initWithName:@"textFieldDidBecomeFirstResponder" object:self userInfo:nil];
//    if([[self delegate] respondsToSelector:@selector(textFieldDidBecomeFirstResponder:)]) {
        [[self delegate] textFieldDidBecomeFirstResponder:notification];
//    }
    
    return didBecomeFirstResponder;
}
@end

