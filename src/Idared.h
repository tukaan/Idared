#import <tcl.h>
#import <Cocoa/Cocoa.h>


@interface DockIcon: NSObject {}
- (int)setBadge: (NSString *)label;
@end


@interface Toolbar: NSObject {}
- (id)init;
- (void)setupToolbar: (NSWindow*)window;
- (NSToolbarItem *)toolbar: (NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag;
- (NSArray *)toolbarAllowedItemIdentifiers: (NSToolbar*)toolbar;
- (NSArray *)toolbarDefaultItemIdentifiers: (NSToolbar*)toolbar;
- (id)runScript: (id)sender;
@end


int SetDockIconBadge (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);
int CreateToolbar (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);
int CreateToolbarItem (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);
int BeginSheet (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);
int EndSheet (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);
int Idared_Init (Tcl_Interp *interp);
int Idared_SafeInit (Tcl_Interp *interp);
