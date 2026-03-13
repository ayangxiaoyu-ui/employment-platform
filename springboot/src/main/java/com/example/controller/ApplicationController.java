package com.example.controller;

import com.example.common.Result;
import com.example.entity.Application;
import com.example.entity.Company;
import com.example.entity.Job;
import com.example.service.ApplicationService;
import com.example.service.CompanyService;
import com.example.service.JobService;
import com.example.vo.ApplicationVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/application")
public class ApplicationController {

    @Autowired
    private JobService jobService;

    @Autowired
    private CompanyService companyService;


    @Autowired
    private ApplicationService applicationService;

    @PostMapping("/apply")
    public Result<Void> apply(@RequestBody Application application) {

        // 默认状态：0-待查看
        application.setStatus(0);

        try {
            applicationService.save(application);
            return Result.success();
        } catch (DuplicateKeyException e) {
            return Result.error("你已经投递过该职位了");
        }
    }
    @GetMapping("/student/{studentId}")
    public Result<List<ApplicationVO>> listByStudent(@PathVariable Long studentId) {

        // 1. 查询该学生所有投递记录
        List<Application> apps = applicationService.lambdaQuery()
                .eq(Application::getStudentId, studentId)
                .orderByDesc(Application::getCreateTime)
                .list();

        // 2. 转换为 VO
        List<ApplicationVO> result = apps.stream().map(app -> {
            ApplicationVO vo = new ApplicationVO();
            vo.setApplicationId(app.getId());
            vo.setJobId(app.getJobId());
            vo.setStatus(app.getStatus());
            vo.setCreateTime(app.getCreateTime());

            // 查询岗位信息
            Job job = jobService.getById(app.getJobId());
            if (job != null) {
                vo.setJobTitle(job.getTitle());
                vo.setLocation(job.getLocation());
                vo.setSalaryMin(job.getSalaryMin());
                vo.setSalaryMax(job.getSalaryMax());

                // 查询企业名称
                Company company = companyService.getById(job.getCompanyId());
                if (company != null) {
                    vo.setCompanyName(company.getName());
                }
            }

            return vo;
        }).toList();

        return Result.success(result);
    }

}
