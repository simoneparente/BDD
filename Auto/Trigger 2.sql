/*Si scriva il seguente trigger. Quando viene aggiornato un
viaggio esprimendo un valore per il casello di uscita si aggiornano anche gli
attributi Km e Tariffa recuperando i valori dalla tabella TARIFFE (la tariffa
dipende da ingresso, uscita e categoria dell’auto).*/

CREATE OR REPLACE FUNCTION v.update_viaggio() RETURNS trigger AS
    $$
    DECLARE
    prezzo v.tariffe.costo%TYPE;
    chilometraggio v.viaggio.KM%TYPE;

    BEGIN
        IF (NEW.uscita IS NOT NULL) THEN
            SELECT T.costo, T.KM
            INTO prezzo, chilometraggio
        FROM V.AUTO AS A NATURAL JOIN V.viaggio AS V,
             v.tariffe AS T
        WHERE (NEW.uscita=T.uscita)
        AND   (OLD.ingresso=T.ingresso)
        AND   (T.categoria=A.categoria);

            UPDATE v.viaggio
            SET km=chilometraggio, tariffa=prezzo
            WHERE OLD.codiceviaggio=codiceviaggio;
            RAISE NOTICE 'Old_Viaggio: %', OLD.codiceviaggio;
        END IF;
        RETURN NEW;
    END
    $$
LANGUAGE plpgsql;


CREATE OR REPLACE TRIGGER TRIGGER_2 AFTER UPDATE OF uscita ON v.viaggio
    FOR EACH ROW
    EXECUTE PROCEDURE v.update_viaggio();