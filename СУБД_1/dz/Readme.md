



\## Задание 1. Концептуальная модель 

\### Основные сущности

| Сущность | Описание |

\|----------|----------|

| \*\*User\*\* | Пользователь платформы (студент, преподаватель, админ) |

| \*\*Course\*\* | Онлайн-курс, созданный преподавателем |

| \*\*Lesson\*\* | Урок внутри курса |

| \*\*Enrollment\*\* | Запись студента на курс |

| \*\*LessonProgress\*\* | Прогресс прохождения уроков в рамках записи |

| \*\*Review\*\* | Отзыв и оценка студента на курс |

| \*\*Payment\*\* | Платёж студента и отчисление преподавателю |

\### Связи между сущностями

\```

User ──1:N──> Course              (преподаватель создаёт курсы)

User ──1:N──> Enrollment          (студент записывается на курсы)

User ──1:N──> Review              (студент оставляет отзывы)

User ──1:N──> Payment             (студент платит за курсы)

Course ──1:N──> Lesson            (курс состоит из уроков)

Course ──1:N──> Enrollment        (на курс записываются студенты)

Course ──1:N──> Review            (курс получает отзывы)

Course ──1:N──> Payment           (за курс идут отчисления)

Enrollment ──1:N──> LessonProgress (прогресс по записи)

Lesson ──1:N──> LessonProgress    (прогресс по уроку)

\```

\### Обоснование выбора сущностей

\- \*\*User\*\* объединяет студентов и преподавателей, так как у них почти одинаковый набор атрибутов; различие — в поле `role`. Это упрощает аутентификацию и логин.

\- \*\*Enrollment\*\* выделена отдельно: у записи на курс есть собственные атрибуты (дата, статус, завершение), а один студент может быть записан на много курсов.

\- \*\*LessonProgress\*\* реализует требование «продумайте, как хранить статус завершения урока» — прогресс хранится отдельно от записи на курс.

\- \*\*Payment\*\* введена под бизнес-требование «преподаватели получают отчисления от продаж».

\---

\## Задание 2. Логическая модель 

\### Атрибуты, первичные и внешние ключи

\#### User

| Атрибут | Тип | Ограничения |

\|---------|-----|-------------|

| id | integer | PK, auto-increment |

| email | varchar(255) | UNIQUE, NOT NULL |

| full\_name | varchar(255) | NOT NULL |

| role | varchar(20) | NOT NULL, CHECK: `student`, `instructor`, `admin` |

| created\_at | timestamp | NOT NULL, DEFAULT NOW() |

\#### Course

| Атрибут | Тип | Ограничения |

\|---------|-----|-------------|

| id | integer | PK, auto-increment |

| instructor\_id | integer | FK → User.id, NOT NULL |

| title | varchar(255) | NOT NULL |

| description | text | — |

| price | numeric(10,2) | NOT NULL, CHECK ≥ 0 |

| is\_published | boolean | NOT NULL, DEFAULT FALSE |

| created\_at | timestamp | NOT NULL, DEFAULT NOW() |

\#### Lesson

| Атрибут | Тип | Ограничения |

\|---------|-----|-------------|

| id | integer | PK, auto-increment |

| course\_id | integer | FK → Course.id, NOT NULL |

| title | varchar(255) | NOT NULL |

| content | text | — |

| position | integer | NOT NULL, CHECK > 0, UNIQUE(course\_id, position) |

\#### Enrollment

| Атрибут | Тип | Ограничения |

\|---------|-----|-------------|

| id | integer | PK, auto-increment |

| student\_id | integer | FK → User.id, NOT NULL |

| course\_id | integer | FK → Course.id, NOT NULL |

| status | varchar(20) | NOT NULL, CHECK: `active`, `completed`, `cancelled` |

| enrolled\_at | timestamp | NOT NULL, DEFAULT NOW() |

| completed\_at | timestamp | NULL |

| — | — | UNIQUE(student\_id, course\_id) |

\#### LessonProgress

| Атрибут | Тип | Ограничения |

\|---------|-----|-------------|

| id | integer | PK, auto-increment |

| enrollment\_id | integer | FK → Enrollment.id, NOT NULL |

| lesson\_id | integer | FK → Lesson.id, NOT NULL |

| is\_completed | boolean | NOT NULL, DEFAULT FALSE |

| completed\_at | timestamp | NULL |

| — | — | UNIQUE(enrollment\_id, lesson\_id) |

\#### Review

| Атрибут | Тип | Ограничения |

\|---------|-----|-------------|

| id | integer | PK, auto-increment |

| student\_id | integer | FK → User.id, NOT NULL |

| course\_id | integer | FK → Course.id, NOT NULL |

| rating | smallint | NOT NULL, CHECK 1..5 |

| comment | text | — |

| created\_at | timestamp | NOT NULL, DEFAULT NOW() |

| — | — | UNIQUE(student\_id, course\_id) |

\#### Payment

| Атрибут | Тип | Ограничения |

\|---------|-----|-------------|

| id | integer | PK, auto-increment |

| course\_id | integer | FK → Course.id, NOT NULL |

| student\_id | integer | FK → User.id, NOT NULL |

| amount | numeric(10,2) | NOT NULL, CHECK ≥ 0 |

| instructor\_share | numeric(10,2) | NOT NULL, CHECK ≥ 0 и ≤ amount |

| paid\_at | timestamp | NOT NULL, DEFAULT NOW() |

\### Кардинальность связей (нотация Crow's Foot)

| Связь | Кардинальность | Тип связи |

\|-------|----------------|-----------|

| User (instructor) → Course | 1 : 0..N | Неидентифицирующая |

| Course → Lesson | 1 : 1..N | \*\*Идентифицирующая\*\* |

| User (student) → Enrollment | 1 : 0..N | Неидентифицирующая |

| Course → Enrollment | 1 : 0..N | Неидентифицирующая |

| Enrollment → LessonProgress | 1 : 0..N | \*\*Идентифицирующая\*\* |

| Lesson → LessonProgress | 1 : 0..N | Неидентифицирующая |

| User (student) → Review | 1 : 0..N | Неидентифицирующая |

| Course → Review | 1 : 0..N | Неидентифицирующая |

| Course → Payment | 1 : 0..N | Неидентифицирующая |

| User (student) → Payment | 1 : 0..N | Неидентифицирующая |

\### Идентифицирующие vs неидентифицирующие

\- \*\*Идентифицирующие\*\* — дочерняя сущность не существует без родительской:

`  `- `Lesson` без `Course` не имеет смысла;

`  `- `LessonProgress` без `Enrollment` не существует.

\- \*\*Неидентифицирующие\*\* — FK ссылается на независимую сущность:

`  `- `Course.instructor\_id`, `Enrollment.student\_id`, `Review.course\_id` и т. д.

\*\*Решение по наследованию:\*\* выбрана \*\*единая таблица `User`\*\* с полем `role`, а не отдельные таблицы для студентов и преподавателей. Причина: у них почти одинаковый набор атрибутов, а домен не требует разной структуры. Это упрощает аутентификацию, авторизацию и запросы.

\---

\## Задание 3. Физическая модель — SQL для PostgreSQL 

\```sql

-- ============================================================

--  ДЗ №1. Вариант 1. Онлайн-курсы (EdTech)

--  PostgreSQL. Скрипт воспроизводим: DROP ... CASCADE + CREATE

-- ============================================================

-- ---------- Чистим в правильном порядке (дети -> родители) ----------

DROP TABLE IF EXISTS lesson\_progress CASCADE;

DROP TABLE IF EXISTS review          CASCADE;

DROP TABLE IF EXISTS payment         CASCADE;

DROP TABLE IF EXISTS enrollment      CASCADE;

DROP TABLE IF EXISTS lesson          CASCADE;

DROP TABLE IF EXISTS course          CASCADE;

DROP TABLE IF EXISTS "user"          CASCADE;

-- ============================================================

--  USER

-- ============================================================

CREATE TABLE "user" (

`    `id          SERIAL       PRIMARY KEY,

`    `email       VARCHAR(255) NOT NULL UNIQUE,

`    `full\_name   VARCHAR(255) NOT NULL,

`    `role        VARCHAR(20)  NOT NULL

`                `CHECK (role IN ('student', 'instructor', 'admin')),

`    `created\_at  TIMESTAMP    NOT NULL DEFAULT NOW()

);

-- ============================================================

--  COURSE

-- ============================================================

CREATE TABLE course (

`    `id              SERIAL        PRIMARY KEY,

`    `instructor\_id   INTEGER       NOT NULL,

`    `title           VARCHAR(255)  NOT NULL,

`    `description     TEXT,

`    `price           NUMERIC(10,2) NOT NULL DEFAULT 0

`                    `CHECK (price >= 0),

`    `is\_published    BOOLEAN       NOT NULL DEFAULT FALSE,

`    `created\_at      TIMESTAMP     NOT NULL DEFAULT NOW(),

`    `CONSTRAINT fk\_course\_instructor

`        `FOREIGN KEY (instructor\_id)

`        `REFERENCES "user"(id)

`        `ON DELETE RESTRICT

);

CREATE INDEX idx\_course\_instructor ON course(instructor\_id);

-- ============================================================

--  LESSON

-- ============================================================

CREATE TABLE lesson (

`    `id          SERIAL       PRIMARY KEY,

`    `course\_id   INTEGER      NOT NULL,

`    `title       VARCHAR(255) NOT NULL,

`    `content     TEXT,

`    `position    INTEGER      NOT NULL CHECK (position > 0),

`    `CONSTRAINT fk\_lesson\_course

`        `FOREIGN KEY (course\_id)

`        `REFERENCES course(id)

`        `ON DELETE CASCADE,

`    `CONSTRAINT uq\_lesson\_position UNIQUE (course\_id, position)

);

CREATE INDEX idx\_lesson\_course ON lesson(course\_id);

-- ============================================================

--  ENROLLMENT

-- ============================================================

CREATE TABLE enrollment (

`    `id            SERIAL      PRIMARY KEY,

`    `student\_id    INTEGER     NOT NULL,

`    `course\_id     INTEGER     NOT NULL,

`    `status        VARCHAR(20) NOT NULL DEFAULT 'active'

`                  `CHECK (status IN ('active', 'completed', 'cancelled')),

`    `enrolled\_at   TIMESTAMP   NOT NULL DEFAULT NOW(),

`    `completed\_at  TIMESTAMP,

`    `CONSTRAINT fk\_enrollment\_student

`        `FOREIGN KEY (student\_id) REFERENCES "user"(id) ON DELETE CASCADE,

`    `CONSTRAINT fk\_enrollment\_course

`        `FOREIGN KEY (course\_id) REFERENCES course(id) ON DELETE CASCADE,

`    `CONSTRAINT uq\_enrollment UNIQUE (student\_id, course\_id)

);

CREATE INDEX idx\_enrollment\_student ON enrollment(student\_id);

CREATE INDEX idx\_enrollment\_course  ON enrollment(course\_id);

-- ============================================================

--  LESSON\_PROGRESS

-- ============================================================

CREATE TABLE lesson\_progress (

`    `id              SERIAL    PRIMARY KEY,

`    `enrollment\_id   INTEGER   NOT NULL,

`    `lesson\_id       INTEGER   NOT NULL,

`    `is\_completed    BOOLEAN   NOT NULL DEFAULT FALSE,

`    `completed\_at    TIMESTAMP,

`    `CONSTRAINT fk\_lp\_enrollment

`        `FOREIGN KEY (enrollment\_id) REFERENCES enrollment(id) ON DELETE CASCADE,

`    `CONSTRAINT fk\_lp\_lesson

`        `FOREIGN KEY (lesson\_id) REFERENCES lesson(id) ON DELETE CASCADE,

`    `CONSTRAINT uq\_lp UNIQUE (enrollment\_id, lesson\_id)

);

CREATE INDEX idx\_lp\_enrollment ON lesson\_progress(enrollment\_id);

CREATE INDEX idx\_lp\_lesson     ON lesson\_progress(lesson\_id);

-- ============================================================

--  REVIEW

-- ============================================================

CREATE TABLE review (

`    `id          SERIAL       PRIMARY KEY,

`    `student\_id  INTEGER      NOT NULL,

`    `course\_id   INTEGER      NOT NULL,

`    `rating      SMALLINT     NOT NULL CHECK (rating BETWEEN 1 AND 5),

`    `comment     TEXT,

`    `created\_at  TIMESTAMP    NOT NULL DEFAULT NOW(),

`    `CONSTRAINT fk\_review\_student

`        `FOREIGN KEY (student\_id) REFERENCES "user"(id) ON DELETE CASCADE,

`    `CONSTRAINT fk\_review\_course

`        `FOREIGN KEY (course\_id) REFERENCES course(id) ON DELETE CASCADE,

`    `CONSTRAINT uq\_review UNIQUE (student\_id, course\_id)

);

CREATE INDEX idx\_review\_student ON review(student\_id);

CREATE INDEX idx\_review\_course  ON review(course\_id);

-- ============================================================

--  PAYMENT

-- ============================================================

CREATE TABLE payment (

`    `id                SERIAL        PRIMARY KEY,

`    `course\_id         INTEGER       NOT NULL,

`    `student\_id        INTEGER       NOT NULL,

`    `amount            NUMERIC(10,2) NOT NULL CHECK (amount >= 0),

`    `instructor\_share  NUMERIC(10,2) NOT NULL CHECK (instructor\_share >= 0),

`    `paid\_at           TIMESTAMP     NOT NULL DEFAULT NOW(),

`    `CONSTRAINT fk\_payment\_course

`        `FOREIGN KEY (course\_id) REFERENCES course(id) ON DELETE CASCADE,

`    `CONSTRAINT fk\_payment\_student

`        `FOREIGN KEY (student\_id) REFERENCES "user"(id) ON DELETE CASCADE,

`    `CONSTRAINT chk\_share\_le\_amount

`        `CHECK (instructor\_share <= amount)

);

CREATE INDEX idx\_payment\_course  ON payment(course\_id);

CREATE INDEX idx\_payment\_student ON payment(student\_id);

CREATE INDEX idx\_payment\_paid\_at ON payment(paid\_at);

\```

\### Что закрыто из требований

| Требование | Где реализовано |

\|------------|-----------------|

| `PRIMARY KEY` | Все таблицы, `SERIAL` |

| `FOREIGN KEY` | `course`, `lesson`, `enrollment`, `lesson\_progress`, `review`, `payment` |

| `CHECK` | `role`, `price >= 0`, `position > 0`, `status`, `rating 1..5`, `instructor\_share <= amount` |

| `NOT NULL` | На всех обязательных полях |

| `UNIQUE` | `user.email`, `lesson(course\_id, position)`, `enrollment(student\_id, course\_id)`, `review(student\_id, course\_id)`, `lesson\_progress(enrollment\_id, lesson\_id)` |

| Индексы на FK | `idx\_course\_instructor`, `idx\_lesson\_course`, `idx\_enrollment\_\*`, `idx\_lp\_\*`, `idx\_review\_\*`, `idx\_payment\_\*` |

| Воспроизводимость | Блок `DROP TABLE IF EXISTS ... CASCADE` в начале |

\---

\## Задание 4. Частые запросы 

Пять самых частых запросов к базе данных (описание на русском, без SQL):

1\. \*\*Вывести каталог опубликованных курсов с именем преподавателя, ценой и средней оценкой\*\*  

`   `\_Используется на главной странице платформы. Нужны `course` + `user` + `review` (агрегат `AVG(rating)`).\_

2\. \*\*Показать все уроки конкретного курса в правильном порядке\*\*  

`   `\_Экран прохождения курса студентом. Выборка из `lesson WHERE course\_id = ? ORDER BY position`.\_

3\. \*\*Получить список студентов курса с их прогрессом: сколько уроков пройдено из общего числа\*\*  

`   `\_Для преподавателя и админ-панели. `enrollment` + `lesson\_progress` + `lesson` с агрегацией `COUNT(\*) FILTER (WHERE is\_completed)`.\_

4\. \*\*Найти топ-10 курсов по количеству отзывов и средней оценке за последние 30 дней\*\*  

`   `\_Аналитика популярности. `review` + `course`, `GROUP BY`, `ORDER BY COUNT DESC, AVG DESC`, `LIMIT 10`.\_

5\. \*\*Рассчитать сумму, которую должен получить преподаватель за месяц по всем своим курсам\*\*  

`   `\_Реализует бизнес-требование об отчислениях. `payment` + `course`, `SUM(instructor\_share)`, фильтр по `paid\_at` и `instructor\_id`.\_

\---


