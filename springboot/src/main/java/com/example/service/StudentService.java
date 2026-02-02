package com.example.service;

import com.example.entity.Student;

public interface StudentService {
    /**
     * 根据用户ID获取学生信息
     */
    Student getByUserId(Long userId);

    /**
     * 根据ID获取学生信息
     */
    Student getById(Long id);

    /**
     * 保存或更新学生信息
     */
    boolean saveOrUpdate(Student student);
}
