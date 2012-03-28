CREATE TABLE user (
    id  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL,
    PRIMARY KEY (id),
    UNIQUE KEY (name)
);

CREATE TABLE user_hatena (
    name VARCHAR(64) NOT NULL,
    assoc_user_id BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE article (
    id      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    title   VARCHAR(512) NOT NULL,
    body    LONGTEXT NOT NULL,
    created_on DATETIME NOT NULL DEFAULT 0,
    updated_on DATETIME NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    INDEX article_ui_co_index ( user_id, created_on )
);

