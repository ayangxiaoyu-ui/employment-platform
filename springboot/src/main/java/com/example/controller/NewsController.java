package com.example.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.common.Result;
import com.example.entity.News;
import com.example.service.NewsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/news")
public class NewsController {

    @Autowired
    private NewsService newsService;

    /** 公告列表（按时间倒序） */
    @GetMapping("/list")
    public Result<?> list() {
        List<News> list = newsService.list(
                new QueryWrapper<News>().orderByDesc("create_time")
        );
        return Result.success(list);
    }

    /** 公告详情（浏览量 +1） */
    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        News news = newsService.getById(id);
        news.setViewCount(news.getViewCount() + 1);
        newsService.updateById(news);
        return Result.success(news);
    }
}
