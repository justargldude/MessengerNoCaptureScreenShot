// Tweak.xm - ScreenCaptureBypass v4.0 (Ultra Safe - Dynamic Hooking)
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ========== HOOK UISCREEN (LUÔN AN TOÀN - SYSTEM CLASS) ==========
%hook UIScreen
- (BOOL)isCaptured {
    return NO; 
}
%end

// ========== DYNAMIC HOOKING (CHỐNG CRASH) ==========
%group MessengerHooks

%hook MSGQuicksnapScreenCaptureProtectedView
- (void)didMoveToWindow {
    %orig;
    [self setHidden:YES];
    [self setAlpha:0];
}
- (void)setHidden:(BOOL)hidden { %orig(YES); }
- (void)setAlpha:(CGFloat)alpha { %orig(0); }
%end

%hook MSGQuicksnapScreenCaptureProtectionEducationView
- (void)didMoveToWindow {
    %orig;
    [self setHidden:YES];
    [self setAlpha:0];
}
%end

%end // Kết thúc group MessengerHooks

// ========== NOTIFICATION HOOKS ==========
%group NotificationHooks

%hook NSNotificationCenter
- (void)addObserver:(id)observer 
           selector:(SEL)aSelector 
               name:(NSNotificationName)aName 
             object:(id)anObject {
    if (aName != nil) {
        if ([aName isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"] ||
            [aName isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
            return; 
        }
    }
    %orig;
}

- (id)addObserverForName:(NSNotificationName)name 
                  object:(id)obj 
                   queue:(NSOperationQueue *)queue 
              usingBlock:(void (^)(NSNotification *))block {
    if (name != nil) {
        if ([name isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"] ||
            [name isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
            return nil;
        }
    }
    return %orig;
}
%end

%end // Kết thúc group NotificationHooks

// ========== CONSTRUCTOR ==========
%ctor {
    // Init UIScreen hook ngay lập tức (system class - luôn tồn tại)
    %init(_ungrouped);
    
    // Init Notification hooks ngay (NSNotificationCenter luôn tồn tại)
    %init(NotificationHooks);
    
    NSLog(@"[ScreenCaptureBypass] v4.0 - System hooks active!");
    
    // Delay hook cho Messenger classes
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class targetClass = objc_getClass("MSGQuicksnapScreenCaptureProtectedView");
        if (targetClass) {
            %init(MessengerHooks);
            NSLog(@"[ScreenCaptureBypass] Messenger hooks activated!");
        } else {
            NSLog(@"[ScreenCaptureBypass] Target class not found, skipping Messenger hooks.");
        }
    });
}
