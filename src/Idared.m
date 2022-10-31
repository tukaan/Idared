#import "Idared.h"

#import <string.h>
#import <tcl.h>
#import <tk.h>
#import <tkInt.h>
#import <tkMacOSXInt.h>
#import <Cocoa/Cocoa.h>


static Tcl_Interp *tclInterp;

NSMutableArray *toolbarItems;


@implementation DockIcon

- (int)setBadge: (NSString *) label {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSDockTile *dockicon = [NSApp dockTile];
  
  [dockicon setShowsApplicationBadge:YES];
  [dockicon setBadgeLabel:label];
  [dockicon display];

  [pool release];
  return 0;
}

@end


@implementation Toolbar

- (id)init {
  self = [super init];
  return self;
}

- (NSToolbarItem *)toolbar: (NSToolbar *)toolbar
      itemForItemIdentifier:(NSString *)itemIdentifier
      willBeInsertedIntoToolbar:(BOOL)flag
{ 
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSToolbarItem *toolbarItem = nil;

  for (NSDictionary *element in toolbarItems) {
    if ([itemIdentifier isEqualTo:[element objectForKey:@"itemIdentifier"]]) {
      toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:[element objectForKey:@"itemIdentifier"]];
      [toolbarItem setLabel:[element objectForKey:@"buttonLabel"]];
      [toolbarItem setToolTip:[element objectForKey:@"toolTip"]];
      [toolbarItem setImage:[[NSImage alloc] initWithContentsOfFile:[element objectForKey:@"imagePath"]]];
      [toolbarItem setAction:@selector(runScript:)];
      [toolbarItem setTarget:self];
      [toolbarItem setEnabled:YES];
      [toolbarItem setBordered:YES];
    }       
  }

  [pool release];
  return toolbarItem;
}

-(NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar*)toolbar {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSMutableArray *allowedItems = [[NSMutableArray alloc] init];

  for (NSDictionary *element in toolbarItems) {
    [allowedItems addObject: [element objectForKey:@"itemIdentifier"]];
  }

  [pool release];
  return allowedItems;
}

- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar*)toolbar {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSMutableArray *defaultItems = [[NSMutableArray alloc] init]; 

  for (NSDictionary *element in toolbarItems) {
    [defaultItems addObject:[element objectForKey:@"itemIdentifier"]];   
  }

  [pool release];
  return defaultItems;
}

- (void)setupToolbar: (NSWindow*)window {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:@"mainToolbar"];
  [toolbar setDelegate:self];
  [toolbar setAllowsUserCustomization:NO];
  [toolbar setAutosavesConfiguration:NO];
  [window setToolbar:toolbar];
  [window setShowsToolbarButton:NO];
  [toolbar setVisible:YES];
  [toolbar validateVisibleItems];

  [pool release];
}

- (id)runScript: (id)sender {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *searchterm = [sender itemIdentifier]; 

  for (NSDictionary *element in toolbarItems) {
    if ([searchterm isEqualToString:[element objectForKey:@"itemIdentifier"]])  {
      NSString *cmd =  [element objectForKey:@"buttonCommand"];
      char *script = [cmd UTF8String];
      Tcl_Eval(tclInterp, script);
    }
  }

  [pool release];
  return YES;
}

@end


int CreateToolbar(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  if (objc < 2 || objc > 3) {
    Tcl_WrongNumArgs(interp, 1, objv, "pathname ?unify?");
    return TCL_ERROR;
  }

  Tk_Window pathName;
  pathName = Tk_NameToWindow(interp, Tcl_GetString(objv[1]), Tk_MainWindow(interp));

  if (pathName == NULL) {
    return TCL_ERROR;
  }

  Tk_MakeWindowExist(pathName);
  Tk_MapWindow(pathName);

  Drawable d = Tk_WindowId(pathName);
  Toolbar *toolbar = [[Toolbar alloc] init];
  NSView *view = TkMacOSXGetRootControl(d);
  NSWindow *window = [view window];

  [toolbar setupToolbar:window];

  if (objc == 3) {
    if (strcmp(Tcl_GetString(objv[2]), "1") == 0) {
      [window setTitleVisibility:NSWindowTitleHidden];
    }
  }

  [pool release];
  return TCL_OK;
}


