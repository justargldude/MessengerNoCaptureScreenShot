// Tweak.xm - ScreenCaptureBypass v3.1 (Fixed Compiler Error)
#import <UIKit/UIKit.h>

// ========== KHAI BÁO INTERFACE ĐỂ COMPILER HIỂU ==========
@interface MSGQuicksnapScreenCaptureProtectedView : UIView
@end

@interface MSGQuicksnapScreenCaptureProtectionEducationView : UIView
@end

// ========== HOOK 1: Protected View ==========
%hook MSGQuicksnapScreenCaptureProtectedView

- (instancetype)init {
    self = %orig;
    if (self) {
        [self setHidden:YES];
        [self setAlpha:0];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self) {
        [self setHidden:YES];
        [self setAlpha:0];
        [self setUserInteractionEnabled:NO];
    }
    return self;
}

- (void)didMoveToWindow {
    %orig;
    [self setHidden:YES];
    [self setAlpha:0];
}

- (void)setHidden:(BOOL)hidden {
    %orig(YES); // Luôn ẩn
}

- (void)setAlpha:(CGFloat)alpha {
    %orig(0); // Luôn trong suốt
}

%end

// ========== HOOK 2: Education View ==========
%hook MSGQuicksnapScreenCaptureProtectionEducationView

- (void)didMoveToWindow {
    %orig;
    [self setHidden:YES];
    [self setAlpha:0];
}

%end

// ========== HOOK 3: UIScreen.isCaptured (CHÍ MẠNG) ==========
%hook UIScreen

- (BOOL)isCaptured {
    return NO; // Đánh lừa: không ai đang quay
}

%end

// ========== HOOK 4: Chặn Screenshot Notification ==========
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

%ctor {
    NSLog(@"[ScreenCaptureBypass] v3.1 Active!");
}
