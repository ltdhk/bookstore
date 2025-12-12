-- 开启 MySQL 远程连接权限
-- 此脚本在容器首次启动时自动执行

-- 允许 root 用户从任意 IP 远程连接
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'Ltd5030229!';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 刷新权限
FLUSH PRIVILEGES;
