LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY exp24 IS
PORT(CLK:IN STD_LOGIC;
     S1,S2,RST:IN STD_LOGIC;
     SPK:OUT STD_LOGIC;
     LED:OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
     DISPLAY:OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
     SEL:OUT STD_LOGIC_VECTOR(2 DOWNTO 0));
END ENTITY exp24;
ARCHITECTURE BHV OF exp24 IS
SIGNAL CLK1,CLK2:STD_LOGIC;
SIGNAL S,M:STD_LOGIC;  --��λ�ź�
SIGNAL TEST1,TEST2:STD_LOGIC;
SIGNAL COUNTSS,COUNTMM,COUNTHH:STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL FLAG1,FLAG2:STD_LOGIC;
SIGNAL ge1,shi1,ge2,shi2,ge3,shi3:INTEGER;
SIGNAL DATA:INTEGER;
SIGNAL DIV:STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL S11,S22:STD_LOGIC;
SIGNAL SS:INTEGER RANGE 0 TO 63;
BEGIN
--��������
P1:PROCESS(CLK)
BEGIN
     IF CLK'EVENT AND CLK='1' THEN
        DIV<=DIV+1;
     END IF;
END PROCESS P1;

P2:PROCESS(DIV(7))
BEGIN
     IF DIV(8)'EVENT AND DIV(8)='1' THEN
        S11<=NOT S1;
        S22<=NOT S2;
     END IF;
END PROCESS P2;

--����1HZ���ź�
 PROCESS(CLK)
   VARIABLE Q1:STD_LOGIC_VECTOR(15 DOWNTO 0);
   VARIABLE Q2:STD_LOGIC_VECTOR(15 DOWNTO 0);
   BEGIN
       IF CLK'EVENT AND CLK='1' THEN
          IF Q1<5000 THEN 
             Q1:=Q1+1;
          ELSE 
             CLK1<=NOT(CLK1);
             Q1:=(OTHERS=>'0');
          END IF;
       END IF;
       IF CLK'EVENT AND CLK='1' THEN
          IF Q2<5 THEN 
             Q2:=Q1+1;
          ELSE 
             CLK2<=NOT(CLK2);
             Q2:=(OTHERS=>'0');
          END IF;
       END IF;
 END PROCESS;
 
--����ı仯
 PROCESS(CLK1,RST)
   VARIABLE COUNTS:INTEGER RANGE 0 TO 63:=0;
   BEGIN
     IF RST='0' THEN COUNTS:=0;
       ELSIF CLK1'EVENT AND CLK1='1' THEN COUNTS:=COUNTS+1; 
            IF COUNTS=60 THEN 
               COUNTS:=0;
               S<='1';
            ELSE  
               S<='0';
            END IF;
     END IF;
       SS<=COUNTS; 
       COUNTSS<=CONV_STD_LOGIC_VECTOR(COUNTS,7);
 END PROCESS;      
--����ı仯
 PROCESS(S11,S)
   BEGIN
       TEST1<=S11 OR S;
 END PROCESS;
    
 PROCESS(TEST1,RST)
   VARIABLE COUNTM:INTEGER RANGE 0 TO 63:=0;
   BEGIN
	 IF RST='0' THEN COUNTM:=0;
       ELSIF TEST1'EVENT AND TEST1='1' THEN COUNTM:=COUNTM+1;
            IF COUNTM=60 THEN 
               COUNTM:=0;
               M<='1';
            ELSE
               M<='0';    
            END IF;  
     END IF; 
       COUNTMM<=CONV_STD_LOGIC_VECTOR(COUNTM,7);
 END PROCESS;              
--ʱ��ı仯
 PROCESS(S22,M)
   BEGIN
       TEST2<=S22 OR M;
 END PROCESS;
 
 PROCESS(TEST2,RST)
   VARIABLE COUNTH:STD_LOGIC_VECTOR(6 DOWNTO 0);
   BEGIN
		IF RST='0' THEN COUNTH:="0000000";
          ELSIF TEST2'EVENT AND TEST2='1' THEN
             IF COUNTH<23 THEN 
                COUNTH:=COUNTH+1;
             ELSE
                COUNTH:=(OTHERS=>'0');  
             END IF;
        END IF;
        COUNTHH<=COUNTH;
 END PROCESS;
 
