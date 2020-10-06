/*------------------------------------------------------------------------
    File        : clear_RegNum.log
    Description : ��������� ��� ������� ���������������� ��������� LeaseRegistrationNumber
                  �� VIN-e ������������� �������� ��� ��������� �������������� �������� � ������.
                                  
                ���-����: clear_RegNum.log
    

    Author(s)   : dk
    Created     : Mon Sept 28 14:52:42 EEST 2020
    Notes       :
  ----------------------------------------------------------------------*/
{bgpba.i}
{bislogin.i}
{intrface.get xclass}
/*AHTFR29G707036676,HCMDCD91K00301805,HCMDCE91T00030179*/

DEFINE VARIABLE counter AS INT INITIAL 0 NO-UNDO.
DEFINE VARIABLE   vTmpStr  AS CHARACTER NO-UNDO.
DEFINE VARIABLE filelog AS CHARACTER NO-UNDO.
DEFINE STREAM log_strm.
filelog = 'clear_RegNum.log'.

OUTPUT STREAM log_strm TO VALUE(filelog) APPEND CONVERT TARGET "UTF-8".
PUT STREAM log_strm UNFORMATTED 'start search VIN '  SKIP.


DEFINE TEMP-TABLE ttfl NO-UNDO                       /*��������� �������, � ������� ����������� ���� �� ����� ��������������*/
   FIELD tline        AS CHARACTER.
   

PROCEDURE readfile:                               /*��������� ������ ����� ���������*/
   DEFINE INPUT PARAMETER filename AS CHARACTER.  /*��� �����*/ 
   DEFINE VARIABLE vLine      AS LONGCHAR NO-UNDO . /*���� ������ �� ������*/
   DEFINE VARIABLE iLine      AS INTEGER NO-UNDO . /*�������� ����� �����*/
   DEFINE VARIABLE textfromfile       AS LONGCHAR NO-UNDO . /*���� ����� �� �����*/
   DEFINE VARIABLE iLineCount AS INTEGER NO-UNDO .
   DEFINE VARIABLE NewLine    AS CHARACTER NO-UNDO . /*����������� ����� ?*/
   
   NewLine = CHR(13) + CHR(10). 
   COPY-LOB FROM FILE filename TO textfromfile NO-ERROR.
   iLineCount = NUM-ENTRIES(textfromfile, NewLine) .
   DO iLine = 1 TO iLineCount - 1:                          /*������ ���������� �� ������ ������, ��� ��� �� ������� ����� �������*/   
      vLine = TRIM(ENTRY(iLine, textfromfile, NewLine)) . /*���� ������ �� ������*/
      STATUS DEFAULT 'Read file. ' + ' ' +  ' line ' +  STRING(iLine). 
      CREATE ttfl.
      ASSIGN ttfl.tline    = ENTRY(1, vLine).
/*      MESSAGE "line " ttfl.tline  VIEW-AS ALERT-BOX.*/
   END.
   END PROCEDURE.


RUN readfile("listvin.txt"). /*��������� ���� �� ��������� ������� ttfl*/

FOR EACH ttfl: 
/*MESSAGE "outer proc readfile " ttfl.tline  VIEW-AS ALERT-BOX.*/
PUT STREAM log_strm UNFORMATTED 'start search VIN ' ttfl.tline  SKIP.
    FOR EACH signs WHERE signs.file-name = 'term-obl' AND
            signs.code = "VIN-code" and
            signs.xattr-value = ttfl.tline:
    /*            assign signs.xattr-value = input_vin_new.*/
                counter = counter + 1.
/*              MESSAGE "found " counter '. ' ttfl.tline  VIEW-AS ALERT-BOX.*/
                MESSAGE signs.surrogate VIEW-AS ALERT-BOX. 
                /*������,������|1[...]SD|5|01/01/80|2,543,01/01/80,1*/  
                vTmpStr = GetXAttrvalueEx("term-obl", signs.surrogate, "LeaseRegistrationNumber",'').
                MESSAGE "vTmpStr" vTmpStr VIEW-AS ALERT-BOX.
                PUT STREAM log_strm UNFORMATTED 'clering RegNum ' vTmpStr "for " String(signs.surrogate) SKIP.
                UpdateSigns("term-obl", signs.surrogate, "LeaseRegistrationNumber",'',?).
            end.
    if counter = 0 then do:
        MESSAGE counter ' No changes.' VIEW-AS ALERT-BOX.
        PUT STREAM log_strm UNFORMATTED 'No changes.' SKIP. 
    end.
end.

PUT STREAM log_strm UNFORMATTED counter ' VIN(s) changed.' SKIP. 
PUT STREAM log_strm UNFORMATTED '______________________________________________________________' SKIP.
OUTPUT CLOSE.
