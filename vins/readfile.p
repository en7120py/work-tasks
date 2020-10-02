/*------------------------------------------------------------------------
    File        : LeaseRegistrationNumber_clear.p
    Description : Процедура процедура чтения файла построчно. 
                  Записывает во временную таблицу.              

    Author(s)   : dk
    Created     : Fr Oct 2 09:52:42 EEST 2020
    Notes       :
  ----------------------------------------------------------------------*/

{bgpba.i}
{intrface.get xclass}
DEFINE TEMP-TABLE ttfl NO-UNDO                       /*временная таблица, в которую выгружается инфа из файла бисквитовского*/
   FIELD tline        AS CHARACTER.

PROCEDURE readfile:                               /*процедура чтения файла построчно*/
   DEFINE INPUT PARAMETER filename AS CHARACTER.  /*имя файла*/ 
   DEFINE VARIABLE vLine      AS LONGCHAR NO-UNDO . /*одни запись из строки*/
   DEFINE VARIABLE iLine      AS INTEGER NO-UNDO . /*итератор строк файла*/
   DEFINE VARIABLE textfromfile       AS LONGCHAR NO-UNDO . /*весь текст из файла*/
   DEFINE VARIABLE iLineCount AS INTEGER NO-UNDO .
   DEFINE VARIABLE NewLine    AS CHARACTER NO-UNDO . /*разделитель строк ?*/
   
   NewLine = CHR(13) + CHR(10). 
   COPY-LOB FROM FILE filename TO textfromfile NO-ERROR.
   iLineCount = NUM-ENTRIES(textfromfile, NewLine) .
   DO iLine = 1 TO iLineCount - 1:                          /*разбор начинается со второй строки, так как не считаем шапку таблицы*/   
      vLine = TRIM(ENTRY(iLine, textfromfile, NewLine)) . /*одна запись из строки*/
      STATUS DEFAULT 'Read file. ' + ' ' +  ' line ' +  STRING(iLine). 
      CREATE ttfl.
      ASSIGN ttfl.tline    = ENTRY(1, vLine).
      MESSAGE "line " ttfl.tline  VIEW-AS ALERT-BOX.  
   END.
   END PROCEDURE.


RUN readfile("listvin.txt").
/*MESSAGE "end"  VIEW-AS ALERT-BOX.*/
