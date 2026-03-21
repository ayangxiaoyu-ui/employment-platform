package com.example.controller;

import cn.hutool.jwt.JWT;
import com.example.common.Result;
import com.example.entity.*;
import com.example.service.*;
import com.example.vo.ResumeInboxVO;
import com.example.utils.JwtUtils;
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
    private StudentService studentService;

    @Autowired
    private ResumeService resumeService;


    @Autowired
    private ApplicationService applicationService;



    @PostMapping("/mark-read")
    public Result<Void> markRead(@RequestBody Application application) {

        Long applicationId = application.getId();  // ← 必须用 getId()

        if (applicationId == null) {
            return Result.error("缺少 applicationId");
        }

        boolean ok = applicationService.lambdaUpdate()
                .eq(Application::getId, applicationId)
                .set(Application::getStatus, 1)
                .update();

        return ok ? Result.success() : Result.error("标记失败");
    }


    /** 企业简历收件箱 */
    @GetMapping("/inbox")
    public Result<List<ResumeInboxVO>> inbox(@RequestHeader("Authorization") String token) {

        // 去掉 Bearer
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }

        JWT jwt = JwtUtils.parse(token);
        Long userId = ((Number) jwt.getPayload("userId")).longValue();
        String role = (String) jwt.getPayload("role");

        if (!"COMPANY".equals(role)) {
            return Result.error("非企业账号无法查看收件箱");
        }

        // 关键修复：根据 userId 查 companyId
        Company company = companyService.lambdaQuery()
                .eq(Company::getUserId, userId)
                .one();

        if (company == null) {
            return Result.error("企业信息不存在");
        }

        Long companyId = company.getId();

        // 查询该企业所有岗位的投递记录
        List<Application> apps = applicationService.lambdaQuery()
                .inSql(Application::getJobId,
                        "SELECT id FROM job WHERE company_id = " + companyId)
                .orderByDesc(Application::getCreateTime)
                .list();
        // 转换为 VO
        List<ResumeInboxVO> result = apps.stream().map(app -> {
            ResumeInboxVO vo = new ResumeInboxVO();
            vo.setApplicationId(app.getId());
            vo.setResumeId(app.getResumeId());
            vo.setStatus(app.getStatus());
            vo.setCreateTime(app.getCreateTime().toString());

            // 岗位信息
            Job job = jobService.getById(app.getJobId());
            if (job != null) {
                vo.setJobTitle(job.getTitle());
            }

            // 学生信息
            Student stu = studentService.getById(app.getStudentId());
            if (stu != null) {
                vo.setStudentName(stu.getName());
            }

            // 简历信息
            Resume resume = resumeService.getById(app.getResumeId());
            if (resume != null) {
                vo.setResumeUrl(resume.getFileUrl());
            }

            return vo;
        }).toList();

        return Result.success(result);
    }


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
