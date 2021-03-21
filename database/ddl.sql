/* 版本 */
CREATE TABLE version (
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    uid         bigint unsigned                    NULL     COMMENT '当数据私有时可选',
    business    varchar(32)                        NOT NULL COMMENT '业务',
    type        varchar(5)                         NOT NULL COMMENT 'oss,local',
    version     int unsigned                       NOT NULL COMMENT '版本',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COLLATE = utf8mb4_unicode_ci COMMENT '版本信息';

CREATE TABLE version_command (
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    uid         bigint unsigned                    NULL COMMENT '当数据私有时可选',
    business    varchar(32)                        NOT NULL COMMENT '业务',
    version     int unsigned                       NOT NULL COMMENT '版本',
    command     varchar(255)                       NOT NULL COMMENT '同步用的指令',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COLLATE = utf8mb4_unicode_ci COMMENT '版本同步指令';

/* 公共数据 */
CREATE TABLE simple_word ( /*Redis: Set<word>, FrontEnd: Array<word>*/
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    word        varchar(100)                       NOT NULL COMMENT '简单词',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    constraint word unique (word)
) COLLATE = utf8mb4_unicode_ci COMMENT '简单词汇';

CREATE TABLE word ( /*Redis: ZSet<first word, word, score>, FrontEnd: Record<word, score>*/
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    word        varchar(100)                       NOT NULL COMMENT '单词',
    score       double                             NOT NULL COMMENT '词频',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COLLATE = utf8mb4_unicode_ci COMMENT '词汇';

CREATE TABLE professional_word (/*Redis: Hash<category, word, score>, FrontEnd: Record<category, Record<word, score>>*/
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    category_id bigint unsigned                    NOT NULL COMMENT '专业分类',
    word        varchar(100)                       NOT NULL COMMENT '单词',
    score       double                             NOT NULL COMMENT '词频',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    CONSTRAINT category UNIQUE (category_id, word)
) COLLATE = utf8mb4_unicode_ci COMMENT '专业词汇';

CREATE TABLE exchanges (/*Redis: Hash<first word, word, origin>, FrontEnd: Record<word, score>*/
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    word        varchar(100)                       NOT NULL COMMENT '单词',
    origin      varchar(64)                        NOT NULL COMMENT '原型',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COLLATE = utf8mb4_unicode_ci COMMENT '词形';

CREATE TABLE category (/*JsonTree*/
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    name        varchar(64)                        NOT NULL COMMENT '专业类别',
    par_id      varchar(64)                        NOT NULL COMMENT '父级',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) COLLATE = utf8mb4_unicode_ci COMMENT '专业类别';

/* 审核表 */

CREATE TABLE verify (
    id           bigint unsigned                   NOT NULL COMMENT 'uid' primary key,
    business     varchar(64)                       NOT NULL COMMENT '业务',
    action       varchar(32)                       NOT NULL COMMENT '操作add,delete',
    value        varchar(64)                       NOT NULL COMMENT '值',

    status       tinyint default 0                 NOT NULL COMMENT '审批状态, 0初始，1通过，-1拒绝',
    checked_by   varchar(50)                       NULL     COMMENT '审批人',
    checked_time datetime                          NULL     COMMENT '审批人',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `tmp_token` (`tmp_token`)
) COLLATE = utf8mb4_unicode_ci COMMENT '审批表';

/* 用户登陆信息 */

CREATE TABLE auth_pwd (
    uid         bigint unsigned                    NOT NULL COMMENT 'uid' primary key,
    username    varchar(50)                        NOT NULL COMMENT '登录用的用户名',
    password    char(64)                           NOT NULL COMMENT '密码',
    disabled    tinyint(1)                         NOT NULL COMMENT '是否冻结',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `username` (`username`)
) COLLATE = utf8mb4_unicode_ci COMMENT '用户名密码信息';

CREATE TABLE auth_tmp_token (
    uid         bigint unsigned                    NOT NULL COMMENT 'uid' primary key,
    tmp_token   char(36)                           NOT NULL COMMENT '临时账号可以使用临时token登录',
    disabled    tinyint(1)                         NOT NULL COMMENT '是否冻结',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `tmp_token` (`tmp_token`)
) COLLATE = utf8mb4_unicode_ci COMMENT '临时账号信息';

/* 用户私有信息 */

CREATE TABLE user_pri_word ( /*FrontEnd: Record<word, familiar>*/
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    uid         bigint                             NOT NULL COMMENT '用户ID',
    word        varchar(100)                       NOT NULL COMMENT '单词',
    familiar    tinyint(1)                         NOT NULL COMMENT '是否熟悉',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uid_word` (`uid`,`word`)
) COLLATE = utf8mb4_unicode_ci COMMENT '用户私有的词汇';

CREATE TABLE user_category_score ( /*FrontEnd: Record<category, score>*/
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    uid         bigint                             NOT NULL COMMENT '用户ID',
    category_id bigint                             NOT NULL COMMENT '专业ID',
    score       double                             NOT NULL COMMENT '分数',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    UNIQUE KEY `uid_word` (`uid`,`word`)
) COLLATE = utf8mb4_unicode_ci COMMENT '用户词汇分数';

CREATE TABLE user_pri_setting (
    id          bigint unsigned                    AUTO_INCREMENT PRIMARY KEY,
    uid         bigint unsigned                    NOT NULL COMMENT '用户ID',
    kee         varchar(20)                        NOT NULL COMMENT '设置的键',
    val         varchar(50)                        NULL     COMMENT '设置的值，如果为null表从全局设置继承',
    site        varchar(100) default 'global'      NOT NULL COMMENT '生效的站点',
    order       double default 0                   NULL     COMMENT '生效顺序',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    constraint uid_kee unique (uid, kee)
) COLLATE = utf8mb4_unicode_ci COMMENT '用户私有设置';

CREATE TABLE user_pri (
    uid         bigint                             NOT NULL PRIMARY KEY,
    role        tinyint unsigned                   NOT NULL COMMENT '用户角色',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
) COLLATE = utf8mb4_unicode_ci COMMENT '用户私有数据';

CREATE TABLE user_pub (
    uid         bigint                             NOT NULL PRIMARY KEY,
    nickname    varchar(50)                        NULL COMMENT '昵称',

    deleted     tinyint(1) default 0               NOT NULL COMMENT '是否删除',
    create_by   varchar(55)                        NOT NULL COMMENT '创建人',
    create_time datetime default current_timestamp NOT NULL COMMENT '创建日期',
    update_by   varchar(55)                        NULL     COMMENT '更新人',
    update_time datetime                           NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
) COLLATE = utf8mb4_unicode_ci COMMENT '用户公有数据';
