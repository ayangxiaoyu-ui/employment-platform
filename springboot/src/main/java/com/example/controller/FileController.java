package com.example.controller;

import com.example.common.Result;
import com.example.entity.Company;
import com.example.entity.Student;
import com.example.service.CompanyService;
import com.example.service.StudentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/file")
@RequiredArgsConstructor  // 自动生成构造器注入
public class FileController {

    private final StudentService studentService;
    private final CompanyService companyService;

    @Value("${file.upload.avatar-path}")
    private String avatarSavePath;

    @Value("${file.upload.avatar-url-prefix:/uploads/avatar/}")
    private String avatarUrlPrefix;

    private static final long MAX_AVATAR_SIZE = 5 * 1024 * 1024; // 头像 5MB
    private static final long MAX_LOGO_SIZE = 3 * 1024 * 1024;   // Logo 3MB

    // ====================== 学生头像上传 ======================
    @PostMapping("/upload/avatar")
    public Result<String> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        if (file == null || file.isEmpty()) {
            return Result.error("请选择文件");
        }

        if (file.getSize() > MAX_AVATAR_SIZE) {
            return Result.error("文件大小超过限制（最大5MB）");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image")) {
            return Result.error("只允许上传图片文件");
        }

        String ext = getFileExtension(file.getOriginalFilename());

        String fileName = String.format("avatar_%d_%s%s",
                userId,
                UUID.randomUUID().toString().replace("-", "").substring(0, 12),
                ext);

        File dir = new File(avatarSavePath);
        if (!dir.exists() && !dir.mkdirs()) {
            log.error("创建头像目录失败: {}", avatarSavePath);
            return Result.error("服务器错误：无法创建存储目录");
        }

        File destFile = new File(dir, fileName);

        // 删除旧头像
        Student student = studentService.getByUserId(userId);
        if (student == null) {
            return Result.error("未找到对应的学生记录");
        }

        deleteOldFile(student.getAvatar(), dir);

        // 保存新文件
        try {
            file.transferTo(destFile);
            log.info("学生头像上传成功: userId={}, path={}", userId, destFile.getAbsolutePath());
        } catch (IOException e) {
            log.error("保存学生头像失败", e);
            return Result.error("文件保存失败");
        }

        String relativePath = avatarUrlPrefix + fileName;
        student.setAvatar(relativePath);
        boolean success = studentService.saveOrUpdate(student);

        if (!success) {
            destFile.delete();
            return Result.error("更新头像失败");
        }

        String fullUrl = "http://localhost:9999" + relativePath;
        return Result.success(fullUrl);
    }

    // ====================== 企业 Logo 上传 ======================
    @PostMapping("/upload/logo")
    public Result<String> uploadCompanyLogo(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        if (file == null || file.isEmpty()) {
            return Result.error("请选择文件");
        }

        if (file.getSize() > MAX_LOGO_SIZE) {
            return Result.error("文件大小超过限制（最大3MB）");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image")) {
            return Result.error("只允许上传图片文件");
        }

        String ext = getFileExtension(file.getOriginalFilename());

        String fileName = String.format("logo_%d_%s%s",
                userId,
                UUID.randomUUID().toString().replace("-", "").substring(0, 12),
                ext);

        File dir = new File(avatarSavePath);
        if (!dir.exists() && !dir.mkdirs()) {
            log.error("创建 Logo 目录失败: {}", avatarSavePath);
            return Result.error("服务器错误：无法创建存储目录");
        }

        File destFile = new File(dir, fileName);

        // 删除旧 Logo
        Company company = companyService.getByUserId(userId);
        if (company == null) {
            return Result.error("未找到对应的企业记录");
        }

        deleteOldFile(company.getLogo(), dir);

        // 保存新文件
        try {
            file.transferTo(destFile);
            log.info("企业 Logo 上传成功: userId={}, path={}", userId, destFile.getAbsolutePath());
        } catch (IOException e) {
            log.error("保存企业 Logo 失败", e);
            return Result.error("文件保存失败");
        }

        String relativePath = avatarUrlPrefix + fileName;
        company.setLogo(relativePath);
        boolean success = companyService.saveOrUpdate(company);

        if (!success) {
            destFile.delete();
            return Result.error("更新 Logo 失败");
        }

        String fullUrl = "http://localhost:9999" + relativePath;
        return Result.success(fullUrl);
    }

    // 辅助方法：获取文件扩展名（带 . ）
    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return ".jpg";
        }
        return filename.substring(filename.lastIndexOf("."));
    }

    // 辅助方法：删除旧文件（通用）
    private void deleteOldFile(String oldPath, File dir) {
        if (oldPath == null || oldPath.isBlank()) {
            return;
        }

        String oldFileName = oldPath.startsWith(avatarUrlPrefix)
                ? oldPath.substring(avatarUrlPrefix.length())
                : oldPath;

        File oldFile = new File(dir, oldFileName);
        if (oldFile.exists() && oldFile.isFile()) {
            if (oldFile.delete()) {
                log.info("成功删除旧文件: {}", oldFile.getAbsolutePath());
            } else {
                log.warn("删除旧文件失败: {}", oldFile.getAbsolutePath());
            }
        }
    }
}