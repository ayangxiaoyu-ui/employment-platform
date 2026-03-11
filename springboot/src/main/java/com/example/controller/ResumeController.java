package com.example.controller;

import com.example.common.Result;
import com.example.entity.Resume;
import com.example.service.ResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.util.List;

@RestController
@RequestMapping("/api/resume")
public class ResumeController {

    @Autowired
    private ResumeService resumeService;

    @Value("${file.upload.base-path}")
    private String basePath;

    @Value("${file.upload.resume-sub-path}")
    private String resumeSubPath;

    @Value("${file.upload.resume-url-prefix}")
    private String resumeUrlPrefix;

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
    @PostMapping("/upload")
    public Result uploadResume(@RequestParam("file") MultipartFile file,
                               @RequestParam("studentId") Long studentId) {

        if (file.isEmpty()) {
            return Result.error("上传文件为空");
        }

        try {
            // 原始文件名（不要做任何编码转换）
            String originalName = file.getOriginalFilename();

            // 生成新文件名
            String newFileName = "resume_" + studentId + "_" + originalName;

            // 最终保存路径
            String fullPath = basePath + resumeSubPath + newFileName;

            // 创建目录
            File dir = new File(basePath + resumeSubPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            // 保存文件
            file.transferTo(new File(fullPath));

            // 返回给前端的访问 URL
            String fileUrl = resumeUrlPrefix + newFileName;

            return Result.success(fileUrl);

        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("上传失败：" + e.getMessage());
        }
    }

}
