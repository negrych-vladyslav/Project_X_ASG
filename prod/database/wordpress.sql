CREATE DATABASE wordpress;
CREATE USER 'vlad'@'%' IDENTIFIED BY 'Samanyk2005';
GRANT ALL PRIVILEGES ON wordpress.* TO 'vlad'@'%';
FLUSH PRIVILEGES;