--�����������LED�����ı�־λ
 PROCESS(SS,COUNTMM)
   BEGIN
      IF COUNTMM="111011" THEN
        CASE SS IS
        WHEN 50 TO 55 => FLAG1<='1';FLAG2<='0';
        WHEN 56 TO 59 => FLAG1<='1';FLAG2<='1';
        WHEN OTHERS =>FLAG1<='0';FLAG2<='0';
        END CASE; 
      ELSE  FLAG1<='0';FLAG2<='0';     
      END IF;
 END PROCESS;
 
--�����������LED�Ƶ���˸
 PROCESS(FLAG1,FLAG2,COUNTSS)
   VARIABLE LEDD:STD_LOGIC_VECTOR(3 DOWNTO 0):="0001";
   BEGIN
      IF FLAG1='1' THEN 
        IF CLK1='1' THEN SPK<=CLK2;
        ELSE SPK<='0';
        END IF;
--      IF(COUNTSS REM 10)='0' THEN
--         SPK<=CLK2;
--      ELSE SPK<='0';
--      END IF;
      END IF;
      IF FLAG2='1' THEN 
        IF CLK1'EVENT AND CLK1='1' THEN
        LEDD(3 DOWNTO 1):=LEDD(2 DOWNTO 0);
        END IF;
        LED<=LEDD;
      ELSE
		LED<="0000";
        LEDD:="0001";
      END IF;        
  END PROCESS;
  
--��ʾ����
 PROCESS(COUNTSS,COUNTMM,COUNTHH)
   VARIABLE temp1,temp2,temp3:INTEGER;
   BEGIN
       temp1:=CONV_INTEGER(COUNTSS);
       ge1<=temp1 REM 10;
       shi1<=(temp1/10) REM 10;
       temp2:=CONV_INTEGER(COUNTMM);
       ge2<=temp2 REM 10;
       shi2<=(temp2/10) REM 10;
       temp3:=CONV_INTEGER(COUNTHH);
       ge3<=temp3 REM 10;
       shi3<=(temp3/10) REM 10;
 END PROCESS;
 
 PROCESS(CLK,ge1,shi1,ge2,shi2,ge3,shi3)
    VARIABLE Q2: STD_LOGIC_VECTOR(2 DOWNTO 0);
    BEGIN
    IF CLK' EVENT AND CLK='1' THEN
       Q2:=Q2+1;
    END IF;
    CASE Q2 IS
     WHEN "000" => DATA<=ge1;  SEL<="111";
     WHEN "001" => DATA<=shi1; SEL<="110";
     WHEN "010" => DATA<=10;   SEL<="101";
     WHEN "011" => DATA<=ge2;  SEL<="100";
     WHEN "100" => DATA<=shi2; SEL<="011";
     WHEN "101" => DATA<=10;   SEL<="010";
     WHEN "110" => DATA<=ge3;  SEL<="001";
     WHEN "111" => DATA<=shi3; SEL<="000";
    END CASE;
 END PROCESS;
    
 PROCESS(DATA)
    BEGIN
    CASE DATA IS
     WHEN 0 => DISPLAY<="0111111";
     WHEN 1 => DISPLAY<="0000110";
     WHEN 2 => DISPLAY<="1011011";
     WHEN 3 => DISPLAY<="1001111";
     WHEN 4 => DISPLAY<="1100110";
     WHEN 5 => DISPLAY<="1101101";
     WHEN 6 => DISPLAY<="1111101";
     WHEN 7 => DISPLAY<="0000111";
     WHEN 8 => DISPLAY<="1111111";
     WHEN 9 => DISPLAY<="1101111";
     WHEN 10=> DISPLAY<="1000000";
     WHEN OTHERS => NULL;
    END CASE;
 END PROCESS;
END BHV;
         
          

   
 
       
       
 
