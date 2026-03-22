package com.example.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class CompanyDashboardVO {

    /** 投递总次数 */
    private long totalApplications;

    /** 近 7 天新增投递 */
    private long last7DaysApplications;

    /** 待查看（status=0） */
    private long pendingViewCount;

    /** 已查看（status=1） */
    private long viewedCount;

    /** 面试邀请（status=2） */
    private long interviewCount;

    /** 不合适（status=3） */
    private long rejectedCount;

    /** 已录用（status=4） */
    private long hiredCount;

    /** 在招岗位数 */
    private long openJobCount;

    private List<RecentApplicationItemVO> recentApplications = new ArrayList<>();
}
