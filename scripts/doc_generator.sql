set pagesize 20000
set linesize 20000
set heading off
set verify off
set trim on
set termout off
set feedback off

set serveroutput on

spool &2

declare

   c_package_prefix     constant varchar2(15) := '&1';
   c_eol                constant varchar(5) := chr(10);

   type t_source is table of varchar2(4000) index by binary_integer;

   g_output                   varchar2(32000);
   g_toc                      varchar2(32000);
   g_source                   t_source;

   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --This function is used to parse description for package/procedure/function.
   function get_description(
      p_start_line         in number,
      p_end_line           in number) return varchar2 is

      l_comment_found         boolean := false;
      l_source_row            user_source.text%type;
      l_output                varchar2(32000);

   begin

      <<pkg_desc>>
      for i in p_start_line..(p_end_line - 1)
      loop

         --I want to skip rows which don't contain comment definition.
         if (instr(g_source(i), '/**') = 0
               and not l_comment_found) then
            continue;
         end if;

         if (instr(g_source(i), '/**') > 0) then
            l_comment_found := true;
         end if;

         --First let's replace comment start and end from the row and remove leading and trailing spaces.
         --I also want to remove new line characters as I assume that multiline comment will be with <br> tag which can
         --be interpreted by markdown as new line.
         l_source_row := replace(g_source(i), '/**', null);
         l_source_row := replace(l_source_row, '**/', null);
         l_source_row := replace(l_source_row, chr(10), null);
         l_source_row := replace(l_source_row, chr(13), null);
         l_source_row := trim(l_source_row);

         --It is possible that row in the source is just new line character. In that case I want to skip row. But at the
         --same time I want to keep new line characters in text to preserve comment meaning.
         if (l_source_row is not null
               and l_source_row <> chr(10)
               and l_source_row <> chr(13)) then

            l_output := l_output
                        || c_eol
                        || l_source_row;
         end if;

      end loop pkg_desc;

      return l_output;

   end get_description;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --Function is used to parse package description from multiline comment.
   function get_package_description(
      p_package_name       in varchar2) return varchar2 is

      l_end_line              user_identifiers.line%type;
      l_desc                  varchar2(32000);

   begin

      --With this I want to find out on which position is the first procedure/function declaration so I can limit the
      --number of the loops in the source code.
      select i.line
      into l_end_line
      from user_identifiers i
      where 1 = 1
      and object_name = upper(p_package_name)
      and object_type = 'PACKAGE'
      and type in ('PROCEDURE','FUNCTION')
      order by
         object_name,
         line
      fetch first 1 row only;

      l_desc := get_description(p_start_line => 1,
                                p_end_line => l_end_line);

      return l_desc;

   end get_package_description;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --This function is used to parse description for procedure / function argument.
   function get_argument_description(
      p_argument_name      in varchar2,
      p_first_line         in number,
      p_last_line          in number) return varchar2 is

      l_arg_description       varchar2(2000);

   begin

      if (p_argument_name is not null) then

         <<arg_desc>>
         for i in p_first_line..(p_last_line - 1)
         loop

            if ( instr(lower(g_source(i)), p_argument_name) = 0 ) then
               continue;
            end if;

            l_arg_description := regexp_substr(g_source(i), '[^--]+', 1, 2);
            l_arg_description := replace(l_arg_description, chr(10), null);
            l_arg_description := replace(l_arg_description, chr(13), null);
            l_arg_description := trim(l_arg_description);

            if (l_arg_description is not null) then
               exit arg_desc;
            end if;

         end loop arg_desc;

      end if;

      return l_arg_description;

   end get_argument_description;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

   --This function is used to get individual procedures/functions inside the package and print them as a table in
   --markdown.
   function get_arguments(
      p_package_name       in varchar2,
      p_routine_name       in varchar2,
      p_first_line         in number,
      p_last_line          in number) return varchar2 is

      l_arg_description       varchar2(32000);

   begin

      <<args>>
      for cur_arg in (select
                           object_name,
                           argument_name,
                           position,
                           data_type,
                           in_out
                        from user_arguments
                        where 1 = 1
                        and package_name = p_package_name
                        and object_name = p_routine_name
                        order by
                           object_name,
                           position)
      loop

         l_arg_description := l_arg_description
                              || '| '
                              || lower(cur_arg.argument_name)
                              || ' | '
                              || lower(cur_arg.in_out)
                              || ' | '
                              || lower(cur_arg.data_type)
                              || ' | '
                              || get_argument_description(p_argument_name => lower(cur_arg.argument_name),
                                                          p_first_line => p_first_line,
                                                          p_last_line => coalesce(p_last_line, g_source.count))
                              || '|'
                              || c_eol;

      end loop args;

      if (l_arg_description is not null) then

         l_arg_description := '| Parameter | Type | Data Type | Description |'
                              || c_eol
                              || '| --- | --- | --- | --- |'
                              || c_eol
                              || l_arg_description;

      end if;
      return l_arg_description;

   end get_arguments;
   --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

