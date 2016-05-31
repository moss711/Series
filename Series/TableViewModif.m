//
//  TableViewModif.m
//  Series
//
//  Created by Alexandre Blanco Gómez on 31/05/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "TableViewModif.h"
#import "AppDelegate.h"

@implementation TableViewModif


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)scrollRowToVisible:(NSInteger)rowIndex animate:(BOOL)animate{
    if(animate){
        NSRect rowRect = [self rectOfRow:rowIndex];
        NSPoint scrollOrigin = rowRect.origin;
        NSClipView *clipView = (NSClipView *)[self superview];
        scrollOrigin.y += MAX(0, round((NSHeight(rowRect)-NSHeight(clipView.frame))*0.5f));
        NSScrollView *scrollView = (NSScrollView *)[clipView superview];
        if([scrollView respondsToSelector:@selector(flashScrollers)]){
            [scrollView flashScrollers];
        }
        [[clipView animator] setBoundsOrigin:scrollOrigin];
    }else{
        [self scrollRowToVisible:rowIndex];
    }
}

- (void)keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if(key == NSDeleteCharacter || key==NSDeleteFunctionKey)
    {
        [self borrar];
        return;
    }

    
    [super keyDown:theEvent];
    
}
-(void)borrar{
    [(AppDelegate*)[NSApplication sharedApplication].delegate eliminar:self];
}

- (BOOL)validateProposedFirstResponder:(NSResponder *)responder forEvent:(NSEvent *)event
{
    // This allows the user to click on controls within a cell withough first having to select the cell row
    return YES;
}

@end
