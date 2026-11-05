CREATE OR REPLACE FUNCTION bogosort(mas INT[])
RETURNS INT[] LANGUAGE plpgsql AS $$
DECLARE
    is_sorted BOOLEAN;
    i INTEGER;
    len INTEGER;
BEGIN
    len := array_length(mas, 1);

    IF len IS NULL OR len <= 1 THEN
        RETURN mas;
    END IF;

    LOOP
        is_sorted := TRUE;
        
        FOR i IN 1 .. (len - 1) LOOP
            IF mas[i] > mas[i + 1] THEN
                is_sorted := FALSE;
                EXIT;
            END IF;
        END LOOP;

        IF is_sorted THEN
            RETURN mas;
        END IF;

        SELECT ARRAY_AGG(x ORDER BY random())
        INTO mas
        FROM unnest(mas) AS x;
        
        RAISE NOTICE 'Текущая попытка: %', mas;
        
    END LOOP;
END;
$$;

SELECT bogosort(array[1, 3, 4, 3, 5, -6, 0]);





