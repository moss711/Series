//
//  VentanaPreferencias.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 25/3/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "VentanaPreferencias.h"
#import "AppDelegate.h"

@interface VentanaPreferencias ()
@property NSURL* directorioSubs;
@end

@implementation VentanaPreferencias


-(instancetype)initWithGestorDeOpciones:(GestorDeOpciones *)gestorOpciones{
    self=[super initWithWindowNibName:@"VentanaPreferencias"];
    self.gestorOpciones=gestorOpciones;
    self.directorioSubs=gestorOpciones.rutaSubs;
    
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.textFieldDirectorioSubs.stringValue=self.gestorOpciones.rutaSubs.relativePath;
    [self.desplegableIdiomaSubs selectItemWithTag:self.gestorOpciones.buscadorSubsPorDefecto];
}

- (void)mouseDown:(NSEvent *)event{
    [self.window makeFirstResponder:nil];
}

- (IBAction)abrirPanelRutaSubs:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    
    [panel setCanChooseFiles:NO];
    
    // Enable the selection of directories in the dialog.
    [panel setCanChooseDirectories:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  theDoc = [[panel URLs] objectAtIndex:0];
            
            self.directorioSubs=theDoc;
            self.textFieldDirectorioSubs.stringValue=theDoc.relativePath;
            //NSLog(@"%@",[theDoc relativePath]);
        }
        
    }];

}

- (IBAction)botonCancelar:(id)sender {
    [self close];
}

- (IBAction)botonAceptar:(id)sender {
    //[(AppDelegate*)[NSApplication sharedApplication].delegate actualizarPreferenciasConRutaDeSubs:self.directorioSubs];
    [self.gestorOpciones cambiarRutaSubs:self.directorioSubs];
    [self.gestorOpciones cambiarBuscadorSubsPorDefecto:self.desplegableIdiomaSubs.selectedTag];
    //NSLog(@"%d",self.desplegableIdiomaSubs.selectedTag);
    [self close];
}

@end
