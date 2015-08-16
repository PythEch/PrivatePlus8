@interface TabDocument : NSObject
- (NSString *)URLString;
// custom methods
- (BOOL)isBlacklisted;
- (void)addToBlacklistWithFilter:(NSString *)filter;
- (void)removeFromBlacklist;
-(BOOL)isBlankDocument;
@end

@interface TabController : NSObject
- (TabDocument *)activeTabDocument;
-(void)setPrivateBrowsingEnabled:(BOOL)arg1;
-(void)_switchActiveTabDocumentFromTabDocument:(id)arg1 toTabDocument:(id)arg2;
-(void)openInitialBlankTabDocumentIfNeeded;
-(void)_updateTiltedTabViewItems;
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
