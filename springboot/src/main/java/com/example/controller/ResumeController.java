package com.example.controller;

import com.example.common.Result;
import com.example.entity.Resume;
import com.example.service.ResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/resume")
public class ResumeController {

    @Autowired
    private ResumeService resumeService;

/**
 * 根据学生ID获取该学生的所有简历信息
 * @param studentId 学生ID，通过路径变量传递
 * @return 返回一个Result对象，包含该学生的所有简历列表
 */
    @GetMapping("/student/{studentId}")
    public Result<List<Resume>> getByStudent(@PathVariable Long studentId) {
    // 使用MyBatis-Plus的lambda查询方式，查询指定studentId的所有简历
        List<Resume> list = resumeService.lambdaQuery()
                .eq(Resume::getStudentId, studentId)  // 设置查询条件：学生ID等于传入的studentId
                .list();  // 执行查询并返回结果列表
    // 返回成功响应，包含查询到的简历列表
        return Result.success(list);
    }
}
