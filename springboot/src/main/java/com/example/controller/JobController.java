package com.example.controller;

import com.example.common.Result;
import com.example.entity.BrowsingHistory;
import com.example.entity.Job;
import com.example.mapper.JobMapper;
import com.example.service.BrowsingHistoryService;
import com.example.service.JobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
@RestController
@RequestMapping("/api/job")
public class JobController {

    @Autowired
    private JobService jobService;

    @Autowired
    private BrowsingHistoryService browsingHistoryService;

    @Autowired
    private JobMapper jobMapper;


    /** 最新岗位 */
    @GetMapping("/latest")
    public Result<List<Job>> latestJobs() {
        return Result.success(jobService.getAllJobsWithCompany().stream()
                .limit(10)
                .toList());
    }


    /** 热门岗位 */
    @GetMapping("/hot")
    public Result<List<Job>> hotJobs() {

        List<Map<String, Object>> hotList = jobMapper.selectHotJobIds();

        if (hotList.isEmpty()) {
            return Result.success(jobService.getAllJobsWithCompany().stream()
                    .limit(10)
                    .toList());
        }

        List<Long> jobIds = hotList.stream()
                .map(m -> ((Number) m.get("job_id")).longValue())
                .toList();

        List<Job> jobs = jobIds.stream()
                .map(jobService::getJobDetail)
                .toList();

        return Result.success(jobs);
    }


    /** 推荐岗位 */
    @GetMapping("/recommend/{studentId}")
    public Result<List<Job>> recommend(@PathVariable Long studentId) {

        List<BrowsingHistory> history = browsingHistoryService.lambdaQuery()
                .eq(BrowsingHistory::getStudentId, studentId)
                .orderByDesc(BrowsingHistory::getUpdateTime)
                .list();

        if (history.isEmpty()) {
            return Result.success(jobService.getAllJobsWithCompany().stream()
                    .limit(10)
                    .toList());
        }

        List<Long> jobIds = history.stream()
                .map(BrowsingHistory::getJobId)
                .toList();

        List<Job> viewedJobs = jobIds.stream()
                .map(jobService::getJobDetail)
                .toList();

        List<Long> categoryIds = viewedJobs.stream()
                .map(Job::getCategoryId)
                .distinct()
                .toList();

        List<Job> recommend = jobService.lambdaQuery()
                .in(Job::getCategoryId, categoryIds)
                .notIn(Job::getId, jobIds)
                .orderByDesc(Job::getCreateTime)
                .last("LIMIT 10")
                .list();

        return Result.success(recommend);
    }


    /** 所有岗位（含公司信息） */
    @GetMapping("/all")
    public Result<List<Job>> allJobs() {
        return Result.success(jobService.getAllJobsWithCompany());
    }


    /** 公司岗位 */
    @GetMapping("/company/{companyId}")
    public Result<List<Job>> listByCompany(@PathVariable Long companyId) {
        return Result.success(jobService.lambdaQuery()
                .eq(Job::getCompanyId, companyId)
                .eq(Job::getStatus, 1)
                .orderByDesc(Job::getCreateTime)
                .list());
    }


    /** 岗位详情（含公司信息） */
    @GetMapping("/{id}")
    public Result<Job> getById(@PathVariable Long id) {
        Job job = jobService.getJobDetail(id);

        if (job == null) return Result.error("该岗位不存在");
        if (job.getStatus() == 0) return Result.error("该岗位已停止招聘");

        return Result.success(job);
    }
}
