//
//  AppDelegate.m
//  Series
//
//  Created by Alexandre Blanco Gómez on 29/05/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import "AppDelegate.h"
#import "Serie.h"
#import "Episodio.h"
#import "EpisodioTemp.h"
#import "CeldaPrincipal.h"
#import "CeldaAnteriorSub.h"
#import "ObjectiveGumbo/ObjectiveGumbo.h"
#import "ImageViewClickSub.h"
#import "ImageViewClickDescargar.h"
#import "DescargaTemp.h"
#import "ControladorVentanaSecundaria.h"
#import "GestorDeFicheros.h"
#import "GestorDeNotificaciones.h"
#import "GestorDeOpciones.h"
#import "TVRageEpisodeInfo.h"
#import "TVRageEpisodeList.h"
#import "VentanaAnadir.h"
#import "VentanaPreferencias.h"
#import "SubtitulosEsListaSeries.h"
#import "TVRageSearch.h"
#import "TVRageSerie.h"
#import "TheTVDBSearch.h"
#import "TheTVDBSerie.h"
#import "TheTVDBBanners.h"
#import "ControladorVistaDetalles.h"

#import "QuartzCore/CATransaction.h"
#import "QuartzCore/Caanimation.h"

@implementation AppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

NSMutableArray *series;
NSArray *busqueda;
TVRageSearch *busquedaTVRage;
NSMutableArray *proximos;
NSMutableArray *anteriores;
Boolean recargando;
dispatch_semaphore_t semaforoSeries;
NSDate *fechaUltimaRecarga;
ControladorVentanaSecundaria *ventanaSerie;
VentanaAnadir *ventanaAnadir;
VentanaPreferencias *ventanaPreferencias;
GestorDeFicheros *gestorFicheros;
GestorDeNotificaciones *gestorNotificaciones;
GestorDeOpciones *gestorOpciones;
TVRageSerie *serieBusquedaSeleccionada;
ControladorVistaDetalles *controladorVistaDetalles;
int contadorParaSubEs=0;
//popover anadir
bool popoverPrimeraExpansion=NO;
bool popoverSegundaExpansion=NO;
//



- (void)applicationDidHide:(NSNotification *)aNotification{
    [self actualizarSegundoPlano];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center
     shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void) userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification{
    
    //[self.window makeKeyAndOrderFront:self];//Para que se vea la ventana si estaba cerrada
    if([[notification title]isEqualToString:@"Series"]){
        NSLog(@"Notificacion Series clickada");
        [self.window makeKeyAndOrderFront:self];//Abrimos la ventana si no estaba abierta
    }
    if([[notification title] isEqualToString:@"Subtítulo disponible"]||[[notification title] isEqualToString:@"Subtítulos disponibles"]){
        //[self.segmentedControl setSelected:YES forSegment:1];
        //[self cambioSegmentedControl:self.segmentedControl];
        [self descargarSubsPendientes:self];
    }
    [center removeDeliveredNotification: notification];
}

-(void)windowDidClose{
    [self actualizarSegundoPlano];
}

//- (void)applicationDidResignActive:(NSNotification *)aNotification{
//    NSLog(@"%@",@"applicationdidResignActive");
//}


- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    
	if(flag==NO){
		[self.window makeKeyAndOrderFront:self];
	}
	return YES;
}

- (void)actualizarSegundoPlano{
    if((fechaUltimaRecarga==nil)||(([NSDate date].timeIntervalSince1970-fechaUltimaRecarga.timeIntervalSince1970)>60*60*2)){
        fechaUltimaRecarga=[NSDate date];
        [self actualizar:self];
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //NSLog(@"Arrancamos");
    // Insert code here to initialize your application
    self.window.titleVisibility = NSWindowTitleHidden; //esto para la ventana sin titulo y con barra gorda 
    NSManagedObjectContext *context = [self managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Serie" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    series = [[NSMutableArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    
    
    busqueda=[[NSArray alloc] init];
    
    //Iniciar el panel derecho
    controladorVistaDetalles=[[ControladorVistaDetalles alloc]init];
    [self.panelDetalles addSubview:controladorVistaDetalles.view];
    NSRect rect;
    rect.origin.x=0;rect.origin.y=0;
    rect.size=self.panelDetalles.frame.size;
    [controladorVistaDetalles.view setFrame:rect];
    [controladorVistaDetalles.view setAutoresizingMask:NSViewHeightSizable|NSViewWidthSizable];
    //[controladorVistaDetalles mostrarVistaInicial];
    
    //Activo el doble click para anadir serie
    [self.tableviewBusqueda setDoubleAction:@selector(popoverAnadir:)];
    
    //Inicializamos los array de epsiodios
    fetchRequest = [[NSFetchRequest alloc] init];
    entity = [NSEntityDescription
              entityForName:@"Episodio" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSMutableArray *episodios=[[NSMutableArray alloc] initWithArray:[context executeFetchRequest:fetchRequest error:&error]];
    anteriores=[[NSMutableArray alloc] init];
    proximos=[[NSMutableArray alloc]init];
    
    //Miramos null
    NSMutableArray *aBorrar=[[NSMutableArray alloc]init];
    for(Episodio * ep in episodios){
        if(ep.serie==nil){
            [aBorrar addObject:ep];
            NSLog(@"Ep ->%@<- tiene serie null",ep.nombreEpisodio);
        }
    }
    for(Episodio *ep in aBorrar){
        [context deleteObject:ep];
        [episodios removeObject:ep];
    }
    
    
    for(Episodio *episodio in episodios){
        if  ([episodio.tipo integerValue]==1){//anteriores es 1, proximos es 0
            [anteriores addObject:episodio];
        }else{
            [proximos addObject:episodio];
        }
    }
    
    //Ordenar series
    [proximos sortUsingSelector:@selector(compareProximos:)];
    
    [anteriores sortUsingSelector:@selector(compareAnteriores:)];
    
    //Para activar notificaciones de usuario
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    //Para recibir notificacion cuando se cierre
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidClose)
                                                 name:NSWindowWillCloseNotification
                                               object:self.window];
    
    [self comprobarEpisodiosAntiguos];//Se ejecuta en main
    
    //Arrancamos el gestor de opciones
    gestorOpciones=[[GestorDeOpciones alloc]init];
    
    //Arrancamos el gestor de ficheros
    //Borrar si funciona
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSString* rutaSubs=[prefs objectForKey:@"rutaSubs"];
//    if(rutaSubs==nil){
//        gestorFicheros=[[GestorDeFicheros alloc]init];
//        [self abrirPreferencias:self];
//    }else{
//        gestorFicheros=[[GestorDeFicheros alloc]initWithRutaSubs:rutaSubs];
//    }
    gestorFicheros=[[GestorDeFicheros alloc]initWithGestorOpciones:gestorOpciones];
    
    
    gestorNotificaciones=[[GestorDeNotificaciones alloc]initConBotonEp:self.botonEpBarraInferior botonSub:self.botonSubBarraInferior textField:self.textFieldBarraInferior];
    [self snippetRefrescarNumeroEpySubsGestorDeNotificaciones];
    
    semaforoSeries=dispatch_semaphore_create(1);
    
    recargando=NO;//Para que no se ponga mas de una recarga en cola
    
    
    
    [self.tableviewPrincipal reloadData];
    [self actualizarListaEpisodios:self soloPasados:YES];
    
    [self refrescarBadge];
    //[self refrescarTimer]; //ya se va a hacer en actualizar despues de la busqueda
    
    
    
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1800.0//cada media hora
                                                      target:self
                                                    selector:@selector(refrescarTimer)
                                                    userInfo:nil
                                                     repeats:YES];
    [timer setTolerance:300];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:3600//Cada hora se comprueba
                                             target:self
                                           selector:@selector(actualizarSegundoPlano)
                                           userInfo:nil
                                            repeats:YES];
    [timer setTolerance:300];
    
    
    
    
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.horseware.Series" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.horseware.Series"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Series" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Series.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:options error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}


- (IBAction)debugListarTorrents:(id)sender {

}

- (IBAction)anteriores:(id)sender {
    [self.segmentedControl setSelected:YES forSegment:1];
    [self cambioSegmentedControl:self.segmentedControl];
    
}

- (IBAction)proximos:(id)sender {
    [self.segmentedControl setSelected:YES forSegment:0];
    [self cambioSegmentedControl:self.segmentedControl];
}

- (IBAction)exportarSeries:(id)sender {
    // create the save panel
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    // set a new file name
    [panel setNameFieldStringValue:@"series.txt"];
    
    // display the panel
    [panel beginWithCompletionHandler:^(NSInteger result) {
        
        if (result == NSFileHandlingPanelOKButton) {
            
            // create a file namaner and grab the save panel's returned URL
            NSURL *saveURL = [panel URL];
            
            //Crear el fichero
            
            NSMutableString* salida = [[NSMutableString alloc]init];
            NSMutableArray *sids=[[NSMutableArray alloc]init];
            for(Serie *serie in series){
                [sids addObject:serie.sid];
            }
            NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
            [sids sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
            for(int i=0;i<[sids count];i++){
                NSNumber *sid=[sids objectAtIndex:i];
                [salida appendString:sid.stringValue];
                if(i<([sids count]-1)){
                    [salida appendString:@";"];
                }
            }
            [salida writeToURL:saveURL atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
        }
    }];
}

- (IBAction)importarSeries:(id)sender {
//    NSOpenPanel *panel = [NSOpenPanel openPanel];
//    [panel setNameFieldLabel:@"series.txt"];
//    
//    [panel beginWithCompletionHandler:^(NSInteger result) {
//        
//        if (result == NSFileHandlingPanelOKButton) {
//            NSLog(@"%@",@"Importando");
//            // create a file namaner and grab the save panel's returned URL
//            NSURL *saveURL = [panel URL];
//            
//            //Crear el fichero
//            
//            [self enableTodo:NO];
//            NSString *entrada=[[NSString alloc]initWithContentsOfURL:saveURL encoding:NSStringEncodingConversionAllowLossy error:nil];
//            NSArray *items = [entrada componentsSeparatedByString:@";"];
//            
//            
//    
//            
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                //SeccionCritica
//                dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
//                recargando=YES;
//                NSMutableArray *noExisten = [[NSMutableArray alloc]init];
//                for(NSString *sid in items){
//                    BOOL existe = NO;
//                    for(Serie *serie in series){
//                        if(serie.sid.intValue==sid.intValue){
//                            existe=YES;
//                            break;
//                        }
//                    }
//                    if(!existe){
//                        [noExisten addObject:[[NSNumber alloc]initWithInt:[sid intValue]]];
//                    }
//                }
//                [self.spinningWheelRecarga startAnimation:self];
//                [self.progressIndicator setHidden:NO];
//                [self.progressIndicator setMinValue:0];
//                [self.progressIndicator setMaxValue:[noExisten count]];
//                [self.progressIndicator setDoubleValue:0];
//                [self.progressIndicator startAnimation:self];
//                //Final SC
//                dispatch_semaphore_signal(semaforoSeries);
//                
//                for(NSNumber * sid in noExisten){
//                    InformacionSerieNueva *infoSerie = [[InformacionSerieNueva alloc]initWithSid:sid];
//                    NSImage* poster = [infoSerie obtenerPoster];
//                    BOOL exito=[gestorFicheros guardarPoster:poster conSid:infoSerie.sid];
//                    if(!exito){
//                        NSLog(@"Error al guardar el poster");
//                    }
//                    
//                    NSMutableArray *episodios=[self actualizarSerie:infoSerie.sid conNombre:infoSerie.serie];
//                    //El id de tvdb ya se guardo aquien obtener imagen
//                    
//                    //SC
//                    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
//                    NSManagedObjectContext *context = [self managedObjectContext];
//                    Serie *serieNueva = [NSEntityDescription
//                                         insertNewObjectForEntityForName:@"Serie"
//                                         inManagedObjectContext:context];
//                    serieNueva.sid=infoSerie.sid;
//                    serieNueva.serie=infoSerie.serie;
//                    serieNueva.ano=infoSerie.ano;
//                    serieNueva.pais=infoSerie.pais;
//                    serieNueva.idTVdb=infoSerie.idTVdb;
//                    serieNueva.miniatura=[infoSerie.miniatura TIFFRepresentation];
//                    //serieNueva.poster=[infoSerie.poster TIFFRepresentation];
//                    [series addObject:serieNueva];//Se anade al array
//                    
//                    for(EpisodioTemp *ep in episodios){
//                        Episodio *siguienteEp = [NSEntityDescription
//                                                 insertNewObjectForEntityForName:@"Episodio"
//                                                 inManagedObjectContext:context];
//                        siguienteEp.nombreEpisodio=ep.nombreEpisodio;
//                        siguienteEp.numEpisodio=ep.numEpisodio;
//                        siguienteEp.hora=ep.hora;
//                        siguienteEp.serie=serieNueva;
//                        siguienteEp.tipo=[[NSNumber alloc]initWithInt:0];
//                        [proximos addObject:siguienteEp];
//                    }
//                    
//                    NSError *error;
//                    if (![context save:&error]) {//Se guarda el cambio en coredata
//                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//                    }
//                    
//                    [self.progressIndicator incrementBy:1];
//                    //Fin SC
//                    dispatch_semaphore_signal(semaforoSeries);
//                }
//                
//                
//                [proximos sortUsingSelector:@selector(compareProximos:)];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableviewPrincipal reloadData];
//                });
//                [self.spinningWheelRecarga stopAnimation:self];
//                [self.progressIndicator stopAnimation:self];
//                [self.progressIndicator setHidden:YES];
//                recargando=NO;
//                [self enableTodo:YES];
//            });
//        }
//    }];
    
}



- (IBAction)popoverBuscar:(id)sender {
    
    NSLog(@"Buscamos %@",self.popoverTextfield.stringValue);
    //[self.spinningWheelPopoverBuscar startAnimation:self];
    NSLog(@"Uno");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        busquedaTVRage=[[TVRageSearch alloc]initWithString:self.popoverTextfield.stringValue];
        busqueda =[busquedaTVRage getBusqueda];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //[CATransaction begin];//Todo esto es para que no de el error de uncommited catransaction
            if(!popoverPrimeraExpansion){
                NSSize tamano;
                tamano.height=295.0f;
                tamano.width=276.0f;
                [self.popover setContentSize:tamano];
                popoverPrimeraExpansion=YES;
            }
            //[CATransaction commit];
            [self.desplegableUltimoEpPopover removeAllItems];
            [self.desplegableUltimoEpPopover addItemWithTitle:@"..."];
            [self.tableviewBusqueda reloadData];
            //[self.spinningWheelPopoverBuscar stopAnimation:self];
        });
        
        //[self.popover close];
    });
}

