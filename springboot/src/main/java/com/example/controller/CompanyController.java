package com.example.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.example.common.Result;
import com.example.entity.Company;
import com.example.service.CompanyService;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.List;

@RestController
@RequestMapping("/api/company")
public class CompanyController {

    private final CompanyService companyService;

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
            companyService.save(company);
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
        }
        company.setUserId(userId);

        companyService.saveOrUpdate(company);
        return Result.success();
    }

    // ⭐ 获取所有企业信息
    @GetMapping("/list")
    public Result<List<Company>> listAll() {
        return Result.success(companyService.list());
    }

    // ⭐ 分页查询企业信息（可选）
    @GetMapping("/page")
    public Result<IPage<Company>> page(
            @RequestParam(defaultValue = "1") Integer pageNum,
            @RequestParam(defaultValue = "10") Integer pageSize) {

        Page<Company> page = new Page<>(pageNum, pageSize);
        return Result.success(companyService.page(page));
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
