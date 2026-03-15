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




----------
--11.我的收藏表

DROP TABLE IF EXISTS `favorite`;
CREATE TABLE `favorite` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `student_id` bigint(20) NOT NULL COMMENT '学生ID',
  `job_id` bigint(20) NOT NULL COMMENT '职位ID',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '收藏时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_student_job` (`student_id`, `job_id`) COMMENT '同一个学生对同一个职位只存一条收藏记录'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='职位收藏表';




--12就业指导文章·······
DROP TABLE IF EXISTS guide;

CREATE TABLE guide (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL COMMENT '标题',
  description VARCHAR(500) COMMENT '简介',
  cover VARCHAR(300) DEFAULT '/uploads/guide/default.jpg' COMMENT '封面图',
  content LONGTEXT COMMENT '内容（富文本）',
  view_count INT DEFAULT 0 COMMENT '浏览量',
  create_time DATETIME DEFAULT CURRENT_TIMESTAMP
);


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



INSERT INTO company (
    user_id, 
    name, 
    description, 
    logo, 
    address, 
    industry, 
    scale, 
    contact_person, 
    contact_phone, 
    status
) VALUES
(19, '华为技术有限公司', '全球领先的ICT基础设施和智能终端提供商，5G、AI、云计算等领域强势，海归研发岗位众多。', '/uploads/logo/huawei-logo.png', '深圳市龙岗区坂田基地', '计算机软件', '50万人以上', 'HR招聘组', '0755-12345678', 1),
(20, '腾讯科技（深圳）有限公司', '社交、游戏、支付、云计算全覆盖，海归产品/算法/国际业务岗位需求大。', '/uploads/logo/tencent-logo.png', '深圳市南山区腾讯滨海大厦', '互联网/电子商务', '50万人以上', '校园招聘组', '0755-86013388', 1),
(21, '字节跳动科技有限公司', '抖音、今日头条、TikTok母公司，算法/AI/国际化岗位对海归友好。', '/uploads/logo/bytedance-logo.png', '北京市海淀区知春路', '互联网/电子商务', '50万人以上', '人才招聘部', '010-12345678', 1),
(22, '阿里巴巴集团', '电商、云计算、AI、金融科技，海归回国首选之一。', '/uploads/logo/alibaba-com-logo.png', '杭州市余杭区文一西路', '互联网/电子商务', '50万人以上', '招聘中心', '0571-12345678', 1),
(23, '宁德时代新能源科技股份有限公司', '全球动力电池龙头，储能/电池材料/研发岗位大量招海归。', '/uploads/logo/contemporary-amperex-technology-catl-logo.png', '福建省宁德市', '锂电池/储能系统', '50万人以上', '人力资源部', '0593-8908888', 1),
(24, '比亚迪股份有限公司', '新能源汽车、电池、轨道交通全产业链，海归工程/材料/智能驾驶热门。', '/uploads/logo/byd-atualizada-logo.png', '深圳市坪山区', '汽车及新能源汽车制造', '50万人以上', '校园招聘', '0755-89888888', 1),
(25, '中芯国际集成电路制造（北京）有限公司', '中国大陆最大晶圆代工厂，工艺/设备/研发岗位急需海归。', '/uploads/logo/smic-logo.png', '北京市经济技术开发区', '半导体/集成电路制造', '1-5万人', '招聘专员', '010-67898888', 1),
(26, '国家电网有限公司', '世界最大公用事业企业，新能源、智能电网方向招大量海归。', '/uploads/logo/sgcc-logo.png', '北京市西城区西长安街', '电力/新能源', '50万人以上', '人力资源部', '010-12345678', 1),
(27, '中国工商银行股份有限公司', '全球最大商业银行，金融科技、跨境业务、海归优选。', '/uploads/logo/icbc-logo.png', '北京市西城区复兴门内大街', '金融业', '50万人以上', '招聘中心', '010-66105799', 1),
(28, '中国石油天然气集团有限公司', '能源巨头，海外项目、新能源转型招海归。', '/uploads/logo/china-national-petroleum-corporation-logo.png', '北京市东城区东直门北大街', '石油化工', '50万人以上', '人才招聘', '010-62094114', 1),
(29, '小米科技有限责任公司', '智能手机、AIoT、智能硬件，海归产品/算法/智能硬件热门。', '/uploads/logo/xiaomi-logo.png', '北京市海淀区', '消费电子/智能硬件', '1-5万人', '招聘部', '010-12345678', 1),
(30, '大疆创新科技有限公司', '全球无人机领导者，计算机视觉/机器人/算法方向海归热门。', '/uploads/logo/dji-logo.png', '深圳市南山区', '消费电子/智能硬件', '1-5万人', 'HR部门', '0755-26656677', 1),
(31, '百度集团', 'AI大模型、搜索、智能驾驶，海归AI/算法工程师首选。', '/uploads/logo/baidu-logo.png', '北京市海淀区上地', '互联网/电子商务', '1-5万人', '校园招聘', '010-59920000', 1),
(32, '商汤科技', 'AI计算机视觉/大模型领军企业，海归深度学习/多模态方向需求大。', '/uploads/logo/sensetime-logo.jpeg', '上海市徐汇区', '人工智能', '5000-9999人', '人才中心', '021-12345678', 1),
(33, '中国石油天然气股份有限公司（中石油）', '世界500强能源巨头，海外项目、新能源转型、勘探开发方向大量招海归。', '/uploads/logo/petrochina-logo.png', '北京市东城区', '石油化工', '50万人以上', '校园招聘组', '010-62094114', 1),
(34, '中国石油化工股份有限公司（中石化）', '全球最大炼化一体化企业，化工/新能源/材料方向海归需求强劲。', '/uploads/logo/sinopec-logo.png', '北京市朝阳区朝阳门北大街', '石油化工', '50万人以上', '人力资源部', '010-59960114', 1),
(35, '中信银行股份有限公司', '金融业海归录用占比超30%，跨境金融、科技金融岗位首选。', '/uploads/logo/citicbank-logo.jpeg', '北京市朝阳区光华路', '金融业', '5-10万人', '招聘中心', '010-64666688', 1),
(36, '中国国际金融股份有限公司（中金公司）', '中国顶级投行，跨境并购、股权融资、研究方向海归核心岗位。', '/uploads/logo/cicc-logo.png', '北京市朝阳区建国门外大街', '金融业', '1-5万人', '人才招聘部', '010-65051166', 1),
(37, '普华永道（PwC）中国', '四大会计师事务所，审计/税务/咨询/数字化转型，海归热门。', '/uploads/logo/pwc-logo.png', '上海市浦东新区陆家嘴环路', '金融业', '1-5万人', '校园招聘团队', '021-23238888', 1),
(38, '长江存储科技有限责任公司', '国产3D NAND闪存龙头，存储芯片/工艺研发招大量海归。', '/uploads/logo/ymtc-logo.jpeg', '湖北省武汉市东湖高新区', '半导体/集成电路制造', '1-5万人', 'HR部门', '027-87808888', 1),
(39, '华为海思半导体有限公司', '华为芯片设计子公司，AI芯片/麒麟/昇腾方向海归工程师首选。', '/uploads/logo/hisilicon-logo.png', '深圳市龙岗区坂田', '半导体/集成电路制造', '50万人以上', '招聘专员', '0755-12345678', 1),
(40, '隆基绿能科技股份有限公司', '全球光伏组件龙头，硅片/电池/组件研发，海归材料/设备热门。', '/uploads/logo/longi-logo.png', '陕西省西安市经济技术开发区', '光伏/风电新能源设备', '5-10万人', '招聘部', '029-8908888', 1),
(41, '理想汽车科技有限公司', '新能源汽车新势力，智能驾驶/三电系统/产品岗位对海归开放。', '/uploads/logo/li-auto-logo.png', '北京市朝阳区望京', '汽车及新能源汽车制造', '1-5万人', '人才中心', '400-686-0900', 1),
(42, '京东集团', '电商+物流+健康+科技，海归供应链/大数据/海外业务岗位多。', '/uploads/logo/jd-group-logo.png', '北京市亦庄经济开发区', '互联网/电子商务', '50万人以上', '校园招聘', '400-606-5500', 1),
(43, '网易集团', '游戏/音乐/教育/电商，海归游戏开发/算法/国际产品方向。', '/uploads/logo/netease-games-logo.png', '杭州市滨江区网易大厦', '互联网/电子商务', '1-5万人', '招聘组', '0571-89888888', 1);




INSERT INTO sys_user (username, password, role, status, create_time, update_time) VALUES
('meituan_hr',        '$2a$10$QfZfZfZfZfZfZfZfZfZfZu.abcdef1234567890abcdef1234567890', 'COMPANY', 1, NOW(), NOW()),
('kuaishou_hr',       '$2a$10$abcdef1234567890abcdef1234567890abcdef1234567890abcdef', 'COMPANY', 1, NOW(), NOW()),
('bilibili_hr',       '$2a$10$1234567890abcdef1234567890abcdef1234567890abcdef123456', 'COMPANY', 1, NOW(), NOW()),
('shein_hr',          '$2a$10$7890abcdef1234567890abcdef1234567890abcdef1234567890ab', 'COMPANY', 1, NOW(), NOW()),
('vipshop_hr',        '$2a$10$cdef1234567890abcdef1234567890abcdef1234567890abcdef12', 'COMPANY', 1, NOW(), NOW()),
('xiaohongshu_hr',    '$2a$10$def1234567890abcdef1234567890abcdef1234567890abcdef123', 'COMPANY', 1, NOW(), NOW()),
('oppo_hr',           '$2a$10$ef1234567890abcdef1234567890abcdef1234567890abcdef1234', 'COMPANY', 1, NOW(), NOW()),
('vivo_hr',           '$2a$10$f1234567890abcdef1234567890abcdef1234567890abcdef12345', 'COMPANY', 1, NOW(), NOW()),
('lenovo_hr',         '$2a$10$1234567890abcdef1234567890abcdef1234567890abcdef123456', 'COMPANY', 1, NOW(), NOW()),
('haier_hr',          '$2a$10$234567890abcdef1234567890abcdef1234567890abcdef1234567', 'COMPANY', 1, NOW(), NOW()),
('midea_hr',          '$2a$10$34567890abcdef1234567890abcdef1234567890abcdef12345678', 'COMPANY', 1, NOW(), NOW()),
('gac_aion_hr',       '$2a$10$4567890abcdef1234567890abcdef1234567890abcdef123456789', 'COMPANY', 1, NOW(), NOW()),
('xpeng_hr',          '$2a$10$567890abcdef1234567890abcdef1234567890abcdef1234567890', 'COMPANY', 1, NOW(), NOW()),
('zerorun_hr',        '$2a$10$7890abcdef1234567890abcdef1234567890abcdef123456789012', 'COMPANY', 1, NOW(), NOW()),
('deepseek_hr',       '$2a$10$890abcdef1234567890abcdef1234567890abcdef1234567890123', 'COMPANY', 1, NOW(), NOW()),
('moonshot_hr',       '$2a$10$90abcdef1234567890abcdef1234567890abcdef12345678901234', 'COMPANY', 1, NOW(), NOW()),
('zhipu_hr',          '$2a$10$0abcdef1234567890abcdef1234567890abcdef123456789012345', 'COMPANY', 1, NOW(), NOW()),
('minimax_hr',        '$2a$10$abcdef1234567890abcdef1234567890abcdef1234567890123456', 'COMPANY', 1, NOW(), NOW()),
('stepfun_hr',        '$2a$10$bcdef1234567890abcdef1234567890abcdef12345678901234567', 'COMPANY', 1, NOW(), NOW());

INSERT INTO company (
    user_id, 
    name, 
    description, 
    logo, 
    address, 
    industry, 
    scale, 
    contact_person, 
    contact_phone, 
    status
) VALUES
-- id 44
(44, '美团', '本地生活服务龙头，外卖、酒店、出行、社区团购，海归算法/产品/运营岗位众多。', '/uploads/logo/meituan-logo.png', '北京市朝阳区望京', '互联网/电子商务', '50万人以上', '校园招聘组', '010-57398888', 1),

-- id 45
(45, '快手科技', '短视频+直播平台，算法推荐、内容生态，海归推荐系统/多模态岗位需求大。', '/uploads/logo/kuaishou-icon-logo.png', '北京市海淀区中关村', '短视频/直播平台', '10万人以上', '人才招聘部', '400-123-4567', 1),

-- id 46
(46, '哔哩哔哩（B站）', '年轻人文化社区，动画、游戏、知识付费，海归内容/产品/国际化热门。', '/uploads/logo/bilibili-logo.png', '上海市杨浦区', '文化娱乐/传媒', '1-5万人', 'HR部门', '021-12345678', 1),

-- id 47
(47, 'SHEIN', '全球快时尚跨境电商，供应链、数据驱动，海归供应链/算法/海外业务首选。', '/uploads/logo/shein-logo.png', '南京市建邺区', '在线电商平台', '5-10万人', '招聘中心', '025-12345678', 1),

-- id 48
(48, '唯品会', '特卖电商、品牌折扣，海归供应链/大数据/产品岗位多。', '/uploads/logo/vipshop_logo.jpeg', '广州市海珠区', '互联网/电子商务', '1-5万人', '人力资源部', '020-12345678', 1),

-- id 49
(49, '小红书', '生活方式社区、种草电商，海归内容/增长/算法方向需求大。', '/uploads/logo/xiaohongshu-logo.png', '上海市徐汇区', '内容社区/知识付费', '1-5万人', '校园招聘', '021-12345678', 1),

-- id 50
(50, 'OPPO', '智能手机、IoT设备，海归影像算法/硬件/产品热门。', '/uploads/logo/oppo-logo.png', '东莞市长安镇', '消费电子/智能硬件', '5-10万人', '招聘部', '0769-12345678', 1),

-- id 51
(51, 'vivo', '智能手机、影像系统，海归AI/相机算法/海外市场岗位。', '/uploads/logo/vivo-logo.png', '东莞市', '消费电子/智能硬件', '5-10万人', 'HR团队', '0769-12345678', 1),

-- id 52
(52, '联想集团', 'PC、智能设备、服务器，海归AI服务器/云计算/研发方向。', '/uploads/logo/lenovo-logo.png', '北京市海淀区', '消费电子/智能硬件', '5-10万人', '招聘中心', '400-990-8888', 1),

-- id 53
(53, '海尔智家', '智能家居、家电物联网，海归AIoT/产品/海外业务热门。', '/uploads/logo/haier-new-logo.png', '青岛市崂山区', '消费电子/智能硬件', '10万人以上', '人力资源部', '4006-999-999', 1),

-- id 54
(54, '美的集团', '家电、智能制造，海归机器人/自动化/供应链方向。', '/uploads/logo/midea-logo.png', '佛山市顺德区', '消费电子/智能硬件', '10万人以上', '校园招聘', '400-889-9315', 1),

-- id 55
(55, '广汽埃安', '新能源汽车、智能驾驶，海归三电系统/自动驾驶热门。', '/uploads/logo/gac-motor-logo.png', '广州市番禺区', '汽车及新能源汽车制造', '1-5万人', '人才中心', '400-888-8888', 1),

-- id 56
(56, '小鹏汽车', '智能电动汽车、自动驾驶，海归AI/感知/规划算法首选。', '/uploads/logo/xpeng-motors-logo.png', '广州市黄埔区', '汽车及新能源汽车制造', '1-5万人', '招聘组', '400-828-8288', 1),

-- id 57
(57, '零跑汽车', '智能纯电汽车，海归电池管理/智能驾驶方向。', '/uploads/logo/zerorun-logo.png', '浙江省金华市', '汽车及新能源汽车制造', '1-5万人', '人力资源部', '400-101-1010', 1),

-- id 58
(58, 'DeepSeek', '国产大模型开源领先者，海归大模型/训练/推理工程师热门。', '/uploads/logo/deepseek-ai-icon-logo.png', '上海市浦东新区', 'AI 大模型平台', '5000-9999人', '招聘专员', '021-12345678', 1),

-- id 59
(59, 'Moonshot AI（Kimi）', '长文本大模型领跑者，海归多模态/长上下文/工程化方向。', '/uploads/logo/moonshot-logo.png', '北京市海淀区', 'AI 大模型平台', '5000-9999人', '人才招聘', '010-12345678', 1),

-- id 60
(60, '智谱AI（GLM）', '清华系大模型，GLM系列，海归基础模型/对齐/应用热门。', '/uploads/logo/zhipu-ai-icon-logo.png', '北京市海淀区', 'AI 大模型平台', '5000-9999人', 'HR部门', '010-12345678', 1),

-- id 61
(61, 'MiniMax', '海螺AI、Talkie等产品，海归多模态/对话系统/娱乐方向。', '/uploads/logo/minimax-logo.png', '上海市徐汇区', 'AI 大模型平台', '5000-9999人', '招聘团队', '021-12345678', 1),

-- id 62
(62, 'StepFun（阶跃星辰）', '国产多模态大模型，海归视觉/语音/多模态融合工程师首选。', '/uploads/logo/stepfun-icon-logo.png', '北京市海淀区', 'AI 大模型平台', '5000-9999人', '人才中心', '010-12345678', 1);


INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(19, '2026届前端开发实习生 (React/TS)', 57, '参与HarmonyOS NEXT及企业级管理平台的前端开发实习，优秀表现可获得转正机会或优先校招通道', '本科及以上在读学生（计算机科学、软件工程、电子信息工程等相关专业优先，2026届本科/硕士均可）\n熟练掌握React.js核心原理，包括函数组件、Hooks（useState/useEffect/useMemo/useCallback等）、Context API、自定义Hooks及高阶组件的使用\n精通TypeScript类型系统，能独立编写类型安全的组件、工具函数、接口定义，熟悉泛型、联合类型、交叉类型、类型守卫等高级用法\n熟悉现代前端工程化工具链，包括Vite、Webpack 5+、ESLint + Prettier、Stylelint、Husky、lint-staged、PostCSS、Tailwind CSS等，能独立配置项目并处理构建报错、打包优化问题\n有实际Web/小程序/管理后台项目开发经验（如个人作品集、GitHub开源仓库、学校大作业、实习经历）或参与过React/Vue相关竞赛/黑客松优先\n具备良好的代码审美和规范意识，理解组件设计原则、状态管理最佳实践（Zustand/Redux Toolkit/Recoil）、组件库封装、设计系统搭建，能写出可维护、高性能、可测试的前端代码\n对前端性能优化有较强敏感度，熟悉浏览器渲染原理、虚拟列表、图片懒加载、Tree Shaking、Code Splitting、Bundle分析、Web Vitals等技术\n英语四级及以上，能独立阅读英文技术文档、Stack Overflow、GitHub Issues、React官方博客及最新RFC\n每周至少到岗4天以上，实习期3–6个月，能适应快节奏的学习、代码审查与迭代环境，责任心强、沟通主动、乐于分享\n实习期间积极参与团队任务，表现优异者可优先进入华为校招绿色通道或直接转正', 5, 12, '深圳坂田', 1),
(19, '高级Java后端开发工程师 (社招)', 69, '负责5G/云计算/智能终端相关高并发分布式系统的核心后端开发与架构优化', '统招本科及以上学历，计算机/软件工程/通信相关专业\n3–8年Java后端实际开发经验，精通Spring Boot、Spring Cloud Alibaba、MyBatis-Plus等主流框架\n熟练掌握分布式系统常见技术栈，包括但不限于Redis（缓存/分布式锁）、Kafka/RocketMQ（消息队列）、Elasticsearch（搜索/日志）、MySQL（读写分离/分库分表）、Seata（分布式事务）\n深入理解微服务架构设计原则，熟悉服务注册发现（Nacos）、配置中心、负载均衡、熔断降级、限流、链路追踪（Skywalking/Zipkin）等\n有大规模系统（日活千万级以上）设计/重构/性能优化经验，熟悉JVM内存模型、GC调优、线程池使用、SQL优化、索引设计\n具备优秀的代码质量意识，熟悉设计模式、重构技巧、单元测试（JUnit5 + Mockito）、代码审查流程\n有开源项目贡献、专利、技术博客或内部技术分享经验者优先\n英语四级及以上，能流畅阅读英文技术文档、参与国际会议讨论或阅读Arxiv论文\n能适应高强度工作环境，具备较强的责任心、学习能力和团队协作精神，愿意参与7×24值班/OnCall', 25, 45, '深圳/西安', 1),
(19, '2026届大模型应用实习生', 82, '昇腾平台大模型部署/优化/应用开发实习', '人工智能/计算机相关专业硕士/本科高年级在读\n熟练使用PyTorch或TensorFlow框架，理解Transformer架构及常见训练/推理技巧\n熟悉大模型微调方法（如LoRA、QLoRA、PEFT）或部署框架（vLLM、TGI、TensorRT-LLM）至少一种\n有参与过大模型相关项目（Chatbot、RAG、智能体等）或开源贡献经验者优先\n了解昇腾NPU或华为云ModelArts基本使用加分\n具备较强的学习能力和问题解决能力，能快速上手新框架\n英语四级以上，能阅读英文技术论文和文档\n实习期间需保证较高出勤率，表现优异可转正式校招', 8, 15, '上海/深圳', 1),
(19, '云原生架构师 (社招)', 94, '华为云容器平台架构设计与优化', '本科及以上，5年以上云原生/K8s经验\n精通Kubernetes、Istio、服务网格、Observability（Prometheus+Grafana）\n有大规模集群（千节点以上）运维/架构经验\n熟悉云原生安全、CI/CD、GitOps等最佳实践\n有开源贡献或CNCF项目经验优先\n优秀的系统设计和沟通能力，英语良好', 35, 60, '深圳', 1);

-- 20 腾讯科技（深圳）有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(20, '2026届小程序前端实习生', 55, '微信生态小程序/小游戏开发实习，可转正', '本科及以上在读，计算机/设计相关专业\n熟练微信小程序原生开发，熟悉WXML/WXSS/JS及组件化开发\n有使用Taro、uni-app或NutUI等跨端框架经验加分\n理解小程序性能优化、包体积控制、启动速度优化等技巧\n有开发过完整小程序项目（电商、工具、游戏等）经验优先\n具备较好的审美和交互设计敏感度，能与设计师高效协作\n英语四级以上，能阅读英文技术文档\n每周到岗时间灵活但需保证实习质量，优秀者可获得转正机会', 5, 12, '深圳', 1),
(20, '推荐系统算法工程师 (社招)', 84, '视频号/朋友圈个性化推荐模型迭代与优化', '计算机/数学/统计相关专业硕士及以上\n3年以上推荐/排序模型经验，熟悉Wide&Deep/DIN/DCIN/Transformer等\n熟练Python/PyTorch，掌握A/B实验、指标分析\n有亿级DAU推荐系统实战经验优先\n强数学建模和数据敏感度，英语六级以上\n能独立负责模块，从召回到排序全链路', 30, 55, '深圳/北京', 1),
(20, 'SRE工程师 (社招)', 95, '微信/游戏后台稳定性保障与运维', '本科及以上，3年以上SRE/运维开发经验\n精通Kubernetes、Prometheus、ELK、混沌工程\n熟悉高可用架构、容量规划、故障演练\n有大型互联网系统SLO/SLI实践经验优先\n优秀的故障定位和应急响应能力\n愿意参与7x24 OnCall', 28, 50, '深圳', 1),
(20, '2026届游戏开发实习生', 52, '游戏前端/Unity实习', '计算机/游戏设计相关专业在读\n熟悉Unity/Unreal Engine基础\n有小游戏或互动项目经验加分\n创意能力强，团队协作好', 5, 10, '深圳', 1);

-- 21 字节跳动科技有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(21, '2026届多模态大模型实习生', 83, '参与抖音/剪映/飞书等多模态大模型的视频理解、生成、AIGC方向研发实习', '人工智能、计算机视觉、自然语言处理、数学等相关专业硕士/博士在读优先（2026届）\n熟练掌握PyTorch深度学习框架，熟悉Transformer、Diffusion、CLIP、LLaVA、Video-LLaMA等主流多模态/视频模型架构\n有图像/视频理解、生成、跨模态检索、视频字幕/问答等方向的项目经验或论文发表/开源贡献优先\n理解大模型完整训练流程，包括数据清洗、预训练、SFT、RLHF、DPO、对齐等关键阶段，能独立调试训练问题\n熟悉分布式训练框架（DeepSpeed、Megatron-LM、Colossal-AI、FSDP等）至少一种，有多卡/多节点训练经验加分\n具备较强的工程能力，能处理海量数据、优化训练效率、解决OOM/收敛问题\n数学基础扎实（线性代数、概率论、最优化），代码能力强，追求极致性能和代码可读性\n英语六级及以上，能跟踪阅读Arxiv最新多模态/视频大模型论文，快速复现SOTA方法\n实习期间需全职或每周5天以上到岗，能适应高强度研发节奏，抗压能力强，团队协作主动', 9, 16, '北京/上海', 1),
(21, 'Go后端高级开发工程师 (社招)', 71, '负责抖音/头条/电商等核心高并发服务的架构设计与开发', '本科及以上学历，计算机相关专业\n4年以上后端开发经验，精通Go语言及高性能编程（goroutine、channel、context、sync、unsafe等）\n熟悉微服务架构、RPC/gRPC、分布式一致性（etcd、ZooKeeper）、服务治理（熔断/限流/降级/负载均衡）\n有大规模分布式系统设计经验，日请求亿级以上优先\n熟练使用Kafka、Redis、TiDB/ClickHouse、Prometheus等基础设施\n代码洁癖强，追求极致性能和可维护性，熟悉单元测试、压测、混沌工程\n有开源贡献或大型互联网公司经验者优先\n英语良好，能阅读英文技术文档和参与跨团队沟通\n能适应快速迭代环境，责任心强，愿意参与OnCall值班', 30, 55, '上海/北京', 1),
(21, 'AI产品经理 (社招)', 99, 'AIGC产品规划与落地（剪映/豆包）', '本科及以上，3年以上产品经验，懂大模型优先\n熟悉用户增长、A/B测试、数据驱动决策\n有AI产品从0到1经验加分\n优秀的沟通协调和项目推进能力\n对短视频/内容生态有深刻理解\n英语良好，能与海外团队协作', 28, 50, '北京', 1),
(21, '2026届前端实习生 (React/Next.js)', 57, '抖音/今日头条前端实习', '计算机相关专业在读\n熟练React + TypeScript + Next.js\n有SSR/SSG项目经验加分\n性能优化意识强', 5, 12, '上海', 1);

