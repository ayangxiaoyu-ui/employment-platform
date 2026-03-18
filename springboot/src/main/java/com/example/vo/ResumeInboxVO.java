package com.example.vo;

import lombok.Data;

@Data
public class ResumeInboxVO {
    private Long applicationId;
    private Long resumeId;
    private String jobTitle;
    private String studentName;
    private String resumeUrl;
    private Integer status;
    private String createTime;
}
