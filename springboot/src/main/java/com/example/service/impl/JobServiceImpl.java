package com.example.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.Job;
import com.example.mapper.JobMapper;
import com.example.service.JobService;
import org.springframework.stereotype.Service;

@Service
public class JobServiceImpl extends ServiceImpl<JobMapper, Job> implements JobService {
}
