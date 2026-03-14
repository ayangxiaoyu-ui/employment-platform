package com.example.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("message")
public class Message {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long senderId;     // ✔ 正确
    private Long receiverId;   // ✔ 必须是这个名字
    private String content;
    private Integer type;
    private Integer isRead;
    private Date createTime;
}
