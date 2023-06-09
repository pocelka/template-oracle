set pagesize 9999
set linesize 9999
set heading off
set trim on

select
   lower(attribute)              -- error or warning
   || ' '
   || line || '/' || position    -- line and column
   || ' '
   || lower(name)                -- file name
   || case                       -- file extension
         when type = 'PACKAGE' then '.pks'
         when type = 'PACKAGE BODY' then '.pkb'
         when type = 'TYPE' then '.tps'
         when type = 'TYPE BODY' then '.tpb'
         else '.sql'
      end
   || ' '
   || replace(text, chr(10), ' ') -- remove line breaks from error text
   as user_errors
from user_errors
where 1 = 1
and attribute in ('ERROR', 'WARNING')
order by type, name, line, position
;
