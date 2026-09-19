
DROP TABLE IF EXISTS certificate       CASCADE;
DROP TABLE IF EXISTS course_category   CASCADE;
DROP TABLE IF EXISTS category          CASCADE;


CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,   -- для URL / фильтра
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_category_slug ON category(slug);


CREATE TABLE course_category (
    course_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),

    PRIMARY KEY (course_id, category_id),

    CONSTRAINT fk_cc_course
        FOREIGN KEY (course_id)   REFERENCES course(id)   ON DELETE CASCADE,

    CONSTRAINT fk_cc_category
        FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE
);


CREATE INDEX idx_cc_course   ON course_category(course_id);
CREATE INDEX idx_cc_category ON course_category(category_id);


CREATE TABLE certificate (
    id SERIAL PRIMARY KEY,
    enrollment_id INTEGER NOT NULL UNIQUE,  
    serial_number VARCHAR(64) NOT NULL UNIQUE,  
    issued_at TIMESTAMP NOT NULL DEFAULT NOW(),
    pdf_url TEXT,
    grade VARCHAR(10) NOT NULL DEFAULT 'passed'
                   CHECK (grade IN ('passed', 'failed', 'excellent')),

    CONSTRAINT fk_cert_enrollment
        FOREIGN KEY (enrollment_id) REFERENCES enrollment(id) ON DELETE CASCADE,


    CONSTRAINT chk_cert_serial_format
        CHECK (serial_number ~ '^CERT-[0-9]{4}-[A-Z0-9]{6}$')
);

CREATE INDEX idx_cert_enrollment ON certificate(enrollment_id);
CREATE INDEX idx_cert_issued_at  ON certificate(issued_at);


CREATE OR REPLACE FUNCTION trg_certificate_only_for_completed()
RETURNS TRIGGER AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    SELECT status INTO v_status
    FROM enrollment
    WHERE id = NEW.enrollment_id;

    IF v_status IS NULL THEN
        RAISE EXCEPTION 'Запись на курс с id=% не найдена', NEW.enrollment_id;
    END IF;

    IF v_status <> 'completed' THEN
        RAISE EXCEPTION
            'Сертификат можно выдать только по завершённому курсу. Текущий статус: %',
            v_status;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_cert_insert ON certificate;
CREATE TRIGGER trg_cert_insert
    BEFORE INSERT OR UPDATE ON certificate
    FOR EACH ROW
    EXECUTE FUNCTION trg_certificate_only_for_completed();