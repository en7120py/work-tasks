/*------------------------------------------------------------------------
    File        : rewrite_vin.p
    Description : ��楤�� ��� ��������� VIN �࠭ᯮ�⭮�� �।�⢠.
    
                Choise vin: 1 or 2 - ����� 1 ��� ��������� VIN, ����� 2 - ��� ��������� VIN2.
                Enter vin - ����� ���-�����, ����� �㦭� ��������.
                Enter vin - new value - ���� ����� VIN-�.
                
                ���-䠩�: rewrite_vin.log
    

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
filelog = 'rewrite_vin.log'.
OUTPUT STREAM log_strm TO VALUE(filelog) APPEND CONVERT TARGET "UTF-8".
PUT STREAM log_strm UNFORMATTED '��ࠡ��뢠���� VIN �࠭ᯮ�⭮�� �।�⢠ ' input_vin SKIP.


IF choise_vin = '1' THEN DO:
    code_vin='VIN-code'.
    END.
ELSE DO:
    code_vin='VIN2-code'.
    END.


FOR EACH signs WHERE signs.file-name = 'term-obl' AND
/*signs.code = 'VIN2-code' and*/
signs.code = code_vin and
signs.xattr-value = input_vin:
display signs.
display "code_vin" code_vin.
assign signs.xattr-value = input_vin_new.
end.

PUT STREAM log_strm UNFORMATTED '������� ' input_vin '��' input_vin_new SKIP.
PUT STREAM log_strm UNFORMATTED '___________________________________________________________' SKIP.

OUTPUT CLOSE.
