// Tweak.xm - ScreenCaptureBypass v5.0 (Minimal - Maximum Stability)
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ========================================
// CHỈ GIỮ LẠI 2 HOOK AN TOÀN NHẤT
// 1. UIScreen.isCaptured - Đánh lừa toàn bộ App
// 2. NSNotificationCenter - Chặn thông báo screenshot
// ========================================

// ========== HOOK 1: UIScreen (SYSTEM CLASS - 100% AN TOÀN) ==========
%hook UIScreen
- (BOOL)isCaptured {
    // Đây là hook quan trọng nhất và an toàn nhất
    // Khi return NO, App nghĩ không ai đang quay/chụp màn hình
    // -> Protected View sẽ KHÔNG hiện lên
    return NO; 
}
%end

// ========== HOOK 2: NSNotificationCenter (SYSTEM CLASS - AN TOÀN) ==========
%hook NSNotificationCenter

- (void)addObserver:(id)observer 
           selector:(SEL)aSelector 
               name:(NSNotificationName)aName 
             object:(id)anObject {
    // Chặn đăng ký lắng nghe screenshot
    if (aName != nil) {
        if ([aName isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"] ||
            [aName isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
            return; // Không đăng ký -> người kia không biết bạn chụp
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

// ========== CONSTRUCTOR ==========
%ctor {
    %init;
    NSLog(@"[ScreenCaptureBypass] v5.0 Minimal - Active!");
}
