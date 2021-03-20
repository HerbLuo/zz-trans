CREATE TABLE auth_pwd (
    uid         bigint unsigned                    not null comment 'uid' primary key,
    username    varchar(50)                        not null comment '登录用的用户名',
    password    char(64)                           not null comment '密码',
    disabled    tinyint(1)                         not null comment '是否冻结',
    create_time datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    update_time datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP '更新时间',
    create_by   varchar(50)                        null comment '创建人',
    update_by   varchar(50)                        null comment '更新人',
    deleted     tinyint(1)                         not null default 0 comment '是否删除',
    UNIQUE KEY `username` (`username`)
);

CREATE TABLE auth_tmp_token (
    uid         bigint unsigned                    not null comment 'uid' primary key,
    tmp_token   char(36) charset ascii             not null comment '临时账号可以使用临时token登录',
    disabled    tinyint(1)                         not null comment '是否冻结',
    create_time datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    update_time datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP '更新时间',
    create_by   varchar(50)                        null comment '创建人',
    update_by   varchar(50)                        null comment '更新人',
    deleted     tinyint(1)                         not null default 0 comment '是否删除',
    UNIQUE KEY `tmp_token` (`tmp_token`)
);

CREATE TABLE category (
    id          bigint unsigned                    not null auto_increment primary key,
    label       varchar(50)                        not null comment '分类名',
    value       int unsigned                       not null comment '分类值',
    create_time datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    update_time datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP '更新时间',
    create_by   varchar(50)                        null comment '创建人',
    update_by   varchar(50)                        null comment '更新人',
    deleted     tinyint(1)                         not null default 0 comment '是否删除',
);

CREATE TABLE command_user_pri_word (
    id          bigint unsigned                    not null auto_increment primary key,
    ver_id      bigint unsigned                    not null,
    version     bigint unsigned                    not null,
    command     varchar(255)                       not null,
    create_time datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    update_time datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP '更新时间',
    create_by   varchar(50)                        null comment '创建人',
    update_by   varchar(50)                        null comment '更新人',
    deleted     tinyint(1)                         not null default 0 comment '是否删除',
    CONSTRAINT udv_id_version UNIQUE (ver_id, version)
);

CREATE TABLE permissions (
    id          bigint unsigned                      auto_increment primary key,
    `table`     varchar(88)                          not null comment '表名',
    `column`    varchar(88)                          null comment '列级权限',
    uid_read    varchar(88)                          not null comment '表或虚拟表中的uid字段，用于控制表或列的读取权限',
    uid_write   varchar(88)                          not null comment '表或虚拟表中的uid字段，用于控制表或列的读取权限',
    joiners     varchar(255)                         not null comment '使用joiners构建虚拟表',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null comment '更新人',
    update_time datetime                             not null comment '更新时间'
);

CREATE TABLE professional_word (
    id          bigint unsigned                      auto_increment primary key,
    category    bigint unsigned                      not null,
    word        varchar(32)                          not null,
    score       double(255, 0)                       not null,
    verified    tinyint(1) default 0                 not null,
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null comment '更新人',
    update_time datetime                             not null comment '更新时间',
    CONSTRAINT category UNIQUE (category, word)
);

CREATE TABLE simple_word (
    id          bigint unsigned                      auto_increment primary key,
    word        varchar(32)                          not null comment '简单词',
    verified    tinyint(1)                           not null comment '状态：0 未审核 1 成功 -1 拒绝',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null comment '更新人',
    update_time datetime                             not null comment '更新时间',
    constraint word unique (word)
) collate = utf8mb4_unicode_ci comment '简单词汇';

CREATE TABLE user_pri_category (
    id          bigint unsigned                      auto_increment primary key,
    uid         bigint                               not null comment '用户id',
    category    bigint                               not null comment '分类',
    score       double                               not null comment '分数',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null comment '更新人',
    update_time datetime                             not null comment '更新时间',
    CONSTRAINT uid UNIQUE (uid, category)
) collate = utf8mb4_unicode_ci comment '用户专业词汇分数';