-- 22 阿里巴巴集团
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(22, '2026届大模型应用实习生', 82, '基于通义千问大模型的ToB/ToC应用开发与优化实习', '计算机、人工智能相关专业本科/硕士在读\n熟练掌握Python及大模型应用开发框架（LangChain、LlamaIndex等）\n熟悉RAG、Agent、Function Calling、Tool Use等高级应用技术\n有构建过完整大模型应用（知识库问答、智能助手、企业Copilot等）经验优先\n了解大模型评估、Prompt Engineering、模型压缩/量化技巧加分\n具备较好的产品思维，能与业务/产品团队协作\n英语阅读能力强，能查阅英文技术资料和论文\n实习期间表现优秀可获得转正机会或校招优先', 8, 15, '杭州', 1),
(22, '高级前端开发工程师 (社招)', 58, '淘宝/天猫高性能前端开发与优化', '本科及以上，4年以上前端经验\n精通React/Next.js/Vue，SSR/SSG熟练\n掌握性能优化、Web Vitals、可访问性\n有大型电商/复杂交互项目经验\n代码规范强，工程化能力优秀\n能带新人或负责模块', 28, 50, '杭州/北京', 1),
(22, '供应链算法工程师 (社招)', 84, '菜鸟智能调度/预测/路由优化', '数学/计算机相关硕士及以上\n3年以上运筹优化/机器学习经验\n熟悉强化学习/时序预测/GNN\n有物流/供应链算法实战优先\n数据敏感，业务理解强', 25, 45, '杭州', 1),
(22, '2026届云原生实习生', 94, '阿里云容器平台实习', '计算机相关专业在读\n熟悉Kubernetes、Docker基础\n有云原生项目或开源贡献加分\n英语四级以上，学习能力强', 7, 14, '杭州', 1);

-- 23 宁德时代新能源科技股份有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(23, '2026届电池材料研发实习生', 36, '新型电池材料合成、表征与测试实习', '材料科学、化学、物理、能源与动力工程等相关专业本科/硕士在读\n熟悉电化学基本原理，了解电池材料合成、表征、测试方法（循环伏安、充放电测试、阻抗谱等）\n有参与过实验室电池材料相关实验或项目经验优先\n掌握常见材料表征仪器使用（XRD、SEM、XPS、BET、Raman、TEM等）加分\n具备较强的实验动手能力、数据分析与处理能力（Origin、Excel高级功能）\n安全意识强，遵守实验室规范与操作规程\n英语四级及以上，能独立阅读英文文献与技术报告\n实习期需穿戴防护装备，细心认真，责任心强，表现优异可转正', 5, 10, '宁德/上海', 1),
(23, '锂电池BMS算法工程师 (社招)', 36, '下一代BMS状态估计、均衡策略及热管理算法开发', '控制工程、电气工程、计算机相关硕士及以上\n3年以上电池管理系统算法开发经验，熟悉EKF/UKF/PF等状态估计算法\n熟练MATLAB/Simulink/Python，熟悉电池模型建立与参数辨识\n有新能源汽车BMS量产经验或实际车辆验证经验优先\n数学建模能力强，熟悉锂电池电化学特性与衰退机理\n具备优秀的团队协作与文档撰写能力，英语六级以上\n能适应实验室与现场测试环境，能处理复杂问题', 22, 40, '上海/宁德', 1),
(23, '2026届储能系统集成实习生', 36, '大型储能电站系统集成与测试实习', '电力电子、电气工程相关专业在读\n了解储能系统架构、BMS、PCS、EMS基本原理\n有电力电子或储能项目经验加分\n动手能力强，安全意识高', 5, 9, '宁德', 1);

-- 24 比亚迪股份有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(24, '2026届自动驾驶感知算法实习生', 85, '参与激光雷达/视觉/多传感器融合算法实习，可转正', '计算机、车辆工程、人工智能相关专业在读\n熟练掌握Python/PyTorch，熟悉YOLO系列、Transformer、Point Cloud处理（PointNet/PointPillars等）\n有计算机视觉或传感器融合课程项目/竞赛经验优先\n了解BEV感知或端到端自动驾驶框架（如UniAD、ST-P3）加分\n数据清洗、标注、模型训练调试能力强，英语四级以上\n实习期需保证较高出勤率，表现优秀优先校招', 6, 13, '深圳', 1),
(24, '新能源汽车三电系统工程师 (社招)', 31, '电池/电机/电控系统集成与验证', '车辆工程/电气工程相关本科及以上\n3年以上新能源汽车三电系统开发经验\n熟悉BMS、电机控制、DCDC/充电系统\n有整车集成或台架测试经验优先\n熟练使用CANoe/CANalyzer、MATLAB/Simulink\n责任心强，能适应出差和加班', 22, 42, '深圳/西安', 1),
(24, '2026届车载域控嵌入式实习生', 69, '智能驾驶域控制器底层软件开发实习', '嵌入式/计算机/电子相关专业在读\n熟练C/C++，熟悉RTOS/FreeRTOS/AUTOSAR\n了解汽车功能安全（ISO26262）加分\n有STM32/高通/地平线芯片开发经验优先\n代码规范好，调试问题能力强\n每周至少4天到岗', 5, 11, '西安', 1),
(24, '电池测试工程师 (社招)', 36, '动力电池性能测试与可靠性验证', '材料/化学/电气相关本科及以上\n2年以上电池测试经验，熟悉充放电循环、热失控测试\n熟练使用Arbin/Neware等测试设备\n有电池安全标准（GB/T、UN38.3）了解优先\n数据分析能力强，报告撰写规范', 20, 38, '深圳', 1);

-- 25 中芯国际集成电路制造（北京）有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(25, '2026届半导体工艺实习生', 32, '先进节点制程工艺开发与优化实习', '微电子/材料/物理相关专业在读\n了解半导体工艺流程（光刻、刻蚀、沉积、离子注入等）\n有洁净室实习或Fab相关课程经验优先\n熟悉工艺设备基本操作和故障排查\n安全意识强，细心耐心，英语四级以上\n需遵守严格洁净室规范，穿戴防护服', 5, 11, '上海/北京', 1),
(25, '芯片物理设计工程师 (社招)', 32, 'SoC后端物理设计（Floorplan/P&R/STA/DFM）', '微电子/集成电路相关本科及以上\n3年以上物理设计经验，熟练ICC2/Innovus/PrimeTime\n熟悉7nm/5nm及以下节点物理实现流程\n有低功耗/高性能设计或Tapeout经验优先\n时序收敛能力强，能独立解决复杂问题\n抗压能力好，能适应高峰期加班', 25, 48, '上海/北京', 1),
(25, '2026届芯片验证实习生', 32, '数字IC功能验证与仿真实习', '集成电路/电子工程相关专业在读\n熟悉SystemVerilog/UVM验证方法学\n有Verilog/VHDL RTL设计或验证项目经验优先\n了解SoC验证流程、覆盖率分析\n代码能力强，调试耐心，英语阅读良好', 5, 12, '北京', 1),
(25, '工艺设备工程师 (社招)', 32, '光刻/刻蚀设备维护与工艺优化', '电子/自动化/物理相关本科及以上\n3年以上半导体设备维护经验\n熟悉ASML光刻机或Lam刻蚀设备优先\n具备设备故障诊断与预防性维护能力\n团队协作好，能值班支持生产', 22, 45, '上海', 1);

-- 26 国家电网有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(26, '2026届智能电网算法实习生', 12, '新能源接入/负荷预测/优化调度算法实习', '电力系统/自动化/计算机相关专业在读\n熟悉电力系统基本原理和仿真工具（MATLAB/PSCAD）\n了解机器学习在负荷预测中的应用加分\n有电网调度或新能源项目经验优先\n数据处理能力强，英语四级以上\n实习需遵守保密要求', 5, 10, '北京', 1),
(26, '新能源数字孪生工程师 (社招)', 43, '风光储一体化场站数字孪生建模与应用', '电力/控制/计算机相关本科及以上\n3年以上数字孪生或仿真建模经验\n熟练Unity/Unreal Engine或专业电力仿真软件\n有新能源场站数据采集/建模经验优先\n系统架构思维强，跨团队沟通能力好', 20, 38, '北京/上海', 1),
(26, '2026届电力大数据实习生', 12, '电网大数据平台分析与可视化实习', '计算机/统计/电力相关专业在读\n熟练Python/SQL，熟悉Hadoop/Spark基础\n有电力数据分析或可视化项目经验加分\n数据敏感度高，报告撰写能力强', 5, 10, '北京', 1);

-- 27 中国工商银行股份有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(27, '2026届金融科技开发实习生', 69, '银行核心系统/移动银行/支付系统开发实习', '计算机/金融科技/软件工程相关专业在读\n熟练Java/Python，熟悉Spring Boot或Django框架\n了解金融业务场景（支付、清结算、信贷）加分\n有银行/互联网金融项目经验优先\n安全意识强，代码规范好，英语四级以上', 5, 10, '北京', 1),
(27, '大数据开发工程师 (社招)', 12, '金融大数据平台建设、ETL与分析', '计算机/统计相关本科及以上\n3年以上大数据开发经验，精通Spark/Flink/Hadoop\n熟悉银行数据仓库模型和风控/反欺诈场景优先\nSQL/Hive熟练，数据质量意识强\n能独立负责数据链路优化', 22, 40, '北京', 1),
(27, '2026届前端开发实习生 (React)', 57, '网银/手机银行前端界面开发实习', '计算机相关专业在读\n熟练React + TypeScript，熟悉Ant Design或类似UI库\n有移动端H5或小程序开发经验加分\n交互设计敏感度高，性能优化意识强', 5, 11, '北京', 1);

-- 28 中国石油天然气集团有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(28, '2026届能源数字化实习生', 43, '油气勘探/生产数字化转型项目实习', '石油工程/计算机/自动化相关专业在读\n了解油气行业基本知识，熟悉Python数据处理\n有能源大数据或AI应用项目经验加分\n学习意愿强，英语四级以上\n能适应出差或现场环境', 5, 9, '北京', 1),
(28, '海外项目IT工程师 (社招)', 68, '海外油气项目信息化系统建设与维护', '计算机/通信相关本科及以上\n3年以上IT系统实施或运维经验\n熟悉海外项目环境，能适应出国工作\n有油气行业信息化经验优先\n英语流利（口语+技术文档）', 20, 38, '北京/海外', 1);

-- 29 小米科技有限责任公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(29, '2026届AIoT算法实习生', 84, '智能家居/穿戴设备推荐与预测算法实习', '计算机/AI相关专业在读\n熟练Python，熟悉推荐系统或时序预测模型\n有IoT设备数据项目经验加分\n数据分析能力强，英语四级以上', 6, 13, '北京', 1),
(29, '消费电子嵌入式工程师 (社招)', 33, '手机/平板/智能硬件底层软件开发', '电子/计算机相关本科及以上\n3年以上嵌入式开发经验，精通C/C++/RTOS\n熟悉高通/联发科平台优先\n有量产经验，熟悉硬件调试工具\n代码质量高，抗压能力强', 22, 42, '北京', 1),
(29, '2026届前端开发实习生 (React Native)', 59, '小米APP/跨境电商移动端开发实习', '计算机相关专业在读\n熟练React Native，了解iOS/Android原生交互\n有App开发或跨平台项目经验优先\nUI还原能力强，性能优化意识好', 5, 12, '北京', 1);

-- 30 大疆创新科技有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(30, '2026届计算机视觉算法实习生', 85, '无人机影像识别/避障/跟踪算法实习', '计算机视觉/AI相关专业在读\n熟练OpenCV/PyTorch，熟悉目标检测/跟踪算法\n有无人机或机器人视觉项目经验优先\n数学基础扎实，英语六级以上', 7, 14, '深圳', 1),
(30, '无人机嵌入式软件工程师 (社招)', 69, '飞行控制与图像传输底层开发', '嵌入式/计算机相关本科及以上\n3年以上嵌入式Linux或RTOS开发经验\n熟悉ARM架构，了解无人机飞控原理加分\n有产品量产经验优先\n调试能力强，能适应高压项目节奏', 25, 45, '深圳', 1),
(30, '2026届产品实习生 (无人机方向)', 96, '消费级/行业级无人机产品规划实习', '工业设计/电子/市场相关专业在读\n对无人机生态有兴趣，了解用户需求\n有产品实习或竞品分析经验加分\n沟通表达能力好，英语良好', 5, 11, '深圳', 1);

-- 31 百度集团
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(31, '2026届大模型应用实习生', 82, '参与文心一言大模型的ToC/ToB应用开发、Agent/RAG优化实习，可转正通道', '人工智能、计算机科学相关专业本科/硕士在读（2026届优先）\n熟练掌握Python及大模型应用生态（LangChain、LlamaIndex、Haystack等），熟悉Prompt Engineering、Chain of Thought、ReAct等高级技巧\n有构建过完整大模型应用项目经验（如智能助手、知识库问答、企业Copilot、垂直领域Agent）或开源贡献优先\n理解大模型评估体系（BLEU/ROUGE/BERTScore/Human Eval等），熟悉模型压缩、量化、蒸馏、LoRA/PEFT等高效微调方法至少一种\n熟悉大模型部署框架（vLLM、TGI、FastChat、TensorRT-LLM）基础，能处理推理加速、batch处理、KV Cache优化等常见问题\n具备较强的工程能力，能独立调试训练/推理问题，熟悉分布式训练调试（DeepSpeed/FSDP）加分\n数学基础扎实（线性代数、概率统计、最优化），代码能力强，追求稳定性与效率\n英语六级及以上，能跟踪阅读Arxiv最新LLM应用论文，快速复现社区SOTA方法\n实习期间需每周5天以上到岗，能适应高强度研发节奏，责任心强、团队协作主动、乐于分享', 8, 15, '北京', 1),
(31, '自动驾驶感知工程师 (社招)', 85, 'Apollo平台多传感器融合、BEV感知模型迭代与量产落地', '计算机视觉、人工智能、车辆工程相关硕士及以上学历\n3–8年自动驾驶感知算法开发经验，精通PyTorch/TensorFlow，熟悉YOLOv8/DETR/Transformer-based检测、BEVFormer/TPVFormer等主流感知架构\n有激光雷达、摄像头、毫米波雷达等多传感器融合经验，熟悉点云处理（PointPillars、VoxelNet、CenterPoint等）\n有端到端感知或多模态融合项目量产经验优先（如城市/高速NOA场景）\n熟练使用Apollo/nuScenes/OpenDataLab等数据集，掌握数据清洗、标注、增强、模型评估全链路\n代码工程能力强，熟悉模型压缩/量化/部署（TensorRT/ONNX），能独立解决复杂场景召回/漏检问题\n数学建模能力扎实，熟悉概率滤波、卡尔曼、匈牙利匹配等\n英语六级以上，能阅读英文论文和技术文档，具备较强的抗压能力和团队协作精神\n能适应高强度项目节奏，愿意参与路测、夜间/恶劣天气验证及OnCall支持', 30, 55, '北京', 1),
(31, '2026届前端开发实习生 (React)', 57, '百度APP/搜索/文心一言前端界面开发实习', '计算机/软件工程相关专业在读\n熟练React + TypeScript + Zustand/Redux Toolkit，熟悉Hooks、Suspense、Concurrent Mode等高级特性\n有Next.js/Remix经验，了解SSR/SSG/Streaming Rendering加分\n熟悉前端工程化（Vite/Webpack、ESLint、Prettier、Tailwind CSS、Storybook等），能独立处理性能瓶颈\n有大型Web/App项目经验（如搜索结果页、聊天界面、内容推荐页）优先\n性能优化意识强，熟悉Web Vitals、Lighthouse、虚拟列表、懒加载、骨架屏等技术\n英语四级以上，能阅读React官方文档及社区讨论\n每周至少4天到岗，实习期能适应快速迭代与代码审查环境', 5, 12, '北京', 1);

-- 32 商汤科技
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(32, '2026届计算机视觉实习生', 85, 'SenseCore平台CV模型（检测/分割/姿态/3D重建）研发实习', '计算机视觉、人工智能相关专业硕士/本科高年级在读\n熟练PyTorch，熟悉主流检测（YOLOv8/RT-DETR）、分割（SAM/Mask2Former）、姿态（RTMPose/HRNet）、3D重建（NeRF/3DGS）等模型\n有CV方向项目经验（如Kaggle竞赛、开源仓库、论文复现、学校实验）优先\n理解模型训练全流程（数据增强、损失函数、优化器、调度器、混合精度等），能独立调试收敛问题\n熟悉模型压缩/量化（INT8/FP16）、加速（TensorRT/NCNN/OpenVINO）基础加分\n数学基础扎实（线性代数、概率论、几何变换），代码能力强，追求精度与效率平衡\n英语六级及以上，能阅读CVPR/ICCV/ECCV最新论文，快速跟进社区进展\n实习需每周5天以上到岗，能适应高强度实验迭代，责任心强、团队协作好', 7, 14, '上海', 1),
(32, '多模态大模型工程师 (社招)', 83, '视觉+语言多模态模型训练、对齐与应用开发', '计算机视觉/自然语言处理相关硕士及以上\n3–7年多模态模型经验，熟悉CLIP、BLIP、LLaVA、Kosmos、Qwen-VL、InternVL等系列\n有图像/视频理解、生成、跨模态检索、视觉问答、文档理解等方向量产或研究经验优先\n熟练PyTorch分布式训练（DeepSpeed、FSDP、Megatron），熟悉长序列处理、位置编码优化\n有RLHF/DPO对齐、Prompt Tuning、Adapter/LoRA等高效微调经验加分\n具备优秀的工程能力，能处理海量多模态数据清洗、训练稳定性、推理加速等问题\n数学与算法功底扎实，能独立设计实验验证新方法\n英语六级以上，能跟踪多模态领域最新进展，具备较强的抗压与协作能力', 30, 55, '上海/北京', 1),
(32, '2026届测试开发实习生', 88, 'AI模型/平台自动化测试框架搭建与执行实习', '计算机/软件测试相关专业在读\n熟练Python + Pytest/Unittest，熟悉自动化测试设计原则\n有AI模型测试、接口测试、性能测试经验加分\n了解大模型评测指标（BLEU/ROUGE/Human Eval/Perplexity）优先\n能编写稳定、可复用的测试用例与脚本，熟悉CI/CD集成\n责任心强，细致耐心，英语四级以上', 5, 11, '上海', 1);

-- 33 中国石油天然气股份有限公司（中石油）
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(33, '2026届能源大数据实习生', 12, '油气勘探生产大数据分析与可视化实习', '石油工程/计算机/统计相关专业在读\n熟练Python/SQL，熟悉Pandas/Numpy/Matplotlib/Seaborn/Echarts\n了解油气行业数据类型（地震、测井、生产曲线）加分\n有大数据项目或能源数据分析经验优先\n数据敏感度高，报告撰写规范\n英语四级以上，能阅读英文技术报告', 5, 10, '北京', 1),
(33, '数字化转型工程师 (社招)', 43, '海外油气项目数字化系统建设与运维', '计算机/石油工程/自动化相关本科及以上\n3年以上数字化转型或信息化项目经验\n熟悉云平台（阿里云/华为云/AWS）、大数据（Hadoop/Spark）、IoT平台\n有油气行业SCADA/ERP/MES系统实施经验优先\n能适应海外出差与现场支持，英语流利（口语+技术文档）\n项目管理能力强，责任心强，能处理跨部门协调', 20, 38, '北京/海外', 1),
(33, '2026届后端开发实习生', 69, '能源管理系统后端服务开发实习', '计算机相关专业在读\n熟练Java/Go，熟悉Spring Boot或Gin框架\n了解分布式系统、微服务基础加分\n有能源/工业互联网项目经验优先\n代码规范好，学习能力强', 5, 11, '北京', 1);

-- 34 中国石油化工股份有限公司（中石化）
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(34, '2026届化工材料实习生', 36, '新能源材料/催化剂/聚合物工艺研发实习', '化学工程/材料科学/高分子相关专业在读\n熟悉催化反应、聚合反应、材料合成基本原理\n有实验室合成/表征实验经验优先\n掌握XRD/FTIR/SEM/TGA/DSC等仪器操作加分\n实验记录规范，安全意识强\n英语四级以上，能阅读化工文献', 5, 10, '北京', 1),
(34, '炼化数字化工程师 (社招)', 43, '智能炼厂数字孪生、预测维护与优化系统开发', '化工/计算机/自动化相关本科及以上\n3年以上工业数字化或智能制造经验\n熟悉工业互联网平台、数字孪生（Unity/仿真软件）、AI预测模型\n有炼化/石化MES/SCADA系统经验优先\n系统思维强，能跨专业协作，英语良好\n能适应现场出差与调试', 20, 38, '北京/上海', 1),
(34, '2026届数据分析实习生', 12, '化工生产数据清洗、可视化与异常检测实习', '统计/计算机相关专业在读\n熟练Python（Pandas/NumPy/Plotly）、SQL\n有工业数据分析或异常检测项目经验加分\n数据敏感度高，报告呈现能力强', 5, 9, '北京', 1);

-- 35 中信银行股份有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(35, '2026届金融科技开发实习生', 69, '跨境支付、科技金融、零售银行系统开发实习', '计算机/金融科技/软件工程相关专业在读\n熟练Java/Python，熟悉Spring Boot/Django/FastAPI\n了解金融业务场景（支付、信贷、风控、反洗钱）加分\n有银行/支付/互联网金融项目经验优先\n安全意识强，代码规范好，英语四级以上\n每周至少4天到岗，实习表现优异可转正', 5, 10, '北京', 1),
(35, '风控模型工程师 (社招)', 84, '消费金融/信用卡/小微贷款风控模型开发与迭代', '统计学/数学/计算机相关硕士及以上\n3年以上风控模型开发经验，熟练XGBoost/LightGBM/CatBoost/深度学习风控模型\n熟悉A/B实验、KS/PSI/AUC/KS等评估指标，了解变量筛选、WOE/IV、评分卡开发全流程\n有银行/消费金融/互联网信贷风控实战经验优先\n数据敏感度高，业务理解强，能与风控/业务团队高效协作\n英语六级以上，能阅读英文风控论文与报告\n责任心强，能适应模型上线后监控与迭代需求', 22, 40, '北京', 1),
(35, '2026届前端实习生', 57, '手机银行/网银/企业金融前端开发实习', '计算机相关专业在读\n熟练React/Vue + TypeScript，熟悉Ant Design或Element Plus\n有移动端H5或小程序开发经验加分\n交互设计敏感度高，性能优化意识强', 5, 11, '北京', 1);

-- 36 中国国际金融股份有限公司（中金公司）
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(36, '2026届量化研究实习生', 84, '跨境并购、股权融资、衍生品量化模型与策略研究实习', '金融工程/数学/计算机相关硕士在读优先\n熟练Python/R/Matlab，熟悉量化交易框架（Backtrader/QuantConnect/Zipline）\n了解股票/债券/衍生品定价模型、统计套利、多因子模型、机器学习在量化中的应用\n有量化策略回测、实盘模拟或竞赛经验优先\n数学功底扎实（随机过程、时间序列、凸优化），代码能力强\n英语六级以上，能阅读量化金融论文与英文报告\n实习需每周5天到岗，能适应高强度研究节奏', 7, 14, '北京', 1),
(36, '投行系统工程师 (社招)', 68, '投行核心交易系统、CRM、路演系统开发与维护', '计算机相关本科及以上\n3年以上金融系统开发经验，精通Java/Go/Python\n熟悉分布式系统、高并发交易处理、数据安全合规\n有投行/券商系统实施经验优先\n项目管理能力强，能适应高峰期加班\n英语流利，能与海外客户/团队沟通', 25, 45, '北京', 1);

-- 37 普华永道（PwC）中国
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(37, '2026届审计科技实习生', 15, '数字化审计/税务合规/风险管理系统开发实习', '会计/审计/计算机/信息系统相关专业在读\n熟练Python/SQL，熟悉Power BI/Tableau数据可视化\n了解财务报表、内部控制、税务合规基本知识加分\n有审计软件或ERP系统实习经验优先\n细心严谨，数据分析能力强，英语四级以上\n每周至少4天到岗，实习表现优异可转正', 5, 10, '上海', 1),
(37, '数字化转型顾问 (社招)', 98, '企业数字化转型、云ERP、RPA、智能财务咨询与实施', '本科及以上，3年以上咨询/数字化转型经验\n熟悉SAP S/4HANA、Oracle Cloud、阿里云/腾讯云企业服务\n有财务共享中心、智能财务、RPA实施经验优先\n项目管理能力强（PMP或同等证书加分），英文流利\n优秀的沟通协调与文档撰写能力，能适应出差', 25, 45, '上海', 1);

