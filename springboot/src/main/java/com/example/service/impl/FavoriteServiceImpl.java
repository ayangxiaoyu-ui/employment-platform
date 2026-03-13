package com.example.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.Favorite;
import com.example.mapper.FavoriteMapper;
import com.example.service.FavoriteService;
import org.springframework.stereotype.Service; // 必须导入这个

@Service // <--- 检查这里有没有写！！！
public class FavoriteServiceImpl extends ServiceImpl<FavoriteMapper, Favorite> implements FavoriteService {
}