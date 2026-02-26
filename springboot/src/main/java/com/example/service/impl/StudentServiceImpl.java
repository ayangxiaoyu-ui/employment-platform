package com.example.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.entity.Student;
import com.example.mapper.StudentMapper;
import com.example.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class StudentServiceImpl implements StudentService {

    @Autowired
    private StudentMapper studentMapper;

    @Override
    public Student getByUserId(Long userId) {
        QueryWrapper<Student> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId);
        return studentMapper.selectOne(wrapper);
    }
    @Override
    public boolean saveOrUpdate(Student student) {
        if (student.getId() != null) {
            return studentMapper.updateById(student) > 0;
        } else {
            return studentMapper.insert(student) > 0;
        }
    }
}