- (IBAction)actualizar:(id)sender{
    [self actualizarListaEpisodios:sender soloPasados:NO];
}

-(void)actualizarListaEpisodiosDeSeries:(NSArray*)seriesAActualizar{
    if(!recargando){
        recargando=YES;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [gestorNotificaciones inicioDeActualizarEpisodios];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self enableRecargar:NO];
                [self.spinningWheelRecarga startAnimation:self];
                [self.progressIndicator setHidden:NO];
                [self.progressIndicator setMinValue:0];
                [self.progressIndicator setMaxValue:[seriesAActualizar count]];
                [self.progressIndicator setDoubleValue:0];
                [self.progressIndicator startAnimation:self];
            });
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self refrescarTimer];
            });
            NSLog(@"Voy a actualizar %lu series\n",(unsigned long)[seriesAActualizar count]);
            
            //Se cogen los episodios de cada serie
            NSMutableArray *arrayEpisodios =[[NSMutableArray alloc]init];
            dispatch_group_t group = dispatch_group_create();
            
            for(Serie *serieAActualizar in seriesAActualizar){
                dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSMutableArray *episodios=[self actualizarSerie:serieAActualizar];
                    
                    //Seccion critica(Añadir los episodios
                    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
                    if(episodios!=nil){
                        [arrayEpisodios addObject:episodios];
                    }else{
                        [self problemasAlRefrescar:serieAActualizar.serie];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.progressIndicator incrementBy:1];
                    });
                    dispatch_semaphore_signal(semaforoSeries);
                });
            }
            //Esperamos a todos los hilos
            dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
            
            //Seccion critica. Aqui procesamos los episodios que recibimos de la funcion anterior
            dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
            NSManagedObjectContext *context = [self managedObjectContext];
            NSMutableArray *aBorrar=[[NSMutableArray alloc]init];
            NSMutableArray *aAnadir=[[NSMutableArray alloc]init];
            NSMutableIndexSet *indexesBorrar = [[NSMutableIndexSet alloc]init];
            
            for(NSMutableArray *epSerie in arrayEpisodios){
                NSNumber *sid=((EpisodioTemp *)[epSerie objectAtIndex:0]).sid;
                Serie *serie;
                
                if((serie=[self getSerie:sid])!=NULL){
                    
                    //Esto es por si alguno de estos episodios ya esta en anteriores(Pero esto no deberia pasa)
                    //En vez de esto buscar aqui los que son pasados y añadirlos a anteriores.
                    //Nota:Ahora mismo si se devuelve un episodio antiguo pasa primero por la lista de proximos hasta que la siguiente llamada a comprobarEpAnteriores los registre como anteriores(entonces se anota ese episodio como ultimo episodio en anteriores) y l siguiente vez que se recarga ya no sale este episodio de la funcion de actualizar serie
                    NSMutableArray *epAnterioresAEliminarDeLista = [[NSMutableArray alloc]init];
                    for(EpisodioTemp *epNuevo in epSerie){
                        //NSLog(@"%@ %@%@ %@",serie.serie,epNuevo.numEpisodio,epNuevo.nombreEpisodio,epNuevo.hora);
                        if(!([epNuevo.nombreEpisodio isEqualToString:@"TBA"] && [epNuevo.numEpisodio isEqualToString:@"-1"])){
                            if  (epNuevo.hora.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970){
                                Boolean encontrado=NO;
                                for (Episodio *ep in anteriores) {
                                    if(epNuevo.sid.integerValue==ep.serie.sid.integerValue&&[epNuevo.numEpisodio isEqualToString:ep.numEpisodio]&&[epNuevo.nombreEpisodio isEqualToString:ep.nombreEpisodio]){
                                        encontrado=YES;
                                        break;
                                    }
                                }
                                if(encontrado){
                                    NSLog(@"No anado a proximos %@ de %@",epNuevo.nombreEpisodio,serie.serie);
                                    [epAnterioresAEliminarDeLista addObject:epNuevo];
                                }
                            }
                        }
                    }
                    [epSerie removeObjectsInArray:epAnterioresAEliminarDeLista];
                    if(epSerie.count==0){
                        EpisodioTemp *epTBA = [[EpisodioTemp alloc] init];
                        epTBA.sid=sid;
                        epTBA.nombreEpisodio=@"TBA";
                        epTBA.numEpisodio=@"-1";
                        epTBA.hora=nil;
                        
                        [epSerie addObject:epTBA];
                    }
                    //Hasta aqui la parte de mirar en anteriores
                    
                    
                    //Apunto para borrado los episodios que estan en proximos que no estan en la lista actualizada
                    for(Episodio *epViejo in proximos){
                        Boolean borrar=NO;//Si la serie no existe en la lista actualizada no se borra,porque o se acaba de añadir o hubo problemas al refrescar
                        if(epViejo.serie==serie){
                            borrar=YES;
                            for(EpisodioTemp *epNuevo in epSerie){
                                if ([epViejo.numEpisodio isEqualToString:epNuevo.numEpisodio]&&[epViejo.nombreEpisodio isEqualToString:epNuevo.nombreEpisodio]&&[epViejo.hora compare:epNuevo.hora]==NSOrderedSame){
                                    //NSLog(@"No Borrar %@ %@ hora vieja:%@ hora nueva:%@",epViejo.serie.serie,epViejo.nombreEpisodio,epViejo.hora, epNuevo.hora);
                                    borrar=NO;
                                    break;
                                }
                            }
                            if(borrar){
                                [aBorrar addObject:epViejo];
                                [indexesBorrar addIndex:[proximos indexOfObject:epViejo]];
                            }
                        }
                    }
                    //De los episodios que estan en la lista actualizada, añadimos a proximos los que no esten ya
                    for(EpisodioTemp *epNuevo in epSerie){
                        Boolean encontrado=NO;
                        for(Episodio *epViejo in proximos){
                            if(epViejo.serie==serie){
                                if ([epViejo.numEpisodio isEqualToString:epNuevo.numEpisodio]&&[epViejo.nombreEpisodio isEqualToString:epNuevo.nombreEpisodio]&&[epViejo.hora compare:epNuevo.hora]==NSOrderedSame){
                                    encontrado=YES;
                                    break;
                                }
                            }
                        }
                        if(!encontrado){
                            Episodio *siguienteEp = [NSEntityDescription
                                                     insertNewObjectForEntityForName:@"Episodio"
                                                     inManagedObjectContext:context];
                            siguienteEp.nombreEpisodio=epNuevo.nombreEpisodio;
                            siguienteEp.numEpisodio=epNuevo.numEpisodio;
                            siguienteEp.numEpisodioTotal=epNuevo.numEpisodioTotal;
                            siguienteEp.hora=epNuevo.hora;
                            siguienteEp.serie=serie;
                            siguienteEp.tipo=[[NSNumber alloc]initWithInt:0];
                            
                            [aAnadir addObject:siguienteEp];
                        }
                    }
                }
            }
            
            //Borro todos los capitulos de proximos
            for(Episodio *ep in aBorrar){
                [proximos removeObject:ep];
                [context deleteObject:ep];
                NSLog(@"Borro %@ %@",ep.serie.serie,ep.numEpisodio);
            }
            //Anado los nuevo a anadir
            for(Episodio *ep in aAnadir){
                [proximos addObject:ep];
                NSLog(@"Anado %@ %@",ep.serie.serie,ep.numEpisodio);
            }
            
            NSLog(@"Borro %lu ep",[aBorrar count]);
            NSLog(@"Anado %lu ep",[aAnadir count]);
            //Guardo
            NSError *error;
            if (![context save:&error]) {//Se guarda el cambio en coredata
                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
            }
            
            //Ordeno la lista
            [proximos sortUsingSelector:@selector(compareProximos:)];
            
            //Obtengo los indexes a anadir
            NSMutableIndexSet *indexesAnadir = [[NSMutableIndexSet alloc]init];
            for(Episodio *ep in aAnadir){
                [indexesAnadir addIndex:[proximos indexOfObject:ep]];
            }
            
            
            if(self.segmentedControl.selectedSegment==0){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableviewPrincipal beginUpdates];
                    
                    [self.tableviewPrincipal removeRowsAtIndexes:indexesBorrar withAnimation:NSTableViewAnimationEffectGap];
                    [self.tableviewPrincipal insertRowsAtIndexes:indexesAnadir withAnimation:NSTableViewAnimationEffectGap];
                    
                    [self.tableviewPrincipal endUpdates];
                });
            }
            
            
            //Actualizo la barra de abajo
            int epTotales=0;
            int ep24h=0;
            int episodios7d=0;
            int seriesTotales=series.count;
            
            for(Episodio *ep in proximos){
                if([ep.nombreEpisodio isEqualToString:@"TBA"]&&[ep.numEpisodio isEqualToString:@"-1"]){
                    continue;
                }
                epTotales++;
                if([ep.hora timeIntervalSinceDate:[NSDate date]]<60*60*24){
                    ep24h++;
                    episodios7d++;
                }else if([ep.hora timeIntervalSinceDate:[NSDate date]]<60*60*24*7){
                    episodios7d++;
                }
            }
            
            [gestorNotificaciones finDeActualizarEpisodiosConEpisodiosTotales:epTotales
                                                                 episodios24h:ep24h
                                                                  episodios7d:episodios7d
                                                                seriesTotales:seriesTotales];
            
            dispatch_semaphore_signal(semaforoSeries);//Hasta aqui la sc. Si, es gigantesca
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.spinningWheelRecarga stopAnimation:self];
                [self.progressIndicator stopAnimation:self];
                [self.progressIndicator setHidden:YES];
                [self enableRecargar:YES];
            });
            
            recargando=NO;
            NSLog(@"%@",@"Actualizado");
            
        });
        
    }
}

- (IBAction)actualizarListaEpisodios:(id)sender soloPasados:(Boolean)soloPasados {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
            [self comprobarEpisodiosAntiguos];
            
            //NSMutableArray *sids = [[NSMutableArray alloc]init];
            NSMutableArray *seriesAActualizar= [[NSMutableArray alloc]init];
            //NSMutableDictionary *nombres =[[NSMutableDictionary alloc]init];
            if(soloPasados==NO){//Todas las series
                fechaUltimaRecarga=[NSDate date];
                
                for (Serie *serie in series){
                    [seriesAActualizar addObject:serie];
                    //[sids addObject:serie.sid];
                    //[nombres setObject:serie.serie forKey:serie.sid];
                }
            }else{//Solo las series que emitieron episodios desde la ultima actualizacion
                for (Episodio *episodio in proximos) {
                    if(episodio.hora!=nil){
                        if(episodio.hora.timeIntervalSince1970<[NSDate date].timeIntervalSince1970){
                            //NSLog(@"Voy a actualizar %@ . Su hora es %f y la hora actual es %f",serie.serie,serie.hora.timeIntervalSince1970,[NSDate date].timeIntervalSince1970);
                            Boolean encontrado = false;
                            
                            for (Serie* serie in seriesAActualizar){
                                if(episodio.serie==serie){
                                    encontrado=true;
                                    break;
                                }
                            }
                            if(!encontrado){
                                //[nombres setObject:episodio.serie.serie forKey:episodio.serie.sid];
                                //[sids addObject:episodio.serie.sid];
                                [seriesAActualizar addObject:episodio.serie];
                            }
                        }
                    }
                }
            }
            dispatch_semaphore_signal(semaforoSeries);
            
            [self actualizarListaEpisodiosDeSeries:seriesAActualizar];
        });
    
}

- (void)actualizarEpisodiosPasados:(id)sender {
    [self actualizarListaEpisodios:sender soloPasados:YES];
}

