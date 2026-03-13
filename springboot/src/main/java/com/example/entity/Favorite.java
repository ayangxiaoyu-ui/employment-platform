package com.example.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("favorite")
public class Favorite {
    private Long id;
    private Long studentId;
    private Long jobId;
    private LocalDateTime createTime;
}