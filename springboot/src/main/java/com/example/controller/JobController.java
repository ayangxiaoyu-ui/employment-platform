package com.example.controller;

import cn.hutool.jwt.JWT;
import com.example.common.Result;
import com.example.entity.BrowsingHistory;
import com.example.entity.Job;
import com.example.mapper.JobMapper;
import com.example.service.BrowsingHistoryService;
import com.example.service.JobService;
import com.example.utils.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
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

    /** 所有岗位 */
    @GetMapping("/all")
    public Result<List<Job>> allJobs() {
        return Result.success(jobService.getAllJobsWithCompany());
    }
//统一的筛选接口 /api/job/filter
    @GetMapping("/filter")
    public Result<List<Job>> filter(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) Long categoryId
    ) {
        return Result.success(jobService.filterJobs(keyword, categoryId));
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

    @PostMapping("/create")
    public Result<?> createJob(
            @RequestBody Job job,
            @RequestHeader("Authorization") String token
    ) {
        // 去掉 Bearer 前缀
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }

        // 解析 token
        JWT jwt = JwtUtils.parse(token);

        Long companyId = ((Number) jwt.getPayload("userId")).longValue();
        String role = (String) jwt.getPayload("role");

        if (!"COMPANY".equals(role)) {
            return Result.error("非企业账号无法发布岗位");
        }

        job.setCompanyId(companyId);
        job.setStatus(1);
        job.setCreateTime(new Date());
        job.setUpdateTime(new Date());

        boolean ok = jobService.save(job);

        return ok ? Result.success("发布成功") : Result.error("发布失败");
    }


    /** 岗位详情 */
    @GetMapping("/{id}")
    public Result<Job> getById(@PathVariable Long id) {
        Job job = jobService.getJobDetail(id);

        if (job == null) return Result.error("该岗位不存在");
        if (job.getStatus() == 0) return Result.error("该岗位已停止招聘");

        return Result.success(job);
    }
}