- (IBAction)popoverAnadir:(id)sender {
    
    if ([self.tableviewBusqueda selectedRow]<0){
        return;
    }
    
    TVRageSerie *serieSeleccionadaTVRage = [busqueda objectAtIndex:[self.tableviewBusqueda selectedRow]];
    NSString * ultimaTemporadaString=@"";
    NSString * ultimoEpisodioString=@"";
    
    if(self.radioButtonsPopover.selectedTag==1){
        NSString* titulo=self.desplegableUltimoEpPopover.selectedItem.title;
        //NSLog(@"%@",self.desplegableUltimoEpPopover.selectedItem.title);
        NSRegularExpression *nameExpression = [NSRegularExpression regularExpressionWithPattern:@"^(\\d+)x(\\d+) (.+)$" options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *matches = [nameExpression matchesInString:titulo
                                                   options:0
                                                     range:NSMakeRange(0, [titulo length])];
        if(matches.count>0){
            NSTextCheckingResult *match = [matches objectAtIndex:0];
            NSRange matchRange;
            matchRange = [match rangeAtIndex:1];
            //NSLog(@"%@",[titulo substringWithRange:matchRange]);
            ultimaTemporadaString=[titulo substringWithRange:matchRange];
            matchRange = [match rangeAtIndex:2];
            //NSLog(@"%@",[titulo substringWithRange:matchRange]);
            ultimoEpisodioString=[titulo substringWithRange:matchRange];
            //matchRange = [match rangeAtIndex:3];
        }
    }
    
    
    NSLog(@"Temporada /%@/ y ep /%@/",ultimaTemporadaString,ultimoEpisodioString);
    
    [self.popover close];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //SC
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        
        Boolean existe=NO;
        for(Serie *serie in series){
            if(serie.sid.intValue==serieSeleccionadaTVRage.sid){
                existe=YES;
                break;
            }
        }
        dispatch_semaphore_signal(semaforoSeries);
        
        if(existe){
             //Anadir!!! Dar algun feedback de que ya existe, por ejemplo seleccionarla y mover la lista a ella
            return;
        }
        
        
        SubtitulosEsListaSeries *listaSubEs=[[SubtitulosEsListaSeries alloc]init];
        int idSubEs=[listaSubEs getSerieParaNombre:serieSeleccionadaTVRage.nombre].id;
        
        
        TheTVDBSerie *serieSeleccionadaTheTVDB=[[TheTVDBSearch alloc]initWithNombre:serieSeleccionadaTVRage.nombre idTVRage:serieSeleccionadaTVRage.sid].getPrimeraOpcion;
        
        NSImage* miniatura=[NSImage imageNamed:@"ImagenDefecto"];
        if(serieSeleccionadaTheTVDB!=nil){
            TheTVDBBanners *banners=[[TheTVDBBanners alloc]initWithID:serieSeleccionadaTheTVDB.sid];
            NSData *poster=banners.getDataPosterMejorValorado;
            //NSImage* miniatura=banners.getImagenMiniaturaMejorValorada;
            
            //Guardamos la imagen en disco
            BOOL exito=[gestorFicheros guardarPosterConData:poster conSid:[NSNumber numberWithInt:serieSeleccionadaTVRage.sid]];
            if(!exito){
                NSLog(@"Error al guardar imagen");
            }
        }
   
        
       
        
        
        //SC
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        existe=NO;
        
        //Se comprueba otra vez por si se anadio de alguna manera mientras estuvimos fuera de la seccion critica
        for(Serie *serie in series){
            if(serie.sid.intValue==serieSeleccionadaTVRage.sid){
                existe=YES;
                break;
            }
        }
        if(!existe){
            NSManagedObjectContext *context = [self managedObjectContext];
            Serie *serieNueva = [NSEntityDescription
                                 insertNewObjectForEntityForName:@"Serie"
                                 inManagedObjectContext:context];
            serieNueva.sid=[NSNumber numberWithInt:serieSeleccionadaTVRage.sid];
            serieNueva.serie=serieSeleccionadaTVRage.nombre;
            serieNueva.nombreParaMostrar=serieSeleccionadaTVRage.nombre;
            //Si es anime
            if(serieSeleccionadaTVRage.esAnime){
                serieNueva.buscadorTorrent=[NSNumber numberWithInt:buscadorSeriesAnimeSubsIncrustados];
                serieNueva.descargaAutomaticaSub=[NSNumber numberWithBool:NO];
            }
            serieNueva.ano=[NSNumber numberWithInt:serieSeleccionadaTVRage.ano.intValue];
            serieNueva.pais=serieSeleccionadaTVRage.pais;
            if(!([ultimaTemporadaString isEqualToString:@""]||[ultimoEpisodioString isEqualToString:@""])){
                serieNueva.ultimaTemporadaEnAnteriores=[[NSNumber alloc]initWithInt:ultimaTemporadaString.intValue];
                serieNueva.ultimoEpisodioEnAnteriores=[[NSNumber alloc]initWithInt:ultimoEpisodioString.intValue];
            }
            serieNueva.idTVdb=[NSNumber numberWithInt:serieSeleccionadaTheTVDB.sid];
            serieNueva.miniatura=[miniatura TIFFRepresentation];
            //Subtitulos.es
            if(idSubEs>=0){
                serieNueva.idSubtitulosEs=[NSNumber numberWithInt:idSubEs];
            }
            
            serieNueva.buscadorSubtitulos=[NSNumber numberWithInt:gestorOpciones.buscadorSubsPorDefecto];
            
            [series addObject:serieNueva];//Se anade al array
            dispatch_semaphore_signal(semaforoSeries);
            
            //Actualizamos los episodios de la serie nueva
            [self actualizarListaEpisodiosDeSeries:[[NSArray alloc]initWithObjects:serieNueva, nil]];
            
            //Estaria bien hacer scroll a un episodio de la serie
            
            
            //Esto es como se anadian antes los episodios, borrar si todo funciona bien
//            NSMutableArray *episodios=[self actualizarSerie:serieNueva];
//            //Esto será llamar a actualizar con solo una serie, cuando se cree una nueva funcion
//            dispatch_semaphore_wait(semaforoSeries,DISPATCH_TIME_FOREVER);
//            for(EpisodioTemp *ep in episodios){
//                Episodio *siguienteEp = [NSEntityDescription
//                                         insertNewObjectForEntityForName:@"Episodio"
//                                         inManagedObjectContext:context];
//                siguienteEp.nombreEpisodio=ep.nombreEpisodio;
//                siguienteEp.numEpisodio=ep.numEpisodio;
//                siguienteEp.hora=ep.hora;
//                siguienteEp.tipo=[[NSNumber alloc]initWithInt:0];
//                siguienteEp.serie=serieNueva;
//                [proximos addObject:siguienteEp];
//            }
//            NSError *error;
//            if (![context save:&error]) {//Se guarda el cambio en coredata
//                NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//            }
//            
//            [proximos sortUsingSelector:@selector(compareProximos:)];
//            Episodio *ep;
//            
//            for(Episodio *episodio in proximos){
//                if (episodio.serie==serieNueva){
//                    ep = episodio;
//                    break;
//                }
//            }
//            //Fin SC
//            dispatch_semaphore_signal(semaforoSeries);
//            NSInteger indiceFila=[proximos indexOfObject:ep];
//            long prueba=indiceFila;
//            NSLog(@"Index donde se anade la nueva serie %ld",prueba);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.tableviewPrincipal beginUpdates];
//                [self.segmentedControl setSelected:YES forSegment:0];
//                [self cambioSegmentedControl:self.segmentedControl];
//                [self.tableviewPrincipal reloadData];
//                NSLog(@"scroll a %ld",(long)indiceFila);
//                [self.tableviewPrincipal selectRowIndexes:[NSIndexSet indexSetWithIndex:(indiceFila)] byExtendingSelection:NO];
//                [self.tableviewPrincipal scrollRowToVisible:indiceFila animate:YES];
//                [self.tableviewPrincipal endUpdates];
//                [self.spinningWheelPopoverAnadir stopAnimation:self];
//            });
//        }
//        else{
//            dispatch_semaphore_signal(semaforoSeries);
//        }
        
        
        //dispatch_async(dispatch_get_main_queue(), ^{
        //[CATransaction begin];//Todo esto es para que no de el error de uncommited catransaction
        //[CATransaction setDisableActions:YES];
        //[self.popover close];
        //[CATransaction commit];
        //});
            
        }
    });
}

- (IBAction)eliminar:(id)sender {
    if ([self.tableviewPrincipal selectedRow]<0){
        return;
    }if (self.segmentedControl.selectedSegment==1){//Si por un casual se borra desde anteriores
        NSBeep();//Para indicar al usuario que no se puede borrar en esa pestana
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        Episodio *epSeleccionado=[proximos objectAtIndex:[self.tableviewPrincipal selectedRow]];
        NSManagedObjectContext *context = [self managedObjectContext];
        
        Serie* serieABorrar=epSeleccionado.serie;
        NSLog(@"Voy a borrar el ep %@ de %@",epSeleccionado.nombreEpisodio,serieABorrar.serie);
        
        NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
        NSMutableArray *aBorrarProximos = [[NSMutableArray alloc]init];
        for(Episodio *ep in proximos){
            if(ep.serie==serieABorrar){
                [indexes addIndex:[proximos indexOfObject:ep]];
                [aBorrarProximos addObject:ep];
            }
        }
        
        //elimino de array de proximos
        for(Episodio *ep in aBorrarProximos){
            [proximos removeObject:ep];
        }
        
        
        NSMutableArray *aBorrarAnteriores= [[NSMutableArray alloc]init];
        for(Episodio *ep in anteriores){
            if(ep.serie==serieABorrar){
                [aBorrarAnteriores addObject:ep];
            }
        }
        
        for(Episodio *ep in aBorrarAnteriores){
            [context deleteObject:ep];
            [anteriores removeObject:ep];
        }
        //Borrar proximos del modelo
        for(Episodio *ep in aBorrarProximos){
            [context deleteObject:ep];
        }
        [gestorFicheros eliminarPosterConSid:serieABorrar.sid];
        [series removeObject:serieABorrar];
        [context deleteObject:serieABorrar];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableviewPrincipal removeRowsAtIndexes:indexes withAnimation:NSTableViewAnimationSlideRight];
        });
        NSError *error;
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        dispatch_semaphore_signal(semaforoSeries);
    });
}

-(NSMutableArray *)actualizarSerie:(Serie *) serie{
    //inicializamos los xml que vamos a necesitar
    //dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
    //NSLog(@"En actualizar %@",serie.serie);
    TVRageEpisodeInfo *tvRageEpisodeInfo=[[TVRageEpisodeInfo alloc]initWithSid:serie.sid.intValue];
    if(tvRageEpisodeInfo==nil){
        return nil;
    }
    TVRageEpisodeList *tvRageEpisodeList=[[TVRageEpisodeList alloc]initWithSid:serie.sid.intValue];
    if(tvRageEpisodeList==nil){
        return nil;
    }
    //dispatch_semaphore_signal(semaforoSeries);
    
    if(!tvRageEpisodeInfo.parsear){
        return nil;
    }
    
    if(!tvRageEpisodeList.parsear){
        return nil;
    }
    //dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
    
    NSMutableArray *episodiosADevolver=[[NSMutableArray alloc]init];
    EpisodioTemp *nextEpisode=tvRageEpisodeInfo.getNextEpisode;
    NSTimeInterval intervalo=0;
    NSDate *fechaAproximadaNextEpisode=nil;
    Boolean nextEpisodeValidoParaReferencia=false;
    Boolean intervaloEsValido=false;
    if(nextEpisode==nil){
        //NSLog(@"Next es nil");
    }else{
        //[episodiosADevolver addObject:nextEpisode]; No lo añado porque cuando busque todos los episodios ya me aparecera
        //Fecha
        //intervalo=nextVerdadero-nextAprox;
        //NuevoVerdadero=intervalo+nuevoAprox;
        
        fechaAproximadaNextEpisode=[tvRageEpisodeList getAirdateDeEpisodio:nextEpisode];
        if(fechaAproximadaNextEpisode!=nil){
            intervalo=nextEpisode.hora.timeIntervalSince1970-fechaAproximadaNextEpisode.timeIntervalSince1970;
            //NSLog(@"Next episode es %@",nextEpisode.nombreEpisodio);
            intervaloEsValido=YES;
        }
        
        //Calculo para saber si se puede usar de referencia
        if(nextEpisode.getTemporada>0&&nextEpisode.getEpisodio>0){
            nextEpisodeValidoParaReferencia=YES;
        }
    }
    NSString *pais=tvRageEpisodeInfo.getPais;
    EpisodioTemp *latestEpisode=tvRageEpisodeInfo.getLatestEpisode;
    //NSLog(@"Latest episode es %@ %@",latestEpisode.numEpisodio,latestEpisode.nombreEpisodio);
    
    //Establecemos el episodio de referencia, despues obtendremos los datos de los episodios superiores a este
    int temporadaDeReferencia;
    int episodioDeReferencia;
    NSDate *fechaDeReferencia;//Esto se usa para los especiales
    if(serie.ultimaTemporadaEnAnteriores!=nil){
        //NSLog(@"Ultima temp: %@ , capi: %@",serie.ultimaTemporadaEnAnteriores,serie.ultimoEpisodioEnAnteriores);
        temporadaDeReferencia=serie.ultimaTemporadaEnAnteriores.intValue;
        episodioDeReferencia=serie.ultimoEpisodioEnAnteriores.intValue;
        EpisodioTemp *ultimoEpEnAnteriores=[[EpisodioTemp alloc]init] ;
        ultimoEpEnAnteriores.sid=serie.sid;
        ultimoEpEnAnteriores.numEpisodio=[[NSString alloc]initWithFormat:@"%dx%d",temporadaDeReferencia,episodioDeReferencia ];
        fechaDeReferencia=[tvRageEpisodeList getAirdateDeEpisodio:ultimoEpEnAnteriores];
        //NSLog(@"Fecha de referencia %@",fechaDeReferencia);
    }else{//Utilizaremos nextEpisode o latestEpisodeComoReferencia, se descarga a partir de la referencia, esta no incluida
        if(nextEpisodeValidoParaReferencia){
            temporadaDeReferencia=nextEpisode.getTemporada;
            episodioDeReferencia=nextEpisode.getEpisodio;
            [tvRageEpisodeList rellenarEpNumDeEpisodio:nextEpisode];
            fechaDeReferencia=fechaAproximadaNextEpisode;
            [episodiosADevolver addObject:nextEpisode];
        }else{
            temporadaDeReferencia=latestEpisode.getTemporada;
            episodioDeReferencia=latestEpisode.getEpisodio;
            fechaDeReferencia=latestEpisode.hora;
        }
    }
    //Si la que tenemos apuntada en serie es mas reciente utilizamos esa
    if(serie.ultimaFechaEnAnteriores!=nil&&serie.ultimaFechaEnAnteriores.timeIntervalSince1970>fechaDeReferencia.timeIntervalSince1970){
        fechaDeReferencia=serie.ultimaFechaEnAnteriores;
    }
    //NSLog(@"Referencias antes de llamar a episodeList por episodios: %d %d %@ ",temporadaDeReferencia,episodioDeReferencia,fechaDeReferencia);
    NSMutableArray *episodiosDevueltosPorEpisodeList=[tvRageEpisodeList getEpisodiosDesdeTemporada:temporadaDeReferencia Episodio:episodioDeReferencia yFecha:fechaDeReferencia conIntervalo:intervalo valido:intervaloEsValido dePais:pais];
    [episodiosADevolver addObjectsFromArray:episodiosDevueltosPorEpisodeList];
    
    //Comprobar si hay episodio en la lista y si no hay meter tba
    if(episodiosADevolver.count==0){
        EpisodioTemp *epTBA = [[EpisodioTemp alloc] init];
        epTBA.sid=serie.sid;
        epTBA.nombreEpisodio=@"TBA";
        epTBA.numEpisodio=@"-1";
        epTBA.hora=nil;
        [episodiosADevolver addObject:epTBA];
    }
    
    //dispatch_semaphore_signal(semaforoSeries);
    return episodiosADevolver;
}

