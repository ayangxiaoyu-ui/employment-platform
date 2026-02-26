/*
 Navicat Premium Data Transfer

 Source Server         : Localhost
 Source Server Type    : MySQL
 Source Server Version : 8.0.0
 Source Schema         : employment_platform

 Target Server Type    : MySQL
 Target Server Version : 8.0.0
 File Encoding         : 65001

 Date: 23/12/2025
 Description: 大学生就业服务平台数据库脚本 (含浏览记录与推荐支持)
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- 1. 用户表 (所有角色的登录信息)
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) NOT NULL COMMENT '密码',
  `role` varchar(20) NOT NULL COMMENT '角色: ADMIN, COMPANY, STUDENT',
  `status` int(1) DEFAULT 1 COMMENT '状态: 1-正常, 0-禁用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统用户表';

-- ----------------------------
-- 2. 学生信息表
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '关联用户ID',
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `gender` varchar(10) DEFAULT NULL COMMENT '性别',
  `phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `university` varchar(100) DEFAULT NULL COMMENT '毕业院校',
  `major` varchar(100) DEFAULT NULL COMMENT '专业',
  `graduation_year` int(4) DEFAULT NULL COMMENT '毕业年份',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='学生表';

-- ----------------------------
-- 3. 企业信息表
-- ----------------------------
DROP TABLE IF EXISTS `company`;
CREATE TABLE `company` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL COMMENT '关联用户ID',
  `name` varchar(100) NOT NULL COMMENT '企业名称',
  `description` text COMMENT '企业简介',
  `logo` varchar(255) DEFAULT NULL COMMENT '企业Logo',
  `address` varchar(200) DEFAULT NULL COMMENT '详细地址',
  `industry` varchar(50) DEFAULT NULL COMMENT '所属行业',
  `scale` varchar(50) DEFAULT NULL COMMENT '人员规模',
  `contact_person` varchar(50) DEFAULT NULL COMMENT '联系人',
  `contact_phone` varchar(20) DEFAULT NULL COMMENT '联系电话',
  `status` int(1) DEFAULT 0 COMMENT '审核状态: 0-待审核, 1-通过, 2-拒绝',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='企业表';

-- ----------------------------
-- 4. 职位分类表 (字典表)
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL COMMENT '分类名称',
  `type` int(1) DEFAULT 1 COMMENT '类型: 1-职位分类, 2-行业分类',
  `parent_id` bigint(20) DEFAULT 0 COMMENT '父级ID',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='分类字典表';

-- ----------------------------
-- 5. 职位信息表
-- ----------------------------
DROP TABLE IF EXISTS `job`;
CREATE TABLE `job` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_id` bigint(20) NOT NULL COMMENT '发布企业ID',
  `title` varchar(100) NOT NULL COMMENT '职位名称',
  `category_id` bigint(20) DEFAULT NULL COMMENT '职位分类ID',
  `description` text COMMENT '职位描述',
  `requirements` text COMMENT '任职要求',
  `salary_min` int(11) DEFAULT NULL COMMENT '最低薪资',
  `salary_max` int(11) DEFAULT NULL COMMENT '最高薪资',
  `location` varchar(100) DEFAULT NULL COMMENT '工作地点',
  `status` int(1) DEFAULT 1 COMMENT '状态: 1-招聘中, 0-已下架',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发布时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位表';

-- ----------------------------
-- 6. 简历表
-- ----------------------------
DROP TABLE IF EXISTS `resume`;
CREATE TABLE `resume` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `student_id` bigint(20) NOT NULL COMMENT '关联学生ID',
  `title` varchar(100) DEFAULT '我的简历' COMMENT '简历名称',
  `content` text COMMENT '简历详情(JSON格式存储教育/实习经历)',
  `file_url` varchar(255) DEFAULT NULL COMMENT '附件简历URL',
  `is_public` int(1) DEFAULT 1 COMMENT '是否公开: 1-公开, 0-保密',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_student_id` (`student_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='简历表';

-- ----------------------------
-- 7. 职位申请记录表
-- ----------------------------
DROP TABLE IF EXISTS `application`;
CREATE TABLE `application` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `job_id` bigint(20) NOT NULL COMMENT '职位ID',
  `student_id` bigint(20) NOT NULL COMMENT '学生ID',
  `resume_id` bigint(20) NOT NULL COMMENT '使用的简历ID',
  `status` int(1) DEFAULT 0 COMMENT '状态: 0-待查看, 1-已查看, 2-面试邀请, 3-不合适, 4-已录用',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '投递时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_job_student` (`job_id`, `student_id`) COMMENT '同一职位只能投递一次'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位申请表';

-- ----------------------------
-- 8. 消息表 (新增：支持企业主动联系)
-- ----------------------------
DROP TABLE IF EXISTS `message`;
CREATE TABLE `message` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sender_id` bigint(20) NOT NULL COMMENT '发送者用户ID',
  `receiver_id` bigint(20) NOT NULL COMMENT '接收者用户ID',
  `content` text NOT NULL COMMENT '消息内容',
  `type` int(1) DEFAULT 1 COMMENT '类型: 1-普通消息, 2-面试通知, 3-系统通知',
  `is_read` int(1) DEFAULT 0 COMMENT '状态: 0-未读, 1-已读',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
  PRIMARY KEY (`id`),
  KEY `idx_receiver` (`receiver_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='站内消息表';

-- ----------------------------
-- 9. 新闻/公告表
-- ----------------------------
DROP TABLE IF EXISTS `news`;
CREATE TABLE `news` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL COMMENT '标题',
  `content` longtext COMMENT '内容',
  `author_id` bigint(20) DEFAULT NULL COMMENT '发布人ID',
  `view_count` int(11) DEFAULT 0 COMMENT '浏览量',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='新闻公告表';

-- ----------------------------
-- 10. 浏览历史表 (新增：记录用户查看过的职位)
-- ----------------------------
DROP TABLE IF EXISTS `browsing_history`;
CREATE TABLE `browsing_history` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `student_id` bigint(20) NOT NULL COMMENT '学生ID',
  `job_id` bigint(20) NOT NULL COMMENT '职位ID',
  `count` int(11) DEFAULT 1 COMMENT '浏览次数',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '最后浏览时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_job` (`student_id`, `job_id`) COMMENT '同一个学生对同一个职位只存一条记录'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='浏览历史表';

SET FOREIGN_KEY_CHECKS = 1;
-- ----------------------------
-- 11. 初始化管理员账号
-- ----------------------------
-- 默认管理员账号：
-- 用户名: admin
-- 密码: admin123
-- 角色: ADMIN
-- 
-- 如需修改密码，请使用以下方法生成BCrypt哈希：
-- 1. 在Java代码中运行: BCrypt.hashpw("你的密码")
-- 2. 或使用在线BCrypt工具生成
-- 3. 替换下面的password字段值
INSERT IGNORE INTO `sys_user` (`username`, `password`, `role`, `status`) 
VALUES ('admin', '$2a$10$ipNCTTJXqmhCif31hcybWOaPaqc4UGhPKT4gyP3aObt7jqNPLVLuS', 'ADMIN', 1);


-- ----------------------------
-- 12. 行业分类表插入数据
-- ----------------------------
-- 1. 清空表（如果需要重新插入，取消注释执行）
-- TRUNCATE TABLE category;

-- ================================
--          行业分类 (type = 2)
-- ================================

-- 互联网 / 科技大类
INSERT INTO category (name, type, parent_id) VALUES ('互联网/电子商务', 2, 0);
SET @internet_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('社交媒体平台', 2, @internet_id),
('短视频/直播平台', 2, @internet_id),
('在线电商平台', 2, @internet_id),
('在线教育平台', 2, @internet_id),
('本地生活服务(O2O)', 2, @internet_id),
('内容社区/知识付费', 2, @internet_id),
('Web3/元宇宙平台', 2, @internet_id);

-- 软件与信息技术服务
INSERT INTO category (name, type, parent_id) VALUES ('计算机软件', 2, 0);
SET @software_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('企业级 SaaS 服务', 2, @software_id),
('AI 大模型平台', 2, @software_id),
('云计算/大数据服务', 2, @software_id),
('区块链/智能合约平台', 2, @software_id),
('低代码/无代码开发平台', 2, @software_id);

-- 金融业
INSERT INTO category (name, type, parent_id) VALUES ('金融业', 2, 0);
SET @finance_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('传统商业银行', 2, @finance_id),
('互联网银行/直销银行', 2, @finance_id),
('证券/期货/基金公司', 2, @finance_id),
('保险/再保险', 2, @finance_id),
('第三方支付/数字货币', 2, @finance_id),
('消费金融/小额贷款', 2, @finance_id),
('财富管理/私募股权', 2, @finance_id);

-- 房地产与建筑业
INSERT INTO category (name, type, parent_id) VALUES ('房地产与建筑业', 2, 0);
SET @real_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('住宅/商业地产开发', 2, @real_id),
('物业管理/社区服务', 2, @real_id),
('建筑施工/工程总包', 2, @real_id),
('建筑设计/规划设计', 2, @real_id),
('室内设计/软装设计', 2, @real_id),
('智能建筑/楼宇自动化', 2, @real_id);

-- 制造业
INSERT INTO category (name, type, parent_id) VALUES ('制造业', 2, 0);
SET @manufact_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('汽车及新能源汽车制造', 2, @manufact_id),
('半导体/集成电路制造', 2, @manufact_id),
('消费电子/智能硬件', 2, @manufact_id),
('高端装备制造', 2, @manufact_id),
('光伏/风电新能源设备', 2, @manufact_id),
('锂电池/储能系统', 2, @manufact_id);

-- 其他主流行业（简要）
INSERT INTO category (name, type, parent_id) VALUES
('教育培训', 2, 0),
('医疗健康', 2, 0),
('文化娱乐/传媒', 2, 0),
('旅游/酒店餐饮', 2, 0),
('物流/供应链', 2, 0),
('人力资源服务', 2, 0),
('环保/新能源', 2, 0),
('农业/食品', 2, 0);

-- 小众/冷门行业示例
INSERT INTO category (name, type, parent_id) VALUES
('文物修复与古籍保护', 2, 0),
('深海探测与海洋工程', 2, 0),
('太空旅游与商业航天', 2, 0),
('传统香料与调香工艺', 2, 0),
('昆虫养殖与生物技术', 2, 0),
('菌菇培育与食用菌产业', 2, 0);

-- ================================
--          职位分类 (type = 1)
-- ================================

-- 前端开发大类
INSERT INTO category (name, type, parent_id) VALUES ('前端开发', 1, 0);
SET @frontend_id = LAST_INSERT_ID();

-- 二级
INSERT INTO category (name, type, parent_id) VALUES
('React 技术栈', 1, @frontend_id),
('Vue 技术栈', 1, @frontend_id),
('Angular 技术栈', 1, @frontend_id),
('小程序/跨端开发', 1, @frontend_id),
('Web3/区块链前端', 1, @frontend_id);

-- 三级 - React
SET @react_id = (SELECT id FROM category WHERE name = 'React 技术栈' AND parent_id = @frontend_id LIMIT 1);
INSERT INTO category (name, type, parent_id) VALUES
('React + TypeScript', 1, @react_id),
('Next.js 全栈开发', 1, @react_id),
('React Native 移动端', 1, @react_id),
('Remix / React Router 专家', 1, @react_id),
('Redux / Zustand / Recoil 状态管理', 1, @react_id),
('React 三维可视化 (Three.js)', 1, @react_id);

-- 三级 - Vue
SET @vue_id = (SELECT id FROM category WHERE name = 'Vue 技术栈' AND parent_id = @frontend_id LIMIT 1);
INSERT INTO category (name, type, parent_id) VALUES
('Vue 3 + Composition API', 1, @vue_id),
('Nuxt 3 服务端渲染', 1, @vue_id),
('Vite + Vue 工程化', 1, @vue_id),
('Pinia / Vuex 状态管理', 1, @vue_id),
('uni-app / Taro 跨端小程序', 1, @vue_id);

-- 后端开发大类
INSERT INTO category (name, type, parent_id) VALUES ('后端开发', 1, 0);
SET @backend_id = LAST_INSERT_ID();

-- 二级
INSERT INTO category (name, type, parent_id) VALUES
('Java 后端', 1, @backend_id),
('Python 后端', 1, @backend_id),
('Go 后端', 1, @backend_id),
('Node.js 后端', 1, @backend_id);

-- 三级 - Java
SET @java_id = (SELECT id FROM category WHERE name = 'Java 后端' AND parent_id = @backend_id LIMIT 1);
INSERT INTO category (name, type, parent_id) VALUES
('Spring Boot 微服务', 1, @java_id),
('Spring Cloud 分布式系统', 1, @java_id),
('Dubbo + Zookeeper 服务治理', 1, @java_id),
('JVM 调优 / 高并发专家', 1, @java_id);

-- 三级 - Python
SET @python_id = (SELECT id FROM category WHERE name = 'Python 后端' AND parent_id = @backend_id LIMIT 1);
INSERT INTO category (name, type, parent_id) VALUES
('FastAPI 高性能服务', 1, @python_id),
('Django / Django REST', 1, @python_id),
('Flask + Celery 异步任务', 1, @python_id),
('Python 爬虫 / 反爬专家', 1, @python_id);

-- 算法 / AI 类
INSERT INTO category (name, type, parent_id) VALUES ('算法/AI工程师', 1, 0);
SET @ai_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('大模型微调工程师', 1, @ai_id),
('多模态模型工程师', 1, @ai_id),
('推荐系统算法工程师', 1, @ai_id),
('计算机视觉工程师', 1, @ai_id),
('NLP / 对话系统工程师', 1, @ai_id);

-- 测试 / QA
INSERT INTO category (name, type, parent_id) VALUES ('测试/QA', 1, 0);
SET @test_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('自动化测试工程师', 1, @test_id),
('接口测试工程师', 1, @test_id),
('性能测试工程师', 1, @test_id),
('安全渗透测试', 1, @test_id);

-- 运维 / DevOps
INSERT INTO category (name, type, parent_id) VALUES ('运维/DevOps', 1, 0);
SET @ops_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('Kubernetes 运维', 1, @ops_id),
('云原生架构师', 1, @ops_id),
('SRE 工程师', 1, @ops_id);

-- 产品类
INSERT INTO category (name, type, parent_id) VALUES ('产品类岗位', 1, 0);
SET @product_id = LAST_INSERT_ID();

INSERT INTO category (name, type, parent_id) VALUES
('ToC 增长产品', 1, @product_id),
('ToB 企业级产品', 1, @product_id),
('AI 产品经理', 1, @product_id);

-- 冷门岗位（直接一级）
INSERT INTO category (name, type, parent_id) VALUES
('文物修复师', 1, 0),
('古籍数字化专员', 1, 0),
('鲸豚行为研究员', 1, 0),
('深海探测数据分析师', 1, 0),
('太空葬礼策划师', 1, 0),
('传统香料调配师', 1, 0),
('昆虫养殖技术员', 1, 0),
('菌菇培育专家', 1, 0);


INSERT INTO sys_user (username, password, role, status, create_time, update_time) VALUES
('huawei_hr',     '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'COMPANY', 1, NOW(), NOW()),
('tencent_hr',    '$2b$10$BLnKLq9OwFyxBpPUq14dMOxLihGcseSfVCafO6KFP329P5QcIIixO', 'COMPANY', 1, NOW(), NOW()),
('bytedance_hr',  '$2b$10$H3cSv5q6qbgKgcgKbphhNu293eLdIwOWdSHk0Q30YFofyQmzND6ES', 'COMPANY', 1, NOW(), NOW()),
('alibaba_hr',    '$2b$10$r94KwT50UN6aA4UUGe9Cx.iH2OedinwKQIzDD6LSkxqCh.LXHCs.u', 'COMPANY', 1, NOW(), NOW()),
('catl_hr',       '$2b$10$LPqrsVOwcRY2nXNXazTJpOhWYA5eU2GXLD/0qSTWk6Q07frz8cqc6', 'COMPANY', 1, NOW(), NOW()),
('byd_hr',        '$2b$10$yVuo0ELuL51/VEFDMEDv/.NdCwDx81tBC.oRQKgY/TfsVEVH1Pl2e', 'COMPANY', 1, NOW(), NOW()),
('smic_hr',       '$2b$10$HGinz0tlHOFd7buYfRjsIuewIsLImVwvOqKmIqjsx9ASqCyEEKAym', 'COMPANY', 1, NOW(), NOW()),
('sgcc_hr',       '$2b$10$mW5VNALkISFXDX4XBlSw/e9V4ItjQeok2HFn0tM4vsQdcY/hXOnRi', 'COMPANY', 1, NOW(), NOW()),
('icbc_hr',       '$2b$10$JSi14wBPPbUt4OfdRC5RCe90JADY4gPANBmIw6i22mjNo97zkPO0i', 'COMPANY', 1, NOW(), NOW()),
('cnpc_hr',       '$2b$10$9rti7e8sYD4hMCFDpTNe0O220.sKBpXxZ1yqsMjKeZLBB4TFNX.TK', 'COMPANY', 1, NOW(), NOW()),
('xiaomi_hr',     '$2b$10$XTmA3ZMwbN/sgoVBHy2mxeyKQ2BBsuxMPJSN6eHsxo6FJTV/Hn1Ce', 'COMPANY', 1, NOW(), NOW()),
('dji_hr',        '$2b$10$ly8iRXYeieJa4hJ1/lBB5ujO3yW5N6v8kZpuXz7JenB/wGkjOo1g6', 'COMPANY', 1, NOW(), NOW()),
('baidu_hr',      '$2b$10$GnaHSGSzsq2lNfe520ebfu.meR8a5ufaD4zcVLtesBo/sERun.YVe', 'COMPANY', 1, NOW(), NOW()),
('sensetime_hr',  '$2b$10$j9JDK.019ongTERYc7PcT.ipNNdzA49.O679doTZiCONwPCOQkxOK', 'COMPANY', 1, NOW(), NOW()),
('petrochina_hr', '$2b$10$mJyLLKfPJe2ucLyrq6JeqeWluM5VijLI9xh7wIVdzh5XnwGFsdzCa', 'COMPANY', 1, NOW(), NOW()),
('sinopec_hr',    '$2b$10$.Hd6xl0X2lMGfTgtteMCx.EmGEJGTfSzZRSoyrF7zbfmCMsUFN/oy', 'COMPANY', 1, NOW(), NOW()),
('citicbank_hr',  '$2b$10$m1GN9kD7zwsnVMTOHrdshuEBktnhs3f6hydkHUCrATCiFJ1u4BAdy', 'COMPANY', 1, NOW(), NOW()),
('cicc_hr',       '$2b$10$UQV/T9/2MA2B6yeMtZBgme2oLskAgQYRkFzP9digIZ1akxkCit5h.', 'COMPANY', 1, NOW(), NOW()),
('pwc_hr',        '$2b$10$tAHBN8K.Oy43X7/lwqSKs.79JHuvbfYXqXaw97i1OKr70qotSeKU.', 'COMPANY', 1, NOW(), NOW()),
('ymtc_hr',       '$2b$10$m4rFLB9YHXfi7kG1mD2Gu.32Jaz31kzWkIfDr.I.UqU.1iCzu/HRG', 'COMPANY', 1, NOW(), NOW()),
('hisilicon_hr',  '$2b$10$kUapkYgNpMmLO4lAsM0kc.n6mz6XTc4PiWZeNaEi3dB.rTl7/eOee', 'COMPANY', 1, NOW(), NOW()),
('longi_hr',      '$2b$10$gThGLO.9miZxjAY4xOdrmO4ulwCzSxLOknp.cdEF0tYzipSYF.HoC', 'COMPANY', 1, NOW(), NOW()),
('lixiang_hr',    '$2b$10$n.cGs7w.5NrL5MfmLof9sOTJXmsL1OL25z6TSkBiBtUx7AY1vlaeq', 'COMPANY', 1, NOW(), NOW()),
('jd_hr',         '$2b$10$us0mTF.GU9v6vo6TyLUWuuNzsVTL1xy.RhHlSSYT81FseJbmCp3C6', 'COMPANY', 1, NOW(), NOW()),
('netease_hr',    '$2b$10$58vkNMjRlM.zq3FUPiG5bei2hPTOBPjzP6YKQJfEG9AC2E2idPJ1K', 'COMPANY', 1, NOW(), NOW());