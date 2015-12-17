//
//  ViewController.m
//  AMapParserDemo
//
//  Created by Junan on 15/12/16.
//  Copyright © 2015年 mapdemo.zmy. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface ViewController ()<MAMapViewDelegate,AMapSearchDelegate>
{
    MAMapView *_mapView;
    AMapSearchAPI *_search;
    NSInteger successTimes;
    NSInteger failTimes;
    
    NSInteger finshTimes;
    
    NSArray *companysArray;
    NSMutableArray *companyOperateArray;
    
    NSMutableArray *resultArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    successTimes = 0;
    failTimes = 0;
    finshTimes = 0;
    
    companysArray = [[NSArray alloc] init];
    companyOperateArray = [[NSMutableArray alloc] init];
    resultArray = [[NSMutableArray alloc] init];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view, typically from a nib.
    
    //配置用户Key
    [MAMapServices sharedServices].apiKey = @"4bcb5c61c589a8bb4289723a1de60dd6";

    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-20)];
    _mapView.delegate = self;

    [self.view addSubview:_mapView];
    
    //附加设置
    _mapView.language = MAMapLanguageEn;
    
//    杭州市江干区 杭州市江干区凤起东路338号凤起时代大厦1801
    [AMapSearchServices sharedServices].apiKey = @"4bcb5c61c589a8bb4289723a1de60dd6";
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
#if 0
//    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
//    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
//    request.location = [AMapGeoPoint locationWithLatitude:30.27948 longitude:120.158944];
//    request.keywords = @"杭州萧山朗朗卫浴洁具厂";
//    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
//    // POI的类型共分为20种大类别，分别为：
//    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
//    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
//    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
//    request.types = @"公司企业|地名地址信息";
//    request.sortrule = 0;
//    request.requireExtension = YES;
//
//    //发起周边搜索
//    [_search AMapPOIAroundSearch: request];
    
#else
    
    [self readTxt];
    [self doTask];
#endif
}

- (void) doTask {
    if ([companyOperateArray count] > 0) {
        //构造AMapGeocodeSearchRequest对象，address为必选项，city为可选项
        AMapGeocodeSearchRequest *geo = [[AMapGeocodeSearchRequest alloc] init];
        geo.address = [NSString stringWithFormat:@"%@", [companyOperateArray firstObject]];
        geo.city = @"杭州";
        //发起正向地理编码
        [_search AMapGeocodeSearch: geo];
    } else {
        [self writeTxt];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - AMapSearchDelegate
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}

/**
 *  地理编码查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapGeocodeSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapGeocodeSearchResponse 。
 */
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    if(response.geocodes.count == 0) {
        failTimes++;
        NSLog(@"failTimes:%zi", failTimes);
        return;
    } else {
        successTimes++;
//        NSLog(@"successTimes:%zi", successTimes);
    }
    
    AMapTip *p = [response.geocodes firstObject];
    
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = p.location;
    regeo.radius = 10000;
    regeo.requireExtension = YES;

    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeo];
}

/**
 *  逆地理编码查询回调函数
 *
 *  @param request  发起的请求，具体字段参考 AMapReGeocodeSearchRequest 。
 *  @param response 响应结果，具体字段参考 AMapReGeocodeSearchResponse 。
 */
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response {
    if(response.regeocode != nil)
    {
        //通过AMapReGeocodeSearchResponse对象处理搜索结果
        [resultArray addObject:response.regeocode.formattedAddress];
        
        [companyOperateArray removeObjectAtIndex:0];
        
        finshTimes++;
        NSLog(@"ReGeo: success! %zi", finshTimes);
        
        [self doTask];

    } else {
        NSLog(@"ReGeo: failed!");
    }
}

#pragma mark - Private Method
//- (void)addToPlist {
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    //获取完整路径
//    NSString *documentsPath = [path objectAtIndex:0];
//    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"company.plist"];
//    
//    NSMutableArray *array = [[NSMutableArray alloc] init];
//    for (int i = 0; i <10; i++) {
//        NSMutableDictionary *compDic = [[NSMutableDictionary alloc] init];
//        //设置属性值
//        [compDic setObject:@"大真大服装店" forKey:@"name"];
//        [compDic setObject:@"武林路" forKey:@"address"];
//        
//        [array addObject:compDic];
//    }
//    
//    //写入文件
//    [array writeToFile:plistPath atomically:YES];
//    
////    NSLog(@"plistPath:%@", plistPath);
////    NSLog(@"content:%@", array);
//}

//- (void)readPlist {
//    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    //获取完整路径
//    NSString *documentsPath = [path objectAtIndex:0];
//    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"company.plist"];
//    
//    //读文件
//    companysArray = [NSArray arrayWithContentsOfFile:plistPath];
//    
////    for (NSDictionary *dict in companysArray) {
////        NSLog(@"plistPath:%@", [dict objectForKey:@"name"]);
////        NSLog(@"content:%@", [dict objectForKey:@"address"]);
////    }
//}

- (void)readTxt {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"company" ofType:@"txt"];
    
    NSError *error;
    companysArray = [[NSString stringWithContentsOfFile:filePath
              encoding:NSUTF8StringEncoding
              error:&error]
             componentsSeparatedByString:@"\r"];
    companyOperateArray = [[NSMutableArray alloc] initWithArray:companysArray];
}

//- (void)readTxtLocation {
//    //    NSArray *lines; /*将文件转化为一行一行的*/
//    NSString *filePath = @"/Users/junan/Desktop/result/Location.txt";
//    
//    NSError *error;
//    readLocationArray = [[NSString stringWithContentsOfFile:filePath
//                                               encoding:NSUTF8StringEncoding
//                                                  error:&error]
//                     componentsSeparatedByString:@"\r"];
//}

//- (void)writeTxtLocation {
//    //    NSArray *lines; /*将文件转化为一行一行的*/
//    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"company2" ofType:@"txt"];
//    NSString *filePath = @"/Users/junan/Desktop/result/Location.txt";
//    
//    NSString *content = @"";
//    BOOL firstLine = YES;
//    for (NSString *temp in resultLocationArray ) {
//        if (!firstLine) {
//            content = [content stringByAppendingString: @"\r"];
//        } else {
//            firstLine = NO;
//        }
//        content = [content stringByAppendingString: temp];
//    }
//    
//    //文件不存在会自动创建，文件夹不存在则不会自动创建会报错
//    
//    NSError *error;
//    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
//    if (error) {
//        NSLog(@"导出失败:%@",error);
//    }else{
//        NSLog(@"导出成功");
//    }
//}


- (void)writeTxt {
    NSString *filePath = @"/Users/junan/Desktop/result/company2.txt";
    
    NSString *content = @"";
    for (NSString *temp in resultArray ) {
        content = [content stringByAppendingString: temp];
        content = [content stringByAppendingString: @"\r"];
    }

    //文件不存在会自动创建，文件夹不存在则不会自动创建会报错
    NSError *error;
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"导出失败:%@",error);
    }else{
        NSLog(@"导出成功");
    }
}
@end
