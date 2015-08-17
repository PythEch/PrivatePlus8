@interface TiltedTabItem : NSObject
-(void)setTitleColor:(UIColor *)arg1;
@end

@interface TabOverviewItem : NSObject
-(void)setTitleColor:(UIColor *)arg1;
@end

@interface WBSHistoryVisit : NSObject
@end

@interface SafariWebView : NSObject
-(void)_setHistoryDelegate:(id)historyDelegate;
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
@end

@interface TabController : NSObject
- (TabDocument *)activeTabDocument;
-(void)setPrivateBrowsingEnabled:(BOOL)arg1;
-(void)_switchActiveTabDocumentFromTabDocument:(id)arg1 toTabDocument:(id)arg2;
-(void)openInitialBlankTabDocumentIfNeeded;
-(void)_updateTiltedTabViewItems;
-(void)closeTabDocument:(id)arg1 animated:(BOOL)arg2 ;
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
