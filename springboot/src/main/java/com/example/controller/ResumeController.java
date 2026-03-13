package com.example.controller;

import com.example.common.Result;
import com.example.entity.Resume;
import com.example.service.ResumeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.File;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
     * 上传简历文件
     */
    @PostMapping("/upload")
    public Result uploadResume(@RequestParam("file") MultipartFile file,
                               @RequestParam("studentId") Long studentId,
                               @RequestParam(value = "force", defaultValue = "false") boolean force) {

        if (file.isEmpty()) {
            return Result.error("上传文件为空");
        }

        try {
            String originalName = file.getOriginalFilename();
            String title = originalName.substring(0, originalName.lastIndexOf("."));
            String ext = originalName.substring(originalName.lastIndexOf("."));

            // 🔥 1. 检查是否存在同名简历
            boolean exists = resumeService.lambdaQuery()
                    .eq(Resume::getStudentId, studentId)
                    .eq(Resume::getTitle, title)
                    .exists();

            if (exists && !force) {
                // 返回 409 冲突，让前端弹窗询问用户
                return Result.error("409", "存在同名简历，是否替换？");
            }

            // 🔥 2. 生成唯一文件名
            String newFileName = "resume_" + studentId + "_" + System.currentTimeMillis() + ext;
            String fullPath = basePath + resumeSubPath + newFileName;

            File dir = new File(basePath + resumeSubPath);
            if (!dir.exists()) {
                dir.mkdirs();
            }

            file.transferTo(new File(fullPath));

            // 🔥 3. 返回 fileUrl + title
            Map<String, Object> data = new HashMap<>();
            data.put("fileUrl", resumeUrlPrefix + newFileName);
            data.put("title", title);

            return Result.success(data);

        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("上传失败：" + e.getMessage());
        }
    }



    /**
     * 保存简历信息（关键：每次都是新增）
     */
    @PostMapping
    public Result saveResume(@RequestBody Resume resume) {

        resume.setId(null); // 🔥 强制新增
        resume.setCreateTime(new Date());
        resume.setUpdateTime(new Date());

        resumeService.save(resume);

        return Result.success("保存成功");
    }

    /**
     * 查询某学生的所有简历
     */
    @GetMapping("/student/{studentId}")
    public Result<List<Resume>> getByStudent(@PathVariable Long studentId) {

        List<Resume> list = resumeService.lambdaQuery()
                .eq(Resume::getStudentId, studentId)
                .orderByDesc(Resume::getUpdateTime) // 🔥 建议加排序
                .list();

        return Result.success(list);
    }


    /**
     * 删除简历（删除数据库记录 + 删除服务器文件）
     */
    @DeleteMapping("/{id}")
    public Result deleteResume(@PathVariable Long id) {
        System.out.println("dddddd");
        System.out.println("delete id = " + id);
        Resume resume = resumeService.getById(id);
        if (resume == null) {
            System.out.println("delete id = " + id);
            return Result.error("简历不存在");
        }

        String fileUrl = resume.getFileUrl();

        if (fileUrl != null && !fileUrl.isEmpty()) {
            try {
                // 1. 去掉 URL 前缀，得到文件名
                String fileName = fileUrl.substring(resumeUrlPrefix.length());

                // 2. 拼接真实路径
                String filePath = basePath + resumeSubPath + fileName;
                System.out.println("删除文件路径：" + filePath);
                File file = new File(filePath);
                if (file.exists()) {
                    file.delete();
                } else {
                    System.out.println("❌ 文件不存在：" + filePath);
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 3. 删除数据库记录
        resumeService.removeById(id);

        return Result.success("删除成功");
    }



}
