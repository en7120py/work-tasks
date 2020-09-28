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
/*exs XLRTEH4300G230462*/
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

DEFINE VARIABLE counter AS INT INITIAL 0 NO-UNDO.


filelog = 'rewrite_vin.log'.
OUTPUT STREAM log_strm TO VALUE(filelog) APPEND CONVERT TARGET "UTF-8".
PUT STREAM log_strm UNFORMATTED 'search VIN ' input_vin SKIP.


IF choise_vin = '1' THEN DO:
    code_vin='VIN-code'.
    END.
ELSE DO:
    code_vin='VIN2-code'.
    END.
    
    
IF choise_vin='' or input_vin='' or input_vin_new='' THEN DO:
    MESSAGE "Fill in all the fields!"  VIEW-AS ALERT-BOX.
    PUT STREAM log_strm UNFORMATTED 'Empty field(s)!' SKIP. 
    END.
ELSE DO:
/*    MESSAGE "ok" VIEW-AS ALERT-BOX.*/
    FOR EACH signs WHERE signs.file-name = 'term-obl' AND
    signs.code = code_vin and
    signs.xattr-value = input_vin:         
        assign signs.xattr-value = input_vin_new.
        counter = counter + 1.
        /*debugging*/
/*        display signs.*/       
/*        display signs.code.               */
/*        display signs.surrogate.          */
/*        display "new: " signs.xattr-value.*/
        
        MESSAGE "For " signs.surrogate "\n" signs.code "changed. New value: " signs.xattr-value VIEW-AS ALERT-BOX.
            
        PUT STREAM log_strm UNFORMATTED 'for 'signs.surrogate SKIP.
        PUT STREAM log_strm UNFORMATTED 'change ' code_vin ' : ' input_vin ' -----> ' input_vin_new " was successful" SKIP.
    end.
    
    if counter = 0 then do:
        MESSAGE counter ' No changes.' VIEW-AS ALERT-BOX.
        PUT STREAM log_strm UNFORMATTED 'No changes.' SKIP. 
    end.
 END.

PUT STREAM log_strm UNFORMATTED counter ' VIN(s) changed.' SKIP. 
PUT STREAM log_strm UNFORMATTED '______________________________________________________________' SKIP.

OUTPUT CLOSE.
