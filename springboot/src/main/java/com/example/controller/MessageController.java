package com.example.controller;

import com.example.entity.Message;
import com.example.common.Result;
import com.example.service.MessageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/message")
public class MessageController {

    @Autowired
    private MessageService messageService;

    // 查询用户收到的消息
    @GetMapping("/user/{userId}")
    public Result<List<Message>> getMessages(@PathVariable Long userId) {
        List<Message> list = messageService.lambdaQuery()
                .eq(Message::getReceiverId, userId)
                .orderByDesc(Message::getCreateTime)
                .list();
        return Result.success(list);
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
}
