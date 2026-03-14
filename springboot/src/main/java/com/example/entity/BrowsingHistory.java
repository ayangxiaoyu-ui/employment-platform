package com.example.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("browsing_history")
public class BrowsingHistory {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long studentId;

    private Long jobId;

    private Integer count;

    private LocalDateTime updateTime;
}
