package com.example.controller;

import com.example.common.Result;
import com.example.entity.SysUser;
import com.example.service.SysUserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private SysUserService sysUserService;

    @PostMapping("/login")
    public Result<String> login(@RequestBody SysUser user) {
        // 原版：只传 username 和 password
        // String token = sysUserService.login(user.getUsername(), user.getPassword());

        // 修改版：如果 SysUser 里有 role 字段，就传 role；否则传 null
        String token = sysUserService.login(
                user.getUsername(),
                user.getPassword(),
                user.getRole()   // ← 新增：从请求体取 role 传给 service
        );
        return Result.success(token);
    }

    @PostMapping("/register")
    public Result<SysUser> register(@RequestBody SysUser user) {
        return Result.success(sysUserService.register(user));
    }
}