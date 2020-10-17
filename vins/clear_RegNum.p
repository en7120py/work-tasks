/*------------------------------------------------------------------------
    File        : clear_RegNum.log
    Description : Процедура для очистки дополнительного реквизита LeaseRegistrationNumber
                  на VIN-e транспортного средства для повторной принудительной выгрузки в реестр.             
                  Лог-файл: clear_RegNum.log
    
    Author(s)   : dk
    Created     : Mon Sept 28 14:52:42 EEST 2020
    Notes       : Файл (listvin.txt), с требующими выгрузки винами должен лежать в home-каталоге 
  ----------------------------------------------------------------------*/
/*{bgpba.i}*/
{bislogin.i}
{intrface.get xclass}

DEFINE VARIABLE counter AS INT INITIAL 0 NO-UNDO.
DEFINE VARIABLE RegNum  AS CHARACTER NO-UNDO.
DEFINE VARIABLE obespech  AS character initial "л" NO-UNDO.
DEFINE VARIABLE DateEnd  AS CHARACTER NO-UNDO.
DEFINE VARIABLE Obesp  AS CHARACTER NO-UNDO.
DEFINE VARIABLE filelog AS CHARACTER NO-UNDO.
DEFINE STREAM log_strm.
filelog = 'clear_RegNum.log'.
OUTPUT STREAM log_strm TO VALUE(filelog) APPEND CONVERT TARGET "UTF-8".

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
   END.
END PROCEDURE.

PUT STREAM log_strm UNFORMATTED "Start - " Now SKIP.       
RUN readfile("listvin.txt"). /*считывает файл во временную таблицу ttfl*/
FOR EACH ttfl: 
    FOR EACH signs WHERE signs.file-name = 'term-obl' AND
        signs.code = "VIN-code" and
        signs.xattr-value = ttfl.tline:
            RegNum = GetXAttrvalueEx("term-obl", signs.surrogate, "LeaseRegistrationNumber",'').
            DateEnd = GetXAttrvalueEx("term-obl", signs.surrogate, "disposeDT",'').  
            if DateEnd <> "" then do:
                PUT STREAM log_strm UNFORMATTED "!TO CHECK!----------------filed----> " DateEnd " <----?"SKIP.
                PUT STREAM log_strm UNFORMATTED "VIN " ttfl.tline " retired " DateEnd ". LeaseRegNum passed." SKIP.           
                end.
            else do:
                counter = counter + 1.
                UpdateSigns("term-obl", signs.surrogate, "LeaseRegistrationNumber",'',?).
                PUT STREAM log_strm UNFORMATTED "!TO CHECK!----------------empty----> " DateEnd "<----?"SKIP.          
                PUT STREAM log_strm UNFORMATTED "LeaseRegNum cleaned.\nVIN - " ttfl.tline '\n regNum - ' RegNum SKIP.          
            end.
    end.  
end.

PUT STREAM log_strm UNFORMATTED counter ' VIN(s) changed.' SKIP. 
PUT STREAM log_strm UNFORMATTED "End - " Now SKIP. 
PUT STREAM log_strm UNFORMATTED '______________________________________________________________' SKIP.
MESSAGE  counter ' VIN(s) changed. The details -' filelog VIEW-AS ALERT-BOX.
OUTPUT CLOSE.