- (Boolean)obtenerInformacionCapitulo:(EpisodioTemp*)episodio{
    NSXMLDocument *xmlDoc;
    NSError *err=nil;
    NSString *path=[[NSString alloc] initWithFormat:@"/feeds/episodeinfo.php?sid=%@",episodio.sid];
    NSURL *furl = [[NSURL alloc]initWithScheme:@"http" host:@"services.tvrage.com" path:path];
    if (!furl) {
        NSLog(@"Can't create an URL from file");
        return NO;
    }
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                    error:&err];
    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl
                                                      options:NSXMLDocumentTidyXML
                                                        error:&err];
    }
    if (xmlDoc == nil)  {
        if (err) {
            NSLog(@"ErrorObtenerInfo 1 %@",err);
            return NO;
        }
        NSLog(@"ErrorObtenerInfo 3");
        return NO;
    }
    
    if (err) {
        NSLog(@"ErrorObtenerInfo 2 %@",err);
        return NO;
    }
    
    //Esto ya es parte del flujo
    episodio.nombreEpisodio=@"TBA";
    episodio.numEpisodio=@"-1";
    episodio.hora=nil;
    
    NSArray *nodes = [xmlDoc nodesForXPath:@"//show/nextepisode"
                                     error:&err];
    
    if([nodes count]>=1){
        NSXMLElement *elementNextEpisode = [nodes objectAtIndex:0];
        nodes = [elementNextEpisode elementsForName:@"airtime"];//Buscamos la fecha en que sale
        NSArray *hijos;
        NSXMLElement *informacion;
        for (NSXMLElement *elementAirtime in nodes) {
            //NSXMLNode=[elementAirtime attributeForName:@"airtime"];
            NSXMLNode *nodo=[elementAirtime attributeForName:@"format"];
            if([[nodo stringValue] isEqualToString:@"RFC3339"]){
                //NSLog(@"%@",[elementAirtime.children objectAtIndex:0]);
                NSString *horaString = [[NSString alloc] initWithFormat:@"%@",[elementAirtime.children objectAtIndex:0]];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                
                NSDate *date;
                NSError *error;
                [formatter getObjectValue:&date forString:horaString range:nil error:&error];
                
                episodio.hora=date;
                
                hijos=[elementNextEpisode elementsForName:@"title"];
                informacion=[hijos objectAtIndex:0];
                episodio.nombreEpisodio=[[NSString alloc] initWithFormat:@"%@",[informacion.children objectAtIndex:0]];
                
                hijos=[elementNextEpisode elementsForName:@"number"];
                informacion=[hijos objectAtIndex:0];
                episodio.numEpisodio=[[NSString alloc] initWithFormat:@"%@",[informacion.children objectAtIndex:0]];
                
            }
        }
    }
    return YES;
}






- (IBAction)anadir:(id)sender {
    [self.popover showRelativeToRect:[self.botonAnadir bounds]
                              ofView:self.botonAnadir
                       preferredEdge:NSMaxYEdge];
}

- (IBAction)recargarImagen:(id)sender {//pasarlo al nuevo modelo
    NSIndexSet *set=[self.tableviewPrincipal selectedRowIndexes];
    NSArray *episodios;
    if(self.segmentedControl.selectedSegment==1){//anteriores
        episodios=[anteriores objectsAtIndexes:set];
    }else{
        episodios =[proximos objectsAtIndexes:set];
    }
    if(episodios.count<1){
        return;
    }
    NSMutableArray *seriesARecargar=[[NSMutableArray alloc]init];
    for(Episodio* ep in episodios){
        if(![seriesARecargar containsObject:ep.serie]){
            [seriesARecargar addObject:ep.serie];
        }
    }

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//hace falta??
        NSMutableDictionary *miniaturas=[[NSMutableDictionary alloc]init];
        for(Serie* serie in seriesARecargar){
            if(serie.idTVdb==nil){
                continue;
            }
            TheTVDBBanners *banners = [[TheTVDBBanners alloc]initWithID:serie.idTVdb.intValue];
            [miniaturas setObject:banners.getImagenMiniaturaMejorValorada forKey:serie.sid];
            NSData *poster=banners.getDataPosterMejorValorado;
            //Guardamos la imagen en disco
            BOOL exito=[gestorFicheros guardarPosterConData:poster conSid:serie.sid];
            if(!exito){
                NSLog(@"Error al guardar imagen de %@",serie.serie);
            }
        }
        
        //SC
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        
        NSManagedObjectContext *context = [self managedObjectContext];
        
        for(Serie* serie in seriesARecargar){
            NSImage *miniatura=[miniaturas objectForKey:serie.sid];
            if(miniatura!=nil){
                serie.miniatura=[miniatura TIFFRepresentation];
            }
        }
        
        NSError *error;
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        dispatch_semaphore_signal(semaforoSeries);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{//Recargo todo, pero mantengo seleccionado lo que estaba antes
            
            //Otra opcion es calcular todos los episodios que se modificaron y recargar solo esos
            NSIndexSet *indices=[self.tableviewPrincipal selectedRowIndexes];
            [self.tableviewPrincipal reloadData];
            [self.tableviewPrincipal selectRowIndexes:indices byExtendingSelection:NO];
        });
        
    });
}

- (IBAction)completarDatos:(id)sender {
    //Ahora esto es pruebas del nuevo recargar
    NSIndexSet *set=[self.tableviewPrincipal selectedRowIndexes];
    NSArray *episodios =[proximos objectsAtIndexes:set];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for(Episodio *ep in episodios){
            NSLog(@"Pruebo en %@",ep.serie.serie);
            [self actualizarSerie:ep.serie];
            
            
        }
    });
}

-(void)mostrarInfoDeSerie:(NSIndexSet *)indices{
    NSArray *episodios;
    if(self.segmentedControl.selectedSegment==1){//anteriores
        episodios=[anteriores objectsAtIndexes:indices];
    }else{
        episodios =[proximos objectsAtIndexes:indices];
    }
    if(episodios.count>0){
        Episodio *ep=[episodios objectAtIndex:0];
        ventanaSerie=[[ControladorVentanaSecundaria alloc]initWithSerie:ep.serie];
        [ventanaSerie showWindow:self];
    }
}

- (IBAction)mostrarInfoSerie:(id)sender {
    NSIndexSet *set=[self.tableviewPrincipal selectedRowIndexes];
    NSArray *episodios;
    if(self.segmentedControl.selectedSegment==0){//Proximos
        episodios =[proximos objectsAtIndexes:set];
    }else{//Anteriores
        episodios=[anteriores objectsAtIndexes:set];
    }
    
    if(episodios.count>0){
        Episodio *ep=[episodios objectAtIndex:0];
        ventanaSerie=[[ControladorVentanaSecundaria alloc]initWithSerie:ep.serie];
        [ventanaSerie showWindow:self];
    }
    
}

- (IBAction)muestraBusquedaEpisodioSeleccionado:(id)sender{
    NSIndexSet *indices=[self.tableviewPrincipal selectedRowIndexes];
    [self muestraBusquedaEpisodio:indices];
}

- (IBAction)descargaEpisodioSeleccionado:(id)sender {
    NSIndexSet *indices=[self.tableviewPrincipal selectedRowIndexes];
    [self descargaEpisodio:[[NSMutableArray alloc]initWithArray:[anteriores objectsAtIndexes:indices]]];
}
- (IBAction)descargaSubtituloSeleccionado:(id)sender{
    NSIndexSet *indices=[self.tableviewPrincipal selectedRowIndexes];
    [self descargaSubtitulo:[[NSMutableArray alloc]initWithArray:[anteriores objectsAtIndexes:indices]]];
}
- (void)muestraBusquedaEpisodio:(NSIndexSet*)indices{
    NSArray *episodios = [anteriores objectsAtIndexes:indices];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Episodio *ep in episodios){
            //ep.avisado=@YES;
            [ep mostrarBusquedaEpisodio];
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        dispatch_semaphore_signal(semaforoSeries);
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal reloadDataForRowIndexes:indices columnIndexes:[[NSIndexSet alloc]initWithIndex:0]];
            });
        }
        //dispatch_async(dispatch_get_main_queue(), ^{
            [self refrescarBadge];
        //});
        
    });
}
- (void)descargaSubtitulo:(NSMutableArray*)episodiosABajar{
    //NSMutableArray *episodiosABajar = [[NSMutableArray alloc]initWithArray:[anteriores objectsAtIndexes:indices]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [gestorNotificaciones inicioDeDescargarSubtitulos];
        NSMutableArray *descargados = [[NSMutableArray alloc]init];
        
        //Descargamos el sub solo del primero para dar tiempo a que se abra el programa
        if(episodiosABajar.count>0){
            Episodio * ep =[episodiosABajar objectAtIndex:0];
            [episodiosABajar removeObject:ep];
            Boolean exito=[ep descargarSub];
            if(exito){
                [descargados addObject:ep];
            }
            [NSThread sleepForTimeInterval:3];//Duerme para dar tiempo a que se abra el programa
        }
        //Descargamos el resto
        for(Episodio *ep in episodiosABajar){
            Boolean exito=[ep descargarSub];
            if(exito){
                [descargados addObject:ep];
            }
            [NSThread sleepForTimeInterval:0.1];
        }
        
        //Actualizamos el estado de los subtitulos y refrescamos la lista en pantalla y la badge
        
        //SC(Por hacer cambios en datos de core data)
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Episodio *ep in descargados){
            ep.avisadoSub=@YES;
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        //Gestor de notificaciones, informacion para subs
//        int subNuevos=0;
//        NSString *nombreSerie=nil;
//        Boolean mismaSerie=YES;
//        for(Episodio* ep in anteriores){
//            if(ep.urlSub!=nil&&ep.avisadoSub.boolValue==NO){
//                subNuevos++;
//                if(mismaSerie){
//                    if(nombreSerie==nil){
//                        nombreSerie=ep.serie.getNombreAMostrar;
//                    }else{
//                        if(![nombreSerie isEqualToString:ep.serie.getNombreAMostrar]){
//                            mismaSerie=NO;
//                            nombreSerie=nil;
//                        }
//                    }
//                }
//            }
//        }
        
        NSDictionary *subs=[self snippetNumeroYNombreDeSubNuevos];
        [gestorNotificaciones finDeDescargarSubtitulosConSubtitulosNuevos:[(NSNumber*)[subs objectForKey:@"numero"] intValue] serieDeSubNuevos:[subs objectForKey:@"nombre"]];
        
        dispatch_semaphore_signal(semaforoSeries);
        //Fin SC
        
        //Refrescar lista
        NSMutableIndexSet *indices=[[NSMutableIndexSet alloc]init];
        for(Episodio *ep in descargados){
            NSUInteger index = [anteriores indexOfObject:ep];
            if(index !=NSNotFound){
                [indices addIndex:[anteriores indexOfObject:ep]];
            }
        }
        
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal reloadDataForRowIndexes:indices columnIndexes:[[NSIndexSet alloc]initWithIndex:0]];
            });
        }
        
        [self refrescarBadge];
    });
    
}
-(void)descargaEpisodio:(NSMutableArray*)episodiosABajar{
    //NSMutableArray *episodiosABajar = [[NSMutableArray alloc]initWithArray:[anteriores objectsAtIndexes:indices]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [gestorNotificaciones inicioDeDescargarTorrents];
        NSMutableArray *descargados = [[NSMutableArray alloc]init];
        if(episodiosABajar.count>0){
            Episodio * ep =[episodiosABajar objectAtIndex:0];
            [episodiosABajar removeObject:ep];
            Boolean exito=[ep descargarEpisodio];
            if(exito){
                [descargados addObject:ep];
            }
            [NSThread sleepForTimeInterval:3];//Duerme para dar tiempo a que se abra el programa de los torrent,3segundos
        }
        for(Episodio *ep in episodiosABajar){
            Boolean exito=[ep descargarEpisodio];
            if(exito){
                [descargados addObject:ep];
            }
            [NSThread sleepForTimeInterval:0.1];
        }
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Episodio *ep in descargados){
            ep.avisado=@YES;
            
            if(ep.releaseGroup!=nil){//Parte para mantener la informacion de epDescargado(para subs)
                ep.releaseGroupEpDescargado=[[NSString alloc]initWithString:ep.releaseGroup];
                if(ep.urlSubSupuesto!=nil){
                    ep.urlSubSupuestoEpDescargado=[[NSString alloc]initWithString:ep.urlSubSupuesto];
                }else{
                    ep.urlSubSupuestoEpDescargado=nil;
                }
            }else{
                ep.releaseGroupEpDescargado=nil;
                ep.urlSubSupuestoEpDescargado=nil;
            }
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        //Gestor de notificaciones
//        int epNuevos=0;
//        NSString *nombreSerie=nil;
//        Boolean mismaSerie=YES;
//        for(Episodio* ep in anteriores){
//            if(ep.magnetLink!=nil&&ep.avisado.boolValue==NO){
//                epNuevos++;
//                if(mismaSerie){
//                    if(nombreSerie==nil){
//                        nombreSerie=ep.serie.getNombreAMostrar;
//                    }else{
//                        if(![nombreSerie isEqualToString:ep.serie.getNombreAMostrar]){
//                            mismaSerie=NO;
//                            nombreSerie=nil;
//                        }
//                    }
//                }
//            }
//        }
        
        NSDictionary *eps=[self snippetNumeroYNombreDeEpNuevos];
        [gestorNotificaciones finDeDescargarTorrentsConEpisodiosNuevos:[(NSNumber*)[eps objectForKey:@"numero"] intValue]
                                                       serieDeEpNuevos:[eps objectForKey:@"nombre"]];
        
        dispatch_semaphore_signal(semaforoSeries);
        
        NSMutableIndexSet *indices=[[NSMutableIndexSet alloc]init];
        for(Episodio *ep in descargados){
            NSUInteger index = [anteriores indexOfObject:ep];
            if(index !=NSNotFound){
                [indices addIndex:[anteriores indexOfObject:ep]];
            }
        }
        
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal reloadDataForRowIndexes:indices columnIndexes:[[NSIndexSet alloc]initWithIndex:0]];
            });
        }
        
        [self refrescarBadge];
    });
}

- (IBAction)mostrarBusquedaEpisodiosPendientes:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for (Episodio *ep in anteriores){
            if([ep.avisado boolValue]==NO){
                //ep.avisado=@YES;//No es bool, es NSNumber
                [ep mostrarBusquedaEpisodio];
            }
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        dispatch_semaphore_signal(semaforoSeries);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableviewPrincipal reloadData];
        });
        //[[[NSApplication sharedApplication] dockTile]setBadgeLabel:@""];
        [self refrescarBadge];//SE hace su propio hilo y se coge sus semaforors
        NSLog(@"Salgo");
    });
}


