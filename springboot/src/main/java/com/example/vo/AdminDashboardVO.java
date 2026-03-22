package com.example.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class AdminDashboardVO {

    /** 学生账号数（sys_user.role=STUDENT 且 status=1） */
    private long studentUserCount;

    /** 企业账号数 */
    private long companyUserCount;

    /** 学生档案条数 */
    private long studentProfileCount;

    /** 企业档案条数 */
    private long companyProfileCount;

    /** 在招岗位（status=1） */
    private long openJobCount;

    /** 岗位总数 */
    private long totalJobCount;

    /** 投递总次数 */
    private long totalApplications;

    /** 近 7 天新增投递 */
    private long applicationsLast7Days;

    /** 公告数 */
    private long newsCount;

    /** 就业指导文章数 */
    private long guideCount;

    /** 站内消息数 */
    private long messageCount;

    /** 简历数 */
    private long resumeCount;

    /** 近 7 天每日投递量（按本地时区自然日，共 7 个点，从最早一天到昨天/今天） */
    private List<DailyCountVO> applicationTrend = new ArrayList<>();

    @Data
    public static class DailyCountVO {
        /** 展示用，如 03-16 */
        private String label;
        private long count;

        public DailyCountVO(String label, long count) {
            this.label = label;
            this.count = count;
        }
    }
}
