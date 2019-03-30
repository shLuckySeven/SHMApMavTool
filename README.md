# SHMApMavTool
地图开发中常用的app内跳转到对应的map应用工具类

### 使用的时候，导入SHAMapTool头文件，调用：
+(void)startNavWithEndLocation:(CLLocationCoordinate2D)endLocation viewController:(UIViewController*)viewController type:(SHMapNavigationType)type; 方法
#### 根据 SHMapNavigationType 导航的策略，选择传入对应的枚举值即可：
#### typedef enum : NSUInteger {
    SHMapNavigationTypeWalk,//步行规划
    SHMapNavigationTypeDriving,//驾车规划
    } SHMapNavigationType;
