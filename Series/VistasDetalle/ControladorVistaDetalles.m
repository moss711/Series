//
//  ControladorVistaDetalles.m
//  TvTime
//
//  Created by Alexandre Blanco Gómez on 27/7/15.
//  Copyright (c) 2015 Horseware. All rights reserved.
//

#import "ControladorVistaDetalles.h"
#import "ControladorVistaStandbySinInformacion.h"
#import "ControladorVistaProximosCapitulos.h"
#import "QuartzCore/CATransaction.h"
#import "QuartzCore/Caanimation.h"


@implementation ControladorVistaDetalles

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.historialVistas=[[NSMutableArray alloc]init];
    [self mostrarVistaStandby];
}

-(void)mostrarVistaStandby{//Esto elimina el historial
    [self.historialVistas removeAllObjects];
    BOOL animar=YES;
    if([self.controladorVistaActual isMemberOfClass:[ControladorVistaStandbySinInformacion class]]){
        animar=NO;
        NSLog(@"Misma clase");
    }
    if(animar){
        CATransition *animation = [CATransition animation];
        animation.duration = 0.25;
        animation.type = kCATransitionPush;
        animation.subtype=kCATransitionFromRight;
        //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.view.layer addAnimation:animation forKey:@"ChangeView"];
    }
    if(self.controladorVistaActual!=nil){
        [self.controladorVistaActual.view removeFromSuperview];
        self.controladorVistaActual=nil;
    }
    self.vistaCabecera.hidden=YES;
    self.vistaCuerpo.hidden=YES;
    self.controladorVistaActual=[[ControladorVistaStandbySinInformacion alloc]init];
    [self mostrarVista:self.controladorVistaActual.view en:self.view];
    
}

-(void)mostrarVistaProximosCapitulos:(NSArray *)series{
    [self.historialVistas removeAllObjects];
    CATransition *animation = [CATransition animation];
    animation.duration = 0.25;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromRight;
    //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.view.layer addAnimation:animation forKey:@"ChangeView"];
    
    [self.controladorVistaActual.view removeFromSuperview];
    self.controladorVistaActual=[[ControladorVistaProximosCapitulos alloc]initWithSeries:series];
    self.vistaCabecera.hidden=NO;
    self.vistaCuerpo.hidden=NO;
    self.labelBotonIzq.stringValue=@"Cerrar";
    self.labelTitulo.stringValue=self.controladorVistaActual.getStringTitulo;
    self.labelSubtitulo.stringValue=self.controladorVistaActual.getStringSubtitulo;
    NSLog(@"%@",self.vistaCuerpo.class);
    if(self.vistaCuerpo==nil){
        NSLog(@"Vista cuerpo es nil");
    }
    [self mostrarVista:self.controladorVistaActual.view en:self.vistaCuerpo];
}

-(void)mostrarVista:(NSView*)nuevaVista en:(NSView*)contenedorNuevaVista{
    NSRect rect;
    rect.origin.x=0;rect.origin.y=0;
    rect.size=contenedorNuevaVista.frame.size;
    [nuevaVista setFrame:rect];
    [contenedorNuevaVista addSubview:nuevaVista];
    [nuevaVista setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
}

@end