CREATE TABLE user_pri_setting (
    id          bigint unsigned                      auto_increment primary key,
    uid         bigint unsigned                      not null comment '用户ID',
    kee         varchar(20)                          not null comment '设置的键',
    val         varchar(50)                          null     comment '设置的值，如果为null表从全局设置继承',
    site        varchar(100) default 'global'        not null comment '生效的站点',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null comment '更新人',
    update_time datetime                             not null comment '更新时间',
    constraint uid_kee unique (uid, kee)
) collate = utf8mb4_unicode_ci comment '用户私有设置';

create index uid on user_pri_setting (uid);

CREATE TABLE user_pri_word (
    id          bigint unsigned                      auto_increment primary key,
    uid         bigint                               not null comment '用户ID',
    word        varchar(100)                         not null comment '单词',
    familiar    tinyint(1)                           not null comment '是否熟悉',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null comment '更新人',
    update_time datetime                             not null comment '更新时间',
    constraint uid_word unique (uid, word)
);

create index familiar on user_pri_word (familiar);

create index uid on user_pri_word (uid);

CREATE TABLE user_pri (
    uid         bigint                               not null primary key,
    role        tinyint unsigned                     not null comment '用户角色',
    score       double unsigned                      not null comment '用户(单词)分数',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null comment '更新人',
    update_time datetime                             not null comment '更新时间',
) collate = utf8mb4_unicode_ci comment '用户私有数据';

CREATE TABLE user_pub (
    uid          bigint                               not null comment 'uid' primary key,
    nickname     varchar(50)                          null comment '昵称',
    hidden_phone char(11)                             null comment '手**机',
    deleted      tinyint(1) default 0                 not null comment '是否删除',
    create_by    varchar(55)                          not null comment '创建人',
    create_time  datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by    varchar(55)                          null comment '更新人',
    update_time  datetime                             not null comment '更新时间',
) collate = utf8mb4_unicode_ci comment '用户公有数据';

CREATE TABLE word_score_log (
    id          bigint unsigned                      auto_increment primary key,
    word        varchar(32)                          not null comment '单词',
    score       double                               not null comment '词频',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null     comment '更新人',
    update_time datetime                             not null comment '更新时间'
) collate = utf8mb4_unicode_ci comment '调整词频前记录下的一条词汇日志';

CREATE TABLE word (
    id          bigint unsigned                      auto_increment primary key,
    word        varchar(32)                          not null comment '单词',
    score       double(255, 0)                       not null comment '词频',
    verified    tinyint(1) default 0                 not null comment '是否审核通过',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null     comment '更新人',
    update_time datetime                             not null comment '更新时间',
    CONSTRAINT category UNIQUE (word)
) collate = utf8mb4_unicode_ci comment '已经验证的修改词频数据';

CREATE TABLE version_user_pri_word (
    id          bigint unsigned                      not null primary key,
    uid         bigint                               not null comment '用户ID',
    version     int unsigned                         not null comment '版本',
    deleted     tinyint(1) default 0                 not null comment '是否删除',
    create_by   varchar(55)                          not null comment '创建人',
    create_time datetime   default CURRENT_TIMESTAMP not null comment '创建日期',
    update_by   varchar(55)                          null     comment '更新人',
    update_time datetime                             not null comment '更新时间',
    CONSTRAINT uid UNIQUE (uid)
) collate = utf8mb4_unicode_ci comment '用户的生词表版本信息';

# 考虑以下几点：是否所有数据都可以mysql备份。
# 用户私有数据包含以下几点，
# 用户全局设置，用户私有词汇，用户通用词汇分数，用户专业词汇分数，用户网站下的设置
# 需要的操作包含，获取版本，获取两个版本之间的同步指令。
#
