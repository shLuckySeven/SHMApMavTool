//
//  SHAMapTool.h
//  shuhuan
//
//  Created by shuhuan on 16/11/7.
//  Copyright © 2016年 shuhuan. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    SHMapNavigationTypeWalk,//步行规划
    SHMapNavigationTypeDriving,//驾车规划
} TGMapNavigationType;

@interface SHAMapTool : NSObject

+(CGFloat)getDistanceWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude latitude2:(CGFloat)latitude2 longitude2:(CGFloat)longitude2;

//+(void)startNavWithEndLocation:(CLLocationCoordinate2D)endLocation viewController:(UIViewController*)viewController;

+(void)startNavWithEndLocation:(CLLocationCoordinate2D)endLocation viewController:(UIViewController*)viewController type:(SHMapNavigationType)type;

@end
