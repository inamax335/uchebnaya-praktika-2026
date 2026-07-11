-- ============================================================
-- Кейс-задача № 3. База данных "Туризм"
-- СУБД: MySQL 8.0
-- Структура: 4 таблицы-справочника + 1 таблица переменной информации
-- ============================================================

CREATE DATABASE IF NOT EXISTS tourism
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;
USE tourism;

-- ------------------------------------------------------------
-- Справочник 1. Страны
-- ------------------------------------------------------------
CREATE TABLE countries (
    country_id   INT UNSIGNED NOT NULL AUTO_INCREMENT,
    country_name VARCHAR(100) NOT NULL,
    visa_needed  BOOLEAN      NOT NULL DEFAULT FALSE,
    PRIMARY KEY (country_id),
    UNIQUE KEY uq_country_name (country_name)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Справочник 2. Туры (перечень предоставляемых услуг)
-- ------------------------------------------------------------
CREATE TABLE tours (
    tour_id     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    tour_name   VARCHAR(150)  NOT NULL,
    country_id  INT UNSIGNED  NOT NULL,
    duration    TINYINT UNSIGNED NOT NULL COMMENT 'Длительность, дней',
    price       DECIMAL(10,2) NOT NULL COMMENT 'Цена за 1 человека, руб.',
    description TEXT,
    PRIMARY KEY (tour_id),
    CONSTRAINT fk_tours_country FOREIGN KEY (country_id)
        REFERENCES countries (country_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Справочник 3. Клиенты
-- ------------------------------------------------------------
CREATE TABLE clients (
    client_id  INT UNSIGNED NOT NULL AUTO_INCREMENT,
    last_name  VARCHAR(60)  NOT NULL,
    first_name VARCHAR(60)  NOT NULL,
    phone      VARCHAR(20)  NOT NULL,
    email      VARCHAR(100),
    passport   VARCHAR(20)  NOT NULL,
    PRIMARY KEY (client_id),
    UNIQUE KEY uq_clients_passport (passport)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Справочник 4. Менеджеры турфирмы
-- ------------------------------------------------------------
CREATE TABLE managers (
    manager_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    last_name  VARCHAR(60)  NOT NULL,
    first_name VARCHAR(60)  NOT NULL,
    phone      VARCHAR(20)  NOT NULL,
    PRIMARY KEY (manager_id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Таблица переменной информации. Заказы туров
-- Ссылается внешними ключами на все справочники
-- ------------------------------------------------------------
CREATE TABLE orders (
    order_id    INT UNSIGNED  NOT NULL AUTO_INCREMENT,
    order_date  DATE          NOT NULL,
    client_id   INT UNSIGNED  NOT NULL,
    tour_id     INT UNSIGNED  NOT NULL,
    manager_id  INT UNSIGNED  NOT NULL,
    persons     TINYINT UNSIGNED NOT NULL DEFAULT 1,
    total_price DECIMAL(12,2) NOT NULL,
    status      ENUM('новый','оплачен','завершён','отменён')
                NOT NULL DEFAULT 'новый',
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_client FOREIGN KEY (client_id)
        REFERENCES clients (client_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orders_tour FOREIGN KEY (tour_id)
        REFERENCES tours (tour_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orders_manager FOREIGN KEY (manager_id)
        REFERENCES managers (manager_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- ------------------------------------------------------------
-- Тестовое наполнение справочников
-- ------------------------------------------------------------
INSERT INTO countries (country_name, visa_needed) VALUES
('Россия', FALSE), ('Турция', FALSE), ('Египет', FALSE), ('Италия', TRUE);

INSERT INTO tours (tour_name, country_id, duration, price, description) VALUES
('Золотое кольцо России', 1, 7, 45000.00, 'Автобусный тур по древним городам'),
('Анталья все включено', 2, 10, 85000.00, 'Пляжный отдых, отель 5*'),
('Хургада, Красное море', 3, 8, 78000.00, 'Пляжный отдых и дайвинг'),
('Классическая Италия', 4, 9, 120000.00, 'Рим - Флоренция - Венеция');

INSERT INTO clients (last_name, first_name, phone, email, passport) VALUES
('Иванов', 'Сергей', '+7-901-111-22-33', 'ivanov@mail.ru', '4510 123456'),
('Петрова', 'Анна', '+7-902-222-33-44', 'petrova@mail.ru', '4511 654321'),
('Сидоров', 'Олег', '+7-903-333-44-55', NULL, '4512 111222');

INSERT INTO managers (last_name, first_name, phone) VALUES
('Кузнецова', 'Мария', '+7-905-555-66-77'),
('Волков', 'Андрей', '+7-906-777-88-99');

-- ------------------------------------------------------------
-- Тестовое наполнение таблицы переменной информации
-- ------------------------------------------------------------
INSERT INTO orders (order_date, client_id, tour_id, manager_id, persons, total_price, status) VALUES
('2026-03-10', 1, 2, 1, 2, 170000.00, 'оплачен'),
('2026-03-15', 2, 4, 2, 1, 120000.00, 'новый'),
('2026-03-18', 3, 3, 1, 3, 234000.00, 'оплачен');

-- ------------------------------------------------------------
-- Контрольный запрос: заказы с расшифровкой по справочникам
-- ------------------------------------------------------------
SELECT o.order_id,
       o.order_date,
       CONCAT(c.last_name, ' ', c.first_name) AS client,
       t.tour_name,
       cn.country_name,
       CONCAT(m.last_name, ' ', m.first_name) AS manager,
       o.persons,
       o.total_price,
       o.status
FROM orders o
JOIN clients   c  ON c.client_id  = o.client_id
JOIN tours     t  ON t.tour_id    = o.tour_id
JOIN countries cn ON cn.country_id = t.country_id
JOIN managers  m  ON m.manager_id = o.manager_id
ORDER BY o.order_date;
