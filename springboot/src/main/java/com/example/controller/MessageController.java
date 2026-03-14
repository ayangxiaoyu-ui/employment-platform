package com.example.controller;

import com.example.entity.Message;
import com.example.common.Result;
import com.example.service.MessageService;
import com.example.service.UserService;
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
