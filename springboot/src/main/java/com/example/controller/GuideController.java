package com.example.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.example.common.Result;
import com.example.entity.Guide;
import com.example.service.GuideService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;

import java.util.Date;
import java.util.List;

@RestController
@RequestMapping("/api/guide")
public class GuideController {

    @Autowired
    private GuideService guideService;

    /** 当前请求的企业账号 userId（sys_user.id），与 JWT 一致 */
    private Long resolveCompanyAccountUserId(HttpServletRequest request) {
        if (!"COMPANY".equals(request.getAttribute("role"))) {
            return null;
        }
        Object uid = request.getAttribute("userId");
        return uid instanceof Number ? ((Number) uid).longValue() : null;
    }

    /** 发布就业指导文章 */
    @PostMapping
    public Result<?> add(@RequestBody Guide guide) {
        guideService.save(guide);
        return Result.success();
    }

    /** 企业发布就业指导（按当前登录 userId 归属，无需先维护 company 表） */
    @PostMapping("/company")
    public Result<?> addCompanyGuide(HttpServletRequest request, @RequestBody Guide guide) {
        Long publisherUserId = resolveCompanyAccountUserId(request);
        if (publisherUserId == null) {
            return Result.error("请以企业账号登录后发布");
        }
        guide.setId(null);
        guide.setUserId(publisherUserId);
        if (guide.getViewCount() == null) {
            guide.setViewCount(0);
        }
        guide.setCreateTime(new Date());
        if (guide.getCover() == null || guide.getCover().isBlank()) {
            guide.setCover("/uploads/guide/default.jpg");
        }
        guideService.save(guide);
        return Result.success();
    }

    /** 当前企业账号（userId）已发布的文章列表 */
    @GetMapping("/company/mine")
    public Result<List<Guide>> listCompanyGuides(HttpServletRequest request) {
        Long publisherUserId = resolveCompanyAccountUserId(request);
        if (publisherUserId == null) {
            return Result.error("请以企业账号登录");
        }
        List<Guide> list = guideService.lambdaQuery()
                .eq(Guide::getUserId, publisherUserId)
                .orderByDesc(Guide::getCreateTime)
                .list();
        return Result.success(list);
    }

    private boolean isAdmin(HttpServletRequest request) {
        return "ADMIN".equals(request.getAttribute("role"));
    }

    /** 管理员发布平台就业指导（userId 为空，区别于企业文章） */
    @PostMapping("/admin")
    public Result<?> adminPublish(HttpServletRequest request, @RequestBody Guide guide) {
        if (!isAdmin(request)) {
            return Result.error("仅管理员可发布");
        }
        if (guide.getTitle() == null || guide.getTitle().isBlank()) {
            return Result.error("标题不能为空");
        }
        if (guide.getContent() == null || guide.getContent().isBlank()) {
            return Result.error("内容不能为空");
        }
        guide.setId(null);
        guide.setUserId(null);
        if (guide.getViewCount() == null) {
            guide.setViewCount(0);
        }
        guide.setCreateTime(new Date());
        if (guide.getCover() == null || guide.getCover().isBlank()) {
            guide.setCover("/uploads/guide/default.jpg");
        }
        guideService.save(guide);
        return Result.success();
    }

    /** 管理员获取文章（编辑用，不增加浏览量） */
    @GetMapping("/admin/{id}")
    public Result<Guide> adminDetail(HttpServletRequest request, @PathVariable Long id) {
        if (!isAdmin(request)) {
            return Result.error("仅管理员可查看");
        }
        Guide g = guideService.getById(id);
        if (g == null) {
            return Result.error("文章不存在");
        }
        return Result.success(g);
    }

    /** 管理员更新任意就业指导（保留发布者、浏览量、创建时间） */
    @PutMapping("/admin/{id}")
    public Result<Void> adminUpdate(HttpServletRequest request, @PathVariable Long id, @RequestBody Guide body) {
        if (!isAdmin(request)) {
            return Result.error("仅管理员可修改");
        }
        Guide existing = guideService.getById(id);
        if (existing == null) {
            return Result.error("文章不存在");
        }
        if (body.getTitle() == null || body.getTitle().isBlank()) {
            return Result.error("标题不能为空");
        }
        if (body.getContent() == null || body.getContent().isBlank()) {
            return Result.error("内容不能为空");
        }
        existing.setTitle(body.getTitle().trim());
        existing.setDescription(body.getDescription());
        existing.setContent(body.getContent());
        if (body.getCover() != null && !body.getCover().isBlank()) {
            existing.setCover(body.getCover());
        }
        guideService.updateById(existing);
        return Result.success();
    }

