
---------------------------------------------------------------------------------------------
--    calcul_param_2.vhd   (temporaire)
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
entity calcul_param_2 is
    Port (
    i_bclk    : in   std_logic;   -- bit clock
    i_reset   : in   std_logic;
    i_en      : in   std_logic;   -- un echantillon present
    i_ech     : in   std_logic_vector (23 downto 0);
    o_param   : out  std_logic_vector (7 downto 0)                            
    );
end calcul_param_2;

----------------------------------------------------------------------------------

architecture Behavioral of calcul_param_2 is

---------------------------------------------------------------------------------
-- Signaux
----------------------------------------------------------------------------------
    

---------------------------------------------------------------------------------------------
--    Description comportementale
---------------------------------------------------------------------------------------------

type fonction_etat is (
     init,
     att_en,
     carre,
     add,
     send,
     facteur
     );
     
     signal etat_present, etat_suivant: fonction_etat;
     signal ech_carre : signed (47 downto 0); 
     signal entree    : signed (23 downto 0);
     signal fctr : signed (47 downto 0);
     signal fraction : signed (23 downto 0) := "011111000000000000000000"; 
     signal sortie : signed (47 downto 0);
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

process(etat_present, i_en, i_ech, entree, sortie, param_mem, fctr, fraction, ech_carre)
begin
    case etat_present is
    
        when init =>
        
            ech_carre <= ( others => '0');
            fctr <= ( others => '0');
            entree <= ( others => '0');
            sortie <= ( others => '0');
            
            etat_suivant <= att_en;  
            
        when att_en =>
        
             if (i_en = '1') then
                entree <= signed(i_ech);
                etat_suivant <= carre;
             else
                etat_suivant <= att_en;
             end if;
            
        when carre =>
        
            ech_carre <= entree * entree;
            etat_suivant <= add;

  
        when add =>
                sortie <= fctr + ech_carre;
                etat_suivant <= send;
        
        when send =>
        
            param_mem <= std_logic_vector(sortie(47 downto 40));
            etat_suivant <= facteur;
        
        when facteur =>
        
            fctr <= sortie(47 downto 24) * fraction;
            etat_suivant <= att_en;     
        
             
    end case;
    
 end process;   
 
  o_param <= param_mem;
     
end Behavioral;
