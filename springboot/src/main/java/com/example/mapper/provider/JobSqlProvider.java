package com.example.mapper.provider;

public class JobSqlProvider {

    public String filterJobs(String keyword, Long categoryId) {
        StringBuilder sql = new StringBuilder();
        sql.append("""
            SELECT j.*, c.name AS companyName, c.logo AS companyLogo
            FROM job j
            LEFT JOIN company c ON j.company_id = c.id
            WHERE j.status = 1
        """);

        if (keyword != null && !keyword.isEmpty()) {
            sql.append(" AND (j.title LIKE CONCAT('%', #{keyword}, '%') ");
            sql.append(" OR j.description LIKE CONCAT('%', #{keyword}, '%') ");
            sql.append(" OR j.location LIKE CONCAT('%', #{keyword}, '%') ");  // ⭐ 必须加
            sql.append(" OR c.name LIKE CONCAT('%', #{keyword}, '%')) ");
        }
vv          

        if (categoryId != null) {
            sql.append(" AND j.category_id = #{categoryId} ");
        }

        sql.append(" ORDER BY j.create_time DESC ");

        return sql.toString();
    }
}
