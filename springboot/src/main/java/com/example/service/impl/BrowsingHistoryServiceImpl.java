package com.example.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.example.entity.BrowsingHistory;
import com.example.entity.Company;
import com.example.entity.Job;
import com.example.mapper.BrowsingHistoryMapper;
import com.example.service.BrowsingHistoryService;
import com.example.service.CompanyService;
import com.example.service.JobService;
import com.example.vo.BrowsingHistoryVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class BrowsingHistoryServiceImpl
        extends ServiceImpl<BrowsingHistoryMapper, BrowsingHistory>
        implements BrowsingHistoryService {

    @Autowired
    private JobService jobService;

    @Autowired
    private CompanyService companyService;


    @Override
    public void recordView(Long studentId, Long jobId) {

        if (studentId == null || jobId == null) {
            throw new RuntimeException("studentId 或 jobId 不能为空");
        }

        BrowsingHistory history = lambdaQuery()
                .eq(BrowsingHistory::getStudentId, studentId)
                .eq(BrowsingHistory::getJobId, jobId)
                .one();

        if (history == null) {
            // 第一次浏览 → 插入
            history = new BrowsingHistory();
            history.setStudentId(studentId);
            history.setJobId(jobId);
            history.setCount(1);
            save(history);
        } else {
            // 已存在 → 次数 +1
            history.setCount(history.getCount() + 1);
            updateById(history);
        }
    }


    @Override
    public List<BrowsingHistoryVO> listByStudent(Long studentId) {

        List<BrowsingHistory> list = lambdaQuery()
                .eq(BrowsingHistory::getStudentId, studentId)
                .orderByDesc(BrowsingHistory::getUpdateTime)
                .list();

        return list.stream().map(h -> {
            BrowsingHistoryVO vo = new BrowsingHistoryVO();
            BeanUtils.copyProperties(h, vo);

            Job job = jobService.getById(h.getJobId());
            vo.setJob(job);

            // ⭐ 查询公司名称
            Company company = companyService.getById(job.getCompanyId());
            vo.setCompanyName(company != null ? company.getName() : "未知公司");

            return vo;
        }).collect(Collectors.toList());
    }

}

