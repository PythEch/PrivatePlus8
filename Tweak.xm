#import "Tweak.h"
#import "substrate.h"
#import <UIKit/UITableView.h>
#import <UIKit/UISwitch.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define BLACKLIST_PATH @"/var/mobile/Library/Preferences/inpornito.plist"

BOOL isSwitchON;

%ctor {
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:BLACKLIST_PATH];
    blacklist = plist[@"Filters"] ? [plist[@"Filters"] mutableCopy] : [NSMutableArray array];
    isSwitchON = [plist[@"isEnabled"] boolValue];
    didUserEnterIncognito = NO;
}

void saveSettings() {
    NSDictionary *plist = @{@"Filters": blacklist, @"isEnabled": @(isSwitchON)};
    [plist writeToFile:BLACKLIST_PATH atomically:NO];
}


BOOL isLinkFiltered(NSString *link) {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%@ LIKE[cd] SELF", link];
    for (NSString *filter in blacklist) {
        if ([predicate evaluateWithObject:filter]) {
            return YES;
        }
    }

    return NO;
}

%hook History
- (void)_visitedURL:(NSString *)URLString title:(id)arg2 asHTTPNonGet:(BOOL)arg3 visitWasFailure:(BOOL)arg4 incrementVisitCount:(BOOL)arg5 {
    if (IS_TWEAK_ENABLED && checkIfLinkIsFiltered(URLString)) return;

    %orig;
}
%end

%hook BrowserController
- (void)catalogViewController:(id)arg1 mightSelectCompletionItem:(id)arg2 forString:(id)arg3 {
    // DO FUCKING NOTHING
    // FUCK YEAH
    // FUCK YOU SAFARI
    // NO FUCKING PRE-UPDATE URL
}

-(void)tabDocumentDidStartLoading:(TabDocument *)tab {
    %log;
    %orig;
    if (!isSwitchON && !isLinkFiltered([tab URLString])) return;

    TabController *tc = [self tabController];
    BOOL &priv8 = MSHookIvar<BOOL>(tab, "_privateBrowsingEnabled");
    id &lastVisit = MSHookIvar<id>(tab, "_lastVisit");
    NSMutableArray *privateTabDocuments = MSHookIvar<NSMutableArray *>(tc, "_privateTabDocuments");
    NSMutableArray *normalTabDocuments = MSHookIvar<NSMutableArray *>(tc, "_normalTabDocuments");
    TabDocument *&privateActiveTabDocument = MSHookIvar<TabDocument *>(tc, "_privateActiveTabDocument");

    lastVisit = nil;
    priv8 = YES;
    [normalTabDocuments removeObject:tab];
    [privateTabDocuments addObject:tab];
    privateActiveTabDocument = tab;
    [self togglePrivateBrowsing];
    [tc openInitialBlankTabDocumentIfNeeded];
    [tc _updateTiltedTabViewItems];
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