-- 38 长江存储科技有限责任公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(38, '2026届存储芯片工艺实习生', 32, '3D NAND闪存制程工艺开发与优化实习', '微电子/材料科学/物理相关专业在读\n了解NAND闪存工艺流程（沉积、刻蚀、光刻、离子注入、清洗等）\n有半导体实验室或Fab实习经验优先\n熟悉洁净室操作规范、安全要求与工艺设备基本原理\n数据分析能力强，能使用JMP/Origin处理工艺数据\n英语四级以上，能阅读英文工艺文献\n需遵守严格洁净室纪律，穿戴全套防护服', 5, 11, '武汉', 1),
(38, '芯片设计工程师 (社招)', 32, '存储控制器/IP/接口设计与验证', '集成电路/微电子相关本科及以上\n3年以上数字IC设计经验，熟练Verilog/SystemVerilog\n熟悉UVM验证方法学、覆盖率分析、形式验证\n有DDR/LPDDR/NAND接口或控制器设计经验优先\n时序/功耗优化能力强，能独立完成RTL到GDS全流程\n抗压能力好，能适应Tapeout高压期', 25, 48, '武汉', 1),
(38, '2026届测试工程师实习生', 90, '存储芯片性能/可靠性测试实习', '电子/计算机相关专业在读\n熟悉ATE测试平台、ATE编程（Teradyne/Cohu等）\n有半导体测试或可靠性测试经验加分\n细心耐心，数据分析能力强', 5, 10, '武汉', 1);

-- 39 华为海思半导体有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(39, '2026届AI芯片设计实习生', 32, '昇腾/麒麟AI加速器架构与RTL设计实习', '微电子/集成电路/计算机相关专业在读\n熟悉Verilog/SystemVerilog，了解数字电路/计算机体系结构\n有NPU/GPU/Tensor Core相关课程项目或竞赛经验优先\n熟悉高性能计算、并行计算、数据流架构加分\n代码能力强，数学基础好（线性代数、概率论）\n英语六级以上，能阅读芯片设计英文文档与论文', 6, 13, '深圳', 1),
(39, '芯片架构师 (社招)', 32, 'AI芯片/SoC架构设计与性能建模', '微电子/计算机体系结构相关硕士及以上\n5年以上芯片架构经验，熟悉NPU/GPU/TPU设计\n熟练C++建模、SystemC、Gem5/Sniper模拟器\n有流片经验或高性能AI芯片项目优先\n系统思维强，能跨团队协作，英语良好', 35, 60, '深圳', 1),
(39, '2026届后端开发实习生', 69, '芯片设计EDA工具链后端服务开发实习', '计算机相关专业在读\n熟练Java/Go/Python，熟悉Spring Boot或FastAPI\n了解EDA工具链或芯片设计流程加分\n分布式系统基础好，学习能力强', 5, 12, '深圳', 1);

-- 40 隆基绿能科技股份有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(40, '2026届光伏材料实习生', 35, '硅片/电池/组件材料研发与工艺优化实习', '材料科学/化学/物理/能源相关专业在读\n熟悉光伏材料（单晶硅、多晶硅、钙钛矿、TOPCon/HJT）基本原理与表征方法\n有实验室光伏材料合成/测试经验优先\n掌握XRD/SEM/PL/EQE/LIF等仪器操作加分\n实验动手能力强，数据分析规范\n英语四级以上，能阅读光伏领域英文文献\n安全意识强，遵守实验室规范', 5, 10, '西安', 1),
(40, '光伏设备工程师 (社招)', 35, '光伏生产线设备维护、改造与工艺优化', '机械工程/自动化/电子相关本科及以上\n3年以上光伏/半导体设备维护经验\n熟悉PECVD、扩散炉、丝印机、激光设备等优先\n具备设备故障诊断、预防性维护、备件管理能力\n项目执行力强，能适应生产线轮班与出差', 20, 38, '西安', 1),
(40, '2026届工艺工程师实习生', 35, '硅片切割/电池制备工艺实习', '材料/化学工程相关在读\n了解光伏工艺流程（铸锭、切片、扩散、PECVD、金属化等）\n有工艺实验或数据分析经验加分\n细心负责，学习意愿强', 5, 9, '西安', 1);

-- 41 理想汽车科技有限公司
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(41, '2026届端到端自动驾驶实习生', 85, '城市NOA端到端规划/控制/预测算法实习', '人工智能/车辆工程/计算机相关专业在读\n熟悉模仿学习、强化学习、Diffusion/Transformer-based规划模型\n有轨迹预测/规划/控制项目经验或竞赛优先\n熟练PyTorch，了解nuScenes/Argoverse/OpenDrive等数据集\n数学基础扎实（控制论、最优化、概率论）\n英语六级以上，能阅读端到端自动驾驶论文\n实习需每周5天到岗，能适应高强度研发', 7, 14, '北京', 1),
(41, '智能驾驶感知工程师 (社招)', 85, 'BEV/多模态感知模型量产与优化', '计算机视觉/AI相关硕士及以上\n3年以上自动驾驶感知经验，精通PyTorch\n熟悉BEVFormer/TPV/UniAD等端到端感知架构\n有量产经验（城市/高速NOA）优先\n性能优化与部署能力强（TensorRT/ONNX）\n抗压能力强，能参与路测验证', 30, 55, '北京', 1),
(41, '2026届三电系统实习生', 31, '电池/电机/电控集成测试实习', '电气/车辆工程相关专业在读\n熟悉MATLAB/Simulink，了解BMS/电机控制原理\n有新能源汽车三电项目经验加分\n动手能力强，安全意识高', 5, 11, '北京', 1);

-- 42 京东集团
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(42, '2026届供应链算法实习生', 84, '智能仓储/路由/预测/库存优化算法实习', '运筹优化/计算机/工业工程相关专业在读\n熟悉强化学习、时序预测、运筹优化（MILP/CPLEX/Gurobi）\n有物流/供应链项目或竞赛经验加分\nPython熟练，数据分析能力强\n英语四级以上，学习能力强', 6, 13, '北京', 1),
(42, '后端开发工程师 (社招)', 69, '电商核心交易/订单/支付系统开发', '本科及以上，4年以上后端经验，精通Java/Go\n熟悉高并发分布式系统设计\n有亿级交易系统经验优先\n代码规范强，抗压能力好', 25, 45, '北京', 1),
(42, '2026届前端实习生', 58, '京东APP/网页/小程序前端实习', '计算机相关专业在读\n熟练React/Next.js或Vue/Nuxt\n有电商前端经验加分\n性能优化意识强', 5, 12, '北京', 1);

-- 43 网易集团
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(43, '2026届游戏前端实习生', 52, '网易游戏Web/移动端/H5前端开发实习', '计算机/游戏设计相关专业在读\n熟练React/Three.js或Cocos Creator\n有游戏前端或互动H5项目经验优先\n创意能力强，审美好', 5, 12, '杭州', 1),
(43, '游戏服务器开发工程师 (社招)', 71, '高并发MMO/手游服务器开发与优化', '本科及以上，4年以上游戏后端经验，精通C++/Go\n熟悉Netty/gRPC/Kafka等高性能框架\n有大型游戏服务器经验优先\n代码能力强，抗压能力好', 25, 48, '杭州', 1),
(43, '2026届推荐算法实习生', 84, '游戏内容/玩家推荐系统实习', 'AI/计算机相关专业在读\n熟悉推荐系统召回/排序模型\n有游戏数据项目经验加分', 7, 14, '杭州', 1);

-- 44 美团
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(44, '2026届增长产品实习生', 97, '外卖/到店/酒旅业务用户增长与留存策略实习', '计算机/市场/运营相关专业在读\n熟悉数据分析工具（SQL/Python/Excel/Tableau）\n有增长项目或A/B实验经验加分\n业务敏感度高，逻辑清晰\n英语四级以上，沟通能力强', 5, 11, '北京', 1),
(44, '推荐算法工程师 (社招)', 84, '本地生活推荐模型迭代与优化', '计算机/数学相关硕士及以上\n3年以上推荐系统经验，熟悉召回/排序/重排全链路\n有亿级流量推荐实战优先\nPython/PyTorch熟练，业务理解强', 28, 50, '北京', 1),
(44, '2026届前端实习生 (Vue)', 63, '美团APP/小程序/到店业务前端实习', '计算机相关专业在读\n熟练Vue3 + Composition API + Pinia/Vuex\n有小程序或H5经验加分\n性能优化意识强', 5, 12, '北京', 1);

-- 45 快手科技
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(45, '2026届多模态实习生', 83, '短视频/直播内容理解与生成实习', 'AI/CV/NLP相关专业在读\n熟悉视频多模态模型（VideoMAE/CLIP-ViT等）\n有短视频相关项目优先\nPyTorch基础好，英语六级以上', 8, 15, '北京', 1),
(45, '直播推荐工程师 (社招)', 84, '直播间实时推荐与内容分发优化', '3年以上推荐/搜索经验\n熟悉实时推荐、冷启动、多目标优化\n有直播/短视频平台经验优先\n数学建模能力强，抗压能力好', 30, 55, '北京', 1),
(45, '2026届后端实习生', 71, '高并发直播服务开发实习', '计算机相关专业在读\n熟练Go语言，高并发编程基础\n熟悉微服务/Kafka/Redis加分\n学习能力强', 5, 12, '北京', 1);

-- 46 哔哩哔哩（B站）
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(46, '2026届内容社区产品实习生', 97, 'UP主生态/用户增长/社区运营策略实习，可转正通道', '产品/运营/市场/计算机相关专业本科/硕士在读（2026届优先）\n熟悉社区产品逻辑，了解内容创作者（UP主）与消费者双边增长模型\n熟练使用数据分析工具（SQL、Python/Pandas、Excel、Tableau/Looker）进行用户行为分析、漏斗拆解、留存/活跃指标监控\n有社区/内容平台产品实习经验或参与过校园社团/兴趣社区运营项目优先\n对ACG、知识区、生活区等B站核心内容生态有较深理解，能独立提出增长策略与实验方案\n具备优秀的产品文档撰写能力（PRD/MRD/需求文档）、原型设计能力（Axure/Figma/Mockplus）\n英语四级及以上，能阅读英文社区产品案例与增长论文\n逻辑清晰、沟通表达强，能与运营/内容/算法团队高效协作\n每周至少到岗4天以上，实习期3–6个月，能适应快节奏迭代与数据驱动决策环境，责任心强、主动性高', 5, 11, '上海', 1),
(46, '视频推荐工程师 (社招)', 84, '动画/知识/生活区推荐模型迭代与优化', '计算机/数学/统计相关硕士及以上\n3–7年推荐系统经验，精通召回（双塔/多路召回）、排序（DeepFM/DIN/DCIN/Transformer-based）、重排（MMoE/Multi-Task Learning）\n熟悉内容理解模型（文本/视频多模态预训练，如CLIP、VideoMAE）在推荐中的应用\n有亿级DAU内容平台推荐实战经验优先（短视频/长视频/直播均可），熟悉冷启动、多目标优化、探索-利用平衡\n熟练Python/PyTorch/TensorFlow，掌握A/B实验设计、离线/在线评估指标体系、因果推断基础\n具备较强的业务理解与数据敏感度，能独立从业务问题提炼算法方案并推动落地\n英语六级及以上，能阅读推荐系统领域最新论文（RecSys/KDD/WSDM）\n抗压能力强，能适应高强度上线迭代与线上问题排查，团队协作主动', 25, 45, '上海', 1),
(46, '2026届前端实习生', 57, 'B站Web/移动端/弹幕互动前端开发实习', '计算机/软件工程相关专业在读\n熟练React + TypeScript，熟悉Hooks、Context、Suspense、Concurrent Mode等高级特性\n有Next.js/Remix经验，了解SSR/SSG/Streaming SSR加分\n熟悉前端工程化（Vite/Webpack、ESLint/Prettier、Tailwind CSS、Storybook等），能独立处理构建/性能问题\n有视频播放器、弹幕系统、互动组件开发经验优先\n性能优化意识强，熟悉Web Vitals、虚拟列表、懒加载、骨架屏、WebSocket长连接等技术\n英语四级以上，能阅读React/Vue官方文档及社区讨论\n每周至少4天到岗，实习期能适应快速迭代与代码审查环境', 5, 12, '上海', 1);

-- 47 SHEIN
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(47, '2026届供应链算法实习生', 84, '跨境电商供应链预测/库存/路由优化算法实习', '运筹优化/计算机/工业工程/物流相关专业在读\n熟练Python，熟悉时序预测（Prophet/DeepAR/TFT）、运筹优化（MILP/Gurobi/CPLEX/OR-Tools）、强化学习在供应链中的应用\n有电商/物流供应链项目或竞赛经验（如Kaggle供应链预测赛）优先\n了解快时尚/跨境电商业务场景（需求预测、多仓调拨、海外物流）加分\n数据处理与特征工程能力强，熟悉Pandas/NumPy/Spark\n英语六级及以上，能阅读供应链优化领域英文论文与报告\n实习需每周5天到岗，能适应高强度数据实验与业务迭代节奏，责任心强', 6, 13, '南京', 1),
(47, '海外业务后端工程师 (社招)', 71, '全球订单/库存/支付/物流核心系统开发与优化', '本科及以上，4年以上后端开发经验，精通Go/Java/Python\n熟悉高并发分布式系统设计、微服务架构、RPC/gRPC、分布式事务\n有跨境电商/海外订单系统经验优先（多币种、多语言、多时区、海外支付/税务合规）\n熟练Kafka/RocketMQ、Redis、MySQL/TiDB、Elasticsearch等基础设施\n代码质量高，熟悉单元测试、压测、混沌工程、监控告警体系\n英语流利，能与海外团队/供应商沟通技术需求\n抗压能力强，能适应跨境业务高峰期（如黑五/圣诞）加班与紧急响应', 25, 45, '南京', 1),
(47, '2026届前端实习生', 58, 'SHEIN全球APP/网页前端开发实习', '计算机相关专业在读\n熟练React/Next.js或Vue/Nuxt，熟悉SSR/SSG/国际化（i18n）\n有跨境电商或多语言前端经验加分\n性能优化意识强，熟悉Web Vitals、懒加载、图片压缩等', 5, 12, '南京', 1);

-- 48 唯品会
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(48, '2026届特卖推荐实习生', 84, '品牌折扣/闪购推荐模型开发实习', '计算机/数学相关专业在读\n熟悉推荐系统召回/排序模型（双塔/DeepFM/DIN）\n有电商推荐项目或竞赛经验加分\nPython/PyTorch基础好，数据分析能力强\n英语四级以上', 6, 13, '广州', 1),
(48, '大数据工程师 (社招)', 12, '电商大数据平台建设、实时ETL与分析', '本科及以上，3年以上大数据开发经验\n精通Spark/Flink/Hadoop/Hive/ClickHouse\n熟悉电商数据仓库分层模型、实时数仓建设\n有特卖/折扣电商数据处理经验优先\nSQL能力强，数据质量意识高，能独立负责链路优化', 22, 40, '广州', 1),
(48, '2026届前端实习生', 57, '唯品会APP/网页前端开发实习', '计算机相关专业在读\n熟练React/Vue + TypeScript\n有电商前端经验加分\n性能与交互优化意识强', 5, 11, '广州', 1);

-- 49 小红书
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(49, '2026届社区增长实习生', 97, '种草社区用户增长、留存、内容分发策略实习', '产品/运营/市场/计算机相关专业在读\n熟练SQL/Python数据分析，熟悉增长漏斗、A/B实验设计\n对生活方式/种草社区有深刻理解，能独立提出增长方案\n有社区运营/内容增长实习经验或校园社群项目优先\n优秀的文档撰写与沟通表达能力，逻辑清晰\n英语四级以上，能阅读英文增长案例与论文\n每周至少4天到岗，实习期能适应数据驱动快节奏环境', 5, 11, '上海', 1),
(49, '推荐算法工程师 (社招)', 84, '生活方式/种草笔记推荐模型迭代与优化', '计算机/数学相关硕士及以上\n3年以上推荐系统经验，熟悉内容理解（文本/图像多模态）、召回/排序/重排全链路\n有社区/内容平台推荐实战经验优先（冷启动、多目标优化、探索利用）\n熟练Python/PyTorch/TensorFlow，掌握A/B实验、因果推断基础\n业务敏感度高，能从用户笔记/收藏/点赞行为提炼特征\n英语六级及以上，能阅读推荐与多模态领域最新论文\n抗压能力强，能适应高频上线与线上问题排查', 28, 50, '上海', 1),
(49, '2026届前端实习生 (React)', 57, '小红书Web/小程序/笔记编辑器前端开发实习', '计算机相关专业在读\n熟练React + TypeScript + Zustand/Recoil，熟悉Hooks、Suspense\n有Next.js经验，了解SSR/SSG加分\n熟悉富文本编辑器（Draft.js/Slate/TipTap）或笔记类交互组件优先\n性能优化意识强，熟悉虚拟列表、懒加载、图片压缩\n英语四级以上，能阅读React社区文档\n每周至少4天到岗，实习期适应快速迭代', 5, 12, '上海', 1),
(49, '内容审核算法工程师 (社招)', 86, '社区笔记/评论内容安全模型开发与优化', 'NLP/CV相关硕士及以上\n3年以上内容审核/风控模型经验，熟悉文本分类/多模态审核（图像+文本）\n熟练BERT/RoBERTa/ERNIE/CLIP等预训练模型微调\n有社区/社交平台审核实战经验优先\n熟悉在线/离线审核链路、误判分析、人工审核协作\n英语六级以上，能阅读内容安全领域论文', 25, 45, '上海', 1);

-- 50 OPPO
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(50, '2026届影像算法实习生', 85, '手机相机AI算法（美颜/夜景/人像分割）研发实习', '计算机视觉/人工智能相关专业在读\n熟练OpenCV/PyTorch，熟悉图像增强、超分、去噪、RAW域处理\n有手机摄影/计算摄影项目或竞赛经验优先\n熟悉移动端部署（NCNN/TNN/MNN）加分\n数学基础扎实，代码能力强\n英语六级以上，能阅读CV领域论文', 7, 14, '东莞', 1),
(50, '移动端开发工程师 (社招)', 59, 'ColorOS系统/相机APP底层与AI功能开发', '计算机/电子相关本科及以上\n3年以上Android系统/APP开发经验，熟悉AOSP/Framework层\n有影像算法集成或相机HAL层经验优先\n熟悉JNI/Native开发、性能优化\n抗压能力强，能适应手机项目节奏', 22, 42, '东莞', 1),
(50, '2026届嵌入式实习生', 69, '手机SoC底层驱动开发实习', '嵌入式/电子相关专业在读\n熟练C/C++，熟悉Linux内核驱动\n有高通/联发科平台经验加分\n调试能力强', 5, 11, '东莞', 1);

-- 51 vivo
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(51, '2026届相机算法实习生', 85, '手机影像AI算法（人像/夜景/视频防抖）研发实习', '计算机视觉相关专业在读\n熟练PyTorch/OpenCV，熟悉图像分割/增强/防抖算法\n有手机相机项目经验优先\n熟悉移动端推理框架加分\n英语六级以上', 7, 14, '东莞', 1),
(51, 'AI系统工程师 (社招)', 99, 'OriginOS AI功能规划与落地', '产品/计算机相关本科及以上\n3年以上AI产品或系统集成经验\n熟悉大模型在手机端的应用场景优先\n沟通协调能力强，业务理解深', 25, 45, '东莞', 1);

-- 52 联想集团
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(52, '2026届AI服务器实习生', 34, 'AI训练/推理服务器硬件测试与优化实习', '计算机/电子相关专业在读\n了解服务器架构、GPU集群基本原理\n有AI硬件测试或服务器项目经验加分\n动手能力强，英语四级以上', 5, 11, '北京', 1),
(52, '云服务器架构师 (社招)', 94, '联想ThinkSystem云原生服务器设计与优化', '计算机/电子相关本科及以上\n5年以上服务器架构经验\n精通K8s、GPU虚拟化、RDMA\n有AI服务器量产经验优先\n系统设计能力强，英语良好', 30, 55, '北京', 1);

-- 53 海尔智家
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(53, '2026届AIoT实习生', 33, '智能家居场景感知与联动算法实习', '物联网/计算机相关专业在读\n熟悉设备互联协议（Matter/Zigbee/Wi-Fi）\n有智能家居项目经验加分\nPython基础好', 5, 11, '青岛', 1),
(53, '智能家居产品经理 (社招)', 99, '智慧家庭场景产品规划与落地', '工业设计/电子/市场相关本科及以上\n3年以上IoT/智能家居产品经验\n熟悉用户需求挖掘与场景设计\n沟通能力强，英语良好', 22, 40, '青岛', 1);

-- 54 美的集团
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(54, '2026届机器人算法实习生', 85, '家电服务机器人路径规划/避障/抓取算法实习', '机器人/计算机相关专业在读\n熟悉SLAM、路径规划（A*/RRT/DWA）、机械臂运动学\n有ROS/ROS2项目经验优先\n数学基础好', 6, 13, '佛山', 1),
(54, '智能制造工程师 (社招)', 34, '家电生产线自动化与机器人集成优化', '自动化/机械工程相关本科及以上\n3年以上智能制造/工业机器人经验\n熟悉PLC、工业视觉、MES系统\n项目执行力强，能适应现场调试', 20, 38, '佛山', 1);

-- 55 广汽埃安
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(55, '2026届自动驾驶实习生', 85, '纯电平台感知/规划/控制算法实习', 'AI/车辆工程相关专业在读\n熟悉端到端自动驾驶或传统模块化方案\n有仿真测试经验加分\nPyTorch/MATLAB基础', 7, 14, '广州', 1),
(55, '三电系统工程师 (社招)', 31, '电池/电机/电控系统集成与标定', '电气/车辆相关本科及以上\n3年以上新能源汽车三电经验\n熟悉BMS/Motor Control/VCU\n有量产经验优先', 22, 42, '广州', 1);

-- 56 小鹏汽车
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(56, '2026届城市NOA实习生', 85, '端到端城市领航规划/控制/预测算法实习', '人工智能/车辆工程相关专业在读\n熟悉模仿学习/强化学习/Transformer-based规划\n有轨迹规划项目或竞赛经验优先\nPyTorch熟练，数学基础扎实\n英语六级以上\n实习需高强度参与', 8, 15, '广州', 1),
(56, '自动驾驶规划工程师 (社招)', 85, '城市/高速NOA规划与决策优化', '计算机/AI相关硕士及以上\n3年以上自动驾驶规划经验\n熟悉行为规划、轨迹生成、MPC/IDM\n有量产经验优先\n抗压能力强', 30, 55, '广州', 1),
(56, '2026届测试实习生', 90, '智能驾驶仿真与道路测试实习', '计算机相关专业在读\n熟悉Carla/LGSVL/SUMMIT仿真平台\n有自动驾驶测试脚本经验加分', 5, 11, '广州', 1);

-- 57 零跑汽车
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(57, '2026届电池管理实习生', 36, 'BMS算法开发与电池测试实习', '电气/控制相关专业在读\n熟悉SOC/SOH估算、均衡策略\n有电池测试经验加分\nMATLAB/Python基础', 5, 11, '金华', 1),
(57, '智能驾驶工程师 (社招)', 85, '纯电平台自动驾驶感知/规划开发', 'AI/车辆相关本科及以上\n3年以上自动驾驶经验\n有量产车型经验优先\n代码与工程能力强', 25, 45, '金华', 1);

