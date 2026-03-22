package com.example.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.util.Date;

@Data
@TableName("guide")
public class Guide {

    @TableId(type = IdType.AUTO)
    private Long id;

    /** 发布者 sys_user.id（企业账号 JWT 中的 userId）；平台文章为 null */
    private Long userId;

    private String title;

    private String description;

    private String content;

    private Integer viewCount;

    private Date createTime;

    private String cover;
}
