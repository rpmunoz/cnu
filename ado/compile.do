clear all
program drop _all
mata mata clear
set more off
set trace off
set matastrict on

*cd f:/cnu/ado

/* Compilando rutinas y agregandolas a mlib */
vers 10.0
mata mata mlib create lcnu, replace
do cnu_1_1.mata
do cnu_2_1.mata
do cnu_2_2.mata
do cnu_faj.mata
do cnu_proy_pens.mata
do cnu_proy_cnu.mata
do utils.mata
mata mata mlib add lcnu *()

/* Creando checksum */
mata st_global("ayuda",invtokens(dir(".","files","*.hlp")'))
mata st_global("ados",invtokens(dir(".","files","*.ado")'))
mata st_global("tablas",invtokens(dir(".","files","cnu_tabmor*")'))
mata st_global("vectores",invtokens(dir(".","files","cnu_vec*")'))

/* Creando documentacion */
mata dt_moxygen(dir(".","files","*.mata"), "cnu_source.sthlp", 1)

cd ..
mata dt_install_on_the_fly("cnu")
cd ado


/* Instalando */
/*cap net from ~/Documents/programas/stata_super
cap net from ~/../investigacion/george/comandos_paquetes_librerias/stata
cap net from I:\george\comandos_paquetes_librerias\stata\

net install cnu, replace force
mata mata mlib query*/

