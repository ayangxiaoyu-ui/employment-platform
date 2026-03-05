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
}
