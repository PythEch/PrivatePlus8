#import <UIKit/UITableView.h>
#import <UIKit/UISwitch.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import "Tweak.h"

//////////////////////// FUNCTIONS ////////////////////////

static void willTerminateCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    // UI is available, use UIKit here
    //                         - uroboro
    HBLogDebug(@"Wtf Safari, why are you leaving us </3 = %@", name);

    if (!shouldRemovePrivateTabs) return;

    // this too is probably risky but meh

    NSString *libraryPath = ((NSURL *)[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject]).path;
    NSString *path = [NSString pathWithComponents:@[libraryPath, @"Safari/SuspendState.plist"]];
    NSMutableDictionary *plist = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    if (plist[@"SafariStatePrivateDocuments"]) {
        HBLogDebug(@"it wasn't empty");
        plist[@"SafariStatePrivateDocuments"] = @[];
        [plist writeToFile:path atomically:YES];
    } else HBLogDebug(@"it was empty");
}

static BOOL isLinkFiltered(NSString *link) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ LIKE[cd] SELF", link];
    for (NSString *filter in blacklist) {
        if ([predicate evaluateWithObject:filter]) {
            return YES;
        }
    }

    return NO;
}

%ctor {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:BLACKLIST_PATH];
    blacklist = plist[@"Filters"] ? [[plist[@"Filters"] mutableCopy] autorelease] : @[];
    isSwitchON = [plist[@"isEnabled"] boolValue];
    shouldRemovePrivateTabs = [plist[@"removePrivateTabsOnExit"] boolValue];

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetLocalCenter(), NULL,
        willTerminateCallback,
        (CFStringRef)UIApplicationDidEnterBackgroundNotification,
        NULL, CFNotificationSuspensionBehaviorCoalesce);

    CFNotificationCenterAddObserver(
        CFNotificationCenterGetLocalCenter(), NULL,
        willTerminateCallback,
        (CFStringRef)UIApplicationWillTerminateNotification,
        NULL, CFNotificationSuspensionBehaviorCoalesce);
}

//////////////////////// HOOKS ////////////////////////

%hook BrowserController
-(void)tabDocumentDidStartLoading:(TabDocument *)tab {
    %orig;
    if (!isSwitchON || !isLinkFiltered([tab URLString])) return;

    TabController *tc = [self tabController];
    NSMutableArray *privateTabDocuments = MSHookIvar<NSMutableArray *>(tc, "_privateTabDocuments");
    NSMutableArray *normalTabDocuments = MSHookIvar<NSMutableArray *>(tc, "_normalTabDocuments");
    TabDocument *&privateActiveTabDocument = MSHookIvar<TabDocument *>(tc, "_privateActiveTabDocument");
    BOOL &priv8 = MSHookIvar<BOOL>(tab, "_privateBrowsingEnabled");

    // if we are in already a private tab, do nothing
    if (priv8) return;

    // this is a dangerous (imo) way to block logging of history
    // nevertheless it just works™
    [[tab webView] _setHistoryDelegate:nil];

    // remove the blank private tab if necessary
    if ([privateTabDocuments count] == 1 && [privateTabDocuments[0] isBlankDocument]) {
        [privateTabDocuments[0] _closeTabDocumentAnimated:NO];
        [privateTabDocuments removeObject:privateTabDocuments[0]];
        // we can't exactly remove tabs for some reason
        // safari holds closed tabs as hibernated
    }
    priv8 = YES;
    [privateTabDocuments addObject:tab];
    [normalTabDocuments removeObject:tab];
    // fix title colors
    [[tab tiltedTabItem] setTitleColor:[UIColor whiteColor]];
    [[tab tabOverviewItem] setTitleColor:[UIColor whiteColor]];
    if ([tc activeTabDocument] == tab) {
        // do these only when it makes sense
        privateActiveTabDocument = tab;
        [self writePrivateBrowsingPreference:YES];
        [self updatePrivateBrowsingPreferences];
    }
    [tc openInitialBlankTabDocumentIfNeeded];
}
%end

%hook TabController

-(id)tiltedTabViewToolbarItems {
    HBLogDebug(@"Injecting tap twice gesture...");

    id r = %orig;

    UIButton *privateModeButton = MSHookIvar<UIButton *>(self, "_tiltedTabViewPrivateBrowsingButton");
    if (!privateModeButton) {
        HBLogDebug(@"Private mode button is nil (wtf?)");
        return r;
    }

    UITapGestureRecognizer *tapTwice = [[%c(UITapGestureRecognizer) alloc] initWithTarget:self action:@selector(inpornitoMenuAction)];
    tapTwice.numberOfTapsRequired = 2;
    [privateModeButton addGestureRecognizer:tapTwice];
    [UITapGestureRecognizer release];

    HBLogDebug(@"Injected!");
    return r;
}

%new
- (void)inpornitoMenuAction {
    UIAlertView *menuAlert = [[UIAlertView alloc] initWithTitle:@"inpornito"
                                                        message:@"omg this is so much hax"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
    menuAlert.cancelButtonIndex = -1;

    [menuAlert show];
    [menuAlert release];
}
%end