-- 58 DeepSeek
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(58, '2026届大模型训练实习生', 82, '国产开源大模型预训练/后训练/SFT/RLHF全流程实习', '人工智能/计算机/数学相关专业硕士/博士在读（2026届优先）\n熟练PyTorch生态，熟悉Transformer实现细节、混合精度训练、梯度累积、ZeRO-Offload/ZeRO-Infinity等显存优化技巧\n有参与亿参数以上模型训练经验，或成功复现LLaMA/Mistral/Yi/GLM/Qwen等开源模型优先\n熟悉分布式训练框架（DeepSpeed、Megatron-LM、FSDP、Colossal-AI、FlashAttention-2）至少2种以上，能独立配置多节点训练任务\n了解大模型数据处理全链路（去重、过滤、tokenization、packing、多模态数据混合、质量评估）\n具备较强的工程调试能力，能快速定位loss爆炸/NaN/梯度消失/收敛慢等问题，并提出解决方案\n数学基础扎实（最优化理论、概率论、线性代数），代码能力强，追求训练效率、稳定性与可复现性\n英语六级及以上，能阅读Arxiv最新大模型论文（NeurIPS/ICLR/ICML），快速跟进社区进展与复现代码\n实习期间需全职或每周5天以上到岗，能适应高强度、高压力研发环境，责任心极强、团队协作主动、乐于分享技术', 8, 16, '上海', 1),
(58, '推理优化工程师 (社招)', 82, 'vLLM/TensorRT-LLM/自研推理引擎的高性能部署、量化、加速与服务化', '本科及以上学历，计算机/AI相关专业\n3–8年大模型推理优化经验，深入理解KV Cache管理、PagedAttention、FlashAttention-2、连续批处理、Speculative Decoding等技术\n熟练掌握TensorRT、vLLM、TGI、ONNX Runtime、TVM等主流推理框架，能独立完成模型转换、量化（INT8/INT4/AWQ/GPTQ/LLM.int8）、融合优化\n有生产环境部署千卡/万卡规模大模型经验，熟悉GPU/昇腾/昆仑芯等异构硬件推理加速优先\n具备优秀的性能分析与调优能力，能使用Nsight Systems/Compute、nvprof、TensorBoard等工具定位瓶颈并优化吞吐/延迟\n熟悉推理服务工程化（FastAPI/ Triton Inference Server、负载均衡、动态批处理、模型多版本管理、监控告警）\n代码工程能力强，熟悉CI/CD、容器化（Docker/K8s）、自动化测试\n英语良好，能阅读英文技术文档、参与国际社区讨论、跟踪最新推理论文\n抗压能力强，能应对紧急线上推理问题、快速响应业务需求，支持7×24值班', 28, 50, '上海', 1),
(58, '2026届Python后端实习生', 70, '大模型服务化API网关、推理平台后端开发实习', '计算机相关专业在读\n熟练Python后端开发，精通FastAPI/Flask/Django，熟悉异步编程（asyncio）、WebSocket\n了解大模型推理服务常见需求（多模型加载、动态批处理、流式输出、Token限流）\n有高并发Web服务开发或API网关经验加分\n熟悉Docker、K8s基础，了解Prometheus/Grafana监控加分\n代码规范强，测试意识好，英语四级以上\n每周至少4天到岗，实习期能适应快速迭代', 5, 12, '上海', 1),
(58, '大模型安全工程师 (社报)', 91, '大模型红队测试、对抗样本生成、安全防护与对齐实习/社招', '人工智能/网络安全相关专业硕士及以上\n3年以上大模型安全或红队测试经验\n熟悉Prompt Injection、Jailbreak、Data Poisoning、对抗攻击、后门植入等大模型安全攻击方式\n有LLM安全评估框架（Garak、LangChain Guardrails、NeMo Guardrails）使用或开发经验优先\n能设计自动化红队测试pipeline，生成高质量对抗样本并验证模型鲁棒性\n熟悉安全对齐技术（RLHF with safety reward、Constitutional AI、Self-Remind）\n代码能力强，熟悉PyTorch，能快速实现攻击/防御算法\n英语六级以上，能阅读安全领域最新论文（USENIX Security、CCS、arXiv安全专题）\n责任心极强，具备伦理意识，能适应高保密研发环境', 25, 45, '上海', 1);

-- 59 Moonshot AI（Kimi）
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(59, '2026届长上下文大模型实习生', 82, 'Kimi长文本/长上下文训练、位置编码优化、RoPE扩展实习', '人工智能/NLP相关专业硕士/博士在读\n熟练PyTorch，熟悉Transformer长序列处理（ALiBi、RoPE、NTK、PI、YaRN等）\n有长文档/长上下文模型训练或微调经验优先\n了解长序列训练稳定性问题（注意力稀疏化、梯度检查点、激活重计算）\n数学基础扎实，能独立设计实验验证新位置编码或注意力机制\n英语六级以上，能跟踪长上下文领域最新进展\n实习需高强度参与，抗压能力强', 8, 15, '北京', 1),
(59, '多模态大模型工程师 (社招)', 83, 'Kimi视觉+语言长上下文融合、对齐与应用开发', '计算机视觉/NLP相关硕士及以上\n3年以上多模态大模型经验，熟悉LLaVA系列、Kosmos、Qwen-VL、InternVL等\n有长文本+视觉融合、文档理解、多页PDF/长视频理解经验优先\n熟练分布式训练与推理优化\n业务理解强，能推动产品落地\n英语良好', 30, 55, '北京', 1),
(59, '2026届产品实习生', 99, 'Kimi长文本/多模态产品功能规划与用户体验优化实习', '产品/计算机相关专业在读\n对大模型产品有热情，了解长上下文应用场景\n有产品实习或竞品分析经验加分\n文档撰写与沟通能力强', 6, 12, '北京', 1);

-- 60 智谱AI（GLM）
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(60, '2026届GLM微调实习生', 82, 'GLM系列模型垂直领域SFT/LoRA/RLHF微调实习', '人工智能相关专业在读\n熟练PEFT/LoRA/QLoRA，熟悉指令微调与偏好对齐流程\n有垂直领域模型微调经验优先\nPyTorch工程能力强\n英语六级以上', 7, 14, '北京', 1),
(60, '对话系统工程师 (社招)', 86, 'GLM智能体/多轮对话/工具调用系统开发与优化', 'NLP/AI相关硕士及以上\n3年以上对话系统经验，熟悉Agent框架（ReAct/Toolformer/LangChain）\n有开源对话模型贡献或复杂多轮对话项目优先\n熟悉RAG、记忆机制、长上下文管理\n代码与产品思维兼备', 28, 50, '北京', 1),
(60, '2026届测试实习生', 88, '大模型自动化评测与红蓝队测试实习', '计算机相关专业在读\n熟练Python + 测试框架，了解大模型评测指标\n细心耐心，数据分析能力强', 5, 11, '北京', 1);

-- 61 MiniMax
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(61, '2026届多模态对话实习生', 86, '海螺AI/Talkie娱乐向多模态对话模型实习', 'NLP/AI相关专业在读\n熟悉多模态对话系统、角色扮演、情感对齐\n有娱乐/情感对话项目经验加分\nPyTorch基础好', 7, 14, '上海', 1),
(61, '娱乐大模型工程师 (社招)', 83, 'Talkie等娱乐向多模态生成与交互开发', '3年以上生成模型经验\n熟悉Stable Diffusion/LLaVA在娱乐场景应用\n有角色扮演/情感陪伴模型经验优先\n创意与工程能力兼备', 28, 50, '上海', 1);

-- 62 StepFun（阶跃星辰）
INSERT INTO job (company_id, title, category_id, description, requirements, salary_min, salary_max, location, status) VALUES
(62, '2026届多模态融合实习生', 83, '视觉/语音/文本多模态大模型融合训练实习', 'AI相关专业在读\n熟悉多模态预训练与融合架构\n有视觉+语音项目经验加分\nPyTorch熟练，数学基础好', 7, 14, '北京', 1),
(62, '多模态大模型工程师 (社招)', 83, '阶跃星辰视觉/语音/文本统一多模态模型研发', '3年以上多模态经验\n熟悉端到端多模态Transformer\n有语音+视觉融合量产经验优先\n工程能力强，抗压', 30, 55, '北京', 1),
(62, '2026届推理工程师实习生', 82, '多模态模型推理加速与服务化实习', '计算机相关专业在读\n熟悉vLLM/TensorRT/ONNX Runtime\n有大模型部署经验加分\n性能调优意识强', 6, 13, '北京', 1);





