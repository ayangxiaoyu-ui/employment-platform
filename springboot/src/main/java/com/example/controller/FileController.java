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
@RequiredArgsConstructor
public class FileController {

    private final StudentService studentService;
    private final CompanyService companyService;

    @Value("${file.upload.base-path}")
    private String basePath;

    @Value("${file.upload.avatar-sub-path}")
    private String avatarSubPath;

    @Value("${file.upload.logo-sub-path}")
    private String logoSubPath;

    @Value("${file.upload.avatar-url-prefix}")
    private String avatarUrlPrefix;

    @Value("${file.upload.logo-url-prefix}")
    private String logoUrlPrefix;

    private static final long MAX_AVATAR_SIZE = 5 * 1024 * 1024L; // 5MB
    private static final long MAX_LOGO_SIZE   = 3 * 1024 * 1024L; // 3MB

    @PostMapping("/upload/avatar")
    public Result<String> uploadAvatar(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        Result<String> validateResult = validateImageFile(file, MAX_AVATAR_SIZE);
        if (validateResult != null) return validateResult;

        String relativePath = saveFile(file, avatarSubPath, "avatar_" + userId);
        if (relativePath == null) {
            return Result.error("文件保存失败");
        }

        // 删除旧头像 + 更新数据库
        Student student = studentService.getByUserId(userId);
        if (student == null) {
            return Result.error("未找到学生记录");
        }

        deleteOldFile(student.getAvatar(), avatarSubPath);
        student.setAvatar(relativePath);
        if (!studentService.saveOrUpdate(student)) {
            new File(basePath + avatarSubPath + getFileNameFromPath(relativePath)).delete();
            return Result.error("数据库更新失败，已回滚文件");
        }

        log.info("学生头像更新成功: userId={}, path={}", userId, relativePath);
        return Result.success(relativePath);  // 返回相对路径，前端加域名即可
    }

    @PostMapping("/upload/logo")
    public Result<String> uploadLogo(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") Long userId) {

        Result<String> validateResult = validateImageFile(file, MAX_LOGO_SIZE);
        if (validateResult != null) return validateResult;

        String relativePath = saveFile(file, logoSubPath, "logo_" + userId);
        if (relativePath == null) {
            return Result.error("文件保存失败");
        }

        Company company = companyService.getByUserId(userId);
        if (company == null) {
            return Result.error("未找到企业记录");
        }

        deleteOldFile(company.getLogo(), logoSubPath);
        company.setLogo(relativePath);
        if (!companyService.saveOrUpdate(company)) {
            new File(basePath + logoSubPath + getFileNameFromPath(relativePath)).delete();
            return Result.error("数据库更新失败，已回滚文件");
        }

        log.info("企业Logo更新成功: userId={}, path={}", userId, relativePath);
        return Result.success(relativePath);
    }

    // 通用校验
    private Result<String> validateImageFile(MultipartFile file, long maxSize) {
        if (file == null || file.isEmpty()) return Result.error("请选择文件");
        if (file.getSize() > maxSize) return Result.error("文件大小超过限制");
        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image")) return Result.error("只允许上传图片");
        return null;
    }

    // 保存文件，返回相对路径（如 /uploads/avatar/avatar_xx_xxx.jpg）
    private String saveFile(MultipartFile file, String subPath, String prefix) {
        String ext = getFileExtension(file.getOriginalFilename());
        String fileName = prefix + "_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12) + ext;
        String fullDir = basePath + subPath;

        File dir = new File(fullDir);
        if (!dir.exists() && !dir.mkdirs()) {
            log.error("创建目录失败: {}", fullDir);
            return null;
        }

        File dest = new File(dir, fileName);
        try {
            file.transferTo(dest);
            if (!dest.exists() || dest.length() == 0) {
                log.error("文件写入后为空或不存在: {}", dest.getAbsolutePath());
                return null;
            }
            log.info("文件保存成功: {}", dest.getAbsolutePath());
            return avatarUrlPrefix + fileName;  // 或 logoUrlPrefix，根据 subPath 区分也可
        } catch (IOException e) {
            log.error("保存文件异常: {}", dest.getAbsolutePath(), e);
            return null;
        }
    }

    private void deleteOldFile(String oldPath, String subPath) {
        if (oldPath == null || oldPath.trim().isEmpty()) return;
        String fileName = oldPath.substring(oldPath.lastIndexOf("/") + 1);
        File oldFile = new File(basePath + subPath + fileName);
        if (oldFile.exists() && oldFile.isFile()) {
            if (oldFile.delete()) {
                log.info("删除旧文件成功: {}", oldFile.getAbsolutePath());
            } else {
                log.warn("删除旧文件失败: {}", oldFile.getAbsolutePath());
            }
        }
    }

    private String getFileExtension(String filename) {
        if (filename == null || !filename.contains(".")) return ".jpg";
        return filename.substring(filename.lastIndexOf("."));
    }

    private String getFileNameFromPath(String path) {
        return path.substring(path.lastIndexOf("/") + 1);
    }
}