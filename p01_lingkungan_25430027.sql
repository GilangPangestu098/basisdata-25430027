-- p01_lingkungan_25430027.sql
-- Password sengaja diganti penanda. JANGAN commit password asli.
CREATE DATABASE IF NOT EXISTS kopma_027
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'mhs_027'@'localhost' IDENTIFIED BY '<password_kerja>';
GRANT ALL PRIVILEGES ON kopma_027.* TO 'mhs_027'@'localhost';

-- Milestone Proyek 1: basis data dan akun proyek
CREATE DATABASE IF NOT EXISTS klinik_027
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS 'dev_027'@'localhost' IDENTIFIED BY '<password_dev>';
GRANT ALL PRIVILEGES ON klinik_027.* TO 'dev_027'@'localhost';