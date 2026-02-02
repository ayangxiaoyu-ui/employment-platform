package com.example.controller;

import com.example.common.Result;
import com.example.entity.Student;
import com.example.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/file")
public class FileController {

    @Autowired
    private StudentService studentService;

    @Value("${file.upload.avatar-path}")
    private String avatarSavePath;

    @Value("${file.upload.avatar-url-prefix}")
    private String avatarUrlPrefix;

    @PostMapping("/upload/avatar")
    public Result<String> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        if (file == null || file.isEmpty()) {
            return Result.error("请选择文件");
        }

        // 校验图片类型
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image")) {
            return Result.error("只允许上传图片文件");
        }

        // 获取后缀（更安全一点的写法）
        String ext = "";
        String originalFilename = file.getOriginalFilename();
        if (originalFilename != null && originalFilename.contains(".")) {
            ext = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        // 文件名建议：avatar_userId_短uuid.ext
        String fileName = "avatar_" + userId + "_" +
                UUID.randomUUID().toString().replace("-", "").substring(0, 12) + ext;

        // 确保目录存在
        File dir = new File(avatarSavePath);
        if (!dir.exists() && !dir.mkdirs()) {
            return Result.error("创建存储目录失败");
        }

        // 保存文件
        File destFile = new File(dir, fileName);   // 推荐用 File(dir, name) 避免斜杠问题
        try {
            file.transferTo(destFile);
        } catch (IOException e) {
            return Result.error("文件保存失败：" + e.getMessage());
        }

        // 存相对路径到数据库（最推荐）
        String relativePath = avatarUrlPrefix + fileName;

        // 更新学生信息
        Student student = studentService.getByUserId(userId);
        if (student == null) {
            destFile.delete();  // 清理垃圾文件
            return Result.error("未找到对应的学生记录");
        }

        student.setAvatar(relativePath);
        boolean success = studentService.saveOrUpdate(student);

        if (!success) {
            destFile.delete();
            return Result.error("更新头像失败");
        }

        // 开发阶段返回完整可访问地址（方便前端直接用）
        String fullAccessUrl = "http://localhost:9999" + relativePath;

        return Result.success(fullAccessUrl);
    }
}