-(void)descargaEpisodioConIndices:(NSIndexSet*)indices{
    NSMutableArray *episodiosABajar = [[NSMutableArray alloc]initWithArray:[anteriores objectsAtIndexes:indices]];
    [self descargaEpisodio:episodiosABajar];
}
-(void)descargaSubtituloConIndices:(NSIndexSet *)indices{
    NSMutableArray *episodiosABajar = [[NSMutableArray alloc]initWithArray:[anteriores objectsAtIndexes:indices]];
    [self descargaSubtitulo:episodiosABajar];
}
- (IBAction)descargarSubsPendientes:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSMutableArray *epABajar = [[NSMutableArray alloc]init];
        
        for (Episodio *ep in anteriores){
            if(ep.urlSub!=nil){
                if([ep.avisadoSub boolValue]==NO){
                    [epABajar addObject:ep];
                }
            }
        }
        dispatch_semaphore_signal(semaforoSeries);
        [self descargaSubtitulo:epABajar];

    });
    
    //VIejo, lo hace aqui en vez de llamar al otro
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
//        NSManagedObjectContext *context = [self managedObjectContext];
//        NSError *error;
//        
//        for (Episodio *ep in anteriores){
//            if(ep.urlSub!=nil){
//                if([ep.avisadoSub boolValue]==NO){
//                    ep.avisadoSub=@YES;//No es bool, es NSNumber
//                    [ep descargarSub];
//                }
//            }
//        }
//        
//        if (![context save:&error]) {//Se guarda el cambio en coredata
//            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
//        }
//        dispatch_semaphore_signal(semaforoSeries);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableviewPrincipal reloadData];
//            [self refrescarBadge];
//        });
//    });
    
}

- (IBAction)descargarEpisodiosPendientes:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSMutableArray *epABajar = [[NSMutableArray alloc]init];
        
        for (Episodio *ep in anteriores){
            if(ep.magnetLink!=NULL&&ep.avisado.boolValue==NO){
                [epABajar addObject:ep];
            }
        }
        dispatch_semaphore_signal(semaforoSeries);
        [self descargaEpisodio:epABajar];
        
    });
    
    
    //Lo viejo, lo hacia aqui en vez del otro(estaba el codigo repetido) Borrar si todo funciona
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSArray *episodios = [[NSArray alloc]initWithArray:anteriores];
//        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
//        
//        NSMutableArray *episodiosABajar=[[NSMutableArray alloc]init];
//        for(Episodio *ep in episodios){
//            if(ep.magnetLink!=NULL&&ep.avisado.boolValue==NO){
//                [episodiosABajar addObject:ep];
//                ep.avisado=@YES;
//            }
//        }
//        dispatch_semaphore_signal(semaforoSeries);
//        NSMutableArray *descargados = [[NSMutableArray alloc]init];
//        NSMutableArray *conErrores =[[NSMutableArray alloc]init];
//        if(episodiosABajar.count>0){
//            Episodio * ep =[episodiosABajar objectAtIndex:0];
//            [episodiosABajar removeObject:ep];
//            Boolean exito=[ep descargarEpisodio];
//            if(exito){
//                [descargados addObject:ep];
//            }else{
//                [conErrores addObject:ep];
//            }
//            [NSThread sleepForTimeInterval:3];//Duerme para dar tiempo a que se abra el programa de los torrent,3segundos
//        }
//        for(Episodio *ep in episodiosABajar){
//            Boolean exito=[ep descargarEpisodio];
//            if(exito){
//                [descargados addObject:ep];
//            }else{
//                [conErrores addObject:ep];
//            }
//            [NSThread sleepForTimeInterval:0.1];
//        }
//        //Los que fallaron los marco como no descargados
//        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
//        
//        for(Episodio *ep in conErrores){
//                ep.avisado=@NO;
//        }
//        dispatch_semaphore_signal(semaforoSeries);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableviewPrincipal reloadData];
//            [self refrescarBadge];
//        });
//    });
}
- (IBAction)marcarTodoComoDescargado:(id)sender{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for (Episodio *ep in anteriores){
            ep.avisado=@YES;
            if(ep.urlSub!=nil){
                ep.avisadoSub=@YES;
            }
        }
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        [gestorNotificaciones actualizarTodoComoDescargado];
        
        dispatch_semaphore_signal(semaforoSeries);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableviewPrincipal reloadData];
            [self refrescarBadge];
        });
        //[[[NSApplication sharedApplication] dockTile]setBadgeLabel:@""];
    });
}

- (IBAction)marcarEpSeleccionadoComoDescargado:(id)sender {
    NSIndexSet *indicesSeleccionados=[self.tableviewPrincipal selectedRowIndexes];
    [self setEpisodioDescargadoA:YES paraEpisodios:indicesSeleccionados];
}

- (IBAction)marcarEpSeleccionadoComoNoDescargado:(id)sender {
    NSIndexSet *indicesSeleccionados=[self.tableviewPrincipal selectedRowIndexes];
    [self setEpisodioDescargadoA:NO paraEpisodios:indicesSeleccionados];
}

-(void)eliminarEpisodiosConIndices:(NSIndexSet *)indices{
    NSArray *episodios=[anteriores objectsAtIndexes:indices];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Episodio *ep in episodios){
            NSLog(@"Eliminando %@ de %@",ep.nombreEpisodio,ep.serie.serie);
            [gestorFicheros eliminarTorrentDeEpisodio:ep];
            [context deleteObject:ep];
            [anteriores removeObject:ep];//elimino de array
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        //Gestor de notificaciones
        [self snippetRefrescarNumeroEpySubsGestorDeNotificaciones];
        
        dispatch_semaphore_signal(semaforoSeries);
        
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal removeRowsAtIndexes:indices withAnimation:NSTableViewAnimationEffectGap];
            });
        }
        
        [self refrescarBadge];
    });
}

- (void)setExcluirBusquedaEpA:(Boolean)excluir paraEpisodios:(NSIndexSet *)indices{
    NSArray *episodios=[anteriores objectsAtIndexes:indices];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Episodio *ep in episodios){
            ep.excluirBusquedaEp=[[NSNumber alloc]initWithBool:excluir];
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //Gestor de notificaciones, torrents
        [self snippetRefrescarNumeroEpisodiosGestorDeNotificaciones];
        
        dispatch_semaphore_signal(semaforoSeries);
        
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal reloadDataForRowIndexes:indices columnIndexes:[[NSIndexSet alloc]initWithIndex:0]];
            });
        }
        
        [self refrescarBadge];
        
    });
}

-(void)setExcluirBusquedaSubA:(Boolean)excluir paraEpisodios:(NSIndexSet *)indices{
    NSArray *episodios=[anteriores objectsAtIndexes:indices];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Episodio *ep in episodios){
            ep.excluirBusquedaSub=[[NSNumber alloc]initWithBool:excluir];
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        //Gestor de notificaciones, torrents
        [self snippetRefrescarNumeroSubsGestorDeNotificaciones];
        
        dispatch_semaphore_signal(semaforoSeries);
        
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal reloadDataForRowIndexes:indices columnIndexes:[[NSIndexSet alloc]initWithIndex:0]];
            });
        }
        
        [self refrescarBadge];
        
    });
}

- (void)setEpisodioDescargadoA:(Boolean)avisado paraEpisodios:(NSIndexSet*)indices{
    NSArray *episodios=[anteriores objectsAtIndexes:indices];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Episodio *ep in episodios){
            ep.avisado=[[NSNumber alloc]initWithBool:avisado];
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        //Gestor de notificaciones, torrents
        [self snippetRefrescarNumeroEpisodiosGestorDeNotificaciones];

        dispatch_semaphore_signal(semaforoSeries);
        
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal reloadDataForRowIndexes:indices columnIndexes:[[NSIndexSet alloc]initWithIndex:0]];
            });
        }
        
        [self refrescarBadge];
    });
}

- (IBAction)marcarSubSeleccionadoComoDescargado:(id)sender {
    NSIndexSet *indicesSeleccionados=[self.tableviewPrincipal selectedRowIndexes];
    [self setSubDescargadoA:YES paraEpisodios:indicesSeleccionados];
}

- (IBAction)marcarSubSeleccionadoComoNoDescargado:(id)sender {
    NSIndexSet *indicesSeleccionados=[self.tableviewPrincipal selectedRowIndexes];
    [self setSubDescargadoA:NO paraEpisodios:indicesSeleccionados];
}

- (void)setSubDescargadoA:(Boolean)avisadoSub paraEpisodios:(NSIndexSet*)indices{
    NSArray *episodios=[anteriores objectsAtIndexes:indices];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        for(Episodio *ep in episodios){
            if (ep.urlSub!=nil){
                ep.avisadoSub=[[NSNumber alloc]initWithBool:avisadoSub];
            }
        }
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        

        [self snippetRefrescarNumeroSubsGestorDeNotificaciones];
        //Viejo
//        int subNuevos=0;
//        NSString *nombreSerie=nil;
//        Boolean mismaSerie=YES;
//        for(Episodio* ep in anteriores){
//            if(ep.urlSub!=nil&&ep.avisadoSub.boolValue==NO){
//                subNuevos++;
//                if(mismaSerie){
//                    if(nombreSerie==nil){
//                        nombreSerie=ep.serie.getNombreAMostrar;
//                    }else{
//                        if(![nombreSerie isEqualToString:ep.serie.getNombreAMostrar]){
//                            mismaSerie=NO;
//                            nombreSerie=nil;
//                        }
//                    }
//                }
//            }
//        }
//        [gestorNotificaciones actualizarSubtitulosNuevosConSubtitulosNuevos:subNuevos serieDeSubNuevos:nombreSerie];
        
        dispatch_semaphore_signal(semaforoSeries);
        
        
        if([self.segmentedControl selectedSegment]==1){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableviewPrincipal reloadDataForRowIndexes:indices columnIndexes:[[NSIndexSet alloc]initWithIndex:0]];
            });
        }
        
        
        //dispatch_async(dispatch_get_main_queue(), ^{//creo que refrescar badge ya coge su propio hilo
            [self refrescarBadge];
        //});
    });
}

- (IBAction)buscarTorrent:(id)sender {//Hay que llamarlo desde un hilo
    //TO DO: hacer notificiaciones como en buscar subs, para que al terminar si aparece algo nuevo(o aparece un proper) sacar una notificacion
    
    [gestorNotificaciones inicioDeBuscarTorrents];
    
    NSMutableArray *epABuscar=[[NSMutableArray alloc]init];
    
    NSMutableArray *descargasAGuardar=[[NSMutableArray alloc]init];
    NSMutableArray *epConProperNuevo=[[NSMutableArray alloc]init];//Esto es para notificaciones y actualizar el valor del bool hayProper del episodio y poner avisado a 0
    NSMutableArray *epNotificacion=[[NSMutableArray alloc]init];
    NSMutableArray *epAPararDeBuscar=[[NSMutableArray alloc] init];
    
    //Cogemos los episodios de los cuales vamos a buscar torrents
    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
    for (Episodio *ep in anteriores){
        if(ep.excluirBusquedaEp.boolValue){//Si esta ep en concreto no se busca se pasa
            continue;
        }
        if(([[NSDate date] timeIntervalSinceDate:ep.fechaInclusionEnAnteriores]<24*60*60)||ep.magnetLink==NULL||ep.seguirBuscando.boolValue){
            if((ep.serie.descargaAutomaticaEp==nil)||ep.serie.descargaAutomaticaEp.boolValue==YES){
                [epABuscar addObject:ep];
            }
            
            //NSLog(@"Anado serie %@",ep.serie.serie);
        }
    }
    dispatch_semaphore_signal(semaforoSeries);
    
    for(Episodio *ep in epABuscar){
        DescargaTemp *descarga=[ep buscarTorrent];
        if(descarga==nil){
            NSLog(@"%@ %@ NIL",ep.serie.serie,ep.numEpisodio);
        }
        if(descarga!=nil){
            
            NSLog(@"%@->%@<-",descarga.nombre,descarga.releaseGroup);
            //Ep con proper nuevo
            if(!ep.hayProper){
                [epConProperNuevo addObject:ep];//Si antes no habia proper va a haber que notificar y cambiar el bool y poner avisado a 0
            }
            //Ep a finalizar busqueda
            //Por ahora vamos a para de buscar si es mas viejo de un dia
            if([[NSDate date] timeIntervalSinceDate:ep.fechaInclusionEnAnteriores]>24*60*60){
                [epAPararDeBuscar addObject:ep];
            }
            //Descarga a guardar
            if(!descarga.esMagnet){
                //NSLog(@"asdad%@",descarga.urlTorrent);
                BOOL result=[gestorFicheros guardarTorrentDeEpisodio:ep ConURL:descarga.urlTorrent];
                if(!result){
                    NSLog(@"Hubo error guardando un ep");
                }
            }
            
            [descargasAGuardar addObject:descarga];
        }
    }
    
    //Empezamos a modificar los datos
    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    
    //Guardamos las descargas
    for(DescargaTemp *descarga in descargasAGuardar){
        descarga.episodio.esMagnet=[NSNumber numberWithBool:descarga.esMagnet];
        descarga.episodio.nombreDescarga=descarga.nombre;
        if(!descarga.esMagnet){
            descarga.episodio.magnetLink=descarga.urlTorrent;
        }else{
           descarga.episodio.magnetLink=descarga.magnetLink;
        }
        //Si no son los mismos de antes
        if(![descarga.episodio.releaseGroup isEqualToString:descarga.releaseGroup]){
            descarga.episodio.releaseGroup=descarga.releaseGroup;
            descarga.episodio.urlSubSupuesto=nil;//Cambio el release group-> el sub no vale
        }
        //NSLog(@"%@",descarga.releaseGroup);
        //NSLog(@"%@",descarga.episodio);
        //NSLog(@"%@",descarga.episodio.serie);
    }
    
    //Tratamos con los nuevos proper
    for(Episodio *ep in epConProperNuevo){
        ep.hayProper=@YES;
        ep.avisado=@NO;
    }
    
    //Eliminamos el boolean de seguir buscando
    for(Episodio *ep in epAPararDeBuscar){
        ep.seguirBuscando=@NO;
    }
    
    if (![context save:&error]) {//Se guarda el cambio en coredata
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    //Gestor de notificaciones
//    int epNuevos=0;
//    NSString *nombreSerie=nil;
//    Boolean mismaSerie=YES;
//    for(Episodio* ep in anteriores){
//        if(ep.magnetLink!=nil&&ep.avisado.boolValue==NO){
//            epNuevos++;
//            if(mismaSerie){
//                if(nombreSerie==nil){
//                    nombreSerie=ep.serie.getNombreAMostrar;
//                }else{
//                    if(![nombreSerie isEqualToString:ep.serie.getNombreAMostrar]){
//                        mismaSerie=NO;
//                        nombreSerie=nil;
//                    }
//                }
//            }
//        }
//    }
    NSDictionary* eps=[self snippetNumeroYNombreDeEpNuevos];
    [gestorNotificaciones finDeBuscarTorrentsConEpisodiosNuevos:[(NSNumber*)[eps objectForKey:@"numero"] intValue]
                                                serieDeEpNuevos:[eps objectForKey:@"nombre"]];
    
    dispatch_semaphore_signal(semaforoSeries);
    NSLog(@"Terminada busqueda de torrents");
    
    //Notificaciones,casos
    if(epConProperNuevo.count==1&&epNotificacion.count==0){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Episodio corregido disponible";
        notification.informativeText = [NSString stringWithFormat:@"Hay disponible una versión corregida de %@",((Episodio *)[epConProperNuevo objectAtIndex:0]).serie.serie];
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }else if(epConProperNuevo.count==0&&epNotificacion.count==1){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Episodio disponible";
        notification.informativeText = [NSString stringWithFormat:@"Hay disponible un nuevo episodio de %@",((Episodio *)[epNotificacion objectAtIndex:0]).serie.serie];
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }else if(epConProperNuevo.count>0||epNotificacion.count>0){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Episodios disponibles";
        notification.informativeText = [NSString stringWithFormat:@"Hay disponibles %lu nuevos episodios",epConProperNuevo.count+epNotificacion.count];
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
    
}

- (IBAction)debugVentanaAnadir:(id)sender {
    ventanaAnadir=[[VentanaAnadir alloc]init];
    [ventanaAnadir showWindow:self];
}

- (IBAction)debugPonerTodoASubEs:(id)sender {
    contadorParaSubEs++;
    
    if(contadorParaSubEs>5){
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        NSManagedObjectContext *context = [self managedObjectContext];
        NSError *error;
        
        for(Serie *serie in series){
            serie.buscadorSubtitulos=[NSNumber numberWithInt:SubtitulosES];
        }
        
        if (![context save:&error]) {//Se guarda el cambio en coredata
            NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        }
        
        dispatch_semaphore_signal(semaforoSeries);
        contadorParaSubEs=0;
    }
}

- (IBAction)abrirPreferencias:(id)sender {
    [gestorOpciones mostrarPanelOpciones];
    
    //NSURL* url=[NSURL URLWithString:@"file:///Users/Alex/Movies/"];
//    ventanaPreferencias=[[VentanaPreferencias alloc]initWithDirectorioSubs:gestorFicheros.directorioSubs];
//    [ventanaPreferencias showWindow:self];
}


- (void) refrescarBadge{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int numeroBadge=0;
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        for(Episodio *ep in anteriores){
            if((ep.magnetLink!=nil && ![ep.avisado boolValue])||(ep.urlSub!=nil && ![ep.avisadoSub boolValue])){
                numeroBadge++;
            }
        }
        dispatch_semaphore_signal(semaforoSeries);
        
        if(numeroBadge==0){
            [[[NSApplication sharedApplication] dockTile]setBadgeLabel:@""];
        }else{
            [[[NSApplication sharedApplication] dockTile]setBadgeLabel:[NSString stringWithFormat:@"%d",numeroBadge]];
        }
    });
        
}

