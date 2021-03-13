CREATE OR REPLACE FUNCTION fc.find_empty_columns(schema_name text)
    RETURNS TABLE(tab_name text, col_name text) 
    LANGUAGE 'plpgsql'    
AS $BODY$
DECLARE
    col_name text;
	tab_name text;
	col_data_size bigint;
BEGIN
	DROP TABLE IF EXISTS temp_return_table;
	CREATE TEMPORARY TABLE temp_return_table(
	   	tab_name text,
		col_name text
	);
	FOR tab_name IN EXECUTE 'SELECT tablename FROM pg_tables WHERE  schemaname = '''||schema_name||'''' LOOP
		RAISE INFO '%',tab_name;
		FOR col_name IN EXECUTE 'SELECT column_name FROM information_schema.Columns WHERE table_schema = '''||schema_name||''' AND table_name = '''||tab_name||'''' LOOP
			RAISE INFO '%',col_name;
			EXECUTE 'SELECT SUM(CHAR_LENGTH("'|| col_name ||'"::text)) FROM '||schema_name||'.'||tab_name||'' INTO col_data_size;
			IF (col_data_size IS null OR col_data_size=0) THEN
				INSERT INTO temp_return_table values (tab_name,col_name);
			END IF;
		END LOOP;
	END LOOP;
	return query select *  from temp_return_table;	
END;
$BODY$;