package com.example.entity;

import lombok.Data;
import java.util.Date;

@Data
public class Job {

    private Long id;
    private Long companyId;
    private String title;
    private Long categoryId;
    private String description;
    private String requirements;
    private Integer salaryMin;
    private Integer salaryMax;
    private String location;
    private Integer status;
    private Date createTime;
    private Date updateTime;
}
