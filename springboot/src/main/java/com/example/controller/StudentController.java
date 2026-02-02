package com.example.controller;

import com.example.common.Result;
import com.example.entity.Student;
import com.example.service.StudentService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

@RestController
@RequestMapping("/api/student")
public class StudentController {

    private static final Logger log = LoggerFactory.getLogger(StudentController.class);

    @Autowired
    private StudentService studentService;

    @GetMapping("/profile")
    public Result<Student> getProfile() {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return Result.error("未授权");
        }

        Student student = studentService.getByUserId(userId);
        if (student == null) {
            student = new Student();
            student.setUserId(userId);
            studentService.saveOrUpdate(student);
        }
        return Result.success(student);
    }

    @PutMapping("/profile")
    public Result<Void> updateProfile(@RequestBody Student student) {
        Long userId = getCurrentUserId();
        if (userId == null) {
            return Result.error("未授权");
        }

        try {
            Student existing = studentService.getByUserId(userId);
            if (existing != null) {
                // 更新已有记录
                student.setId(existing.getId());
                student.setUserId(userId);  // 确保 userId 不被前端覆盖
            } else {
                // 新增记录
                student.setUserId(userId);
            }

            studentService.saveOrUpdate(student);
            log.info("学生个人信息更新成功, userId={}, studentId={}", userId, student.getId());
            return Result.success();
        } catch (Exception e) {
            // 记录详细异常信息
            log.error("更新学生个人信息失败, userId={}, 请求体={}", userId, student, e);

            // 返回给前端的提示（可以自定义格式，不要把完整堆栈暴露）
            String errorMsg = e.getMessage() != null ? e.getMessage() : "服务器内部错误";
            return Result.error("500", "更新失败：" + errorMsg);
        }
    }

    private Long getCurrentUserId() {
        ServletRequestAttributes attributes = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attributes != null) {
            Object userId = attributes.getRequest().getAttribute("userId");
            if (userId instanceof Long) {
                return (Long) userId;
            }
        }
        return null;
    }
}