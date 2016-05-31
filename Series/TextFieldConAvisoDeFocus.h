//
//  TextFieldConAvisoDeFocus.h
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 12/4/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol TextFieldFocusDelegate <NSTextFieldDelegate>
@required
- (void)textFieldDidBecomeFirstResponder:(NSNotification *)notification;
@end

@interface TextFieldConAvisoDeFocus : NSTextField
@property (assign) id<TextFieldFocusDelegate> delegate;
@end
