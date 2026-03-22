package com.example.controller;

import com.example.common.Result;
import com.example.entity.Resume;
import com.example.entity.Student;
import com.example.service.ResumeService;
import com.example.service.StudentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.*;

@RestController
@RequestMapping("/api/resume")
public class ResumeController {

    @Autowired
    private ResumeService resumeService;

    @Autowired
    private StudentService studentService;

    @Value("${file.upload.base-path}")
    private String basePath;

    @Value("${file.upload.resume-sub-path}")
    private String resumeSubPath;

    @Value("${file.upload.resume-url-prefix}")
    private String resumeUrlPrefix;


    // ============================================================
    // 1. 企业端查看简历详情（区分在线简历 / 附件简历）
    // ============================================================
    @GetMapping("/{id}")
    public Result<?> getResumeDetail(@PathVariable Long id) {

        Resume resume = resumeService.getById(id);
        if (resume == null) {
            return Result.error("简历不存在");
        }

        Student student = studentService.getById(resume.getStudentId());

        Map<String, Object> data = new HashMap<>();
        data.put("id", resume.getId());
        data.put("title", resume.getTitle());
        data.put("type", resume.getType());

        if (resume.getType() == 1) {
            // ⭐ 在线简历
            data.put("content", resume.getContent());
        } else {
            // ⭐ 附件简历
            data.put("fileUrl", resume.getFileUrl());
        }

        if (student != null) {
            data.put("studentName", student.getName());
            data.put("gender", student.getGender());
            data.put("phone", student.getPhone());
            data.put("email", student.getEmail());
            data.put("university", student.getUniversity());
            data.put("major", student.getMajor());
        }

        return Result.success(data);
    }


    // ============================================================
    // 2. 上传 PDF 简历文件（返回 fileUrl + title）
    // ============================================================
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

            // 检查是否存在同名简历
            boolean exists = resumeService.lambdaQuery()
                    .eq(Resume::getStudentId, studentId)
                    .eq(Resume::getTitle, title)
                    .exists();

            if (exists && !force) {
                return Result.error("409", "存在同名简历，是否替换？");
            }

            // 生成唯一文件名
            String newFileName = "resume_" + studentId + "_" + System.currentTimeMillis() + ext;
            String fullPath = basePath + resumeSubPath + newFileName;

            File dir = new File(basePath + resumeSubPath);
            if (!dir.exists()) dir.mkdirs();

            file.transferTo(new File(fullPath));

            Map<String, Object> data = new HashMap<>();
            data.put("fileUrl", resumeUrlPrefix + newFileName);
            data.put("title", title);

            return Result.success(data);

        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("上传失败：" + e.getMessage());
        }
    }


    // ============================================================
    // 3. 保存附件简历（type=2）
    // ============================================================
    @PostMapping
    public Result saveResume(@RequestBody Resume resume) {

        resume.setId(null);
        resume.setCreateTime(new Date());
        resume.setUpdateTime(new Date());

        // ⭐ 附件简历
        resume.setType(2);
        resume.setContent(null);

        resumeService.save(resume);
        return Result.success("附件简历保存成功");
    }


    // ============================================================
    // 4. 保存在线简历（type=1）：带 id 则更新；否则按学生 upsert 唯一在线简历
    // ============================================================
    @PostMapping("/online")
    public Result<?> saveOnlineResume(@RequestBody Resume resume) {

        if (resume.getStudentId() == null) {
            return Result.error("缺少 studentId");
        }

        Date now = new Date();
        resume.setType(1);
        resume.setFileUrl(null);

        if (resume.getId() != null) {
            Resume existing = resumeService.getById(resume.getId());
            if (existing == null || !existing.getStudentId().equals(resume.getStudentId())) {
                return Result.error("简历不存在或无权修改");
            }
            if (existing.getType() == null || existing.getType() != 1) {
                return Result.error("只能修改在线简历");
            }
            existing.setTitle(resume.getTitle() != null && !resume.getTitle().isBlank()
                    ? resume.getTitle() : existing.getTitle());
            existing.setContent(resume.getContent());
            if (resume.getIsPublic() != null) {
                existing.setIsPublic(resume.getIsPublic());
            }
            existing.setUpdateTime(now);
            resumeService.updateById(existing);
            Map<String, Object> out = new HashMap<>();
            out.put("id", existing.getId());
            return Result.success(out);
        }

        List<Resume> onlines = resumeService.lambdaQuery()
                .eq(Resume::getStudentId, resume.getStudentId())
                .eq(Resume::getType, 1)
                .orderByDesc(Resume::getUpdateTime)
                .list();
        Resume latest = onlines.isEmpty() ? null : onlines.get(0);

        if (latest != null) {
            latest.setTitle(resume.getTitle() != null && !resume.getTitle().isBlank()
                    ? resume.getTitle() : latest.getTitle());
            latest.setContent(resume.getContent());
            if (resume.getIsPublic() != null) {
                latest.setIsPublic(resume.getIsPublic());
            }
            latest.setUpdateTime(now);
            resumeService.updateById(latest);
            Map<String, Object> out = new HashMap<>();
            out.put("id", latest.getId());
            return Result.success(out);
        }

        resume.setId(null);
        resume.setCreateTime(now);
        resume.setUpdateTime(now);
        if (resume.getTitle() == null || resume.getTitle().isBlank()) {
            resume.setTitle("在线简历");
        }
        if (resume.getIsPublic() == null) {
            resume.setIsPublic(1);
        }
        resumeService.save(resume);
        Map<String, Object> out = new HashMap<>();
        out.put("id", resume.getId());
        return Result.success(out);
    }


    // ============================================================
    // 5. 查询某学生所有简历（在线 + 附件）
    // ============================================================
    @GetMapping("/student/{studentId}")
    public Result<List<Resume>> getByStudent(@PathVariable Long studentId) {

        List<Resume> list = resumeService.lambdaQuery()
                .eq(Resume::getStudentId, studentId)
                .orderByDesc(Resume::getUpdateTime)
                .list();

        return Result.success(list);
    }


    // ============================================================
    // 6. 删除简历（附件简历删除文件，在线简历不删文件）
    // ============================================================
    @DeleteMapping("/{id}")
    public Result deleteResume(@PathVariable Long id) {

        Resume resume = resumeService.getById(id);
        if (resume == null) {
            return Result.error("简历不存在");
        }

        // ⭐ 附件简历才删除文件
        if (resume.getType() == 2 && resume.getFileUrl() != null) {
            try {
                String fileName = resume.getFileUrl().substring(resumeUrlPrefix.length());
                String filePath = basePath + resumeSubPath + fileName;

                File file = new File(filePath);
                if (file.exists()) file.delete();

            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        resumeService.removeById(id);
        return Result.success("删除成功");
    }

}
