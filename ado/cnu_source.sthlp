*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:Beginning of file -utils.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
////////////////////////////////////////////////////////////////////////////////
// FUNCIONES ADICIONALES (UTILS)
////////////////////////////////////////////////////////////////////////////////

mata:

// NOMBRE     : cnu_save_tab_mort
// DESCRIPCION: Exporta (guarda) tablas de mortalidad desde mata a un archivo binario
// RESULTADO  : VOID
// DETALLES   : 
//  Las tablas se almacenan en archivos sin extension en la carpeta plus con la
//  siguiente estructura de nombre:
//    plus/c/cnu_tabmor_[tipo][agno][genero]
//  , adicionalmente si el usuario lo desea, puede incluir un nombre alternativo
//  al final del nombre completo
//    plus/c/cnu_tabmor_[tipo][agno][genero][altname]
//  de esta forma podra utilizar sus propias tablas de mortalidad

{smcl}
*! {marker cnu_save_tab_mort}{bf:function -{it:cnu_save_tab_mort}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
void cnu_save_tab_mort(
    real matrix tabla,    // Tabla a guardar
    real scalar agno,     // Agno de la tabla
    string scalar genero, // Genero (h: Hombre, m: Mujer)
    string scalar tipo,   // Tipo de tabla (rv: Afiliado, mi: Con discapacidad, b: Beneficiario
   |string scalar path,   // (OPCIONAL) Directorio donde guardar el archvo (por defecto PERSONAL)
    real scalar repl,     // (OPCIONAL) Dicotomica (1 si desea reemplazar existente) (por defecto 0)
    string scalar altname // (OPCIONAL) Nombre alternativo
    ) 
    {
    
    real scalar fh, ncols, nrows
    string scalar fullpath
    
    // Verificando altname
    if (altname==J(1,1,"")) altname = "";

    // Verificamos path
    if (path == J(1, 1, "")) path = c("sysdir_plus")+"c"+c("dirsep")
    
    // Verificamos repl(replace)
    if (repl == J(1, 1, .)) repl = 0
    
    // Verifica dimensiones de la tabla
    if ((ncols = cols(tabla)) != 3) {
        errprintf("La tabla no tiene 3 columnas ('Edad', 'Qx' y 'Factor'), tiene %g.\n", ncols)
        _error(601)
    }
    /*if ((nrows = rows(tabla)) != 211) {
        errprintf("La tabla no tiene 211 filas (rango de edades entre 0 y 210), tiene %g.\n", nrows)
        exit()
    }*/
    
    // Verifica que tipo de tabla sea correcta
    /*if (!regexm(tipo,"^(rv|mi|b)$")) {
        errprintf("Tipo de tabla '%s' no permitido. Solo rv, mi o b estan permitidos\n", tipo)
        _error(601)
    }*/
        
    // Verifica que sexo haya sido bien especificado
    if (!regexm(genero, "^(h|m)$")) {
        errprintf("Genero '%s' no permitido. Solo h o m estan permitidos\n", genero)
        _error(601)
    }

    fullpath = (path+"cnu_tabmor_"+tipo+strofreal(agno)+genero+altname)

    // Chequea existencia
    if (fileexists(fullpath) & !repl) {
        errprintf("El archivo %s ya existe, especifique la opcion 'replace'.\n", fullpath)
        _error(601)
    }
    else if (fileexists(fullpath) & repl) unlink(fullpath)

    fh = _fopen(fullpath, "rw")
    
    // En el caso de error
    if (fh != 0) {
        errprintf("Ha ocurrido un error al tratar de crear el archivo %s\n(error %f)\n", fullpath,fh)
        _error(601)
    }
    
    // Guardando y cerrando
    fputmatrix(fh, tabla)
    fclose(fh)
    
    sprintf("Se ha guardado la tabla en %s.",fullpath)
}

// NOMBRE     : cnu_get_tab_mort
// DESCRIPCION: Importa tablas de mortalidad a MATA
// RESULTADO  : tabla de mortalidad

{smcl}
*! {marker cnu_get_tab_mort}{bf:function -{it:cnu_get_tab_mort}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real matrix cnu_get_tab_mort( 
    real   scalar agno,   // Agno de la tabla
    string scalar genero, // Genero (h: Hombre, m: Mujer)
    string scalar tipo,   // Tipo de tabla (rv: Afiliado, mi: Con discapacidad, b: Beneficiario
   |string scalar path,   // (OPCIONAL) Directorio donde guardar el archvo (por defecto PERSONAL)
    string scalar altname
    ) 
    {
    
    string scalar fullpath
    real scalar fh
    real matrix x
    
    // Verificamos path
    if (path == J(1, 1, "")) path = c("sysdir_plus")+"c"+c("dirsep")
    else if (!direxists(path)) _error(1,"El directorio -"+path+"-no fue encontrado")
    
    /* // Verifica que tipo de tabla sea correcta
    if (!regexm(tipo,"^(rv|mi|b)$")) {
        errprintf("Tipo de tabla '%s' no permitido. Solo rv, mi o b estan permitidos\n", tipo)
        _error(601)
    } */
        
    // Verifica que sexo haya sido bien especificado
    if (!regexm(genero, "^(h|m)$")) {
        errprintf("Genero '%s' no permitido. Solo h o m estan permitidos\n", genero)
        _error(601)
    }
    
    fullpath = (path+"cnu_tabmor_"+tipo+strofreal(agno)+genero+altname)

    // Chequea existencia
    if (!fileexists(fullpath)) {
        errprintf("La tabla %s no existe\n", fullpath)
        _error(601)
    }

    // Abre archivo y lee tabla de moralidad
    fh = _fopen(fullpath, "rw")
    x = fgetmatrix(fh)
    fclose(fh)
    
    return(x)
}


// NOMBRE     : cnu_save_vec_tasas
// DESCRIPCION: Exporta (guarda) vectores de tasas en archivos binarios
// RESULTADO  : VOID
// DETALLES   :
//  Los vectores se almacenan en archivos sin extension en la carpeta plus con la
//  siguiente estructura de nombre:
//    plus/c/cnu_vec[agno]
//  , adicionalmente si el usuario lo desea, puede incluir un nombre alternativo
//  al final del nombre completo
//    plus/c/cnu_vec[agno][altname]
//  de esta forma podra utilizar sus propios vectores de tasas.

{smcl}
*! {marker cnu_save_vec_tasas}{bf:function -{it:cnu_save_vec_tasas}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
void cnu_save_vec_tasas(
    real matrix tabla,    // Tabla (vector) a exportar
    real scalar agno,     // Agno de la tabla
   |string scalar path,   // (OPCIONAL) Directorio donde guardar el archvo (por defecto PERSONAL)
    real scalar repl,     // (OPCIONAL) Dicotomica (1 si desea reemplazar existente) (por defecto 0)
    string scalar altname
    ) 
    {
    
    real scalar fh, ncols, nrows
    string scalar fullpath
    
    // Verificamos path
    if (path == J(1, 1, "")) path = c("sysdir_plus")+"c"+c("dirsep")
    
    // Verificamos repl(replace)
    if (repl == J(1, 1, .)) repl = 0
    
    // Verifica dimensiones de la tabla
    if ((ncols = cols(tabla)) != 2) {
        errprintf("La tabla no tiene 2 columnas ('Agno' y 'Tasa'), tiene %g.\n", ncols)
        _error(601)
    }
    if ((nrows = rows(tabla)) != 191) {
        errprintf("La tabla no tiene 191 filas (rango de edades entre 1 y 191), tiene %g.\n", nrows)
        _error(601)
    }
    
    fullpath = (path+"cnu_vec"+strofreal(agno)+altname)

    // Chequea existencia
    if (fileexists(fullpath) & !repl) {
        errprintf("El archivo %s ya existe, especifique la opcion 'replace'.\n", fullpath)
        _error(601)
    }
    else if (fileexists(fullpath) & repl) unlink(fullpath)

    fh = _fopen(fullpath, "rw")
    
    // En el caso de error
    if (fh != 0) {
        errprintf("Ha ocurrido un error al tratar de crear el archivo %s\n(error %f)\n", fullpath,fh)
        _error(601)
    }
    
    // Guardando y cerrando
    fputmatrix(fh, tabla)
    fclose(fh)
    
    sprintf("Se ha guardado la tabla (vector) en %s.",fullpath)
}

// NOMBRE     : cnu_get_tab_mort
// DESCRIPCION: Importa vector de tasas a MATA
// RESULTADO  : Vector de tasas

{smcl}
*! {marker cnu_get_vec_tasas}{bf:function -{it:cnu_get_vec_tasas}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real matrix cnu_get_vec_tasas(
    real scalar agno,     // Agno del vector
    |string scalar path,   // (OPCIONAL) Directorio donde guardar el archvo (por defecto PERSONAL)
    string scalar altname
    ) 
    {
    
    string scalar fullpath
    real scalar fh
    real matrix x
    
    // Verificamos path
    if (path == J(1, 1, "")) path = c("sysdir_plus")+"c"+c("dirsep")
        
    fullpath = (path+"cnu_vec"+strofreal(agno)+altname)

    // Chequea existencia
    if (!fileexists(fullpath)) {
        errprintf("La tabla (vector de tasas) %s no existe\n", fullpath)
        _error(601)
    }

    // Abre archivo y lee tabla de moralidad
    fh = _fopen(fullpath, "rw")
    x = fgetmatrix(fh)
    fclose(fh)
    
    return(x)
}


// NOMBRE     : cnu_mejorar_tabla
// DESCRIPCION: Aplica mejoramiento a tablas de mortalidad
// RESULTADO  : Tabla de mortalidad ajustada (vector)
{smcl}
*! {marker cnu_mejorar_tabla}{bf:function -{it:cnu_mejorar_tabla}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real colvector cnu_mejorar_tabla(
    real colvector edades,
    real colvector qx,        // Valor Qx (Mortalidad)
    real colvector aa,        // Valor AA (Factor de mejoramiento)
    real scalar agno_qx,      // Agno de la tabla
    real scalar agno_actual,  // Agno de calculo
    real scalar edad          // Edad del individuo
    )
    {
    
    real scalar difagnos
    
    difagnos = agno_actual - agno_qx
    return(qx :* (1 :- aa):^(difagnos :+ edades :- edad))
}


// NOMBRE     : cnu_which_tab_mort
// DESCRIPCION: Determina que agno de tabla de mortalidad debe usar el individuo
// RESULTADO  : Agno correspondiente de la tabla a utilizar (scalar)

{smcl}
*! {marker cnu_which_tab_mort}{bf:function -{it:cnu_which_tab_mort}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real scalar cnu_which_tab_mort(
    real scalar fsiniestro,
    string scalar tipo
    )
    {
    
    // Verifica que tipo de tabla sea correcta
    if (!regexm(tipo,"^(rv|mi|b)$")) {
        errprintf("Tipo de tabla '%s' no permitido. Solo rv, mi o b estan permitidos\n", tipo)
        _error(601)
    }
    
    // Si es que es para afiliado
    if (tipo == "rv") {
        if (fsiniestro <= 20050131) {
            return(1985)
        }
        else if (fsiniestro <= 20100630) {
            return(2004)
        }
        else {
            return(2009)
        }
    } // Si es que es para persona invalidez
    else if (tipo == "mi") {
        if (fsiniestro <= 20080131) {
            return(1985)
        }
        else {
            return(2006)
        }
    } // Si es que es para beneficiario
    else {
        if (fsiniestro <= 20080131) {
            return(1985)
        }
        else {
            return(2006)
        }
    }
}


// NOMBRE     : export_tab
// DESCRIPCION: Exporta matrices a texto plano para ser generadas desde mata
// RESULTADO  : VOID

{smcl}
*! {marker export_tab}{bf:function -{it:export_tab}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
void export_tab(
    real matrix tabla,      // Tabla a exportar
   |string scalar filename, // (opcional) Nombre de archivo a exportar
    string scalar mode,     // (opcional) Modo de conexion (a = append, w = write)
    string scalar tabname   // (opcional) Nombre de la tabla
    )
    {
    
    // Variables definition
    real scalar ncols, nrows, i, j, fh
    string colvector stringtab
    
    if (mode == J(1,1,"")) mode = "w"
    if (tabname == J(1,1,"")) tabname = "x"
    
    ncols = cols(tabla)
    nrows = rows(tabla)
    stringtab = J(nrows,1,"")
    
    for(i=1; i<=nrows; i++) {
        for(j=1; j<=ncols; j++) {
            if (j==1 & i==1) { // First cell
                stringtab[i] = sprintf("(%f ,",tabla[i,j])
            }
            else if (j==ncols & i==nrows) { // Last cell
                stringtab[i] = stringtab[i] + sprintf("%f)",tabla[i,j])
            }
            else if (j==ncols & i !=nrows) { // Last cell of row
                stringtab[i] = stringtab[i] + sprintf("%f \",tabla[i,j])
            }
            else { // Middle cell
                stringtab[i] = stringtab[i] + sprintf("%f, ",tabla[i,j])
            }
        }
    }

    // Returning
    if (filename==J(1,1,"")) {
        printf("%s = \n", tabname)
        for(i=1;i<=nrows;i++) {
            printf("\t%s\n", stringtab[i])
        }
    }
    else {
        fh = fopen(filename, mode)
        fput(fh, sprintf("%s = \n", tabname))
        for(i=1;i<=nrows;i++) {
            fput(fh, sprintf("\t%s",stringtab[i]))
        }
        fclose(fh)
    }
}

{smcl}
*! {marker cnu_import_plain_tab_mort}{bf:function -{it:cnu_import_plain_tab_mort}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
void cnu_import_plain_tab_mort(
    string scalar fname,
    real scalar agno,
    string scalar genero,
    string scalar tipo,
   |string scalar path,
    real scalar repl,
    string scalar sep,
    string scalar altname
    )
{
    real matrix tabla;
    string scalar line;
    
    if (sep==J(1,1,"")) sep=";";
    
    /* Verifica que exista el archivo */
    if(!fileexists(fname)) _error(1)
    
    /* Leyendo tabla */
    tabla = strtoreal(mm_insheet(fname,sep));

    /* Guardandola */
    cnu_save_tab_mort(tabla, agno, genero, tipo, path, repl, altname)
    
    return
}

/* Importa vector de tasas */
{smcl}
*! {marker cnu_import_plain_vec}{bf:function -{it:cnu_import_plain_vec}- in file -{it:utils.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
void cnu_import_plain_vec(
    string scalar fname,
    real scalar agno,
   |string scalar path,
    real scalar repl,
    string scalar sep,
    string scalar altname
    )
{
    real matrix tabla;
    string scalar line;
    
    if (sep==J(1,1,"")) sep=";";
    
    /* Verifica que exista el archivo */
    if(!fileexists(fname)) _error(1)
    
    /* Leyendo vector */
    tabla = strtoreal(mm_insheet(fname,sep));

    /* Guardandola */
    cnu_save_vec_tasas(tabla, agno, path, repl, altname);
    
    return
}
end

*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:End of file -utils.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:Beginning of file -cnu_proy_pens.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
mata:
{smcl}
*! {marker cnu_proy_pens}{bf:function -{it:cnu_proy_pens}- in file -{it:cnu_proy_pens.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real matrix function cnu_proy_pens(
    real scalar x,              // Edad del afiliado
    real scalar y,              // Edad del conyuge
    real scalar cotmujer,       // Escalar binario (1 si el cotizante es mujer)
    real scalar conymujer,      // Escalar binario (1 si el cotizante es mujer)
    string scalar tipo_tm_cot,  // Tipo de tabla de mortalidad (rv, mi, b)
    string scalar tipo_tm_cony, // Tipo de tabla de mortalidad (rv, mi, b)
    real scalar saldoi,         // Saldo al momento del retiro
    real scalar agnovec,        // Agno del vector
    real scalar rp,             // Tasa RP a utilizar
    real scalar agnotabla,      // Agno de la tabla de mortalidad del cotizante
    real scalar agnotablabenef, // Agno de la tabla de mortalidad del cotizante
    real scalar agnoactual,     // Agno actual (de calculo)
    real scalar fsiniestro,     // Fecha en que ocurre el siniestro (se utiliza para asignar la tabla)
  | real scalar confaj,         // Si es con factor de ajuste o no
    real scalar edadm,          // (FAJ) Edad max 
    real scalar pcent,          // (FAJ) Porcentaje a cubrir 
    real scalar rp0,            // (FAJ) Pension de referencia (puede autocalcularse) 
    real scalar criter,         // (FAJ) Criterio de convergencia
    real scalar maxiter,        // (FAJ) Max num de iteraciones
    string scalar path_tm,      // Directorio donde buscar las tablas de mortalidad
    string scalar path_v    
) {

    real colvector cnu, pens
    real matrix vec
    real scalar i, N
    
    N = 110 - x + 1
    
    // Calculando CNU que se utilizara
    cnu = cnu_proy_cnu(x,y,cotmujer,conymujer,tipo_tm_cot,
            tipo_tm_cony, agnovec, 0, J(191,1,rp), J(191,1,-1e100), agnotabla,
            agnotablabenef, agnoactual, fsiniestro, 0, path_tm, path_v)

    if (rp != -1e100) vec = ((1::191), J(191,1,rp))
    else vec = cnu_get_vec_tasas(agnovec, path_v)
    
    real colvector saldo
    
    // Pension sin factor de ajuste
    if (!confaj) 
    {
        pens  = J(N,1,.)
        saldo = J(N,1,.)
        
        pens[1]  = saldoi/cnu[1]
        saldo[1] = (saldoi - pens[1])*(1+vec[1,2])
        for(i=2;i<=N;i++)
        {
            pens[i]  = saldo[i-1]/cnu[i]
            saldo[i] = max(
                (0,(saldo[i-1] - pens[i])*(1+vec[i,2]))
                )
        }
        return((saldo,pens))
    }
    // Pension con factor de ajuste
    else
    {
        real scalar faj, fajactivo, pensfaj, saldofaj
        
        // Calculando FAJ
        if (st_local("debug")!="") {
            cnu[1::10],vec[1::10,2]
            x,edadm, saldoi, pcent, rp0, criter, maxiter
        }
        faj = cnu_faj(x, cnu, vec[,2], edadm, saldoi, pcent, rp0,
            criter, maxiter)
        
        // Iniciando simulacion
        pens      = J(N,1,.)
        pensfaj   = pcent*saldoi/cnu[1]
        saldofaj  = J(N,1,0)
        fajactivo = 0
        saldo     = J(N,1,.)
        
        pens[1]     = pensfaj/pcent*(1-faj)
        saldo[1]    = (saldoi - pens[1] - pens[1]/(1-faj)*faj)*(1+vec[1,2])
        saldofaj[1] = pens[1]/(1-faj)*faj*(1+vec[1,2])
        for(i=2;i<=N;i++)
        {
            // Si faj no esta activo
            if (!fajactivo)
            {
                pens[i] = saldo[i-1]/cnu[i]*(1-faj)
            
                // Si es que la pension sigue siendo superior que la pension
                // FAJ. entonces entrar. De lo contrario, se activa la pension
                // FAJ y deja de entrar a este nivel.
                if (pens[i] > pensfaj)
                {
                    saldofaj[i] = (saldofaj[i-1] + saldo[i-1]/cnu[i]*faj)*(1+vec[i,2])
                    saldo[i]    = (saldo[i-1] - saldo[i-1]/cnu[i])*(1+vec[i,2])
                    continue
                }
                                            
                fajactivo   = 1
                
            }

            // Calculando pension y saldos segun FAJ
            if ( (saldofaj[i-1] - (pensfaj-saldo[i-1]/cnu[i])) < 0) 
            {
                pens[i]  = saldo[i-1]/cnu[i]
                saldo[i] = (saldo[i-1] - saldo[i-1]/cnu[i])*(1+vec[i,2])
                continue
            }

            pens[i]     = pensfaj
            saldo[i]    = (saldo[i-1] - saldo[i-1]/cnu[i])*(1+vec[i,2])
            saldofaj[i] = (saldofaj[i-1] - (pensfaj-saldo[i-1]/cnu[i]))*(1+vec[i,2])

        }
        return((saldo,J(N,1,faj),saldofaj,pens))
    }
    
}

end
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:End of file -cnu_proy_pens.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:Beginning of file -cnu_1_1.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! version 0.13.10.23 23oct2013
mata:

// NOMBRE     : cnu_1_1
// DESCRIPCION: Calcula CNU para Pension de sobrevivencia para conyuge sin hijos (version escalar)
// RESULTADO  : CNU para Pension de sobrevivencia para conyuge sin hijos (version escalar)

{smcl}
*! {marker cnu_1_1}{bf:function -{it:cnu_1_1}- in file -{it:cnu_1_1.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real scalar cnu_1_1(
    real scalar y,          // Edad del conyuge
    real scalar mujer,      // Escalar binario (1 si el conyuge es mujer)
    string scalar tipo_tm,  // Tabla de mortalidad para el beneficiario
    real scalar agnovec,    // Agno del vector
    real scalar rv,         // Valor de la tasa para RV
    real scalar rp,         // Valor de la tasa para RP
    real scalar norp,       // Dicotomica indicando si calcula o no RP
    real scalar agnotabla,  // Agno de la tabla de mortalidad del beneficiario
    real scalar agnoactual, // Agno actual (de calculo)
    real scalar fsiniestro, // Fecha del siniestro
    | real scalar stepprint,
    string scalar path_tm,  // Directorio donde se encuentran las tablas de mortalidad
    string scalar path_v
    )
    {
    
    real scalar cnu, lyt, l_y, tmax, i, t
    real colvector qxtmp
    real matrix vec, tabla_mort
    string scalar mujer_tm
    
    // Valor inicial en rv
    l_y = 1

    // N periodos
    tmax = 110 - y

    // Mejoramiento de la tabla
    if (mujer) mujer_tm = "m"
    else mujer_tm = "h"
    
    // Asignacion dinamica de tabla
    if (fsiniestro != 0) agnotabla = cnu_which_tab_mort(fsiniestro, tipo_tm)
    
    tabla_mort = cnu_get_tab_mort(agnotabla, mujer_tm, tipo_tm, path_tm)
    qxtmp = cnu_mejorar_tabla(tabla_mort[.,1],tabla_mort[.,2], tabla_mort[.,3], agnotabla, agnoactual, y)
    st_local("tipotabla",tipo_tm)
    st_local("agnotabla", strofreal(agnotabla))
    
    // Genera vector
    if (norp) 
    {
        vec = ((1::191), J(191,1,rv))
    } 
    else if (rp != -1e100)
    {
        vec = ((1::191), J(191,1,rp))
    }
    else 
    {
        vec = cnu_get_vec_tasas(agnovec, path_v)
    }    
    
    // De termina si se imprime o no el resultado en pantalla
    if (stepprint == J(1, 1, .)) stepprint = 0
    
    // Sumatoria
    cnu = 1
    lyt = 1
    i = 0
    if (stepprint) { // En el caso de que se desee imprimir los resultados en pantalla
        printf("t = %3.0f: CNU = 1\n", 0)
        for (t=1 ; t<=tmax ; t++) {
            
            lyt = lyt*(1 - qxtmp[y + t])
            i = vec[t,2]

            //printf("t = %3.0f: CNU = %9.6f + (%g/%g)/(1 + %g)^%g\n", t, cnu, lyt, l_y, i, t)
            printf("t = %3.0f: cnu = %9.6f + %g/((1 + %g)^%g)\n", t, cnu, lyt, i, t)
            //cnu = cnu + (lyt/l_y)/((1 + i)^t)
            cnu = cnu + lyt/((1 + i)^t)
            
        }
    }
    else {
        for (t=1 ; t<=tmax ; t++) {
            
            lyt = lyt*(1 - qxtmp[y + t])
            i = vec[t,2]
            
            //cnu = cnu + (lyt/l_y)/((1 + i)^t)
            cnu = cnu + lyt/((1 + i)^t)
        }
    }
    
    return(round((.6*(cnu :- 11/24)), .000001))
}

// NOMBRE     : cnu_1_1_vec
// DESCRIPCION: Calcula CNU para Pension de sobrevivencia para conyuge sin hijos (version vectorial)
// RESULTADO  : CNU para Pension de sobrevivencia para conyuge sin hijos (version vectorial)

{smcl}
*! {marker cnu_1_1_vec}{bf:function -{it:cnu_1_1_vec}- in file -{it:cnu_1_1.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real colvector cnu_1_1_vec(
    real colvector y,           // Edad del conyuge
    real colvector mujer,       // Vector binario (1 si el conyuge es mujer)
    string colvector tipo_tm,      // Tipo de tabla de mortalidad (rv, mi, b)
    real colvector agnovec,     // Agno del vector
    real scalar norp,           // Dicotomica indicando si calcula o no RP
    real colvector rv,          // Valor de la tasa para RV
    real colvector rp,          // Valor de la tasa para RP
    real colvector agnotabla,      // Agno de la tabla de mortalidad del beneficiario
    real colvector vagnoactual, // Agno actual (de calculo)
    real colvector vfsiniestro, // Fecha del siniestro
    real colvector touse,       // Vector binario (1 si debe calcular para la observacion)
    real scalar printlistado,   // Dicotomica indicando si imprime listado de no calculados por problemas
    string scalar path_tm,
    string scalar path_v
    )
    {
    
    // Definicion de escalares
    real scalar N, sex, edad, nerr_menor_20, nerr_mayor_110, vecexists, j, nerr_vector
    string scalar err_menor_20, err_mayor_110, err_vector
    real colvector cnu
    
    N = rows(y)
    cnu = J(N,1,.)
    
    err_menor_20 = ""
    err_mayor_110 = ""
    err_vector = ""
    nerr_menor_20 = 0
    nerr_mayor_110 = 0
    nerr_vector = 0
    
    for (j=1 ; j <= N ; j++) { // Puede calcular CNU
    
        /* Verifica si se ha presionado la tecla break 
        accionada por parallel */
        parallel_break()
        
        if (touse[j,1]) { // Revisa si debe incluirse o no

            edad = y[j,1]
            sex=mujer[j,1]
            
            if (path_v=="") vecexists = fileexists(c("sysdir_plus")+"c/cnu_vec"+strofreal(agnovec[j]))
            else vecexists = fileexists(path_v+"cnu_vec"+strofreal(agnovec[j]))
            
            if (edad >= 20 & edad <= 110 & vecexists) {
                            
                // Guarda resultado en vector CNU            
                cnu[j,1] = cnu_1_1(edad, sex, tipo_tm[j], agnovec[j], rv[j], rp[j], norp, agnotabla[j], vagnoactual[j], vfsiniestro[j], 0, path_tm, path_v)
            }
            else if (edad < 20) { // No puede calcular CNU por ser menor de 20
                if (nerr_menor_20++ < 20) err_menor_20 = err_menor_20+strofreal(j)+" "
            }
            else if (!vecexists) {
                if (nerr_vector++ < 20) err_vector = err_vector+strofreal(j)+" "
            }
            else { // No puede calcular CNU por ser mayor de 110
                if (nerr_mayor_110++ < 20) err_mayor_110 = err_mayor_110+strofreal(j)+" "
            }
        }
    }

    // Pasa listado de obs que no pudo procesar a una local
    if (printlistado) {
        st_local("err_menor_20", err_menor_20)
        st_local("err_mayor_110", err_mayor_110)
        st_local("err_vector", err_vector)
        
        st_local("nerr_menor_20", strofreal(nerr_menor_20))
        st_local("nerr_mayor_110", strofreal(nerr_mayor_110))
        st_local("nerr_menor_20", strofreal(nerr_menor_20))
    }
    
    return(cnu)
}


end
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:End of file -cnu_1_1.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:Beginning of file -cnu_2_2.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! version 0.13.10.23 23oct2013
mata:

// NOMBRE     : cnu_2_2_vec
// DESCRIPCION: Calcula CNU para conyuge sin hijos (vectorial)
// RESULTADO  : CNU para conyuge sin hijos (vector)
{smcl}
*! {marker cnu_2_2_vec}{bf:function -{it:cnu_2_2_vec}- in file -{it:cnu_2_2.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real colvector cnu_2_2_vec(
    real colvector x,           // Edad del afiliado
    real colvector y,           // Edad del conyuge
    real colvector cotmujer,    // Vector binario (1 si el cotizante es mujer)
    real colvector conymujer,   // Vector binario (1 si el conyuge es mujer)
    string colvector tipo_tm_cot,  // Tipo de tabla de mortalidad (rv, mi, b) para el cotizante
    string colvector tipo_tm_cony, // Tipo de tabla de mortalidad (rv, mi, b) para el beneficiario
    real colvector agnovec,     // Agno del vector
    real scalar norp,           // Dicotomica indicando si calcula o no RP
    real colvector rv,          // Valor de la tasa para RV
    real colvector rp,          // Valor de la tasa para RP
    real colvector agnotabla,      // Agno de la tabla de mortalidad del cotizante
    real colvector agnotablabenef, // Agno de la tabla de mortalidad del beneficiario
    real colvector vagnoactual, // Agno actual (de calculo)
    real colvector vfsiniestro, // Fecha del siniestro
    real colvector touse,       // Vector binario (1 si debe calcular para la observacion)
    string scalar path_tm,
    string scalar path_v
    )
    {
        
    // Definicion de escalares
    real scalar N, s_cot, s_cony, edad_cot, edad_cony, j, vecexists
    real scalar nerr_menor_20_cot, nerr_mayor_110_cot, nerr_menor_20_cony, nerr_mayor_110_cony, nerr_vector
    string scalar err_menor_20_cot, err_mayor_110_cot, err_menor_20_cony, err_mayor_110_cony, err_vector
    real colvector cnu
    
    N = rows(x)
    cnu = J(N,1,.)
    
    err_menor_20_cot = ""
    err_menor_20_cony = ""
    err_mayor_110_cot = ""
    err_mayor_110_cony = ""
    err_vector = ""
    nerr_menor_20_cot = 0
    nerr_menor_20_cony = 0
    nerr_mayor_110_cot = 0
    nerr_mayor_110_cony = 0
    nerr_vector = 0    

    for (j=1 ; j <= N ; j++) {
    
        /* Verifica si se ha presionado la tecla break 
        (parallel) */
        parallel_break()
    
        if (touse[j,1]) {
        
            edad_cot = x[j,1]
            edad_cony = y[j,1]
            
            if (path_v == "") vecexists = fileexists(c("sysdir_plus")+"c/cnu_vec"+strofreal(agnovec[j]))
            else vecexists = fileexists(path_v+"cnu_vec"+strofreal(agnovec[j]))
            
            if (edad_cot >= 20 & edad_cot <= 110 & edad_cony >= 20 & edad_cony <= 110 & vecexists) {
            
                // Mujer
                s_cot = cotmujer[j,1]
                s_cony = conymujer[j,1]            
                                
                // Guarda resultado en vector CNU
                cnu[j,1] = cnu_2_2(edad_cot, edad_cony, s_cot, s_cony, tipo_tm_cot[j], tipo_tm_cony[j], agnovec[j], rv[j], rp[j], norp, agnotabla[j], agnotablabenef[j], vagnoactual[j], vfsiniestro[j], 0, path_tm, path_v)
            } 
            else if (edad_cot < 20) {
                if (nerr_menor_20_cot++ < 20) err_menor_20_cot = err_menor_20_cot+strofreal(j)+" "
            }
            else if (edad_cony < 20) {
                if (nerr_menor_20_cony++ < 20) err_menor_20_cony = err_menor_20_cony+strofreal(j)+" "
            }
            else if (edad_cot > 110) {
                if (nerr_mayor_110_cot++ < 20) err_mayor_110_cot = err_mayor_110_cot+strofreal(j)+" "
            }
            else if (!vecexists) {
                if (nerr_vector++ < 20) err_vector = err_vector + strofreal(j)+" "
            }
            else {
                if (nerr_mayor_110_cony++ < 20) err_mayor_110_cony = err_mayor_110_cony+strofreal(j)+" "
            }
        }    
    }

    st_local("err_menor_20_cot", err_menor_20_cot)
    st_local("err_menor_20_cony", err_menor_20_cony)
    st_local("err_mayor_110_cot", err_mayor_110_cot)
    st_local("err_mayor_110_cony", err_mayor_110_cony)
    st_local("err_vector", err_mayor_110_cony)
    
    st_local("nerr_menor_20_cot", strofreal(nerr_menor_20_cot))
    st_local("nerr_menor_20_cony", strofreal(nerr_menor_20_cony))
    st_local("nerr_mayor_110_cot", strofreal(nerr_mayor_110_cot))
    st_local("nerr_mayor_110_cony", strofreal(nerr_mayor_110_cony))
    st_local("nerr_vector", strofreal(nerr_mayor_110_cony))
    
    return(cnu)
}

// NOMBRE     : cnu_2_2
// DESCRIPCION: Calcula CNU para conyuge sin hijos (escalar)
// RESULTADO  : CNU para conyuge sin hijos (escalar)

{smcl}
*! {marker cnu_2_2}{bf:function -{it:cnu_2_2}- in file -{it:cnu_2_2.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real scalar cnu_2_2(
    real scalar x,               // Edad del afiliado
    real scalar y,               // Edad del conyuge
    real scalar cotmujer,        // Escalar binario (1 si el cotizante es mujer)
    real scalar conymujer,       // Escalar binario (1 si el conyuge es mujer)
    string scalar tipo_tm_cot,   // Tabla de mortalidad para el cotizante
    string scalar tipo_tm_cony,  // Tabla de mortalidad para el beneficiario
    real scalar agnovec,         // Agno del vector
    real scalar rv,              // Valor de la tasa para RV
    real scalar rp,
    real scalar norp,            // Dicotomica indicando si calcula o no RP
    real scalar agnotabla,       // Agno de la tabla de mortalidad del cotizante
    real scalar agnotablabenef,  // Agno de la tabla de mortalidad del beneficiario
    real scalar agnoactual,      // Agno actual (de calculo)
    real scalar fsiniestro,      // Fecha del siniestro
  | real scalar stepprint,
    string scalar path_tm,       // Directorio donde se encuentran las tablas de mortalidad
    string scalar path_v    
    )
    {
    
    real scalar l_x, l_y, tmax, cnu, i, lxt, lyt, t
    real colvector qxtmp_cot, qxtmp_cony
    real matrix vec, tabla_mort_cot, tabla_mort_cony
    string scalar cotmujer_tm, conymujer_tm
    
    // Verifica si desea imprimir en pantalla
    if (stepprint == J(1,1,.)) stepprint = 0
    
    // Valor inicial en rv            
    l_x = 1
    l_y = 1

    // N periodos
    tmax = 110 - y + 1

    // Mejoramiento de la tabla
    if (cotmujer) cotmujer_tm = "m"
    else cotmujer_tm = "h"
    
    if (conymujer) conymujer_tm = "m"
    else conymujer_tm = "h"
    
    // Asignacion dinamica de tabla
    if (fsiniestro != 0) {
        agnotabla      = cnu_which_tab_mort(fsiniestro, tipo_tm_cot)
        agnotablabenef = cnu_which_tab_mort(fsiniestro, tipo_tm_cony)
    }
    st_local("tipotabla", tipo_tm_cot)
    st_local("tipotablabenef", tipo_tm_cony)
    st_local("agnotabla", strofreal(agnotabla))
    st_local("agnotablabenef", strofreal(agnotablabenef))
    
    tabla_mort_cot  = cnu_get_tab_mort(agnotabla, cotmujer_tm, tipo_tm_cot, path_tm)
    tabla_mort_cony = cnu_get_tab_mort(agnotablabenef, conymujer_tm, tipo_tm_cony, path_tm)
    
    qxtmp_cot = cnu_mejorar_tabla(tabla_mort_cot[.,1], tabla_mort_cot[.,2], tabla_mort_cot[.,3], agnotabla, agnoactual, x)
    qxtmp_cony = cnu_mejorar_tabla(tabla_mort_cony[.,1], tabla_mort_cony[.,2], tabla_mort_cony[.,3], agnotablabenef, agnoactual, y)
    
    // Genera vector
    if (norp) 
    {
        vec = ((1::191), J(191,1,rv))
    } 
    else if (rp != -1e100)
    {
        vec = ((1::191), J(191,1,rp))
    }
    else 
    {
        vec = cnu_get_vec_tasas(agnovec, path_v)
    }
    
    // Sumatoria
    cnu = 0
    i = 0
    lxt = 1
    lyt = 1
    if (stepprint) { // En el caso de que desee mostrar los resultados en pantalla
        printf("t = %3.0f: CNU = 1\n", 0)
        for (t=1 ; t<=tmax ; t++) {
            
            i = vec[t,2]
            
            lxt  = lxt *(1 -  qxtmp_cot[x + t - 1])
            lyt  = lyt *(1 - qxtmp_cony[y + t])
            // printf("t = %3.0f: CNU = %9.6f + (%g/((1 + %g)^%g)) - ((%g*%g)/(%g*%g*(1 + %g)^%g))\n", t, cnu, lyt, i, t, lxt, lyt, l_x, l_y,i,t)
            printf("t = %3.0f: cnu = %9.6f + (%g/(1 + %g)^%g)*(1 - %g)\n", t, cnu, lyt, i, t, lxt, )
            //cnu = cnu + (lyt/(l_y*(1 + i)^t)) - ((lxt*lyt)/(l_x*l_y*(1 + i)^t))
            cnu = cnu + (lyt/(1 + i)^t)*(1 - lxt)
        }
    }
    else {
        for (t=1 ; t<=tmax ; t++) {
            
            i = vec[t,2]
            
            lxt  = lxt *(1 -  qxtmp_cot[x + t - 1])
            lyt  = lyt *(1 - qxtmp_cony[y + t])
            
            //cnu = cnu + (lyt/(l_y*(1 + i)^t)) - ((lxt*lyt)/(l_x*l_y*(1 + i)^t))
            cnu = cnu + (lyt/(1 + i)^t)*(1 - lxt)
        }
    }
    
    return(round((.6 :* cnu), .000001))
}

end
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:End of file -cnu_2_2.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:Beginning of file -cnu_faj.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}

mata
/**moxygen
 * @brief Funcion objetivo a optimizar
 **/
{smcl}
*! {marker cnu_faj_fun_obj}{bf:function -{it:cnu_faj_fun_obj}- in file -{it:cnu_faj.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real scalar function cnu_faj_fun_obj(
    real scalar faj,
    real scalar x,
    real colvector cnu,
    real colvector rp_a,
    |real scalar edadm,
    real scalar saldo,
    real scalar pcent,
    real scalar rp0
) {
    if (edadm == J(1,1,.)) edadm = 98.00
    if (saldo == J(1,1,.)) saldo =  1.00
    if (pcent == J(1,1,.)) pcent =  0.30
    if (rp0   == J(1,1,.)) rp0   = saldo/cnu[1]

    real scalar suma, t, pens_t, saldo_t
    suma    = 0
    saldo_t = saldo
    
    for(t=0;t<=edadm-x;t++)
    {
        pens_t  = saldo_t/cnu[t+1]
        saldo_t = (saldo_t - pens_t)*(1+rp_a[t+1])
        suma = suma + (pens_t - max(((1-faj)*pens_t,pcent*rp0)))/(1+rp_a[t+1])^(t + 1)
    }
    
    return(suma)
}

/**moxygen
 * @brief Calcula el factor de ajuste
 * @param cnu   Vector columna. Trayectoria del CNU
 * @param rp_a  Vector columna. Tasa de interes anual RP.
 * @param edadm Escalar. Edad hasta la que cubre el FAJ
 * @param saldo Escalar. Saldo al momento del retiro
 * @param pref  Escalar. % de referencia
 */
{smcl}
*! {marker cnu_faj}{bf:function -{it:cnu_faj}- in file -{it:cnu_faj.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real scalar function cnu_faj(
    real scalar x,
    real colvector cnu,
    real colvector rp_a,
    |real scalar edadm,
    real scalar saldo,
    real scalar pcent,
    real scalar rp0,
    real scalar criter,
    real scalar maxiter
    ) {
    
    if (st_local("debug")!="") {
        cnu[1::10],rp_a[1::10]
        x,edadm, saldo, pcent, rp0, criter, maxiter
    }
    
    // Importantes en blanco
    if (criter  == J(1,1,.)) criter = 1e-7
    if (maxiter == J(1,1,.)) maxiter = 100
    if (edadm == J(1,1,.)) edadm = 98
        
    // Resolucion a traves de una busqueda binaria
    // Alcanza una prescision de 1e-10 en ~ 50 pasos
    real scalar faj1, faj2, val1, val2
    real scalar minr, maxr, rango
    
    minr = 0
    maxr = 1
    rango = maxr-minr
    real scalar niter
    niter = 0
    
    while ((rango > criter) & (++niter < maxiter))
    {
        faj1 = minr + rango/3
        faj2 = minr + rango/3*2
        
        val1 = cnu_faj_fun_obj(faj1,x,cnu,rp_a,edadm,saldo,pcent,rp0)
        val2 = cnu_faj_fun_obj(faj2,x,cnu,rp_a,edadm,saldo,pcent,rp0)
        
        if ((val1 < val2) & (val1 > 0)) maxr = faj2
        else                            minr = faj1
        
        rango = maxr-minr
    }
    
    if (val1 < val2) return(faj1)
    else return(faj2)
}

{smcl}
*! {marker cnu_faj_vec}{bf:function -{it:cnu_faj_vec}- in file -{it:cnu_faj.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real colvector function cnu_faj_vec(
    real colvector vedadm,         // Edad max a cubrir por FAJ
    real colvector vsaldo,         // Saldo del afiliado
    real colvector vpcent,         // % de pension de referencia a cubrir
    real colvector vrp0,           // pension de referencia
    real colvector x,              // Edad del afiliado
    real colvector y,              // Edad del conyuge
    real colvector cotmujer,       // Escalar binario (1 si el cotizante es mujer)
    real colvector conymujer,      // Escalar binario (1 si el cotizante es mujer)
    string colvector tipo_tm_cot,  // Tipo de tabla de mortalidad (rv, mi, b)
    string colvector tipo_tm_cony, // Tipo de tabla de mortalidad (rv, mi, b)
    real colvector agnovec,        // Agno del vector
    real colvector rp,             // Tasa RP a utilizar
    real colvector agnotabla,      // Agno de la tabla de mortalidad del cotizante
    real colvector agnotablabenef, // Agno de la tabla de mortalidad del cotizante
    real colvector agnoactual,     // Agno actual (de calculo)
    real colvector fsiniestro,     // Fecha en que ocurre el siniestro (se utiliza para asignar la tabla)
    real colvector touse,
  | real scalar criter,            // Prescision (optimizacion)
    real scalar maxiter,           // Maximo numero de iteraciones (optim)
    string scalar path_tm,         // Directorio donde buscar las tablas de mortalidad
    string scalar path_v           // Directorio donde buscar vectores de tasa
) {
    real scalar N, i
    N = length(x)
    
    real colvector cnu, faj, rp_a, rv_a
    rv_a = J(110,1,.)
    faj  = J(N,1,.)    
    for(i=1;i<=N;i++)
    {
        parallel_break()
        
        if (!touse[i]) continue
    
        // Picking the right vector
        if (rp[i]==-1e100) rp_a = cnu_get_vec_tasas(agnovec[i], path_v)[,2]
        else rp_a = J(110,1,rp[i])
        
        // Calculando proyeccion del CNU
        cnu = cnu_proy_cnu(x[i],y[i],cotmujer[i],conymujer[i],tipo_tm_cot[i],
            tipo_tm_cony[i], agnovec[i], 0, rp_a, rv_a, agnotabla[i], agnotablabenef[i],
            agnoactual[i], fsiniestro[i], 0, path_tm, path_v)
        
        // Calculando FAJ
        faj[i] = cnu_faj(x[i], cnu, rp_a, vedadm[i], vsaldo[i], vpcent[i],
            vrp0[i], criter, maxiter)

    }
    
    return(faj)
    
}
    /*
// Proyecta el CNU
cnu  = cnu_proy_cnu(65,67,0,1,"rv","b",2013,0,J(110-65+1,1,-1e100),J(110-65+1,1,.03),2009,2006,2014,0)
rp_a = J(110-65+1,1,.03)
fajs = J(100,1,.5):*(.5/100:*(1::100))

for(i=1;i<=length(fajs);i++) {
    printf("%5.4fc %9.5fc\n",fajs[i],cnu_faj_fun_obj(fajs[i],65,cnu,rp_a))
}

cnu_faj(65, cnu, rp_a,98,1,.3,.)

cnu2 = cnu_proy_cnu( 65, 67, 0, 1, "rv", "b", 2013, 0,J(110-65+1,1,-1e+100), J(110-65+1,1,.03), 2009, 2006, 2014, 0, 0, "", "" )

cnu_faj(65, cnu2)


    /*real scalar faj,
    real scalar x,
    real colvector cnu,
    real colvector rp_a,
    |real scalar edadm,
    real scalar saldo,
    real scalar pcent,
    real scalar rp0*/
*/
end
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:End of file -cnu_faj.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:Beginning of file -cnu_2_1.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! version 0.13.10.23 23oct2013
mata:

// NOMBRE     : cnu_2_1_vec
// DESCRIPCION: Calcula CNU para afiliado soltero (version vectorial)
// RESULTADO  : CNU para afiliado soltero (version vectorial)

{smcl}
*! {marker cnu_2_1_vec}{bf:function -{it:cnu_2_1_vec}- in file -{it:cnu_2_1.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real colvector cnu_2_1_vec(
    real colvector x,            // Edad del afiliado
    real colvector mujer,        // Genero del afiliado
    string colvector tipo_tm,    // Tipo de tabla de mortalidad (rv, mi, b)
    real colvector agnovec,      // Agno del vector
    real scalar norp,            // 1 si no desea calcular Retiro Programado
    real colvector rv,           // Tasa rentabilidad (para Renta Vitalicia)
    real colvector rp,           // Tasa para RP
    real colvector agnotabla,    // Agno de la tabla de mortalidad
    real colvector vagnoactual,  // Agno actual de calculo
    real colvector vfsiniestro,  // Fecha del siniestro (para definicion dinamica de tabla de mortalidad)
    real colvector touse,        // 1 si incluira a observacion en el calculo
    real scalar printlistado,    // 1 si retornara listado de errores
    string scalar path_tm,       // Path a tablas de mortalidad
    string scalar path_v         // Path a tablas de mortalidad
    )
    {
    
    // Definicion de escalares
    real scalar N, sex, edad, nerr_menor_20, nerr_mayor_110, nerr_vector, vecexists, j
    string scalar err_menor_20, err_mayor_110, err_vector
    real colvector cnu
    
    N = rows(x)
    cnu = J(N,1,.)
    
    err_menor_20 = ""
    err_mayor_110 = ""
    err_vector = ""
    nerr_menor_20 = 0
    nerr_mayor_110 = 0
    nerr_vector = 0

    for (j=1 ; j <= N ; j++) { // Puede calcular CNU
        
        /* Verifica si se ha presionado la tecla break 
        accionada por parallel */
        parallel_break()
        
        if (!touse[j]) continue

        edad = x[j,1]
        sex=mujer[j,1]
        
        if (path_v=="")    vecexists = fileexists(c("sysdir_plus")+"c/cnu_vec"+strofreal(agnovec[j]))
        else vecexists = fileexists(path_v+"cnu_vec"+strofreal(agnovec[j]))
        
        if (edad >= 20 & edad <= 110 & vecexists) {
                        
            // Guarda resultado en vector CNU            
            cnu[j,1] = cnu_2_1(edad, sex, tipo_tm[j], agnovec[j], rv[j], rp[j], norp, agnotabla[j], vagnoactual[j], vfsiniestro[j], 0, path_tm, path_v)
        }
        else if (edad < 20) { // No puede calcular CNU por ser menor de 20
            if (nerr_menor_20++ < 20) err_menor_20 = err_menor_20+strofreal(j)+" "
        }
        else if (!vecexists) { // Vector inexistente
            if (nerr_vector++ < 20) err_vector = err_vector+strofreal(j)+" "
        }
        else { // No puede calcular CNU por ser mayor de 110
            if (nerr_mayor_110++ < 20) err_mayor_110 = err_mayor_110+strofreal(j)+" "
        }
    }

    // Pasa listado de obs que no pudo procesar a una local
    if (printlistado) {
        st_local("err_menor_20", err_menor_20)
        st_local("err_mayor_110", err_mayor_110)
        st_local("err_vector", err_vector)
        
        st_local("nerr_menor_20", strofreal(nerr_menor_20))
        st_local("nerr_mayor_110", strofreal(nerr_mayor_110))
        st_local("nerr_vector", strofreal(nerr_vector))
    }
    
    return(cnu)
}

// NOMBRE     : cnu_2_1
// DESCRIPCION: Calcula CNU para afiliado soltero (version escalar)
// RESULTADO  : CNU para afiliado soltero (version escalar)

{smcl}
*! {marker cnu_2_1}{bf:function -{it:cnu_2_1}- in file -{it:cnu_2_1.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real scalar cnu_2_1(
    real scalar x,          // Edad del afiliado
    real scalar mujer,      // Escalar binario (1 si el cotizante es mujer)
    string scalar tipo_tm,  // Tipo de tabla de mortalidad (rv, mi, b)
    real scalar agnovec,    // Agno del vector
    real scalar rv,         // Valor de la tasa para RV
    real scalar rp,
    real scalar norp,       // Dicotomica indicando si calcula o no RP
    real scalar agnotabla,  // Agno de la tabla de mortalidad del cotizante
    real scalar agnoactual, // Agno actual (de calculo)
    real scalar fsiniestro, // Fecha en que ocurre el siniestro (se utiliza para asignar la tabla)
  | real scalar stepprint,
    string scalar path_tm,  // Directorio donde buscar las tablas de mortalidad
    string scalar path_v    
    )
    {
    
    real scalar cnu, lxt, l_x, tmax, i, t
    real colvector qxtmp
    real matrix vec, tabla_mort
    string scalar mujer_tm
    
    // Verifica si desea imprimir resultados en panalla
    if (stepprint == J(1,1,.)) stepprint = 0
    
    // Valor inicial en rv
    l_x = 1

    // N periodos
    tmax = 110 - x + 1

    // Mejoramiento de la tabla
    if (mujer) mujer_tm = "m"
    else mujer_tm = "h"
    
    // Asignacion dinamica de tabla
    if (fsiniestro != 0) agnotabla = cnu_which_tab_mort(fsiniestro, tipo_tm)
    st_local("tipotabla",tipo_tm)
    st_local("agnotabla",strofreal(agnotabla))
    
    tabla_mort = cnu_get_tab_mort(agnotabla, mujer_tm, tipo_tm, path_tm)
    
    qxtmp = cnu_mejorar_tabla(tabla_mort[.,1],tabla_mort[.,2], tabla_mort[.,3], agnotabla, agnoactual, x)
    
    // Genera vector
    if (norp) 
    {
        vec = ((1::191), J(191,1,rv))
    }
    else if (rp != -1e100) 
    {
        vec = ((1::191), J(191,1,rp))
    }
    else 
    {
        vec = cnu_get_vec_tasas(agnovec, path_v)
    }
    
    // Sumatoria
    cnu = 1
    lxt = 1
    i = 0
    // Calcula CNU
    if (stepprint) {
        printf("t = %3.0f: CNU = 1\n", 0)
        for (t=1 ; t<=tmax ; t++) {
            
            lxt = lxt*(1 - qxtmp[x + t - 1])
            i = vec[t,2]
            
            // printf("t = %3.0f: CNU = %9.6f + (%g/%g)/((1 + %g)^%g)\n",t,cnu,lxt,l_x,i,t)
            printf("t = %3.0f: cnu = %9.6f + %g/((1 + %g)^%g)\n", t, cnu , lxt, i, t)
            //cnu = cnu + (lxt/l_x)/((1 + i)^t)
            cnu = cnu + lxt/((1 + i)^t)
        }
    }
    else {
        for (t=1 ; t<=tmax ; t++) {
            
            lxt = lxt*(1 - qxtmp[x + t - 1])
            i = vec[t,2]
                            
            //cnu = cnu + (lxt/l_x)/((1 + i)^t)
            cnu = cnu + lxt/((1 + i)^t)
        }
    }
    return(round((cnu :- 11/24), .000001))
}

end

*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:End of file -cnu_2_1.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:Beginning of file -cnu_proy_cnu.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
mata:
{smcl}
*! {marker cnu_proy_cnu}{bf:function -{it:cnu_proy_cnu}- in file -{it:cnu_proy_cnu.mata}-}
*! {back:{it:(previous page)}}
*!{dup 78:{c -}}{asis}
real colvector function cnu_proy_cnu(
    real scalar x,              // Edad del afiliado
    real scalar y,              // Edad del conyuge
    real scalar cotmujer,       // Escalar binario (1 si el cotizante es mujer)
    real scalar conymujer,      // Escalar binario (1 si el cotizante es mujer)
    string scalar tipo_tm_cot,  // Tipo de tabla de mortalidad (rv, mi, b)
    string scalar tipo_tm_cony, // Tipo de tabla de mortalidad (rv, mi, b)
    real scalar agnovec,        // Agno del vector
    real scalar norp,           // 1 si no corresponde a RP
    real colvector rp,          // Tasa RP a utilizar
    real colvector rv,          // Tasa RV a utilizar
    real scalar agnotabla,      // Agno de la tabla de mortalidad del cotizante
    real scalar agnotablabenef, // Agno de la tabla de mortalidad del cotizante
    real scalar agnoactual,     // Agno actual (de calculo)
    real scalar fsiniestro,     // Fecha en que ocurre el siniestro (se utiliza para asignar la tabla)
  | real scalar stepprint,
    string scalar path_tm,      // Directorio donde buscar las tablas de mortalidad
    string scalar path_v    
    ) {

    // Proyectando CNU
    real colvector cnu, xs, agnosa
    real scalar n
    
    xs     = x::110
    n      = length(xs)
    agnosa = agnoactual::(agnoactual + n-1)
        
    cnu = cnu_2_1_vec(
        xs, J(n,1,cotmujer), J(n,1,tipo_tm_cot), J(n,1,agnovec), norp, rv, rp,
        J(n,1,agnotabla), agnosa,J(n,1,fsiniestro), J(n,1,1), stepprint,
        path_tm, path_v
        )

    // Si es que tiene conyuge
    if (y != .) 
    {
        real colvector ys
        ys  = y::(y+n-1)
            
        cnu = cnu + editmissing(cnu_2_2_vec(
                xs, ys, J(n,1,cotmujer), J(n,1,conymujer),
                J(n,1,tipo_tm_cot), J(n,1,tipo_tm_cony),
                J(n,1,agnovec), norp, rv, rp,
                J(n,1,agnotabla), J(n,1,agnotablabenef),
                agnosa,J(n,1,fsiniestro), J(n,1,1), path_tm, path_v
            ),0)
        
    }            
    return(cnu)
    
}
end
*! {smcl}
*! {c TLC}{dup 78:{c -}}{c TRC}
*! {c |} {bf:End of file -cnu_proy_cnu.mata-}{col 83}{c |}
*! {c BLC}{dup 78:{c -}}{c BRC}
