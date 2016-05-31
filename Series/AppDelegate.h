//
//  AppDelegate.h
//  Series
//
//  Created by Alexandre Blanco Gómez on 29/05/14.
//  Copyright (c) 2014 Horseware. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TableViewModif.h"
#import "Serie.h"
#import "GestorDeFicheros.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate,NSUserNotificationCenterDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

//Hasta aqui por defecto al crearla

@property (weak) IBOutlet NSButton *botonAnadir;
@property (weak) IBOutlet NSMenuItem *menuAnadir;
@property (weak) IBOutlet NSPopover *popover;
@property (weak) IBOutlet NSTextField *popoverTextfield;
@property (weak) IBOutlet NSTableView *tableviewBusqueda;
@property (weak) IBOutlet TableViewModif *tableviewPrincipal;
@property (weak) IBOutlet NSProgressIndicator *spinningWheelRecarga;
@property (weak) IBOutlet NSProgressIndicator *spinningWheelPopoverBuscar;
@property (weak) IBOutlet NSProgressIndicator *spinningWheelPopoverAnadir;
@property (weak) IBOutlet NSMenuItem *menuEliminar;
@property (weak) IBOutlet NSButton *botonEliminar;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSSegmentedControl *segmentedControl;
@property (weak) IBOutlet NSButton *botonRecargar;
@property (weak) IBOutlet NSMenuItem *menuRecargar;
@property (weak) IBOutlet NSMenuItem *menuProximos;
@property (weak) IBOutlet NSMenuItem *menuAnteriores;
@property (weak) IBOutlet NSMenuItem *menuRecargarImagen;
@property (weak) IBOutlet NSMenuItem *menuMarcarEp;
@property (weak) IBOutlet NSMenuItem *menuMarcarSub;
@property (weak) IBOutlet NSMenuItem *menuMarcarNoEp;
@property (weak) IBOutlet NSMenuItem *menuMarcarNoSub;
@property (weak) IBOutlet NSMenuItem *menuMostrarBusquedaEpisodio;
@property (weak) IBOutlet NSMenuItem *menuDescargarSubtitulo;
@property (weak) IBOutlet NSMenuItem *menuDescargarEpisodio;

@property (weak) IBOutlet NSTextField *ultimaTemporadaPopover;
@property (weak) IBOutlet NSTextField *ultimoEpisodioPopover;
@property (weak) IBOutlet NSMenuItem *menuMostrarInfoSerie;

//Popover anadir
@property (weak) IBOutlet NSMatrix *radioButtonsPopover;
@property (weak) IBOutlet NSPopUpButton *desplegableUltimoEpPopover;
- (IBAction)actionCambioSeleccionRadioButton:(NSMatrix *)sender;
@property (weak) IBOutlet NSViewController *controladorPopover;
@property (weak) IBOutlet NSView *vistaEpisodioPopover;

//Parte derecha
@property (weak) IBOutlet NSView *panelDetalles;



//Barra inferior
@property (weak) IBOutlet NSTextField *textFieldBarraInferior;
@property (weak) IBOutlet NSButton *botonEpBarraInferior;
@property (weak) IBOutlet NSButton *botonSubBarraInferior;
@property (weak) IBOutlet NSView *viewPopover;



- (IBAction)debugListarTorrents:(id)sender;

-(dispatch_semaphore_t)getSemafotoSeries;
- (IBAction)anteriores:(id)sender;
- (IBAction)proximos:(id)sender;
- (IBAction)exportarSeries:(id)sender;
- (IBAction)importarSeries:(id)sender;
- (IBAction)cambioSegmentedControl:(NSSegmentedControl *)sender;
- (IBAction)popoverBuscar:(id)sender;
- (IBAction)actualizar:(id)sender;
- (IBAction)popoverAnadir:(id)sender;
- (IBAction)eliminar:(id)sender;
- (IBAction)anadir:(id)sender;
- (IBAction)recargarImagen:(id)sender;
- (IBAction)completarDatos:(id)sender;
- (IBAction)mostrarInfoSerie:(id)sender;
- (IBAction)mostrarBusquedaEpisodiosPendientes:(id)sender;
- (IBAction)muestraBusquedaEpisodioSeleccionado:(id)sender;
- (IBAction)descargaEpisodioSeleccionado:(id)sender;
- (IBAction)descargaSubtituloSeleccionado:(id)sender;
- (void)muestraBusquedaEpisodio:(NSIndexSet*)indices;
- (void)descargaSubtitulo:(NSMutableArray*)episodiosABajar;
-(void)descargaEpisodio:(NSMutableArray*)episodiosABajar;
-(void)descargaEpisodioConIndices:(NSIndexSet*)indices;
- (void)descargaSubtituloConIndices:(NSIndexSet*)indices;
- (IBAction)descargarSubsPendientes:(id)sender;
- (IBAction)descargarEpisodiosPendientes:(id)sender;
- (IBAction)marcarTodoComoDescargado:(id)sender;
- (IBAction)marcarEpSeleccionadoComoDescargado:(id)sender;
- (IBAction)marcarEpSeleccionadoComoNoDescargado:(id)sender;
- (IBAction)marcarSubSeleccionadoComoDescargado:(id)sender;
- (IBAction)marcarSubSeleccionadoComoNoDescargado:(id)sender;
- (void)setExcluirBusquedaEpA:(Boolean)excluir paraEpisodios:(NSIndexSet*)indices;
- (void)setExcluirBusquedaSubA:(Boolean)excluir paraEpisodios:(NSIndexSet *)indices;
- (void)setEpisodioDescargadoA:(Boolean)avisado paraEpisodios:(NSIndexSet*)indices;
- (void)setSubDescargadoA:(Boolean)avisadoSub paraEpisodios:(NSIndexSet*)indices;
-(void)mostrarInfoDeSerie:(NSIndexSet *)indices;
- (IBAction)buscarTorrent:(id)sender;
-(GestorDeFicheros*)instanciaGestorFicheros;
-(void) eliminarEpisodiosConIndices:(NSIndexSet*)indices;
//-(void) actualizarPreferenciasConRutaDeSubs:(NSURL*)rutaSubs;
- (IBAction)pruebaAnimacion:(id)sender;

- (IBAction)debugVentanaAnadir:(id)sender;

- (IBAction)debugPonerTodoASubEs:(id)sender;

- (IBAction)abrirPreferencias:(id)sender;


@end
