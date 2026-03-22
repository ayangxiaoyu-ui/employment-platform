package com.example.controller;

import cn.hutool.jwt.JWT;
import com.example.entity.Company;
import com.example.entity.Message;
import com.example.common.Result;
import com.example.service.CompanyService;
import com.example.service.MessageService;
import com.example.service.UserService;
import com.example.utils.JwtUtils;
import com.example.vo.MessageVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/message")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @Autowired
    private UserService userService;

    @Autowired
    private CompanyService companyService;




    /**
     * 企业端：获取所有互动对象（学生）
     */
    @GetMapping("/company/inbox")
    public Result<List<MessageVO>> getCompanyInbox(@RequestHeader("Authorization") String token) {

        // 解析 token
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        JWT jwt = JwtUtils.parse(token);
        Long userId = ((Number) jwt.getPayload("userId")).longValue();
        String role = (String) jwt.getPayload("role");

        if (!"COMPANY".equals(role)) {
            return Result.error("非企业账号无法查看互动信息");
        }

        // 企业 userId → 企业 companyId
        Company company = companyService.lambdaQuery()
                .eq(Company::getUserId, userId)
                .one();

        if (company == null) {
            return Result.error("企业信息不存在");
        }

        Long companyId = company.getId();

        // 查询所有与企业互动的消息
        List<Message> list = messageService.lambdaQuery()
                .and(w -> w.eq(Message::getReceiverId, companyId)
                        .or()
                        .eq(Message::getSenderId, companyId))
                .orderByDesc(Message::getCreateTime)
                .list();

        // 按联系人分组（学生 ID）
        Map<Long, Message> latestMap = new LinkedHashMap<>();

        for (Message msg : list) {
            Long targetId = msg.getSenderId().equals(companyId)
                    ? msg.getReceiverId()
                    : msg.getSenderId();

            latestMap.putIfAbsent(targetId, msg);
        }

        // 转成 VO
        List<MessageVO> result = latestMap.values().stream().map(msg -> {
            MessageVO vo = new MessageVO();
            BeanUtils.copyProperties(msg, vo);

            Long targetId = msg.getSenderId().equals(companyId)
                    ? msg.getReceiverId()
                    : msg.getSenderId();

            vo.setTarget(userService.getUserInfo(targetId));
            return vo;
        }).collect(Collectors.toList());

        return Result.success(result);
    }


    /**
     * 企业端：获取与某个学生的聊天记录
     */
    @GetMapping("/company/chat")
    public Result<List<Message>> getCompanyChat(
            @RequestHeader("Authorization") String token,
            @RequestParam Long studentId) {

        // 解析 token
        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        JWT jwt = JwtUtils.parse(token);
        Long userId = ((Number) jwt.getPayload("userId")).longValue();

        Company company = companyService.lambdaQuery()
                .eq(Company::getUserId, userId)
                .one();

        if (company == null) {
            return Result.error("企业信息不存在");
        }

        Long companyId = company.getId();

        // 查询聊天记录
        List<Message> list = messageService.lambdaQuery()
                .and(w -> w.eq(Message::getSenderId, companyId)
                        .eq(Message::getReceiverId, studentId))
                .or(w -> w.eq(Message::getSenderId, studentId)
                        .eq(Message::getReceiverId, companyId))
                .orderByAsc(Message::getCreateTime)
                .list();

        return Result.success(list);
    }
    /**
     * 企业端：发送消息给学生
     */
    @PostMapping("/company/send")
    public Result<Void> companySend(
            @RequestHeader("Authorization") String token,
            @RequestBody Message message) {

        if (token.startsWith("Bearer ")) {
            token = token.substring(7);
        }
        JWT jwt = JwtUtils.parse(token);
        Long userId = ((Number) jwt.getPayload("userId")).longValue();

        Company company = companyService.lambdaQuery()
                .eq(Company::getUserId, userId)
                .one();

        if (company == null) {
            return Result.error("企业信息不存在");
        }

        message.setSenderId(company.getId());
        message.setIsRead(0);

        messageService.save(message);
        return Result.success();
    }


    // 查询用户收到的消息
    @GetMapping("/user/{userId}")
    public Result<List<MessageVO>> getMessages(@PathVariable Long userId) {

        List<Message> list = messageService.lambdaQuery()
                .and(w -> w.eq(Message::getReceiverId, userId)
                        .or()
                        .eq(Message::getSenderId, userId))
                .orderByDesc(Message::getCreateTime)
                .list();

        // ⭐ 按联系人分组（企业ID 或 学生ID）
        Map<Long, Message> latestMap = new LinkedHashMap<>();

        for (Message msg : list) {
            Long targetId = msg.getSenderId().equals(userId)
                    ? msg.getReceiverId()
                    : msg.getSenderId();

            // 如果这个联系人还没放进去，则放入（因为 list 已按时间倒序）
            latestMap.putIfAbsent(targetId, msg);
        }

        // ⭐ 转成 VO
        List<MessageVO> result = latestMap.values().stream().map(msg -> {
            MessageVO vo = new MessageVO();
            BeanUtils.copyProperties(msg, vo);

            Long targetId = msg.getSenderId().equals(userId)
                    ? msg.getReceiverId()
                    : msg.getSenderId();

            vo.setTarget(userService.getUserInfo(targetId));
            return vo;
        }).collect(Collectors.toList());

        return Result.success(result);
    }




    // 标记为已读
    @PostMapping("/read/{id}")
    public Result<Void> markRead(@PathVariable Long id) {
        messageService.lambdaUpdate()
                .eq(Message::getId, id)
                .set(Message::getIsRead, 1)
                .update();
        return Result.success();
    }

    // 发送消息
    @PostMapping("/send")
    public Result<Void> send(@RequestBody Message message) {
        message.setIsRead(0);
        messageService.save(message);
        return Result.success();
    }

    @GetMapping("/chat")
    public Result<List<Message>> getChat(
            @RequestParam Long userA,
            @RequestParam Long userB) {

        List<Message> list = messageService.lambdaQuery()
                .and(w -> w.eq(Message::getSenderId, userA)
                        .eq(Message::getReceiverId, userB))
                .or(w -> w.eq(Message::getSenderId, userB)
                        .eq(Message::getReceiverId, userA))
                .orderByAsc(Message::getCreateTime)
                .list();

        return Result.success(list);
    }

}
