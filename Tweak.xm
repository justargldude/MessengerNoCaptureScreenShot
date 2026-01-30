// Tweak.xm - ScreenCaptureBypass v5.0 (Minimal - Maximum Stability)
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

%hook UIScreen
- (BOOL)isCaptured {
    return NO; 
}
%end

%hook NSNotificationCenter
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    if (aName != nil) {
        if ([aName isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"] ||
            [aName isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
            return;
        }
    }
    %orig;
}
%end

%ctor {
    %init;
    NSLog(@"[ScreenCaptureBypass] v5.0 Active!");
}
