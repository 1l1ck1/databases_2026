
DO $$
BEGIN
    INSERT INTO course (instructor_id, title, price)
    VALUES (1, 'Курс с отрицательной ценой', -100);

    RAISE NOTICE '[1] CHECK: неожиданно вставка прошла';
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE
            '[1] CHECK. Цена курса не может быть отрицательной — это экономически бессмысленно. '
            'Сообщение СУБД: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '[1] CHECK. Другая ошибка: %', SQLERRM;
END;
$$;



DO $$
BEGIN
    INSERT INTO course (instructor_id, title, price)
    VALUES (99999, 'Курс от призрака', 100);

    RAISE NOTICE '[2] FK: неожиданно вставка прошла';
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE
            '[2] FOREIGN KEY. Курс нельзя привязать к несуществующему преподавателю. '
            'Сообщение СУБД: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '[2] FK. Другая ошибка: %', SQLERRM;
END;
$$;



DO $$
BEGIN
    INSERT INTO "user" (email, full_name, role)
    VALUES ('alice@mail.com', 'Дубликат Алисы', 'student');

    RAISE NOTICE '[3] UNIQUE: неожиданно вставка прошла';
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE
            '[3] UNIQUE. Email должен быть уникальным — иначе пользователь не сможет однозначно войти в систему. '
            'Сообщение СУБД: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '[3] UNIQUE. Другая ошибка: %', SQLERRM;
END;
$$;


DO $$
BEGIN
    INSERT INTO "user" (email, full_name, role)
    VALUES (NULL, 'Без Email', 'student');

    RAISE NOTICE '[4] NOT NULL: неожиданно вставка прошла';
EXCEPTION
    WHEN not_null_violation THEN
        RAISE NOTICE
            '[4] NOT NULL. Email обязателен — без него невозможно идентифицировать пользователя. '
            'Сообщение СУБД: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '[4] NOT NULL. Другая ошибка: %', SQLERRM;
END;
$$;


DO $$
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM enrollment
        WHERE status = 'active'
        LIMIT 1
    ) THEN
        RAISE NOTICE '[5] Подготовка: нет активных записей — пропускаем демонстрацию';
    ELSE
        BEGIN
            INSERT INTO certificate (enrollment_id, serial_number, grade)
            SELECT id, 'CERT-2026-ABC123', 'passed'
            FROM enrollment
            WHERE status = 'active'
            LIMIT 1;

            RAISE NOTICE '[5] TRIGGER: неожиданно вставка прошла';
        EXCEPTION
            WHEN raise_exception THEN
                RAISE NOTICE
                    '[5] БИЗНЕС-ПРАВИЛО. Сертификат можно выдать только по завершённому курсу. '
                    'Сообщение СУБД: %', SQLERRM;
            WHEN others THEN
                RAISE NOTICE '[5] TRIGGER. Другая ошибка: %', SQLERRM;
        END;
    END IF;
END;
$$;



DO $$
DECLARE
    v_user_id   INTEGER;
    v_courses   INTEGER;
    v_enroll    INTEGER;
BEGIN

    INSERT INTO "user" (email, full_name, role)
    VALUES ('cascade_test@mail.com', 'Cascade Test', 'instructor')
    RETURNING id INTO v_user_id;

    INSERT INTO course (instructor_id, title, price)
    VALUES (v_user_id, 'Временный курс', 100);

    SELECT COUNT(*) INTO v_courses FROM course WHERE instructor_id = v_user_id;

    RAISE NOTICE '[BONUS] Создан пользователь id=%, курсов у него: %', v_user_id, v_courses;

    BEGIN
        DELETE FROM "user" WHERE id = v_user_id;
        RAISE NOTICE '[BONUS] Пользователь удалён. Проверьте, что стало с курсами.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE
                '[BONUS] Нельзя удалить преподавателя, пока у него есть курсы '
                '(ON DELETE RESTRICT на course.instructor_id). Сообщение СУБД: %',
                SQLERRM;
    END;
END;
$$;