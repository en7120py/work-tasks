/*------------------------------------------------------------------------
    File        : rewrite_vin.p
    Description : Процедура для изменения VIN-code или VIN2-code транспортного средства.
    
                Choise vin: 1 or 2 - ввести 1 для изменения VIN, ввести 2 - для изменения VIN2.
                Enter vin - ввести вин-номер, который нужно изменить.
                Enter vin - new value - новый номер VIN-а.
                
                Лог-файл: rewrite_vin.log
    

    Author(s)   : dk
    Created     : Mon Sept 7 14:52:42 EEST 2020
    Notes       :
  ----------------------------------------------------------------------*/

{bislogin.i}
{intrface.get xclass}
DEFINE VARIABLE code_vin AS CHAR.

DEFINE VARIABLE choise_vin AS CHAR NO-UNDO INIT '' LABEL 'Choise vin: 1 or 2' FORMAT 'x(1)'.
UPDATE choise_vin WITH FRAME fId.
DEFINE VARIABLE input_vin AS CHAR NO-UNDO INIT '' LABEL 'Enter vin' FORMAT 'x(20)'.
UPDATE input_vin WITH FRAME fId.
HIDE FRAME fId.
DEFINE VARIABLE input_vin_new AS CHAR NO-UNDO INIT '' LABEL 'Enter vin - new value' FORMAT 'x(20)'.
UPDATE input_vin_new WITH FRAME fId.
HIDE FRAME fId.
DEFINE VARIABLE filelog AS CHARACTER NO-UNDO.
DEFINE STREAM log_strm.

filelog = 'rewrite_vin.log'.
OUTPUT STREAM log_strm TO VALUE(filelog) APPEND CONVERT TARGET "UTF-8".
PUT STREAM log_strm UNFORMATTED 'search VIN ' input_vin SKIP.


IF choise_vin = '1' THEN DO:
    code_vin='VIN-code'.
    END.
ELSE DO:
    code_vin='VIN2-code'.
    END.
    
    
FOR EACH signs WHERE signs.file-name = 'term-obl' AND
signs.code = code_vin and
signs.xattr-value = input_vin:         
    assign signs.xattr-value = input_vin_new.
    display signs.
    PUT STREAM log_strm UNFORMATTED 'for 'signs.surrogate SKIP.
    PUT STREAM log_strm UNFORMATTED 'change ' code_vin ' : ' input_vin ' -----> ' input_vin_new " was successful" SKIP.
    
END.

PUT STREAM log_strm UNFORMATTED '___________________________________________________________' SKIP.

OUTPUT CLOSE.
