
---------------------------------------------------------------------------------------------
--    calcul_param_1.vhd
---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------
--    Université de Sherbrooke - Département de GEGI
--
--    Version         : 5.0
--    Nomenclature    : inspiree de la nomenclature 0.2 GRAMS
--    Date            : 16 janvier 2020, 4 mai 2020
--    Auteur(s)       : 
--    Technologie     : ZYNQ 7000 Zybo Z7-10 (xc7z010clg400-1) 
--    Outils          : vivado 2019.1 64 bits
--
---------------------------------------------------------------------------------------------
--    Description (sur une carte Zybo)
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------
-- À FAIRE: 
-- Voir le guide de la problématique
---------------------------------------------------------------------------------------------
--
---------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;  -- pour les additions dans les compteurs
USE ieee.numeric_std.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

----------------------------------------------------------------------------------
-- 
----------------------------------------------------------------------------------
entity calcul_param_1 is
    Port (
    i_bclk    : in   std_logic; -- bit clock (I2S)
    i_reset   : in   std_logic;
    i_en      : in   std_logic; -- un echantillon present a l'entrée
    i_ech     : in   std_logic_vector (23 downto 0); -- echantillon en entrée
    o_param   : out  std_logic_vector (7 downto 0)   -- paramètre calculé
    );
end calcul_param_1;

----------------------------------------------------------------------------------

architecture Behavioral of calcul_param_1 is

---------------------------------------------------------------------------------
-- Signaux
----------------------------------------------------------------------------------
    
    

---------------------------------------------------------------------------------------------
--    Description comportementale
---------------------------------------------------------------------------------------------

type fonction_etat is (
     init,
     att_enable,
     compte1,
     fois2,
     save, 
     reset
     );
     
    signal etat_present, etat_suivant: fonction_etat; 
    signal compte_reset : std_logic;
    signal compte_en : std_logic;
    signal compte_ini : unsigned (7 downto 0);
    signal compte_next : unsigned (7 downto 0);
    signal param_mem : std_logic_vector (7 downto 0);   

begin 

process(i_bclk, i_reset)
    begin
       if (i_reset = '1') then
             etat_present <= init;
       else
           if rising_edge(i_bclk) then
                 etat_present <= etat_suivant;
           end if;
       end if;
end process;

process(i_bclk, i_reset)
    begin
       if (compte_reset = '1') then
             compte_ini <= "00000000";
       else
           if rising_edge(i_bclk) and compte_en = '1' then
                 compte_ini <= compte_ini + 1 ;
           end if;
       end if;
end process;

process(etat_present, i_en, i_ech, compte_ini, i_bclk, param_mem)
begin
    case etat_present is
        when init =>       
            param_mem <= "00000000";
            compte_en <= '0';
            compte_reset <= '1';
            etat_suivant <= att_enable;
            
        when att_enable =>
            if i_en = '1' and i_ech(23) = '0' then
                compte_reset <= '0';
                compte_en <= '0';
                etat_suivant <= compte1;
            elsif i_en = '1' and i_ech(23) = '1' then
                compte_reset <= '0';
                compte_en <= '0';
                etat_suivant <= fois2;
            else 
                compte_reset <= '0';
                compte_en <= '0';
                etat_suivant <= att_enable;
            end if;
                
        when compte1 =>
            if (compte_ini = "11111111" ) then
                etat_suivant <= att_enable;
            else
                compte_en <= '1';
                etat_suivant <= att_enable;
            end if;
           
        when fois2 =>
            if (compte_ini < 2) then
               etat_suivant <= reset;
            else
                compte_next <= (compte_ini) + (compte_ini);
                etat_suivant <= save;
            end if;
         
        when save =>
            param_mem <= std_logic_vector(compte_next); 
            etat_suivant <= reset;
        
        when reset =>       
            compte_reset <= '1';
            etat_suivant <= att_enable;
                 
    end case;
    
end process;

    o_param <= param_mem;
 
end Behavioral;
