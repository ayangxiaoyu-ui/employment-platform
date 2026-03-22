package com.example.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.common.Result;
import com.example.entity.News;
import com.example.service.NewsService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
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
    //获取最新 5 条公告
    @GetMapping("/latest")
    public Result<?> latest() {
        List<News> list = newsService.list(
                new QueryWrapper<News>()
                        .orderByDesc("create_time")
                        .last("LIMIT 5")
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

    /** 管理员发布公告 */
    @PostMapping("/admin")
    public Result<Void> adminPublish(HttpServletRequest request, @RequestBody News body) {
        if (!"ADMIN".equals(request.getAttribute("role"))) {
            return Result.error("仅管理员可发布公告");
        }
        if (body.getTitle() == null || body.getTitle().isBlank()) {
            return Result.error("标题不能为空");
        }
        if (body.getContent() == null || body.getContent().isBlank()) {
            return Result.error("内容不能为空");
        }
        Object uid = request.getAttribute("userId");
        Long authorId = uid instanceof Number ? ((Number) uid).longValue() : null;

        News news = new News();
        news.setTitle(body.getTitle().trim());
        news.setContent(body.getContent());
        news.setAuthorId(authorId);
        news.setViewCount(0);
        news.setCreateTime(new Date());
        newsService.save(news);
        return Result.success();
    }

    /** 管理员删除公告 */
    @DeleteMapping("/admin/{id}")
    public Result<Void> adminDelete(HttpServletRequest request, @PathVariable Long id) {
        if (!"ADMIN".equals(request.getAttribute("role"))) {
            return Result.error("仅管理员可删除公告");
        }
        if (!newsService.removeById(id)) {
            return Result.error("公告不存在或已删除");
        }
        return Result.success();
    }
}
