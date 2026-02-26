package com.example.service;

import com.example.entity.Student;

public interface StudentService {
    /**
     * 根据用户ID获取学生信息
     */
    Student getByUserId(Long userId);

    /**
     * 保存或更新学生信息
     */
    boolean saveOrUpdate(Student student);
}
