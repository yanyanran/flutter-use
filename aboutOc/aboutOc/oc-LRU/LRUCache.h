//
//  LRUCache.h
//  aboutOc
//
//  Created by yanran on 2024/5/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LRUCache : NSObject

+(instancetype)shard;

/// 创建/重置方法
/// @param maxCount 最大缓存数量
-(void)initOrResetWithMaxCount:(int)maxCount;

/// 添加缓存
-(void)addWithKey:(NSString *)key value:(id)value;

/// 根据key删除数据
-(void)removeWithKey:(NSString *)key;

/// 根据key获取数据
-(id)getDataWithKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
