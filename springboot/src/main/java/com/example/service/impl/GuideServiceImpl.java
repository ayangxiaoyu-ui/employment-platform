package com.example.service.impl;


import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.Guide;
import com.example.mapper.GuideMapper;
import com.example.service.GuideService;
import org.springframework.stereotype.Service;

@Service
public class GuideServiceImpl extends ServiceImpl<GuideMapper, Guide> implements GuideService {

}