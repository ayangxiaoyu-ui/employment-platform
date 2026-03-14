package com.example.controller;

import com.example.common.Result;
import com.example.service.BrowsingHistoryService;
import com.example.vo.BrowsingHistoryVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/browsing")
public class BrowsingHistoryController {

    @Autowired
    private BrowsingHistoryService browsingHistoryService;

    // ⭐ 点击职位详情时调用
    @PostMapping("/record")
    public Result<?> record(@RequestParam Long studentId, @RequestParam Long jobId) {
        browsingHistoryService.recordView(studentId, jobId);
        return Result.success();
    }

    // ⭐ 我的足迹页面调用
    @GetMapping("/{studentId}")
    public Result<List<BrowsingHistoryVO>> list(@PathVariable Long studentId) {
        return Result.success(browsingHistoryService.listByStudent(studentId));
    }
}
