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
    @Autowired
    private JobMapper jobMapper;

    @Override
    public List<Job> getAllJobsWithCompany() {
        return jobMapper.selectAllWithCompany();
    }

    @Override
    public Job getJobDetail(Long id) {
        List<Job> list = jobMapper.selectAllWithCompany();
        return list.stream()
                .filter(j -> j.getId().equals(id))
                .findFirst()
                .orElse(null);
    }
}
