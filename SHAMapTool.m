
//
//  SHAMapTool.m
//  shuhuan
//
//  Created by shuhuan on 16/11/7.
//  Copyright © 2016年 shuhuan. All rights reserved.
//

#import "SHAMapTool.h"
#import <MAMapKit/MAGeometry.h>
#import <MapKit/MapKit.h>
/*
 * https://www.jianshu.com/p/de16b81363e8
 * 地图配置文档
 */

@implementation SHAMapTool

+(CGFloat)getDistanceWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude latitude2:(CGFloat)latitude2 longitude2:(CGFloat)longitude2
{
    
    //1.将两个经纬度点转成投影点
    MAMapPoint point1 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude,longitude));
    MAMapPoint point2 = MAMapPointForCoordinate(CLLocationCoordinate2DMake(latitude2,longitude2));
    //2.计算距离
    CLLocationDistance distance = MAMetersBetweenMapPoints(point1,point2);
    return distance;
    
}



#pragma mark - 跳转外置地图导航
//弹出选择地图Sheet
//+(void)startNavWithEndLocation:(CLLocationCoordinate2D)endLocation  viewController:(UIViewController *)viewController
//{
//
//    NSArray * mapArray =[self getInstalledMapAppWithEndLocation:endLocation];
//
//    UIAlertController *mapSelectActionSheet=[UIAlertController alertControllerWithTitle:nil message:@"请选择地图" preferredStyle:UIAlertControllerStyleActionSheet];
//    // 设置按钮
//    UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
//    for (NSDictionary * dic in mapArray) {
//        UIAlertAction *defultAction = [UIAlertAction actionWithTitle:[dic objectForKey:@"title"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            [self alertAction:dic];
//            DLog(@"点击+++++%@",[dic objectForKey:@"title"]);
//
//        }];
//        [mapSelectActionSheet addAction:defultAction];
//    }
//    [mapSelectActionSheet addAction:cancel];
//    [viewController presentViewController:mapSelectActionSheet animated:YES completion:^{
//    }];
//}

//点击某一个地图
+ (void)alertAction:(NSDictionary *)dic
{
    NSString * str =[dic objectForKey:@"title"];
    
    if ([str isEqualToString:@"苹果自带地图"]){
        CLLocationCoordinate2D GCJLocation = CLLocationCoordinate2DMake([dic[@"latitude"] doubleValue], [dic[@"longitude"] doubleValue]);
        
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:GCJLocation addressDictionary:nil]];
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking,
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        
    }
    else if ([str isEqualToString:@"百度地图"]) {
        DLog(@"点击了————---- %@",str);
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[dic objectForKey:@"url"]]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
        }
    }else if ([str isEqualToString:@"高德地图"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
    }else if ([str isEqualToString:@"谷歌地图"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
    }else if ([str isEqualToString:@"腾讯地图"]){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic objectForKey:@"url"]]];
    }
    
}
//判断当前用户手机上都安装了哪些地图客户端
+ (NSArray *)getInstalledMapAppWithEndLocation:(CLLocationCoordinate2D)endLocation type:(TGMapNavigationType)type
{
    BOOL isWalking =NO;
    if (type ==TGMapNavigationTypeWalk) {
        isWalking =YES;
    }else if (type ==TGMapNavigationTypeDriving){
        isWalking =NO;
    }
    CLLocationCoordinate2D bdLocation = [CommonUtility bd09Encrypt:endLocation.latitude bdLon:endLocation.longitude];//将火星坐标->百度坐标
    
    NSMutableArray *maps = [NSMutableArray array];
    
    //苹果地图
    NSMutableDictionary *iosMapDic = [NSMutableDictionary dictionary];
    iosMapDic[@"title"] = @"苹果自带地图";
    iosMapDic[@"latitude"]=StringFromDouble(endLocation.latitude);
    iosMapDic[@"longitude"]=StringFromDouble(endLocation.longitude);
    [maps addObject:iosMapDic];
    
    //百度地图
    /*
     * http://lbsyun.baidu.com/index.php?title=uri/api/ios
     * 导航模式，固定为transit、driving、navigation、walking，riding分别表示公交、驾车、导航、步行和骑行
     */
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSMutableDictionary *baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] = @"百度地图";
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%lf,%lf|name=目的地&mode=%@&coord_type=bd09ll",bdLocation.latitude,bdLocation.longitude,isWalking?@"walking":@"driving"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        baiduMapDic[@"url"] = urlString;
        [maps addObject:baiduMapDic];
    }
    //高德地图
    /*
     * https://lbs.amap.com/api/amap-mobile/guide/ios/route
     t = 0 驾车；
     t = 1 公交；
     t = 2 步行；
     t = 3 骑行（骑行仅在V788以上版本支持）；
     */
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        
        NSMutableDictionary *gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[@"title"] = @"高德地图";
        //https://lbs.amap.com/api/amap-mobile/guide/ios/route
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=TOGO&sid=BGVIS1&did=BGVIS2&dlat=%lf&dlon=%lf&t=%@",endLocation.latitude, endLocation.longitude,isWalking?@"2":@"0"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        gaodeMapDic[@"url"] = urlString;
        [maps addObject:gaodeMapDic];
    }
    
    //谷歌地图
    /*
     * https://developers.google.com/maps/documentation/ios-sdk/urlscheme
     */
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSMutableDictionary *googleMapDic = [NSMutableDictionary dictionary];
        googleMapDic[@"title"] = @"谷歌地图";
        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%lf,%lf&directionsmode=%@",@"TOGO",@"comgooglemaps",endLocation.latitude, endLocation.longitude,isWalking?@"walking":@"driving"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        googleMapDic[@"url"] = urlString;
        [maps addObject:googleMapDic];
    }
    //腾讯地图
    /*
     * http://lbs.qq.com/uri_v1/guide-route.html
     */
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];
        qqMapDic[@"title"] = @"腾讯地图";
        NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=%@&tocoord=%lf,%lf&to=终点&coord_type=1&policy=0",isWalking?@"walk":@"drive",endLocation.latitude, endLocation.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        qqMapDic[@"url"] = urlString;
        [maps addObject:qqMapDic];
    }
    return maps;
}

+(void)startNavWithEndLocation:(CLLocationCoordinate2D)endLocation viewController:(UIViewController*)viewController type:(TGMapNavigationType)type{
    NSArray * mapArray =[self getInstalledMapAppWithEndLocation:endLocation type:type];
    
    UIAlertController *mapSelectActionSheet=[UIAlertController alertControllerWithTitle:nil message:@"请选择地图" preferredStyle:UIAlertControllerStyleActionSheet];
    // 设置按钮
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    for (NSDictionary * dic in mapArray) {
        UIAlertAction *defultAction = [UIAlertAction actionWithTitle:[dic objectForKey:@"title"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertAction:dic];
            DLog(@"点击+++++%@",[dic objectForKey:@"title"]);
            
        }];
        [mapSelectActionSheet addAction:defultAction];
    }
    [mapSelectActionSheet addAction:cancel];
    [viewController presentViewController:mapSelectActionSheet animated:YES completion:^{
    }];
}



@end