INSERT INTO sys_user (username, password, role, status) VALUES
('li_xiaoyu001', '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('wang_zhifan',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('zhang_ruiqi',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('chen_yuhan',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('liu_haoran',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('yang_xinyi',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('zhao_mengyao', '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('wu_jiaxin',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('zhou_tianyi',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('xu_chenxi',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('sun_yifei',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('ma_yuning',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('hu_jingyi',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('guo_zihan',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('lin_xuan',     '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('feng_yuxuan',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('deng_ziyue',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('cao_yuchen',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('peng_xiaohan', '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('jiang_mingze', '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('he_yutong',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('tang_junyi',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('song_xinyue',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('du_yifan',     '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('shen_chenyu',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('wei_zixuan',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('han_yutian',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('lv_xiaotong',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('jin_haoyu',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('shi_zimo',     '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('fu_yingrui',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('qian_zhihao',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('hong_xinran',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('yan_ziyi',     '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('cheng_yaowen', '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('luo_tianle',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('xie_jiahui',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('dai_yilin',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('qiao_zhiyuan', '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('bao_xuanxuan', '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('meng_zixuan',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('shi_yichen',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('ye_haoran',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('mo_yihan',     '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('pan_junhao',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('su_xinlei',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('ding_yuxuan',  '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('ren_chenxi',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('jin_zihan',    '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1),
('cui_yutong',   '$2b$10$SyXM2bnG5LpgjYal37SbfuT0X4Q8IrD4jzwmo9xN04p4fd8I/wD/m', 'STUDENT', 1);

INSERT INTO student (user_id, name, gender, phone, email, university, major, graduation_year, avatar) VALUES
(114, '李晓钰', '女', '13812345678', 'li_xiaoyu001@example.com', '清华大学', '计算机科学与技术', 2026, NULL),
(115, '王志凡', '男', '13987654321', 'wang_zhifan@example.com', '北京大学', '软件工程', 2026, NULL),
(116, '张瑞琪', '女', '13611112233', 'zhang_ruiqi@example.com', '复旦大学', '人工智能', 2026, NULL),
(117, '陈雨涵', '女', '13744445555', 'chen_yuhan@example.com', '浙江大学', '数据科学与大数据技术', 2026, NULL),
(118, '刘浩然', '男', '13566667777', 'liu_haoran@example.com', '上海交通大学', '信息安全', 2026, NULL),
(119, '杨欣怡', '女', '18888889999', 'yang_xinyi@example.com', '南京大学', '计算机科学与技术', 2026, NULL),
(120, '赵梦瑶', '女', '15012341234', 'zhao_mengyao@example.com', '武汉大学', '软件工程', 2026, NULL),
(121, '吴佳欣', '女', '15156785678', 'wu_jiaxin@example.com', '华中科技大学', '人工智能', 2026, NULL),
(122, '周天一', '男', '15298769876', 'zhou_tianyi@example.com', '西安交通大学', '数据科学与大数据技术', 2026, NULL),
(123, '徐晨曦', '女', '15334563456', 'xu_chenxi@example.com', '哈尔滨工业大学', '计算机科学与技术', 2026, NULL),
(124, '孙怡菲', '女', '18022223333', 'sun_yifei@example.com', '同济大学', '信息安全', 2026, NULL),
(125, '马宇宁', '男', '18177778888', 'ma_yuning@example.com', '东南大学', '软件工程', 2026, NULL),
(126, '胡静怡', '女', '18299990000', 'hu_jingyi@example.com', '南开大学', '人工智能', 2026, NULL),
(127, '郭子涵', '男', '18311112222', 'guo_zihan@example.com', '天津大学', '数据科学与大数据技术', 2026, NULL),
(128, '林轩', '男', '18433334444', 'lin_xuan@example.com', '厦门大学', '计算机科学与技术', 2026, NULL),
(129, '冯宇轩', '男', '18555556666', 'feng_yuxuan@example.com', '山东大学', '软件工程', 2026, NULL),
(130, '邓子悦', '女', '18677778888', 'deng_ziyue@example.com', '四川大学', '人工智能', 2026, NULL),
(131, '曹雨晨', '女', '18799990000', 'cao_yuchen@example.com', '电子科技大学', '信息安全', 2026, NULL),
(132, '彭晓涵', '女', '18922223333', 'peng_xiaohan@example.com', '北京邮电大学', '数据科学与大数据技术', 2026, NULL),
(133, '蒋明泽', '男', '13044445555', 'jiang_mingze@example.com', '北京理工大学', '计算机科学与技术', 2026, NULL),
(134, '何雨桐', '女', '13166667777', 'he_yutong@example.com', '西北工业大学', '软件工程', 2026, NULL),
(135, '唐俊逸', '男', '13288889999', 'tang_junyi@example.com', '大连理工大学', '人工智能', 2026, NULL),
(136, '宋欣悦', '女', '13300001111', 'song_xinyue@example.com', '重庆大学', '数据科学与大数据技术', 2026, NULL),
(137, '杜一凡', '男', '13422223333', 'du_yifan@example.com', '吉林大学', '计算机科学与技术', 2026, NULL),
(138, '沈晨宇', '男', '13544445555', 'shen_chenyu@example.com', '中山大学', '信息安全', 2026, NULL),
(139, '魏子轩', '男', '13666667777', 'wei_zixuan@example.com', '华南理工大学', '软件工程', 2026, NULL),
(140, '韩宇天', '男', '13788889999', 'han_yutian@example.com', '中国科学技术大学', '人工智能', 2026, NULL),
(141, '吕晓彤', '女', '13800001111', 'lv_xiaotong@example.com', '北京航空航天大学', '数据科学与大数据技术', 2026, NULL),
(142, '金浩宇', '男', '13922223333', 'jin_haoyu@example.com', '北京师范大学', '计算机科学与技术', 2026, NULL),
(143, '石子墨', '男', '13044445555', 'shi_zimo@example.com', '中央财经大学', '软件工程', 2026, NULL),
(144, '付颖睿', '女', '13166667777', 'fu_yingrui@example.com', '对外经济贸易大学', '人工智能', 2026, NULL),
(145, '钱志豪', '男', '13288889999', 'qian_zhihao@example.com', '上海财经大学', '数据科学与大数据技术', 2026, NULL),
(146, '洪欣然', '女', '13300001111', 'hong_xinran@example.com', '西南财经大学', '计算机科学与技术', 2026, NULL),
(147, '闫子怡', '女', '13422223333', 'yan_ziyi@example.com', '中南财经政法大学', '信息安全', 2026, NULL),
(148, '程耀文', '男', '13544445555', 'cheng_yaowen@example.com', '东北大学', '软件工程', 2026, NULL),
(149, '罗天乐', '男', '13666667777', 'luo_tianle@example.com', '湖南大学', '人工智能', 2026, NULL),
(150, '谢佳慧', '女', '13788889999', 'xie_jiahui@example.com', '兰州大学', '数据科学与大数据技术', 2026, NULL),
(151, '戴怡琳', '女', '13800001111', 'dai_yilin@example.com', '中国海洋大学', '计算机科学与技术', 2026, NULL),
(152, '乔志远', '男', '13922223333', 'qiao_zhiyuan@example.com', '中国地质大学', '软件工程', 2026, NULL),
(153, '鲍萱萱', '女', '13044445555', 'bao_xuanxuan@example.com', '中国石油大学', '人工智能', 2026, NULL),
(154, '孟子轩', '男', '13166667777', 'meng_zixuan@example.com', '中国矿业大学', '数据科学与大数据技术', 2026, NULL),
(155, '史奕辰', '男', '13288889999', 'shi_yichen@example.com', '河海大学', '计算机科学与技术', 2026, NULL),
(156, '叶浩然', '男', '13300001111', 'ye_haoran@example.com', '南京航空航天大学', '信息安全', 2026, NULL),
(157, '莫逸涵', '男', '13422223333', 'mo_yihan@example.com', '南京理工大学', '软件工程', 2026, NULL),
(158, '潘俊豪', '男', '13544445555', 'pan_junhao@example.com', '北京化工大学', '人工智能', 2026, NULL),
(159, '苏欣蕾', '女', '13666667777', 'su_xinlei@example.com', '北京交通大学', '数据科学与大数据技术', 2026, NULL),
(160, '丁雨轩', '女', '13788889999', 'ding_yuxuan@example.com', '北京科技大学', '计算机科学与技术', 2026, NULL),
(161, '任晨曦', '女', '13800001111', 'ren_chenxi@example.com', '北京工业大学', '软件工程', 2026, NULL),
(162, '金子涵', '女', '13922223333', 'jin_zihan@example.com', '北京林业大学', '人工智能', 2026, NULL),
(163, '崔雨桐', '女', '13044445555', 'cui_yutong@example.com', '中国农业大学', '数据科学与大数据技术', 2026, NULL);





-- 第 1 批简历数据精简版 (1-10)
-- 生成时间: 2026-03-10

INSERT INTO `resume` (`student_id`, `title`, `content`, `file_url`, `is_public`) VALUES 
(2, '李晓钰的求职简历', '{"name":"李晓钰","school":"清华大学","major":"计算机科学与技术","gpa":"3.7/4.0","rank":"前18%","tech":"Java/Go/Python/Spring Boot/Redis","intern":"阿里巴巴测试开发，优化接口响应降低59%，解决线上问题19个","project":"智能推荐系统(QPS 9548)、物联网平台(代码8k+行)","cert":"华为HCIP、系统架构设计师","eval":"热爱技术，具备扎实基础，有丰富的阿里实习经验"}', '/uploads/resume/resume_2_李晓钰.pdf', 1),

(3, '王志凡的求职简历', '{"name":"王志凡","school":"北京大学","major":"软件工程","gpa":"3.9/4.0","rank":"前6%","tech":"Java/Go/Python/Spring Boot/Gin/Vue","intern":"快手数据分析工程师，完成5个需求迭代，接口优化降低57%","project":"实时数据处理平台(GitHub 468+ Stars)、云原生监控系统","cert":"华为HCIP、系统架构设计师","eval":"ACM-ICPC银牌，热爱技术，积极参与开源社区"}', '/uploads/resume/resume_3_王志凡.pdf', 1),

(4, '张瑞琪的求职简历', '{"name":"张瑞琪","school":"复旦大学","major":"人工智能","gpa":"3.8/4.0","rank":"前26%","tech":"Python/C++/Java/PyTorch/Spring Boot","intern":"美团产品经理，完成5个需求迭代，解决线上问题6个","project":"在线教育直播平台(QPS 9847)、云原生监控告警系统","cert":"Oracle OCP、CKA","eval":"热爱AI技术，具备扎实基础，有丰富的美团实习经验"}', '/uploads/resume/resume_4_张瑞琪.pdf', 1),

(5, '陈雨涵的求职简历', '{"name":"陈雨涵","school":"浙江大学","major":"数据科学与大数据技术","gpa":"3.6/4.0","rank":"前9%","tech":"Python/Java/SQL/Spark/Flink/Hadoop","intern":"网易测试开发，解决线上问题17个，接口优化降低55%","project":"实时数据处理平台(GitHub 137+ Stars)、供应链管理系统","cert":"系统架构设计师、PMP、软件设计师、华为HCIP","eval":"ACM-ICPC银牌，热爱大数据技术，有丰富的网易实习经验"}', '/uploads/resume/resume_5_陈雨涵.pdf', 1),

(6, '刘浩然的求职简历', '{"name":"刘浩然","school":"上海交通大学","major":"信息安全","gpa":"3.6/4.0","rank":"前27%","tech":"Python/C/Go/Metasploit/Burp Suite","intern":"B站数据分析、美团测试开发，共解决线上问题34个","project":"智能推荐系统(GitHub 204+ Stars)、实时数据处理平台","cert":"CISP、系统架构设计师、CKA、华为HCIP","eval":"数学建模国赛二等奖，热爱安全技术，有丰富的B站和美团实习经验"}', '/uploads/resume/resume_6_刘浩然.pdf', 1),

(7, '杨欣怡的求职简历', '{"name":"杨欣怡","school":"南京大学","major":"计算机科学与技术","gpa":"3.4/4.0","rank":"前10%","tech":"Java/Go/Python/Spring Boot/gRPC/TiDB","intern":"滴滴后端开发完成8个需求，华为客户端开发完成8个需求","project":"社交APP后端(微服务架构)、在线教育直播平台(GitHub 226+ Stars)","cert":"系统架构设计师、PMP、Oracle OCP","eval":"蓝桥杯国赛一等奖，热爱技术，有丰富的滴滴和华为实习经验"}', '/uploads/resume/resume_7_杨欣怡.pdf', 1),

(8, '赵梦瑶的求职简历', '{"name":"赵梦瑶","school":"武汉大学","major":"软件工程","gpa":"3.4/4.0","rank":"前11%","tech":"Java/Go/Python/Spring Boot/Flink/HBase","intern":"滴滴数据分析+算法工程师，共解决线上问题22个，编写技术文档13篇","project":"金融风控系统(QPS 6734)、在线教育直播平台","cert":"AWS SAA、华为HCIP","eval":"互联网+金奖，热爱技术，有丰富的滴滴实习经验"}', '/uploads/resume/resume_8_赵梦瑶.pdf', 1),

(9, '吴佳欣的求职简历', '{"name":"吴佳欣","school":"华中科技大学","major":"人工智能","gpa":"3.4/4.0","rank":"前9%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"华为客户端开发解决线上问题20个，小红书算法工程师完成7个需求","project":"在线教育直播平台(代码1.4万行)、金融风控系统(GitHub 319+ Stars)","cert":"PMP、软件设计师、CKA","eval":"蓝桥杯国赛一等奖，热爱AI技术，有丰富的华为和小红书实习经验"}', '/uploads/resume/resume_9_吴佳欣.pdf', 1),

(10, '周天一', '{"name":"周天一","school":"西安交通大学","major":"数据科学与大数据技术","gpa":"3.4/4.0","rank":"前25%","tech":"Python/SQL/Java/Spark/Flink/Hadoop","intern":"腾讯产品经理，解决线上问题7个，接口优化降低59%，编写技术文档10篇","project":"供应链管理系统(Serverless)、实时数据处理平台(GitHub 132+ Stars)","cert":"华为HCIP、软件设计师","eval":"蓝桥杯国赛一等奖，热爱大数据技术，有丰富的腾讯实习经验"}', '/uploads/resume/resume_10_周天一.pdf', 1);





-- 第 2 批简历数据精简版 (11-20)
-- 生成时间: 2026-03-10

INSERT INTO `resume` (`student_id`, `title`, `content`, `file_url`, `is_public`) VALUES 
(11, '徐晨曦的求职简历', '{"name":"徐晨曦","school":"哈尔滨工业大学","major":"计算机科学与技术","gpa":"3.5/4.0","rank":"前11%","tech":"Java/Go/Python/Spring Boot/Kubernetes","intern":"百度后端开发接口优化降低37%，阿里测试开发完成8个需求迭代","project":"供应链管理系统(GitHub 210+ Stars)、分布式电商系统(代码1万+行)","cert":"AWS SAA、CISP、软件设计师、PMP","eval":"CET-6 649分，热爱技术，有百度和阿里实习经验"}', '/uploads/resume/resume_11_徐晨曦.pdf', 1),

(12, '孙怡菲的求职简历', '{"name":"孙怡菲","school":"同济大学","major":"信息安全","gpa":"3.7/4.0","rank":"前16%","tech":"Python/C/Go/Metasploit/Burp Suite","intern":"B站客户端开发完成4个需求，接口优化降低33%，编写技术文档5篇","project":"物联网平台(GitHub 64+ Stars, QPS 3392)、在线教育平台(QPS 4088)","cert":"CISP、华为HCIP、PMP、AWS SAA","eval":"国家奖学金，热爱安全技术，有丰富的B站实习经验"}', '/uploads/resume/resume_12_孙怡菲.pdf', 1),

(13, '马宇宁的求职简历', '{"name":"马宇宁","school":"东南大学","major":"软件工程","gpa":"3.5/4.0","rank":"前19%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"快手运维开发完成3个需求，美团算法工程师完成6个需求迭代","project":"智能推荐系统(GitHub 226+ Stars)、云原生监控系统(GitHub 448+ Stars)","cert":"CISP、AWS SAA、软件设计师","eval":"ACM-ICPC银牌，热爱技术，有快手和美团实习经验"}', '/uploads/resume/resume_13_马宇宁.pdf', 1),

(14, '胡静怡的求职简历', '{"name":"胡静怡","school":"南开大学","major":"人工智能","gpa":"3.7/4.0","rank":"前18%","tech":"Python/C++/Java/PyTorch/Spring Boot","intern":"美团前端开发完成5个需求，华为客户端开发完成7个需求迭代","project":"供应链管理系统(GitHub 480+ Stars)、物联网平台(GitHub 367+ Stars)","cert":"CISP、Oracle OCP、软件设计师、CKA","eval":"数学建模国赛二等奖，热爱AI技术，有美团和华为实习经验"}', '/uploads/resume/resume_14_胡静怡.pdf', 1),

(15, '郭子涵的求职简历', '{"name":"郭子涵","school":"天津大学","major":"数据科学与大数据技术","gpa":"3.3/4.0","rank":"前12%","tech":"Python/SQL/Java/Spark/Flink/Hadoop","intern":"B站算法工程师接口优化降低50%，滴滴运维开发解决线上问题12个","project":"物联网平台(GitHub 388+ Stars, QPS 9109)、金融风控系统(QPS 9629)","cert":"PMP、软件设计师","eval":"互联网+金奖，热爱大数据技术，有B站和滴滴实习经验"}', '/uploads/resume/resume_15_郭子涵.pdf', 1),

(16, '林轩的求职简历', '{"name":"林轩","school":"厦门大学","major":"计算机科学与技术","gpa":"3.4/4.0","rank":"前6%","tech":"Java/Go/Python/Spring Boot/Prometheus","intern":"小米前端开发完成8个需求迭代，接口优化降低61%，解决线上问题11个","project":"云原生监控系统(QPS 9449, GitHub 340+ Stars)、供应链管理系统","cert":"AWS SAA、华为HCIP、软件设计师、系统架构设计师","eval":"蓝桥杯国赛一等奖，热爱技术，有丰富的小米实习经验"}', '/uploads/resume/resume_16_林轩.pdf', 1),

(17, '冯宇轩的求职简历', '{"name":"冯宇轩","school":"山东大学","major":"软件工程","gpa":"3.6/4.0","rank":"前28%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"百度客户端开发完成4个需求，接口优化降低64%，编写技术文档9篇","project":"物联网平台(QPS 9330)、智能客服机器人(GitHub 466+ Stars, QPS 8657)","cert":"AWS SAA、软件设计师、CISP","eval":"ACM-ICPC银牌，热爱技术，有丰富的百度实习经验"}', '/uploads/resume/resume_17_冯宇轩.pdf', 1),

(18, '邓子悦的求职简历', '{"name":"邓子悦","school":"四川大学","major":"人工智能","gpa":"3.8/4.0","rank":"前24%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"携程运维开发完成3个需求，美团客户端开发完成7个需求迭代","project":"分布式电商系统(GitHub 385+ Stars)、物联网平台(GitHub 234+ Stars)","cert":"华为HCIP、CISP","eval":"CET-6 640分，国家奖学金，热爱AI技术，有携程和美团实习经验"}', '/uploads/resume/resume_18_邓子悦.pdf', 1),

(19, '曹雨晨的求职简历', '{"name":"曹雨晨","school":"电子科技大学","major":"信息安全","gpa":"3.8/4.0","rank":"前5%","tech":"Python/C/Go/Metasploit/Burp Suite","intern":"快手运维开发完成7个需求，拼多多运维开发解决线上问题7个","project":"社交APP后端(QPS 7816, 代码1万+行)、金融风控系统(QPS 1894)","cert":"软件设计师、华为HCIP、CKA、CISP","eval":"CET-6 647分，数学建模国赛二等奖，热爱安全技术，有快手和拼多多实习经验"}', '/uploads/resume/resume_19_曹雨晨.pdf', 1),

(20, '彭晓涵的求职简历', '{"name":"彭晓涵","school":"北京邮电大学","major":"数据科学与大数据技术","gpa":"3.7/4.0","rank":"前5%","tech":"Python/SQL/Java/Spark/Flink/Go","intern":"小米数据分析工程师完成6个需求迭代，接口优化降低51%，编写文档10篇","project":"分布式电商系统(GitHub 321+ Stars)、社交APP后端(代码1.4万+行)","cert":"PMP、AWS SAA、软件设计师","eval":"CET-6 632分，互联网+金奖，热爱大数据技术，有丰富的小米实习经验"}', '/uploads/resume/resume_20_彭晓涵.pdf', 1);

-- 第 3 批简历数据精简版 (21-30)
-- 生成时间: 2026-03-10

INSERT INTO `resume` (`student_id`, `title`, `content`, `file_url`, `is_public`) VALUES 
(21, '蒋明泽的求职简历', '{"name":"蒋明泽","school":"北京理工大学","major":"计算机科学与技术","gpa":"3.4/4.0","rank":"前8%","tech":"Java/Go/Python/Spring Boot/PyTorch","intern":"美团算法工程师完成6个需求，解决线上问题19个，接口优化降低50%","project":"智能推荐系统(代码6661行)、在线教育直播平台(GitHub 355+ Stars, 代码1.4万行)","cert":"CKA、Oracle OCP","eval":"CET-6 618分，数学建模国赛二等奖，热爱技术，有丰富的美团实习经验"}', '/uploads/resume/resume_21_蒋明泽.pdf', 1),

(22, '何雨桐的求职简历', '{"name":"何雨桐","school":"西北工业大学","major":"软件工程","gpa":"3.7/4.0","rank":"前26%","tech":"Java/Go/Python/Spring Boot/Django","intern":"腾讯测试开发完成7个需求，滴滴数据分析完成8个需求，接口优化降低60%","project":"供应链管理系统(GitHub 349+ Stars, QPS 4188)、物联网平台(GitHub 191+ Stars)","cert":"PMP、软件设计师","eval":"数学建模国赛二等奖，热爱技术，有腾讯和滴滴实习经验"}', '/uploads/resume/resume_22_何雨桐.pdf', 1),

(23, '唐俊逸的求职简历', '{"name":"唐俊逸","school":"大连理工大学","major":"人工智能","gpa":"3.5/4.0","rank":"前5%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"快手数据分析完成7个需求，解决线上问题9个，编写技术文档7篇","project":"金融风控系统(GitHub 314+ Stars, 代码1.4万行)、云原生监控系统(GitHub 139+ Stars)","cert":"系统架构设计师、AWS SAA、Oracle OCP","eval":"ACM-ICPC银牌，热爱AI技术，有丰富的快手实习经验"}', '/uploads/resume/resume_23_唐俊逸.pdf', 1),

(24, '宋欣悦的求职简历', '{"name":"宋欣悦","school":"重庆大学","major":"数据科学与大数据技术","gpa":"3.5/4.0","rank":"前21%","tech":"Python/SQL/Java/Spark/Flink","intern":"小米客户端开发完成6个需求，接口优化降低55%，编写技术文档10篇","project":"在线教育直播平台(GitHub 376+ Stars, QPS 3929)、供应链管理系统(QPS 3321)","cert":"Oracle OCP、软件设计师、华为HCIP、CKA","eval":"国家奖学金，热爱大数据技术，有丰富的小米实习经验"}', '/uploads/resume/resume_24_宋欣悦.pdf', 1),

(25, '杜一凡的求职简历', '{"name":"杜一凡","school":"吉林大学","major":"计算机科学与技术","gpa":"3.6/4.0","rank":"前10%","tech":"Java/Go/Python/Spring Boot/Flink","intern":"华为产品经理完成8个需求，接口优化降低33%，编写技术文档9篇","project":"实时数据处理平台(GitHub 325+ Stars, QPS 5188)、分布式电商系统(GitHub 461+ Stars)","cert":"华为HCIP、CISP","eval":"国家奖学金，热爱技术，有丰富的华为实习经验"}', '/uploads/resume/resume_25_杜一凡.pdf', 1),

(26, '沈晨宇的求职简历', '{"name":"沈晨宇","school":"中山大学","major":"信息安全","gpa":"3.4/4.0","rank":"前17%","tech":"Python/C/Go/Metasploit/Flink","intern":"美团数据分析解决线上问题13个，接口优化降低37%，编写技术文档10篇","project":"实时数据处理平台(QPS 5894)、物联网平台(QPS 1962, 代码1.3万行)","cert":"PMP、CISP、CKA","eval":"国家奖学金，热爱安全技术，有丰富的美团实习经验"}', '/uploads/resume/resume_26_沈晨宇.pdf', 1),

(27, '魏子轩的求职简历', '{"name":"魏子轩","school":"华南理工大学","major":"软件工程","gpa":"3.4/4.0","rank":"前7%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"拼多多客户端开发完成4个需求，接口优化降低60%，解决线上问题11个","project":"智能推荐系统(GitHub 132+ Stars, QPS 3483)、金融风控系统(GitHub 184+ Stars)","cert":"CISP、Oracle OCP、CKA、软件设计师","eval":"互联网+金奖，热爱技术，有丰富的拼多多实习经验"}', '/uploads/resume/resume_27_魏子轩.pdf', 1),

(28, '韩宇天的求职简历', '{"name":"韩宇天","school":"中国科学技术大学","major":"人工智能","gpa":"3.5/4.0","rank":"前29%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"网易后端开发完成7个需求，接口优化降低68%，解决线上问题10个","project":"智能推荐系统(QPS 3640)、物联网平台(QPS 3330, 优秀项目奖)","cert":"Oracle OCP、AWS SAA","eval":"蓝桥杯国赛一等奖，热爱AI技术，有丰富的网易实习经验"}', '/uploads/resume/resume_28_韩宇天.pdf', 1),

(29, '吕晓彤的求职简历', '{"name":"吕晓彤","school":"北京航空航天大学","major":"数据科学与大数据技术","gpa":"3.8/4.0","rank":"前5%","tech":"Python/SQL/Java/Spark/Go","intern":"美团前端开发完成3个需求，接口优化降低58%，解决线上问题13个","project":"社交APP后端(GitHub 197+ Stars, 代码1.3万行)、在线教育平台(GitHub 409+ Stars)","cert":"PMP、CKA","eval":"CET-6 627分，ACM-ICPC银牌，热爱大数据技术，有丰富的美团实习经验"}', '/uploads/resume/resume_29_吕晓彤.pdf', 1),

(30, '金浩宇的求职简历', '{"name":"金浩宇","school":"北京师范大学","major":"计算机科学与技术","gpa":"3.8/4.0","rank":"前9%","tech":"Java/Go/Python/Spring Boot/Spring Cloud","intern":"快手运维开发完成8个需求解决线上问题20个，滴滴数据分析接口优化降低33%","project":"分布式电商系统(GitHub 383+ Stars)、供应链管理系统(QPS 1694, 技术创新奖)","cert":"CKA、CISP","eval":"热爱技术，有快手和滴滴实习经验"}', '/uploads/resume/resume_30_金浩宇.pdf', 1);

-- 第 4 批简历数据精简版 (31-40)
-- 生成时间: 2026-03-10

INSERT INTO `resume` (`student_id`, `title`, `content`, `file_url`, `is_public`) VALUES 
(31, '石子墨的求职简历', '{"name":"石子墨","school":"中央财经大学","major":"软件工程","gpa":"3.6/4.0","rank":"前29%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"网易测试开发完成4个需求，携程数据分析完成8个需求，接口优化降低62%","project":"智能推荐系统(GitHub 301+ Stars, 代码7963行)、在线教育平台(QPS 6247, 代码1.2万行)","cert":"CKA、软件设计师、PMP、华为HCIP","eval":"ACM-ICPC银牌，热爱技术，有网易和携程实习经验"}', '/uploads/resume/resume_31_石子墨.pdf', 1),

(32, '付颖睿的求职简历', '{"name":"付颖睿","school":"对外经济贸易大学","major":"人工智能","gpa":"3.5/4.0","rank":"前22%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"快手客户端开发完成8个需求，拼多多算法工程师完成3个需求，解决线上问题18个","project":"金融风控系统(GitHub 457+ Stars, QPS 1496)、物联网平台(代码7842行)","cert":"系统架构设计师、AWS SAA、CISP、软件设计师","eval":"热爱AI技术，有快手和拼多多实习经验"}', '/uploads/resume/resume_32_付颖睿.pdf', 1),

(33, '钱志豪的求职简历', '{"name":"钱志豪","school":"上海财经大学","major":"数据科学与大数据技术","gpa":"3.8/4.0","rank":"前6%","tech":"Python/SQL/Java/Spark/Flink","intern":"滴滴前端开发完成3个需求，腾讯客户端开发完成4个需求，解决线上问题19个","project":"智能客服机器人(代码6834行)、智能推荐系统(GitHub 56+ Stars, 代码1.1万行)","cert":"PMP、Oracle OCP、CKA、软件设计师","eval":"CET-6 621分，国家奖学金，热爱大数据技术，有滴滴和腾讯实习经验"}', '/uploads/resume/resume_33_钱志豪.pdf', 1),

(34, '洪欣然的求职简历', '{"name":"洪欣然","school":"西南财经大学","major":"计算机科学与技术","gpa":"3.4/4.0","rank":"前15%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"小红书前端开发接口优化降低60%，解决线上问题14个，编写技术文档7篇","project":"云原生监控系统(GitHub 213+ Stars, QPS 8042)、供应链管理系统(GitHub 446+ Stars)","cert":"Oracle OCP、软件设计师","eval":"CET-6 619分，蓝桥杯国赛一等奖，热爱技术，有丰富的小红书实习经验"}', '/uploads/resume/resume_34_洪欣然.pdf', 1),

(35, '闫子怡的求职简历', '{"name":"闫子怡","school":"中南财经政法大学","major":"信息安全","gpa":"3.5/4.0","rank":"前24%","tech":"Python/C/Go/Metasploit/Burp Suite","intern":"滴滴前端开发接口优化降低33%，解决线上问题5个，编写技术文档3篇","project":"云原生监控系统(代码1.1万行)、在线教育平台(GitHub 419+ Stars, QPS 1599)","cert":"软件设计师、华为HCIP","eval":"蓝桥杯国赛一等奖，热爱安全技术，有滴滴实习经验"}', '/uploads/resume/resume_35_闫子怡.pdf', 1),

(36, '程耀文的求职简历', '{"name":"程耀文","school":"东北大学","major":"软件工程","gpa":"3.6/4.0","rank":"前27%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"京东运维开发完成8个需求，阿里客户端开发完成3个需求，共解决线上问题26个","project":"金融风控系统(GitHub 141+ Stars, 代码1.2万行)、在线教育平台(QPS 2163, 代码1.2万行)","cert":"AWS SAA、华为HCIP","eval":"CET-6 645分，ACM-ICPC银牌，热爱技术，有京东和阿里实习经验"}', '/uploads/resume/resume_36_程耀文.pdf', 1),

(37, '罗天乐的求职简历', '{"name":"罗天乐","school":"湖南大学","major":"人工智能","gpa":"3.4/4.0","rank":"前13%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"网易运维开发完成6个需求，接口优化降低54%，编写技术文档6篇","project":"智能推荐系统(GitHub 62+ Stars, 代码5241行)、分布式电商系统(GitHub 186+ Stars)","cert":"系统架构设计师、PMP、Oracle OCP","eval":"ACM-ICPC银牌，互联网+金奖，热爱AI技术，有丰富的网易实习经验"}', '/uploads/resume/resume_37_罗天乐.pdf', 1),

(38, '谢佳慧的求职简历', '{"name":"谢佳慧","school":"兰州大学","major":"数据科学与大数据技术","gpa":"3.8/4.0","rank":"前16%","tech":"Python/SQL/Java/Spark/Flink","intern":"小红书测试开发完成3个需求，解决线上问题5个，编写技术文档3篇","project":"供应链管理系统(GitHub 289+ Stars, QPS 2414)、云原生监控系统(GitHub 397+ Stars)","cert":"AWS SAA、软件设计师、CISP、华为HCIP","eval":"CET-6 607分，数学建模国赛二等奖，热爱大数据技术，有小红书实习经验"}', '/uploads/resume/resume_38_谢佳慧.pdf', 1),

(39, '戴怡琳的求职简历', '{"name":"戴怡琳","school":"中国海洋大学","major":"计算机科学与技术","gpa":"3.8/4.0","rank":"前16%","tech":"Java/Go/Python/Spring Boot/PyTorch","intern":"网易算法工程师接口优化降低64%，解决线上问题6个，编写技术文档5篇","project":"智能推荐系统(QPS 6754, 优秀项目奖)、智能客服机器人(代码1万+行, 技术创新奖)","cert":"AWS SAA、PMP、系统架构设计师、软件设计师","eval":"CET-6 641分，蓝桥杯国赛一等奖，热爱技术，有丰富的网易实习经验"}', '/uploads/resume/resume_39_戴怡琳.pdf', 1),

(40, '乔志远的求职简历', '{"name":"乔志远","school":"中国地质大学","major":"软件工程","gpa":"3.3/4.0","rank":"前22%","tech":"Java/Go/Python/Spring Boot/Spring Cloud","intern":"B站测试开发接口优化降低61%，完成3个需求迭代，编写技术文档5篇","project":"社交APP后端(GitHub 184+ Stars, QPS 7468)、分布式电商系统(GitHub 381+ Stars, QPS 9996)","cert":"PMP、AWS SAA、CISP、Oracle OCP","eval":"CET-6 616分，数学建模国赛二等奖，热爱技术，有丰富的B站实习经验"}', '/uploads/resume/resume_40_乔志远.pdf', 1);

-- 第 5 批简历数据精简版 (41-50)
-- 生成时间: 2026-03-10

INSERT INTO `resume` (`student_id`, `title`, `content`, `file_url`, `is_public`) VALUES 
(41, '鲍萱萱的求职简历', '{"name":"鲍萱萱","school":"中国石油大学","major":"人工智能","gpa":"3.5/4.0","rank":"前23%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"小米数据分析完成6个需求，阿里后端开发完成7个需求，共解决线上问题25个","project":"社交APP后端(GitHub 294+ Stars, 代码7725行)、智能推荐系统(技术创新奖)","cert":"华为HCIP、CKA、系统架构设计师、Oracle OCP","eval":"国家奖学金，热爱AI技术，有小米和阿里实习经验"}', '/uploads/resume/resume_41_鲍萱萱.pdf', 1),

(42, '孟子轩的求职简历', '{"name":"孟子轩","school":"中国矿业大学","major":"数据科学与大数据技术","gpa":"3.5/4.0","rank":"前15%","tech":"Python/SQL/Java/Spark/Flink","intern":"腾讯数据分析完成8个需求，接口优化降低49%，编写技术文档6篇","project":"物联网平台(GitHub 228+ Stars, QPS 7252)、实时数据处理平台(GitHub 317+ Stars, 代码1.4万行)","cert":"AWS SAA、系统架构设计师","eval":"互联网+金奖，热爱大数据技术，有丰富的腾讯实习经验"}', '/uploads/resume/resume_42_孟子轩.pdf', 1),

(43, '史奕辰的求职简历', '{"name":"史奕辰","school":"河海大学","major":"计算机科学与技术","gpa":"3.5/4.0","rank":"前7%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"美团算法工程师解决线上问题10个，接口优化降低35%，编写技术文档4篇","project":"在线教育直播平台(代码1.1万行)、实时数据处理平台(QPS 5740, 代码8596行)","cert":"CKA、Oracle OCP","eval":"CET-6 618分，ACM-ICPC银牌，热爱技术，有丰富的美团实习经验"}', '/uploads/resume/resume_43_史奕辰.pdf', 1),

(44, '叶浩然的求职简历', '{"name":"叶浩然","school":"南京航空航天大学","major":"信息安全","gpa":"3.7/4.0","rank":"前5%","tech":"Python/C/Go/Metasploit/Burp Suite","intern":"京东前端开发完成6个需求，美团后端开发完成8个需求，共解决线上问题28个","project":"分布式电商系统(代码6232行, 优秀项目奖)、金融风控系统(GitHub 401+ Stars, 代码1万行)","cert":"软件设计师、CKA","eval":"蓝桥杯国赛一等奖，热爱安全技术，有京东和美团实习经验"}', '/uploads/resume/resume_44_叶浩然.pdf', 1),

(45, '莫逸涵的求职简历', '{"name":"莫逸涵","school":"南京理工大学","major":"软件工程","gpa":"3.9/4.0","rank":"前8%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"京东客户端开发完成4个需求，百度客户端开发完成6个需求，共解决线上问题7个","project":"分布式电商系统(代码8114行, 优秀项目奖)、社交APP后端(GitHub 57+ Stars, QPS 3374)","cert":"CKA、系统架构设计师","eval":"蓝桥杯国赛一等奖，国家奖学金，热爱技术，有京东和百度实习经验"}', '/uploads/resume/resume_45_莫逸涵.pdf', 1),

(46, '潘俊豪的求职简历', '{"name":"潘俊豪","school":"北京化工大学","major":"人工智能","gpa":"3.8/4.0","rank":"前6%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"B站测试开发完成6个需求，接口优化降低32%，编写技术文档4篇","project":"在线教育直播平台(QPS 8975, GitHub 69+ Stars)、分布式电商系统(GitHub 172+ Stars, QPS 6190)","cert":"软件设计师、Oracle OCP、AWS SAA","eval":"蓝桥杯国赛一等奖，热爱AI技术，有丰富的B站实习经验"}', '/uploads/resume/resume_46_潘俊豪.pdf', 1),

(47, '苏欣蕾的求职简历', '{"name":"苏欣蕾","school":"北京交通大学","major":"数据科学与大数据技术","gpa":"3.4/4.0","rank":"前19%","tech":"Python/SQL/Java/Spark/Flink","intern":"阿里运维开发完成7个需求，接口优化降低44%，编写技术文档4篇","project":"云原生监控系统(QPS 4964, 代码1.2万行)、分布式电商系统(GitHub 310+ Stars, QPS 5922)","cert":"软件设计师、CKA、系统架构设计师","eval":"国家奖学金，热爱大数据技术，有丰富的阿里实习经验"}', '/uploads/resume/resume_47_苏欣蕾.pdf', 1),

(48, '丁雨轩的求职简历', '{"name":"丁雨轩","school":"北京科技大学","major":"计算机科学与技术","gpa":"3.5/4.0","rank":"前16%","tech":"Java/Go/Python/Spring Boot/React","intern":"字节跳动测试开发解决线上问题20个，接口优化降低34%，编写技术文档7篇","project":"供应链管理系统(GitHub 126+ Stars, QPS 4949)、分布式电商系统(QPS 4282, 代码6415行)","cert":"Oracle OCP、软件设计师、PMP","eval":"热爱技术，有丰富的字节跳动实习经验"}', '/uploads/resume/resume_48_丁雨轩.pdf', 1),

(49, '任晨曦的求职简历', '{"name":"任晨曦","school":"北京工业大学","major":"软件工程","gpa":"3.6/4.0","rank":"前13%","tech":"Java/Go/Python/Spring Boot/Gin","intern":"小红书测试开发解决线上问题14个，京东前端开发完成3个需求迭代","project":"在线教育直播平台(QPS 6770)、物联网平台(GitHub 445+ Stars, 代码1.2万行)","cert":"AWS SAA、CKA、PMP、Oracle OCP","eval":"CET-6 610分，热爱技术，有小红书和京东实习经验"}', '/uploads/resume/resume_49_任晨曦.pdf', 1),

(50, '金子涵的求职简历', '{"name":"金子涵","school":"北京林业大学","major":"人工智能","gpa":"3.7/4.0","rank":"前7%","tech":"Python/C++/Java/PyTorch/TensorFlow","intern":"美团客户端开发完成4个需求，滴滴客户端开发完成3个需求，共解决线上问题17个","project":"分布式电商系统(QPS 8582)、在线教育直播平台(QPS 8769, 代码1.4万行)","cert":"华为HCIP、PMP、系统架构设计师","eval":"ACM-ICPC银牌，国家奖学金，热爱AI技术，有美团和滴滴实习经验"}', '/uploads/resume/resume_50_金子涵.pdf', 1);





INSERT INTO news (title, content, author_id, view_count, create_time) VALUES

('【系统维护通知】就业服务平台将于3月16日晚进行维护升级', '各位师生：\n\n为提升系统稳定性与用户体验，就业服务平台将于今晚（3月16日）23:00-次日01:00进行系统维护升级。\n\n维护期间，平台将暂停访问，包括岗位查询、简历投递、在线预约等功能均无法使用。请各位同学提前安排使用时间，避免影响求职进度。\n\n如有紧急情况，请联系就业服务中心值班电话：010-12345678。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【重磅】2026届春季校园招聘会正式启动，120+名企等你来', '各位2026届毕业生：\n\n"职引未来·筑梦青春"2026届春季校园招聘会正式启动！本次招聘会将邀请120+优质企业参与，涵盖互联网、智能制造、金融科技、新能源等多个热门行业，提供就业岗位3000+。\n\n【时间】2026年3月20日（周四）09:00-16:00\n【地点】学校体育馆主馆\n【参会企业】阿里巴巴、腾讯、字节跳动、华为、比亚迪、中信证券等120余家知名企业\n【岗位类型】技术研发、产品运营、市场营销、职能管理、生产制造等\n\n【温馨提示】\n1. 请提前在就业平台预约参会，领取电子入场券\n2. 建议携带纸质简历10-15份\n3. 着装得体，建议商务休闲装\n\n预约链接：https://career.university.edu.cn\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【宣讲会预告】阿里巴巴2026届校招宣讲会·3月17日', '各位同学：\n\n阿里巴巴集团将于本周五举办2026届校园招聘宣讲会，届时将有HR及业务部门负责人现场分享，并接收简历投递。\n\n【时间】2026年3月17日（周五）14:00-16:00\n【地点】A3报告厅\n【面向对象】2026届本科、硕士、博士毕业生\n【招聘岗位】Java开发工程师、前端工程师、产品经理、算法工程师、数据分析师等\n【薪资范围】年薪25-45万（视岗位及能力而定）\n\n【宣讲流程】\n14:00-14:30 集团介绍及业务分享\n14:30-15:15 技术/产品专场分享\n15:15-15:45 校友经验分享\n15:45-16:00 Q&A及简历投递\n\n【准备材料】纸质简历、成绩单、相关证书复印件\n\n阿里巴巴校园招聘组\n2026年3月15日', 1, 0, NOW()),

('【技术专场】腾讯2026届技术岗宣讲会·3月21日', '计算机学院及相关专业同学：\n\n腾讯公司将于下周二举办技术专场宣讲会，重点招聘软件开发、算法、测试开发等技术岗位。欢迎计算机、软件工程、人工智能等相关专业同学参加。\n\n【时间】2026年3月21日（周二）19:00-21:00\n【地点】科技馆二楼报告厅\n【招聘部门】微信事业群、云与智慧产业事业群、互动娱乐事业群、技术工程事业群\n【岗位类型】后端开发、前端开发、算法工程师、测试开发、运维工程师\n\n【内推福利】\n现场投递简历可获得内推资格，简历优先筛选，面试流程加速！\n\n【笔试时间】3月25日（周六）10:00\n【面试安排】3月底-4月初\n\n腾讯招聘团队\n2026年3月15日', 1, 0, NOW()),

('【报名开启】"简历门诊"一对一优化工作坊', '各位同学：\n\n为帮助同学们提升求职竞争力，就业服务中心特邀资深HR及职业规划师举办"简历门诊"工作坊，提供一对一简历诊断与优化服务。\n\n【活动时间】2026年3月18日-3月22日\n【服务时段】每日09:00-12:00，14:00-17:00\n【地点】就业服务中心咨询室（学生活动中心301）\n【服务对象】全体在校学生，限50人\n\n【服务内容】\n✓ 简历结构优化与排版建议\n✓ 个人优势挖掘与表达\n✓ 项目经历描述技巧\n✓ 针对不同岗位的简历定制策略\n\n【报名方式】\n登录就业服务平台→活动报名→选择时段→上传现有简历\n报名截止：3月17日18:00\n\n【温馨提示】建议携带笔记本电脑，现场修改完善。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【时间调整】就业服务中心3月17日下午暂停线下服务', '各位师生：\n\n因全体工作人员参加业务培训，就业服务中心将于本周五（3月17日）下午暂停线下服务。\n\n【暂停时间】3月17日（周五）13:30-17:30\n【暂停业务】现场咨询、简历打印、就业协议盖章、档案查询等\n\n【替代服务】\n1. 线上咨询：就业服务平台"在线咨询"功能24小时开放\n2. 紧急事务：请拨打值班电话010-12345678\n3. 自助服务：就业服务大厅自助终端可正常使用\n\n【恢复时间】3月20日（周一）起恢复正常办公\n\n给您带来不便，敬请谅解。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】美团2026届前端实习生招募启动', '各位同学：\n\n美团到店事业群前端团队开放2026届实习生招聘，欢迎有志于前端开发的同学投递简历。\n\n【岗位名称】前端开发实习生\n【工作地点】北京、上海、成都\n【实习时长】3个月及以上，优秀者可转正\n【薪资待遇】300-400元/天，另有餐补、房补\n\n【岗位职责】\n1. 参与美团App及小程序的前端开发工作\n2. 参与前端性能优化及工程化建设\n3. 参与技术方案设计与代码评审\n\n【任职要求】\n1. 2026届本科及以上学历，计算机相关专业\n2. 熟悉HTML/CSS/JavaScript，了解React或Vue框架\n3. 对前端技术有热情，具备良好的学习能力\n\n【投递方式】\n邮箱：campus@meituan.com\n邮件标题：姓名-学校-前端实习-到岗时间\n\n【截止日期】2026年4月15日\n\n美团招聘团队\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】京东技术部Java后端开发实习生', '各位同学：\n\n京东零售技术部开放后端开发实习岗位，诚邀热爱技术的你加入！\n\n【岗位名称】Java后端开发实习生\n【部门】京东零售-平台业务部\n【工作地点】北京亦庄总部\n【实习待遇】350-450元/天，免费三餐，异地房补1500元/月\n\n【岗位职责】\n1. 参与京东核心交易系统的开发与维护\n2. 参与高并发系统的设计与优化\n3. 参与分布式系统技术攻关\n\n【岗位要求】\n1. 2026届硕士及以上学历，计算机相关专业优先\n2. 扎实的Java基础，熟悉Spring Boot、MyBatis等框架\n3. 熟悉MySQL、Redis，了解消息队列\n4. 了解分布式系统原理，有微服务经验加分\n\n【招聘流程】\n简历筛选→笔试→技术面试→HR面试→Offer\n\n【投递链接】https://campus.jd.com\n职位编号：JD2026-TECH-001\n\n京东校园招聘\n2026年3月15日', 1, 0, NOW()),

('【讲座预告】面试技巧提升：从简历到Offer的通关秘籍', '各位同学：\n\n如何在面试中脱颖而出？如何应对压力面试？就业服务中心特邀某500强企业资深HR总监张老师，为大家分享面试技巧与注意事项。\n\n【讲座主题】面试技巧提升：从简历到Offer的通关秘籍\n【主讲人】张敏，某世界500强企业人力资源总监，15年招聘经验\n【时间】2026年3月19日（周日）14:30-16:30\n【地点】图书馆报告厅\n【面向对象】全体在校学生\n\n【讲座内容】\n1. 面试前的准备清单\n2. 自我介绍的艺术（1分钟、3分钟版本）\n3. 行为面试法（STAR法则）实战应用\n4. 技术面试与HR面试的区别应对\n5. 薪资谈判技巧\n6. 面试礼仪与禁忌\n\n【互动环节】现场模拟面试，主讲人点评指导\n\n【报名方式】就业服务平台→讲座报名，限200人\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【重要提醒】2026届毕业生就业去向统计问卷填写通知', '各位2026届毕业生：\n\n为准确掌握毕业生就业情况，做好就业服务与统计工作，请全体2026届毕业生于3月25日前完成就业去向统计问卷填写。\n\n【填写对象】全体2026届本科、硕士、博士毕业生\n【填写时间】即日起至2026年3月25日24:00\n【填写方式】登录就业服务平台→"就业调查"模块→填写问卷\n\n【问卷内容】\n- 当前就业状态（已签约、已录用、考研、出国、创业、求职中等）\n- 就业单位信息（如有）\n- 期望薪资与行业\n- 求职困难与需求\n\n【重要说明】\n1. 问卷数据仅用于统计分析，严格保密\n2. 未按时填写将影响就业推荐表及报到证办理\n3. 就业状态如有变化，请及时更新\n\n【咨询电话】010-12345678（就业数据管理办公室）\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【专场招聘】"互联网+"行业专场招聘会·40家名企', '各位同学：\n\n"互联网+"行业专场招聘会即将举办，40家知名互联网企业携300+优质岗位等你来！\n\n【时间】2026年3月22日（周三）13:30-17:00\n【地点】学生活动中心一楼大厅\n【参会企业】字节跳动、美团、快手、小红书、哔哩哔哩、蔚来汽车、小鹏汽车等40家\n\n【岗位亮点】\n• 技术类：前端、后端、算法、测试、运维（占比60%）\n• 产品类：产品经理、产品运营、数据分析（占比25%）\n• 设计类：UI设计、交互设计、视觉设计（占比10%）\n• 职能类：HR、行政、财务（占比5%）\n\n【薪资水平】\n技术岗：年薪25-50万\n产品岗：年薪20-40万\n设计岗：年薪18-35万\n\n【参会福利】\n前100名签到同学可获得求职大礼包（包含简历模板、面试指南、企业内推码）\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【宣讲会】字节跳动2026届校招宣讲会·3月24日', '各位同学：\n\n字节跳动将于下周举办2026届校园招聘宣讲会，抖音、今日头条、飞书等业务线HR及技术负责人将现场分享。\n\n【时间】2026年3月24日（周五）18:30-20:30\n【地点】大礼堂\n【面向群体】2026届毕业生及优秀在校生\n【招聘规模】计划招聘2000+实习生及应届生\n\n【业务线介绍】\n- 抖音：短视频内容推荐算法、直播技术\n- 飞书：企业协作平台研发\n- 朝夕光年：游戏研发与发行\n- ByteDance Research：AI大模型研究\n\n【岗位类型】\n研发、产品、设计、运营、销售、职能六大类\n\n【特殊福利】\n• 扁平化管理，技术氛围浓厚\n• 免费三餐，下午茶，健身房\n• 租房补贴，就近房补1500元/月\n\n【笔试安排】3月27日统一在线笔试\n\n字节跳动校园招聘组\n2026年3月15日', 1, 0, NOW()),

('【功能上新】就业服务平台"岗位收藏"功能正式上线', '各位同学：\n\n为方便同学们管理心仪的求职岗位，就业服务平台正式上线"岗位收藏"功能！\n\n【功能介绍】\n✓ 一键收藏感兴趣岗位，建立个人求职清单\n✓ 收藏岗位状态实时提醒（即将截止、已停止招聘）\n✓ 支持分类管理（按行业、地域、岗位类型）\n✓ 收藏岗位对比分析（薪资、要求、发展前景）\n\n【使用指南】\n1. 浏览岗位详情页，点击"☆收藏"按钮\n2. 进入"我的收藏"查看管理\n3. 设置提醒，不错过投递时机\n\n【温馨提示】\n收藏≠投递，请及时关注岗位截止日期，尽早投递简历。\n\n【反馈渠道】\n使用过程中如有问题，请联系平台技术支持：tech@career.edu.cn\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【培训报名】职场礼仪与沟通技巧专题培训', '各位同学：\n\n良好的职业形象与沟通能力是求职成功的关键。就业服务中心特举办职场礼仪与沟通技巧培训，帮助同学们提升职业素养。\n\n【培训时间】2026年3月23日（周四）14:00-17:00\n【培训地点】就业指导中心团体辅导室\n【培训师】李婷，国际注册礼仪培训师，10年企业培训经验\n【限额】40人（小班教学，确保互动效果）\n\n【培训内容】\n模块一：职业形象塑造（14:00-15:00）\n- 商务着装规范与搭配技巧\n- 仪容仪表管理\n- 职业体态与肢体语言\n\n模块二：商务沟通技巧（15:00-16:00）\n- 有效倾听与表达\n- 邮件与微信沟通礼仪\n- 会议沟通技巧\n\n模块三：模拟演练（16:00-17:00）\n- 商务场景角色扮演\n- 专家点评与指导\n\n【报名方式】就业服务平台→培训报名，报名截止3月21日\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】华为2026届实习生招聘全面启动', '各位同学：\n\n华为2026届实习生招聘正式启动！六大业务线联合招聘，提供实习岗位500+，转正率高达70%。\n\n【招聘部门】\n- 终端BG：手机、平板、穿戴设备研发\n- 云计算：云原生、AI、大数据\n- 数字能源：智能光伏、数据中心能源\n- 海思半导体：芯片设计与验证\n- 2012实验室：前沿技术研究\n- 运营商BG：5G网络解决方案\n\n【岗位类别】\n研发类、销售类、服务类、供应链类、财经类、法务类\n\n【实习地点】\n深圳、东莞、北京、上海、杭州、成都、西安、南京、武汉\n\n【实习福利】\n• 实习薪资：本科300元/天，硕士350元/天，博士400元/天\n• 异地实习房补：1000-2000元/月\n• 商业保险、免费加班餐、班车接送\n• 转正机会：实习表现优秀者可直接获得校招Offer\n\n【招聘流程】\n简历投递→机考→综合测评→技术面试→业务主管面试→录用\n\n【投递官网】career.huawei.com\n【截止时间】2026年4月30日\n\n华为招聘团队\n2026年3月15日', 1, 0, NOW()),

('【搬迁公告】就业服务中心迁至新行政楼302室', '各位师生：\n\n因学校整体规划调整，就业服务中心将于下周搬迁至新址，现将有关事项通知如下：\n\n【新地址】新行政楼302室（原图书馆北侧新楼）\n【搬迁时间】2026年3月18日-3月19日\n【暂停服务时间】3月18日全天\n\n【新场地设施】\n- 咨询服务区：5个服务窗口\n- 面试间：3间标准化视频面试室（可预约）\n- 团体辅导室：可容纳50人\n- 自助服务区：简历打印、证件照拍摄、资料查询\n\n【交通指引】\n- 校内巴士：乘坐1号线至"行政楼站"\n- 步行：从图书馆北门步行约3分钟\n- 停车：新行政楼地下停车场B2层\n\n【咨询电话】010-12345678（搬迁期间正常接听）\n\n因搬迁给您带来不便，敬请谅解。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【公开课】职业规划：从迷茫到清晰的探索之路', '各位同学：\n\n你是否对未来职业方向感到迷茫？不知道如何发挥专业优势？就业服务中心特邀职业规划专家王老师，带你探索职业发展的可能性。\n\n【课程主题】职业规划：从迷茫到清晰的探索之路\n【主讲人】王建国，GCDF全球职业规划师，15年高校就业指导经验\n【时间】2026年3月20日（周一）19:00-21:00\n【地点】教学楼A101\n【面向对象】大一至大三学生（建议尽早规划）\n\n【课程大纲】\n1. 自我认知：兴趣、能力、价值观探索\n2. 职业世界认知：行业趋势与岗位分析\n3. 职业决策：目标设定与路径选择\n4. 行动计划：从规划到执行的落地方法\n\n【特色环节】\n- 霍兰德职业兴趣测试现场解读\n- 校友职业发展案例分享\n- 个人职业规划书撰写指导\n\n【报名方式】就业服务平台→讲座报名，限150人\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】网易游戏2026届实习生招聘启动', '各位同学：\n\n网易游戏2026届实习生招聘正式启动！雷火、互娱两大事业群联合招聘，邀你一起创造游戏梦想。\n\n【招聘事业群】\n- 网易雷火：逆水寒、永劫无间、倩女幽魂等\n- 网易互娱：梦幻西游、阴阳师、第五人格等\n\n【开放岗位】\n【技术类】\n- 游戏客户端开发（Unity/Unreal）\n- 游戏服务端开发（Java/C++）\n- 游戏测试工程师\n- 技术美术（TA）\n\n【策划类】\n- 系统策划、数值策划、文案策划\n- 关卡策划、战斗策划\n\n【美术类】\n- 原画设计师、3D模型师、动作设计师\n- 特效设计师、UI设计师\n\n【实习地点】杭州、广州\n【实习福利】\n• 薪资：300-500元/天\n• 免费三餐，下午茶，零食饮料不限量\n• 健身房、游戏室、睡眠舱\n• 转正率超60%，提前锁定校招Offer\n\n【投递方式】game.163.com/campus\n【截止时间】2026年4月20日\n\n网易游戏招聘组\n2026年3月15日', 1, 0, NOW()),

('【功能上新】就业平台"企业评价"功能上线，匿名评价保障权益', '各位同学：\n\n为帮助同学们更全面了解实习企业，就业服务平台正式上线"企业评价"功能，支持对实习企业进行匿名评价。\n\n【功能说明】\n✓ 匿名评价：保护个人隐私，畅所欲言\n✓ 多维度评分：薪资福利、工作环境、培养体系、转正机会等\n✓ 真实反馈：仅验证过实习经历的同学可评价\n✓ 企业回复：企业可对评价进行回应\n\n【评价维度】\n1. 薪资待遇（是否按时发放、是否有拖欠）\n2. 工作环境（办公条件、团队氛围）\n3. 培养体系（是否有导师、培训机会）\n4. 工作强度（加班情况、压力水平）\n5. 转正机会（转正比例、转正薪资）\n6. 综合评价与建议\n\n【使用方式】\n登录平台→企业详情页→"企业评价"标签→撰写评价\n\n【温馨提示】\n请基于真实经历客观评价，禁止恶意诋毁或虚假宣传。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【专场招聘】智能制造行业专场招聘会·50家企业', '各位同学：\n\n"智造未来"智能制造行业专场招聘会即将举办，50家制造业龙头企业提供岗位800+，涵盖研发、生产、管理等多类岗位。\n\n【时间】2026年3月25日（周二）09:00-15:00\n【地点】工程训练中心一楼展厅\n【参会企业】\n- 汽车制造：比亚迪、蔚来、理想、小鹏、吉利\n- 电子制造：富士康、立讯精密、歌尔股份\n- 装备制造：三一重工、中联重科、徐工集团\n- 家电制造：美的、格力、海尔\n- 工业自动化：汇川技术、大族激光\n\n【岗位类型】\n机械工程师、电气工程师、自动化工程师、质量工程师、生产管理、供应链管理\n\n【薪资水平】\n本科：年薪12-20万\n硕士：年薪18-30万\n博士：年薪30-50万\n\n【特色服务】\n现场设置简历诊断区、面试技巧咨询区\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【宣讲会】小米集团2026届校招宣讲会·3月18日', '各位同学：\n\n小米集团2026届校园招聘宣讲会将于本周举办，手机部、汽车部、AI实验室等多个部门现场招聘。\n\n【时间】2026年3月18日（周六）14:00-16:00\n【地点】科技馆报告厅\n【面向对象】2026届毕业生\n\n【招聘部门】\n- 手机部：MIUI系统、影像技术、硬件研发\n- 汽车部：自动驾驶、智能座舱、三电系统\n- AI实验室：大模型、语音交互、计算机视觉\n- 互联网业务部：电商、金融、互联网服务\n- 生态链部：IoT产品研发\n\n【岗位类型】\n软件研发、硬件研发、产品经理、设计、运营、职能\n\n【工作地点】\n北京、上海、深圳、武汉、南京、西安\n\n【薪资福利】\n• 有竞争力的薪资+股权激励\n• 补充医疗保险、年度体检\n• 健身房、图书馆、员工餐厅\n• 12天带薪年假\n\n【内推码】XIAOMI2026（投递时填写优先筛选）\n\n小米招聘团队\n2026年3月15日', 1, 0, NOW()),

('【放假通知】就业服务中心2026年劳动节放假安排', '各位师生：\n\n根据学校《关于2026年劳动节放假安排的通知》，就业服务中心放假安排如下：\n\n【放假时间】\n2026年5月1日（周五）至5月5日（周二），共5天\n4月26日（周日）、5月9日（周六）正常上班\n\n【服务调整】\n- 线下服务：放假期间暂停\n- 线上服务：就业服务平台正常使用\n- 紧急事务：5月3日-4日安排电话值班，010-12345678\n\n【业务办理提示】\n1. 就业协议盖章：请于4月30日前或5月6日后办理\n2. 档案查询：放假期间暂停，5月6日恢复\n3. 招聘会安排：5月1日-5日无现场招聘活动\n\n【温馨提示】\n请同学们提前安排好就业相关事务，避免影响求职进度。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【工作坊】求职邮件写作：让你的邮件被HR看见', '各位同学：\n\n求职邮件是求职的"敲门砖"，一封专业的邮件能让你脱颖而出。就业服务中心特举办求职邮件写作工作坊。\n\n【主题】求职邮件写作：从标题到落款的全流程指南\n【时间】2026年3月21日（周二）15:00-17:00\n【地点】就业指导中心多媒体教室\n【主讲人】陈静，某知名互联网公司HRBP\n【限额】30人（小班教学，含实操练习）\n\n【内容大纲】\n1. 邮件礼仪基础\n   - 邮箱选择与签名设置\n   - 邮件格式规范\n\n2. 邮件标题撰写技巧\n   - 投递简历：姓名-学校-岗位-到岗时间\n   - 咨询问题：简洁明了，突出关键\n\n3. 正文撰写要点\n   - 自我介绍：3句话说明来意\n   - 求职动机：为什么选这个岗位\n   - 附件处理：简历命名、文件格式\n\n4. 常见错误案例分析\n   - 邮件过于随意\n   - 附件过大或格式错误\n   - 群发邮件未隐藏收件人\n\n【实操环节】现场撰写邮件，讲师点评修改\n\n【报名方式】就业服务平台→工作坊报名\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】OPPO 2026届软件研发实习生招聘', '各位同学：\n\nOPPO 2026届软件研发实习生招聘正式启动！ColorOS、影像、AI等多个技术团队等你来加入。\n\n【岗位名称】软件研发实习生\n【工作地点】深圳、东莞、成都、西安、南京\n【实习时长】3个月及以上，优先6个月\n\n【招聘方向】\n- 系统开发：Android系统优化、ColorOS功能开发\n- 影像技术：相机算法、图像处理\n- AI技术：语音助手、智能推荐、大模型应用\n- 性能优化：系统流畅度、功耗优化\n- 安全隐私：数据安全、隐私保护技术\n\n【岗位要求】\n1. 2026届本科及以上学历，计算机、软件、电子等相关专业\n2. 扎实的编程基础，熟悉Java/C++/Python至少一种\n3. 对移动技术有热情，关注行业动态\n4. 有实际项目经验或开源贡献优先\n\n【实习福利】\n• 薪资：本科280元/天，硕士350元/天，博士450元/天\n• 房补：异地实习生1500元/月\n• 餐饮：免费三餐+下午茶\n• 转正：实习表现优秀者直通校招终面\n\n【投递方式】oppo.com/campus\n【截止时间】2026年4月30日\n\nOPPO招聘团队\n2026年3月15日', 1, 0, NOW()),

('【智能升级】就业平台AI岗位推荐功能上线', '各位同学：\n\n为提升岗位匹配效率，就业服务平台正式升级AI智能推荐系统，基于你的浏览记录和简历信息，为你精准推荐合适岗位。\n\n【核心功能】\n🤖 智能匹配\n- 分析你的专业、技能、求职意向\n- 匹配度评分，优先展示高匹配岗位\n\n📊 个性化推荐\n- 基于浏览记录学习你的偏好\n- 推荐"你可能感兴趣的岗位"\n- 相似岗位智能联想\n\n🔔 智能提醒\n- 新上线匹配岗位即时推送\n- 收藏岗位状态变更提醒\n- 投递进度实时跟踪\n\n📈 求职分析\n- 个人求职竞争力分析\n- 同专业同学投递趋势\n- 岗位热度与竞争程度提示\n\n【隐私保护】\nAI分析仅在本地进行，不上传个人敏感信息。\n\n【使用方式】\n登录平台→首页"为你推荐"栏目→完善简历提升匹配度\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【专场招聘】金融科技行业专场招聘会', '各位同学：\n\n"数智金融"金融科技行业专场招聘会即将举办，银行、证券、保险、金融科技公司等30+企业提供岗位500+。\n\n【时间】2026年3月28日（周五）13:30-17:00\n【地点】经济管理学院一楼大厅\n【参会单位】\n【银行】工商银行、招商银行、平安银行、微众银行\n【证券】中信证券、华泰证券、国泰君安、东方财富\n【保险】中国平安、中国人寿、太平洋保险\n【金融科技】蚂蚁集团、陆金所、京东数科、度小满\n\n【岗位类型】\n- 技术类：金融科技工程师、数据分析师、算法工程师\n- 业务类：投行分析师、行业研究员、理财经理\n- 职能类：风险管理、合规、财务、HR\n\n【专业要求】\n金融、经济、会计、统计、计算机、数学等相关专业\n\n【薪资参考】\n技术岗：年薪25-45万\n业务岗：年薪20-40万+业绩奖金\n\n【特别提示】部分岗位需证券/基金从业资格证\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【技术专场】百度2026届技术岗宣讲会·3月26日', '各位同学：\n\n百度将于3月26日举办技术专场宣讲会，搜索、AI、自动驾驶等核心技术团队现场分享。\n\n【时间】2026年3月26日（周四）19:00-21:00\n【地点】计算机学院报告厅\n【面向对象】计算机、人工智能、软件工程等相关专业学生\n\n【招聘部门】\n- 搜索技术部：大搜索、知识图谱、推荐系统\n- AI技术部：文心大模型、飞桨、智能语音\n- 自动驾驶部：Apollo自动驾驶系统\n- 智能云：企业级AI解决方案\n- 移动生态：百度App、贴吧、知道\n\n【岗位类型】\n机器学习工程师、深度学习工程师、NLP工程师、计算机视觉工程师、后端开发工程师\n\n【薪资福利】\n• 技术岗年薪：30-60万（SP offer可达80万）\n• 签字费、股票期权\n• 北京户口指标\n• 免费三餐，健身房，年度体检\n\n【笔试安排】3月29日在线笔试\n【面试流程】3-4轮技术面试+1轮HR面试\n\n【内推码】BD2026TECH（简历优先处理）\n\n百度校园招聘\n2026年3月15日', 1, 0, NOW()),

('【讲座】技术面试通关攻略：算法与项目经验', '计算机学院同学：\n\n技术面试是互联网大厂求职的关键环节。就业服务中心特邀资深技术面试官，为你揭秘技术面试的考察重点。\n\n【主题】技术面试通关攻略：算法与项目经验\n【主讲人】刘强，前阿里巴巴技术专家，10年面试官经验\n【时间】2026年3月24日（周三）19:00-21:00\n【地点】软件学院报告厅\n【面向对象】意向互联网/科技公司技术岗的同学\n\n【讲座内容】\n一、算法面试（60分钟）\n- 常考算法题型：数组、链表、树、图、动态规划\n- 刷题策略：从LeetCode到真题\n- 面试中的算法题解思路\n- 手写代码规范与注意事项\n\n二、项目经验面试（40分钟）\n- 如何选择项目：复杂度与匹配度\n- 项目描述：STAR法则应用\n- 技术深度挖掘：原理、优化、难点\n- 场景设计题：系统设计基础\n\n三、互动答疑（20分钟）\n- 现场解答技术面试疑惑\n\n【准备建议】\n建议提前刷10道LeetCode中等难度题目，带着问题来听讲。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】快手2026届前端实习生招募', '各位同学：\n\n快手前端团队开放2026届实习生招聘，主站、直播、电商等业务线等你来！\n\n【岗位名称】前端开发实习生\n【业务线】主站、直播、电商、本地生活、海外\n【工作地点】北京、杭州、深圳\n【实习时长】3个月起，优先6个月\n\n【岗位职责】\n1. 参与快手App及Web端功能开发\n2. 参与前端性能优化，提升用户体验\n3. 参与前端工程化建设，提升开发效率\n4. 参与新技术调研与落地\n\n【技术要求】\n1. 扎实的HTML/CSS/JavaScript基础\n2. 熟悉React或Vue框架，了解原理\n3. 了解前端工程化工具（Webpack/Vite）\n4. 对性能优化、跨端开发有了解加分\n\n【实习福利】\n• 薪资：350-450元/天\n• 房补：北京1500元/月，杭州/深圳1000元/月\n• 免费三餐，下午茶，零食饮料\n• 健身房、按摩室、睡眠舱\n• 转正机会：实习满3个月可参与转正答辩\n\n【投递方式】kuaishou.com/campus\n职位ID：FE-2026-001\n\n快手招聘团队\n2026年3月15日', 1, 0, NOW()),

('【值班安排】就业服务中心周末值班服务', '各位同学：\n\n为方便同学们办理就业事务，本周末就业服务中心将安排老师值班，提供简历修改与就业咨询服务。\n\n【值班时间】\n3月18日（周六）09:00-12:00，14:00-17:00\n3月19日（周日）09:00-12:00，14:00-17:00\n\n【值班地点】就业服务中心咨询室（学生活动中心301）\n\n【服务内容】\n✓ 简历诊断与修改建议\n✓ 求职咨询与规划指导\n✓ 就业政策解答\n✓ 就业协议、推荐表等事务咨询\n\n【预约方式】\n为保证服务质量，建议提前在就业服务平台预约时段，每小时限3人。\n未预约同学可现场排队，视情况安排。\n\n【温馨提示】\n- 请携带纸质简历或笔记本电脑\n- 周末不提供盖章服务，请工作日办理\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【政策解读】2026年最新就业政策与补贴指南', '各位2026届毕业生：\n\n为帮助大家了解最新就业政策，就业服务中心特举办就业政策解读讲座，详解各类就业补贴与优惠政策。\n\n【主题】2026年最新就业政策与补贴指南\n【时间】2026年3月27日（周一）14:30-16:30\n【地点】图书馆报告厅\n【主讲人】赵敏，就业指导中心政策研究办公室主任\n【面向对象】2026届毕业生\n\n【政策内容】\n一、国家层面政策\n- 应届生身份认定与保护\n- 基层就业项目（三支一扶、西部计划、特岗教师）\n- 大学生征兵入伍政策\n- 创业扶持政策\n\n二、地方就业补贴\n- 求职创业补贴（1000-3000元/人）\n- 就业见习补贴\n- 灵活就业社保补贴\n- 新引进人才生活补贴\n\n三、学校就业支持\n- 困难毕业生帮扶政策\n- 就业推荐与重点推荐\n- 违约与改派流程\n\n【申请指南】\n现场发放《2026届毕业生就业政策手册》，详解申请流程与材料准备。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】携程集团2026届技术实习生招聘', '各位同学：\n\n携程集团2026届技术实习生招聘启动！酒店、机票、旅游度假等业务线技术团队等你来。\n\n【岗位名称】Java开发/前端开发/测试开发实习生\n【工作地点】上海、扬州、南通\n【实习时长】3个月及以上\n\n【业务线介绍】\n- 住宿事业部：酒店预订系统、民宿平台\n- 交通事业部：机票、火车票、用车系统\n- 旅游事业部：跟团游、自由行、签证系统\n- 商旅事业部：企业差旅管理系统\n\n【岗位要求】\n【Java开发】\n- 扎实的Java基础，熟悉Spring Boot\n- 熟悉MySQL、Redis、消息队列\n- 了解微服务架构\n\n【前端开发】\n- 熟悉HTML/CSS/JavaScript\n- 熟悉React或Vue\n- 了解前端性能优化\n\n【测试开发】\n- 熟悉测试理论与方法\n- 掌握Python/Java至少一种\n- 了解自动化测试框架\n\n【实习福利】\n• 薪资：300-400元/天\n• 异地房补：上海1500元/月，扬州/南通800元/月\n• 免费三餐，年度体检\n• 旅游福利：每年2次免费旅游机会\n• 转正机会：实习优秀者直通校招Offer\n\n【投递方式】trip.com/campus\n【截止时间】2026年4月25日\n\n携程招聘团队\n2026年3月15日', 1, 0, NOW()),

('【功能上新】就业平台"投递状态提醒"功能上线', '各位同学：\n\n为帮助同学们及时掌握求职进度，就业服务平台正式上线"投递状态提醒"功能。\n\n【功能亮点】\n📱 多渠道提醒\n- 站内消息实时推送\n- 邮件通知（支持设置提醒频率）\n- 短信提醒（重要节点）\n- 微信服务号绑定提醒\n\n📊 状态跟踪\n- 简历投递：已投递→已查看→初筛通过→面试安排→Offer发放\n- 每个状态变更即时提醒\n- 超过7天未处理自动提醒HR\n\n⏰ 智能提醒\n- 笔试/面试前24小时、2小时双重提醒\n- 材料提交截止前提醒\n-  Offer确认截止提醒\n\n📈 投递统计\n- 个人投递数据统计（投递数、回复率、面试率）\n- 同专业同学投递趋势对比\n- 求职效率分析报告\n\n【设置方式】\n登录平台→"我的投递"→"提醒设置"→选择提醒方式与频率\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【专场招聘】校企合作专场招聘会·优质岗位推荐', '各位同学：\n\n"校企联动·共创未来"校企合作专场招聘会即将举办，20家深度合作企业提供定向培养岗位300+。\n\n【时间】2026年3月29日（周三）09:00-15:00\n【地点】就业服务中心招聘大厅\n【参会企业】\n- 战略合作企业：华为、腾讯、阿里巴巴、字节跳动\n- 实习基地企业：中国移动、中国电信、中国银行、工商银行\n- 校友企业：滴滴出行、商汤科技、旷视科技、寒武纪\n\n【岗位特色】\n✓ 定向培养：入职后配备企业导师+学校导师双导师\n✓ 实习衔接：可提前入职实习，计入试用期\n✓ 优先录用：合作企业简历优先筛选\n✓ 联合培养：部分岗位支持在职攻读企业合作硕士\n\n【招聘流程】\n现场投递→企业初筛→学校推荐→企业终面→录用\n\n【准备材料】\n- 简历2份（标注"校企合作专场"）\n- 成绩单\n- 相关证书复印件\n- 就业推荐表（如有）\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【宣讲会】美的集团2026届校招宣讲会·3月30日', '各位同学：\n\n美的集团2026届校园招聘宣讲会将于3月30日举办，智能家居、工业技术、楼宇科技等多个事业部现场招聘。\n\n【时间】2026年3月30日（周四）14:00-16:00\n【地点】A2报告厅\n【面向对象】2026届本科、硕士、博士毕业生\n\n【招聘事业部】\n- 智能家居事业群：家用空调、冰箱、洗衣机、小家电\n- 工业技术事业群：压缩机、电机、芯片、散热模块\n- 楼宇科技事业部：中央空调、电梯、楼宇控制\n- 机器人与自动化：库卡机器人、瑞仕格物流\n- 创新型业务：美云智数（工业互联网）、安得智联（供应链）\n\n【岗位类型】\n研发技术类、信息技术类、制造技术类、国内营销类、海外营销类、供应链物流类、财务金融类、行政管理类\n\n【薪资福利】\n• 本科：年薪15-25万\n• 硕士：年薪20-35万\n• 博士：年薪35-50万+科研启动金\n• 员工宿舍/房补、免费工作餐、年度体检\n• 股权激励计划\n\n【内推码】MIDEA2026\n\n美的集团招聘组\n2026年3月15日', 1, 0, NOW()),

('【工作坊】无领导小组讨论（群面）通关技巧', '各位同学：\n\n群面（无领导小组讨论）是众多企业采用的面试形式，如何在群面中脱颖而出？就业服务中心特举办专题工作坊。\n\n【主题】无领导小组讨论通关技巧\n【时间】2026年3月28日（周二）18:30-21:00\n【地点】就业指导中心团体辅导室\n【主讲人】王芳，某咨询公司高级顾问，8年面试官经验\n【限额】24人（模拟演练需要，小班教学）\n\n【工作坊流程】\n18:30-19:00 群面理论讲解\n- 群面流程与评分标准\n- 角色分析：领导者、时间控制者、记录者、建议者\n- 常见题型：排序题、案例分析题、创意题\n\n19:00-20:00 模拟群面（第一轮）\n- 12人一组实战演练\n- 讲师现场观察记录\n\n20:00-20:30 点评与反馈\n- 逐一点评每位同学表现\n- 指出问题与改进方向\n\n20:30-21:00 技巧总结与Q&A\n\n【报名方式】\n就业服务平台→工作坊报名，需缴纳押金20元（到场退还）\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】BOSS直聘2026届实习生招聘', '各位同学：\n\nBOSS直聘2026届实习生招聘启动！产品、运营、技术等多岗位开放，直聘模式让求职更高效。\n\n【开放岗位】\n【产品类】\n- 产品经理实习生（C端/B端）\n- 用户研究实习生\n- 数据产品实习生\n\n【运营类】\n- 内容运营实习生\n- 用户运营实习生\n- 商业运营实习生\n\n【技术类】\n- 前端开发实习生（React方向）\n- Java开发实习生\n- 算法实习生（推荐算法）\n\n【工作地点】北京朝阳区太阳宫\n【实习时长】4个月及以上，每周至少4天\n\n【岗位要求】\n1. 2026届本科及以上学历\n2. 对产品/运营/技术有热情，有相关实习经验优先\n3. 数据敏感，逻辑思维强\n4. 沟通能力强，抗压能力强\n\n【实习福利】\n• 薪资：300-400元/天\n• 免费三餐，下午茶，零食饮料\n• 健身房，年度体检\n• 扁平化管理，与CEO面对面交流机会\n• 转正机会：实习满4个月可参与转正答辩\n\n【投递方式】\n登录BOSS直聘App→搜索"BOSS直聘实习生"→投递简历\n或直接发送简历至：campus@kanzhun.com\n\nBOSS直聘招聘组\n2026年3月15日', 1, 0, NOW()),

('【临时闭馆】就业服务中心3月16日闭馆一天', '各位师生：\n\n因中心设备进行紧急检修升级，就业服务中心将于明日（3月16日）临时闭馆一天。\n\n【闭馆时间】2026年3月16日（周四）全天\n【闭馆范围】就业服务大厅、咨询室、面试间、档案室\n\n【业务调整】\n- 线下咨询：暂停，建议通过就业服务平台在线咨询\n- 就业协议盖章：请延后至3月17日办理\n- 档案查询：3月17日恢复\n- 招聘会场地：3月16日暂停使用\n\n【紧急联系方式】\n如有紧急事务，请联系：\n- 就业管理：张老师 138-xxxx-xxxx\n- 档案查询：李老师 139-xxxx-xxxx\n- 技术支持：tech@career.edu.cn\n\n【恢复时间】2026年3月17日（周五）起正常开放\n\n给您带来不便，敬请谅解。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【心理讲座】求职压力管理与心理调适', '各位同学：\n\n求职季压力大、焦虑多？就业服务中心联合心理健康教育中心，特举办求职心理调适讲座，帮助你缓解求职压力。\n\n【主题】求职压力管理与心理调适\n【时间】2026年3月31日（周五）15:00-17:00\n【地点】心理健康教育中心团体辅导室\n【主讲人】刘芳，注册心理师，心理健康教育中心主任\n【面向对象】正在求职或即将求职的同学\n\n【讲座内容】\n一、求职压力识别（30分钟）\n- 求职焦虑的表现与成因\n- 压力与动力的平衡\n- 常见认知误区\n\n二、压力管理技巧（40分钟）\n- 认知重构：改变不合理信念\n- 情绪调节：正念减压技巧\n- 行为激活：制定可行计划\n- 社会支持：寻求帮助的资源\n\n三、现场体验（40分钟）\n- 渐进式肌肉放松训练\n- 正念呼吸练习\n- 团体支持活动\n\n四、答疑与咨询预约（20分钟）\n\n【温馨提示】\n建议穿着舒适服装，便于参与放松练习。\n\n【报名方式】就业服务平台→讲座报名，限30人\n\n就业服务中心 & 心理健康教育中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】顺丰科技2026届技术实习生招聘', '各位同学：\n\n顺丰科技2026届实习生招聘启动！物流科技、供应链科技、金融科技三大方向等你来。\n\n【岗位名称】Java开发/前端开发/算法/测试实习生\n【工作地点】深圳、武汉、杭州\n【实习时长】3个月及以上，优先6个月\n\n【业务方向】\n- 智慧物流：路径优化、智能调度、无人配送\n- 供应链科技：仓储管理、库存优化、需求预测\n- 金融科技：支付系统、供应链金融、风控系统\n- 大数据：物流大数据平台、实时计算、数据仓库\n\n【岗位要求】\n【Java开发】\n- 扎实的Java基础，熟悉Spring Cloud\n- 熟悉分布式系统设计与开发\n- 有高并发系统经验加分\n\n【算法工程师】\n- 计算机、数学、统计等相关专业\n- 熟悉机器学习算法，有实际项目经验\n- 熟悉Python，了解TensorFlow/PyTorch\n\n【实习福利】\n• 薪资：本科300元/天，硕士380元/天，博士480元/天\n• 异地房补：深圳1500元/月，武汉/杭州1000元/月\n• 免费三餐，健身房，年度体检\n• 物流行业顶级技术团队指导\n• 转正率超70%，提前锁定校招Offer\n\n【投递方式】sf-tech.com/campus\n【截止时间】2026年4月30日\n\n顺丰科技招聘组\n2026年3月15日', 1, 0, NOW()),

('【风险提示】就业平台"企业风险提醒"功能上线', '各位同学：\n\n为保护同学们的求职权益，就业服务平台正式上线"企业风险提醒"功能，对存在风险的企业进行提示。\n\n【风险提示类型】\n⚠️ 经营异常\n- 被列入经营异常名录\n- 近期有大量劳动仲裁记录\n- 存在严重失信行为\n\n⚠️ 求职风险\n- 收取费用（培训费、押金、服装费等）\n- 薪资承诺与实际不符投诉较多\n- 实习/试用期过长且无明确转正标准\n\n⚠️ 信息虚假\n- 招聘信息与实际情况严重不符\n- 冒用其他企业名义招聘\n- 岗位描述夸大或模糊\n\n【提示方式】\n- 企业详情页红色风险提示标签\n- 投递前弹窗提醒\n- 高风险企业限制发布岗位\n\n【投诉举报】\n如发现企业存在违规行为，可通过平台"举报"功能反馈，我们将及时核实处理。\n\n【温馨提示】\n求职过程中请提高警惕，切勿缴纳任何费用，保留好相关证据。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【暑期实习】2026年暑期实习专场招聘会', '各位同学：\n\n"暑期实习·提前起跑"2026年暑期实习专场招聘会即将举办，50家企业提供500+暑期实习岗位。\n\n【时间】2026年4月5日（周六）09:00-16:00\n【地点】体育馆主馆\n【参会企业】\n互联网：字节跳动、美团、快手、小红书、哔哩哔哩\n金融：中金公司、中信证券、招商银行、平安银行\n制造：华为、大疆、比亚迪、蔚来、理想\n咨询：麦肯锡、BCG、贝恩、四大\n快消：宝洁、联合利华、欧莱雅、雀巢\n\n【岗位特点】\n✓ 转正机会：80%岗位提供转正机会\n✓ 实习时长：2-3个月，暑期集中实习\n✓ 面向对象：2026届毕业生（2026年9月-2027年8月毕业）\n\n【准备建议】\n1. 提前准备简历，突出项目经验\n2. 了解目标企业及岗位\n3. 准备自我介绍（1分钟版本）\n4. 携带成绩单、证书复印件\n\n【报名方式】\n就业服务平台预约参会，领取电子票\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【宣讲会】海康威视2026届校招宣讲会·4月2日', '各位同学：\n\n海康威视2026届校园招聘宣讲会将于4月2日举办，研究院、国内业务中心、国际业务中心等多部门现场招聘。\n\n【时间】2026年4月2日（周五）14:00-16:00\n【地点】科技馆报告厅\n【面向对象】2026届本科、硕士、博士毕业生\n\n【招聘部门】\n- 中央研究院：AI算法、集成电路、先进传感\n- 国内业务中心：解决方案、技术支持、销售\n- 国际业务中心：海外销售、技术支持\n- 智能制造部：自动化设备、工业机器人\n- 汽车电子：车载视觉、自动驾驶\n\n【岗位类型】\n算法类、软件类、硬件类、营销类、供应链类、职能类\n\n【工作地点】\n杭州、武汉、西安、成都、上海、北京、深圳及海外\n\n【薪资福利】\n• 算法岗：年薪35-60万\n• 软件/硬件岗：年薪25-45万\n• 营销岗：年薪20-35万+提成\n• 杭州人才补贴：硕士3万，博士10万\n• 股权激励、员工宿舍、免费三餐\n\n【内推码】HIK2026\n\n海康威视招聘组\n2026年3月15日', 1, 0, NOW()),

('【工作坊】项目经历描述技巧：让简历更有说服力', '各位同学：\n\n项目经历是技术岗简历的核心，如何写出有说服力的项目描述？就业服务中心特举办专题工作坊。\n\n【主题】项目经历描述技巧：STAR法则与量化表达\n【时间】2026年4月3日（周六）14:00-17:00\n【地点】就业指导中心多媒体教室\n【主讲人】张明，某互联网公司技术总监，阅简历5000+\n【限额】30人（含一对一简历指导）\n\n【工作坊内容】\n14:00-15:00 项目描述方法论\n- STAR法则详解（情境-任务-行动-结果）\n- 量化表达技巧（数据说话）\n- 技术深度与广度的平衡\n\n15:00-16:00 优秀案例分析\n- 分析5个优秀项目描述案例\n- 对比修改前后效果\n- 不同岗位的项目侧重\n\n16:00-17:00 一对一指导\n- 携带简历现场修改\n- 讲师针对性建议\n- 同学互评交流\n\n【准备材料】\n请携带打印版简历或笔记本电脑。\n\n【报名方式】就业服务平台→工作坊报名\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】用友网络2026届前端实习生招聘', '各位同学：\n\n用友网络2026届前端实习生招聘启动！BIP商业创新平台、YonSuite等多款产品等你来参与。\n\n【岗位名称】前端开发实习生\n【工作地点】北京、上海、杭州、南昌\n【实习时长】3个月及以上\n\n【业务介绍】\n用友是全球领先的企业云服务与软件提供商，服务超过700万家企业客户。你将参与：\n- BIP智能财务、人力、供应链产品研发\n- 低代码平台YonBuilder开发\n- 企业级SaaS应用前端架构\n\n【岗位要求】\n1. 2026届本科及以上学历，计算机相关专业\n2. 扎实的HTML/CSS/JavaScript基础\n3. 熟悉React或Vue，了解TypeScript\n4. 了解前端工程化、性能优化\n5. 对企业级应用开发感兴趣\n\n【技术栈】\nReact、TypeScript、Webpack、微前端架构\n\n【实习福利】\n• 薪资：本科280元/天，硕士350元/天\n• 异地房补：北京/上海1500元/月，杭州/南昌1000元/月\n• 免费三餐，健身房，年度体检\n• 企业级项目经验，技术大牛指导\n• 转正机会：实习优秀者直通校招\n\n【投递方式】yonyou.com/campus\n职位编号：FE-2026-001\n\n用友招聘团队\n2026年3月15日', 1, 0, NOW()),

('【服务上新】就业服务中心"在线咨询"功能上线', '各位同学：\n\n为方便同学们随时获取就业指导，就业服务中心正式上线"在线咨询"功能，专业老师在线答疑解惑。\n\n【咨询方式】\n💬 即时咨询（工作日9:00-17:00）\n- 就业政策咨询\n- 简历诊断建议\n- 求职困惑解答\n- 职业规划指导\n\n📧 留言咨询（24小时）\n- 非工作时间可留言\n- 24小时内回复\n- 支持上传附件（简历、offer等）\n\n📹 视频咨询（需预约）\n- 深度职业规划\n- 模拟面试\n- 复杂问题解答\n\n【咨询老师】\n- 就业政策专家：张老师（10年就业管理经验）\n- 职业规划师：李老师（GCDF认证）\n- 行业导师：王经理（互联网大厂HRD）\n\n【使用方式】\n1. 登录就业服务平台\n2. 点击右下角"在线咨询"图标\n3. 选择咨询类型与老师\n4. 开始咨询\n\n【服务承诺】\n工作日即时响应，复杂问题24小时内给出解决方案。\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【形势分析】2026年就业市场趋势与应对策略', '各位同学：\n\n2026年就业形势如何？哪些行业机会多？就业服务中心特举办就业形势分析讲座，为你解读最新就业市场趋势。\n\n【主题】2026年就业市场趋势与应对策略\n【时间】2026年4月6日（周四）19:00-21:00\n【地点】图书馆报告厅\n【主讲人】陈教授，劳动经济研究所所长，就业政策研究专家\n【面向对象】全体在校学生\n\n【内容大纲】\n一、宏观经济与就业形势（30分钟）\n- 2026年经济增长预期\n- 就业市场总体供需分析\n- 重点行业就业形势\n\n二、热门行业机会分析（40分钟）\n- 人工智能与大数据：人才缺口与薪资水平\n- 新能源与智能制造：政策红利与岗位增长\n- 生物医药与健康：后疫情时代机遇\n- 金融科技与数字化转型：复合型人才需求\n\n三、求职策略建议（30分钟）\n- 如何提升就业竞争力\n- 跨专业求职的可行性\n- 考研vs就业的决策框架\n- 体制内vs体制外的选择\n\n四、互动答疑（20分钟）\n\n【资料领取】\n现场发放《2026年就业市场白皮书》\n\n就业服务中心\n2026年3月15日', 1, 0, NOW()),

('【实习招聘】科大讯飞2026届AI实习生招聘', '各位同学：\n\n科大讯飞2026届AI实习生招聘启动！语音合成、语音识别、认知智能、多模态等核心技术团队等你来。\n\n【岗位名称】AI算法实习生/软件开发实习生\n【工作地点】合肥、北京、上海、广州、西安、苏州\n【实习时长】3个月及以上，优先6个月\n\n【研究方向】\n- 语音合成：个性化语音、情感语音、歌声合成\n- 语音识别：远场识别、方言识别、多语种识别\n- 认知智能：自然语言理解、知识图谱、大模型\n- 多模态：图文理解、虚拟人、智能驾驶\n- 智医助理：医疗AI、辅助诊断\n- 智慧教育：自适应学习、智能评测\n\n【岗位要求】\n【AI算法】\n- 计算机、人工智能、数学等相关专业\n- 熟悉深度学习框架（PyTorch/TensorFlow）\n- 有语音/NLP/CV相关项目经验\n- 顶会论文或竞赛获奖优先\n\n【软件开发】\n- 扎实的编程基础，熟悉C++/Python/Java\n- 熟悉Linux开发环境\n- 了解AI算法部署与优化\n\n【实习福利】\n• 薪资：本科350元/天，硕士450元/天，博士600元/天\n• 异地房补：合肥1000元/月，北京/上海1500元/月\n• 免费三餐，健身房，年度体检\n• 参与国家级AI项目机会\n• 转正率超80%，AI顶尖人才计划\n\n【投递方式】iflytek.com/campus\n【截止时间】2026年5月15日\n\n科大讯飞招聘组\n2026年3月15日', 1, 0, NOW());


INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'2026届校招全攻略：从简历到Offer的时间线规划',
'详解2026届校园招聘完整时间线，包含寒假实习、暑期实习、秋招提前批等关键节点，助你把握每个求职机会。',
'/uploads/guide/timeline.jpg',
'<h2>一、校招时间线总览</h2>
<p>对于2026届应届毕业生来说，校招从2024年12月就已启动。以下是完整的时间规划：</p>

<h3>2024年12月-2025年2月（寒假实习申请）</h3>
<ul>
<li><strong>自我评估</strong>：明确职业目标和个人优势，确定目标行业和岗位类型。</li>
<li><strong>简历撰写</strong>：制作专业简历，确保简洁明了、重点突出。</li>
<li><strong>实习申请</strong>：寻找与未来职业方向相关的寒假实习机会。</li>
</ul>

<h3>2025年3月-5月（暑期实习黄金期）</h3>
<ul>
<li><strong>技能提升</strong>：根据目标职位要求，学习编程语言、数据分析等技能。</li>
<li><strong>模拟面试</strong>：每周进行2次模拟面试并录像复盘，提升表达能力。</li>
<li><strong>暑期实习网申</strong>：积极投递心仪企业，暑期实习转正率通常较高。</li>
</ul>

<h3>2025年6月-7月（秋招提前批）</h3>
<ul>
<li>互联网大厂技术岗提前批启动，简历优先筛选。</li>
<li>保持与实习公司的联系，争取转正机会。</li>
<li>熟悉不同企业的测评系统，进行针对性练习。</li>
</ul>

<h3>2025年8月-11月（正式秋招）</h3>
<ul>
<li>8-9月：互联网、金融行业集中招聘。</li>
<li>10-11月：国企、制造业、外企招聘高峰。</li>
<li>持续优化简历，根据反馈调整求职策略。</li>
</ul>

<h2>二、关键准备清单</h2>
<table border="1" cellpadding="8">
<tr><th>时间节点</th><th>必备事项</th><th>备注</th></tr>
<tr><td>提前6个月</td><td>确定目标行业与岗位</td><td>避免海投，精准定位。</td></tr>
<tr><td>提前3个月</td><td>完善简历，准备作品集</td><td>针对不同岗位准备多个版本。</td></tr>
<tr><td>提前1个月</td><td>刷题与模拟面试</td><td>技术岗建议完成一定数量的算法练习。</td></tr>
<tr><td>招聘季</td><td>每日投递5-10份简历</td><td>记录投递进度，及时跟进。</td></tr>
</table>

<h2>三、特别提醒</h2>
<p>每个单位都有自己的招聘节奏，用人单位不会等你。如果心仪企业只在3月收简历，错过这个时间可能失去机会。建议建立Excel表格跟踪每家企业的网申开放时间、笔试面试安排。</p>',
1280,
NOW()
);

INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'简历优化六大技巧：让你的简历通过ATS筛选',
'掌握JD关键词匹配、经历量化、STAR法则等六大专业技巧，实测可提升简历通过率50%以上。',
'/uploads/guide/resume.jpg',
'<h2>技巧一：JD关键词精准匹配</h2>
<p>拿到目标岗位的JD后，先提取高频核心词。例如运营岗位常见的用户增长、数据复盘、内容策划等关键词，需要自然融入经历描述中，以避免简历被ATS系统过滤。</p>

<h2>技巧二：经历量化表达</h2>
<p>将模糊的描述改为具体数据支撑：</p>
<ul>
<li>不推荐：参与社团招新</li>
<li>推荐：负责社团招新线上推广，制作3条短视频，获得1.2万播放，拉新150名成员，转化率12.5%</li>
</ul>

<h2>技巧三：软技能场景化</h2>
<p>不要只写具备团队协作能力，而是提供具体事例：</p>
<p>作为小组组长，协调5名成员完成为期2个月的课程设计，提前3天交付，获得导师92分评价，并作为优秀案例在年级展示。</p>

<h2>技巧四：跨场景经历迁移</h2>
<p>将校园社团经验迁移到市场岗位：</p>
<ul>
<li>社团活动策划 → 市场活动策划能力</li>
<li>拉赞助经历 → 商务拓展能力</li>
<li>公众号运营 → 新媒体运营能力</li>
</ul>

<h2>技巧五：STAR法则描述项目</h2>
<p>每个项目经历按STAR结构撰写：</p>
<ul>
<li><strong>S（情境）</strong>：项目背景与目标</li>
<li><strong>T（任务）</strong>：你的具体职责</li>
<li><strong>A（行动）</strong>：采取的关键措施</li>
<li><strong>R（结果）</strong>：量化成果与影响</li>
</ul>

<h2>技巧六：面试预备式优化</h2>
<p>在简历重点经历旁标注可延伸的面试细节：</p>
<ul>
<li>项目中的技术难点及解决方案</li>
<li>你在团队中的具体贡献占比</li>
<li>如果重来会优化的环节</li>
</ul>

<h2>简历自查清单</h2>
<p>提交前可对照以下内容进行检查：</p>
<ol>
<li>是否清晰写出求职岗位。</li>
<li>是否只保留与岗位相关的经历。</li>
<li>最相关经历是否放在前面。</li>
<li>是否用动词加数字描述成果。</li>
<li>自我评价是否有事例支撑。</li>
<li>联系方式是否清晰准确。</li>
<li>是否检查错字和语法。</li>
<li>照片是否为职业照。</li>
<li>排版是否简洁（不超过一页）。</li>
<li>文件命名是否规范，例如岗位-姓名-学校。</li>
</ol>',
2560,
NOW()
);
INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'技术面试通关全攻略：算法+八股文+项目经验',
'针对计算机专业学生的技术面试指南，涵盖算法刷题策略、系统设计、八股文知识及项目经验阐述技巧。',
'/uploads/guide/tech_interview.jpg',
'<h2>一、技术面试流程解析</h2>
<p>计算机行业技术面试通常包含以下环节：</p>
<ol>
<li><strong>简历筛选</strong>：通过ATS或HR初筛。</li>
<li><strong>笔试或在线测评</strong>：算法、数据结构、SQL、计算机基础。</li>
<li><strong>技术面试（1至3轮）</strong>：算法编程、系统设计、项目经验、八股文。</li>
<li><strong>HR面试</strong>：沟通能力、职业规划、团队合作。</li>
<li><strong>Offer谈判</strong>：薪资、岗位、入职时间。</li>
</ol>

<h2>二、算法刷题策略</h2>
<h3>分阶段刷题计划</h3>
<ul>
<li><strong>第1至2个月</strong>：LeetCode Top 100，掌握数组、链表、树、图等基础。</li>
<li><strong>第3个月</strong>：动态规划专题，理解状态转移方程。</li>
<li><strong>第4个月</strong>：企业真题，重点刷目标公司近三年笔试题。</li>
</ul>

<h3>面试中的算法题解思路</h3>
<ol>
<li>先与面试官确认输入输出格式。</li>
<li>说出暴力解法，再逐步优化。</li>
<li>手写代码时注意边界条件。</li>
<li>主动分析时间和空间复杂度。</li>
</ol>

<h2>三、八股文知识体系</h2>
<table border="1" cellpadding="8">
<tr><th>类别</th><th>核心考点</th><th>掌握程度</th></tr>
<tr><td>操作系统</td><td>进程线程、内存管理、IO多路复用</td><td>必会</td></tr>
<tr><td>计算机网络</td><td>TCP/IP、HTTP与HTTPS、网络安全</td><td>必会</td></tr>
<tr><td>数据库</td><td>索引优化、事务隔离、SQL调优</td><td>必会</td></tr>
<tr><td>设计模式</td><td>单例、工厂、观察者、策略模式</td><td>熟悉</td></tr>
<tr><td>分布式系统</td><td>CAP理论、微服务、消息队列</td><td>了解</td></tr>
</table>

<h2>四、项目经验阐述技巧</h2>
<p>使用STAR法则结合技术深度：</p>
<ul>
<li><strong>技术选型</strong>：为什么选择该技术栈？是否对比过其他方案？</li>
<li><strong>难点攻克</strong>：遇到的最大技术挑战是什么？如何解决的？</li>
<li><strong>性能优化</strong>：性能提升的具体数据和优化手段。</li>
<li><strong>个人贡献</strong>：独立完成还是团队协作？负责哪些模块？</li>
</ul>

<h2>五、系统设计面试</h2>
<p>常见系统设计题包括：</p>
<ul>
<li>设计短链接服务。</li>
<li>设计即时通讯系统。</li>
<li>设计秒杀系统。</li>
<li>设计推荐系统。</li>
</ul>
<p>答题框架：需求分析 → 流量估算 → 架构设计 → 数据库设计 → 关键问题解决方案。</p>',
1890,
NOW()
);
INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'无领导小组讨论（群面）通关秘籍',
'详解群面流程、角色分工、评分标准，提供话术模板和常见题型解析，助你在群面中脱颖而出。',
'/uploads/guide/group_interview.jpg',
'<h2>一、群面流程与评分标准</h2>
<p>无领导小组讨论通常持续30至45分钟，流程如下：</p>
<ol>
<li><strong>读题思考</strong>（5分钟）：阅读案例，列出个人观点。</li>
<li><strong>个人观点陈述</strong>（2分钟每人）：轮流阐述观点。</li>
<li><strong>小组讨论</strong>（15至20分钟）：达成共识，形成方案。</li>
<li><strong>总结汇报</strong>（3至5分钟）：推选代表向面试官汇报。</li>
</ol>

<h2>二、四大角色与定位</h2>
<table border="1" cellpadding="8">
<tr><th>角色</th><th>职责</th><th>适合人群</th><th>风险</th></tr>
<tr><td><strong>领导者</strong></td><td>把控方向、分配时间、协调冲突</td><td>逻辑强、气场足</td><td>容易成为众矢之的</td></tr>
<tr><td><strong>时间控制者</strong></td><td>提醒进度、推动流程</td><td>细心、有条理</td><td>仅报时容易边缘化</td></tr>
<tr><td><strong>记录者</strong></td><td>记录观点、总结归纳</td><td>书写快、逻辑清晰</td><td>记录过多可能忽略发言</td></tr>
<tr><td><strong>建议者</strong></td><td>提供创意、补充论据</td><td>思维活跃、知识面广</td><td>发言质量要求高</td></tr>
</table>

<h2>三、高分技巧与话术</h2>
<h3>1. 抢先亮牌（前几分钟）</h3>
<blockquote>大家好，我是某某专业的某某。我认为这个问题的核心在于……，建议我们从几个维度展开讨论，大家看是否可行。</blockquote>

<h3>2. 化解冲突</h3>
<blockquote>我觉得两位同学的观点都有道理，A同学强调的是……，B同学关注的是……，其实两者并不矛盾，我们可以这样处理……</blockquote>

<h3>3. 拉回正题</h3>
<blockquote>不好意思打断一下，我们现在的讨论有些偏离主题，题目要求的是……，建议我们先聚焦在这个点上。</blockquote>

<h3>4. 总结推进</h3>
<blockquote>我来总结一下目前的进展，我们已经确定了……，接下来需要讨论的是……，建议……</blockquote>

<h2>四、常见题型与解题思路</h2>
<ul>
<li><strong>排序题</strong>：先确定标准，再分类排序。</li>
<li><strong>资源分配题</strong>：明确约束条件，建立评估模型。</li>
<li><strong>案例分析题</strong>：使用SWOT分析，提出可落地方案。</li>
<li><strong>创意策划题</strong>：目标、策略、执行、预算形成闭环。</li>
</ul>

<h2>五、致命错误警示</h2>
<p>以下行为会严重影响评分：</p>
<p>全程沉默或极少发言；打断他人说话；固执己见否定所有人；与面试官争辩；透露具体薪资期望。</p>',
1450,
NOW()
);
INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'面试礼仪与形象管理：从着装到言谈举止',
'首因效应决定面试成败。详解不同行业的着装要求、肢体语言、言谈礼仪，助你打造专业职业形象。',
'/uploads/guide/etiquette.jpg',
'<h2>一、首因效应：前7秒定成败</h2>
<p>研究表明，面试官在见到候选人的前7秒内就已形成初步印象。职业形象管理不是形式主义，而是职业化的体现。</p>

<h2>二、分行业着装指南</h2>
<table border="1" cellpadding="8">
<tr><th>行业类型</th><th>男士着装</th><th>女士着装</th><th>禁忌</th></tr>
<tr><td>金融、咨询、律所</td><td>深色西装、白衬衫、领带、皮鞋</td><td>西装套裙或裤装、淡妆、中跟鞋</td><td>休闲装、夸张配饰</td></tr>
<tr><td>互联网、科技</td><td>商务休闲（衬衫加西裤）</td><td>简约连衣裙或衬衫加裤装</td><td>拖鞋、短裤、破洞牛仔</td></tr>
<tr><td>创意、设计</td><td>个性化但整洁，可带设计元素</td><td>时尚得体，展现审美</td><td>过于随意或邋遢</td></tr>
<tr><td>国企、制造业</td><td>保守正装</td><td>保守套装，避免浓妆</td><td>奇装异服、夸张造型</td></tr>
</table>

<h2>三、肢体语言管理</h2>
<ul>
<li><strong>进门</strong>：敲门三声，等待回应后进入，微笑问好。</li>
<li><strong>坐姿</strong>：坐椅子的三分之二位置，背部挺直，双手自然放桌面。</li>
<li><strong>眼神</strong>：保持适度眼神交流，不要长时间盯视。</li>
<li><strong>手势</strong>：适度使用，避免小动作，如抖腿、转笔。</li>
<li><strong>离场</strong>：椅子归位，微微鞠躬，表达感谢。</li>
</ul>

<h2>四、言谈礼仪细节</h2>
<h3>称呼规范</h3>
<ul>
<li>未知姓名：各位面试官好。</li>
<li>已知姓名：张经理好、李主管好。</li>
<li>避免使用：你们好、老师好。</li>
</ul>

<h3>应答礼仪</h3>
<ul>
<li>面试官提问后，思考两三秒再回答。</li>
<li>使用“您”而非“你”。</li>
<li>不直接否定面试官，可先肯定再补充。</li>
<li>不懂的问题可说明了解不够深入，并尝试从其他角度分析。</li>
</ul>

<h2>五、线上面试特别注意事项</h2>
<ul>
<li><strong>背景</strong>：选择干净整洁的背景。</li>
<li><strong>光线</strong>：面部光线充足，避免背光。</li>
<li><strong>设备</strong>：提前调试摄像头和麦克风。</li>
<li><strong>视线</strong>：看摄像头而非屏幕。</li>
<li><strong>应急</strong>：准备备用网络和设备。</li>
</ul>

<h2>六、时间管理与守时</h2>
<p>提前15分钟到达面试地点，如遇特殊情况：</p>
<ul>
<li>提前30分钟电话说明情况。</li>
<li>到达后先道歉，不要找借口。</li>
<li>调整状态后再进入面试环节。</li>
</ul>',
980,
NOW()
);
INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'薪资谈判技巧：如何优雅地谈钱不伤感情',
'拿到Offer后如何争取更高薪资？详解薪资构成、谈判时机、话术策略，助你获得理想薪酬。',
'/uploads/guide/salary.jpg',
'<h2>一、薪资谈判的心理建设</h2>
<p>谈判不是讨价还价，而是价值确认。企业给你Offer说明认可你的能力，合理争取薪资是职业化的表现。</p>

<h2>二、薪资构成全解析</h2>
<p>谈薪前必须了解总包（Total Package）的构成：</p>
<table border="1" cellpadding="8">
<tr><th>组成部分</th><th>说明</th><th>谈判空间</th></tr>
<tr><td>基本工资</td><td>月薪固定部分，五险一金缴纳基数</td><td>高</td></tr>
<tr><td>绩效奖金</td><td>季度或年度发放，与考核挂钩</td><td>中</td></tr>
<tr><td>年终奖</td><td>通常为一至六个月不等</td><td>较高</td></tr>
<tr><td>股票或期权</td><td>互联网公司常见，通常四年归属期</td><td>中</td></tr>
<tr><td>签字费</td><td>入职一次性奖金，可弥补上家年终奖损失</td><td>较高</td></tr>
<tr><td>补贴福利</td><td>房补、餐补、交通补、通讯补等</td><td>较低</td></tr>
</table>

<h2>三、最佳谈判时机</h2>
<ul>
<li><strong>最佳时机</strong>：收到正式Offer后、确认前。</li>
<li><strong>次佳时机</strong>：HR面试时，当被问到期望薪资。</li>
<li><strong>避免时机</strong>：初面阶段主动谈薪，会给面试官留下不佳印象。</li>
</ul>

<h2>四、谈判话术模板</h2>
<h3>场景一：HR询问期望薪资</h3>
<blockquote>根据我的调研，这个岗位的市场薪资范围大约在15至20K之间。结合我的实习经历和项目经验，我希望能在16K以上。当然，我更看重贵公司的发展平台和团队氛围，如果整体薪酬方案具有竞争力，我愿意进一步沟通。</blockquote>

<h3>场景二：已有Offer，希望争取更高薪资</h3>
<blockquote>非常感谢贵公司的认可。我目前确实收到了另一家公司的Offer，薪资为18K。但我更倾向于加入贵公司，因为……（具体原因）。想了解贵公司在薪资方面是否还有调整空间？如果能达到18K，我可以立即确认。</blockquote>

<h3>场景三：薪资低于预期</h3>
<blockquote>感谢贵公司的Offer。坦诚来说，这个薪资比我预期稍低。我在实习期间独立负责了某项目，并取得了具体成果。基于这些经验，我希望薪资能调整到某范围。如果薪资暂时无法调整，是否可以增加签字费或提高年终奖比例？</blockquote>

<h2>五、谈判禁忌</h2>
<p>以下行为会严重影响谈判效果：</p>
<p>不要虚报其他Offer；不要以威胁方式谈薪；不要只谈钱不谈发展；不要接受Offer后再反悔要求加薪；不要透露自己的最低底线。</p>

<h2>六、非薪资谈判点</h2>
<p>如果薪资确实无法调整，可以争取：</p>
<ul>
<li>更早的绩效评估时间，例如六个月提前调薪。</li>
<li>更多带薪年假。</li>
<li>远程办公或弹性工作制。</li>
<li>培训预算或考证补贴。</li>
<li>导师制或更快的晋升通道。</li>
</ul>',
1120,
NOW()
);

INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'应届生求职心理调适：应对焦虑与挫折',
'求职压力大、屡遭拒绝？专业心理师教你识别焦虑源头、调节情绪、重建自信，保持最佳求职状态。',
'/uploads/guide/psychology.jpg',
'<h2>一、求职焦虑的识别</h2>
<p>求职季常见的焦虑表现包括：</p>
<ul>
<li>失眠或睡眠质量下降</li>
<li>频繁查看邮箱和招聘应用</li>
<li>自我否定，例如“我不行”“没人要我”</li>
<li>社交回避，不愿谈论求职话题</li>
<li>躯体症状，如头痛、胃痛、食欲改变</li>
</ul>

<h2>二、焦虑源头分析</h2>
<table border="1" cellpadding="8">
<tr><th>焦虑类型</th><th>具体表现</th><th>应对策略</th></tr>
<tr><td>不确定性焦虑</td><td>担心能否找到工作、去哪个城市</td><td>制定备用方案，接受不确定性</td></tr>
<tr><td>同辈压力</td><td>看到同学拿到Offer，自己还没有</td><td>专注自身节奏，避免比较</td></tr>
<tr><td>完美主义</td><td>只投大厂，小公司不考虑</td><td>调整预期，先就业再择业</td></tr>
<tr><td>能力不足</td><td>面试被拒后怀疑自身能力</td><td>针对性提升，建立成长型思维</td></tr>
</table>

<h2>三、情绪调节技巧</h2>
<h3>1. 正念呼吸法（面试前使用）</h3>
<ol>
<li>闭上眼睛，深吸气四秒</li>
<li>屏住呼吸四秒</li>
<li>缓慢呼气六秒</li>
<li>重复三至五次，帮助放松</li>
</ol>

<h3>2. 焦虑具象化</h3>
<p>把担忧写下来，区分可控与不可控：</p>
<ul>
<li><strong>可控</strong>：简历优化、刷题、模拟面试等，可立即行动</li>
<li><strong>不可控</strong>：HR是否回复、竞争对手实力等，学会接纳</li>
</ul>

<h3>3. 建立小胜利清单</h3>
<p>每天记录三件做得好的小事：</p>
<ul>
<li>今天投递了五份简历</li>
<li>完成了一道算法题</li>
<li>收到了一个面试邀请</li>
</ul>

<h2>四、应对拒绝的策略</h2>
<p>把每次拒绝当作能力扫描：</p>
<ol>
<li><strong>归因分析</strong>：判断是简历问题、技能不足还是匹配度问题</li>
<li><strong>信息收集</strong>：礼貌询问HR是否能提供反馈</li>
<li><strong>快速迭代</strong>：根据反馈调整简历或准备方向</li>
<li><strong>情绪隔离</strong>：拒绝的是岗位，不是你这个人</li>
</ol>

<h2>五、建立支持系统</h2>
<ul>
<li><strong>求职伙伴</strong>：组建三至五人互助小组，共享信息、模拟面试</li>
<li><strong>导师资源</strong>：联系学长学姐获取行业建议</li>
<li><strong>专业帮助</strong>：学校心理咨询中心提供支持</li>
<li><strong>家庭沟通</strong>：与父母坦诚沟通压力，争取理解</li>
</ul>

<h2>六、压力面试特别应对</h2>
<p>面对面试官的刻意施压时：</p>
<ul>
<li>保持微笑，深呼吸</li>
<li>避免防御性反驳，可先表达理解</li>
<li>用事实回应质疑，例如引用项目经历</li>
<li>把压力测试视为情绪稳定性的考察</li>
</ul>',
890,
NOW()
);
INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'网申技巧与ATS系统通关指南',
'90%的简历在网申阶段就被机器筛选掉。详解网申填写技巧、关键词优化、开放性问题回答策略。',
'/uploads/guide/application.jpg',
'<h2>一、ATS系统工作原理</h2>
<p>ATS（申请人追踪系统）是企业用于筛选简历的工具，它会：</p>
<ul>
<li>解析简历内容，提取关键词</li>
<li>匹配岗位要求中的硬性条件</li>
<li>按匹配度排序，HR通常只看前20%</li>
</ul>
<p>优化目标是让系统能读懂，同时让HR看着舒服。</p>

<h2>二、网申填写核心技巧</h2>
<h3>1. 基本信息准确无误</h3>
<ul>
<li>姓名、身份证号、手机号必须准确</li>
<li>使用专业邮箱，例如姓名拼音邮箱，避免昵称邮箱</li>
<li>毕业时间统一填写为2026年6月或7月</li>
</ul>

<h3>2. 教育经历突出优势</h3>
<ul>
<li>重点学校需明确标注</li>
<li>GPA较高或排名靠前可写</li>
<li>相关课程只写三至五门核心课程</li>
</ul>

<h3>3. 实习经历STAR描述</h3>
<p>使用动词加数量词的结构：</p>
<blockquote>主导用户增长项目，通过优化落地页，将转化率从2.1%提升至3.8%，月新增用户增加五千。</blockquote>

<h2>三、开放性问题回答策略</h2>
<table border="1" cellpadding="8">
<tr><th>常见问题</th><th>考察点</th><th>回答框架</th></tr>
<tr><td>为什么选择我们公司</td><td>求职动机</td><td>行业、企业、岗位三个维度</td></tr>
<tr><td>描述一次团队合作经历</td><td>协作能力</td><td>STAR法则，突出个人贡献</td></tr>
<tr><td>你的职业规划是什么</td><td>稳定性</td><td>短期与中期目标</td></tr>
<tr><td>最大的缺点是什么</td><td>自我认知</td><td>真实缺点、改进措施、已有成效</td></tr>
<tr><td>大学最成功或遗憾的事</td><td>反思能力</td><td>情境、行动、收获</td></tr>
</table>

<h2>四、关键词优化清单</h2>
<p>根据岗位类型，在简历中自然融入以下关键词：</p>
<ul>
<li><strong>技术岗</strong>：Java、Python、Spring Boot、MySQL、Redis、微服务、高并发</li>
<li><strong>产品岗</strong>：用户调研、需求分析、原型设计、数据分析、敏捷开发</li>
<li><strong>运营岗</strong>：用户增长、内容运营、活动策划、转化率、日活</li>
<li><strong>市场岗</strong>：品牌推广、渠道拓展、市场调研、竞品分析、营销策划</li>
</ul>

<h2>五、网申细节提醒</h2>
<ul>
<li>提早申请，避开截止前高峰期</li>
<li>随填随存，避免系统超时</li>
<li>简历使用PDF格式，作品集按要求上传</li>
<li>照片需为职业照或证件照，背景纯色</li>
<li>提交前预览全文，检查错字和格式</li>
</ul>

<h2>六、网申进度管理</h2>
<p>建议建立跟踪表格：</p>
<table border="1" cellpadding="8">
<tr><th>公司</th><th>岗位</th><th>投递日期</th><th>状态</th><th>下一步</th></tr>
<tr><td>腾讯</td><td>产品策划</td><td>3月1日</td><td>笔试完成</td><td>准备面试</td></tr>
<tr><td>阿里</td><td>运营</td><td>3月5日</td><td>简历筛选</td><td>等待通知</td></tr>
</table>',
1340,
NOW()
);INSERT INTO guide (title, description, cover, content, view_count, create_time) VALUES
(
'求职陷阱识别与权益保护指南',
'虚假招聘、培训贷、试用期陷阱等问题频发。详解常见求职骗局识别方法、劳动合同审查要点与维权渠道。',
'/uploads/guide/safety.jpg',
'<h2>一、常见求职陷阱识别</h2>

<h3>陷阱一：虚假高薪招聘</h3>
<p><strong>特征</strong>：薪资明显高于市场水平，要求极低，急招。</p>
<p><strong>识别</strong>：查询企业工商信息，查看是否存在经营异常或劳动仲裁记录。</p>

<h3>陷阱二：培训贷</h3>
<p><strong>套路</strong>：以“先培训后就业”为名，诱导签订贷款合同。</p>
<p><strong>真相</strong>：培训质量差，最终背负高额贷款。</p>
<p><strong>应对</strong>：正规企业不会向求职者收取任何费用。</p>

<h3>陷阱三：试用期陷阱</h3>
<table border="1" cellpadding="8">
<tr><th>违法行为</th><th>法律规定</th><th>维权方式</th></tr>
<tr><td>试用期不签合同</td><td>入职一个月内必须签订书面合同</td><td>保留工资流水与考勤记录，申请仲裁</td></tr>
<tr><td>试用期过长</td><td>合同一年以内试用期不超过一个月；一至三年不超过两个月；三年以上不超过六个月</td><td>向劳动监察部门投诉</td></tr>
<tr><td>试用期薪资低于80%</td><td>试用期工资不得低于转正后工资的80%</td><td>要求补足差额</td></tr>
<tr><td>随意辞退</td><td>需证明不符合录用条件</td><td>要求出具书面说明，申请赔偿</td></tr>
</table>

<h3>陷阱四：传销式招聘</h3>
<p><strong>特征</strong>：面试地点偏僻，要求缴纳费用，强调发展下线。</p>
<p><strong>识别</strong>：查询正规直销企业名单，不在名单内的均需警惕。</p>

<h2>二、劳动合同审查要点</h2>
<p>签约前务必确认以下内容：</p>
<ul>
<li><strong>主体信息</strong>：公司名称与Offer一致，公章清晰。</li>
<li><strong>合同期限</strong>：起止日期明确，试用期符合法律规定。</li>
<li><strong>工作内容</strong>：岗位名称、工作地点具体明确。</li>
<li><strong>薪资待遇</strong>：基本工资、绩效奖金计算方式明确。</li>
<li><strong>五险一金</strong>：缴纳基数、比例、起始时间明确。</li>
<li><strong>违约金</strong>：仅培训与竞业限制可约定违约金，其他情况无效。</li>
</ul>

<h2>三、三方协议注意事项</h2>
<ul>
<li>违约金一般不超过月薪两倍，可协商。</li>
<li>备注栏可写明薪资、岗位、工作地点等关键条款。</li>
<li>升学或考公成功可无条件解约。</li>
<li>企业毁约需支付违约金并出具解约函。</li>
</ul>

<h2>四、维权渠道与流程</h2>

<h3>1. 协商解决</h3>
<p>与HR或直属领导沟通，保留聊天记录与邮件证据。</p>

<h3>2. 学校就业中心</h3>
<p>可向学校投诉，学校有权约谈企业或列入黑名单。</p>

<h3>3. 劳动监察部门</h3>
<p>拨打12333或前往人社局投诉，处理拖欠工资、不签合同等问题。</p>

<h3>4. 劳动仲裁</h3>
<p>免费申请，时效一年，可主张：</p>
<ul>
<li>未签合同的双倍工资（最多十一个月）</li>
<li>违法解除的赔偿金</li>
<li>加班费、年假工资等</li>
</ul>

<h3>5. 法院诉讼</h3>
<p>对仲裁结果不服，可在十五日内向法院起诉。</p>

<h2>五、求职安全自查清单</h2>
<p>
查询企业工商信息是否正常；<br>
面试地点是否正规；<br>
是否要求缴纳任何费用；<br>
是否扣押证件；<br>
合同条款是否清晰；<br>
薪资与五险一金是否明确。
</p>',
1050,
NOW()
);
