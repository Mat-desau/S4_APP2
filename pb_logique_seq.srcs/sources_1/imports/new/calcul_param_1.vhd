
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
    i_bclk           : in std_logic; -- bit clock (I2S)
    i_reset          : in std_logic;
    i_en             : in std_logic; -- un echantillon present a l'entrée
    i_ech            : in std_logic_vector (23 downto 0); -- echantillon en entrée
    i_cpt_bits       : in std_logic_vector(7 downto 0);
    
    o_bit_enable     : out std_logic ; 
    o_cpt_bit_reset  : out std_logic ;
    o_param          : out std_logic_vector (7 downto 0)   -- paramètre calculé
    );
end calcul_param_1;

----------------------------------------------------------------------------------

architecture Behavioral of calcul_param_1 is

   
type fonction_etat is (
     initiale,
     detect_plus,
     plus1,
     plus2,
     compt_plus,
     fois2,
     save
     );
     
    signal etat_present, etat_suivant: fonction_etat; 
    signal periode : std_logic_vector(7 downto 0);   

---------------------------------------------------------------------------------
-- Signaux
----------------------------------------------------------------------------------
    

---------------------------------------------------------------------------------------------
--    Description comportementale
---------------------------------------------------------------------------------------------
begin 

process(i_bclk, i_reset)
    begin
       if (i_reset = '1') then
             etat_present <= initiale;
       else
           if rising_edge(i_bclk) AND i_en = '1' then
                 etat_present <= etat_suivant;
           end if;
       end if;
end process;

process(etat_present, i_ech, i_cpt_bits)
begin
    case etat_present is
        when initiale =>  
            etat_suivant <= detect_plus;  
        
        when detect_plus =>
            if (i_ech(23) = '0') then
                etat_suivant <= plus1;
            else
                etat_suivant <= detect_plus;
            end if;  
            
        when plus1 =>
            if (i_ech(23) = '0') then
                etat_suivant <= plus2;
            else
                etat_suivant <= detect_plus;
            end if;  
            
        when plus2 =>
            if (i_ech(23) = '0') then
                etat_suivant <= compt_plus;
            else
                etat_suivant <= detect_plus;
            end if; 
        
        when compt_plus =>
            if (i_ech(23) = '1') then
                etat_suivant <= fois2;
            else 
                etat_suivant <= compt_plus;
            end if; 
 
         when fois2 =>
            etat_suivant <= save;
          
         when save =>
            etat_suivant <= detect_plus;
            
         when others =>
            etat_suivant <= initiale;   
                                      
    end case;
    
end process;


process(etat_present)
begin
    case etat_present is
    
        when initiale =>
            o_bit_enable     <= '0';
            o_cpt_bit_reset  <= '1';
            o_param          <= "00000000"; 
            
        when detect_plus =>
            o_bit_enable     <= '0';
            o_cpt_bit_reset  <= '0';
            o_param          <= "00000000"; 
            
        when plus1 =>
            o_bit_enable     <= '0';
            o_cpt_bit_reset  <= '0';
            o_param          <= "00000000";  
            
        when plus2 =>
            o_bit_enable     <= '0';
            o_cpt_bit_reset  <= '0';
            o_param          <= "00000000"; 
            
        when compt_plus =>
            o_bit_enable     <= '1';
            o_cpt_bit_reset  <= '0';
            o_param          <= "00000000"; 
            
        when fois2 =>
            o_bit_enable     <= '0';
            o_cpt_bit_reset  <= '0';
            o_param          <= "00000000"; 
            
        when save =>
            o_bit_enable     <= '0';
            o_cpt_bit_reset  <= '0';
            o_param          <= "00000000";             
                                                              
               
    end case;
end process;
    -- o_param <= x"01";    -- temporaire ...
 
end Behavioral;
