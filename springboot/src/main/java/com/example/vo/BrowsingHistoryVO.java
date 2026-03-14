package com.example.vo;

import com.example.entity.Job;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class BrowsingHistoryVO {
    private Long id;
    private Long studentId;
    private Long jobId;
    private Integer count;
    private LocalDateTime updateTime;

    private Job job; // ⭐ 直接把职位信息返回给前端
    private String companyName;
}