begin

   g_toc := '<!-- DO NOT EDIT THIS FILE DIRECTLY - it is generated using document generator. -->';
   g_toc := g_toc
            || c_eol
            || '<!-- markdownlint-disable MD012 MD033 MD041 -->';

   --I want to go through packages for which I'm going to generate documentation.
   <<pkg>>
   for cur_pkg in (select lower(object_name)  as package_name
                     from user_objects
                     where 1 = 1
                     and object_type = 'PACKAGE'
                     and object_name like upper(c_package_prefix) || '%')
   loop

      g_output := '# Package '
                  || cur_pkg.package_name
                  || c_eol;

      g_toc := g_toc
               || c_eol
               || c_eol
               || '- [Package '
               || cur_pkg.package_name
               || '](#package-'
               || cur_pkg.package_name
               || ')';

      --I want to get source code for package spec into memory as I will be using this several times. Might be faster
      --then going always into the view.
      select text
      bulk collect into g_source
      from user_source
      where 1 = 1
      and type = 'PACKAGE'
      and name = upper(cur_pkg.package_name);

      --Package description
      g_output := g_output
                  || get_package_description(p_package_name => cur_pkg.package_name)
                  || c_eol;

      --Description and details for procedures / functions inside the package.
      <<routine>>
      for cur_rout in (select
                           i.name,
                           i.type,
                           i.line,
                           lead(i.line, 1, null) over (partition by object_name order by line) as next_line
                        from user_identifiers i
                        where 1 = 1
                        and object_name = upper(cur_pkg.package_name)
                        and object_type = 'PACKAGE'
                        and type in ('PROCEDURE','FUNCTION')
                        order by
                           object_name,
                           line)
      loop

         --Sub routine header
         g_output := g_output
                     || c_eol
                     || '## '
                     || initcap(cur_rout.type)
                     || ' '
                     || lower(cur_rout.name)
                     || c_eol;

         g_toc := g_toc
                  || c_eol
                  || '  - ['
                  || initcap(cur_rout.type)
                  || ' '
                  || lower(cur_rout.name)
                  || '](#'
                  || lower(cur_rout.type)
                  || '-'
                  || lower(cur_rout.name)
                  || ')';

         g_output := g_output
                     || get_description(p_start_line => cur_rout.line,
                                        p_end_line => coalesce(cur_rout.next_line, g_source.count));

         g_output := g_output
                     || c_eol
                     || get_arguments(p_package_name => upper(cur_pkg.package_name),
                                      p_routine_name => cur_rout.name,
                                      p_first_line => cur_rout.line,
                                      p_last_line => cur_rout.next_line);


      end loop routine;

   end loop pkg;

   g_output := g_toc
               || c_eol
               || c_eol
               || g_output;

   sys.dbms_output.put_line(g_output);

end;
/

spool off
