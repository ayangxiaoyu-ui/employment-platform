package com.example.entity;

import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.Data;
import java.util.Date;

@Data
public class Resume {
@JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    private Long studentId;
    private String title;
    private String content;
    private String fileUrl;
    private Integer isPublic;
    private Date createTime;
    private Date updateTime;
    private Integer type;  // 1=在线简历  2=附件简历

}
