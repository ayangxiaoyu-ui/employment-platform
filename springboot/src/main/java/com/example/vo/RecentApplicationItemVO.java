package com.example.vo;

import lombok.Data;

@Data
public class RecentApplicationItemVO {

    private Long applicationId;
    private Long jobId;
    private Long studentId;
    private Long resumeId;
    private String jobTitle;
    private String studentName;
    private Integer status;
    private String createTime;
}
