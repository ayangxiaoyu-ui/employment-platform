package com.example.controller;

import cn.hutool.jwt.JWT;
import com.example.common.Result;
import com.example.entity.Company;
import com.example.service.CompanyService;
import com.example.utils.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @Autowired
    private CompanyService companyService;

    @GetMapping("/me")
    public Result<Map<String, Object>> getMe(@RequestHeader("Authorization") String token) {

        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }

        JWT jwt = JwtUtils.parse(token);
        Long userId = ((Number) jwt.getPayload("userId")).longValue();
        String role = (String) jwt.getPayload("role");

        Map<String, Object> data = new HashMap<>();
        data.put("userId", userId);
        data.put("role", role);

        if ("COMPANY".equals(role)) {
            Company company = companyService.getByUserId(userId);
            data.put("companyId", company != null ? company.getId() : null);
        }

        return Result.success(data);
    }
}
