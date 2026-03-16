package com.example.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.Job;
import com.example.mapper.JobMapper;
import com.example.service.JobService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class JobServiceImpl extends ServiceImpl<JobMapper, Job> implements JobService {
    @Override
    public boolean createJob(Job job) {
        return this.save(job);
    }

    @Autowired
    private JobMapper jobMapper;

    /** 全部岗位（含公司信息） */
    @Override
    public List<Job> getAllJobsWithCompany() {
        return jobMapper.selectAllWithCompany();
    }

    /** 岗位详情（含公司信息） */
    @Override
    public Job getJobDetail(Long id) {
        return jobMapper.selectDetail(id);
    }

    /** ⭐ 统一筛选（关键词 + 分类） */
    @Override
    public List<Job> filterJobs(String keyword, Long categoryId) {
        return jobMapper.filterJobs(keyword, categoryId);
    }
}
