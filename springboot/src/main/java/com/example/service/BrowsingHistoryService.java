package com.example.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.example.entity.BrowsingHistory;
import com.example.vo.BrowsingHistoryVO;

import java.util.List;

public interface BrowsingHistoryService extends IService<BrowsingHistory> {

    void recordView(Long studentId, Long jobId);

    List<BrowsingHistoryVO> listByStudent(Long studentId);
}
