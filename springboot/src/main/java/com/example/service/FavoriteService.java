package com.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.entity.Favorite;

/**
 * 职位收藏服务接口
 */
public interface FavoriteService extends IService<Favorite> {
    // 如果以后需要复杂的统计逻辑（比如某个职位的收藏总数），在这里定义方法
}