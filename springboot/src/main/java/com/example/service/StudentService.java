package com.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.entity.Student;

public interface StudentService extends IService<Student> {

    /**
     * 根据用户ID获取学生信息
     */
    Student getByUserId(Long userId);
}
