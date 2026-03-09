package com.example.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.Application;
import com.example.mapper.ApplicationMapper;
import com.example.service.ApplicationService;
import org.springframework.stereotype.Service;

@Service
public class ApplicationServiceImpl
        extends ServiceImpl<ApplicationMapper, Application>
        implements ApplicationService {
}
