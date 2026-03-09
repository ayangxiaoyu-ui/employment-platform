package com.example.entity;

import lombok.Data;
import java.util.Date;

@Data
public class Application {
    private Long id;
    private Long jobId;
    private Long studentId;
    private Long resumeId;
    private Integer status;
    private Date createTime;
}
