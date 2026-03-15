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

    private String title;

    private String description;

    private String content;

    private Integer viewCount;

    private Date createTime;

    private String cover;
}
