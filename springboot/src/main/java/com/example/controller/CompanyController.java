package com.example.controller;

import com.example.common.Result;
import com.example.entity.Company;
import com.example.service.CompanyService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@RestController
@RequestMapping("/api/company")
public class CompanyController {

    private final CompanyService companyService;

    // 构造器注入（推荐写法）
    public CompanyController(CompanyService companyService) {
        this.companyService = companyService;
    }

    @GetMapping("/profile")
    public Result<Company> getProfile() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return Result.error("未授权");
        }

        Company company = companyService.getByUserId(userId);
        if (company == null) {
            company = new Company();
            company.setUserId(userId);
            companyService.saveOrUpdate(company);
        }
        return Result.success(company);
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody Company company) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return Result.error("未授权");
        }

        Company existing = companyService.getByUserId(userId);
        if (existing != null) {
            company.setId(existing.getId());
            company.setUserId(userId);
        } else {
            company.setUserId(userId);
        }

        companyService.saveOrUpdate(company);
        return Result.success();
    }

    private Long getCurrentUserId() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            Object userId = attributes.getRequest().getAttribute("userId");
            if (userId instanceof Long) {
                return (Long) userId;
            }
        }
        return null;
    }
}