    /** 管理员删除任意就业指导文章 */
    @DeleteMapping("/admin/{id}")
    public Result<Void> adminDelete(HttpServletRequest request, @PathVariable Long id) {
        if (!isAdmin(request)) {
            return Result.error("仅管理员可操作");
        }
        if (!guideService.removeById(id)) {
            return Result.error("文章不存在");
        }
        return Result.success();
    }

    /** 企业获取本人文章详情（编辑用，不增加浏览量） */
    @GetMapping("/company/{id}")
    public Result<Guide> companyDetail(HttpServletRequest request, @PathVariable Long id) {
        Long publisherUserId = resolveCompanyAccountUserId(request);
        if (publisherUserId == null) {
            return Result.error("请以企业账号登录");
        }
        Guide g = guideService.getById(id);
        if (g == null) {
            return Result.error("文章不存在");
        }
        if (g.getUserId() == null || !g.getUserId().equals(publisherUserId)) {
            return Result.error("无权查看该文章");
        }
        return Result.success(g);
    }

    /** 企业更新本人发布的文章 */
    @PutMapping("/company/{id}")
    public Result<Void> updateCompanyGuide(HttpServletRequest request, @PathVariable Long id, @RequestBody Guide body) {
        Long publisherUserId = resolveCompanyAccountUserId(request);
        if (publisherUserId == null) {
            return Result.error("请以企业账号登录");
        }
        Guide existing = guideService.getById(id);
        if (existing == null) {
            return Result.error("文章不存在");
        }
        if (existing.getUserId() == null || !existing.getUserId().equals(publisherUserId)) {
            return Result.error("无权修改该文章");
        }
        if (body.getTitle() == null || body.getTitle().isBlank()) {
            return Result.error("标题不能为空");
        }
        if (body.getContent() == null || body.getContent().isBlank()) {
            return Result.error("内容不能为空");
        }
        existing.setTitle(body.getTitle().trim());
        existing.setDescription(body.getDescription());
        existing.setContent(body.getContent());
        if (body.getCover() != null && !body.getCover().isBlank()) {
            existing.setCover(body.getCover());
        }
        guideService.updateById(existing);
        return Result.success();
    }

    /** 删除本人（本 userId）发布的文章 */
    @DeleteMapping("/company/{id}")
    public Result<Void> deleteCompanyGuide(HttpServletRequest request, @PathVariable Long id) {
        Long publisherUserId = resolveCompanyAccountUserId(request);
        if (publisherUserId == null) {
            return Result.error("请以企业账号登录");
        }
        Guide g = guideService.getById(id);
        if (g == null) {
            return Result.error("文章不存在");
        }
        if (g.getUserId() == null || !g.getUserId().equals(publisherUserId)) {
            return Result.error("无权删除该文章");
        }
        guideService.removeById(id);
        return Result.success();
    }

    /** 全部就业指导 */
    @GetMapping("/list")
    public Result<?> list() {
        List<Guide> list = guideService.list(
                new QueryWrapper<Guide>()
                        .orderByDesc("create_time")
        );
        return Result.success(list);
    }

    /** 最新 5 条就业指导 */
    @GetMapping("/latest")
    public Result<?> latest() {
        List<Guide> list = guideService.list(
                new QueryWrapper<Guide>()
                        .orderByDesc("create_time")
                        .last("LIMIT 5")
        );
        return Result.success(list);
    }

    /** 详情（浏览量 +1） */
    @GetMapping("/{id}")
    public Result<?> detail(@PathVariable Long id) {
        Guide guide = guideService.getById(id);
        guide.setViewCount(guide.getViewCount() + 1);
        guideService.updateById(guide);
        return Result.success(guide);
    }
}
