package com.example.vo;

import lombok.Data;
import java.util.Date;

@Data
public class ApplicationVO {
    private Long applicationId;
    private Long jobId;
    private String jobTitle;
    private String companyName;
    private String location;
    private Integer salaryMin;
    private Integer salaryMax;
    private Integer status;
    private Date createTime;
}
