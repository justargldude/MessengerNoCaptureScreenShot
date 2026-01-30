// Tweak.xm - ScreenCaptureBypass v2.0 (Safe Edition)
#import <UIKit/UIKit.h>
// ========== SETTINGS TOGGLE ==========
#define PLIST_PATH                                                             \
  @"/var/mobile/Library/Preferences/com.yourname.screencapturebypass.plist"
static BOOL isEnabled() {
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
  if (!dict)
    return YES; // Mặc định BẬT nếu chưa có file
  return [dict[@"isEnabled"] boolValue];
}
static BOOL shouldBlockNotification() {
  NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PLIST_PATH];
  if (!dict)
    return YES;
  return [dict[@"blockNotification"] boolValue];
}
// ========== HOOK 1: Protected View (AN TOÀN) ==========
% hook MSGQuicksnapScreenCaptureProtectedView
    // ✅ SAFE: Cho tạo bình thường, nhưng ẩn ngay lập tức
    - (instancetype)init {
  self = % orig;
  if (self && isEnabled()) {
    [self setHidden:YES];
    [self setAlpha:0];
    [self setUserInteractionEnabled:NO];
  }
  return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
  self = % orig;
  if (self && isEnabled()) {
    [self setHidden:YES];
    [self setAlpha:0];
    [self setUserInteractionEnabled:NO];
  }
  return self;
}
- (void)didMoveToWindow {
  % orig;
  if (isEnabled()) {
    [self setHidden:YES];
    [self setAlpha:0];
  }
}
- (void)layoutSubviews {
  % orig;
  if (isEnabled()) {
    [self setHidden:YES];
    [self setAlpha:0];
  }
}
- (void)setHidden:(BOOL)hidden {
  % orig(isEnabled() ? YES : hidden);
}
- (void)setAlpha:(CGFloat)alpha {
  % orig(isEnabled() ? 0 : alpha);
}
%
        end
        // ========== HOOK 2: Education View (AN TOÀN) ==========
        % hook MSGQuicksnapScreenCaptureProtectionEducationView -
    (instancetype)init {
  self = % orig;
  if (self && isEnabled()) {
    [self setHidden:YES];
    [self setAlpha:0];
  }
  return self;
}
- (void)didMoveToWindow {
  % orig;
  if (isEnabled()) {
    [self setHidden:YES];
  }
}
%
        end
        // ========== HOOK 3: UIScreen.isCaptured (CHÍ MẠNG) ==========
        % hook UIScreen -
    (BOOL)isCaptured {
  if (isEnabled()) {
    return NO; // Đánh lừa: "Không ai đang quay màn hình"
  }
  return % orig;
}
%
        end
        // ========== HOOK 4: Chặn Screenshot Notification (ẨN DANH) ==========
        % hook NSNotificationCenter -
    (void)addObserver : (id)observer selector : (SEL)aSelector name
    : (NSNotificationName)aName object : (id)anObject {

  if (shouldBlockNotification()) {
    // Chặn đăng ký lắng nghe -> Người kia không biết bạn chụp
    if ([aName isEqualToString:
                   @"UIApplicationUserDidTakeScreenshotNotification"] ||
        [aName isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
      return;
    }
  }
  % orig;
}
// Block cả phương thức mới của iOS 15+
- (id)addObserverForName:(NSNotificationName)name
                  object:(id)obj
                   queue:(NSOperationQueue *)queue
              usingBlock:(void (^)(NSNotification *))block {

  if (shouldBlockNotification()) {
    if ([name isEqualToString:
                  @"UIApplicationUserDidTakeScreenshotNotification"] ||
        [name isEqualToString:@"UIScreenCapturedDidChangeNotification"]) {
      return nil;
    }
  }
  return % orig;
}
% end % ctor {
  NSLog(@"[ScreenCaptureBypass] v2.0 Loaded! Enabled: %@",
        isEnabled() ? @"YES" : @"NO");
}