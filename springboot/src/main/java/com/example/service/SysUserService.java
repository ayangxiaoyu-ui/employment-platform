package com.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.entity.SysUser;

public interface SysUserService extends IService<SysUser> {
    SysUser register(SysUser user);
    String login(String username, String password, String role);
}