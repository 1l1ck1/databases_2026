

\## Таблица нарушений

| № | Ограничение | Выполняемый запрос (SQL) | Сообщение СУБД | Понятное сообщение для пользователя | Как исправить |

\|---|-------------|--------------------------|----------------|-------------------------------------|---------------|

| 1 | \*\*CHECK\*\* | `INSERT INTO course (instructor\_id, title, price) VALUES (1, 'X', -100);` | `new row for relation "course" violates check constraint "course\_price\_check"` | «Цена курса не может быть отрицательной — стоимость должна быть ≥ 0.» | Указать неотрицательную цену (`price = 0` или больше). |

| 2 | \*\*FOREIGN KEY\*\* | `INSERT INTO course (instructor\_id, title, price) VALUES (99999, 'X', 100);` | `insert or update on table "course" violates foreign key constraint "fk\_course\_instructor"` | «Курс нельзя привязать к несуществующему преподавателю. Сначала создайте пользователя с ролью `instructor`.» | Создать пользователя с `role = 'instructor'` и использовать его `id`, либо указать существующий `instructor\_id`. |

| 3 | \*\*UNIQUE\*\* | `INSERT INTO "user" (email, full\_name, role) VALUES ('alice@mail.com', 'X', 'student');` | `duplicate key value violates unique constraint "user\_email\_key"` | «Пользователь с таким email уже зарегистрирован. Войдите под своим аккаунтом или используйте другой email.» | Использовать другой email либо выполнить вход/восстановление пароля для существующего. |

| 4 | \*\*NOT NULL\*\* | `INSERT INTO "user" (email, full\_name, role) VALUES (NULL, 'X', 'student');` | `null value in column "email" of relation "user" violates not-null constraint` | «Email обязателен — без него невозможно идентифицировать пользователя и отправить уведомления.» | Указать корректный email. |

| 5 | \*\*Триггер (бизнес-правило)\*\* | `INSERT INTO certificate (enrollment\_id, serial\_number, grade) VALUES (<active\_id>, 'CERT-2026-ABC123', 'passed');` | `Сертификат можно выдать только по завершённому курсу. Текущий статус: active` | «Нельзя выдать сертификат: курс ещё не завершён. Дождитесь статуса `completed` у записи на курс.» | Обновить `enrollment.status = 'completed'` (и `completed\_at = NOW()`), затем выдать сертификат. |
