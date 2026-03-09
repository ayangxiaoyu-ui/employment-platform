package com.example.entity;

import lombok.Data;
import java.util.Date;

@Data
public class Resume {
    private Long id;
    private Long studentId;
    private String title;
    private String content;
    private String fileUrl;
    private Integer isPublic;
    private Date createTime;
    private Date updateTime;
}
