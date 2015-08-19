#define BLACKLIST_PATH @"/var/mobile/Library/Preferences/inpornito.plist"

BOOL isSwitchON;
BOOL shouldRemovePrivateTabs;
NSMutableArray *blacklist;

@interface TiltedTabItem : NSObject
-(void)setTitleColor:(UIColor *)arg1;
@end

@interface WBSTopHitCompletionMatch : NSObject
-(NSString *)originalURLString;
@end

@interface TabOverviewItem : NSObject
-(void)setTitleColor:(UIColor *)arg1;
@end

@interface WBSHistoryVisit : NSObject
@end

@interface _WKWebsiteDataStore : NSObject
+(id)nonPersistentDataStore;
-(BOOL)isNonPersistent;
@end

@interface WKWebViewConfiguration : NSObject
-(void)_setWebsiteDataStore:(id)arg1;
-(_WKWebsiteDataStore *)_websiteDataStore;
@end

@interface SafariWebView : NSObject
-(void)_setHistoryDelegate:(id)historyDelegate;
-(WKWebViewConfiguration *)configuration;
@end

@interface TabDocument : NSObject
- (NSString *)URLString;
-(BOOL)isBlankDocument;
-(void)setLastVisit:(WBSHistoryVisit *)arg1 ;
-(void)setClosed:(BOOL)arg1;
-(BOOL)privateBrowsingEnabled;
-(void)_closeTabDocumentAnimated:(BOOL)arg1 ;
-(void)hibernate;
-(TiltedTabItem *)tiltedTabItem;
-(TabOverviewItem *)tabOverviewItem;
-(SafariWebView *)webView;
-(void)loadURL:(id)arg1 userDriven:(BOOL)arg2 ;
-(NSString *)title;
-(NSURL *)URL;
-(NSUUID *)UUID;
-(BOOL)privateBrowsingEnabled;
-(id)initWithBrowserController:(id)arg1 ;
-(id)bookmark;
-(void)_initLoadingController;
-(id)initWithTitle:(id)arg1 URL:(id)arg2 UUID:(id)arg3 privateBrowsingEnabled:(BOOL)arg4 hibernated:(BOOL)arg5 bookmark:(id)arg6 browserController:(id)arg7 ;
@end

@interface TabController : NSObject
- (TabDocument *)activeTabDocument;
-(TabDocument *)tabDocumentForURL:(id)arg1 ;
-(void)setPrivateBrowsingEnabled:(BOOL)arg1;
-(void)replaceTabDocument:(id)arg1 withTabDocument:(id)arg2 ;
-(void)setActiveTabDocument:(id)arg1 animated:(BOOL)arg2 ;
-(void)_switchActiveTabDocumentFromTabDocument:(id)arg1 toTabDocument:(id)arg2;
-(void)openInitialBlankTabDocumentIfNeeded;
-(void)_updateTiltedTabViewItems;
-(void)closeTabDocument:(id)arg1 animated:(BOOL)arg2 ;
-(void)insertNewTabDocument:(id)arg1 openedFromTabDocument:(id)arg2 inBackground:(BOOL)arg3 animated:(BOOL)arg4 ;
@end

@interface BrowserController : NSObject
+ (id)sharedBrowserController;
- (void)updatePrivateBrowsingPreferences;
- (void)writePrivateBrowsingPreference:(BOOL)preference;
- (void)_togglePrivateBrowsingWithConfirmation:(BOOL)confirmation;
- (BOOL)privateBrowsingEnabled;
- (TabController *)tabController;
-(void)_setPrivateBrowsingEnabled:(BOOL)arg1;
-(void)togglePrivateBrowsing;
@end

@interface SwagClass : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIActionSheetDelegate>
@property (assign) UITextView *textView;
@property (assign) UITableView *tableView;
@property (assign) UIActionSheet *omgdanger;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void) doAlertWithTableView;
- (void) switchChanged:(id)sender;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (void) reverseSwag:(id)sender;
- (void) swag:(id)sender;
- (void) completeSwag:(id)sender;
- (void)actionSheet:(UIActionSheet *)omgdanger clickedButtonAtIndex:(NSInteger)buttonIndex;
@end