- (void) refrescarTimer{
    NSLog(@"Refrescar timer");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
        //Compruebo episodios pasados
        [self comprobarEpisodiosAntiguos];//No se llama al semaforo dentro porque se hace todo de una tacada
        dispatch_semaphore_signal(semaforoSeries);
        [self buscarTorrent:self];//Aqui ya se llama al semaforo dentro porque hay que esperar un tiempo a obtener las paginas
        [self refrescarBadge];//Se crea un hilo dentro y se llama al semaforo
        [self buscarSubs];//Aqui ya se llama al semaforo dentro porque hay que esperar un tiempo a buscar los subs
        [self refrescarBadge];
        dispatch_async(dispatch_get_main_queue(), ^{//Pasar a dentro de cada metodo
            [self.tableviewPrincipal reloadData];
        });
    });
}



//Datamodel de tabla
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    if([tableView.identifier isEqualToString:@"tableviewBusqueda"]){
        // Get a new ViewCell
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
        
        // Since this is a single-column table view, this would not be necessary.
        // But it's a good practice to do it in order by remember it when a table is multicolumn.
        
        TVRageSerie *serie = [busqueda objectAtIndex:row];
        cellView.textField.stringValue = [[NSString alloc] initWithFormat:@"%@ %@ %@",serie.nombre,serie.pais,serie.ano];
        return cellView;
    }else if ([tableView.identifier isEqualToString:@"tableviewPrincipal"]){
        Episodio *ep;
        
        if(self.segmentedControl.selectedSegment==1){//Vista de anteriores
            ep = [anteriores objectAtIndex:row];
        }else{//Vista de siguientes
            ep = [proximos objectAtIndex:row];
        }
        //NSLog(@"Id:%@ y row %ld, serie es %@ y ep es %@",tableView.identifier,row,ep.serie.serie,ep.nombreEpisodio);
        //result.nombreSerie.stringValue = ep.serie.serie;
        NSString *nombreSerie=ep.serie.serie;
        if(ep.serie.nombreParaMostrar!=nil){
            nombreSerie=ep.serie.nombreParaMostrar;
        }
        NSString *numCapitulo;
        NSString *nombreCapitulo;
        NSString *fechaEmision;
        NSString *dias;
        NSString *horas;
        
        if([ep.nombreEpisodio isEqualToString:@"TBA"] && [ep.numEpisodio isEqualToString:@"-1"]){
            numCapitulo=@"";
            nombreCapitulo=@"";
            fechaEmision=@"";
            dias=@"TBA";
            horas=@"";
            
        }else{
            numCapitulo = ep.numEpisodio;
            nombreCapitulo = ep.nombreEpisodio;
            fechaEmision= ep.horaString;
            horas = [[NSString alloc] initWithFormat:@"%ld horas",ep.horasRestantes];
            dias = [[NSString alloc] initWithFormat:@"%ld dias",ep.diasRestantes];
        }
        NSImage *imagen=[[NSImage alloc] initWithData:ep.serie.miniatura];
        
        if(self.segmentedControl.selectedSegment==1){//Vista de anteriores
            CeldaAnteriorSub *result = [tableView makeViewWithIdentifier:@"celdaAnteriorSub2" owner:self];
            result.nombreSerie.stringValue=nombreSerie;
            result.numCapitulo.stringValue=numCapitulo;
            result.nombreCapitulo.stringValue=nombreCapitulo;
            result.fechaEmision.stringValue=fechaEmision;
            result.dias.stringValue=dias;
            result.horas.stringValue=horas;
            
            result.imageView.image=imagen;
            NSMenu *theMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
            int indiceMenu=0;
            
            if(ep.magnetLink!=nil){//Descargar ep, menu
            [theMenu insertItemWithTitle:@"Descargar episodio" action:@selector(descargarEp) keyEquivalent:@"d" atIndex:indiceMenu];
                indiceMenu++;
            }
            
            if(ep.urlSub!=nil){//Descargar sub, menu
                [theMenu insertItemWithTitle:@"Descargar subtítulo" action:@selector(descargarSub) keyEquivalent:@"s" atIndex:indiceMenu];
                indiceMenu++;
            }
            [theMenu insertItemWithTitle:@"Mostrar búsqueda de episodio" action:@selector(mostrarBusquedaEp) keyEquivalent:@"" atIndex:indiceMenu];
            indiceMenu++;
            [theMenu insertItem:[NSMenuItem separatorItem] atIndex:indiceMenu];
            indiceMenu++;
            
            if(ep.serie.descargaAutomaticaEp.boolValue&&!ep.excluirBusquedaEp.boolValue){//Si se descargan los ep de esta serie
                result.banderaDescarga.hidden=NO;
                if(ep.magnetLink!=nil){
                    result.enableEp=YES;
                    if(ep.avisado.boolValue==NO){
                        //Aqui dentro se mira si en proper
                        result.banderaDescarga.image=[NSImage imageNamed:@"DescargaAzulPNG"];
                        if(ep.nombreDescarga!=nil){
                            result.banderaDescarga.toolTip=ep.nombreDescarga;
                        }else{
                            result.banderaDescarga.toolTip=@"Episodio no descargado";
                        }
                        
                        [theMenu insertItemWithTitle:@"Marcar episodio como descargado" action:@selector(marcarEpDescargado) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }else{
                        //Aqui dentro se mira si es proper
                        result.banderaDescarga.image=[NSImage imageNamed:@"DescargaGrisPNG"];
                        if(ep.nombreDescarga!=nil){
                            result.banderaDescarga.toolTip=ep.nombreDescarga;
                        }else{
                            result.banderaDescarga.toolTip=@"Episodio descargado";
                        }
                        [theMenu insertItemWithTitle:@"Marcar episodio como no descargado" action:@selector(marcarEpNoDescargado) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }
                }else{
                    result.enableEp=NO;
                    result.banderaDescarga.toolTip=@"Episodio no disponible";
                    result.banderaDescarga.image=[NSImage imageNamed:@"DescargaGrisNoDisponiblePNG"];
                }
            }else{
                result.enableEp=NO;
                result.banderaDescarga.hidden=YES;
            }
            
            if(ep.serie.descargaAutomaticaSub.boolValue&&!ep.excluirBusquedaSub.boolValue){
                result.banderaSub.hidden=NO;
                if(ep.urlSub!=nil){
                    //[result.banderaSub setEnabled:YES];
                    result.enableSub=YES;
                    //[result.banderaSub setHidden:NO];
                    if([ep.avisadoSub boolValue]==NO){
                        result.banderaSub.image=[NSImage imageNamed:@"ccPNG"];
                        result.banderaSub.toolTip=@"Subtítulo no descargado";
                        [theMenu insertItemWithTitle:@"Marcar subtítulo como descargado" action:@selector(marcarSubDescargado) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }else{
                        result.banderaSub.image=[NSImage imageNamed:@"CCGrisPNG"];
                        result.banderaSub.toolTip=@"Subtítulo descargado";
                        [theMenu insertItemWithTitle:@"Marcar subtítulo como no descargado" action:@selector(marcarSubNoDescargado) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }
                }else{
                    //[result.banderaSub setEnabled:NO];
                    result.enableSub=NO;
                    //[result.banderaSub setHidden:YES];
                    result.banderaSub.toolTip=@"Subtítulo no disponible";
                    result.banderaSub.image=[NSImage imageNamed:@"CCGrisNoDisponiblePNG"];
                }
            }else{
                result.enableSub=NO;
                result.banderaSub.hidden=YES;
            }
            
            //Mas opciones para el menu!
            if(ep.serie.descargaAutomaticaSub.boolValue||ep.serie.descargaAutomaticaEp.boolValue){
                //Algo va a haber
                [theMenu insertItem:[NSMenuItem separatorItem] atIndex:indiceMenu];
                indiceMenu++;
                
                if(ep.serie.descargaAutomaticaEp.boolValue){
                    if(ep.excluirBusquedaEp.boolValue){
                        [theMenu insertItemWithTitle:@"Buscar este episodio" action:@selector(noExcluirBusquedaEp) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }else{
                        [theMenu insertItemWithTitle:@"Parar de buscar este episodio" action:@selector(excluirBusquedaEp) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }
                }
                if(ep.serie.descargaAutomaticaSub.boolValue){
                    if(ep.excluirBusquedaSub.boolValue){
                        [theMenu insertItemWithTitle:@"Buscar este subtítulo" action:@selector(noExcluirBusquedaSub) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }else{
                        [theMenu insertItemWithTitle:@"Parar de buscar este subtítulo" action:@selector(excluirBusquedaSub) keyEquivalent:@"" atIndex:indiceMenu];
                        indiceMenu++;
                    }
                }
                
            }
            
            //Eliminar Ep
            [theMenu insertItem:[NSMenuItem separatorItem] atIndex:indiceMenu];
            indiceMenu++;
            [theMenu insertItemWithTitle:@"Eliminar episodio de la lista" action:@selector(eliminarEp) keyEquivalent:@"" atIndex:indiceMenu];
            indiceMenu++;
            
            //Propiedades de serie
            [theMenu insertItem:[NSMenuItem separatorItem] atIndex:indiceMenu];
            indiceMenu++;
            [theMenu insertItemWithTitle:@"Propiedades de serie" action:@selector(mostrarInformacionSerie) keyEquivalent:@"i" atIndex:indiceMenu];
            indiceMenu++;
            [result setMenu:theMenu];
            
          
            return result;
        }else{//Vista de siguientes
            CeldaPrincipal *result = [tableView makeViewWithIdentifier:@"celdaSerie" owner:self];
            result.nombreSerie.stringValue=nombreSerie;
            result.numCapitulo.stringValue=numCapitulo;
            result.nombreCapitulo.stringValue=nombreCapitulo;
            result.fechaEmision.stringValue=fechaEmision;
            result.dias.stringValue=dias;
            result.horas.stringValue=horas;
            result.imageView.image=imagen;
            //NSLog(@"%@ %@",ep.serie.serie,ep);
            //NSLog(@"%@ : %@-%@, %@, dias %@ horas %@",nombreSerie,numCapitulo,nombreCapitulo,fechaEmision,dias,horas);
//            if(imagen==nil){
//                NSLog(@"imagen nil");
//            }
//            if(result==nil){
//                NSLog(@"Result nil");
//            }
            return result;
        }
        
    }
    return [[NSTableCellView alloc]init];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    //NSLog(@"Table view %@",tableView.identifier);
    if([tableView.identifier isEqualToString:@"tableviewBusqueda"]){
        return [busqueda count];
    }else if ([tableView.identifier isEqualToString:@"tableviewPrincipal"]){
        if(self.segmentedControl.selectedSegment==1){
            return [anteriores count];
        }
        return [proximos count];
    }
    return 0;
}

- (IBAction)cambioSegmentedControl:(NSSegmentedControl *)sender {
    [self.window makeKeyAndOrderFront:self];//Para que las notificaciones abran la ventana
    [self enableEliminar:NO];
    [self.menuMostrarInfoSerie setEnabled:NO];
    [self.menuRecargarImagen setEnabled:NO];
    [self enableMarcar:NO];
    [self.menuDescargarEpisodio setEnabled:NO];
    [self.menuDescargarSubtitulo setEnabled:NO];
    [self.menuMostrarBusquedaEpisodio setEnabled:NO];
    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
    [self comprobarEpisodiosAntiguos];
    dispatch_semaphore_signal(semaforoSeries);
    if(sender.selectedSegment==0){
        [self.tableviewPrincipal setAllowsMultipleSelection:NO];
    }else{
        [self.tableviewPrincipal setAllowsMultipleSelection:YES];
    }
    [self.tableviewPrincipal reloadData];
    [self tableViewSelectionDidChange:[NSNotification notificationWithName:@"Change" object:self.tableviewPrincipal]];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
    //Si la seleccion fue en la tabla de la busqueda
    if(aNotification.object==self.tableviewBusqueda){
        NSLog(@"busqueda");
        if(self.tableviewBusqueda.numberOfSelectedRows!=1){
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(!popoverSegundaExpansion){
                [CATransaction begin];//Todo esto es para que no de el error de uncommited catransaction
                NSSize tamano;
                tamano.height=398.0f;
                tamano.width=276.0f;
                [self.popover setContentSize:tamano];
                [CATransaction commit];
                popoverSegundaExpansion=YES;
            }
            
            NSLog(@"%@",self.controladorPopover);
            NSLog(@"%f %f",self.popover.contentSize.height,self.popover.contentSize.width);
            NSLog(@"%f %f",self.viewPopover.frame.size.height,self.viewPopover.frame.size.width);
        });
        
        
        [self.desplegableUltimoEpPopover removeAllItems];
        [self.desplegableUltimoEpPopover addItemWithTitle:@"Cargando episodios..."];
        serieBusquedaSeleccionada=[busqueda objectAtIndex:[self.tableviewBusqueda selectedRow]];
        TVRageSerie *serie=serieBusquedaSeleccionada;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            TVRageEpisodeInfo* tvRageEpisodeInfo=[[TVRageEpisodeInfo alloc]initWithSid:serie.sid];
            [tvRageEpisodeInfo parsear];
            EpisodioTemp* lastEpisode=tvRageEpisodeInfo.getLatestEpisode;
            TVRageEpisodeList* tvRageEpisodeList=[[TVRageEpisodeList alloc]initWithSid:serie.sid];
            [tvRageEpisodeList parsear];
            
            //Asegurarse de que la serie sigue seleccionada
            if(serieBusquedaSeleccionada.sid!=serie.sid){
                return;
            }
            
            NSMutableArray* episodiosAnterioes=[tvRageEpisodeList listaDeEpisodiosEmitidosConLatestEpisode:lastEpisode];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if(episodiosAnterioes.count<1){
                    [self.desplegableUltimoEpPopover removeAllItems];
                    [self.desplegableUltimoEpPopover addItemWithTitle:@"..."];
                }else{
                    NSArray *sortedArray;
                    sortedArray = [episodiosAnterioes sortedArrayUsingSelector:@selector(compareInv:)];
                    [self.desplegableUltimoEpPopover removeAllItems];
                    for(EpisodioTemp* ep in sortedArray){
                        NSString *titulo=[[NSString alloc]initWithFormat:@"%@ %@",ep.numEpisodio,ep.nombreEpisodio];
                        [self.desplegableUltimoEpPopover addItemWithTitle:titulo];
                    }
                    [self.desplegableUltimoEpPopover addItemWithTitle:@"0x00 (Aún no vi ninguno :O)"];
                }
            });
        });
    }
    else if(self.segmentedControl.selectedSegment==1){//Seleccionada vista de anteriores
        //[self.botonEliminar setEnabled:NO];
        //[self.menuEliminar setEnabled:NO];
        [self enableEliminar:NO];
        [self.menuRecargarImagen setEnabled:NO];
        if([self.tableviewPrincipal numberOfSelectedRows]>0){//Si hay filas seleccionadas
            //[controladorVistaDetalles mostrarAnteriores(NSArray)episodios]
            
            [self enableMarcar:YES];
            [self.menuMostrarBusquedaEpisodio setEnabled:YES];
            [self.menuMostrarInfoSerie setEnabled:YES];
            [self.menuDescargarSubtitulo setEnabled:YES];
            [self.menuDescargarEpisodio setEnabled:YES];
            NSLog(@"Anteriores: hay filas seleccionadas");
        }else{//No hay ninguna seleccionada
            [controladorVistaDetalles mostrarVistaStandby];
            
            [self enableMarcar:NO];
            [self.menuMostrarInfoSerie setEnabled:NO];
            [self.menuMostrarBusquedaEpisodio setEnabled:NO];
            [self.menuDescargarSubtitulo setEnabled:NO];
            [self.menuDescargarEpisodio setEnabled:NO];
            NSLog(@"Anteriores: no hay filas seleccionadas");
        }
        
    }
    else if([self.tableviewPrincipal selectedRow]>=0){//Seleccionada vista de proximos
        NSIndexSet* indices=self.tableviewPrincipal.selectedRowIndexes;
        NSArray* episodiosSel=[proximos objectsAtIndexes:indices];
        NSMutableArray* seriesSel=[[NSMutableArray alloc]init];
        for(Episodio *ep in episodiosSel){
            if(![seriesSel containsObject:ep.serie]){
                [seriesSel addObject:ep.serie];
            }
        }
        [controladorVistaDetalles mostrarVistaProximosCapitulos:seriesSel];
        
        //[self.botonEliminar setEnabled:YES];
        //[self.menuEliminar setEnabled:YES];
        [self enableEliminar:YES];
        [self.menuMostrarInfoSerie setEnabled:YES];
        [self enableMarcar:NO];
        [self.menuRecargarImagen setEnabled:YES];
        [self.menuMostrarBusquedaEpisodio setEnabled:NO];
        [self.menuDescargarSubtitulo setEnabled:NO];
        [self.menuDescargarEpisodio setEnabled:NO];
    }else{//proximos sin episodios seleccionados
        [controladorVistaDetalles mostrarVistaStandby];
        
        //[self.botonEliminar setEnabled:NO];
        //[self.menuEliminar setEnabled:NO];
        [self enableEliminar:NO];
        [self.menuMostrarInfoSerie setEnabled:NO];
        [self enableMarcar:NO];
        [self.menuRecargarImagen setEnabled:NO];
        [self.menuMostrarBusquedaEpisodio setEnabled:NO];
        [self.menuDescargarSubtitulo setEnabled:NO];
        [self.menuDescargarEpisodio setEnabled:NO];
    }
}
-(void)enableAnadir:(Boolean)enabled{
    [self.menuAnadir setEnabled:enabled];
    [self.botonAnadir setEnabled:enabled];
}
-(void)enableEliminar:(Boolean)enabled{
    [self.menuEliminar setEnabled:enabled];
    [self.botonEliminar setEnabled:enabled];
}
-(void)enableMarcar:(Boolean)enabled{
    [self.menuMarcarEp setEnabled:enabled];
    [self.menuMarcarSub setEnabled:enabled];
    [self.menuMarcarNoEp setEnabled:enabled];
    [self.menuMarcarNoSub setEnabled:enabled];
}
-(void)enableRecargar:(Boolean)enabled{
    [self.menuRecargar setEnabled:enabled];
    [self.botonRecargar setEnabled:enabled];
}
-(void)enableSegmentedControl:(Boolean)enabled{
    [self.segmentedControl setEnabled:enabled];
    [self.menuAnteriores setEnabled:enabled];
    [self.menuProximos setEnabled:enabled];
}

-(void)enableTodo:(Boolean) enabled{
    [self enableAnadir:enabled];
    [self enableEliminar:enabled];
    [self enableMarcar:enabled];
    [self.menuRecargarImagen setEnabled:enabled];
    [self enableRecargar:enabled];
    [self enableSegmentedControl:enabled];
}

-(void)comprobarEpisodiosAntiguos{
    //Elimino los que sean mas antiguos de x dias
    
    NSMutableArray *aBorrar=[[NSMutableArray alloc]init];
    
    for(Episodio *episodioAntiguo in anteriores){
        Boolean borrarPorFecha=NO;
        if(episodioAntiguo.fechaInclusionEnAnteriores!=nil){
            borrarPorFecha=[[NSDate date] timeIntervalSinceDate:episodioAntiguo.fechaInclusionEnAnteriores]>60*60*24*14;
        }else{
            borrarPorFecha=[[NSDate date] timeIntervalSinceDate:episodioAntiguo.hora]>60*60*24*14;
        }
        if((borrarPorFecha)&&[episodioAntiguo.avisado isEqual:@YES]){
            NSLog(@"%@",@"Eliminado episodio antiguo");
            [aBorrar addObject:episodioAntiguo];
        }
    }
    
    NSManagedObjectContext *context = [self managedObjectContext];
    for(Episodio *ep in aBorrar){
        [gestorFicheros eliminarTorrentDeEpisodio:ep];
        [context deleteObject:ep];
        [anteriores removeObject:ep];//elimino de array
    }
    //Guardamos cambios
    NSError *error;
    if (![context save:&error]) {//Se guarda el cambio en coredata
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
    //Busco en proximos los episodios ya emitidos
    //Comprobar que no esten ya anadidos
    for(Episodio *serie in proximos){
        if(serie.hora!=nil){
            if  (serie.hora.timeIntervalSince1970 < [NSDate date].timeIntervalSince1970){
                Boolean encontrado=NO;
                for (Episodio *ep in anteriores) {
                    if(serie.serie.sid.integerValue==ep.serie.sid.integerValue&&[serie.numEpisodio isEqualToString:ep.numEpisodio]&&[serie.nombreEpisodio isEqualToString:ep.nombreEpisodio]){
                        encontrado=YES;
                        break;
                    }
                }
                if(!encontrado){
                    NSManagedObjectContext *context = [self managedObjectContext];
                    
                    Episodio *nuevoEpAntiguo = [NSEntityDescription
                                                insertNewObjectForEntityForName:@"Episodio"
                                                inManagedObjectContext:context];
                    
                    nuevoEpAntiguo.serie=serie.serie;
                    nuevoEpAntiguo.hora=serie.hora;
                    nuevoEpAntiguo.nombreEpisodio=serie.nombreEpisodio;
                    nuevoEpAntiguo.numEpisodio=serie.numEpisodio;
                    nuevoEpAntiguo.tipo=[[NSNumber alloc]initWithInt:1];
                    nuevoEpAntiguo.fechaInclusionEnAnteriores=[NSDate date];
                    
                    [anteriores addObject:nuevoEpAntiguo];//Se anade al array
                    
                    //Apuntamos este episodio como el ultimo registrado si procede
                    NSString *temporada = [nuevoEpAntiguo.numEpisodio componentsSeparatedByString:@"x"][0];
                    NSString *capitulo = [nuevoEpAntiguo.numEpisodio componentsSeparatedByString:@"x"][1];
                    int temporadaint = [temporada intValue];
                    int capituloint = [capitulo intValue];
                    
                    Boolean actualizarElUltimo=NO;
                    if(nuevoEpAntiguo.serie.ultimaTemporadaEnAnteriores==nil){
                        if(capituloint>0){
                            actualizarElUltimo=YES;
                        }
                    }else{
                        if((nuevoEpAntiguo.serie.ultimaTemporadaEnAnteriores.intValue<temporadaint)||(nuevoEpAntiguo.serie.ultimaTemporadaEnAnteriores.intValue==temporadaint&&nuevoEpAntiguo.serie.ultimoEpisodioEnAnteriores.intValue<capituloint)){
                            actualizarElUltimo=YES;
                        }
                    }
                    
                    //Si hay en proximos un capitulo anterior con fecha de emision posterior al que vamos a apuntar entonces no apuntamos
                    //Esto es por si hay un error en las fechas de un capitulo y le ponen una fecha anterior a la actual cuando no fue emitido aun
                    if(actualizarElUltimo){
                        for (Episodio *ep in nuevoEpAntiguo.serie.episodios){
                            if(ep.tipo.intValue!=0){//Tiene que ser tipo proximos, si no no vale
                                continue;
                            }
                            if(ep.getNumeroEpisodio==0){//Si es un especial no lo contamos
                                continue;
                            }
                            if([ep.numEpisodio isEqualToString:@"-1"]){//Si es TBA no lo contamos
                                continue;
                            }
                            if ([ep numCapituloAnteriorA:nuevoEpAntiguo]){
                                if([ep.hora compare:nuevoEpAntiguo.hora] == NSOrderedDescending) {
                                    //ep es posterior a nuevoEpAntiguo
                                    actualizarElUltimo=NO;
                                }
                            }
                        }
                    }
                    
                    if(actualizarElUltimo){
                        if(capitulo>0){
                            NSLog(@"Apuntamos nuevo ultimo capitulo");
                            nuevoEpAntiguo.serie.ultimaTemporadaEnAnteriores=[[NSNumber alloc]initWithInt:temporadaint];
                            nuevoEpAntiguo.serie.ultimoEpisodioEnAnteriores=[[NSNumber alloc]initWithInt:capituloint];
                        }
                    }
                    //Apuntamos la fecha
                    if(nuevoEpAntiguo.serie.ultimaFechaEnAnteriores==nil){
                        nuevoEpAntiguo.serie.ultimaFechaEnAnteriores=nuevoEpAntiguo.hora;
                    }else{
                        if(nuevoEpAntiguo.serie.ultimaFechaEnAnteriores.timeIntervalSince1970<nuevoEpAntiguo.hora.timeIntervalSince1970){
                            nuevoEpAntiguo.serie.ultimaFechaEnAnteriores=nuevoEpAntiguo.hora;
                        }
                    }
                    
                    NSError *error;
                    if (![context save:&error]) {//Se guarda el cambio en coredata
                        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
                    }
                }
            }
        }
    }
    
    
    //Ordenar series
    [anteriores sortUsingSelector:@selector(compareAnteriores:)];
}

-(void)buscarSubs{//Anadir una condicion para parar de buscar los capitulos que llevan una semana sin subtitulos,
    [gestorNotificaciones inicioDeBuscarSubtitulos];
    NSMutableArray *subsEncontrados=[[NSMutableArray alloc]init];
    NSMutableArray *subsANotificar=[[NSMutableArray alloc]init];
    NSMutableArray *epABuscar=[[NSMutableArray alloc]init];
    NSMutableDictionary *encontradosDic=[[NSMutableDictionary alloc]init];
    NSMutableDictionary *subsSupuestosDic=[[NSMutableDictionary alloc]init];
    NSMutableDictionary *subsSupuestosEpDescargadoDic=[[NSMutableDictionary alloc]init];
    NSMutableArray *urls=[[NSMutableArray alloc]init];
    
    //SubtitulosEsListaSeries *lista=[[SubtitulosEsListaSeries alloc]init];
    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
    for(Episodio *ep in anteriores){
        if(ep.excluirBusquedaSub.boolValue){
            continue;
        }
        
        // no hay subs publicados||no se encontro la version y sabemos que version queremos||tenemos apuntada la version que se bajo el user pero aun no encontramos esos subs
        if(ep.urlSub==nil||(ep.urlSubSupuesto==nil&&ep.releaseGroup!=nil)||(ep.urlSubSupuestoEpDescargado==nil&&ep.releaseGroupEpDescargado!=nil)){
            if(ep.serie.descargaAutomaticaSub==nil||ep.serie.descargaAutomaticaSub.boolValue==YES){
                [epABuscar addObject:ep];
            }
        }
    }
    
    //Debug(Esto se borrrara cuando ya se busque el id de sub.es al buscar serie)
    //Actualizamos ids de series que no tengan id de subs(solo subtitulos.es por ahora)
    
//    for(Serie *serie in series){
//        if(serie.buscadorSubtitulos!=nil){
//            if(serie.buscadorSubtitulos.intValue==SubtitulosES){
//                if(serie.idSubtitulosEs==nil){
//                    int idSubEs=[lista getSerieParaNombre:serie.serie].id;
//                    if(idSubEs>=0){
//                        serie.idSubtitulosEs=[NSNumber numberWithInt:idSubEs];
//                    }
//                }
//            }
//        }
//    }
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    if (![context save:&error]) {//Se guarda el cambio en coredata
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    dispatch_semaphore_signal(semaforoSeries);
    
    for(Episodio *ep in epABuscar){
        NSLog(@"Buscando sub de: %@,%@ %@",ep.serie.serie,ep.numEpisodio,ep.nombreEpisodio);
        NSLog(@"%@",ep.releaseGroup);
        NSString *url;
        if(ep.urlSub!=nil){
            url=ep.urlSub;
        }else{
            url =[ep buscarSub];
        }
        
        if(url!=nil){
            [encontradosDic setObject:ep forKey:url];
            if(ep.releaseGroup!=nil&&ep.urlSubSupuesto==nil){//Buscamos el sub supuesto
                NSString *urlSubSupuesto=[ep buscarSubSupuestoConDireccion:url];
                if(urlSubSupuesto!=nil){
                    [subsSupuestosDic setObject:urlSubSupuesto forKey:url];
                }
            }
            if(ep.releaseGroupEpDescargado!=nil&&ep.urlSubSupuestoEpDescargado==nil){//Buscamos el sub supuesto de la ultima version descargada
                NSString *urlSubSupuestoEpDescargado=[ep buscarSubSupuestoEpDescargadoConDireccion:url];
                if(urlSubSupuestoEpDescargado!=nil){
                    [subsSupuestosEpDescargadoDic setObject:urlSubSupuestoEpDescargado forKey:url];
                }
            }
            [urls addObject:url];
            [subsEncontrados addObject:ep.serie.serie];
        }
    }
    
    
    dispatch_semaphore_wait(semaforoSeries, DISPATCH_TIME_FOREVER);
    context = [self managedObjectContext];
    for(NSString *url in urls){
        Episodio *ep=[encontradosDic objectForKey:url];
        if(ep.urlSub==nil){
            [subsANotificar addObject:ep];
        }
        ep.urlSub=url;
        NSString *urlSubSupuesto=[subsSupuestosDic objectForKey:url];
        if(urlSubSupuesto!=nil){
            ep.urlSubSupuesto=urlSubSupuesto;
        }
        //Guardamos el sub supuesto de la ultima version descargada
        NSString *urlSubSupuestoEpDescargado=[subsSupuestosEpDescargadoDic objectForKey:url];
        if(urlSubSupuestoEpDescargado!=nil){
            ep.urlSubSupuestoEpDescargado=urlSubSupuestoEpDescargado;
        }
    }
    if (![context save:&error]) {//Se guarda el cambio en coredata
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    //Gestor de notificaciones
//    int subNuevos=0;
//    NSString *nombreSerie=nil;
//    Boolean mismaSerie=YES;
//    for(Episodio* ep in anteriores){
//        if(ep.urlSub!=nil&&ep.avisadoSub.boolValue==NO){
//            subNuevos++;
//            if(mismaSerie){
//                if(nombreSerie==nil){
//                    nombreSerie=ep.serie.getNombreAMostrar;
//                }else{
//                    if(![nombreSerie isEqualToString:ep.serie.getNombreAMostrar]){
//                        mismaSerie=NO;
//                        nombreSerie=nil;
//                    }
//                }
//            }
//        }
//    }
    NSDictionary* subs=[self snippetNumeroYNombreDeSubNuevos];
    [gestorNotificaciones finDeBuscarSubtitulosConSubtitulosNuevos:[(NSNumber*)[subs objectForKey:@"numero"] intValue]
                                                  serieDeSubNuevos:[subs objectForKey:@"nombre"]];
    
    dispatch_semaphore_signal(semaforoSeries);
    NSLog(@"Terminada busqueda de subs");
    //Avisar de subs encontrados
    if([subsANotificar count]==1){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Subtítulo disponible";
        notification.informativeText = [NSString stringWithFormat:@"Hay disponible un nuevo subtítulo de %@",[[((Episodio*)[subsANotificar objectAtIndex:0]) serie] serie]];
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }else if([subsANotificar count]>1){
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = @"Subtítulos disponibles";
        notification.informativeText = [NSString stringWithFormat:@"Hay disponibles %lu nuevos subtítulos",[subsANotificar count]];
        notification.soundName = NSUserNotificationDefaultSoundName;
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
    }
}
-(Serie*)getSerie:(NSNumber*)sid{
    for (Serie *serie in series){
        if([serie.sid isEqualToNumber:sid]){
            return serie;
        }
    }
    return NULL;
}
-(void)problemasAlRefrescar:(NSString *)nombreSerie{
    NSLog(@"No se pudo actualizar la serie %@",nombreSerie);
    fechaUltimaRecarga=nil;
}



-(dispatch_semaphore_t)getSemafotoSeries{
    return semaforoSeries;
}

-(GestorDeFicheros*)instanciaGestorFicheros{
    return gestorFicheros;
}

-(void)snippetRefrescarNumeroEpisodiosGestorDeNotificaciones{//Llamar dentro de semaforo
    //Gestor de notificaciones, ep
//    int epNuevos=0;
//    NSString *nombreSerie=nil;
//    Boolean mismaSerie=YES;
//    for(Episodio* ep in anteriores){
//        if(ep.magnetLink!=nil&&ep.avisado.boolValue==NO){
//            epNuevos++;
//            if(mismaSerie){
//                if(nombreSerie==nil){
//                    nombreSerie=ep.serie.getNombreAMostrar;
//                }else{
//                    if(![nombreSerie isEqualToString:ep.serie.getNombreAMostrar]){
//                        mismaSerie=NO;
//                        nombreSerie=nil;
//                    }
//                }
//            }
//        }
//    }
    NSDictionary* eps=[self snippetNumeroYNombreDeEpNuevos];
    
    
    [gestorNotificaciones actualizarEpNuevosConEpisodiosNuevos:[(NSNumber*)[eps objectForKey:@"numero"] intValue] serieDeEpNuevos:[eps objectForKey:@"nombre"]];
}

-(void)snippetRefrescarNumeroSubsGestorDeNotificaciones{//Llamar dentro de semaforo
    //Gestor de notificaciones
//    int subNuevos=0;
//    NSString *nombreSerie=nil;
//    Boolean mismaSerie=YES;
//    for(Episodio* ep in anteriores){
//        if(ep.urlSub!=nil&&ep.avisadoSub.boolValue==NO){
//            subNuevos++;
//            if(mismaSerie){
//                if(nombreSerie==nil){
//                    nombreSerie=ep.serie.getNombreAMostrar;
//                }else{
//                    if(![nombreSerie isEqualToString:ep.serie.getNombreAMostrar]){
//                        mismaSerie=NO;
//                        nombreSerie=nil;
//                    }
//                }
//            }
//        }
//    }
    NSDictionary* subs=[self snippetNumeroYNombreDeSubNuevos];
    
    [gestorNotificaciones finDeBuscarSubtitulosConSubtitulosNuevos:[(NSNumber*)[subs objectForKey:@"numero"] intValue] serieDeSubNuevos:[subs objectForKey:@"nombre"]];
}

-(void)snippetRefrescarNumeroEpySubsGestorDeNotificaciones{//Llamar dentro de semaforo
    ///Viejo
//    //Gestor de notificaciones, sub
//    int subNuevos=0;
//    NSString *nombreSerieSub=nil;
//    Boolean mismaSerie=YES;
//    for(Episodio* ep in anteriores){
//        if(ep.urlSub!=nil&&ep.avisadoSub.boolValue==NO){
//            subNuevos++;
//            if(mismaSerie){
//                if(nombreSerieSub==nil){
//                    nombreSerieSub=ep.serie.getNombreAMostrar;
//                }else{
//                    if(![nombreSerieSub isEqualToString:ep.serie.getNombreAMostrar]){
//                        mismaSerie=NO;
//                        nombreSerieSub=nil;
//                    }
//                }
//            }
//        }
//    }
//    
//    //Gestor de notificaciones, torrents
//    int epNuevos=0;
//    NSString* nombreSerieEp=nil;
//    mismaSerie=YES;
//    for(Episodio* ep in anteriores){
//        if(ep.magnetLink!=nil&&ep.avisado.boolValue==NO){
//            epNuevos++;
//            if(mismaSerie){
//                if(nombreSerieEp==nil){
//                    nombreSerieEp=ep.serie.getNombreAMostrar;
//                }else{
//                    if(![nombreSerieEp isEqualToString:ep.serie.getNombreAMostrar]){
//                        mismaSerie=NO;
//                        nombreSerieEp=nil;
//                    }
//                }
//            }
//        }
//    }
    NSDictionary* subs=[self snippetNumeroYNombreDeSubNuevos];
    NSDictionary* eps=[self snippetNumeroYNombreDeEpNuevos];
    
    [gestorNotificaciones actualizarEpYSubtitulosNuevosConEpisodiosNuevo:[(NSNumber*)[eps objectForKey:@"numero"] intValue]
                                                         serieDeEpNuevos:[eps objectForKey:@"nombre"]
                                                        subtitulosNuevos:[(NSNumber*)[subs objectForKey:@"numero"] intValue]
                                                        serieDeSubNuevos:[subs objectForKey:@"nombre"]] ;
}


-(NSDictionary*)snippetNumeroYNombreDeEpNuevos{
        int epNuevos=0;
        NSString* nombreSerieEp=nil;
        Boolean mismaSerie=YES;
        for(Episodio* ep in anteriores){
            if(ep.magnetLink!=nil&&ep.avisado.boolValue==NO){
                epNuevos++;
                if(mismaSerie){
                    if(nombreSerieEp==nil){
                        nombreSerieEp=ep.serie.getNombreAMostrar;
                    }else{
                        if(![nombreSerieEp isEqualToString:ep.serie.getNombreAMostrar]){
                            mismaSerie=NO;
                            nombreSerieEp=nil;
                        }
                    }
                }
            }
        }
    NSMutableDictionary * dic=[[NSMutableDictionary alloc]init];
    [dic setObject:[NSNumber numberWithInt:epNuevos] forKey:@"numero"];
    if(nombreSerieEp!=nil){
        [dic setObject:nombreSerieEp forKey:@"nombre"];
    }
    
    return [[NSDictionary alloc]initWithDictionary:dic];
}
-(NSDictionary*)snippetNumeroYNombreDeSubNuevos{
        int subNuevos=0;
        NSString *nombreSerieSub=nil;
        Boolean mismaSerie=YES;
        for(Episodio* ep in anteriores){
            if(ep.urlSub!=nil&&ep.avisadoSub.boolValue==NO){
                subNuevos++;
                if(mismaSerie){
                    if(nombreSerieSub==nil){
                        nombreSerieSub=ep.serie.getNombreAMostrar;
                    }else{
                        if(![nombreSerieSub isEqualToString:ep.serie.getNombreAMostrar]){
                            mismaSerie=NO;
                            nombreSerieSub=nil;
                        }
                    }
                }
            }
        }
    
    NSMutableDictionary * dic=[[NSMutableDictionary alloc]init];
    [dic setObject:[NSNumber numberWithInt:subNuevos] forKey:@"numero"];
    if(nombreSerieSub!=nil){
        [dic setObject:nombreSerieSub forKey:@"nombre"];
    }
    
    return [[NSDictionary alloc]initWithDictionary:dic];
    
}

- (IBAction)pruebaAnimacion:(id)sender {
    //Pruebas animacion
    CATransition *animation = [CATransition animation];
    animation.duration = 0.5;
    animation.type = kCATransitionPush;
    animation.subtype=kCATransitionFromBottom;
    //animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.textFieldBarraInferior.layer addAnimation:animation forKey:@"changeTextTransition"];
    
    // Change the text
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    self.textFieldBarraInferior.stringValue = newDateString;
}

//-(void) actualizarPreferenciasConRutaDeSubs:(NSURL*)rutaSubs{
//    gestorFicheros.directorioSubs=rutaSubs;
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    [prefs setObject:rutaSubs.absoluteString forKey:@"rutaSubs"];
//    [prefs synchronize];
//    //NSLog(@"%@",rutaSubs.absoluteString);
//}


- (IBAction)actionCambioSeleccionRadioButton:(NSMatrix *)sender {
    if(sender.selectedTag==0){
        self.desplegableUltimoEpPopover.enabled=NO;
    }else{
        self.desplegableUltimoEpPopover.enabled=YES;
    }
}
@end
