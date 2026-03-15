package com.example.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.common.Result;
import com.example.entity.Guide;
import com.example.service.GuideService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/guide")
public class GuideController {

    @Autowired
    private GuideService guideService;

    /** 发布就业指导文章 */
    @PostMapping
    public Result<?> add(@RequestBody Guide guide) {
        guideService.save(guide);
        return Result.success();
    }

    /** 全部就业指导 */
    @GetMapping("/list")
    public Result<?> list() {
        List<Guide> list = guideService.list(
                new QueryWrapper<Guide>()
                        .orderByDesc("create_time")
        );
        return Result.success(list);
    }

    /** 最新 5 条就业指导 */
    @GetMapping("/latest")
    public Result<?> latest() {
        List<Guide> list = guideService.list(
                new QueryWrapper<Guide>()
                        .orderByDesc("create_time")
                        .last("LIMIT 5")
        );
        return Result.success(list);
    }

    /** 详情（浏览量 +1） */
    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        Guide guide = guideService.getById(id);
        guide.setViewCount(guide.getViewCount() + 1);
        guideService.updateById(guide);
        return Result.success(guide);
    }
}
