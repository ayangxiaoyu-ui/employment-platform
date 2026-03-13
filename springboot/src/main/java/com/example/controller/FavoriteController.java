package com.example.controller;

import com.example.common.Result;
import com.example.entity.Favorite;
import com.example.entity.Job;
import com.example.mapper.FavoriteMapper;
import com.example.service.FavoriteService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/favorite")
public class FavoriteController {

    @Autowired
    private FavoriteService favoriteService;

    @Autowired
    private FavoriteMapper favoriteMapper;

    /**
     * 切换收藏状态 (Toggle)
     * 如果已收藏则取消，未收藏则添加
     */
    @PostMapping("/toggle")
    public Result<Boolean> toggle(@RequestBody Favorite favorite) {
        if (favorite.getStudentId() == null || favorite.getJobId() == null) {
            return Result.error("参数缺失");
        }

        // 1. 查询是否已经收藏
        Favorite one = favoriteService.lambdaQuery()
                .eq(Favorite::getStudentId, favorite.getStudentId())
                .eq(Favorite::getJobId, favorite.getJobId())
                .one();

        if (one != null) {
            // 2. 已收藏 -> 取消收藏
            favoriteService.removeById(one.getId());
            return Result.success(false); // 返回 false 表示当前是不收藏状态
        } else {
            // 3. 未收藏 -> 添加收藏
            favoriteService.save(favorite);
            return Result.success(true); // 返回 true 表示当前是已收藏状态
        }
    }

    /**
     * 获取当前职位的收藏状态
     * 用于页面初始化时判断星星是否需要点亮
     */
    @GetMapping("/status")
    public Result<Boolean> getStatus(@RequestParam Long studentId, @RequestParam Long jobId) {
        long count = favoriteService.lambdaQuery()
                .eq(Favorite::getStudentId, studentId)
                .eq(Favorite::getJobId, jobId)
                .count();
        return Result.success(count > 0);
    }
    @GetMapping("/my/{studentId}")
    public Result<List<Job>> getMyFavorites(@PathVariable Long studentId) {
        // 使用注入的 mapper 调用方法，不要用 getBaseMapper()
        List<Job> jobs = favoriteMapper.getFavoriteJobs(studentId);
        return Result.success(jobs);
    }

}