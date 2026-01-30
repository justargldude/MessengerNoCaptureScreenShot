// Tweak.xm - ScreenCaptureBypass v2.0 (Fixed Forward Declaration)
#import <UIKit/UIKit.h>

// ========== FORWARD DECLARATIONS ==========
// Khai báo interface để compiler biết các method
@interface MSGQuicksnapScreenCaptureProtectedView : UIView
@end

@interface MSGQuicksnapScreenCaptureProtectionEducationView : UIView
@end

// ========== SETTINGS TOGGLE ==========
#define PLIST_PATH @"/var/mobile/Library/Preferences/com.yourname.screencapturebypass.plist"

static BOOL isEnabled() {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
    if (!dict) return YES; // Mặc định BẬT nếu chưa có file
    return [dict[@"isEnabled"] boolValue];
}

static BOOL shouldBlockNotification() {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
    if (!dict) return YES;
    return [dict[@"blockNotification"] boolValue];
}

// ========== HOOK 1: Protected View (AN TOÀN) ==========
%hook MSGQuicksnapScreenCaptureProtectedView

// ✅ SAFE: Cho tạo bình thường, nhưng ẩn ngay lập tức
- (instancetype)init {
    self = %orig;
    if (self && isEnabled()) {
        self.hidden = YES;
        self.alpha = 0;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = %orig;
    if (self && isEnabled()) {
        self.hidden = YES;
        self.alpha = 0;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)didMoveToWindow {
    %orig;
    if (isEnabled()) {
        self.hidden = YES;
        self.alpha = 0;
    }
}

- (void)layoutSubviews {
    %orig;
    if (isEnabled()) {
        self.hidden = YES;
        self.alpha = 0;
    }
}

- (void)setHidden:(BOOL)hidden {
    if (isEnabled()) {
        if (!hidden) { // Chỉ can thiệp khi app muốn HIỆN view
            %orig(YES); // Ép ẨN
            return;
        }
    }
    %orig(hidden);
}

- (void)setAlpha:(CGFloat)alpha {
    if (isEnabled()) {
        if (alpha > 0) { // Chỉ can thiệp khi app muốn HIỆN
            %orig(0);
            return;
        }
    }
    %orig(alpha);
}

%end

// ========== HOOK 2: Education View (AN TOÀN) ==========
%hook MSGQuicksnapScreenCaptureProtectionEducationView

- (instancetype)init {
    self = %orig;
    if (self && isEnabled()) {
        self.hidden = YES;
        self.alpha = 0;
    }
    return self;
}

- (void)didMoveToWindow {
    %orig;
    if (isEnabled()) {
        self.hidden = YES;
    }
}

%end

// ========== HOOK 3: UIScreen.isCaptured (CHÍ MẠNG) ==========
%hook UIScreen

- (BOOL)isCaptured {
    if (isEnabled()) {
        // CHỈ áp dụng cho Messenger
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        if ([bundleID containsString:@"messenger"] || 
            [bundleID containsString:@"facebook"]) {
            return NO; // Đánh lừa: "Không ai đang quay màn hình"
        }
    }
    return %orig;
}

%end

// ========== HOOK 4: Chặn Screenshot Notification (ẨN DANH) ==========
%hook NSNotificationCenter

- (void)addObserver:(id)observer 
           selector:(SEL)aSelector 
               name:(NSNotificationName)aName 
             object:(id)anObject {
    
    if (shouldBlockNotification() && aName != nil) {
        // Chỉ chặn khi observer THUỘC Messenger
        NSString *className = NSStringFromClass([observer class]);
        BOOL isMessengerClass = [className hasPrefix:@"MSG"] || 
                               [className hasPrefix:@"FB"] ||
                               [className containsString:@"Messenger"];
        
        if (isMessengerClass) {
            if ([aName isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"] ||
                [aName isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
                NSLog(@"[ScreenCaptureBypass] Blocked notification: %@ for %@", aName, className);
                return; // Không đăng ký
            }
        }
    }
    %orig;
}

// Block cả phương thức mới của iOS 15+
- (id)addObserverForName:(NSNotificationName)name 
                  object:(id)obj 
                   queue:(NSOperationQueue *)queue 
              usingBlock:(void (^)(NSNotification *))block {
    
    if (shouldBlockNotification() && name != nil) {
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        if ([bundleID containsString:@"messenger"] || 
            [bundleID containsString:@"facebook"]) {
            
            if ([name isEqualToString:@"UIApplicationUserDidTakeScreenshotNotification"] ||
                [name isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
                NSLog(@"[ScreenCaptureBypass] Blocked block-based notification: %@", name);
                return nil;
            }
        }
    }
    return %orig;
}

%end

%ctor {
    NSLog(@"[ScreenCaptureBypass] v2.0 Loaded! Enabled: %@", isEnabled() ? @"YES" : @"NO");
}
