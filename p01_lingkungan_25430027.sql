-- p01_lingkungan_25430027.sql
-- Password sengaja diganti penanda. JANGAN commit password asli.
CREATE DATABASE kopma_027
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'mhs_027'@'localhost' IDENTIFIED BY '<password_kerja>';
GRANT ALL PRIVILEGES ON kopma_027.* TO 'mhs_027'@'localhost';