int CreateToolbarItem (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  if(objc != 6) {
    Tcl_WrongNumArgs(interp, 1, objv, "identifier label tooltip imagepath cmd");
    return TCL_ERROR;
  }

  NSMutableDictionary *newtoolbutton = [[NSMutableDictionary alloc] init];

  NSString *identifier = [NSString stringWithUTF8String:Tcl_GetString(objv[1])];
  NSString *label = [NSString stringWithUTF8String:Tcl_GetString(objv[2])];
  NSString *tooltip = [NSString stringWithUTF8String:Tcl_GetString(objv[3])];
  NSString *imagepath = [NSString stringWithUTF8String:Tcl_GetString(objv[4])];
  NSString *command = [NSString stringWithUTF8String:Tcl_GetString(objv[5])];

  [newtoolbutton setObject:identifier forKey:@"itemIdentifier"];
  [newtoolbutton setObject:label forKey:@"buttonLabel"];
  [newtoolbutton setObject:tooltip forKey:@"toolTip"];
  [newtoolbutton setObject:imagepath forKey:@"imagePath"];
  [newtoolbutton setObject:command forKey:@"buttonCommand"];

  [toolbarItems addObject:newtoolbutton];

  return TCL_OK;
}


int SetDockIconBadge (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSString *label;

  if (objc != 2) {
    Tcl_WrongNumArgs(interp, 1, objv, "label");
    return TCL_ERROR;
  }

  DockIcon *dockicon = [[DockIcon alloc] init];

  label = [NSString stringWithUTF8String:Tcl_GetString(objv[1])];
  [dockicon setBadge:label];

  [pool release];
  return TCL_OK;
}


int BeginSheet (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

  if (objc != 3) {
    Tcl_WrongNumArgs(interp, 1, objv, "parent? sheet?");
    return TCL_ERROR;
  }

  Tk_Window parentpath = Tk_NameToWindow(interp, Tcl_GetString(objv[1]), Tk_MainWindow(interp));

  if (parentpath == NULL) {
    return TCL_ERROR;
  }
  
  Tk_Window sheetpath = Tk_NameToWindow(interp, Tcl_GetString(objv[2]), Tk_MainWindow(interp));

  if (sheetpath == NULL) {
    return TCL_ERROR;
  }

  Tk_MakeWindowExist(sheetpath);
  Tk_MapWindow(sheetpath);

  Drawable parent_d = Tk_WindowId(parentpath);
  NSView *parentview = TkMacOSXGetRootControl(parent_d);
  NSWindow *parent = [parentview window];

  Drawable sheet_d = Tk_WindowId(sheetpath);
  NSView *sheetview = TkMacOSXGetRootControl(sheet_d);
  NSWindow *sheet = [sheetview window];

  if (sheet == nil) {
    return TCL_ERROR;
  }
  
  [parent beginSheet:sheetview.window completionHandler:nil];

  [pool release];
  return TCL_OK;
}


int EndSheet (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {
  if (objc != 2) {
    Tcl_WrongNumArgs(interp, 1, objv, "sheet?");
    return TCL_ERROR;
  }

  Tk_Window sheetpath = Tk_NameToWindow(interp, Tcl_GetString(objv[1]), Tk_MainWindow(interp));

  if (sheetpath == NULL) {
    return TCL_ERROR;
  }

  Drawable d = Tk_WindowId(sheetpath);
  NSView *sheetview = TkMacOSXGetRootControl(d);

  [NSApp endSheet:sheetview.window];
  [sheetview.window orderOut:nil];
  Tk_DestroyWindow(sheetpath);

  return TCL_OK;
}


int Idared_Init (Tcl_Interp *interp) {
  if (Tcl_InitStubs(interp, "8.6", 0) == NULL) {
    return TCL_ERROR;
  }
  if (Tk_InitStubs(interp, "8.6", 0) == NULL) {
    return TCL_ERROR;
  }

  Tcl_CreateObjCommand(interp, "Idared::set_badge", SetDockIconBadge, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "Idared::create_toolbar", CreateToolbar, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "Idared::create_toolbaritem", CreateToolbarItem, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "Idared::begin_sheet", BeginSheet, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);
  Tcl_CreateObjCommand(interp, "Idared::end_sheet", EndSheet, (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

  toolbarItems = [[NSMutableArray alloc] init];
  tclInterp = interp;

  if (Tcl_PkgProvide(interp, "Idared", "0.1") != TCL_OK) {
    return TCL_ERROR;
  }

  return TCL_OK;
}


int Idared_SafeInit(Tcl_Interp *interp) {
  return Idared_Init(interp);
}
