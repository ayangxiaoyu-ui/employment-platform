package com.example.service.impl;

import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.digest.BCrypt;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.common.exception.CustomException;
import com.example.entity.Company;
import com.example.entity.Student;
import com.example.entity.SysUser;
import com.example.mapper.CompanyMapper;
import com.example.mapper.StudentMapper;
import com.example.mapper.SysUserMapper;
import com.example.service.SysUserService;
import com.example.utils.JwtUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SysUserServiceImpl extends ServiceImpl<SysUserMapper, SysUser> implements SysUserService {

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private CompanyMapper companyMapper;

    /**
     * 用户注册
     * - 校验用户名是否重复
     * - 密码加密（默认123456）
     * - 保存用户
     * - 根据角色初始化 student/company 表记录，并将 name 默认设为 username
     */
    @Override
    @Transactional
    public SysUser register(SysUser user) {
        // 1. 校验用户名是否已存在
        SysUser existUser = this.getOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, user.getUsername()));
        if (existUser != null) {
            throw new CustomException("用户名已存在");
        }

        // 2. 密码加密
        if (StrUtil.isBlank(user.getPassword())) {
            user.setPassword("123456"); // 默认密码
        }
        user.setPassword(BCrypt.hashpw(user.getPassword()));

        // 3. 保存用户（此时 user.id 会自动生成）
        this.save(user);

        // 4. 根据角色初始化关联表数据
        if ("STUDENT".equals(user.getRole())) {
            Student student = new Student();
            student.setUserId(user.getId());
            student.setName(user.getUsername());           // 默认姓名 = 登录用户名
            studentMapper.insert(student);
        } else if ("COMPANY".equals(user.getRole())) {
            Company company = new Company();
            company.setUserId(user.getId());
            company.setName(user.getUsername());           // 默认企业名 = 登录用户名
            companyMapper.insert(company);
        }

        return user;
    }

    /**
     * 用户登录
     * - 支持前端传 role 进行校验（可选）
     * - 校验用户名、密码、账号状态
     * - 如果传了 role，则必须匹配用户实际角色
     * - 生成并返回 token
     */
    @Override
    public String login(String username, String password, String role) {
        // 1. 查找用户
        SysUser user = this.getOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, username));
        if (user == null) {
            throw new CustomException("用户不存在");
        }

        // 2. 校验密码
        if (!BCrypt.checkpw(password, user.getPassword())) {
            throw new CustomException("密码错误");
        }

        // 3. 校验账号状态
        if (user.getStatus() == 0) {
            throw new CustomException("账号已被禁用");
        }

        // 4. 如果前端传了 role，则校验是否匹配
        if (StrUtil.isNotBlank(role) && !role.equals(user.getRole())) {
            throw new CustomException("角色不匹配，请选择正确的身份登录");
        }

        // 5. 生成 token（使用用户真实的 role）
        return JwtUtils.createToken(user.getId(), user.getUsername(), user.getRole());
    }
}