package com.example.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.Resume;
import com.example.mapper.ResumeMapper;
import com.example.service.ResumeService;
import org.springframework.stereotype.Service;

@Service
public class ResumeServiceImpl extends ServiceImpl<ResumeMapper, Resume> implements ResumeService {
}
