package com.example.controller;

import com.example.common.Result;
import com.example.entity.Application;
import com.example.entity.Job;
import com.example.entity.SysUser;
import com.example.service.ApplicationService;
import com.example.service.CompanyService;
import com.example.service.GuideService;
import com.example.service.JobService;
import com.example.service.MessageService;
import com.example.service.NewsService;
import com.example.service.ResumeService;
import com.example.service.StudentService;
import com.example.service.SysUserService;
import com.example.vo.AdminDashboardVO;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Date;

@RestController
@RequestMapping("/api/admin/dashboard")
public class AdminDashboardController {

    private static final DateTimeFormatter DAY_FMT = DateTimeFormatter.ofPattern("MM-dd");

    @Autowired
    private SysUserService sysUserService;
    @Autowired
    private StudentService studentService;
    @Autowired
    private CompanyService companyService;
    @Autowired
    private JobService jobService;
    @Autowired
    private ApplicationService applicationService;
    @Autowired
    private NewsService newsService;
    @Autowired
    private GuideService guideService;
    @Autowired
    private MessageService messageService;
    @Autowired
    private ResumeService resumeService;

    @GetMapping("/stats")
    public Result<AdminDashboardVO> stats(HttpServletRequest request) {
        if (!"ADMIN".equals(request.getAttribute("role"))) {
            return Result.error("仅管理员可查看数据看板");
        }

        AdminDashboardVO vo = new AdminDashboardVO();

        vo.setStudentUserCount(sysUserService.lambdaQuery()
                .eq(SysUser::getRole, "STUDENT")
                .eq(SysUser::getStatus, 1)
                .count());
        vo.setCompanyUserCount(sysUserService.lambdaQuery()
                .eq(SysUser::getRole, "COMPANY")
                .eq(SysUser::getStatus, 1)
                .count());
        vo.setStudentProfileCount(studentService.count());
        vo.setCompanyProfileCount(companyService.count());
        vo.setOpenJobCount(jobService.lambdaQuery().eq(Job::getStatus, 1).count());
        vo.setTotalJobCount(jobService.count());
        vo.setTotalApplications(applicationService.count());
        vo.setNewsCount(newsService.count());
        vo.setGuideCount(guideService.count());
        vo.setMessageCount(messageService.count());
        vo.setResumeCount(resumeService.count());

        ZoneId zone = ZoneId.systemDefault();
        LocalDate today = LocalDate.now(zone);
        Date weekStart = Date.from(today.minusDays(6).atStartOfDay(zone).toInstant());
        vo.setApplicationsLast7Days(applicationService.lambdaQuery()
                .ge(Application::getCreateTime, weekStart)
                .count());

        for (int i = 6; i >= 0; i--) {
            LocalDate d = today.minusDays(i);
            Date start = Date.from(d.atStartOfDay(zone).toInstant());
            Date end = Date.from(d.plusDays(1).atStartOfDay(zone).toInstant());
            long c = applicationService.lambdaQuery()
                    .ge(Application::getCreateTime, start)
                    .lt(Application::getCreateTime, end)
                    .count();
            vo.getApplicationTrend().add(new AdminDashboardVO.DailyCountVO(d.format(DAY_FMT), c));
        }

        return Result.success(vo);
    }
}
