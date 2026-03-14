package com.example.service.impl;

import com.example.entity.Student;
import com.example.entity.Company;
import com.example.mapper.StudentMapper;
import com.example.mapper.CompanyMapper;
import com.example.service.UserService;
import com.example.vo.UserInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private StudentMapper studentMapper;

    @Autowired
    private CompanyMapper companyMapper;

    @Override
    public UserInfo getUserInfo(Long id) {
        UserInfo info = new UserInfo();

        // 先查学生
        Student stu = studentMapper.selectById(id);
        if (stu != null) {
            info.setId(stu.getId());
            info.setName(stu.getName());
            info.setAvatar(stu.getAvatar());
            return info;
        }

        // 再查企业
        Company com = companyMapper.selectById(id);
        if (com != null) {
            info.setId(com.getId());
            info.setName(com.getName());
            info.setAvatar(com.getLogo());
            return info;
        }

        return null;
    }
}
