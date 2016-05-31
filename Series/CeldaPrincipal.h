//
//  CeldaPrincipal.h
//  Series
//
//  Created by Alexandre Blanco Gómez on 29/05/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CeldaPrincipal : NSTableCellView
@property IBOutlet NSTextField *nombreSerie;
@property IBOutlet NSTextField *numCapitulo;
@property IBOutlet NSTextField *nombreCapitulo;
@property IBOutlet NSTextField *fechaEmision;
@property IBOutlet NSTextField *dias;
@property IBOutlet NSTextField *horas;

@end
