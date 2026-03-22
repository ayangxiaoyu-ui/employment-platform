package com.example.vo;

import lombok.Data;

@Data
public class ResumeInboxVO {
    private Long applicationId;
    private Long resumeId;
    private Long studentId;
    private String jobTitle;
    private String studentName;
    /** 投递的简历类型：1=在线 2=附件 */
    private Integer resumeType;
    private String resumeTitle;
    /** 附件简历文件路径（type=2） */
    private String resumeUrl;
    /** 在线简历 JSON 原文（type=1） */
    private String resumeContent;
    private Integer status;
    private String createTime;
}
