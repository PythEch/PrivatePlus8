@interface TabDocument : NSObject
- (NSString *)URLString;
// custom methods
- (BOOL)isBlacklisted;
- (void)addToBlacklistWithFilter:(NSString *)filter;
- (void)removeFromBlacklist;
@end

@interface TabController : NSObject
- (TabDocument *)activeTabDocument;
@end

@interface BrowserController : NSObject
+ (id)sharedBrowserController;
- (void)updatePrivateBrowsingPreferences;
- (void)writePrivateBrowsingPreference:(BOOL)preference;
- (void)_togglePrivateBrowsingWithConfirmation:(BOOL)confirmation;
- (BOOL)privateBrowsingEnabled;
- (TabController *)tabController;
@end
