package com.example.controller;

import com.example.common.Result;
import com.example.entity.Job;
import com.example.service.JobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/job")
public class JobController {

    @Autowired
    private JobService jobService;

    @GetMapping("/company/{companyId}")
    public Result<List<Job>> listByCompany(@PathVariable Long companyId) {
        List<Job> jobs = jobService.lambdaQuery()
                .eq(Job::getCompanyId, companyId)
                .eq(Job::getStatus, 1)
                .orderByDesc(Job::getCreateTime)
                .list();

        return Result.success(jobs);
    }

    @GetMapping("/{id}")
    public Result<Job> getById(@PathVariable Long id) {
        // 直接调用 MyBatis-Plus 提供的 getById 方法
        Job job = jobService.getById(id);

        if (job == null) {
            return Result.error("该岗位信息不存在");
        }

        // 如果你需要在这个接口做状态判断（如：下架的职位不能看详情）
        if (job.getStatus() == 0) {
            return Result.error("该岗位已停止招聘");
        }

        return Result.success(job);
    }
    @GetMapping("/latest")
    public Result<List<Job>> latestJobs() {
        List<Job> list = jobService.lambdaQuery()
                .orderByDesc(Job::getCreateTime)
                .last("LIMIT 10")   // ⭐ 取最新 10 条
                .list();

        return Result.success(list);
    }

}
