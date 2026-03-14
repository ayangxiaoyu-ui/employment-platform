package com.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.entity.Job;

import java.util.List;

public interface JobService extends IService<Job> {

    // 查询所有岗位（含公司信息）
    List<Job> getAllJobsWithCompany();

    // 根据 ID 查询岗位（含公司信息）
    Job getJobDetail(Long id);
}
